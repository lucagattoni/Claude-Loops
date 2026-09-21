# RESUME — handover 20260921 · **`D4` resolved — watchdog is now a 14-day staleness nudge**

**Repo state:** `main` at `ce5d763`, clean, no open branches or worktrees. All gates green.
**Tags/releases:** in step — nothing awaiting a backfill.
**Backlog tiers:** `D1`–`D4` are all decided, so §2 is closed; §3 and §4 are empty. **§5 has two
open items**, both opened by this PR: `A15` (`--status` should check the threshold against the live
mode) and `A16` (no off-machine signal separates "no sweep ran" from "a sweep ran and published
nothing"). Open **content** work is in `KB_GAPS.md` § *Active Gaps*.
**Last session:** shipped `A13` (`v3.6.0`) and `A14` (`v3.6.2`); backfilled `v3.6.1` and `v3.6.3`;
moved the tracker to on-demand runs (`v3.7.0`), keeping the schedule one switch away; resolved `D4`
— `MAX_AGE_HOURS` raised to 336 (14 days), single-homed in `scripts/check-digest-freshness.sh`
(`v3.7.1`).

---

## 1. `D4` — RESOLVED 20260921

**Applied: option (b).** `MAX_AGE_HOURS` raised **48 → 336 (14 days)**, single-homed in
`scripts/check-digest-freshness.sh`; the workflow's `env:` override is **deleted**, not set to 336.
Shipped in `v3.7.1`.

**What it was.** Once runs went on demand (`v3.7.0`, 20260912),
`.github/workflows/tracker-watchdog.yml` stopped measuring health and started measuring *how
recently you chose to run a sweep*. It went red within two days of the pause and stayed red — 11
consecutive red scheduled runs, 20260912 → 20260921 — which is the *Notification Fatigue* pattern
this KB documents in `docs/17`, running in our own CI.

**Two things the fix had to do that the one-line framing missed.**

1. **The number had two homes.** `run-loop-news-now.sh --status` calls
   `check-digest-freshness.sh` with no env, so it reads the script's default and never CI's value.
   Editing only the workflow would have left `--status` judging at 48 while CI judged at 336 — the
   same silent drift that got option (d) rejected, merely relocated. The backlog's "one-line
   change" claim is corrected in place in §2.
2. **The STALE message was misdirecting.** It told the operator to run
   `launchctl print gui/$(id -u)/com.luca.loop-news` — a LaunchAgent deliberately disabled since
   `v3.7.0`. At 48h the alarm fired constantly and the wrong advice was cheap; at 336h it fires
   fortnightly, so every firing must be actionable on its own. It now names
   `run-loop-news-now.sh` first and reaches for launchctl only if `--status` says SCHEDULED.
   **Six survey agents read those lines and cleared them; only the adjudicator caught it.**

**The attached condition — do not lose this.** 336 concedes real sensitivity: a silently failing
*scheduled* run would go unnoticed for two weeks instead of two days. **If the schedule is ever
restored, set `MAX_AGE_HOURS` back to 48 in the same commit as the switch.**
`scripts/SCHEDULING.md`'s "To scheduled" procedure now carries that step, and "To on demand" carries
its mirror. Without it, (b) quietly becomes (a)'s blind spot.

**A red run under ON DEMAND is a TRUE positive.** Its fix is `bash scripts/run-loop-news-now.sh`,
never a wider threshold — widening until the check stops firing is this repo's *"a check that cannot
tell must fail"* rule broken in the other direction: a check that cannot fail.

Full options table, evidence and the original recommendation: `plans/20260904_2053-open-work-backlog.md` §2.

> **Lesson kept:** §2 sits outside every tier-emptiness check. `D4` sat there from 20260912 to
> 20260921 while §3/§4/§5 all read empty. An empty tier is never proof that nothing is open.

---

## 2. How the tracker runs now — ON DEMAND

**Decided 20260912 by the user: on-demand runs are the norm, replacing the daily schedule.** What
looked like an outage earlier that day (STALE 76h, launchd job `disabled`) was the deliberate pause
that preceded this decision. Nothing is broken.

```bash
bash scripts/run-loop-news-now.sh            # run a sweep now (~45-60 min, real money)
bash scripts/run-loop-news-now.sh --status   # which mode is live, when it last published
bash scripts/run-loop-news-now.sh --check    # the environment it would use; runs nothing
```

**Both modes stay supported, and switching is two commands either way** — `scripts/SCHEDULING.md`
is the one home for the procedure, including the trap that cost a diagnosis: `launchctl enable`
must precede `bootstrap`, or the job silently inherits the disabled flag and stays dead.

**Why there is a launcher rather than "just run the script".** An interactive shell has sourced
your profile, so its `PATH` is a *superset* of the recorded one; `bash scripts/run-loop-news.sh`
from a terminal can succeed where the scheduled path would fail, and you would not find out until
you switched modes. The launcher reads `PATH`, `HOME`, the working directory and the log paths out
of `scripts/com.luca.loop-news.plist`, adds the identity variables launchd synthesizes but no plist
declares (`USER`/`LOGNAME`, from `id -un` — see `v3.7.2`), and starts the wrapper under `env -i`
with those, so the two modes match **by construction, not by intent** — closely, though not
identically: the launchd-internal variables are not reproducible from outside launchd.
`com.luca.loop-news.plist` is
therefore the single environment definition, not merely a schedule — **do not delete it**, it would
break on-demand runs too.

Everything else is unchanged: same day log (`logs/loop-news-YYYYMMDD.log`), same catch-all
(`logs/launchd.log`, tee'd so you also watch it live), same commit-and-push to `main`, same exit
codes — **6** = reported success but published nothing, **7** = failed and could not tell whether it
had published.

## 3. What `A13`/`A14` do and — importantly — do **not** catch

This outage is the proof. The guards shipped last session assert that **a run which started and
reported success actually published**:

- `scripts/assert-published.sh` — exit **0** published / **1** checked, not ours / **2** cannot
  tell. Every cannot-tell path exits 2, including a `BASE_SHA` that is not an ancestor of the new
  `origin/main`.
- `published_state()` in `run-loop-news.sh` is the single implementation; four call sites use it.
- Wrapper **exit 6** = reported success, published nothing. **Exit 7** = failed and could not tell
  whether it had published, so it refused to retry. Table in `scripts/SCHEDULING.md`.

**None of that fires when the run never starts.** A disabled scheduler produces no log, no exit
code and no notification — the two failure modes look identical from inside the repo, which is the
original eight-week-outage lesson restated. **The only thing that caught this was the off-machine
watchdog**, and it needed 48h to do it.

---

## 4. Open work

The backlog is empty. Open **content** work is in `KB_GAPS.md` § *Active Gaps*:

- **`docs/24` is under-sampled** — re-cut as eight ~100-line units with a floor of 20 claims per
  100 in-scope lines; a unit under the floor counts as not checked. **Re-measure first, every
  time:** 1,271 lines when the gap was written, 1,354 on 09-08, **1,445 on 09-12** — the tracker
  grows it faster than the gap note can track, so any unit boundaries you inherit are already wrong.
- **47 UNVERIFIABLE claims** need triage. The numbered list is in
  `plans/20260907_0645-c7-unverifiable-and-coverage-appendix.md`. Drop #29; re-run #13/#33/#34/#44
  with the Wayback fallback that settled the OpenAI date.
- **C10 left 245 of 335 findings unrefuted** under a cap — marked, not hidden.

### Known limits, recorded rather than implied
- **`notify()` is desktop-only**, so the only off-machine signal is `check-digest-freshness.sh` —
  now a 336h (14-day) staleness nudge (`D4`, 20260921), not a same-day check. Under ON DEMAND there
  is no fixed fire time to measure a lag against, so a lost sweep is invisible off-machine until
  roughly a fortnight of silence accumulates. That is the deliberate cost of (b).
- **`cleanup()` is never executed by any test**, yet exits 6 and 7 both *promise* the operator that
  the artifact and checkpoint branch are preserved. That promise is read, not run. An executable
  `cleanup()` test is the obvious next infrastructure step.
- **The premise is inferred:** that a Phase 5c/5d abort leaves `claude -p` exiting 0 is read from
  `SKILL.md` and `run_claude()`, never observed.

---

## 5. Lessons carried forward

1. **A guard that asserts on a run's output cannot see a run that never happened.** `A13`/`A14`
   close "started and published nothing"; only the off-machine watchdog closes "never started".
   Both are needed, and they fail in different places.
2. **Commit before mutating.** `git checkout -- <file>` restores to the last *commit*. Last session
   two must-fixes' worth of uncommitted work were silently reverted mid-mutation-run; only the
   harness file survived, because it was never a mutation target.
3. **Fixing a defect without pinning it is how it comes back.** After closing the rc-127 hole,
   *restoring* it still left the harness green until a check was added for it. Three of
   `verify-publish-guard.sh`'s 21 checks exist only because a mutant survived.
4. **Routing through a script introduces statuses you did not enumerate.** `bash` returns 127 for a
   missing file; a `case` listing only the contract's codes with a permissive `*)` is a fabricated
   result.
5. **A justification comment is a claim, and gets checked like one.** "The 48h watchdog pages for
   it" was false by 19 hours, and it was the sole ground for the trade-off it justified.
6. **Never put a count in prose without re-deriving it at the end.** "162 → 159 lines" and
   "22 checks" were both wrong when written, in the same day.
7. **Carried, still true:** backlog line numbers are stale by default (re-grep the anchor); a
   fixture must assert its own precondition; an empty regex is a guaranteed pass; some hazards are
   properties of the text and need a static check.
