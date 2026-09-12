# RESUME — handover 20260912 · **the tracker is PAUSED, and that is the first thing to deal with**

**Repo state:** `main` at `2628171`, clean, no open branches or worktrees. All gates green.
**Backlog:** `plans/20260904_2053-open-work-backlog.md` §3, §4 and §5 are **all empty**.
**Last session:** shipped `A13` (`v3.6.0`) and `A14` (`v3.6.2`), backfilled `v3.6.1`.

---

## 1. LIVE ISSUE — the daily tracker has not run since 2026-09-09

`scripts/check-digest-freshness.sh` reports **STALE, 76h** (limit 48h). Newest digest entry is
`2026-09-09 04:00 UTC`. Runs on the 10th, 11th and 12th did not happen.

**Root cause, diagnosed 20260912 — it is NOT a crash.** The launchd job is explicitly disabled:

```
$ launchctl print-disabled gui/$(id -u) | grep loop-news
        "com.luca.loop-news" => disabled
```

Evidence it is a deliberate pause rather than a failure:
- No day logs exist for 09-10/11/12 — `logs/loop-news-*.log` stops at `20260909`. The wrapper
  never started, so nothing inside it failed.
- The machine has **not rebooted** (`up 7 days`, booted Sep 4), so nothing unloaded it implicitly.
- The `20260909` run finished normally: published, cleaned up its branch.
- `~/Library/LaunchAgents/com.luca.loop-news.plist` is present and byte-identical to the repo copy.

**The alarm worked.** `tracker-watchdog.yml` ran green on 09-10 (the 09-09 entry was still under
48h) and **failed on 2026-09-11T13:11Z**, exactly as designed. It will keep failing daily until the
tracker publishes again — so an unexplained red watchdog in that window is this, not a new fault.

### To resume it — `enable` BEFORE `bootstrap`, or it silently stays dead

`scripts/SCHEDULING.md` documents this trap: a `bootstrap` alone inherits the disabled flag.

```bash
launchctl enable    gui/$(id -u)/com.luca.loop-news
launchctl bootout   gui/$(id -u)/com.luca.loop-news 2>/dev/null   # ignore "no such process"
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.luca.loop-news.plist
launchctl print     gui/$(id -u)/com.luca.loop-news | grep -E 'state|disabled'   # verify
```

**Verify the artifact, not the command:** after the next 05:00 local trigger, check that
`logs/loop-news-$(date +%Y%m%d).log` exists and that `origin/main` gained a `feat: loop news run `
commit — `launchctl list` showing the label proves only that it is loaded.

### If the pause was deliberate and should continue
Leave it, but expect a red `tracker-watchdog` every day. There is no "paused" state the watchdog
understands — it only measures digest age.

---

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
