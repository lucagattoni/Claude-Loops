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
- [ ] C10 sweep workflow — resumed as `wf_fdc6bf90-b66` (10 sweeps cached from the killed run)
- [ ] C7 find workflow — script patched and ready (`c7-doc-sweep-wf_146b1e97-fb1.js`), NOT started;
      run it only after C10 finishes. Running both at once is what hit the session limit.
- [ ] Apply edits, one commit per doc, `mkdocs build --strict` bare before each
- [ ] Update backlog §8 + §5 H1 row + `CLAUDE.md` note in the SAME PR
- [ ] Correct the 2,076 figure: `plans/` in place; `LOOP_ENGINEERING_NEWS.md` + `CHANGELOG.md` by a
      NEW append-only entry whose header starts with a WORD, never a digit
- [ ] Release + tag + GitHub release

## Lesson worth keeping
Both workflows died on a session limit and BOTH threw away every completed agent because
`adjudication.apply` was read without a null guard — the adjudicator returning `null` on error
destroyed 10 good sweeps' worth of output. Both scripts now default the adjudicator and the critic,
and report `adjudicatorLost` rather than crashing. A partial run must still return its partial work.

## Next command
Check the workflow, then apply. Scratchpad (chunks, brief, blame maps):
`/private/tmp/claude-501/-Users-luca-Code-repos-github-lucagattoni-Claude-Loops/fc9ce808-8f72-42bc-b030-33f5fe85cc79/scratchpad`

## Gates (from the backlog §9)
- `uv run --with-requirements requirements-docs.txt mkdocs build --strict` — run **bare**
- `grep -rn 'repo: github\.com' docs/ | grep -v '\[github'`
- `bash scripts/kb-structure-check.sh` — triage every hit or record a waiver
- Public repo — PRIMARY CHECK on every file
