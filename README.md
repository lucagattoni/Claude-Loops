# Claude Loops

A living knowledge base and automated tracker for **loop engineering** — the practice
of designing systems that prompt Claude for you, rather than typing prompts yourself.

---

## What's in this repo

| Path | What it is |
|---|---|
| [`LOOP_ENGINEERING.md`](LOOP_ENGINEERING.md) | Slim index of all loop engineering topics |
| [`docs/`](docs/) | One in-depth doc per topic, linked from the index |
| [`CHANGELOG.md`](CHANGELOG.md) | Versioned history of changes to the knowledge base |
| [`SOURCES.md`](SOURCES.md) | Dynamic list of news sources monitored daily |
| [`LOOP_ENGINEERING_NEWS.md`](LOOP_ENGINEERING_NEWS.md) | Append-only daily digest of new findings |
| [`.claude/skills/fetch-loop-news/`](.claude/skills/fetch-loop-news/SKILL.md) | Claude skill that runs the daily fetch |
| [`scripts/run-loop-news.sh`](scripts/run-loop-news.sh) | Shell wrapper to invoke the skill headlessly |
| [`plans/`](plans/) | Implementation plans for features in progress |

---

## Reading the knowledge base

Start with [`LOOP_ENGINEERING.md`](LOOP_ENGINEERING.md) — it's a table of 18 topics,
each with a one-line summary and a link to the full `docs/<topic>.md` file. Read the
index to navigate; open a doc when you need depth.

The knowledge base grows automatically: when the daily loop finds a new concept not
yet covered, it creates a new `docs/<topic>.md` and adds a row to the index.

---

## Daily news tracker

Every day at **09:00 IST (08:00 UTC)** a Claude loop:

1. Reads [`SOURCES.md`](SOURCES.md) to get the current source list and relevance keywords
2. Fetches new posts from X.com profiles (via Chrome), RSS feeds, and blog pages
3. Scores each post against the keyword list
4. Appends a new dated entry to [`LOOP_ENGINEERING_NEWS.md`](LOOP_ENGINEERING_NEWS.md)
5. If a finding introduces a new concept, creates or updates the relevant `docs/` file
   and adds a row to the [`LOOP_ENGINEERING.md`](LOOP_ENGINEERING.md) index

### Run it manually

```bash
# Inside a Claude Code session
/fetch-loop-news

# Headless (from terminal)
bash scripts/run-loop-news.sh
```

Logs are written to `logs/loop-news-YYYYMMDD.log` (gitignored).

### Add or remove a source

Edit [`SOURCES.md`](SOURCES.md) — the loop reads it fresh on every run.

```markdown
| New Actor | rss | https://theirblog.com/feed | Why they're relevant |
```

Supported types: `x` (X.com profile), `rss` (RSS/Atom feed), `html` (blog index page).

---

## Workflow rules

- `main` is the stable branch — never commit directly to it
- Every new feature or plan gets its own branch and a PR
- All timestamps use Irish Standard Time (IST = UTC+1 in summer)

---

## Contributing

1. Add a new source to [`SOURCES.md`](SOURCES.md) — no code change needed
2. For knowledge base edits, open a PR targeting `main`
3. For new plans, add a file to [`plans/`](plans/) on a feature branch
