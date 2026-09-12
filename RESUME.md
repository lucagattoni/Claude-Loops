# RESUME — handover 20260912 · **the tracker is PAUSED, and that is the first thing to deal with**

**Repo state:** `main` at `2628171`, clean, no open branches or worktrees. All gates green.
**Backlog:** `plans/20260904_2053-open-work-backlog.md` §3, §4 and §5 are **all empty**.
**Last session:** shipped `A13` (`v3.6.0`) and `A14` (`v3.6.2`), backfilled `v3.6.1`.

---

## 1. The tracker is now ON DEMAND — this replaces the old "live issue"

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

### OPEN DECISION — the freshness watchdog now measures the wrong thing

`.github/workflows/tracker-watchdog.yml` fails when the newest digest is older than 48h. Under a
schedule that was the only off-machine health signal. **Under on-demand it measures how recently
you chose to run a sweep**, so it goes red within two days of any pause and stays red — the
*Notification Fatigue* pattern this KB documents in `docs/17`. Options, none yet taken:

| Option | Effect |
|---|---|
| Leave it | Red CI daily; the signal is ignored, which is the failure mode | 
| Raise `MAX_AGE_HOURS` (e.g. 336 = 14 days) | Becomes a "the KB is going stale" nudge, not a health check |
| Trigger on `workflow_dispatch` only | Silent until asked; no automatic staleness signal at all |

**Not changed unilaterally** — it is CI config on a public repo, and **if the schedule is ever
restored the watchdog becomes correct again with no edit**, which argues for leaving it rather than
deleting it.

## 2. Pending: `v3.6.3` is cut but untagged

The 09-09 pipeline run cut `## [3.6.3] — 20260909 05:02` in `CHANGELOG.md`. Per decision **D2** the
pipeline deliberately never tags or releases (`gh` is not in its allowlist), so every pipeline-cut
version needs a manual backfill. Tags and releases are otherwise in step at **73/73**.

```bash
# tag the PIPELINE COMMIT that carries the entry — the precedent for every pipeline-cut tag
git tag -a v3.6.3 2628171 -m "..."   &&  git push origin v3.6.3
gh release create v3.6.3 --latest --notes-file <the [3.6.3] section>
```

Check with `git tag | wc -l` against `gh release list | wc -l` rather than trusting this number.

---

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
