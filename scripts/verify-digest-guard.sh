#!/usr/bin/env bash
# Prove that Phase 5d's digest guard fires — and only when it should.
#
# THE GUARD UNDER TEST, copied verbatim from .claude/skills/integrate-loop-news/SKILL.md Phase 5d:
#
#     if git diff --cached --quiet -- LOOP_ENGINEERING_NEWS.md; then
#       echo "FATAL: ..." >&2
#       exit 1
#     fi
#
# It runs AFTER `git reset --soft "$(git merge-base HEAD origin/main)"` and asserts that the run
# actually wrote the digest section Phase 4 mandates. Both properties — the placement and the
# `-- LOOP_ENGINEERING_NEWS.md` scoping — are load-bearing, and this script is what says so.
#
# WHY THIS FILE EXISTS. The guard was added in v3.4.2 and validated in a throwaway scratch repo
# whose transcript is gone. `RESUME.md` lesson 6 is "anything a repo file instructs must live in
# the repo", and a proof that exists only as prose in a digest entry is exactly what that rule
# forbids: nobody can re-run it, so nobody can tell if a later edit broke the guard. Written to
# disk 20260907 after a handover audit caught the omission.
#
# WHY A SANITY CASE. The first two attempts at this harness leaked staged state across
# `git checkout` and reported a BROKEN run as healthy. A harness that cannot produce a failure
# proves nothing, so case 0 must FATAL before any passing case is believed.
#
# Usage:  bash scripts/verify-digest-guard.sh        (exit 0 = guard behaves correctly)

set -uo pipefail

TMP="$(mktemp -d "${TMPDIR:-/tmp}/digest-guard-XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
FAILURES=0

cd "$TMP" || exit 2
git init -q .
git config user.email harness@example.invalid
git config user.name "digest guard harness"
echo "base" > LOOP_ENGINEERING_NEWS.md
git add -A && git commit -qm "base"
git branch -q -M main

# The guard, verbatim. Returns 0 when it would ALLOW the commit, 1 when it would abort the run.
guard() { git diff --cached --quiet -- LOOP_ENGINEERING_NEWS.md && return 1 || return 0; }

# The guard as it was FIRST written (unscoped) — kept to prove the scoping is not cosmetic.
guard_unscoped() { git diff --cached --quiet && return 1 || return 0; }

# Reset to a genuinely clean per-case state. `git checkout` alone leaks staged and worktree
# changes between cases, which is how the first two versions of this harness lied.
fresh() {
  git checkout -q main 2>/dev/null
  git reset -q --hard main
  git clean -qfdx
  git branch -qD run 2>/dev/null
  git checkout -q -b run main
}

check() { # check <label> <expected: allow|abort> <actual-rc>
  local label="$1" expect="$2" rc="$3" got
  [[ "$rc" -eq 0 ]] && got="allow" || got="abort"
  if [[ "$got" == "$expect" ]]; then
    printf '  ok    %-52s %s\n' "$label" "$got"
  else
    printf '  FAIL  %-52s expected %s, got %s\n' "$label" "$expect" "$got"
    FAILURES=$((FAILURES + 1))
  fi
}

echo "Phase 5d digest guard — behavioural proof"
echo

# --- 0. SANITY: the harness must be able to produce an abort at all -------------------------
fresh
git reset -q --soft "$(git merge-base HEAD main)"
guard; check "0 SANITY untouched tree must abort" abort $?

# --- 1. Healthy run, Phase 4d checkpointed the digest ---------------------------------------
# The case that broke the original Phase 5b placement: the digest is already in HEAD, so before
# the --soft reset the index matches HEAD and an earlier guard reads "empty" on a HEALTHY run.
fresh
echo "## 2026-01-01 00:00 UTC (run)" >> LOOP_ENGINEERING_NEWS.md
git add -A && git commit -qm "wip(loop-news): digest entry"
guard; check "1a healthy+checkpointed BEFORE reset (old 5b spot)" abort $?
git add LOOP_ENGINEERING_NEWS.md
git reset -q --soft "$(git merge-base HEAD main)"
guard; check "1b healthy+checkpointed AFTER reset (5d, correct)" allow $?

# --- 2. Healthy run, no checkpoint (digest only in the worktree) -----------------------------
fresh
echo "## 2026-01-01 00:00 UTC (run)" >> LOOP_ENGINEERING_NEWS.md
git add LOOP_ENGINEERING_NEWS.md
git reset -q --soft "$(git merge-base HEAD main)"
guard; check "2  healthy, no checkpoint" allow $?

# --- 3. BROKEN: Phase 4 never wrote the section ----------------------------------------------
fresh
git reset -q --soft "$(git merge-base HEAD main)"
guard; check "3  broken: digest never written" abort $?

# --- 4. BROKEN: digest missing, but the run staged something else ----------------------------
# This is why the guard is scoped to the digest file. Unscoped it passes here, which is the exact
# failure it exists to catch.
fresh
echo "unrelated" > SOURCES.md
git add -A && git commit -qm "wip(loop-news): structural review"
git reset -q --soft "$(git merge-base HEAD main)"
guard;          check "4a broken: other file staged (scoped guard)" abort $?
guard_unscoped; check "4b same case, UNSCOPED guard — why scoping matters" allow $?

echo
if [[ "$FAILURES" -eq 0 ]]; then
  echo "PASS — the guard allows both healthy shapes, aborts both broken ones,"
  echo "       and the sanity case proves this harness can produce an abort."
  exit 0
fi
echo "FAIL — $FAILURES case(s) behaved wrongly. The guard in Phase 5d, or this harness, is broken."
echo "       Do not trust a passing case from a harness whose sanity case did not abort."
exit 1
