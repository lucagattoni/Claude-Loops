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
# 100, not 40: the 2026-07-04 production run hit "Reached max turns (40)" twice in a row
# on Stage B — Phase 4 (digest + integrate) + 4b + the MANDATORY every-run 4c structural
# review + Phase 5 release/commit/push is real work that a normal day can exceed 40 turns
# on. 60 was the plan's documented fallback; raised further to 100 for more headroom.
INTEGRATE_MAX_TURNS="${LOOP_INTEGRATE_MAX_TURNS:-100}"
INTEGRATE_BUDGET_USD="${LOOP_INTEGRATE_BUDGET_USD:-20}"

CLAUDE_BIN="${CLAUDE_BIN:-/opt/homebrew/bin/claude}"

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

stamp() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# Best-effort desktop notification + log line. Never fails the script.
notify() {
  local msg="$1"
  echo "[$(stamp)] NOTIFY: ${msg}" | tee -a "$LOG_FILE"
  osascript -e "display notification \"${msg}\" with title \"loop-news tracker\"" >/dev/null 2>&1 || true
}

# --- Worktree: one per run, so findings.json survives across attempts ----------------
git -C "$REPO_ROOT" worktree prune                          # clear any orphan from a crash
git -C "$REPO_ROOT" fetch origin main
BASE_SHA="$(git -C "$REPO_ROOT" rev-parse origin/main)"     # captured ONCE, before any attempt

WT_PARENT="$(mktemp -d -t loop-news-wt.XXXXXX)"; WT_DIR="$WT_PARENT/wt"   # add needs a non-existent leaf
TEMP_BRANCH="loop-news-run-$(date -u +%Y%m%d-%H%M%S)"

cleanup() {
  # Preserve the artifact for post-mortem before the worktree vanishes.
  [[ -f "$WT_DIR/.loop-news/findings.json" ]] && \
    cp "$WT_DIR/.loop-news/findings.json" "$REPO_ROOT/logs/findings-$(date +%Y%m%d).json" 2>/dev/null || true
  git -C "$REPO_ROOT" worktree remove --force "$WT_DIR" 2>/dev/null || rm -rf "$WT_PARENT"
  git -C "$REPO_ROOT" branch -D "$TEMP_BRANCH" 2>/dev/null || true
}
trap cleanup EXIT

git -C "$REPO_ROOT" worktree add -b "$TEMP_BRANCH" "$WT_DIR" origin/main

# True when the artifact exists AND its "today" matches the current UTC date.
findings_valid() {
  local f="$WT_DIR/.loop-news/findings.json"
  [[ -f "$f" ]] && \
    [[ "$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("today",""))' "$f" 2>/dev/null)" \
       == "$(date -u +%Y-%m-%d)" ]]
}

# run_claude <label> <claude-args...> — run one session in the worktree via a PTY (so
# claude flushes line-by-line), fold its output into the day log, and return success =
# exit 0 AND no transient-error marker. Sets the global BUDGET_EXCEEDED=1 (and does NOT
# reset it — the caller must check it right after the call) when the budget-exceeded
# marker is seen, so the outer loop can stop instead of retrying a deterministic failure.
BUDGET_EXCEEDED=0
run_claude() {
  local label="$1"; shift
  local tmp; tmp="$(mktemp -t loop-news-attempt.XXXXXX)"
  echo "[$(stamp)] ${label} starting" | tee -a "$LOG_FILE"
  ( cd "$WT_DIR" && script -q "$tmp" "$CLAUDE_BIN" --permission-mode auto "$@" )
  local code=$?
  cat "$tmp" >> "$LOG_FILE"
  local transient="no"
  grep -Eq "$ERROR_REGEX" "$tmp" && transient="yes"
  if grep -Eq "$BUDGET_EXCEEDED_REGEX" "$tmp"; then BUDGET_EXCEEDED=1; fi
  rm -f "$tmp"
  if [[ $code -eq 0 && $transient == "no" ]]; then return 0; fi
  echo "[$(stamp)] ${label} failed (exit=${code}, transient=${transient}, budget_exceeded=${BUDGET_EXCEEDED})" | tee -a "$LOG_FILE"
  return 1
}

# Per-stage claude arg arrays — every per-stage difference lives here (model/effort/turns/
# budget, plus A-uses-Chrome vs B-uses-git); run_claude just wraps PTY + transient scan.
A_ARGS=(--model "$SEARCH_MODEL" --effort "$SEARCH_EFFORT"
        --max-turns "$SEARCH_MAX_TURNS" --max-budget-usd "$SEARCH_BUDGET_USD" --chrome
        --allowedTools "Read,Edit,Write,WebFetch,mcp__claude-in-chrome__*" -p "/fetch-loop-news")
B_ARGS=(--model "$INTEGRATE_MODEL" --effort "$INTEGRATE_EFFORT"
        --max-turns "$INTEGRATE_MAX_TURNS" --max-budget-usd "$INTEGRATE_BUDGET_USD"
        --allowedTools "Read,Edit,Write,WebFetch,Bash(git *)" -p "/integrate-loop-news")

echo "[$(stamp)] Starting loop-news run (worktree $WT_DIR, base $BASE_SHA)" | tee -a "$LOG_FILE"

attempt=1; success=0
while (( attempt <= MAX_ATTEMPTS )); do
  # Isolate this attempt: discard a failed attempt's partial TRACKED edits. The gitignored
  # .loop-news/ (findings.json) is untracked+ignored, so reset/clean leave it intact.
  git -C "$WT_DIR" fetch origin main
  git -C "$WT_DIR" reset --hard origin/main
  git -C "$WT_DIR" clean -fd            # NOT -x → keeps ignored .loop-news/

  ok=1; BUDGET_EXCEEDED=0
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
    git -C "$WT_DIR" fetch origin main
    NEW_MAIN_SHA="$(git -C "$WT_DIR" rev-parse origin/main)"
    if [[ "$NEW_MAIN_SHA" != "$BASE_SHA" ]]; then
      if git -C "$WT_DIR" log --oneline "${BASE_SHA}..${NEW_MAIN_SHA}" | grep -q "loop news run"; then
        echo "[$(stamp)] attempt ${attempt}: origin/main already has a loop-news commit — Stage B would be redundant, skipping" | tee -a "$LOG_FILE"
        success=1; break
      fi
      # else: main advanced for an unrelated reason — rebase our notion of "base" forward
      # so the publish-safety guard below doesn't later mistake this same unrelated
      # advance for "our run already published."
      echo "[$(stamp)] attempt ${attempt}: origin/main advanced for an unrelated reason — continuing" | tee -a "$LOG_FILE"
      BASE_SHA="$NEW_MAIN_SHA"
    fi
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

  # --- failure path: publish-safety guard before any retry ---
  # Same false-positive risk as the Stage-A guard above: origin/main can advance for an
  # unrelated reason (a concurrently-merged human PR), which must not be mistaken for
  # "our push already happened" — that would wrongly abandon a legitimately retriable
  # failure. Check for a matching loop-news commit in the delta, not just "did it move."
  git -C "$REPO_ROOT" fetch origin main
  NEW_MAIN_SHA="$(git -C "$REPO_ROOT" rev-parse origin/main)"
  if [[ "$NEW_MAIN_SHA" != "$BASE_SHA" ]]; then
    if git -C "$REPO_ROOT" log --oneline "${BASE_SHA}..${NEW_MAIN_SHA}" | grep -q "loop news run"; then
      notify "Attempt ${attempt} failed AFTER publishing (origin/main has our loop-news commit) — not retrying; check repo state."
      exit 1                           # B already pushed → never retry (would double-commit)
    fi
    # else: main advanced for an unrelated reason — rebase forward and keep retrying.
    echo "[$(stamp)] origin/main advanced for an unrelated reason during attempt ${attempt} — continuing" | tee -a "$LOG_FILE"
    BASE_SHA="$NEW_MAIN_SHA"
  fi
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

echo "[$(stamp)] Run complete (succeeded on attempt ${attempt})" | tee -a "$LOG_FILE"

# --- success path: align the primary checkout if B published and it's on main ---
git -C "$REPO_ROOT" fetch origin main
if [[ "$(git -C "$REPO_ROOT" rev-parse origin/main)" != "$BASE_SHA" ]] && \
   [[ "$(git -C "$REPO_ROOT" symbolic-ref --quiet --short HEAD)" == "main" ]]; then
  git -C "$REPO_ROOT" pull --ff-only origin main | tee -a "$LOG_FILE"
fi
exit 0
