#!/usr/bin/env bash
# Drop -e: a failed attempt must NOT kill the script — we handle failures
# explicitly so we can retry. Keep -u and pipefail.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

mkdir -p logs
LOG_FILE="logs/loop-news-$(date +%Y%m%d).log"

MAX_ATTEMPTS=3
# Seconds to wait before each retry. Index 0 is the wait before attempt 2,
# index 1 before attempt 3. (The wait after the final attempt is never used.)
BACKOFF_SECONDS=(30 90 180)

# Generous cost ceiling per attempt. Set high enough that a normal run never trips
# it (a budget-trip would itself fail the attempt) but low enough to bound a runaway.
MAX_BUDGET_USD=8

# Connection-level error markers that indicate a TRANSIENT failure worth retrying.
# macOS script(1) does not reliably propagate the child exit code, so we also
# scan the attempt's output for these — this is how the real failures surfaced
# (e.g. "API Error: Unable to connect to API (ECONNRESET)").
ERROR_REGEX='API Error:|ECONNRESET|ETIMEDOUT|Unable to connect to API|Connection closed mid-response|socket hang up|overloaded_error|529 |503 Service'

stamp() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# Best-effort desktop notification + log line. Never fails the script.
notify() {
  local msg="$1"
  echo "[$(stamp)] NOTIFY: ${msg}" | tee -a "$LOG_FILE"
  osascript -e "display notification \"${msg}\" with title \"loop-news tracker\"" >/dev/null 2>&1 || true
}

# True (0) only when the working tree has no pending changes to TRACKED files.
# Uses `git diff` (not `git status`) so untracked dirs like memory/ and the
# gitignored logs/ never count as dirty.
tree_clean() {
  git diff --quiet && git diff --cached --quiet
}

run_attempt() {
  local attempt="$1"
  local tmp_log
  tmp_log="$(mktemp -t loop-news-attempt.XXXXXX)"

  echo "[$(stamp)] Attempt ${attempt}/${MAX_ATTEMPTS} starting" | tee -a "$LOG_FILE"

  # script(1) allocates a PTY so claude flushes output line-by-line (live tail).
  # Write this attempt to its own typescript so we can inspect it for transient
  # errors, then fold it into the day log.
  #   -q  suppress "Script started / Script done" messages
  script -q "$tmp_log" \
    /opt/homebrew/bin/claude \
      --permission-mode auto \
      --chrome \
      --max-turns 40 \
      --max-budget-usd "$MAX_BUDGET_USD" \
      --allowedTools "Read,Edit,WebFetch,mcp__claude-in-chrome__*" \
      -p "/fetch-loop-news"
  local exit_code=$?

  # Fold this attempt's output into the day log (live tail already saw it via PTY).
  cat "$tmp_log" >> "$LOG_FILE"

  local transient="no"
  grep -Eq "$ERROR_REGEX" "$tmp_log" && transient="yes"
  rm -f "$tmp_log"

  # Success = clean exit AND no transient-error marker in the output.
  if [[ $exit_code -eq 0 && $transient == "no" ]]; then
    return 0
  fi

  echo "[$(stamp)] Attempt ${attempt} failed (exit=${exit_code}, transient_error=${transient})" | tee -a "$LOG_FILE"
  return 1
}

echo "[$(stamp)] Starting fetch-loop-news run" | tee -a "$LOG_FILE"

attempt=1
while (( attempt <= MAX_ATTEMPTS )); do
  head_before="$(git rev-parse HEAD 2>/dev/null || echo unknown)"

  if run_attempt "$attempt"; then
    echo "[$(stamp)] Run complete (succeeded on attempt ${attempt})" | tee -a "$LOG_FILE"
    exit 0
  fi

  # Conservative safety guard: only retry when the failed attempt left NO durable
  # trace. If it already committed (HEAD moved) or made partial edits to tracked
  # files, a fresh re-run could duplicate work or hit a tag/release collision —
  # so we stop and ask a human instead. (Full safe-to-retry idempotency belongs
  # in the skill itself; this wrapper just refuses to make things worse.)
  head_after="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
  if [[ "$head_after" != "$head_before" ]]; then
    notify "Attempt ${attempt} failed AFTER committing (HEAD moved) — not retrying; check repo state."
    exit 1
  fi
  if ! tree_clean; then
    notify "Attempt ${attempt} failed with partial uncommitted edits — not retrying; run 'git status' and clean up."
    exit 1
  fi

  if (( attempt < MAX_ATTEMPTS )); then
    wait_s="${BACKOFF_SECONDS[$((attempt - 1))]}"
    echo "[$(stamp)] Clean failure (no durable changes) — backing off ${wait_s}s before retry" | tee -a "$LOG_FILE"
    sleep "$wait_s"
  fi
  (( attempt++ ))
done

notify "All ${MAX_ATTEMPTS} attempts failed (transient/connection errors) — no digest today. Re-run manually when the API is healthy."
exit 1
