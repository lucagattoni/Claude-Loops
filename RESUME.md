# RESUME — handover 20260912 · **decision `D4` first, then the work**

**Repo state:** `main` at `cec77bb`, clean, no open branches or worktrees. All gates green.
**Tags/releases:** in step — nothing awaiting a backfill.
**Backlog tiers:** `plans/20260904_2053-open-work-backlog.md` §3, §4 and §5 are all empty — but
**`D4` in §2 is open**, and no tier-emptiness check reads §2. See §1 below.
**Last session:** shipped `A13` (`v3.6.0`) and `A14` (`v3.6.2`); backfilled `v3.6.1` and `v3.6.3`;
moved the tracker to on-demand runs (`v3.7.0`), keeping the schedule one switch away.

---

## 1. DECISION `D4` — TAKE THIS FIRST, BEFORE ANY OTHER WORK

**Recorded 20260912 at the user's instruction: this is the first decision a new session takes.**

Now that runs are on demand, `.github/workflows/tracker-watchdog.yml` no longer measures health. It
fails when the newest digest is older than `MAX_AGE_HOURS` (48). Under a schedule that meant *a run
was due and silently failed* — it is the only off-machine signal this pipeline has, and it is how
the 09-11 pause was noticed at all. On demand it measures **how recently you chose to run a sweep**,
so it goes red within two days of any pause and stays red: the *Notification Fatigue* pattern this
KB documents in `docs/17`, and a direct hit on the repo's own rule that **an unaccounted flag is an
unread check**.

**Full options, evidence and a marked recommendation are in the backlog's §2, as `D4`** —
`plans/20260904_2053-open-work-backlog.md`. In short: **(a)** leave it and accept daily red;
**(b)** raise `MAX_AGE_HOURS` to ~336 (14 days), turning it into a staleness nudge — *recommended*,
and its real cost is losing 48h sensitivity if the schedule ever returns; **(c)** `workflow_dispatch`
only, giving up the automatic signal; **(d)** commit the active mode and make the threshold
mode-dependent — correct in both modes, but two homes for one fact and the drift is silent.

A constraint worth knowing before reaching for (d): the active mode is *local machine state*
(`launchctl`), so **CI cannot observe it**. Mode-awareness requires committing the mode.

> **`D4` lives in §2, which no tier-emptiness check reads.** §3/§4/§5 being empty does not mean
> there is nothing to decide. This repo shipped exactly that defect once — a note parked outside
> every tier that stayed stale for weeks.

Decide, apply, and strike the row in the same PR.

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
of `scripts/com.luca.loop-news.plist` and starts the wrapper under `env -i` with exactly those, so
the two modes are identical **by construction, not by intent**. `com.luca.loop-news.plist` is
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
- **`notify()` is desktop-only**, and the off-machine backstop is weaker than it reads:
  `check-digest-freshness.sh` runs 09:00 UTC against `MAX_AGE_HOURS` 48 while the tracker fires
  04:00–05:00 UTC, so **a single lost day reads ~29h and pages nobody**. Measured, not assumed.
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
