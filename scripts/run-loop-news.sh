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

# Connection-level error markers that indicate a TRANSIENT failure worth retrying.
# macOS script(1) does not reliably propagate the child exit code, so we also
# scan the attempt's output for these — this is how the real failures surfaced
# (e.g. "API Error: Unable to connect to API (ECONNRESET)").
ERROR_REGEX='API Error:|ECONNRESET|ETIMEDOUT|Unable to connect to API|Connection closed mid-response|socket hang up|overloaded_error|529 |503 Service'

stamp() { date -u +%Y-%m-%dT%H:%M:%SZ; }

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
  if run_attempt "$attempt"; then
    echo "[$(stamp)] Run complete (succeeded on attempt ${attempt})" | tee -a "$LOG_FILE"
    exit 0
  fi

  if (( attempt < MAX_ATTEMPTS )); then
    wait_s="${BACKOFF_SECONDS[$((attempt - 1))]}"
    echo "[$(stamp)] Backing off ${wait_s}s before retry" | tee -a "$LOG_FILE"
    sleep "$wait_s"
  fi
  (( attempt++ ))
done

echo "[$(stamp)] All ${MAX_ATTEMPTS} attempts failed — giving up" | tee -a "$LOG_FILE"
exit 1
