# Claude Loops

A living knowledge base and automated tracker covering **two disciplines, kept separate**:

| **Part I — Loop Engineering** | **Part II — Developing with Claude Code** |
|---|---|
| Designing a system that prompts an agent *for* you — it fires on a trigger, works, verifies, and stops. You are not at the keyboard. | You and Claude Code building software together, iteratively, with you in the loop. |
| General, tool-agnostic. | Claude Code specific, version-stamped. |

For **building software**, the honest default is Part II — *"most effective coding agent use is a
complex, highly iterative process"* ([Andrew Ng](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map-in-detail-using-coding-agents/),
2026-09-04, explicitly *not* autonomous long-horizon execution). Part I is where **recurring,
well-specified, verifiable** work belongs — triage, sweeps, dependency bumps, docs sync, digests —
and there the payoff compounds.

Not sure which you need? [**Choosing Your Mode**](https://lucagattoni.github.io/Claude-Loops/35-choosing-your-mode/)
is the router: three tests a task must pass before a loop is worth building.

## 📖 Read the documentation → **<https://lucagattoni.github.io/Claude-Loops/>**

The knowledge base is meant to be **read on the docs site** (a 3-column layout with
search, navigation, and light/dark themes) — not as raw Markdown here on GitHub. Every
link below points to the [published site](https://lucagattoni.github.io/Claude-Loops/);
the files in this repo are the *source* the site is built from.

---

## What's in this repo

| Source file | Read it on the site |
|---|---|
| `docs/*.md` | [The knowledge base](https://lucagattoni.github.io/Claude-Loops/) — one page per topic |
| `LOOP_ENGINEERING.md` | [Home / topic index](https://lucagattoni.github.io/Claude-Loops/) — both parts, one row per topic |
| `CHANGELOG.md` | [Changelog](https://lucagattoni.github.io/Claude-Loops/changelog/) |
| `SOURCES.md` | [Sources](https://lucagattoni.github.io/Claude-Loops/sources/) |
| `LOOP_ENGINEERING_NEWS.md` | [News digest](https://lucagattoni.github.io/Claude-Loops/news/) |
| `.claude/skills/fetch-loop-news/SKILL.md` | Search skill — finds news, writes the findings artifact (source only) |
| `.claude/skills/integrate-loop-news/SKILL.md` | KB skill — integrates + restructures + publishes (source only) |
| `scripts/run-loop-news.sh` | Shell wrapper — runs both skills as two sessions in one worktree (source only) |
| [`scripts/SCHEDULING.md`](scripts/SCHEDULING.md) | How to change the cron cadence, or enable/disable the daily run (macOS launchd) |
| `plans/` | Implementation plans for features in progress (source only) |

---

## Reading the knowledge base

**Read it on the site: <https://lucagattoni.github.io/Claude-Loops/>** — the 3-column
layout (nav · content · on-this-page TOC) is the intended reading experience, with search
and cross-links that don't work in raw GitHub Markdown.

| If you want to… | Start at |
|---|---|
| Work out which half you need | [Choosing Your Mode](https://lucagattoni.github.io/Claude-Loops/35-choosing-your-mode/) |
| Build software with Claude Code | [The Development Workflow](https://lucagattoni.github.io/Claude-Loops/36-development-workflow/) |
| Decide on one session or several | [Session Architecture](https://lucagattoni.github.io/Claude-Loops/37-session-architecture/) |
| Design an autonomous loop | [The Loop Contract](https://lucagattoni.github.io/Claude-Loops/27-loop-contract/) |
| Know when a loop is actually done | [Verification](https://lucagattoni.github.io/Claude-Loops/04-verification/) |

The knowledge base grows automatically: when the daily loop finds a new concept not yet
covered, it adds a page and a row to the [topic index](https://lucagattoni.github.io/Claude-Loops/).

---

## Daily news tracker

Every day a Claude loop:

1. Reads the [sources list](https://lucagattoni.github.io/Claude-Loops/sources/) and relevance keywords
2. Fetches new posts from X.com profiles (via Chrome), RSS feeds, and blog pages
3. Scores each post against the keyword list
4. Appends a new dated entry to the [news digest](https://lucagattoni.github.io/Claude-Loops/news/)
5. If a finding introduces a new concept, creates or updates the relevant topic page
   and adds a row to the [index](https://lucagattoni.github.io/Claude-Loops/)

### Run it manually

```bash
# Inside a Claude Code session — run the two halves in order:
/fetch-loop-news        # search → writes .loop-news/findings.json
/integrate-loop-news    # integrate + restructure + commit + push

# Headless, isolated end-to-end (from terminal) — recommended:
bash scripts/run-loop-news.sh
```

The wrapper runs both skills as two sessions inside one throwaway git worktree branched
off `origin/main`, so a run never disturbs your working checkout. Logs are written to
`logs/loop-news-YYYYMMDD.log` and the findings artifact is copied to
`logs/findings-YYYYMMDD.json` (both gitignored).

Per-stage model, effort, max-turns and budget default at the top of
`scripts/run-loop-news.sh`. Three ways to override them, in precedence order
(CLI flag > env file / exported env var > built-in default):

```bash
# 1. Standing local default — copy the template, edit it, done (auto-sourced every run):
cp scripts/run-loop-news.env.example scripts/run-loop-news.env
$EDITOR scripts/run-loop-news.env

# 2. Exported env var (e.g. in the launchd plist), same LOOP_SEARCH_*/LOOP_INTEGRATE_* names.

# 3. CLI flags, for a one-off run:
bash scripts/run-loop-news.sh --integrate-model opus --integrate-effort max
bash scripts/run-loop-news.sh --model opus --effort max   # shorthand: both stages
bash scripts/run-loop-news.sh --help                       # full flag list
```

`scripts/run-loop-news.env` is gitignored — only the `.example` template is tracked.

### Add or remove a source

Edit the `SOURCES.md` source file (rendered as [Sources](https://lucagattoni.github.io/Claude-Loops/sources/)
on the site) — the loop reads it fresh on every run.

```markdown
| New Actor | rss | https://theirblog.com/feed | Why they're relevant |
```

**Seven** source types are in use (row counts as of 2026-09-06):

| Type | What it is | Rows |
|---|---|---|
| `github` | One repo — commits and releases since the last run | 23 |
| `rss` | RSS/Atom feed | 14 |
| `x` | An X.com profile timeline | 7 |
| `html` | A blog or index page, scraped directly | 5 |
| `github-search` | A GitHub search API query | 3 |
| `x-search` | An X.com search query | 1 |
| `linkedin` | A LinkedIn content search | 1 |

**Prefer `html` over `rss` when a publication has no discoverable feed.** A 404 feed and a quiet
week produce the same empty result, and this repo has lost two months of a high-value source to
exactly that twice — see the warning at the top of
[`SOURCES.md`](https://lucagattoni.github.io/Claude-Loops/sources/).

### Change the schedule, or pause it

The daily run is a macOS launchd LaunchAgent (`com.luca.loop-news`), not cron. To change
how often it fires, or to enable/disable it, see **[scripts/SCHEDULING.md](scripts/SCHEDULING.md)**
for the exact `launchctl` commands and `StartCalendarInterval`/`StartInterval` syntax.

---

## Contributing

1. Add a new source by editing `SOURCES.md` — no code change needed (see [Sources](https://lucagattoni.github.io/Claude-Loops/sources/))
2. For knowledge base edits, open a PR targeting `main`
3. For new plans, add a file to the `plans/` directory on a feature branch

---

## License

[MIT](LICENSE)
