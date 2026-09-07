#!/usr/bin/env bash
# Assert that origin/main gained a commit matching a regex since a given base SHA.
#
# WHAT THIS PROVES, AND WHY IT IS PROVABLE AT ALL. Backlog item C4 (v3.4.2) made every tracker run
# commit — including a zero-finding one — so "origin/main carries a commit matching
# OUR_COMMIT_REGEX in the delta since BASE_SHA" is now a reliable post-condition of a run that
# actually published. Before C4 it was not: a quiet day published nothing, so "published nothing
# because there was nothing" and "published nothing because it died" were indistinguishable.
#
# WHY THE CHECK IS NEEDED (backlog item A13). run-loop-news.sh's `success` flag means only that
# run_claude() saw `claude -p` exit 0 with no transient-error marker in its transcript. That is
# equally true when a skill-internal guard aborts: Phase 5c's build gate and Phase 5d's digest
# guard in .claude/skills/integrate-loop-news/SKILL.md `exit 1` the agent's own bash BLOCK inside
# the session, not the `claude -p` process. A clean exit having pushed nothing is this repo's
# eight-week-outage shape exactly — a green run that shipped nothing.
#
# WHY IT IS ITS OWN FILE. So scripts/verify-publish-guard.sh exercises the check that actually
# ships rather than a copy pasted into the harness, which drifts silently. (Its sibling
# scripts/verify-digest-guard.sh copies its subject because a SKILL.md is prose that cannot be
# invoked; a bash check can be, so it is.)
#
# Usage: assert-published.sh <repo-dir> <base-sha> <commit-regex>
#   repo-dir      a git checkout with an `origin` remote. REPO_ROOT and WT_DIR are worktrees of
#                 one repository and share a single refs/remotes/origin/main, so either works.
#   base-sha      origin/main as captured before this run could have pushed (run-loop-news.sh's
#                 $BASE_SHA, forward-rebased by its own guards when main advanced unrelatedly).
#   commit-regex  ERE matched against each commit SUBJECT in the delta, e.g.
#                 '^feat: loop news run '. Passed in, never hardcoded here, so this script and
#                 run-loop-news.sh's OUR_COMMIT_REGEX cannot drift apart unnoticed.
#
# Exit 0 — the delta base-sha..origin/main contains a matching subject: PUBLISHED.
# Exit 1 — checked cleanly, no match: NOT published, whatever the caller's exit code said.
# Exit 2 — COULD NOT CHECK. Every such path exits 2: bad arguments (wrong count, or any empty
#          one), a non-positive-integer retry count, a non-git target, fetch failure after the
#          bounded retry, an unresolvable origin/main, a BASE_SHA that is not an ancestor of the
#          new origin/main, a `git log` failure, and a grep that itself fails on a malformed
#          regex. Callers must treat this exactly like exit 1: a check that cannot
#          tell has not confirmed a publish, and this repo's rule is that such a check fails,
#          never passes. There is deliberately no `|| true`, no empty default and no stale-ref
#          fallback anywhere below.
#
# Env: ASSERT_PUBLISHED_FETCH_TRIES (default 3) — a transient network blip immediately after a
#      genuine push would otherwise raise a false alarm. Retries only ever delay the same verdict;
#      exhausting them still exits 2, never 0.

set -uo pipefail

usage() { echo "usage: assert-published.sh <repo-dir> <base-sha> <commit-regex>" >&2; }

if [[ $# -ne 3 ]]; then usage; exit 2; fi
REPO_DIR="$1"; BASE_SHA="$2"; COMMIT_REGEX="$3"

# An EMPTY regex is not a lenient check, it is a guaranteed pass: `grep -qE ""` matches any input,
# including the single blank line an empty delta produces. An unset caller variable under `set -u`
# would be caught at the call site, but an empty-valued one would not, and it would silently turn
# this whole script into `exit 0` — the fabricated-success class A13 exists to close. Refuse.
if [[ -z "$REPO_DIR" || -z "$BASE_SHA" || -z "$COMMIT_REGEX" ]]; then
  echo "assert-published.sh: empty argument (repo-dir='${REPO_DIR}', base-sha='${BASE_SHA}', regex='${COMMIT_REGEX}') — cannot check" >&2
  usage; exit 2
fi

TRIES="${ASSERT_PUBLISHED_FETCH_TRIES:-3}"
if ! [[ "$TRIES" =~ ^[1-9][0-9]*$ ]]; then
  echo "assert-published.sh: ASSERT_PUBLISHED_FETCH_TRIES='${TRIES}' is not a positive integer — cannot check" >&2
  exit 2
fi

if ! git -C "$REPO_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  echo "assert-published.sh: '${REPO_DIR}' is not a git checkout — cannot check" >&2
  exit 2
fi

# Fetch fresh, every time, and never fall back to whatever origin/main already pointed at. On the
# direct Stage-B-success path, run-loop-news.sh's own most recent fetches (its pre-flight guard and
# its failure-path guard) both ran BEFORE Stage B's push landed: reading either would be reading a
# snapshot taken before the very commit this is meant to find, and would fail a healthy run.
fetched=0; fetch_err=""
for (( i = 1; i <= TRIES; i++ )); do
  if fetch_err="$(git -C "$REPO_DIR" fetch origin main -q 2>&1)"; then fetched=1; break; fi
  echo "assert-published.sh: fetch origin main failed (attempt ${i}/${TRIES}): ${fetch_err}" >&2
  if (( i < TRIES )); then sleep 2; fi
done
if (( ! fetched )); then
  echo "assert-published.sh: could not fetch origin/main in '${REPO_DIR}' after ${TRIES} attempt(s) — cannot tell whether the run published" >&2
  exit 2
fi

# --verify --quiet so an unresolvable ref exits non-zero and prints nothing, rather than echoing
# the literal string back. An EMPTY right-hand side below would turn "BASE.." into "BASE..HEAD",
# which silently asks a different question — the LOCAL branch instead of the remote — and in the
# worktree Stage B commits into, that local branch carries the very commit that never got pushed.
# That is a fabricated pass on the exact failure this script exists to catch.
if ! NEW_MAIN_SHA="$(git -C "$REPO_DIR" rev-parse --verify --quiet origin/main)"; then NEW_MAIN_SHA=""; fi
if [[ -z "$NEW_MAIN_SHA" ]]; then
  echo "assert-published.sh: could not resolve origin/main in '${REPO_DIR}' after a clean fetch — cannot check" >&2
  exit 2
fi

# `git log A..B` requires only that both objects EXIST — not that A is an ancestor of B. After a
# force-push or a history rewrite, BASE_SHA is normally still a loose object in this checkout (it
# was fetched before the rewrite, and git keeps unreachable objects for gc.pruneExpire, two weeks
# by default), so the range silently stops meaning "what this run added" and starts meaning
# "everything on the new history minus the old one" — a large set of unrelated commits. One stray
# old `feat: loop news run ` subject in there then reports PUBLISHED on a run that published
# nothing. Reproduced against this script before the guard existed: exit 0, "1 commit(s) in the
# delta". Ancestry is the precondition the delta question assumes, so check it rather than hoping
# `git log` fails. It cannot false-alarm on a real run: BASE_SHA is only ever assigned from
# `rev-parse origin/main` or forward-rebased to a later origin/main, and `--is-ancestor X X` is 0.
if ! git -C "$REPO_DIR" merge-base --is-ancestor "$BASE_SHA" "$NEW_MAIN_SHA" >/dev/null 2>&1; then
  echo "assert-published.sh: ${BASE_SHA} is not an ancestor of origin/main (${NEW_MAIN_SHA}) — the history was rewritten, or that base is not on this branch. The delta would answer a different question — cannot check" >&2
  exit 2
fi

if ! SUBJECTS="$(git -C "$REPO_DIR" log --format=%s "${BASE_SHA}..${NEW_MAIN_SHA}" 2>/dev/null)"; then
  echo "assert-published.sh: git log ${BASE_SHA}..${NEW_MAIN_SHA} failed — ${BASE_SHA} does not resolve in '${REPO_DIR}' — cannot check" >&2
  exit 2
fi

# grep -E, not -F: COMMIT_REGEX is an anchored ERE, matching run-loop-news.sh's own usage at its
# two sibling guards. rc 0 = matched, 1 = clean no-match, >1 = grep itself failed (e.g. an invalid
# regex), which is a cannot-tell and must not be conflated with a clean no-match.
printf '%s\n' "$SUBJECTS" | grep -qE "$COMMIT_REGEX"
MATCH_RC=$?
DELTA_N="$(printf '%s\n' "$SUBJECTS" | grep -c . )"

if (( MATCH_RC == 0 )); then
  echo "assert-published.sh: PUBLISHED — origin/main carries a commit matching '${COMMIT_REGEX}' in ${BASE_SHA}..${NEW_MAIN_SHA} (${DELTA_N} commit(s) in the delta)"
  exit 0
fi
if (( MATCH_RC > 1 )); then
  echo "assert-published.sh: grep failed on regex '${COMMIT_REGEX}' (rc=${MATCH_RC}) — cannot check" >&2
  exit 2
fi
echo "assert-published.sh: NOT PUBLISHED — no commit matching '${COMMIT_REGEX}' in ${BASE_SHA}..${NEW_MAIN_SHA} (${DELTA_N} commit(s) in the delta)" >&2
exit 1
