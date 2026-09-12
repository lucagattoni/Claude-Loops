# Running the tracker (macOS) — **two modes, one environment**

The tracker supports two ways of being run, and they are meant to stay interchangeable:

| Mode | How it fires | Status |
|---|---|---|
| **On demand** | you run `scripts/run-loop-news-now.sh` | **active since 20260912 — the default** |
| **Scheduled** | the `com.luca.loop-news` LaunchAgent, 05:00 local | available, currently disabled |

**Neither is a one-way door.** Switching is two commands in either direction (below), and both
modes run the same wrapper in the same environment *by construction* — the launcher reads `PATH`,
`HOME`, the working directory and the log paths out of `scripts/com.luca.loop-news.plist` at run
time and starts the wrapper under `env -i` with exactly those. So "it worked when I ran it by hand"
stays evidence about the scheduled path too, and vice versa.

```bash
bash scripts/run-loop-news-now.sh            # run a sweep now
bash scripts/run-loop-news-now.sh --status   # which mode is live, and when it last published
bash scripts/run-loop-news-now.sh --check    # print the environment it would use, run nothing
```

**Which mode am I in?** `--status` asks launchd and the repo directly rather than inferring it. Use
it before concluding anything about a stale digest — on 20260912 a paused tracker read as a broken
one for three days because nothing reported the mode.

A sweep takes roughly 45–60 minutes and costs real money (Stage A and Stage B each carry their own
`--max-budget-usd`), so on demand it is a deliberate act, not a background one.

## Why not just run the wrapper directly

An interactive shell has sourced your profile, so its `PATH` is a **superset** of the recorded one.
`bash scripts/run-loop-news.sh` from a terminal can therefore succeed on a machine where the
scheduled path would fail — and you would not find out until you switched modes. This repo already
lost eight weeks to a binary-resolution bug of exactly that shape. Use the launcher.

`scripts/com.luca.loop-news.plist` is the **single definition of that environment**, committed and
read by both modes. It is not only a schedule. **Do not delete it** — deleting it breaks on-demand
runs as well as scheduled ones.

### Output and exit codes

The run is `tee`d: you watch it live *and* the same bytes land in `logs/launchd.log`, exactly as
launchd would have captured them. The wrapper writes its own structured day log at
`logs/loop-news-YYYYMMDD.log` in both modes. Both files are gitignored and local to this machine.

The launcher passes the wrapper's exit code through unchanged. `0` is a verified publish;
**`6`** = reported success but published nothing; **`7`** = failed and could not tell whether it had
already published, so it refused to retry. Full table below.

> **Verify the artifact, not the message.** Confirm `origin/main` gained a `feat: loop news run `
> commit before believing any summary.

---

## Switching modes

**To scheduled.** `enable` must come *before* `bootstrap` — a `bootstrap` alone inherits the
disabled flag and the job silently stays dead, which is what happened on 20260912:

```bash
cp scripts/com.luca.loop-news.plist ~/Library/LaunchAgents/   # if the live copy is missing
launchctl enable    gui/$(id -u)/com.luca.loop-news
launchctl bootout   gui/$(id -u)/com.luca.loop-news 2>/dev/null   # ignore "no such process"
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.luca.loop-news.plist
bash scripts/run-loop-news-now.sh --status                     # must report SCHEDULED
```

**To on demand.** `disable` alone is not enough — it prevents future loads but does not unload a
running job, so `bootout` is the one that actually stops it:

```bash
launchctl disable gui/$(id -u)/com.luca.loop-news
launchctl bootout gui/$(id -u)/com.luca.loop-news 2>/dev/null
bash scripts/run-loop-news-now.sh --status                     # must report ON DEMAND
```

Verify with `--status` in both directions rather than trusting the commands' silence.

### The freshness watchdog is mode-dependent — this is the one thing switching does not fix

`.github/workflows/tracker-watchdog.yml` runs `scripts/check-digest-freshness.sh` daily and fails
when the newest digest entry is older than `MAX_AGE_HOURS` (48).

- **Under SCHEDULED that is a real health check**: a run was due, so a stale digest means one
  silently failed. It is the only off-machine signal this pipeline has.
- **Under ON DEMAND it measures something else** — how recently *you chose* to run a sweep — so it
  goes red within two days of any pause and stays red. Left alone that is a standing false alarm,
  the *Notification Fatigue* pattern this KB documents in `docs/17`.

It is recorded here rather than quietly changed; the open decision is in `RESUME.md`. **If you
switch back to scheduled, the watchdog becomes correct again with no edit** — which is a reason to
leave it alone rather than delete it.

---

## launchd reference

Everything below is the detail behind the switch commands above. Not needed for a normal on-demand
run.

---

## Check current status

```bash
launchctl list | grep loop-news                              # quick: PID / last exit code / label
grep -E 'Using claude binary|VERSION DRIFT' logs/loop-news-*.log   # which CLI version actually ran
launchctl print gui/$(id -u)/com.luca.loop-news               # full status: schedule, paths, state
tail -f /Users/luca/Code/repos/github_lucagattoni/Claude-Loops/logs/launchd.log
```

`launchctl list`'s middle column is the **last exit code** (`-` = not running, `0` =
last run succeeded, nonzero = last run failed).

**What a nonzero code means.** The wrapper distinguishes its failures, so the number tells you
whether to re-run, wait, or go and look at the repository:

| Code | Meaning | What to do |
|---|---|---|
| `0` | Published, and the commit was verified on `origin/main` | Nothing |
| `1` | All attempts failed, or a deterministic stop (session limit, budget), or it failed *after* publishing | Read the day log; re-run when the cause has cleared |
| `3` | No usable `claude` binary at preflight | Fix `CLAUDE_BIN` / `PATH`; this never resolves on its own |
| `4` | A slash command did not resolve — the skill is missing from the checked-out tree | Check `.claude/skills/` on `origin/main` |
| `5` | `Credit balance is too low` — an API key is shadowing the subscription | Unset `ANTHROPIC_API_KEY`, or top up |
| `6` | **Reported success but published nothing.** A guard inside the session aborted; `claude -p` still exited 0 | Look for `FATAL` in the day log. Stage A's artifact is preserved — re-run resumes cheaply |
| `7` | **Failed, and it could not tell whether it had already published.** It refused to retry rather than risk committing the digest twice | Check `origin/main` by hand before re-running. The artifact and any checkpoint branch are preserved |

`6` and `7` are the two that need a human to look at the repository rather than just re-run: both
mean the run stopped precisely because it would otherwise have reported something it had not
verified. Neither pages anyone off-machine — `check-digest-freshness.sh` only fires after 48h, and
a single missed day is under that threshold.

---

## Set the periodicity

Edit `StartCalendarInterval` in `scripts/com.luca.loop-news.plist`. Each key is
optional — an **omitted key matches every value** of that field, which is how "daily"
vs. "only on Mondays" is expressed:

| Key | Meaning | Omit it to mean |
|---|---|---|
| `Hour` | 0–23 | every hour |
| `Minute` | 0–59 | every minute |
| `Day` | 1–31 (day of month) | every day |
| `Weekday` | 0–7 (0 and 7 both = Sunday) | every day of the week |
| `Month` | 1–12 | every month |

```xml
<!-- Daily at 05:00 local (today's config) -->
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key><integer>5</integer>
    <key>Minute</key><integer>0</integer>
</dict>

<!-- Weekdays only, 08:30 local -->
<key>StartCalendarInterval</key>
<array>
    <dict><key>Weekday</key><integer>1</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>2</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>3</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>4</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>5</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
</array>

<!-- Twice a day: 05:00 and 17:00 -->
<key>StartCalendarInterval</key>
<array>
    <dict><key>Hour</key><integer>5</integer><key>Minute</key><integer>0</integer></dict>
    <dict><key>Hour</key><integer>17</integer><key>Minute</key><integer>0</integer></dict>
</array>
```

**A fixed cadence instead of a wall-clock time** ("every N seconds," not "at HH:MM"):
use `StartInterval` (integer seconds) instead of `StartCalendarInterval` — the two are
mutually exclusive, so remove one when adding the other.

```xml
<!-- Every 6 hours, regardless of clock time -->
<key>StartInterval</key>
<integer>21600</integer>
```

**Apply the change:**

```bash
cp scripts/com.luca.loop-news.plist ~/Library/LaunchAgents/com.luca.loop-news.plist
launchctl bootout gui/$(id -u)/com.luca.loop-news 2>/dev/null   # unload the old schedule (ignore "no such process")
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.luca.loop-news.plist
git add scripts/com.luca.loop-news.plist
git commit -m "chore(scheduling): change tracker cadence to ..."
```

---

## Stop it from firing again (read this before running just `disable`)

> **`disable` alone is not enough if the job is currently loaded.** "Disabled" and
> "loaded" are two independent states in launchd, and `disable` only changes the
> first one: it writes a persistent flag to launchd's override database
> (`launchctl print-disabled gui/$(id -u)` will correctly show `=> disabled`
> immediately). It does **not** unload the job. If the job was already bootstrapped —
> which it is, any time `launchctl list | grep loop-news` shows a line — its
> *already-armed* next `StartCalendarInterval` trigger can still fire once despite the
> disabled flag being set correctly. This is not hypothetical: it happened on this
> machine — `disable` was run, `print-disabled` confirmed `=> disabled`, and the job
> still fired at its next 05:00 trigger. **To reliably stop the next run, you must also
> `bootout` it** — `disable` by itself is not sufficient.

**To stop it right now, run both commands together:**

```bash
launchctl disable gui/$(id -u)/com.luca.loop-news   # persists the "don't run" flag across reboots
launchctl bootout  gui/$(id -u)/com.luca.loop-news   # unloads it NOW so the next trigger can't fire
```

Verify it actually stopped:

```bash
launchctl list | grep loop-news              # no output = fully unloaded, confirmed stopped
launchctl print-disabled gui/$(id -u) | grep loop-news   # should show "=> disabled"
```

**To reactivate it later, run both commands together** (order matters — `enable`
before `bootstrap`, otherwise the freshly-loaded job inherits the disabled flag and
silently never fires):

```bash
launchctl enable    gui/$(id -u)/com.luca.loop-news
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.luca.loop-news.plist
```

Verify it's back:

```bash
launchctl print gui/$(id -u)/com.luca.loop-news | grep -A4 "event triggers"
```

### What each command actually does (for reference)

| Command | Effect | Survives reboot? | Stops an already-loaded job's next fire? |
|---|---|---|---|
| `disable` | Sets a persistent "don't run" flag | Yes | **Not reliably** — see warning above |
| `enable` | Clears that flag | Yes | n/a (this is the resume half) |
| `bootout` | Unloads the job from launchd immediately | No — a login/reboot won't reload it either, since `RunAtLoad` is `false` | Yes — this is the one that actually works |
| `bootstrap` | Loads the job (plist → launchd) | n/a | n/a (this is the resume half) |

**Remove entirely** (also delete the live plist file if you don't want it to come back):

```bash
launchctl disable gui/$(id -u)/com.luca.loop-news
launchctl bootout  gui/$(id -u)/com.luca.loop-news
rm ~/Library/LaunchAgents/com.luca.loop-news.plist
```

---

## Trigger a run right now (ignoring the schedule)

```bash
launchctl kickstart gui/$(id -u)/com.luca.loop-news
# or just run the script directly, bypassing launchd entirely:
bash scripts/run-loop-news.sh
```

---

## Why launchd, not `CronCreate` / a plain crontab

- **Survives reboots and doesn't need the terminal open** — a plain `crontab` entry
  works too, but launchd also restarts on crash and integrates with macOS login
  sessions.
- **Needs local Chrome automation** — the search stage uses `--chrome`
  (`mcp__claude-in-chrome__*`), which requires the logged-in GUI session; a `CronCreate`
  routine or a headless CI runner can't drive the local browser.
- See [docs/09 — Headless Mode](../docs/09-headless-mode.md) for the general
  LaunchAgent-vs-Routines tradeoff this repo's setup follows.
