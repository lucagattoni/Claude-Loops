# RESUME — backlog step 11 (C7 + C10) · COMPLETE

**Branch:** `20260906_1548-step11-c7-c10-sweeps` · **shipped as `v3.4.0`**
**Plan item:** `plans/20260904_2053-open-work-backlog.md` §8 step 11 — struck, with H1.

## Done
- **C10** — 3,774/3,774 previously-unswept changelog bullets, 24/24 chunks, zero count
  mismatches → 29 edits across 18 docs. Evidence: `plans/20260906_2306-c10-changelog-sweep-evidence.md`.
- **C7** — 4,025 previously-unverified doc lines, 34/34 units, 656 claims, 471 URLs → 150 edits
  across 25 files. Evidence: `plans/20260907_0100-c7-doc-sweep-evidence.md`.
- **H1** closed — `05 06 19 35` stamped; `31` waived with cause and the grep false positive named.
- `kb-structure-check.sh` §5 (README vs `SOURCES.md`) and §6 (Part II stamps), both proven by
  negative test.
- 21 `KB_GAPS` entries, two digest entries, backlog + `CLAUDE.md` re-pointed.

## What is NOT done, and is logged rather than implied
- **`docs/24` is under-sampled.** r = -0.64 between unit size and scrutiny; it got 11.8 claims per
  100 lines against a 26.5 small-unit rate. Re-cut as eight ~100-line units with a floor of 20
  claims/100; a unit under the floor counts as **not checked**. In `KB_GAPS.md`.
- The 47 UNVERIFIABLE claims need triage against what is already on disk (one was settleable by a
  Wayback call and is now fixed).
- C10 left 245 of 335 findings unrefuted under a cap — marked, not hidden.

## Next
**Step 13 (H14)** — retitle the IST-dependent scheduling comments **before 2026-10-25**. Plus `C4`
in §4. Nothing else in the backlog is open.

## Lessons this branch paid for
1. **A null adjudicator must not destroy the run.** Reading `adjudication.apply` unguarded threw
   away every completed agent, twice.
2. **Bank discovery before spending on refutation.** Four session limits; C7 survived only after
   being restructured into a find-only pass whose results were cached.
3. **Resume replays the longest unchanged PREFIX of `agent()` calls.** Inserting a new call site
   invalidates everything after it — content-identical prompts do not help. Recover from
   `journal.jsonl` and run a fresh minimal workflow instead.
4. **A bucket guarded on `votes.length` silently drops items whose refuter crashed.** Give them
   their own bucket and hand them to the judge marked UNREFUTED.
5. **Prove a new check fires.** §6's first regex reported clean over a corpus it had undercounted.
