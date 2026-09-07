# RESUME — backlog step 11 (C7 + C10)

**Branch:** `20260906_1548-step11-c7-c10-sweeps` · started 20260906 15:48 UTC
**Plan item:** `plans/20260904_2053-open-work-backlog.md` §8 step 11 — C7 + C10, plus H1's
remainder (`05 06 19 31 35` version stamps) and the README "Seven source types" sync.

## Scope, measured (not as the backlog states it)
- **C10** — unswept changelog range `0.2.21`–`2.1.199` **plus** `2.1.261`+ (the last sweep covered
  `2.1.200`–`2.1.260`). **3,774 top-level bullets across 335 versions**, in 24 chunks.
  **Correction to the backlog:** it says "187 of 2,076 bullets ... across 385 versions". The real
  total is **5,200 bullets across 387 versions** — `Fixed` alone is 2,767, which already exceeds the
  claimed total. The 2,076 figure is wrong and understates the unswept range by ~2.5x.
  `LOOP_ENGINEERING_NEWS.md:644,649,714` and `CHANGELOG.md:792` carry the same wrong number.
- **C7** — 23 docs (C7's 20 minus `11` and `23`, which `CLAUDE.md` marks already swept, plus H1's
  `05 06 19 31 35`). **~4,025 pre-2026-09-04 lines** are the actual unverified scope, measured by
  `git blame`. `docs/35` is 0% pre-0904 (entirely new) — stamp-only. `docs/19` is 100% pre-0904.

## State
- [x] Worktree created; structure-check baseline captured (matches the recorded standing waivers
      exactly: `docs/18`/`docs/32` appendix orphans, `docs/31:90` `@mention`, `docs/04:319`,
      `docs/16:77` — all documented non-defects in H6/H11).
- [x] **README "Seven source types" synced** + `kb-structure-check.sh` § 5 added to catch the drift
      mechanically. Guard proven to fire on the exact historical drift and on a missing Total row.
- [x] **H1 baseline verified**: `05 06 19 31 35` each have **zero** version markers of any kind
      (not just zero `v2.1.x`). The backlog's correction about `35` is right.
- [x] **C10 denominator diagnosed** — see `finding-c10-denominator.md` in the scratchpad. Three of
      the prior digest's four counts (`Fixed` 2,740, `Changed` 168, `Removed` 35) reproduce exactly;
      only the "All = 2,076" total is wrong. Real total then: **5,132**.
- [x] **C10 SHIPPED.** 3,774/3,774 bullets, 24/24 chunks, 0 mismatches. 520 verified rows →
      29 edits across 18 docs (one commit each), 10 gaps to `KB_GAPS.md`. Evidence pack:
      `plans/20260906_2306-c10-changelog-sweep-evidence.md`.
- [x] **The 2,076 figure corrected** — `plans/` in place, digest by a NEW word-initial entry
      (`check-digest-freshness.sh` confirmed it still reads the 2026-09-06 04:00 run as newest).
- [x] Duplicated `## Session Watchdog` section consolidated into `docs/25`.
- [ ] **C7 find-only pass** — running as `wf_5bb263dc-d3c`; 8 of 34 units already cached
      (40 findings, 176 claims, 132 URLs). Re-run must report `lostUnits` empty.
- [ ] C7 finalise workflow (shortlist → refute → Opus adjudicate → Opus critic)
- [ ] Apply C7 edits, one commit per doc, `mkdocs build --strict` bare
- [ ] H1 stamps for `05 06 19 31 35` (all verified to have ZERO version markers of any kind)
- [ ] Update backlog §8 step 11 + §5 H1 row + the `CLAUDE.md` note in the SAME PR
- [ ] Release + tag + GitHub release + PR

## Lessons worth keeping

1. **A null adjudicator must not destroy the run.** Both workflows first died reading
   `adjudication.apply` with no guard, throwing away every completed agent. Both now default the
   adjudicator and critic and report `adjudicatorLost`. A partial run must return its partial work.
2. **Bank discovery before spending on refutation.** Four session limits were hit. C10 survived
   because sweep+verify were cached before refutation started; C7's first full run lost 26 of 34
   finders and everything downstream. C7 is now a **find-only** pass — findings get banked, then a
   separate finalise workflow shortlists/refutes/adjudicates (the shape that worked for C10).
3. **Agents miscount large JSON arrays.** Three C10 sweepers reported reading fewer candidates than
   were delivered (97 vs "80"). The completeness critic read that as a pipeline leak reproducing this
   repo's signature defect. It was not: the verify agent produced findings from array indices 63-96,
   so it saw the whole set. **Check a peer's claim before acting on it.** The critic's
   recommendation still stands — assert `delivered == swept` in code rather than after the fact.

## C7 note for whoever applies its findings
The C7 finders read the **primary checkout on `main`**, which does NOT yet have this branch's C10
fixes. Two C7 findings (`docs/08:480-487` precedence, `docs/08:252-266` PermissionRequest output
contract) are already fixed here — independent corroboration from a different method, not new work.
Apply C7 findings by **anchor match against this worktree**; an anchor that no longer matches is the
safe signal that C10 already fixed it.
