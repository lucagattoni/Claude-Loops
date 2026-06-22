---
name: fetch-loop-news
description: Daily fetch of loop engineering news from tracked sources and general search; updates LOOP_ENGINEERING_NEWS.md and docs/ when new concepts are found
---

Fetch today's loop engineering news and update the tracking docs.

## Phase 1 — Load context

1. Read `SOURCES.md`:
   - Extract the sources table (Actor, Type, Handle/URL, Notes)
   - Extract the relevance keywords list
2. Read `LOOP_ENGINEERING_NEWS.md`:
   - Find the most recent dated section header (format: `## YYYY-MM-DD`)
   - Record that date as `last_run_date`
3. Get the exact Irish time by running:
   ```bash
   TZ='Europe/Dublin' date '+%Y-%m-%d %H:%M %Z'
   ```
   Record the date part as `today` and the full output as `run_time`.
   Use this value for all timestamps written to files — never estimate the time.

## Phase 2 — Per-source search

Launch one subagent per source in parallel. Each subagent receives the source row,
the full keywords list, and `last_run_date`.

**The goal is to find relevant content from that source — not just recent content.**
Search *within* the source for the keywords. Do not limit to posts newer than
`last_run_date` for the search itself; use `last_run_date` only to de-prioritise
already-seen items during deduplication in Phase 3.

---

### For `type: x` sources

1. Use Chrome to navigate to:
   `https://x.com/search?q=from%3A<handle>+<url-encoded-keyword-query>&f=live`

   Build the keyword query as an OR of the most specific keywords:
   `"loop engineering" OR "Claude Code" OR "agent loop" OR agentic OR subagent OR MCP OR worktree`

2. Read the search results (latest posts matching those keywords from that account).
3. For each result collect: post text (first line), URL, date, one-sentence summary.
4. Also navigate to the profile page `https://x.com/<handle>` and scan the first
   visible page of posts for anything posted after `last_run_date` that matches
   ≥ 1 keyword (catches posts that don't use exact keyword phrasing).
5. **Thread and link expansion** — for every post that scores Tier 1 or Tier 2:
   - Navigate to the post's thread URL (`x.com/<handle>/status/<id>`)
   - Read all visible replies and quote-tweets; note any that add new concepts,
     data points, or counter-arguments relevant to loop engineering
   - Collect **every** external link found in the post and its thread (not x.com
     links) into a candidate list; for each candidate record: URL, anchor
     text / surrounding context, and which reply it appeared in
   - Score the full candidate list and select the **3 most innovative** links —
     prioritise links that:
       1. Introduce a concept, technique, or data point not yet in `docs/`
       2. Come from a domain not already tracked in `SOURCES.md`
       3. Carry strong signal words (research paper, benchmark, new framework,
          case study, real cost/time numbers)
     Discard links that duplicate known sources, are generic landing pages, or
     are promotional without substantive content
   - WebFetch those 3 selected URLs; summarise each and add to the results array
     with `"source": "via @<handle> thread"` and the actual URL of the linked page

---

### For `type: rss` sources

1. WebFetch the feed URL from SOURCES.md.
2. Parse all `<item>` or `<entry>` elements.
3. Score each against the keywords (title + description).
4. Collect matching items: title, link, pubDate, one-sentence description.
5. **Link expansion** — for every Tier 1 or Tier 2 match, WebFetch the article URL
   itself (not just the RSS summary); read the full text and collect **all** embedded
   links into a candidate list with their anchor text and surrounding sentence;
   score the candidates and select the **3 most innovative** — prioritise links
   that introduce new concepts, cite research, or reference real-world deployments
   not already in `docs/`; WebFetch those 3 and add findings to the results array.

---

### For `type: html` sources

1. WebFetch the page URL from SOURCES.md.
2. Extract all article/post links with their titles and any visible snippet or date.
3. Score each against the keywords.
4. Collect matching items: title, URL, inferred date, one-sentence summary.
5. **Link expansion** — for every Tier 1 or Tier 2 match, WebFetch the article URL
   itself; read the full text and collect **all** embedded links into a candidate
   list; score and select the **3 most innovative** using the same criteria as the
   X source expansion (new concept, untracked domain, strong signal words);
   WebFetch those 3 and add findings to the results array.

---

Score each item against the keyword tiers from `SOURCES.md`:
- **Tier 1 or 2 match** → always include
- **Tier 3 or 4 match only** → include only if the post substantively discusses loop
  engineering practice, not just a passing mention of a tool name

Each subagent returns a JSON array (empty if no matches):
```json
[
  {
    "source": "Actor name or @handle",
    "title": "Post or article title / first line",
    "url": "https://...",
    "date": "YYYY-MM-DD",
    "tier": 1,
    "summary": "One sentence on why this is relevant to loop engineering."
  }
]
```

The `tier` field is the highest tier matched (1 = most specific). Include it so the
digest can sort findings by relevance.

## Phase 3 — General search (bonus pass)

After all per-source subagents return, run two additional searches:

**X.com keyword search:**
Use Chrome to navigate to:
`https://x.com/search?q=%22loop+engineering%22+OR+%22agent+loop%22+OR+%22Claude+Code%22&src=typed_query&f=live`

Read the first page of live results. Score each post against the keywords.
Collect any relevant items not already found in Phase 2.

For any Tier 1 or Tier 2 post found here, apply the same thread-and-link
expansion as Phase 2 X sources: read the full thread, collect all external
links as candidates, score them, and WebFetch the 3 most innovative.

**Web search:**
Use WebSearch (or WebFetch a search engine) for:
`"loop engineering" OR "agent loop" Claude Code agentic 2026`

Collect any new articles, blog posts, or resources from the last 7 days.

**Dynamic source expansion:**
If Phase 2 or Phase 3 surfaces a person or company that:
- Published 2+ relevant pieces on the topic, AND
- Has meaningful audience engagement

…add them as a new row to `SOURCES.md` under the appropriate type.

## Phase 4 — Write digest

1. Merge all results from Phases 2 and 3 into a single list.
2. Deduplicate: remove any item whose `url` already appears in `LOOP_ENGINEERING_NEWS.md`.
3. Append a new section using this format (timestamp in Irish Standard Time):

```markdown
## YYYY-MM-DD HH:MM IST (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @handle | "Title" | [link](url) | Summary sentence |

### No new content
- Actor — reason (e.g. no keyword matches found in their posts)

### Docs updated this run
- (list any docs/ changes made below)

### Sources to consider adding to SOURCES.md
- (list any newly surfaced actors worth tracking)

---
```

If zero new findings after deduplication, write the section with an empty findings
table and list all sources under "No new content". Never skip the section.

4. For each item in "New findings", assess whether it introduces a **new concept,
   technique, or tool** not yet present in any `docs/*.md` file:
   - Read the relevant `docs/*.md` files to check coverage
   - New concept → create `docs/<topic>.md` and add a row to `LOOP_ENGINEERING.md`:
     `| N | [Topic](docs/<topic>.md) | One-sentence summary |`
   - Updates existing concept → edit only that `docs/<topic>.md`
   - Already fully covered → no doc changes needed

5. Update `CHANGELOG.md` under `[Unreleased]` for any doc additions or changes.

6. Close any Chrome tabs opened during this run.
