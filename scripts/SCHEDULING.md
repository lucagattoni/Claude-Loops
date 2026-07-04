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

## Enable / disable

Two different things, easy to conflate:

- **`disable`** — persists across reboots; the job cannot run at all (even a manual
  `kickstart`) until re-`enable`d. Use this for "stop running it for a while."
- **`bootout`** — unloads the job from launchd for the current session; a `bootstrap`
  (or a reboot/login, since `RunAtLoad` is `false` here so not even that) is needed to
  bring it back. Use this when you're about to replace the plist file anyway.

```bash
# Pause indefinitely (survives reboot; explicit re-enable required)
launchctl disable gui/$(id -u)/com.luca.loop-news

# Resume
launchctl enable gui/$(id -u)/com.luca.loop-news
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.luca.loop-news.plist

# Unload only (schedule stays in the plist; reload with bootstrap when ready)
launchctl bootout gui/$(id -u)/com.luca.loop-news

# Remove entirely (also delete the live plist file if you don't want it back)
launchctl bootout gui/$(id -u)/com.luca.loop-news
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
