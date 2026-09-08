# RESUME — backlog `A14` (one home for the delta question) · COMPLETE

**Branch:** `20260908_0650-a14-ancestry-in-sibling-guards`.
**Plan item:** `plans/20260904_2053-open-work-backlog.md` §3 — `A14`, struck.
**Backlog state:** **§3, §4 and §5 are all empty. No backlog items remain open.**
Open *content* work continues in `KB_GAPS.md` § *Active Gaps* — an empty backlog is not an empty repo.

## Done
- **`published_state()`** in `run-loop-news.sh` is the one implementation of "has `origin/main`
  gained one of our commits since `BASE_SHA`?". Four call sites use it; no bare
  `git log … | grep -qE` survives. The pre-flight and failure-path guards had each re-implemented
  it without the ancestry precondition, which reads a rewritten history as *we published*.
- **A cannot-tell branch per guard, in opposite directions** — the part `A14` did not anticipate.
  Pre-flight declines to *start* Stage B; the failure path re-reads once after the loop's own
  backoff, then exits **7** rather than retrying. Retrying the check is not retrying the push.
- **Exit codes documented** in the wrapper header and, for the operator, as a table in
  `scripts/SCHEDULING.md` — none existed anywhere before.
- **`verify-publish-guard.sh` at 21 checks**; `docs/09` point 4 rewritten; `CLAUDE.md`, the
  backlog and `CHANGELOG.md` `[3.6.2]` updated in the same PR.

## What is NOT done, and is logged rather than implied
- **`notify()` is still desktop-only**, and the off-machine backstop is weaker than it reads:
  `check-digest-freshness.sh` runs 09:00 UTC against `MAX_AGE_HOURS` 48 while the tracker fires
  04:00–05:00 UTC, so **a single lost day reads ~29h and pages nobody**. Two consecutive misses
  are needed. Measured, not assumed. Widening `notify()` remains a separate question.
- **`cleanup()` is still never executed by any test.** Exit 6 and exit 7 both *promise* the
  operator that the artifact and checkpoint branch are preserved; that promise is read from the
  code, not run. An executable `cleanup()` test is the obvious next infrastructure step.
- **The premise remains inferred:** that a Phase 5c/5d abort leaves `claude -p` exiting 0 is read
  from `SKILL.md` and `run_claude()`, never observed.
- Carried in `KB_GAPS.md`: `docs/24` under-sampled (now **1,354** lines — re-measure before
  cutting); 47 UNVERIFIABLE claims, numbered in
  `plans/20260907_0645-c7-unverifiable-and-coverage-appendix.md`; C10 left 245 of 335 findings
  unrefuted under a cap.

## Concurrency note — the daily tracker runs alongside this
It fires daily at 05:00 Europe/Dublin (04:00 UTC under IST, 05:00 under GMT) and lands mid-flight
routinely — on 20260908 it published while this branch was open. **Re-run
`scripts/kb-structure-check.sh` after any concurrent landing.** A run publishing an *empty* digest
section is correct since `v3.4.2`. A run publishing *nothing* now exits 6; a run that cannot tell
exits 7. Both preserve `logs/findings-YYYYMMDD.json` and the `loop-news-run-YYYYMMDD` branch.

## Lessons carried forward
1. **Commit before mutating — I broke this rule and paid for it in this branch.** The mutation
   loop calls `git checkout -- <file>`, which restores to the last *commit*, not to the
   pre-mutation state. Two must-fixes' worth of uncommitted work were silently reverted mid-run;
   only the harness file survived, because it was never a mutation target. The rule was already
   written down. Committing costs nothing.
2. **Fixing a defect without pinning it is how it comes back.** After closing the rc-127 hole, the
   mutation pass showed that *restoring* it left the harness green. Three of this branch's checks
   (11, 11b, and case 10's widened shape match) exist only because a mutant survived.
3. **A guard added later can silently un-cover an earlier one.** Adding the ancestry check in
   `A13` masked two mutants a previous round had killed. Exit code alone stops discriminating once
   several guards share one code — assert *which* guard fired.
4. **Routing through a script introduces a status you did not enumerate.** `bash` returns 127 for a
   missing file. A `case` listing only the contract's codes, with a `*)` arm that means "fine", is
   a fabricated result — and the primary checkout is exactly where another agent may remove a file
   mid-run.
5. **A justification comment is a claim, and gets checked like one.** "The 48h watchdog pages for
   it" was false by 19 hours, and it was the sole ground for the trade-off it justified.
6. **Never put a count in prose without re-deriving it at the end.** "162 → 159 lines" and
   "22 checks" were both wrong when written; the file had changed under the first and the second
   was never counted. Both were caught, one by review and one by me, in the same day.
7. **Carried, still true:** backlog line numbers are stale by default (re-grep the anchor); a
   fixture must assert its own precondition; an empty regex is a guaranteed pass, not a lenient
   check; some hazards are properties of the text and need a static check.
