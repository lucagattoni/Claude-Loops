#!/usr/bin/env bash
# Headless driver for the daily loop-engineering tracker.
#
# Runs the pipeline as TWO sessions inside ONE isolated git worktree:
#   A) /fetch-loop-news    — search; writes .loop-news/findings.json, no commit
#   B) /integrate-loop-news — integrate + restructure + commit + push origin HEAD:main
#
# Isolation: all work happens in a throwaway worktree branched off origin/main, so the
# run never depends on (or disturbs) whatever branch/state the primary checkout is in.
#
# Retry: the worktree is created once per run; each attempt hard-resets the tree to
# origin/main first (the gitignored .loop-news/ survives), so a B failure re-runs only B
# against A's saved findings — search is not repeated. A publish-safety guard refuses to
# retry once origin/main has advanced (a prior attempt already pushed), preventing a
# double-commit of the day's digest.
#
# Post-condition: a successful run must have put a matching commit on origin/main. `claude -p`
# exiting 0 does not prove that — a skill-internal guard aborts the agent's bash block, not the
# process — so scripts/assert-published.sh checks the delta after the retry loop and exits 6 if a
# run that reported success published nothing. scripts/verify-publish-guard.sh proves that check.
#
# One question, one implementation: published_state() below wraps that script and is the only way
# this file asks "has origin/main gained one of our commits since BASE_SHA?" — the pre-flight
# guard, the failure-path guard and the post-run assertion all go through it. It answers three
# ways, not two: published, not-ours, or CANNOT TELL, and each guard has its own conservative
# branch for the third. Exit 7 is the failure-path one: the run failed and we could not determine
# whether it had already published, so it stops rather than risk a second commit.
#
# Exit codes: 0 ok · 1 attempts exhausted / failed after publishing / deterministic stop · 3 no
# usable claude binary · 4 a slash command did not resolve · 5 credit balance · 6 reported success
# but published nothing · 7 failed and could not tell whether it published.
#
# Drop -e: a failed attempt must NOT kill the script — we handle failures explicitly.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$REPO_ROOT/logs"
LOG_FILE="$REPO_ROOT/logs/loop-news-$(date +%Y%m%d).log"   # ABSOLUTE — survives worktree teardown

# Auto-source a local env file if present (gitignored; copy from run-loop-news.env.example).
# Lets you set a standing per-stage default without exporting shell env vars.
[[ -f "$REPO_ROOT/scripts/run-loop-news.env" ]] && source "$REPO_ROOT/scripts/run-loop-news.env"

# ── Per-stage tuning — the ONE place to change any of it, independently ───────────────
#   --model : alias (sonnet|opus|fable) or a full id (e.g. claude-sonnet-5)
#   --effort: low | medium | high | xhigh | max
#   Precedence: CLI flag (see usage() below) > this file / an exported env var > default.
#   Defaults reproduce prior behaviour.
#   Note on --max-budget-usd under a Claude subscription (Pro/Max): it is NOT a real
#   dollar cost — you're not billed per token — it's a script-side tripwire computed from
#   API list-price-equivalent token usage, purely to stop a runaway/looping session. Set
#   it generously; it should only ever trip on a session that is genuinely stuck, not on
#   a normal thorough run.
SEARCH_MODEL="${LOOP_SEARCH_MODEL:-sonnet}"              # Skill A · fetch-loop-news
SEARCH_EFFORT="${LOOP_SEARCH_EFFORT:-high}"
# 100, not 40: raised for headroom alongside INTEGRATE_MAX_TURNS below (no evidence
# search itself needs it — it's a ceiling, so a generous one costs nothing if unused).
SEARCH_MAX_TURNS="${LOOP_SEARCH_MAX_TURNS:-100}"
SEARCH_BUDGET_USD="${LOOP_SEARCH_BUDGET_USD:-30}"
INTEGRATE_MODEL="${LOOP_INTEGRATE_MODEL:-sonnet}"        # Skill B · integrate-loop-news
INTEGRATE_EFFORT="${LOOP_INTEGRATE_EFFORT:-high}"
# 250, not 100: the 2026-07-04 run hit "Reached max turns (40)" twice; raised to 100.
# The 2026-07-06 validation run (74 findings, 9+ docs touched) hit "Reached max turns
# (100)" twice in a row too — a large-batch day genuinely needs more than 100. Same
# rationale as before: this is a ceiling, not a target, so a generous one costs nothing
# on a normal/small day; it only matters on the days it would otherwise fail outright.
INTEGRATE_MAX_TURNS="${LOOP_INTEGRATE_MAX_TURNS:-250}"
INTEGRATE_BUDGET_USD="${LOOP_INTEGRATE_BUDGET_USD:-20}"

# --- Claude binary: resolve it, never assume a path ------------------------------------
# This was hardcoded to /opt/homebrew/bin/claude. The CLI moved to the native installer
# (~/.local/bin/claude) and the constant silently became wrong: every attempt exited 127
# ("No such file or directory"), which matches no ERROR_REGEX, so the run burned all three
# attempts and reported only to a desktop notification and a gitignored log. The whole of
# the 2026-09-05 04:00 UTC scheduled run failed this way before Stage A started.
# Resolve in priority order; an explicit CLAUDE_BIN still wins so an operator can pin one.
resolve_claude_bin() {
  local c
  if [[ -n "${CLAUDE_BIN:-}" ]]; then printf '%s' "$CLAUDE_BIN"; return; fi
  c="$(command -v claude 2>/dev/null)"
  if [[ -n "$c" ]]; then printf '%s' "$c"; return; fi
  for c in "$HOME/.local/bin/claude" /opt/homebrew/bin/claude /usr/local/bin/claude; do
    if [[ -x "$c" ]]; then printf '%s' "$c"; return; fi
  done
  printf ''
}
CLAUDE_BIN="$(resolve_claude_bin)"

# Production incident (2026-07-05): Stage A's parallel per-source subagents (Phase 2 —
# one subagent per tracked source) tripped the CLI's own internal background-task wait
# ceiling ("Background tasks still running after 600s; terminating"), which the CLI's own
# error output says to disable via this env var. Safe to leave uncapped here: the outer
# --max-turns/--max-budget-usd ceilings on each stage still bound the overall session
# even if no individual background wait is capped internally.
export CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS=0

usage() {
  cat <<'USAGE'
Usage: run-loop-news.sh [options]

Per-stage overrides (each defaults to its LOOP_* env var, which defaults to the
built-in default — precedence is: CLI flag > env var > default):

  --search-model <model>       Model for the search stage (fetch-loop-news)
  --search-effort <level>      Effort for the search stage (low|medium|high|xhigh|max)
  --integrate-model <model>    Model for the integrate stage (integrate-loop-news)
  --integrate-effort <level>   Effort for the integrate stage
  --model <model>              Shorthand: set both stages' model at once
  --effort <level>             Shorthand: set both stages' effort at once
  -h, --help                   Show this help and exit

Model accepts an alias (sonnet|opus|fable) or a full model id (e.g. claude-sonnet-5).

Examples:
  run-loop-news.sh --integrate-model opus --integrate-effort max
  run-loop-news.sh --model opus --effort max
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --search-model) SEARCH_MODEL="$2"; shift 2 ;;
    --search-effort) SEARCH_EFFORT="$2"; shift 2 ;;
    --integrate-model) INTEGRATE_MODEL="$2"; shift 2 ;;
    --integrate-effort) INTEGRATE_EFFORT="$2"; shift 2 ;;
    --model) SEARCH_MODEL="$2"; INTEGRATE_MODEL="$2"; shift 2 ;;
    --effort) SEARCH_EFFORT="$2"; INTEGRATE_EFFORT="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

MAX_ATTEMPTS=3
# Seconds to wait before each retry. Index 0 is the wait before attempt 2, index 1 before 3.
BACKOFF_SECONDS=(30 90 180)

# Connection-level error markers that indicate a TRANSIENT failure worth retrying.
# macOS script(1) does not reliably propagate the child exit code, so we also scan the
# attempt's output for these.
ERROR_REGEX='API Error:|ECONNRESET|ETIMEDOUT|Unable to connect to API|Connection closed mid-response|socket hang up|overloaded_error|529 |503 Service'

# --max-budget-usd was exceeded. This is DETERMINISTIC, not transient — retrying re-runs
# the exact same (now over-budget) work and hits the same wall, burning MAX_ATTEMPTS for
# nothing. Checked separately from ERROR_REGEX so the wrapper can stop immediately instead
# of backing off and retrying.
BUDGET_EXCEEDED_REGEX='Exceeded USD budget'

# Claude account (subscription) usage limit hit. Also DETERMINISTIC within this script's
# lifetime — it resets on a wall-clock time (e.g. "resets 7:20pm"), not on a short backoff,
# so all MAX_ATTEMPTS would burn their backoff delays for nothing (observed in production,
# 2026-07-06: 3 attempts, 30s+90s backoff, all hit the same limit instantly). Distinct from
# ERROR_REGEX (that's transient/retriable) and BUDGET_EXCEEDED_REGEX (that's our own
# --max-budget-usd tripwire) — this is Anthropic's own account-level quota.
SESSION_LIMIT_REGEX="You've hit your session limit"

# A slash command that does not resolve prints "Unknown command: /x" and EXITS 0 (verified on
# claude 2.1.261). Both stages are invoked as slash commands, so without this the wrapper would
# log a clean success having executed nothing — a green silence, worse than a crash. Deterministic:
# a skill that is absent from the checked-out tree stays absent, so retrying cannot help.
UNKNOWN_COMMAND_REGEX="Unknown command: /"

# "Credit balance is too low" is what a pay-as-you-go API key with no credit returns while it
# shadows the claude.ai subscription. Deterministic — it cannot resolve inside a run — but it was
# absent from every regex, so the 2026-07-20 outage burned all three attempts and ~2h of backoff
# before reporting. Distinct from BUDGET_EXCEEDED (our own --max-budget-usd tripwire).
CREDIT_BALANCE_REGEX="Credit balance is too low"

# Match OUR published commit, anchored to the subject line the skill actually emits
# ("feat: loop news run <time> — <N> findings..."). Previously an unanchored substring search over
# `git log --oneline`, which also matched a Revert of that commit, and any human commit whose
# subject merely mentioned the phrase — either of which would be misread as "Stage B already
# published" and abandon a legitimately retriable failure.
OUR_COMMIT_REGEX="^feat: loop news run "

stamp() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# published_state <git-dir> — has origin/main gained one of OUR commits since BASE_SHA?
#
# THE ONE implementation of that question (A14). Three call sites ask it: the pre-flight guard, the
# failure-path publish-safety guard, and the post-run assertion. They used to ask it three ways —
# two of them with a bare `git log "${BASE_SHA}..${NEW}" | grep -qE`, which is WRONG in a way that
# only shows up after a history rewrite: `git log A..B` requires the two objects to exist, not that
# A is an ancestor of B. A force-pushed origin/main leaves BASE_SHA as a loose object for
# gc.pruneExpire (two weeks), so the range silently becomes "the new history minus the old one" and
# a stray `feat: loop news run ` subject in it matched — reported as "we published". Proven while
# shipping A13. assert-published.sh has the ancestry precondition; these two guards did not, so the
# fix is to stop re-implementing the question rather than to paste `merge-base` in three places.
#
# Returns assert-published.sh's code verbatim: 0 published · 1 checked, not ours · 2 CANNOT TELL.
# ANY OTHER CODE means the checker itself did not run — a missing or unreadable script is rc 127
# from bash, not a verdict — and callers must treat it exactly like 2. So enumerate 0 and 1, and
# make the catch-all fail closed: a `*)` arm that means "checked cleanly" is a fabricated result.
# Sets MAIN_SHA_NOW to the freshly-fetched origin/main (empty when it could not be resolved) and
# ASSERT_OUT to the diagnostic, so callers can log which guard fired without re-running anything.
# assert-published.sh does the fetch, with its own bounded retry, so callers must not fetch first.
published_state() {
  local dir="$1"
  ASSERT_OUT="$(bash "$REPO_ROOT/scripts/assert-published.sh" "$dir" "$BASE_SHA" "$OUR_COMMIT_REGEX" 2>&1)"
  local rc=$?
  MAIN_SHA_NOW="$(git -C "$dir" rev-parse --verify --quiet origin/main)" || MAIN_SHA_NOW=""
  return "$rc"
}

# Best-effort desktop notification + log line. Never fails the script.
notify() {
  local msg="$1"
  echo "[$(stamp)] NOTIFY: ${msg}" | tee -a "$LOG_FILE"
  osascript -e "display notification \"${msg}\" with title \"loop-news tracker\"" >/dev/null 2>&1 || true
}

# --- Preflight: a shadowing API key is what caused the 2026-07-20 outage ---------------
# A pay-as-you-go ANTHROPIC_API_KEY takes precedence over the claude.ai login, and when it has no
# credit every attempt dies with "Credit balance is too low". Warn rather than unset: silently
# editing the operator's environment would hide a deliberate key. LOOP_ALLOW_API_KEY=1 silences it.
if [[ -n "${ANTHROPIC_API_KEY:-}" && "${LOOP_ALLOW_API_KEY:-0}" != "1" ]]; then
  notify "WARNING: ANTHROPIC_API_KEY is set and takes precedence over the claude.ai login. If it has no credit every attempt will fail. Unset it, or set LOOP_ALLOW_API_KEY=1 to silence this."
fi

# --- Preflight: fail fast and loudly on a missing binary ------------------------------
# Deliberately NOT a retriable failure. A missing binary is deterministic: three attempts
# with backoff cannot fix it, they only delay the report by two minutes. Exit 3 is distinct
# from 1 (attempts failed) so a caller can tell "never started" from "tried and failed".
if [[ -z "$CLAUDE_BIN" || ! -x "$CLAUDE_BIN" ]]; then
  notify "FATAL: no usable claude binary (resolved to '${CLAUDE_BIN:-<nothing>}'). Set CLAUDE_BIN in scripts/run-loop-news.env, or put claude on PATH. Not retrying — this never resolves on its own."
  exit 3
fi
# Record the binary AND the version behind it. `claude` is normally a symlink into
# ~/.local/share/claude/versions/<v>, and the auto-updater can repoint it BETWEEN stages — so the
# path alone says nothing about what actually ran. Observed 2026-09-06: Stage A ran 2.1.261 and
# Stage B ran 2.1.263, and nothing anywhere recorded it. A version change mid-run is not a failure,
# but it IS a confounder (different behaviour, and on macOS a per-binary firewall rule that the new
# path does not inherit), so it must be visible rather than inferred afterwards from file mtimes.
CLAUDE_REAL="$(cd "$(dirname "$CLAUDE_BIN")" && readlink "$(basename "$CLAUDE_BIN")" 2>/dev/null || printf '%s' "$CLAUDE_BIN")"
# Returns a bare semver, or nothing. Anything that is not a version — a broken binary, an
# unexpected banner, an error on stdout — yields EMPTY rather than a garbage token, because a
# garbage token compares unequal and would raise a false drift alarm on every stage.
claude_version() {
  "$CLAUDE_BIN" --version 2>/dev/null | awk '{print $1}' | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+$' || true
}
CLAUDE_VERSION_START="$(claude_version)"
echo "[$(stamp)] Using claude binary: $CLAUDE_BIN -> ${CLAUDE_REAL} (version ${CLAUDE_VERSION_START:-unknown})" | tee -a "$LOG_FILE"
if [[ -z "$CLAUDE_VERSION_START" ]]; then
  # Could not tell. Say so loudly rather than recording a blank and moving on.
  notify "WARNING: could not read \`claude --version\` at startup. The run continues, but its version provenance is unknown."
fi

# --- Worktree: one per run, so findings.json survives across attempts ----------------
git -C "$REPO_ROOT" worktree prune                          # clear any orphan from a crash
git -C "$REPO_ROOT" fetch origin main
BASE_SHA="$(git -C "$REPO_ROOT" rev-parse origin/main)"     # captured ONCE, before any attempt

WT_PARENT="$(mktemp -d -t loop-news-wt.XXXXXX)"; WT_DIR="$WT_PARENT/wt"   # add needs a non-existent leaf
# Stable per UTC day, not per invocation: a run that dies mid-integration leaves its checkpoint
# commits on this branch, and the next run today finds them by name and continues.
TEMP_BRANCH="loop-news-run-$(date -u +%Y%m%d)"

# Set once the run has published: stops cleanup re-creating the resume artifact it just retired.
ARTIFACT_CONSUMED=0

cleanup() {
  # Preserve the artifact so the next run can RESUME from it instead of re-searching — unless this
  # run already published it, in which case re-creating it here would hand the next run a set that
  # is already in main and produce a duplicate digest. cleanup runs on EXIT, i.e. AFTER the success
  # path, so without this guard it silently undoes the consume. (Caught by asserting on the files
  # on disk; the success path's own log line said "consumed" and was telling the truth. NOTE: that
  # was a hand check, not an automated one. This comment claimed "a test" until the 20260907
  # handover audit looked for it. A13 has since put scripts/verify-publish-guard.sh in the repo,
  # but be precise about what that reaches: it proves assert-published.sh's logic, and statically
  # proves WHERE the wrapper calls it from. It never executes this function. cleanup()'s behaviour
  # on the new exit-6 path — ARTIFACT_CONSUMED still 0, so the artifact is preserved and the
  # branch kept — is read from this code, not run, and stays a hand check.)
  # UTC to match SEED_ARTIFACT — a local-time name would split the pair either side of midnight.
  if (( ! ARTIFACT_CONSUMED )) && [[ -f "$WT_DIR/.loop-news/findings.json" ]]; then
    cp "$WT_DIR/.loop-news/findings.json" "$REPO_ROOT/logs/findings-$(date -u +%Y%m%d).json" 2>/dev/null || true
  fi
  git -C "$REPO_ROOT" worktree remove --force "$WT_DIR" 2>/dev/null || rm -rf "$WT_PARENT"
  # Keep the branch when it carries unpushed Stage-B checkpoints — it IS the resume state, and
  # deleting it here would discard exactly the work the checkpoints exist to protect. Deleted only
  # once the run has published, or when it never committed anything.
  if (( ARTIFACT_CONSUMED )) || [[ -z "$(git -C "$REPO_ROOT" log --oneline "${BASE_SHA}..${TEMP_BRANCH}" 2>/dev/null)" ]]; then
    git -C "$REPO_ROOT" branch -D "$TEMP_BRANCH" 2>/dev/null || true
  else
    echo "[$(stamp)] Kept branch ${TEMP_BRANCH} — it holds $(git -C "$REPO_ROOT" rev-list --count "${BASE_SHA}..${TEMP_BRANCH}" 2>/dev/null) Stage-B checkpoint commit(s). The next run today resumes from it." | tee -a "$LOG_FILE"
  fi
}
trap cleanup EXIT

# Resume Stage B when a previous run today left checkpoints on the per-day branch; otherwise
# start clean from origin/main.
STAGE_B_RESUMED=0
if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$TEMP_BRANCH" \
   && [[ -n "$(git -C "$REPO_ROOT" log --oneline "${BASE_SHA}..${TEMP_BRANCH}" 2>/dev/null)" ]]; then
  git -C "$REPO_ROOT" worktree add "$WT_DIR" "$TEMP_BRANCH"
  STAGE_B_RESUMED=1
else
  git -C "$REPO_ROOT" branch -D "$TEMP_BRANCH" 2>/dev/null || true   # empty leftover, if any
  git -C "$REPO_ROOT" worktree add -b "$TEMP_BRANCH" "$WT_DIR" origin/main
fi

# artifact_valid <path> — true when the file is a Stage-A artifact this run may use: parses as
# JSON, declares the schema this wrapper understands, is stamped with the current UTC date, and
# carries at least one finding. Checked as a whole because each part fails differently: a truncated
# write parses but has no findings; yesterday's artifact parses and has findings; a schema bump
# would silently change field meanings. Any failure is false — an unreadable artifact is never
# treated as an absent one, and never as a usable one.
artifact_state() {
  local f="$1"
  [[ -f "$f" ]] || { echo "absent"; return; }
  python3 - "$f" "$(date -u +%Y-%m-%d)" <<'EOF' 2>/dev/null || echo "unusable"
import json,sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    print("unusable"); sys.exit(0)
if d.get("schema") != 1 or d.get("today") != sys.argv[2] or not isinstance(d.get("findings"), list):
    print("unusable"); sys.exit(0)
# "complete" is written by Phase 4 of fetch-loop-news. Artifacts predating the field were only
# ever written at the end of a run, so treat its absence as complete — the alternative would
# re-search every historical artifact.
print("complete" if d.get("complete", True) else "partial")
EOF
}

# Complete = Stage A finished; the attempt loop may skip search entirely.
# NOTE: a zero-finding day is a legitimate COMPLETE artifact — fetch-loop-news is required to
# write `"findings": []` rather than nothing. Inferring completeness from a non-empty findings
# array (as an earlier revision of this function did) re-ran the whole 23-minute search three
# times on a genuinely quiet day.
artifact_complete() { [[ "$(artifact_state "$1")" == "complete" ]]; }

# Partial = Stage A died mid-sweep but banked some sources. Worth seeding: the skill reads
# sources_done and resumes from there instead of re-sweeping what it already has.
artifact_partial()  { [[ "$(artifact_state "$1")" == "partial"  ]]; }

# Either shape is worth carrying into the new worktree.
artifact_usable()   { case "$(artifact_state "$1")" in complete|partial) return 0;; *) return 1;; esac; }

# The in-worktree artifact — what the attempt loop consults to decide "skip Stage A".
# Only a COMPLETE artifact skips it; a partial one still runs Stage A, which resumes from it.
findings_valid() { artifact_complete "$WT_DIR/.loop-news/findings.json"; }

# --- Stage-A resume: reuse today's search rather than paying for it twice ---------------
# Stage A costs ~23 minutes and up to $SEARCH_BUDGET_USD. Its artifact already survived every
# previous run (cleanup copies it to logs/), but nothing ever read it back, so any failure after
# Stage A — a session limit, a killed process, a machine reboot — re-ran the whole search.
#
# The trap this closes: a SUCCESSFUL run also leaves an artifact behind. Seeding from it blindly
# would re-integrate findings that are already published and emit a duplicate digest. So the
# artifact is marked consumed the moment a run publishes, and only an unconsumed one is reused.
SEED_ARTIFACT="$REPO_ROOT/logs/findings-$(date -u +%Y%m%d).json"
CONSUMED_ARTIFACT="$REPO_ROOT/logs/findings-$(date -u +%Y%m%d).consumed.json"

if [[ "${LOOP_FORCE_SEARCH:-0}" == "1" ]]; then
  echo "[$(stamp)] LOOP_FORCE_SEARCH=1 — ignoring any saved artifact, Stage A will run" | tee -a "$LOG_FILE"
elif artifact_usable "$SEED_ARTIFACT"; then
  mkdir -p "$WT_DIR/.loop-news"
  cp "$SEED_ARTIFACT" "$WT_DIR/.loop-news/findings.json"
  _n="$(python3 -c 'import json,sys;d=json.load(open(sys.argv[1]));print(len(d["findings"]), len(d.get("sources_done",[])))' "$SEED_ARTIFACT" 2>/dev/null)"
  if artifact_complete "$SEED_ARTIFACT"; then
    echo "[$(stamp)] RESUME (complete): reusing today's unconsumed Stage-A artifact (${_n% *} findings) — skipping search. LOOP_FORCE_SEARCH=1 to re-search." | tee -a "$LOG_FILE"
  else
    echo "[$(stamp)] RESUME (partial): Stage A died mid-sweep — ${_n% *} findings from ${_n#* } sources already banked. Stage A will run and continue from there." | tee -a "$LOG_FILE"
  fi
  unset _n
elif [[ -f "$SEED_ARTIFACT" ]]; then
  echo "[$(stamp)] A saved artifact exists but is not usable (wrong date, wrong schema, empty, or unreadable) — Stage A will run" | tee -a "$LOG_FILE"
fi

# run_claude <label> <claude-args...> — run one session in the worktree via a PTY (so
# claude flushes line-by-line), fold its output into the day log, and return success =
# exit 0 AND no transient-error marker. Sets the global BUDGET_EXCEEDED=1 / SESSION_LIMIT=1
# (and does NOT reset either — the caller must check right after the call) when their
# respective markers are seen, so the outer loop can stop instead of retrying a
# deterministic (non-transient, backoff-won't-help) failure.
BUDGET_EXCEEDED=0
UNKNOWN_COMMAND=0
CREDIT_BALANCE=0
SESSION_LIMIT=0
run_claude() {
  local label="$1"; shift
  local tmp; tmp="$(mktemp -t loop-news-attempt.XXXXXX)"
  local v_now; v_now="$(claude_version)"
  echo "[$(stamp)] ${label} starting (claude ${v_now:-unknown})" | tee -a "$LOG_FILE"
  if [[ -n "$v_now" && -n "$CLAUDE_VERSION_START" && "$v_now" != "$CLAUDE_VERSION_START" ]]; then
    # Deliberately NOT fatal: Claude Code updates often, and aborting would skip a day's run every
    # time it did. But the run's output is now split across two binaries, so the record must say so.
    echo "[$(stamp)] VERSION DRIFT: run started on ${CLAUDE_VERSION_START}, ${label} is running ${v_now}" | tee -a "$LOG_FILE"
    notify "Claude Code changed mid-run: started ${CLAUDE_VERSION_START}, ${label} on ${v_now}. The run continues. Re-check anything this stage published — a new binary does not inherit a per-binary firewall rule, and stage behaviour may differ."
  fi
  ( cd "$WT_DIR" && script -q "$tmp" "$CLAUDE_BIN" --permission-mode auto "$@" )
  local code=$?
  cat "$tmp" >> "$LOG_FILE"
  local transient="no"
  grep -Eq "$ERROR_REGEX" "$tmp" && transient="yes"
  if grep -Eq "$BUDGET_EXCEEDED_REGEX" "$tmp"; then BUDGET_EXCEEDED=1; fi
  if grep -Fq "$SESSION_LIMIT_REGEX" "$tmp"; then SESSION_LIMIT=1; fi
  if grep -Fq "$UNKNOWN_COMMAND_REGEX" "$tmp"; then UNKNOWN_COMMAND=1; fi
  if grep -Fq "$CREDIT_BALANCE_REGEX" "$tmp"; then CREDIT_BALANCE=1; fi
  rm -f "$tmp"
  if (( UNKNOWN_COMMAND )); then
    echo "[$(stamp)] ${label} invoked a slash command that does not resolve (claude exited ${code} regardless)" | tee -a "$LOG_FILE"
    return 1
  fi
  if [[ $code -eq 0 && $transient == "no" ]]; then return 0; fi
  echo "[$(stamp)] ${label} failed (exit=${code}, transient=${transient}, budget_exceeded=${BUDGET_EXCEEDED}, session_limit=${SESSION_LIMIT})" | tee -a "$LOG_FILE"
  return 1
}

# Per-stage claude arg arrays — every per-stage difference lives here (model/effort/turns/
# budget, plus A-uses-Chrome vs B-uses-git); run_claude just wraps PTY + transient scan.
A_ARGS=(--model "$SEARCH_MODEL" --effort "$SEARCH_EFFORT"
        --max-turns "$SEARCH_MAX_TURNS" --max-budget-usd "$SEARCH_BUDGET_USD" --chrome
        --allowedTools "Read,Edit,Write,WebFetch,mcp__claude-in-chrome__*"
        --disallowedTools "Bash(git *),Bash(gh *),Skill" -p "/fetch-loop-news")
B_ARGS=(--model "$INTEGRATE_MODEL" --effort "$INTEGRATE_EFFORT"
        --max-turns "$INTEGRATE_MAX_TURNS" --max-budget-usd "$INTEGRATE_BUDGET_USD"
        --allowedTools "Read,Edit,Write,WebFetch,Bash(git *),Bash(uv *),Bash(bash scripts/kb-structure-check.sh*)" -p "/integrate-loop-news")

echo "[$(stamp)] Starting loop-news run (worktree $WT_DIR, base $BASE_SHA)" | tee -a "$LOG_FILE"
if (( STAGE_B_RESUMED )); then
  echo "[$(stamp)] RESUME (stage B): $(git -C "$WT_DIR" rev-list --count "${BASE_SHA}..HEAD") checkpoint commit(s) already on ${TEMP_BRANCH} — integration continues from there." | tee -a "$LOG_FILE"
fi

attempt=1; success=0
while (( attempt <= MAX_ATTEMPTS )); do
  # Isolate this attempt: discard a failed attempt's partial TRACKED edits. The gitignored
  # .loop-news/ (findings.json) is untracked+ignored, so reset/clean leave it intact.
  git -C "$WT_DIR" fetch origin main
  # Discard a failed attempt's UNCOMMITTED edits, but keep any Stage-B checkpoint commits — those
  # are the resume state. Resetting to origin/main here (as this did) threw them away every retry.
  if [[ -n "$(git -C "$WT_DIR" log --oneline "${BASE_SHA}..HEAD" 2>/dev/null)" ]]; then
    git -C "$WT_DIR" reset --hard HEAD
  else
    git -C "$WT_DIR" reset --hard origin/main
  fi
  git -C "$WT_DIR" clean -fd            # NOT -x → keeps ignored .loop-news/

  # Reset ALL FOUR deterministic-failure markers, not two. run_claude() sets them by grepping the
  # whole transcript and returns 0 anyway for three of them, while CREDIT_BALANCE and
  # UNKNOWN_COMMAND were initialised once, globally — so a marker string appearing in a SUCCESSFUL
  # stage's transcript survived into later attempts and could exit the run with a notify() telling
  # the operator to wait for a quota reset that never happened. Retry behaviour and artifact
  # preservation were identical either way, so this is diagnostic accuracy, not a safety fix — but
  # A14's pre-flight cannot-tell path is a new way to reach the wrong message instead of exit 7's.
  ok=1; BUDGET_EXCEEDED=0; SESSION_LIMIT=0; CREDIT_BALANCE=0; UNKNOWN_COMMAND=0
  # STAGE A — search; skipped entirely if a valid artifact already exists (B-only retry)
  if ! findings_valid; then
    run_claude "attempt ${attempt}/${MAX_ATTEMPTS} · A (search)" "${A_ARGS[@]}" || ok=0
    findings_valid || ok=0             # A must have produced a usable artifact
  else
    echo "[$(stamp)] attempt ${attempt}: valid findings.json present — skipping search" | tee -a "$LOG_FILE"
  fi

  # Cheap, zero-LLM-cost guard: if Stage A's own session already carried the pipeline
  # through and pushed (a known failure mode — see fetch-loop-news/SKILL.md Phase 4),
  # skip Stage B instead of paying for a full redundant session. Checks for a MATCHING
  # loop-news commit in the delta, not just "did origin/main move" — main can legitimately
  # advance for an unrelated reason (e.g. a human merging a different PR concurrently,
  # which is common in this repo), and that must NOT be mistaken for "this run already
  # published" — doing so would silently skip a day's digest that was never written.
  if (( ok )); then
    published_state "$WT_DIR"; rc_pre=$?
    case "$rc_pre" in
      0)
        echo "[$(stamp)] attempt ${attempt}: origin/main already has a loop-news commit — Stage B would be redundant, skipping" | tee -a "$LOG_FILE"
        success=1; break
        ;;
      2)
        # CANNOT TELL. Do not run Stage B on an unanswerable state: if main really does already
        # carry today's digest, a redundant Stage B publishes a duplicate — a durable artifact
        # someone has to unpick by hand. Marking the attempt failed hands the decision to the
        # failure-path guard below, which is the single place that decides retry-or-stop, instead
        # of adding a second one here. Before A14 this branch did not exist and the state was
        # misread as "we published", skipping the day silently.
        echo "[$(stamp)] attempt ${attempt}: ${ASSERT_OUT}" | tee -a "$LOG_FILE"
        echo "[$(stamp)] attempt ${attempt}: cannot tell whether origin/main already carries this run — not starting Stage B" | tee -a "$LOG_FILE"
        ok=0
        ;;
      1)
        # Checked cleanly, and the commit is not ours. If main moved anyway, a human merged
        # something concurrently — rebase our notion of "base" forward so the publish-safety guard
        # below does not later mistake that same unrelated advance for "our run already published."
        if [[ -n "$MAIN_SHA_NOW" && "$MAIN_SHA_NOW" != "$BASE_SHA" ]]; then
          echo "[$(stamp)] attempt ${attempt}: origin/main advanced for an unrelated reason — continuing" | tee -a "$LOG_FILE"
          BASE_SHA="$MAIN_SHA_NOW"
        fi
        ;;
      *)
        # The checker did not run at all — bash returns 127 when scripts/assert-published.sh is
        # missing from $REPO_ROOT, which is the PRIMARY checkout that this repo's own rules warn
        # another agent may check out to an older commit mid-run. Not a verdict, so never read as
        # one. Same action as 2.
        echo "[$(stamp)] attempt ${attempt}: assert-published.sh returned an unexpected status ${rc_pre} — the check did not run: ${ASSERT_OUT}" | tee -a "$LOG_FILE"
        ok=0
        ;;
    esac
  fi

  # STAGE B — integrate + restructure + commit + push (only if A stage is good)
  if (( ok )); then
    run_claude "attempt ${attempt}/${MAX_ATTEMPTS} · B (integrate)" "${B_ARGS[@]}" \
      && { success=1; break; } || ok=0
  fi

  # --- budget-exceeded is DETERMINISTIC: never retry (would just hit the same wall) ---
  if (( BUDGET_EXCEEDED )); then
    notify "Attempt ${attempt} exceeded its --max-budget-usd — not retrying (this always recurs). Raise LOOP_SEARCH_BUDGET_USD / LOOP_INTEGRATE_BUDGET_USD."
    exit 1
  fi

  # --- session limit is an account-level quota that resets on a clock, not a backoff:
  # never retry within this script run (the reset time is printed in the log for a human).
  if (( CREDIT_BALANCE )); then
    notify "FATAL: 'Credit balance is too low' — an API key with no credit is shadowing the claude.ai subscription. Not retrying (deterministic). Unset ANTHROPIC_API_KEY, or top up the key."
    exit 5
  fi
  if (( UNKNOWN_COMMAND )); then
    notify "FATAL: a stage invoked a slash command that does not resolve — the skill is missing from the checked-out tree. Not retrying (deterministic). Check .claude/skills/ on origin/main."
    exit 4
  fi
  if (( SESSION_LIMIT )); then
    notify "Attempt ${attempt} hit the Claude account session limit — not retrying (resets on a clock, not a backoff). Re-run manually after the reset time (see log)."
    exit 1
  fi

  # --- failure path: publish-safety guard before any retry ---
  # Same false-positive risk as the Stage-A guard above: origin/main can advance for an
  # unrelated reason (a concurrently-merged human PR), which must not be mistaken for
  # "our push already happened" — that would wrongly abandon a legitimately retriable
  # failure. Check for a matching loop-news commit in the delta, not just "did it move."
  published_state "$REPO_ROOT"; rc_fail=$?
  case "$rc_fail" in
    0)
      notify "Attempt ${attempt} failed AFTER publishing (origin/main has our loop-news commit) — not retrying; check repo state."
      exit 1                           # B already pushed → never retry (would double-commit)
      ;;
    2)
      # CANNOT TELL, so do not retry the PUSH. This guard exists to stop a second publish, and the
      # whole point of a retry here is to push again — doing that blind after a history rewrite is
      # exactly how the digest gets committed twice. Losing the day is recoverable: cleanup()
      # preserves Stage A's artifact and any Stage-B checkpoints, so tomorrow resumes cheaply,
      # whereas a duplicate commit on main is unpicked by hand.
      #
      # BE PRECISE ABOUT THE BACKSTOP — it is weaker than it sounds, and this comment is the ground
      # for the trade-off. check-digest-freshness.sh runs at 09:00 UTC against MAX_AGE_HOURS 48
      # while the tracker fires 04:00-05:00 UTC, so a SINGLE lost day reads ~29h old and the
      # watchdog prints FRESH — it pages nobody. Only a second consecutive miss (~53h) crosses the
      # threshold. Until then the only signal is notify(): a desktop popup and a gitignored day
      # log, both on the machine that failed. So this trades a possibly silent lost day against a
      # certain duplicate commit, and takes the silent one knowingly.
      #
      # Re-check once before giving up. Retrying the CHECK is not retrying the PUSH, so the safety
      # property is untouched: assert-published.sh's own window is 3 tries x 2s, far shorter than
      # this loop's own backoff, and a transient blip deserves that backoff while a genuine rewrite
      # simply answers 2 again.
      echo "[$(stamp)] ${ASSERT_OUT}" | tee -a "$LOG_FILE"
      wait_recheck="${BACKOFF_SECONDS[$((attempt - 1))]}"
      echo "[$(stamp)] publish-safety check could not tell — re-reading (not re-pushing) in ${wait_recheck}s before giving up" | tee -a "$LOG_FILE"
      sleep "$wait_recheck"
      published_state "$REPO_ROOT"; rc_recheck=$?
      if (( rc_recheck == 0 )); then
        notify "Attempt ${attempt} failed AFTER publishing (the re-check confirmed our commit on origin/main) — not retrying; check repo state."
        exit 1
      elif (( rc_recheck == 1 )); then
        echo "[$(stamp)] re-check settled it: nothing of ours on origin/main — continuing to retry" | tee -a "$LOG_FILE"
        if [[ -n "$MAIN_SHA_NOW" && "$MAIN_SHA_NOW" != "$BASE_SHA" ]]; then BASE_SHA="$MAIN_SHA_NOW"; fi
      else
        echo "[$(stamp)] ${ASSERT_OUT}" | tee -a "$LOG_FILE"
        notify "Attempt ${attempt} failed and the publish-safety check still could not tell whether we published (status ${rc_recheck}) — not retrying, because retrying blind is how the digest gets committed twice. Stage A's artifact and any checkpoints on ${TEMP_BRANCH} are preserved. See ${LOG_FILE}."
        exit 7
      fi
      ;;
    1)
      # Checked cleanly, nothing of ours on main. If it moved, a human merged something
      # concurrently — rebase forward and keep retrying rather than abandoning a retriable failure.
      if [[ -n "$MAIN_SHA_NOW" && "$MAIN_SHA_NOW" != "$BASE_SHA" ]]; then
        echo "[$(stamp)] origin/main advanced for an unrelated reason during attempt ${attempt} — continuing" | tee -a "$LOG_FILE"
        BASE_SHA="$MAIN_SHA_NOW"
      fi
      ;;
    *)
      # The checker did not run (127 = the script is not on disk; anything else is off-contract).
      # Falling through to the retry below would push again without ever having asked whether we
      # already published — the one thing this guard exists to prevent, reached through a side door.
      echo "[$(stamp)] ${ASSERT_OUT}" | tee -a "$LOG_FILE"
      notify "Attempt ${attempt} failed and the publish-safety check itself did not run (status ${rc_fail}) — not retrying. Is scripts/assert-published.sh present in ${REPO_ROOT}? Stage A's artifact and any checkpoints on ${TEMP_BRANCH} are preserved. See ${LOG_FILE}."
      exit 7
      ;;
  esac
  if (( attempt < MAX_ATTEMPTS )); then
    wait_s="${BACKOFF_SECONDS[$((attempt - 1))]}"
    echo "[$(stamp)] Clean failure (nothing published) — backing off ${wait_s}s" | tee -a "$LOG_FILE"
    sleep "$wait_s"
  fi
  (( attempt++ ))
done

if (( ! success )); then
  notify "All ${MAX_ATTEMPTS} attempts failed — no digest today. Re-run manually when the API is healthy."
  exit 1
fi

# --- A13: assert on the ARTIFACT, never on Stage B's exit status ----------------------
# `success` above means only that run_claude() saw `claude -p` exit 0 with no transient-error
# marker in its transcript. That is true of a genuine publish — and equally true when a
# skill-internal guard aborts: Phase 5c's build gate and Phase 5d's digest guard in
# integrate-loop-news/SKILL.md `exit 1` the agent's own bash BLOCK, not the `claude -p` process,
# so a session that printed FATAL and then ended its turn cleanly arrives here with success=1 and
# nothing on origin/main. A green run that shipped nothing is this repo's eight-week-outage shape
# exactly, so the script does not get to say the run completed until it has checked the durable
# artifact instead of assuming it. C4 is what makes the check possible: every run commits now,
# including a zero-finding one, so a matching commit in the delta is a reliable post-condition.
#
# The check lives in scripts/assert-published.sh, reached through published_state() like the
# pre-flight and failure-path guards, so scripts/verify-publish-guard.sh proves the thing that
# actually runs rather than a copy that can drift from it. Any non-zero is treated the same
# (1 = checked, no commit; 2 = could not check at all): an assertion that could not confirm a
# publish has not confirmed one.
#
# THIS BLOCK MUST STAY HERE — after the retry loop's failure exit above, and before both the
# run-complete line and the retirement block below (`rm -f "$SEED_ARTIFACT"`; `ARTIFACT_CONSUMED=1`).
# That flag also disarms cleanup()'s resume-preservation copy of findings.json into logs/, so an
# assertion placed after retirement would destroy Stage A's ~23-minute search on the exact failure
# it exists to catch, turning a cheap resumed re-run into a full re-search — against this repo's
# "every expensive stage must be resumable" rule. verify-publish-guard.sh's case 8 checks the
# placement and ordering; case 10 pins the arguments, once, inside published_state(). Re-run it if
# you touch this block or that script.
#
# ON "LOUDLY": notify() is an osascript popup plus this machine's gitignored day log. The only
# off-machine signal remains scripts/check-digest-freshness.sh under tracker-watchdog.yml (daily,
# MAX_AGE_HOURS 48), so a non-publish caught here can still be invisible elsewhere for up to 48h.
# Widening notify() is a separate, larger question this change deliberately does not answer.
if published_state "$REPO_ROOT"; then
  echo "[$(stamp)] ${ASSERT_OUT}" | tee -a "$LOG_FILE"
else
  ASSERT_RC=$?
  echo "[$(stamp)] ${ASSERT_OUT}" | tee -a "$LOG_FILE"
  notify "FATAL: every attempt reported success but nothing was published — origin/main carries no commit matching '${OUR_COMMIT_REGEX}' since ${BASE_SHA} (assert-published.sh exit ${ASSERT_RC}). Not retrying: the retry loop above has already run. Stage A's findings artifact and any Stage-B checkpoints on ${TEMP_BRANCH} are PRESERVED for a resumed re-run. See ${LOG_FILE}."
  exit 6
fi

echo "[$(stamp)] Run complete (succeeded on attempt ${attempt})" | tee -a "$LOG_FILE"

# Retire the artifact so a later run today re-searches instead of republishing this set.
# Renamed rather than deleted: it stays available for post-mortem, just not for resume.
if [[ -f "$WT_DIR/.loop-news/findings.json" ]]; then
  cp "$WT_DIR/.loop-news/findings.json" "$CONSUMED_ARTIFACT" 2>/dev/null || true
fi
rm -f "$SEED_ARTIFACT"
ARTIFACT_CONSUMED=1
echo "[$(stamp)] Stage-A artifact marked consumed ($(basename "$CONSUMED_ARTIFACT"))" | tee -a "$LOG_FILE"

# --- success path: align the primary checkout if B published and it's on main ---
git -C "$REPO_ROOT" fetch origin main
if [[ "$(git -C "$REPO_ROOT" rev-parse origin/main)" != "$BASE_SHA" ]] && \
   [[ "$(git -C "$REPO_ROOT" symbolic-ref --quiet --short HEAD)" == "main" ]]; then
  git -C "$REPO_ROOT" pull --ff-only origin main | tee -a "$LOG_FILE"
fi
exit 0
