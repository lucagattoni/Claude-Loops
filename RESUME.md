# RESUME — backlog `A13` (the wrapper asserts on the published commit) · COMPLETE

**Branch:** `20260907_0932-a13-assert-published-commit`.
**Plan item:** `plans/20260904_2053-open-work-backlog.md` §3 — `A13`, struck.
**Backlog state:** §4 and §5 are empty; **one item is open, `A14`**, opened by this branch's own
adversarial review. Open *content* work still sits in `KB_GAPS.md` § *Active Gaps*.

## Done
- **`scripts/assert-published.sh`** (new) — re-fetches `origin/main` and requires a commit matching
  `OUR_COMMIT_REGEX` in `BASE_SHA..origin/main`. Exit **0** published / **1** checked, no match /
  **2** could not check. Callers treat 1 and 2 alike. **Every** cannot-tell path exits 2: bad
  arguments, a non-positive-integer retry count, a non-git target, fetch failure after a bounded
  retry, an unresolvable `origin/main`, a `BASE_SHA` that is **not an ancestor** of the new
  `origin/main`, a `git log` failure, and a grep that itself fails on a malformed regex. An empty
  regex is refused up front — `grep -qE ""` matches any input, so it would have fabricated a pass.
- **`scripts/run-loop-news.sh`** — calls it between the retry loop's failure exit and the
  artifact-retirement block, above the run-complete line. New exit code **6**. The verdict line
  reaches the day log on both paths, so a healthy run leaves positive evidence the check ran.
- **`scripts/verify-publish-guard.sh`** (new, **18 checks**) — two clones of one bare origin, so
  "committed but never pushed" is constructable rather than vacuous. Sanity case first; both
  healthy shapes; the main-moved-but-not-by-us twin; eight cannot-tell cases, three of which assert
  **which guard fired** rather than only that one did; and static cases 7/8 pinning the regex
  against the wrapper's and the call site's **arguments, ordering and terminating `exit 6`**.
- **`.github/workflows/guards.yml`** (new) — runs both guard harnesses on any PR or push touching
  `scripts/**` or `.claude/skills/**`. Nothing invoked either before this.
- Docs synced in the same change: `docs/09` gained a point 5 (its old parenthetical "the wrapper
  still judges success by exit code" was falsified by this commit), `docs/17`'s scheduler-death row
  now names the implementation, `LOOP_ENGINEERING.md`'s row 9, `CLAUDE.md` (open-work note → a
  one-line pointer; two map rows for the new scripts), and the backlog.

## What is NOT done, and is logged rather than implied
- **`notify()` is still desktop-only.** An osascript popup plus a gitignored day log, both on the
  machine that failed. A caught non-publish stays invisible off-machine for up to 48h until
  `check-digest-freshness.sh` pages STALE. Named in the code, not solved. Widening it is a
  separate, larger question.
- **`A14` is open** — the wrapper's two sibling guards (pre-flight "already published, skipping"
  and failure-path "failed AFTER publishing") grep the same delta without the ancestry
  precondition. Not a fabricated-success path: both take the conservative action, and
  `assert-published.sh` then exits 2 on the same delta, so the run exits 6. The residual is a
  misdiagnosis in the log. Full analysis in the backlog's §3.
- **The `git log` failure branch in `assert-published.sh` is unreachable in practice** and is
  therefore uncovered — reaching it needs a repo where `merge-base` succeeds and `log` does not.
  Kept as defence in depth, recorded as an equivalent mutant, **not** claimed as tested.
- **The premise is inferred, not measured.** That a Phase 5c/5d abort leaves `claude -p` exiting 0
  is read from `SKILL.md` and `run_claude()`, never observed. The assertion is a post-condition, so
  it holds either way — but the next run that legitimately trips the 5d guard should have its
  observed `claude -p` exit code recorded in the day log.
- **A transient network failure right after a genuine push now raises a false alarm** (exit 6 on a
  run that succeeded). The 3-try fetch retry reduces it; nothing eliminates it, and nothing should
  — the alternative is a stale-ref fallback, which is the fabricated-success class this closes.
- Carried, still open in `KB_GAPS.md`: **`docs/24` under-sampled**; **47 UNVERIFIABLE claims** to
  triage; **C10 left 245 of 335 findings unrefuted** under a cap — marked, not hidden.

## Concurrency note — the daily tracker runs alongside this
It fires daily at 05:00 Europe/Dublin local (04:00 UTC under IST, 05:00 under GMT) and has landed a
run mid-flight before — on 20260907 it pushed 76 findings into 12 docs 21 minutes after a branch
landed. **Re-run `scripts/kb-structure-check.sh` after any concurrent landing.**
A run that publishes an *empty* digest section is correct and expected since `v3.4.2` — do not
"fix" it. **New from this branch:** a run that publishes *nothing at all* now exits 6 instead of
logging success, and leaves `logs/findings-YYYYMMDD.json` and the `loop-news-run-YYYYMMDD` branch
in place for a cheap resumed re-run.

## Lessons carried forward
1. **A mutation pass earns its cost by surviving.** Round 1: eight mutants, seven killed — the
   survivor was the one the design had argued hardest about (an unchecked `rev-parse` letting
   `BASE_SHA..` collapse to `BASE_SHA..HEAD`). Round 2, after the adversarial review's fix:
   12 mutants, 11 killed, 1 equivalent. **Reasoning about a guard is not coverage of it**; only
   the mutant showed the hole, and case 5c (single-branch clone) closed it.
2. **A new guard can silently un-cover an old one.** Adding the ancestry check masked two mutants
   round 1 had killed: with several guards able to return exit 2, removing one is hidden by the
   next, and the mutant survives with no test touched. **Exit code alone stops discriminating —
   assert which guard fired.** Three cases now pin the diagnostic string.
3. **Reproduce the mechanism; do not trust the label.** Case 6b was called "git log fails" and
   never exercised that branch — the ancestry guard reaches an unresolvable base first. Running it
   and reading the message is what showed that; the label had been wrong since it was written.
4. **A fixture must assert its own precondition.** Case 5c is only meaningful if its `fetch`
   really succeeds; if it silently failed, the case would degrade into a duplicate of case 5 and
   still print `ok`. It now checks and fails loudly instead.
5. **An empty string is not a permissive check, it is a guaranteed pass.** `grep -qE ""` matches
   any input, including the blank line an empty delta produces. Any regex arriving from a caller
   must be rejected when empty.
6. **Some hazards are properties of the text, not of the behaviour.** No amount of behavioural
   testing of `assert-published.sh` can see *where* it is called from, and the call site's
   position is the thing the backlog warned would make the fix destructive. That needs a static
   check — and it caught the ordering mutant when every git-state case stayed green.
7. **Deleting a stale note can be worse than editing it.** `CLAUDE.md`'s open-work note met its own
   stated delete condition, but deleting it outright would have left the backlog and `KB_GAPS.md`
   unreachable from the entry point — the exact defect `v3.5.0` had just fixed for `RESUME.md`.
   Replaced with a one-line pointer instead.
8. **Carried from the last branch, still true:** backlog line numbers are stale by default (re-grep
   the anchor, never cite a new number); a guard must be placed where its precondition holds; a
   harness that cannot produce a failure proves nothing; verify a date, do not compute one.
