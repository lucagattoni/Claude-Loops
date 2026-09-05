#!/usr/bin/env bash
# Fail if the newest digest entry in LOOP_ENGINEERING_NEWS.md is older than MAX_AGE_HOURS.
#
# Why this exists: the tracker produced nothing between 2026-07-20 and 2026-09-05 and nobody
# noticed. Every failure path reported to a macOS desktop notification and a gitignored log file
# — both on the same machine as the failure, so a dead machine, a dead scheduler and a dead
# pipeline all look identical from anywhere else: silence.
#
# This check deliberately runs OFF that machine (GitHub Actions). A watchdog sharing a failure
# domain with the thing it watches is not a watchdog.
#
# It also asserts on the published artifact — the newest dated header in the committed digest —
# rather than on any run's exit status. "The workflow succeeded" has been true here while nothing
# shipped; "the digest has a fresh entry" cannot be.
#
# Exit 0 = fresh. Exit 1 = stale (or unreadable — see below). Never exits 0 on "I could not tell".

set -uo pipefail

DIGEST="${1:-LOOP_ENGINEERING_NEWS.md}"
MAX_AGE_HOURS="${MAX_AGE_HOURS:-48}"

fail() { printf '%s\n' "STALE: $*" >&2; exit 1; }

[[ -f "$DIGEST" ]] || fail "$DIGEST does not exist"

# Newest dated header. The file is newest-first, so the first match is the newest entry.
# Format, fixed by the skill: "## YYYY-MM-DD HH:MM UTC (run)" — the trailing parenthetical varies
# ("catch-up run — eight-week backlog"), so it is not matched.
header="$(grep -m1 -E '^## [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2} UTC' "$DIGEST" || true)"
[[ -n "$header" ]] || fail "no dated '## YYYY-MM-DD HH:MM UTC' header found in $DIGEST — the format changed, or the file is truncated"

stamp="$(printf '%s' "$header" | sed -E 's/^## ([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}) UTC.*/\1/')"

# GNU date (CI) and BSD date (macOS) disagree on parsing; try both rather than assuming a platform.
if entry_epoch="$(date -u -d "$stamp UTC" +%s 2>/dev/null)"; then :
elif entry_epoch="$(date -u -j -f '%Y-%m-%d %H:%M' "$stamp" +%s 2>/dev/null)"; then :
else
  fail "could not parse timestamp '$stamp' with either GNU or BSD date"
fi
[[ -n "$entry_epoch" ]] || fail "empty epoch for '$stamp'"

now_epoch="$(date -u +%s)"
age_hours=$(( (now_epoch - entry_epoch) / 3600 ))

if (( age_hours < 0 )); then
  fail "newest entry '$stamp' is $(( -age_hours ))h in the FUTURE — a bad stamp is as broken as a stale one"
fi

if (( age_hours > MAX_AGE_HOURS )); then
  fail "newest digest entry is ${age_hours}h old (limit ${MAX_AGE_HOURS}h) — '$stamp'. The tracker has not published. Check logs/loop-news-*.log on the scheduler host and 'launchctl print gui/\$(id -u)/com.luca.loop-news'."
fi

printf 'FRESH: newest digest entry is %sh old (limit %sh) — %s\n' "$age_hours" "$MAX_AGE_HOURS" "$stamp"
