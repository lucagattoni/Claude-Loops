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
- [ ] C10 sweep workflow — running (`wf_fdc6bf90-b66`)
- [ ] C7 find workflow
- [ ] Apply edits, one commit per doc, `mkdocs build --strict` bare before each
- [ ] Update backlog §8 + §5 H1 row + `CLAUDE.md` note in the SAME PR
- [ ] README "Seven source types" table sync (counts drifted: `x`=9, `html`=9, total 60)
- [ ] Release + tag + GitHub release

## Next command
Check the workflow, then apply. Scratchpad (chunks, brief, blame maps):
`/private/tmp/claude-501/-Users-luca-Code-repos-github-lucagattoni-Claude-Loops/fc9ce808-8f72-42bc-b030-33f5fe85cc79/scratchpad`

## Gates (from the backlog §9)
- `uv run --with-requirements requirements-docs.txt mkdocs build --strict` — run **bare**
- `grep -rn 'repo: github\.com' docs/ | grep -v '\[github'`
- `bash scripts/kb-structure-check.sh` — triage every hit or record a waiver
- Public repo — PRIMARY CHECK on every file
