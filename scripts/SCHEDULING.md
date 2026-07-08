# Scheduling the daily tracker (macOS)

The tracker runs via a **macOS launchd LaunchAgent** (not cron, not `CronCreate`) —
`com.luca.loop-news`, which invokes `scripts/run-loop-news.sh`.

Two copies of the same file exist and must be kept in sync manually:

| Copy | Role |
|---|---|
| `scripts/com.luca.loop-news.plist` (this repo, tracked) | Source of truth / history — edit **this one** first |
| `~/Library/LaunchAgents/com.luca.loop-news.plist` | The live copy launchd actually reads |

**Workflow for any change:** edit the tracked copy → `cp` it into `~/Library/LaunchAgents/`
→ reload with `launchctl` (below) → commit the tracked copy. Editing only the live copy
means the next person (or your future self) reads stale history in git.

launchd's `<uid>` in the commands below is your user id — get it once with `id -u`
(`501` on this machine); the domain target for a per-user GUI LaunchAgent is always
`gui/<uid>/<label>`.

---

## Check current status

```bash
launchctl list | grep loop-news                              # quick: PID / last exit code / label
launchctl print gui/$(id -u)/com.luca.loop-news               # full status: schedule, paths, state
tail -f /Users/luca/Code/repos/github_lucagattoni/Claude-Loops/logs/launchd.log
```

`launchctl list`'s middle column is the **last exit code** (`-` = not running, `0` =
last run succeeded, nonzero = last run failed).

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
