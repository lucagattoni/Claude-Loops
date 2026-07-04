# Claude Loops

A living knowledge base and automated tracker for **loop engineering** — the practice
of designing systems that prompt Claude for you, rather than typing prompts yourself.

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
| `LOOP_ENGINEERING.md` | [Home / topic index](https://lucagattoni.github.io/Claude-Loops/) |
| `CHANGELOG.md` | [Changelog](https://lucagattoni.github.io/Claude-Loops/changelog/) |
| `SOURCES.md` | [Sources](https://lucagattoni.github.io/Claude-Loops/sources/) |
| `LOOP_ENGINEERING_NEWS.md` | [News digest](https://lucagattoni.github.io/Claude-Loops/news/) |
| `.claude/skills/fetch-loop-news/SKILL.md` | Search skill — finds news, writes the findings artifact (source only) |
| `.claude/skills/integrate-loop-news/SKILL.md` | KB skill — integrates + restructures + publishes (source only) |
| `scripts/run-loop-news.sh` | Shell wrapper — runs both skills as two sessions in one worktree (source only) |
| `plans/` | Implementation plans for features in progress (source only) |

---

## Reading the knowledge base

**Read it on the site: <https://lucagattoni.github.io/Claude-Loops/>** — the 3-column
layout (nav · content · on-this-page TOC) is the intended reading experience, with search
and cross-links that don't work in raw GitHub Markdown. Start with
[The Paradigm Shift](https://lucagattoni.github.io/Claude-Loops/01-paradigm-shift/),
[The Loop Contract](https://lucagattoni.github.io/Claude-Loops/27-loop-contract/), and
[Verification](https://lucagattoni.github.io/Claude-Loops/04-verification/).

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
`scripts/run-loop-news.sh`. Override them via `LOOP_SEARCH_*` / `LOOP_INTEGRATE_*` env
vars, or with CLI flags on a one-off run (CLI > env > default):

```bash
bash scripts/run-loop-news.sh --integrate-model opus --integrate-effort max
bash scripts/run-loop-news.sh --model opus --effort max   # shorthand: both stages
bash scripts/run-loop-news.sh --help                       # full flag list
```

### Add or remove a source

Edit the `SOURCES.md` source file (rendered as [Sources](https://lucagattoni.github.io/Claude-Loops/sources/)
on the site) — the loop reads it fresh on every run.

```markdown
| New Actor | rss | https://theirblog.com/feed | Why they're relevant |
```

Supported types: `x` (X.com profile), `rss` (RSS/Atom feed), `html` (blog index page).

---

## Contributing

1. Add a new source by editing `SOURCES.md` — no code change needed (see [Sources](https://lucagattoni.github.io/Claude-Loops/sources/))
2. For knowledge base edits, open a PR targeting `main`
3. For new plans, add a file to the `plans/` directory on a feature branch
