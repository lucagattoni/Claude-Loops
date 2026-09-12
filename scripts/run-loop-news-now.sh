#!/usr/bin/env bash
# Run the daily tracker ON DEMAND, in the exact environment launchd would have given it.
#
# WHY THIS EXISTS. The tracker supports TWO modes and they must stay interchangeable:
#
#   on demand  (the default since 20260912) — you run this script when you want a sweep
#   scheduled  (available, currently disabled) — the launchd agent fires it at 05:00 local
#
# Whichever is active, the run must be IDENTICAL: same PATH, same HOME, same working directory,
# same log files, same exit codes. Otherwise "it worked when I ran it by hand" stops being
# evidence about the scheduled path, and vice versa — and switching modes becomes a gamble.
#
# Running `bash scripts/run-loop-news.sh` straight from a terminal does NOT give you that. An
# interactive shell has sourced your profile, so its PATH is a SUPERSET of the recorded one; a run
# that succeeds there can fail under launchd. This repo already lost eight weeks to a
# binary-resolution bug of exactly that shape. So this launcher pins the environment instead of
# inheriting it, and both modes end up running the wrapper the same way.
#
# ONE HOME FOR THE CONTRACT. Every value below is read out of scripts/com.luca.loop-news.plist at
# run time, not copied here. That file is NOT a schedule any more — it is kept, committed, as the
# RECORD of the environment the tracker was built and proven to run in, and as the way back if a
# schedule is ever wanted again. Reading it rather than duplicating it means this launcher cannot
# drift from that record. If the plist is missing or a key cannot be read, this aborts — it never
# falls back to the ambient environment, because a fallback that "works" is exactly how a manual
# run stops matching the environment everything else was tested against.
#
# Usage:
#   bash scripts/run-loop-news-now.sh            run a sweep now
#   bash scripts/run-loop-news-now.sh --check    print the resolved environment and exit, run nothing
#   bash scripts/run-loop-news-now.sh --status   which mode is live, and when it last published
#
# Exit codes are the wrapper's own, passed through unchanged — see scripts/SCHEDULING.md.
# 6 = reported success but published nothing · 7 = failed and could not tell whether it published.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST="$HERE/com.luca.loop-news.plist"

[[ -f "$PLIST" ]] || { echo "FATAL: $PLIST not found — it is the single definition of the run environment, and guessing one is how the two modes diverge" >&2; exit 2; }

# read_plist <key-path> — the value, or abort. Never returns empty, never defaults.
read_plist() {
  local key="$1" val
  val="$(plutil -extract "$key" raw -o - "$PLIST" 2>/dev/null)" || val=""
  if [[ -z "$val" ]]; then
    echo "FATAL: could not read '${key}' from $(basename "$PLIST"). The launchd environment cannot be reproduced, and guessing it is exactly how a manual run stops matching a scheduled one." >&2
    exit 2
  fi
  printf '%s' "$val"
}

LN_PATH="$(read_plist EnvironmentVariables.PATH)" || exit 2
LN_HOME="$(read_plist EnvironmentVariables.HOME)" || exit 2
LN_WD="$(read_plist WorkingDirectory)"            || exit 2
LN_LOG="$(read_plist StandardOutPath)"            || exit 2

# The recorded invocation, read rather than assumed to be `/bin/bash <wrapper>`, so an edit to the
# record is picked up here too.
LN_ARG0="$(read_plist ProgramArguments.0)" || exit 2
LN_ARG1="$(read_plist ProgramArguments.1)" || exit 2

[[ -d "$LN_WD" ]] || { echo "FATAL: WorkingDirectory '$LN_WD' does not exist" >&2; exit 2; }
# Check the file this will ACTUALLY exec, which is whatever ProgramArguments names — not a
# hardcoded sibling path. An earlier revision checked "$HERE/run-loop-news.sh" and would have
# passed while the recorded target was missing, which is a guard checking the wrong thing.
[[ -f "$LN_ARG1" ]] || { echo "FATAL: recorded target '$LN_ARG1' does not exist" >&2; exit 2; }

if [[ "${1:-}" == "--status" ]]; then
  # The question this answers — "is it supposed to be running right now?" — took a full
  # investigation on 20260912 because nothing reported it. Never infer the mode from whether a
  # digest looks recent; ask launchd and the repo directly, and say when the answer is unknown.
  label="$(read_plist Label)" || exit 2
  echo "Tracker mode"
  if launchctl print-disabled "gui/$(id -u)" 2>/dev/null | grep -q "\"${label}\" => disabled"; then
    sched_disabled="yes"
  else
    sched_disabled="no"
  fi
  if launchctl print "gui/$(id -u)/${label}" >/dev/null 2>&1; then loaded="yes"; else loaded="no"; fi
  if [[ "$loaded" == "yes" && "$sched_disabled" == "no" ]]; then
    printf '  %-22s %s\n' "active mode" "SCHEDULED — launchd will fire it at the plist's time"
  else
    printf '  %-22s %s\n' "active mode" "ON DEMAND — nothing fires on a clock; run this script"
  fi
  printf '  %-22s %s\n' "agent loaded" "$loaded"
  printf '  %-22s %s\n' "agent disabled" "$sched_disabled"
  printf '  %-22s %s\n' "installed plist" "$( [[ -f "$LN_HOME/Library/LaunchAgents/${label}.plist" ]] && echo present || echo "absent (schedule cannot be started until it is copied back)" )"
  echo
  echo "Last publish"
  last="$(git -C "$LN_WD" log -1 --format='%h  %cI  %s' --grep='^feat: loop news run ' 2>/dev/null)"
  printf '  %-22s %s\n' "newest run commit" "${last:-<none found>}"
  printf '  %-22s %s\n' "newest day log" "$(ls -t "$LN_WD"/logs/loop-news-*.log 2>/dev/null | head -1 | xargs -I{} basename {} 2>/dev/null || echo '<none>')"
  echo
  echo "Digest freshness (informational under ON DEMAND — it measures when you last chose to run)"
  bash "$LN_WD/scripts/check-digest-freshness.sh" 2>&1 | sed 's/^/  /'
  exit 0
fi

if [[ "${1:-}" == "--check" ]]; then
  echo "Resolved from $(basename "$PLIST") — the recorded environment this run will reproduce:"
  printf '  %-18s %s\n' "PATH"             "$LN_PATH"
  printf '  %-18s %s\n' "HOME"             "$LN_HOME"
  printf '  %-18s %s\n' "WorkingDirectory" "$LN_WD"
  printf '  %-18s %s\n' "launchd log"      "$LN_LOG"
  printf '  %-18s %s\n' "command"          "$LN_ARG0 $LN_ARG1"
  echo
  echo "NOT verified by --check: that the run itself behaves identically. This proves the"
  echo "environment is reproduced, not that the pipeline works. Only a real run does that."
  exit 0
fi

mkdir -p "$(dirname "$LN_LOG")"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] MANUAL RUN starting — reproducing the recorded environment from $(basename "$PLIST")" | tee -a "$LN_LOG"
echo "  day log:     $LN_WD/logs/loop-news-\$(date +%Y%m%d).log" | tee -a "$LN_LOG"
echo "  catch-all:   $LN_LOG" | tee -a "$LN_LOG"

# `env -i` so nothing from the interactive shell leaks in. The point is to match the recorded
# environment exactly, not to add to whatever happens to be exported in this terminal — an
# interactive shell has sourced your profile and its PATH is a superset.
# Output is tee'd rather than redirected: the bytes reaching $LN_LOG are what launchd would have
# captured, and you also get to watch it. PIPESTATUS[0] keeps the wrapper's exit code, which
# carries real meaning (6 and 7 in particular) and must not be replaced by tee's.
cd "$LN_WD" || exit 2
env -i \
  PATH="$LN_PATH" \
  HOME="$LN_HOME" \
  TERM="${TERM:-dumb}" \
  "$LN_ARG0" "$LN_ARG1" 2>&1 | tee -a "$LN_LOG"
rc="${PIPESTATUS[0]}"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] MANUAL RUN finished — exit ${rc}" | tee -a "$LN_LOG"
case "$rc" in
  0) echo "Published. Verify the artifact, not this message: check origin/main for a 'feat: loop news run ' commit." ;;
  6) echo "EXIT 6 — reported success but published NOTHING. Look for FATAL in the day log. The Stage-A artifact is preserved; a re-run resumes cheaply." >&2 ;;
  7) echo "EXIT 7 — failed and could not tell whether it had already published, so it refused to retry. Check origin/main BY HAND before re-running." >&2 ;;
  *) echo "Exit ${rc} — see scripts/SCHEDULING.md for what it means." >&2 ;;
esac
exit "$rc"
