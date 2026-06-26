#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

mkdir -p logs

LOG_FILE="logs/loop-news-$(date +%Y%m%d).log"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Starting fetch-loop-news run" | tee -a "$LOG_FILE"

# script(1) allocates a PTY so claude flushes output line-by-line rather than
# buffering until completion.  Without it, `tail -f` shows nothing live.
#   -q  suppress "Script started / Script done" messages
#   -a  append to LOG_FILE rather than overwrite
script -q -a "$LOG_FILE" \
  /opt/homebrew/bin/claude \
    --permission-mode auto \
    --chrome \
    --max-turns 40 \
    --allowedTools "Read,Edit,WebFetch,mcp__claude-in-chrome__*" \
    -p "/fetch-loop-news"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Run complete" | tee -a "$LOG_FILE"
