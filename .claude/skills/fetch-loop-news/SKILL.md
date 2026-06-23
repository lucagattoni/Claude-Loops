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
3. Get the exact local time by running:
   ```bash
   date '+%Y-%m-%d %H:%M %Z'
   ```
   Record the date part as `today` and the full output as `run_time`.
   The `%Z` token captures the system timezone automatically — use whatever
   the computer reports. Use this value for all timestamps written to files —
   never estimate the time or override the timezone.

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

**Prefer RSS over HTML.** Before fetching the index page, check whether the site
exposes an RSS feed (common paths: `/feed`, `/rss`, `/rss.xml`, `/atom.xml`). If a
valid feed is found, switch to the `rss` strategy for this source and record the feed
URL in SOURCES.md for future runs.

**Use site search when available.** If the site has a search interface, prefer
fetching a search URL over scraping the full index — it returns targeted results and
reduces noise. Build the query from Tier 1+2 keywords:

```
<base-url>/search?q=loop+engineering+OR+agent+loop+OR+harness+engineering
```

Common search path patterns: `/search`, `/search?q=`, `/?s=`, `/?query=`.
If search returns no results or errors, fall back to the index page.

1. WebFetch the page URL from SOURCES.md (or the search URL constructed above).
2. Extract all article/post links with their titles and any visible snippet or date.
3. Score each against the keywords.
4. Collect matching items: title, URL, inferred date, one-sentence summary.
5. **Link expansion** — for every Tier 1 or Tier 2 match, WebFetch the article URL
   itself; read the full text and collect **all** embedded links into a candidate
   list; score and select the **3 most innovative** using the same criteria as the
   X source expansion (new concept, untracked domain, strong signal words);
   WebFetch those 3 and add findings to the results array.

---

### For `type: github` sources

1. WebFetch `<repo-url>/commits/main` (try `master` if `main` returns 404).
2. Scan the commit list for entries with a `committerdate` or commit message date
   newer than `last_run_date`. Collect their commit SHAs and messages.
3. For each new commit whose message or diff path mentions a keyword-matching file
   (e.g. new `.md` files in a `docs/` folder, a `PATTERNS.md`, `EXAMPLES.md`):
   - WebFetch the commit URL (`<repo-url>/commit/<sha>`) to read the diff.
   - Score changed files and commit message against the keyword tiers.
   - Collect matching items: commit title, `<repo-url>/commit/<sha>`, date, summary.
4. Also WebFetch `<repo-url>/releases` — if any release is newer than `last_run_date`,
   include it; describe what new patterns or examples it introduces.
5. **Link expansion** — for any Tier 1 or Tier 2 commit or release, collect external
   links from the commit message / release notes; score and WebFetch the 3 most
   innovative using the same criteria as other source types.

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
3. Insert a new section immediately after the initial `---` separator (so the
   newest run always appears at the top). The format (timestamp from `run_time` —
   timezone label comes from the system, e.g. IST, GMT, CET):

```markdown
## YYYY-MM-DD HH:MM <TZ> (run)

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

## Phase 4b — Doc coherence review

After all per-finding doc writes are done, reason about the overall state of the
knowledge base **as a whole**. This is not about individual findings — it is about
whether the docs still form a coherent, well-structured body of knowledge given
the evolution of loop engineering thinking.

**Ask these questions each run:**

1. **Grouping**: Does `LOOP_ENGINEERING.md` still organise topics logically? If
   new docs were added this run, do they belong in an existing section or do they
   warrant a new section header?

2. **Overlap and redundancy**: Do any two docs now cover the same concept from
   different angles without cross-referencing each other? Add a `See also:` line
   to each overlapping doc pointing to the other.

3. **Staleness**: Do any existing doc summaries in the index no longer reflect the
   doc's current content (because it was extended this run)? Update the summary
   in `LOOP_ENGINEERING.md`.

4. **Progression**: Does the ordering within each section still reflect the logical
   reading sequence — from foundational to advanced? Reorder rows within a section
   if a new doc belongs earlier.

5. **Fragmentation**: Is any concept now split across 3+ docs in a way that makes
   it hard to find? Consider whether two short docs should be merged, or whether
   one doc should become the canonical page with the others as thin cross-references.

**Apply the minimum change that resolves each issue found.** Restructuring the index
counts as a MAJOR release (see Phase 5). Adding cross-reference lines or updating
summaries counts as PATCH.

## Phase 5 — Release determination and auto-commit

After all Phase 4 writes are complete:

### 5a — Determine release tier

Count the outputs of this run:
- **M** = number of new `docs/*.md` files created
- **U** = number of existing `docs/*.md` files updated
- **N** = number of new findings added to the digest

Apply this decision table:

| Condition | Release tier |
|---|---|
| Any existing doc removed or renamed, or `LOOP_ENGINEERING.md` restructured | **MAJOR** |
| M ≥ 1 (at least one new doc file created) | **MINOR** |
| M = 0 and U ≥ 1 (existing docs updated, none new) | **PATCH** |
| M = 0 and U = 0 and N ≥ 1 (findings only, no doc changes) | **PATCH** |
| N = 0 and M = 0 and U = 0 (nothing changed) | **None** — skip commit |

### 5b — Cut a release if warranted

For **MINOR** or **PATCH** releases:
1. Read the most recent versioned section header in `CHANGELOG.md` (format `## [X.Y.Z]`) to determine the current version.
2. Increment it: MINOR bumps Y and resets Z to 0; PATCH bumps Z only.
3. In `CHANGELOG.md`, rename `## [Unreleased]` to `## [X.Y.Z] — <today's date> <TZ>` (the new version) and add a fresh `## [Unreleased]` section above it with empty `### Added` and `### Changed` subsections.

For **MAJOR** releases: leave `[Unreleased]` in place and note the major change there — major releases require a manual decision.

For **None**: skip all changelog changes and skip the commit entirely.

### 5c — Commit

Stage and commit:
```bash
git add LOOP_ENGINEERING_NEWS.md LOOP_ENGINEERING.md SOURCES.md CHANGELOG.md docs/ .claude/skills/fetch-loop-news/SKILL.md
git commit -m "feat: loop news run <run_time> — <N> findings, <M> new docs [<tier>]"
```
Where `<tier>` is the release tier (e.g. `minor`, `patch`, or `none`).
Omit `[none]` from the message when tier is None (but in that case the commit is skipped anyway).
