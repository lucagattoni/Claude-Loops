---
name: fetch-loop-news
description: Daily fetch of loop engineering news from X.com and blogs; updates LOOP_ENGINEERING_NEWS.md and docs/ when new concepts are found
---

Fetch today's loop engineering news and update the tracking docs.

## Phase 1 — Load context

1. Read `SOURCES.md`:
   - Extract the sources table (Actor, Type, Handle/URL, Why)
   - Extract the relevance keywords list
2. Read `LOOP_ENGINEERING_NEWS.md`:
   - Find the most recent dated section header (format: `## YYYY-MM-DD`)
   - Record that date as `last_run_date` — skip any content older than this
3. Record today's date as `today` (ISO format: YYYY-MM-DD)

## Phase 2 — Fetch and score

Launch one subagent per source in parallel. Each subagent receives:
- The source row (Actor, Type, Handle/URL)
- The relevance keywords list
- `last_run_date` (to filter out old content)

**For `type: x` sources:**
1. Use the Chrome browser tools to navigate to `https://x.com/<handle>`
2. Extract all posts visible on the profile page
3. Filter to posts published after `last_run_date`
4. Score each post: relevant if title/text matches ≥ 1 keyword (case-insensitive)
5. For each relevant post collect: title/first line, URL, date, one-sentence summary

**For `type: rss` sources:**
1. Try fetching these paths in order until one returns valid XML:
   `<url>/feed`, `<url>/rss.xml`, `<url>/atom.xml`, `<url>/feed.xml`, `<url>/rss`
2. Parse `<item>` or `<entry>` elements
3. Filter to items with `<pubDate>` or `<updated>` after `last_run_date`
4. Score each item against keywords
5. Collect: title, link, date, description snippet (truncated to 1 sentence)

**For `type: html` sources:**
1. WebFetch the blog index URL
2. Extract all article links with their titles and any visible date/snippet
3. Filter to items that appear to be newer than `last_run_date` (use dates in text or proximity to top of page)
4. Score each item against keywords
5. Collect: title, URL, inferred date, one-sentence summary from snippet

Each subagent returns a JSON array (empty array if no matches):
```json
[
  {
    "source": "Actor name or @handle",
    "title": "Post or article title",
    "url": "https://...",
    "date": "YYYY-MM-DD",
    "summary": "One sentence describing why this is relevant."
  }
]
```

## Phase 3 — Write digest

1. Merge all subagent result arrays into a single list
2. Deduplicate: remove any item whose `url` already appears anywhere in `LOOP_ENGINEERING_NEWS.md`
3. Append a new section to `LOOP_ENGINEERING_NEWS.md` using this format:

```markdown
## YYYY-MM-DD (run: 08:00 UTC)

### New findings

| Source | Title | URL | Summary |
|---|---|---|---|
| @handle | "Title" | [link](url) | Summary sentence |

### No new content
- Actor — reason (e.g. no posts since last run, no keyword matches)

---
```

If there are zero new findings after deduplication, write the section with an empty
"New findings" table and list all sources under "No new content". Never skip the
section — the log must always record that the run happened.

4. For each item in "New findings", assess whether it describes a **new concept,
   technique, or tool** not yet present in any `docs/*.md` file:
   - Read the relevant `docs/*.md` files to check coverage
   - If the concept is new → create `docs/<topic>.md` with an in-depth write-up,
     then add a new row to the Topics table in `LOOP_ENGINEERING.md`:
     `| N | [Topic title](docs/<topic>.md) | One-sentence summary |`
   - If the concept updates an existing topic → edit only that `docs/<topic>.md`
   - If already fully covered → no doc changes needed

5. Close any Chrome tabs opened during this run.
