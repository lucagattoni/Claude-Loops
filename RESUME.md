# RESUME — backlog step 13 (C4 + H14) · COMPLETE

**Branch:** `20260907_0757-c4-zero-finding-commit-and-h14-dst`.
**Plan item:** `plans/20260904_2053-open-work-backlog.md` §8 step 13 — struck, with `C4` and `H14`.
**Backlog state:** steps 1–13 shipped; **§4 and §5 are empty**; one new item open (`A13`, §3).

## Done
- **C4** — a zero-finding run now **commits** its digest section instead of discarding it.
  Decision taken by the user: commit, cut no release. `integrate-loop-news/SKILL.md` Phase 4,
  5a, 5b and 5d; downstream claims corrected in `CHANGELOG.md:10`, `docs/34`, `docs/09`.
- **H14** — the two live DST-dependent comments (`scripts/com.luca.loop-news.plist:15`,
  `.github/workflows/tracker-watchdog.yml:15`) now state the **rule**, not one regime's stamp,
  so the 2026-10-25 date is removed rather than deferred to the next changeover.
- Backlog corrected where this work proved it wrong: C4's `D1` half was already shipped; H14's
  `CHANGELOG.md:867` is the `05:00 local (= 04:00 UTC)` bullet, whose line number moves with every
  release — a historical entry that stays as written; H14's live
  surface was two comments, not the two files the row named.
- `CLAUDE.md`'s open-work note slimmed to a pointer (165 → 158 lines); its "do not re-spend
  budget on" list relocated to backlog §1, which is now its one home.

## What is NOT done, and is logged rather than implied
- **`A13`** (new, §3) — `run-loop-news.sh:477` still logs `Run complete` on Stage B's exit
  status. C4 makes the artifact assertion *possible* (every run now commits, so a
  `^feat: loop news run ` commit in the delta is a reliable post-condition) but does not make
  it. Deliberately deferred: it changes unattended retry-path behaviour and deserves its own
  adversarial review.
- Carried from step 11, still open: **`docs/24` is under-sampled** (re-cut as eight ~100-line
  units, floor of 20 claims/100; a unit under the floor counts as not checked); **47
  UNVERIFIABLE claims** need triage against what is already on disk; **C10 left 245 of 335
  findings unrefuted** under a cap — marked, not hidden. All in `KB_GAPS.md`.

## Concurrency note — the daily tracker runs alongside this
It fires daily at 05:00 Europe/Dublin local (04:00 UTC under IST, 05:00 UTC under GMT) and has
already landed a run today at 06:30 UTC. On 20260907 it pushed 76 findings into 12 docs **21
minutes after** step 11 landed. **Re-run `scripts/kb-structure-check.sh` after any concurrent
landing** — its §5 caught a README/`SOURCES.md` drift within hours on its first real run.

**New, from this branch:** the tracker's own commit behaviour just changed. A run that publishes
an *empty* digest section is now correct and expected — do not "fix" it, and do not read it as a
broken pipeline.

## Lessons carried forward
1. **A null adjudicator must not destroy the run.** Reading `adjudication.apply` unguarded threw
   away every completed agent, twice.
2. **Bank discovery before spending on refutation.** Four session limits; C7 survived only after
   being restructured into a find-only pass whose results were cached.
3. **Resume replays the longest unchanged PREFIX of `agent()` calls**, so never insert a new
   `agent()` call into a run you mean to resume — it invalidates everything after it even when
   prompts are byte-identical. Recover from `journal.jsonl` and launch a fresh minimal workflow.
   *(This was recorded twice in the previous RESUME.md, as items 3 and 6; merged here.)*
4. **A bucket guarded on `votes.length` silently drops items whose refuter crashed.** Give them
   their own bucket and hand them to the judge marked UNREFUTED.
5. **Prove a new check fires.** §6's first regex reported clean over a corpus it had undercounted.
6. **Anything a repo file instructs must live in the repo.** Two instructions once pointed at
   numbered lists that existed only in a workflow transcript. Before proposing a session clear,
   grep for references to off-disk artifacts and walk every link.
7. **Backlog line numbers are stale by default.** Both of step 13's items cited lines that had
   drifted (`SKILL.md:300` gone; `CHANGELOG.md:867` was `:1609` before this release and moves
   again with the next). Re-grep the anchor text; never edit by the line number a plan records —
   and never *write* one either: this branch's first pass recorded that lesson and then cited five
   line numbers its own commit went on to shift.
8. **A guard written into a procedure must be placed where its precondition holds.** This branch's
   first pass put "assert the staged diff is non-empty" in Phase 5b — before any `git add`, and
   before the `--soft` reset that makes the index mean "everything this run changed". It would
   have halted every *correct* quiet-day run: a check that cannot tell, failing always, which is
   the same defect as one that cannot tell and passes always. Reading the phase in isolation did
   not reveal it; tracing the index state through the whole of Phase 5 did.
9. **A harness that cannot produce a failure proves nothing.** Two attempts at the scratch-repo
   proof leaked staged state across `git checkout` and reported a broken run as healthy. Add a
   sanity case that must fail, and watch it fail, before trusting any case that passes.
10. **Verify a date, do not compute one.** "2027-03-29" was written as the next DST changeover
   from the last-Sunday-of-March rule. The last Sunday of March 2027 is the **28th**. The rule was
   right and the arithmetic was wrong, which is the shape that survives review — the fix was to
   drop the date, since H14's whole point is comments that do not depend on one.
