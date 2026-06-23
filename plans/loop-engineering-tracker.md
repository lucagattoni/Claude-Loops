# Plan: Loop Engineering Daily News Tracker

## Goal

Run a Claude loop once a day at 8 AM UTC that searches X.com and key personal/company
blogs for new content on loop engineering, then appends a structured digest entry to
`LOOP_ENGINEERING_NEWS.md`.

The set of sources is **dynamic**: curated in `SOURCES.md` at the repo root and read
fresh on each run, so adding or removing a source takes effect at the next scheduled
run without touching the loop logic.

---

## Files to Create

| File | Role | Status |
|---|---|---|
| `SOURCES.md` | Dynamic list of sources and relevance signals | pending |
| `LOOP_ENGINEERING_NEWS.md` | Append-only digest log (one entry per run) | pending |
| `docs/<topic>.md` | In-depth topic docs (one per section) | **done** — 18 files created |
| `.claude/skills/fetch-loop-news/SKILL.md` | Reusable Claude skill the cron triggers | pending |
| `scripts/run-loop-news.sh` | Thin shell wrapper that invokes `claude -p /fetch-loop-news` | pending |

---

## Source List Design (`SOURCES.md`)

Each source is a record with three fields: `type`, `handle/url`, and `keywords` the
agent uses to decide whether a post is relevant.

**Initial sources (seed list):**

| Actor | Type | Handle / URL | Why |
|---|---|---|---|
| Anthropic | Company blog | https://www.anthropic.com/blog | Claude Code, loop engineering originator |
| Boris Cherny | X.com | @bcherny | Creator of Claude Code |
| Andrej Karpathy | X.com | @karpathy | Influential ML researcher |
| Andrew Ng | X.com | @AndrewYNg | Agentic AI education |
| OpenAI | Company blog | https://openai.com/blog | Competitor loop patterns, agents |
| Addy Osmani | Personal blog | https://addyosmani.com/blog | Co-defined loop engineering |
| Simon Willison | Personal blog | https://simonwillison.net | LLM tooling practitioner |
| Swyx / swyx.io | Blog + X | @swyx / https://www.swyx.io/blog | AI engineering community |
| The New Stack | Media | https://thenewstack.io | Published the Boris Cherny loop-engineering piece |

**Relevance keywords:** `loop engineering`, `agentic`, `Claude Code`, `subagent`,
`MCP`, `headless`, `worktree`, `verification loop`, `AI agent`, `computer use`.

The agent scores a post as relevant if it matches ≥ 1 keyword. It records the
headline, URL, source, date, and a one-sentence summary.

---

## Tracking Doc Design (`LOOP_ENGINEERING_NEWS.md`)

Append-only. Each daily run adds one section:

```markdown
## 2026-06-21 (run: 08:00 UTC)

### New findings

| Source | Title | URL | Summary |
|---|---|---|---|
| @bcherny | "Loops that self-heal" | https://x.com/... | ... |
| anthropic.com/blog | "Claude Code 2.0" | https://... | ... |

### No new content
- @AndrewYNg — last post predates previous run
- openai.com/blog — no loop-engineering keywords matched

---
```

If there are zero new findings the section records that explicitly (so the log is
always complete, never silently empty).

---

## Skill Design (`.claude/skills/fetch-loop-news/SKILL.md`)

The skill runs in three phases:

### Phase 1 — Load context
1. Read `SOURCES.md` to get the current source list and keywords.
2. Read the last entry in `LOOP_ENGINEERING_NEWS.md` to get the "last run" timestamp
   (used to skip content older than the previous run).

### Phase 2 — Fetch and score
For each source, in parallel subagents:
- **X.com profiles** (`type: x`): Use `claude --chrome` to navigate to
  `x.com/<handle>` (the session is already logged in), extract posts from the last 24h,
  and score against keywords.
- **Blogs with RSS** (`type: rss`): Use `WebFetch` on the RSS/Atom feed URL, parse
  `<item>` entries, score against keywords.
- **Blogs without RSS** (`type: html`): Use `WebFetch` on the blog index page, extract
  links + snippets, score against keywords.

Each subagent returns a JSON array of matching items:
```json
[
  {
    "source": "@bcherny",
    "title": "...",
    "url": "...",
    "date": "2026-06-21",
    "summary": "one sentence"
  }
]
```

### Phase 3 — Write digest
1. Deduplicate against URLs already present in `LOOP_ENGINEERING_NEWS.md`.
2. Append a new dated section to `LOOP_ENGINEERING_NEWS.md`.
3. For each finding, assess whether it introduces a **new concept, technique, or tool**
   not yet covered in `LOOP_ENGINEERING.md` or its linked docs.
4. If yes → create or update the relevant `docs/<topic>.md` file with an in-depth
   write-up, then add or update a link to it in `LOOP_ENGINEERING.md` (one line per
   topic, no inline expansion — keep the main doc slim).
5. If the finding updates an existing concept, edit only the specific `docs/<topic>.md`
   file; do not touch `LOOP_ENGINEERING.md` unless the link is missing.
6. If chrome was used, close the tab.

### `LOOP_ENGINEERING.md` content policy
- The main doc is a **map, not a manual** — a single table with one row per topic.
- Never expand content inline; all detail lives in `docs/<topic>.md`.
- New rows added by the loop must follow the existing table format:
  `| N | [Topic title](docs/<topic>.md) | One-sentence summary |`
- If an existing `docs/<topic>.md` is updated, do not touch `LOOP_ENGINEERING.md`
  unless the row itself is missing or the summary needs correcting.

**Skill invocation:**
```bash
claude --permission-mode auto \
       --chrome \
       --max-turns 40 \
       --allowedTools "Read,Edit,WebFetch,Bash(echo *),mcp__claude-in-chrome__*" \
       -p "/fetch-loop-news"
```

---

## Scheduling

Use `CronCreate` (the Claude Code scheduler) to run the shell wrapper daily at 08:00 UTC:

```
cron: 0 8 * * *
command: bash /Users/luca/Code/repos/github_lucagattoni/Claude-Loops/scripts/run-loop-news.sh
```

The wrapper script (`scripts/run-loop-news.sh`):
```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
claude --permission-mode auto \
       --chrome \
       --max-turns 40 \
       --allowedTools "Read,Edit,WebFetch,mcp__claude-in-chrome__*" \
       -p "/fetch-loop-news" \
  >> logs/loop-news-$(date +%Y%m%d).log 2>&1
```

---

## Implementation Steps

- [x] **Step 1** — Create `SOURCES.md` with the seed source list (table format).
- [x] **Step 2** — Create `LOOP_ENGINEERING_NEWS.md` with a header and placeholder
      first entry (so Phase 1 always has a "last run" timestamp to read).
- [x] **Step 3** — Refactor `LOOP_ENGINEERING.md` into a slim index: extracted all 18
      sections into `docs/<topic>.md`; main doc is now a linked topic table.
- [x] **Step 4** — Create `.claude/skills/fetch-loop-news/SKILL.md` with the
      three-phase procedure above (including the `LOOP_ENGINEERING.md` update logic).
- [x] **Step 5** — Create `scripts/run-loop-news.sh` (executable).
- [x] **Step 6** — Create `logs/` directory (gitignored) for run logs.
- [x] **Step 7** — Registered cron via `CronCreate`: `3 6 * * *` local (= 05:03 UTC),
      durable, fires daily. Note: auto-expires after 7 days; re-register or use
      system crontab for permanent scheduling.
- [x] **Step 8** — Dry-run completed Jun 21 2026 18:33 UTC: 5 findings captured,
      `docs/19-mcp-security.md` created, `docs/17-failure-patterns.md` updated, digest
      appended to `LOOP_ENGINEERING_NEWS.md`. Cycle verified end-to-end.
- [x] **Step 9** — Cron confirmed registered at 05:03 UTC daily. Skill strategy and
      keyword taxonomy subsequently corrected and merged (PR #2).

---

## Open Questions / Risks

| Risk | Mitigation |
|---|---|
| X.com login wall / CAPTCHA | Chrome connector uses existing session; if interrupted Claude pauses and asks the user to handle it manually |
| Rate limiting on blogs | Spread subagent fetches with small delays; RSS preferred over HTML scraping |
| No RSS feed available | Fall back to HTML index scrape; mark source `type: html` in `SOURCES.md` |
| Stale `SOURCES.md` | The file is committed — anyone on the team can PR new sources; the loop picks them up on next run |
| Log file growth | `logs/` is gitignored; rotate weekly with a simple cron `find logs/ -mtime +7 -delete` |
| Cost overrun | `--max-turns 40` caps the session; typical run expected to be ~10–15 turns and well under $0.10 |
