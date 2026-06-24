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
3. Get the current UTC time by running:
   ```bash
   TZ=UTC date '+%Y-%m-%d %H:%M UTC'
   ```
   Record the date part as `today` and the full output as `run_time`.
   Always use UTC — never estimate the time or substitute a local timezone.

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

### For `type: x-search` sources

These are live keyword search URLs on X.com. Content is dynamically loaded — a single page read is not enough.

1. Use Chrome to navigate to the search URL from SOURCES.md.
2. **Scroll to load posts**: after the initial page load, scroll down at least 3 times (waiting briefly between scrolls) to load a minimum of 20 posts. Use the scroll action or JavaScript `window.scrollBy(0, 3000)` between reads.
3. Read all visible posts. For each collect: author handle, post text (first 2 lines), URL, date, one-sentence summary.
4. Score each post against the keyword tiers.
5. **Link expansion** — for every Tier 1 or Tier 2 post: apply the same thread-and-link expansion as `type: x` sources (navigate to thread URL, collect external links, WebFetch the 3 most innovative).

---

### For `type: linkedin` sources

LinkedIn search results are dynamically loaded. A single page read returns very few posts.

1. Use Chrome to navigate to the search URL from SOURCES.md.
2. **Scroll to load posts**: scroll down at least 3 times to load a minimum of 20 posts. Use JavaScript `window.scrollBy(0, 3000)` and wait 1–2 seconds between each scroll.
3. **Extract post text with JavaScript** — LinkedIn uses hashed class names; use this approach:
   ```javascript
   const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
   const feedPostNodes = [];
   let node;
   while (node = walker.nextNode()) {
     if (node.textContent.trim() === 'Feed post') feedPostNodes.push(node.parentElement);
   }
   const seen = new Set();
   const posts = [];
   feedPostNodes.forEach(el => {
     let container = el;
     for (let j = 0; j < 8; j++) {
       if (container.innerText?.length > 200) break;
       container = container.parentElement;
     }
     const text = container.innerText?.replace(/\n{3,}/g, '\n')?.trim()?.slice(0, 700);
     const key = text?.slice(0, 60);
     const pulseHref = container.querySelector('a[href*="/pulse/"]')?.href?.split('?')[0];
     if (text && !seen.has(key)) { seen.add(key); posts.push({ text, pulseHref }); }
   });
   JSON.stringify(posts);
   ```
4. Score each post against the keyword tiers (author headline + post text).
5. **Pulse article expansion** — for every Tier 1 or Tier 2 post that includes a `pulseHref`: WebFetch the article URL and summarise its content. Treat it like a full article find.

---

### For `type: github-search` sources

These are GitHub API search URLs that surface repositories matching keywords.
The API returns clean JSON — no browser needed, no JS rendering.

1. WebFetch the API URL from SOURCES.md.
   The response is JSON with an `items` array. For each item extract:
   `full_name`, `description`, `html_url`, `updated_at`, `stargazers_count`.
2. Score each repo against the keyword tiers (`full_name` + `description`).
3. For every Tier 1 or Tier 2 repo:
   - Check whether `updated_at > last_run_date`; flag as new/recently-active
   - WebFetch the raw README: `https://raw.githubusercontent.com/<full_name>/main/README.md`
     (try `master` if `main` 404s)
   - Summarise the README's key patterns, techniques, or data points against the KB
   - Check whether the repo is already tracked as a `github` source in SOURCES.md;
     if not and it has ≥2 relevant contributions, note it in "Sources to consider"
4. Collect matching items: repo name, URL (`html_url`), `updated_at`, summary.
5. **KB-gap targeting**: Before fetching, read `KB_GAPS.md` if it exists. Prefer
   repos that address documented gaps over repos duplicating well-covered topics.

**Low-yield signal:** If a github-search URL returns ≤1 Tier 1-2 result this run,
note it in "Sources to consider" with a suggested keyword refinement for the next
commit (e.g. `q=%22claude+loops%22+harness` may yield better results than
`q=%22claude+code%22+harness`).

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
   newest run always appears at the top). The format:

```markdown
## YYYY-MM-DD HH:MM UTC (run)

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

5. **Reading list curation** — after KB doc writes, evaluate new findings against
   `docs/32-reading-list.md`:

   a. Read `docs/32-reading-list.md` to understand the current entries and groups.

   b. For each new finding that is a **full article** (not an X post or a short thread):
      - Determine which reading list group it fits. Current groups:
        *Why Loops* / *Getting Started* / *Harness Design & Architecture* /
        *Goal Engineering & Stopping Conditions* / *Loops in Production* /
        *Reference Implementations* — or a **new group** if the topic isn't covered.
        Reference implementations (GitHub repos, sample codebases) belong in
        *Reference Implementations*, not in article groups.
      - Ask: does this article offer something the existing entries in that group do not?
        Strong signals for inclusion: quantified claims, authoritative source (official
        Anthropic engineering, creator of a major tool), unique technique not documented
        elsewhere in `docs/`, or a real-world case study with outcome data.
      - Weak signals (skip): restatement of concepts already well-covered, no original
        contribution, promotional without substantive content.

   c. **Add** the article if it clears the bar. Write the full entry format:
      ```
      ### [Title](url) — Author
      **Added:** YYYY-MM-DD · **Published:** Mon YYYY

      **Why here:** One or two sentences on what uniquely earns this article a place —
      what it offers that existing entries in this group do not.

      **Summary:** 3–5 sentences covering the article's key claims, data points,
      patterns, or techniques.
      ```

   d. **Remove or replace** — if adding an article would push a group past ~4 entries,
      remove the weakest existing entry in that group (the one with the least unique
      contribution relative to the rest of the KB). A group should never exceed 5
      entries; the list must stay slim.

   e. **New groups** — if a new finding covers a topic not represented by any existing
      group (e.g. "Fleet Engineering at Scale", "MCP Security"), add a new `##` group
      section with a one-sentence description before the first entry.

   f. Record any reading list changes in "Docs updated this run":
      `- docs/32-reading-list.md — added "<title>"; removed "<title>" (replaced)`

6. **KB gap tracking** — after all doc writes, update `KB_GAPS.md` to record which
   areas of the KB are currently thin or missing:

   a. Read `KB_GAPS.md` (create it if it doesn't exist).
   b. Review all existing `docs/*.md` for completeness. Topics that are thin:
      - Only 1-2 sentences on a concept that warrants deeper coverage
      - Cross-references that say "see X" but X is thin too
      - A failure pattern that lacks a concrete fix mechanism
   c. For each gap, write one line in `KB_GAPS.md`:
      ```
      - <topic>: <what's missing> — search keywords: <2-3 specific keyword phrases>
      ```
   d. Remove gaps that were filled by this run's doc writes.
   e. **These keywords are inputs to future github-search and web search queries.**
      The goal is iterative deepening: each run identifies what's still thin and
      provides targeted keywords so the next run searches more specifically.

   Example `KB_GAPS.md` entry:
   ```markdown
   # KB Gaps — topics needing deeper coverage
   
   - Fleet coordination protocols: STATE.md multi-loop coordination needs an
     example implementation — search keywords: "state machine" "agent coordination"
     "claude code" fleet
   - Verifier tuning techniques: criteria for distinguishing Verifier Theater from
     genuine passing — search keywords: "agent evaluator" "verification criteria"
     "LLM judge" calibration
   ```

7. Update `CHANGELOG.md` under `[Unreleased]` for any doc additions or changes.

8. Close any Chrome tabs opened during this run.

## Phase 4b — Devil's Advocate KB Review

After all per-finding doc writes are done, apply a **devil's advocate** lens to the
knowledge base — assume each change you just made could be wrong, incomplete, or
subtly inconsistent, and look for evidence of that.

This is not about individual findings — it is about whether the docs still form a
coherent, well-structured, internally-consistent body of knowledge.

### Devil's advocate questions

**Assume each doc update is wrong. Ask:**

1. **Internal contradictions** — Does anything written this run conflict with claims
   in other docs? (Example: a new token cost number that differs from a figure in
   docs/11; a new failure pattern that is the same as an existing one under a
   different name.) Fix the contradiction; prefer the more specific, cited source.

2. **Missing cross-references** — Is there any doc that now references a concept
   that lives in another doc, without a link? A reader who needs the concept should
   never have to search for it. Add the link.

3. **Unverifiable claims** — Did any edit introduce a pattern, metric, or technique
   attributed to a repo or post, but the source does not actually say this? Remove
   or flag it.

4. **Better placement** — Is there content now in doc X that belongs more naturally
   in doc Y (which already covers the parent topic)? A well-structured KB has one
   canonical place per concept.

5. **Redundancy** — Is any new section nearly identical to existing content in
   another doc? If yes, consolidate: keep the canonical version, replace the
   duplicate with a cross-reference.

**Structural coherence:**

6. **Grouping**: Does `LOOP_ENGINEERING.md` still organise topics logically? New
   docs added this run — do they belong in an existing section or warrant a new one?

7. **Staleness**: Do any existing doc summaries in the index no longer reflect the
   doc's current content (because it was extended this run)? Update the summary.

8. **Progression**: Does the ordering within each section still reflect the logical
   reading sequence — from foundational to advanced? Reorder if needed.

9. **Fragmentation**: Is any concept now split across 3+ docs without a canonical
   home? Consider merging thin docs or designating one as primary.

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
git add LOOP_ENGINEERING_NEWS.md LOOP_ENGINEERING.md SOURCES.md CHANGELOG.md KB_GAPS.md docs/ .claude/skills/fetch-loop-news/SKILL.md
git commit -m "feat: loop news run <run_time> — <N> findings, <M> new docs [<tier>]"
```
Where `<tier>` is the release tier (e.g. `minor`, `patch`, or `none`).
Omit `[none]` from the message when tier is None (but in that case the commit is skipped anyway).
