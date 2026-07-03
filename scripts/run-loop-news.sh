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

# ── Per-stage tuning — the ONE place to change any of it, independently ───────────────
#   --model : alias (sonnet|opus|fable) or a full id (e.g. claude-sonnet-5)
#   --effort: low | medium | high | xhigh | max
#   Each var falls back to an env override, so change it either by editing the default
#   here OR by exporting the env var (e.g. in the launchd plist) — no logic change needed.
#   Defaults reproduce prior behaviour.
SEARCH_MODEL="${LOOP_SEARCH_MODEL:-sonnet}"              # Skill A · fetch-loop-news
SEARCH_EFFORT="${LOOP_SEARCH_EFFORT:-high}"
SEARCH_MAX_TURNS="${LOOP_SEARCH_MAX_TURNS:-40}"
SEARCH_BUDGET_USD="${LOOP_SEARCH_BUDGET_USD:-8}"
INTEGRATE_MODEL="${LOOP_INTEGRATE_MODEL:-sonnet}"        # Skill B · integrate-loop-news
INTEGRATE_EFFORT="${LOOP_INTEGRATE_EFFORT:-high}"
INTEGRATE_MAX_TURNS="${LOOP_INTEGRATE_MAX_TURNS:-40}"
INTEGRATE_BUDGET_USD="${LOOP_INTEGRATE_BUDGET_USD:-8}"

CLAUDE_BIN="${CLAUDE_BIN:-/opt/homebrew/bin/claude}"

MAX_ATTEMPTS=3
# Seconds to wait before each retry. Index 0 is the wait before attempt 2, index 1 before 3.
BACKOFF_SECONDS=(30 90 180)

# Connection-level error markers that indicate a TRANSIENT failure worth retrying.
# macOS script(1) does not reliably propagate the child exit code, so we also scan the
# attempt's output for these.
ERROR_REGEX='API Error:|ECONNRESET|ETIMEDOUT|Unable to connect to API|Connection closed mid-response|socket hang up|overloaded_error|529 |503 Service'

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
# exit 0 AND no transient-error marker.
run_claude() {
  local label="$1"; shift
  local tmp; tmp="$(mktemp -t loop-news-attempt.XXXXXX)"
  echo "[$(stamp)] ${label} starting" | tee -a "$LOG_FILE"
  ( cd "$WT_DIR" && script -q "$tmp" "$CLAUDE_BIN" --permission-mode auto "$@" )
  local code=$?
  cat "$tmp" >> "$LOG_FILE"
  local transient="no"
  grep -Eq "$ERROR_REGEX" "$tmp" && transient="yes"
  rm -f "$tmp"
  if [[ $code -eq 0 && $transient == "no" ]]; then return 0; fi
  echo "[$(stamp)] ${label} failed (exit=${code}, transient=${transient})" | tee -a "$LOG_FILE"
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

  ok=1
  # STAGE A — search; skipped entirely if a valid artifact already exists (B-only retry)
  if ! findings_valid; then
    run_claude "attempt ${attempt}/${MAX_ATTEMPTS} · A (search)" "${A_ARGS[@]}" || ok=0
    findings_valid || ok=0             # A must have produced a usable artifact
  else
    echo "[$(stamp)] attempt ${attempt}: valid findings.json present — skipping search" | tee -a "$LOG_FILE"
  fi
  # STAGE B — integrate + restructure + commit + push (only if A stage is good)
  if (( ok )); then
    run_claude "attempt ${attempt}/${MAX_ATTEMPTS} · B (integrate)" "${B_ARGS[@]}" \
      && { success=1; break; } || ok=0
  fi

  # --- failure path: publish-safety guard before any retry ---
  git -C "$REPO_ROOT" fetch origin main
  if [[ "$(git -C "$REPO_ROOT" rev-parse origin/main)" != "$BASE_SHA" ]]; then
    notify "Attempt ${attempt} failed AFTER publishing (origin/main advanced) — not retrying; check repo state."
    exit 1                             # B already pushed → never retry (would double-commit)
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
