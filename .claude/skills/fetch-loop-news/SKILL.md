---
name: fetch-loop-news
description: Search step of the daily loop-engineering tracker — searches tracked sources + the general web for relevant news, scores candidates, and writes a findings artifact. Hands off to integrate-loop-news via .loop-news/findings.json. Does NOT edit the KB or commit.
---

Search today's loop engineering news and write a handoff artifact for `integrate-loop-news`.

This is the **search half** of the tracker (Phases 1–3 + handoff). It does no KB
reasoning, no doc edits, and no commit — it produces `.loop-news/findings.json`, which
`integrate-loop-news` consumes. In the daily run, `scripts/run-loop-news.sh` launches this
skill and then launches `integrate-loop-news` as a second session in the same worktree.

**Write only to `.loop-news/findings.json`.** Do not edit `SOURCES.md`, `docs/`, or any
tracked file — those changes wouldn't survive the wrapper's reset-between-attempts and are
`integrate-loop-news`'s job. Record every suggestion (new sources, feed URLs, keyword
refinements) inside the artifact instead.

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
already-seen items during deduplication (which `integrate-loop-news` does).

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
valid feed is found, switch to the `rss` strategy for this source *for this run* and
record the discovered feed URL in the artifact's `source_updates` so
`integrate-loop-news` can update SOURCES.md for future runs.

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
     if not and it has ≥2 relevant contributions, add it to the artifact's
     `sources_to_consider`
4. Collect matching items: repo name, URL (`html_url`), `updated_at`, summary.
5. **KB-gap targeting**: Before fetching, read `KB_GAPS.md` if it exists. Prefer
   repos that address documented gaps over repos duplicating well-covered topics.

**Low-yield signal:** If a github-search URL returns ≤1 Tier 1-2 result this run,
add it to the artifact's `source_updates` with a suggested keyword refinement for the
next commit (e.g. `q=%22claude+loops%22+harness` may yield better results than
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

…add them to the artifact's `sources_to_consider` (do **not** edit SOURCES.md here —
`integrate-loop-news` decides whether to add the row and commits it).

## Phase 4 — Hand off to `integrate-loop-news`

1. Merge all results from Phases 2 and 3 into a single **pre-dedup** list (do not dedup
   here — `integrate-loop-news` dedups against `LOOP_ENGINEERING_NEWS.md`).
2. Write `.loop-news/findings.json` (create the `.loop-news/` directory if needed — it is
   gitignored). Use exactly this schema:
   ```json
   {
     "schema": 1,
     "today": "YYYY-MM-DD",
     "run_time": "YYYY-MM-DD HH:MM UTC",
     "last_run_date": "YYYY-MM-DD",
     "findings": [
       { "source": "@handle", "title": "...", "url": "https://...",
         "date": "YYYY-MM-DD", "tier": 1, "summary": "..." }
     ],
     "sources_to_consider": [
       { "actor": "...", "type": "x", "handle_or_url": "...", "note": "why worth tracking" }
     ],
     "source_updates": [
       { "actor": "...", "change": "discovered feed URL <url>" }
     ]
   }
   ```
   - `today`, `run_time`, `last_run_date` come from Phase 1. `findings` is the merged
     pre-dedup list. `sources_to_consider` / `source_updates` may be empty arrays.
   - On a zero-finding day, still write the file with `"findings": []`.
3. Close any Chrome tabs opened during this run.
4. **Stop here — unconditionally, with no exceptions.** Do not edit the KB, do not
   commit, and do not invoke `/integrate-loop-news` yourself — not via the Skill tool,
   not by reading and following its SKILL.md inline, under any circumstance, including
   when you believe you were invoked interactively. You cannot reliably tell interactive
   invocation from a headless wrapper run, and the two-session split (context isolation,
   independent retry, independent model/effort) is deliberate — collapsing it back into
   one session defeats the reason it was split. If a human wants to complete the
   pipeline, **they** run `/integrate-loop-news` themselves, as their own explicit,
   separate step.
