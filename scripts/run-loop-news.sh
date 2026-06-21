#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

mkdir -p logs

LOG_FILE="logs/loop-news-$(date +%Y%m%d).log"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Starting fetch-loop-news run" >> "$LOG_FILE"

claude --permission-mode auto \
       --chrome \
       --max-turns 40 \
       --allowedTools "Read,Edit,WebFetch,mcp__claude-in-chrome__*" \
       -p "/fetch-loop-news" \
  >> "$LOG_FILE" 2>&1

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Run complete" >> "$LOG_FILE"
