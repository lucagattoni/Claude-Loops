#!/usr/bin/env bash
# Prove that scripts/assert-published.sh — the artifact check A13 added to run-loop-news.sh —
# fires exactly when it should, and only then.
#
# THE SCRIPT UNDER TEST is scripts/assert-published.sh, invoked below AS SHIPPED, not as a copy
# pasted into this file. Edit the real script and this harness runs the edit. Case 7 covers the
# one thing calling the real script cannot: this harness's own idea of the commit regex drifting
# from run-loop-news.sh's OUR_COMMIT_REGEX.
#
# WHY TWO CLONES. A single working copy cannot represent "committed but never pushed": `git log`
# in that copy sees its own commits whether or not they ever left the machine, so case 2 — the
# exact shape A13 exists to catch — would be unconstructable and would pass vacuously. So `wt/`
# stands in for run-loop-news.sh's $WT_DIR (where Stage B commits) and `repo/` for $REPO_ROOT
# (what the assertion actually reads); both clone one bare origin.git, and only what reaches
# origin.git via a real `git push` is visible from repo/.
#
# WHY A SANITY CASE. scripts/verify-digest-guard.sh's own header records two earlier versions of
# that harness that leaked state and reported a broken run as healthy. A harness that cannot
# produce a failure proves nothing, so case 0 must report no-publish before any passing case here
# is believed (CLAUDE.md: "prove a new check fires before trusting it").
#
# WHY CASES 7 AND 8 ARE GREPS, NOT GIT STATE. Cases 0-6c prove assert-published.sh's logic.
# Nothing in them can prove WHERE run-loop-news.sh calls it from — and that placement is the
# backlog's own named hazard: "get this wrong and the fix causes the damage it detects." An
# assertion below the artifact-retirement block would pass every git-state case here while
# destroying Stage A's resume state on every real non-publish. That is a property of the wrapper's
# TEXT, so it is checked by grep, the same technique scripts/kb-structure-check.sh §5/§6 uses.
#
# Usage:  bash scripts/verify-publish-guard.sh        (exit 0 = the guard behaves correctly)
#         Takes ~10s: case 5 exercises the real fetch-retry loop, sleeps included.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_UNDER_TEST="$HERE/assert-published.sh"
WRAPPER="$HERE/run-loop-news.sh"
[[ -f "$SCRIPT_UNDER_TEST" ]] || { echo "missing: $SCRIPT_UNDER_TEST" >&2; exit 2; }
[[ -f "$WRAPPER" ]]           || { echo "missing: $WRAPPER" >&2; exit 2; }

REGEX='^feat: loop news run '   # must equal run-loop-news.sh's OUR_COMMIT_REGEX — case 7 proves it
# The real subject shape, verbatim from `git log --grep` on main, so the fixture cannot pass on a
# string the pipeline never emits.
SUBJ='feat: loop news run 2026-01-01 04:00 UTC — 3 findings, 1 new docs [patch]'

TMP="$(mktemp -d "${TMPDIR:-/tmp}/publish-guard-XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
FAILURES=0
cd "$TMP" || exit 2

BASE_SHA=""
fresh() {   # rebuild every repo from nothing, per case: nothing can leak between cases
  rm -rf origin.git wt repo human
  git init -q --bare origin.git
  git clone -q origin.git wt 2>/dev/null
  git clone -q origin.git repo 2>/dev/null
  local d
  for d in wt repo; do
    git -C "$d" config user.email harness@example.invalid
    git -C "$d" config user.name  "publish guard harness"
  done
  git -C wt checkout -q -b main 2>/dev/null
  git -C wt commit -q --allow-empty -m "base"
  git -C wt push -q origin HEAD:main
  git -C repo fetch -q origin main
  BASE_SHA="$(git -C repo rev-parse origin/main)"
  # The fixture is worthless if the two clones are not genuinely separate views of one origin.
  [[ -n "$BASE_SHA" ]] || { echo "  FATAL: fixture did not produce a BASE_SHA" >&2; exit 2; }
}

check() { # check <label> <expected: publish|no-publish> <actual-rc>
  local label="$1" expect="$2" rc="$3" got
  [[ "$rc" -eq 0 ]] && got="publish" || got="no-publish"
  if [[ "$got" == "$expect" ]]; then
    printf '  ok    %-56s %s (rc=%s)\n' "$label" "$got" "$rc"
  else
    printf '  FAIL  %-56s expected %s, got %s (rc=%s)\n' "$label" "$expect" "$got" "$rc"
    FAILURES=$((FAILURES + 1))
  fi
}

check_rc() { # check_rc <label> <expected-rc> <actual-rc>
  local label="$1" expect="$2" rc="$3"
  if [[ "$rc" -eq "$expect" ]]; then
    printf '  ok    %-56s rc=%s\n' "$label" "$rc"
  else
    printf '  FAIL  %-56s expected rc=%s, got rc=%s\n' "$label" "$expect" "$rc"
    FAILURES=$((FAILURES + 1))
  fi
}

echo "assert-published.sh — behavioural proof"
echo

# --- 0. SANITY: this harness must be able to produce a no-publish verdict at all -------------
fresh
bash "$SCRIPT_UNDER_TEST" repo "$BASE_SHA" "$REGEX" 2>/dev/null
check "0 SANITY untouched origin must read no-publish" no-publish $?

# --- 1. Stage B commits AND pushes -> publish -------------------------------------------------
fresh
git -C wt commit -q --allow-empty -m "$SUBJ"
git -C wt push -q origin HEAD:main
bash "$SCRIPT_UNDER_TEST" repo "$BASE_SHA" "$REGEX" >/dev/null
check "1 Stage B commits and pushes" publish $?

# --- 2. Stage B "succeeds" (claude -p exits 0) but pushes nothing -> no-publish ---------------
# The gap A13 closes. The realistic shape is NOT "nothing happened at all" (that is case 0):
# Phase 4d checkpoints as it goes, so a Stage B that aborted at Phase 5c/5d typically HAS local
# commits. What never happened is the push — wt/ carries the commit, origin.git does not, and
# therefore neither does repo/, which is what the wrapper reads.
fresh
git -C wt commit -q --allow-empty -m "$SUBJ"
bash "$SCRIPT_UNDER_TEST" repo "$BASE_SHA" "$REGEX" 2>/dev/null
check "2 Stage B commits locally, exits 0, never pushes" no-publish $?

# --- 3. origin/main advanced for an unrelated human commit AND ours -> publish ----------------
# Mirrors the wrapper's two existing guards: an unrelated concurrent merge must neither be
# mistaken for our publish nor hide it when both land in the same delta.
fresh
git clone -q origin.git human 2>/dev/null
git -C human config user.email harness@example.invalid
git -C human config user.name  "unrelated human"
git -C human commit -q --allow-empty -m "fix: typo in README"
git -C human push -q origin HEAD:main
git -C wt fetch -q origin main && git -C wt reset -q --hard origin/main
git -C wt commit -q --allow-empty -m "$SUBJ"
git -C wt push -q origin HEAD:main
bash "$SCRIPT_UNDER_TEST" repo "$BASE_SHA" "$REGEX" >/dev/null
check "3 unrelated commit coexists with our own" publish $?

# --- 3b. origin/main advanced ONLY for an unrelated commit -> no-publish ----------------------
# The false-positive twin of case 3, and the one that matters most for a wrapper whose older bug
# class was "main moved, therefore we published". Main moved; we did not publish.
fresh
git clone -q origin.git human 2>/dev/null
git -C human config user.email harness@example.invalid
git -C human config user.name  "unrelated human"
git -C human commit -q --allow-empty -m "fix: typo in README"
git -C human push -q origin HEAD:main
bash "$SCRIPT_UNDER_TEST" repo "$BASE_SHA" "$REGEX" 2>/dev/null
check "3b main advanced, but not by us" no-publish $?

# --- 4. Pre-flight "already published, skipping" path -> publish ------------------------------
# Models the wrapper's cheap pre-flight guard: a prior session already published, so success=1 is
# set without running Stage B at all. BASE_SHA is deliberately NOT rebased here — the wrapper's
# MATCHING branch breaks before reaching the rebase line; only its unmatched else-branch rebases.
fresh
git -C wt commit -q --allow-empty -m "$SUBJ"
git -C wt push -q origin HEAD:main
bash "$SCRIPT_UNDER_TEST" repo "$BASE_SHA" "$REGEX" >/dev/null
check "4 pre-flight skip: already published, BASE_SHA unrebased" publish $?

# --- 5. Cannot tell: origin unreachable -> must NOT report publish ----------------------------
# "When a check cannot tell, it must fail, never pass." Point repo/'s remote at a path that does
# not exist: deterministic, no network needed. This also exercises the real fetch-retry loop, so
# the case takes a few seconds; exhausting the retries must still refuse to pass.
fresh
git -C repo remote set-url origin "$TMP/does-not-exist.git"
bash "$SCRIPT_UNDER_TEST" repo "$BASE_SHA" "$REGEX" 2>/dev/null
rc=$?
check    "5  origin unreachable — cannot tell, must not pass" no-publish "$rc"
check_rc "5b cannot-tell is exit 2, not a clean no-match" 2 "$rc"

# --- 5c. Cannot tell: the fetch SUCCEEDS but origin/main is unresolvable ----------------------
# The branch no other case reaches, and the one whose failure mode is worst. If NEW_MAIN_SHA is
# allowed to be empty, "${BASE_SHA}..${NEW_MAIN_SHA}" collapses to "BASE..HEAD" — silently a
# different question, about the LOCAL branch instead of the remote — and any local, unpushed
# loop-news commit then reads as PUBLISHED. A single-branch clone reproduces it honestly:
# `git fetch origin main` succeeds and writes FETCH_HEAD, but the configured refspec covers only
# the cloned branch, so refs/remotes/origin/main is never created. (Shallow single-branch clones
# are what most CI checkouts are, so this is a shape a real caller can be handed.)
rm -rf origin.git wt repo human narrow
git init -q --bare origin.git
git clone -q origin.git wt 2>/dev/null
git -C wt config user.email harness@example.invalid
git -C wt config user.name  "publish guard harness"
git -C wt checkout -q -b main 2>/dev/null
git -C wt commit -q --allow-empty -m "base"
git -C wt push -q origin HEAD:main
BASE_SHA="$(git -C wt rev-parse HEAD)"
git -C wt checkout -q -b other
git -C wt commit -q --allow-empty -m "unrelated branch"
git -C wt push -q origin HEAD:other
git clone -q --single-branch --branch other origin.git narrow 2>/dev/null
# The fixture is only meaningful if the fetch really does succeed here; assert that, or this case
# would silently degrade into a duplicate of case 5.
if git -C narrow fetch origin main -q 2>/dev/null; then
  bash "$SCRIPT_UNDER_TEST" narrow "$BASE_SHA" "$REGEX" 2>/dev/null
  check_rc "5c fetch ok but origin/main unresolvable" 2 $?
else
  printf '  FAIL  %-56s %s\n' "5c fixture broken: fetch failed, case is vacuous" "fix the fixture"
  FAILURES=$((FAILURES + 1))
fi

# --- 6. Cannot tell: the repo dir is not a git checkout -> must NOT report publish ------------
fresh
mkdir -p not-a-repo
bash "$SCRIPT_UNDER_TEST" not-a-repo "$BASE_SHA" "$REGEX" 2>/dev/null
check_rc "6  target is not a git checkout" 2 $?

# --- 6b. Cannot tell: BASE_SHA unreachable (history rewritten) -> must NOT report publish -----
# The only case that exercises the `git log` failure branch. Without it that branch never runs,
# and a fail-open edit to it would go unnoticed.
fresh
git -C wt commit -q --allow-empty -m "$SUBJ"
git -C wt push -q origin HEAD:main
bash "$SCRIPT_UNDER_TEST" repo "0000000000000000000000000000000000000000" "$REGEX" 2>/dev/null
check_rc "6b base SHA unreachable — git log fails" 2 $?

# --- 6c. Cannot tell: an EMPTY regex must be refused, never treated as a match ----------------
# `grep -qE ""` matches any input, so an empty regex would turn the whole script into exit 0 —
# on a run that published nothing. This is the fabricated-success shape the item exists to close.
fresh
bash "$SCRIPT_UNDER_TEST" repo "$BASE_SHA" "" 2>/dev/null
check_rc "6c empty regex refused, not treated as a match" 2 $?

echo
echo "Static checks against the real wrapper"
echo

# --- 7. Regex drift between this harness and run-loop-news.sh's OUR_COMMIT_REGEX --------------
# Cases 0-6c prove the script's logic against WHATEVER regex it is handed. If the wrapper's regex
# changes and this file's copy does not, every case above keeps passing — against the wrong regex.
WRAPPER_REGEX="$(grep -m1 '^OUR_COMMIT_REGEX=' "$WRAPPER" | sed -E 's/^OUR_COMMIT_REGEX="(.*)"$/\1/')"
if [[ -n "$WRAPPER_REGEX" && "$WRAPPER_REGEX" == "$REGEX" ]]; then
  printf '  ok    %-56s %s\n' "7 REGEX matches the wrapper's OUR_COMMIT_REGEX" "match"
else
  printf '  FAIL  %-56s wrapper=%q harness=%q\n' "7 REGEX drift" "${WRAPPER_REGEX:-<unset>}" "$REGEX"
  FAILURES=$((FAILURES + 1))
fi

# --- 8. WIRING + ORDERING of the call site inside run-loop-news.sh ---------------------------
# Four fixed-string anchors, each required to appear EXACTLY ONCE first — a grep that matches
# nothing must fail loudly, never silently skip the check it was supposed to perform — then their
# line numbers must run in this order:
#   the all-attempts-failed notify  <  the assert call  <  the run-complete line  <  retirement
# The middle anchor is the WHOLE invocation, not just the script's name: it proves the call passes
# $REPO_ROOT, $BASE_SHA and $OUR_COMMIT_REGEX — a correct check wired to the wrong arguments is
# still a broken gate. None of the four may appear anywhere else in the file, comments included,
# which is why the retirement anchor is its comment line and not `rm -f "$SEED_ARTIFACT"` (the new
# A13 comment block quotes that, so it now appears twice).
A1='All ${MAX_ATTEMPTS} attempts failed'
A2='ASSERT_OUT="$(bash "$REPO_ROOT/scripts/assert-published.sh" "$REPO_ROOT" "$BASE_SHA" "$OUR_COMMIT_REGEX" 2>&1)"'
A3='Run complete (succeeded on attempt'
A4='# Retire the artifact so a later run today re-searches'
n1=$(grep -Fc -- "$A1" "$WRAPPER"); n2=$(grep -Fc -- "$A2" "$WRAPPER")
n3=$(grep -Fc -- "$A3" "$WRAPPER"); n4=$(grep -Fc -- "$A4" "$WRAPPER")
if [[ "$n1" -ne 1 || "$n2" -ne 1 || "$n3" -ne 1 || "$n4" -ne 1 ]]; then
  printf '  FAIL  %-56s failed=%s call=%s complete=%s retire=%s (need 1 each)\n' \
    "8 all four call-site anchors present exactly once" "$n1" "$n2" "$n3" "$n4"
  FAILURES=$((FAILURES + 1))
else
  l1=$(grep -Fn -- "$A1" "$WRAPPER" | cut -d: -f1); l2=$(grep -Fn -- "$A2" "$WRAPPER" | cut -d: -f1)
  l3=$(grep -Fn -- "$A3" "$WRAPPER" | cut -d: -f1); l4=$(grep -Fn -- "$A4" "$WRAPPER" | cut -d: -f1)
  if [[ "$l1" -lt "$l2" && "$l2" -lt "$l3" && "$l3" -lt "$l4" ]]; then
    printf '  ok    %-56s %s < %s < %s < %s\n' "8 assert sits after the retry loop, before retirement" "$l1" "$l2" "$l3" "$l4"
  else
    printf '  FAIL  %-56s lines %s / %s / %s / %s are out of order\n' \
      "8 assert sits after the retry loop, before retirement" "$l1" "$l2" "$l3" "$l4"
    FAILURES=$((FAILURES + 1))
  fi
fi

# --- 9. Both scripts still parse ---------------------------------------------------------------
if bash -n "$WRAPPER" 2>/dev/null && bash -n "$SCRIPT_UNDER_TEST" 2>/dev/null; then
  printf '  ok    %-56s %s\n' "9 run-loop-news.sh and assert-published.sh parse" "ok"
else
  printf '  FAIL  %-56s %s\n' "9 a script does not parse (bash -n)" "fix this first"
  FAILURES=$((FAILURES + 1))
fi

echo
if [[ "$FAILURES" -eq 0 ]]; then
  echo "PASS — real publishes are recognised, silent non-publishes and unanswerable checks are"
  echo "       refused, the call site is correctly wired and ordered, and the sanity case proves"
  echo "       this harness can fail."
  exit 0
fi
echo "FAIL — $FAILURES check(s) behaved wrongly. assert-published.sh, its call site, or this"
echo "       harness is broken. Do not trust a passing case from a harness whose sanity case"
echo "       did not fail."
exit 1
