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

0. **Resume check — do this first.** If `.loop-news/findings.json` already exists and its
   `today` matches the current UTC date, a previous attempt of this run banked work. Load it and
   keep all five accumulated fields: `findings`, `sources_done`, `coverage`,
   `sources_to_consider` and `source_updates`. **Every source named in `sources_done` is already
   swept — do not sweep it again** (the one exception is the re-run of `partial` browser sources
   before Phase 3, which reads `coverage`). Carry everything banked straight through to the final
   artifact. A browser source in `sources_done` with no coverage record (an artifact written
   before `A17`) gets `{"status": "partial", "passes": [], "gap": "no coverage record in the
   resumed artifact"}` — which sends it through the re-run.
   If `complete` is already `true`, there is nothing to do: stop and report that the artifact is
   complete. (The wrapper normally skips this whole session in that case, so reaching here means
   you were invoked directly.)
   If the file is absent, unreadable, or stamped with a different date, ignore it and start clean —
   never guess at partial state.

1. Read `SOURCES.md`:
   - Extract the sources table (Actor, Type, Handle/URL, Notes)
   - Extract the relevance keywords list
2. Read `LOOP_ENGINEERING_NEWS.md`:
   - Find the most recent **run** header. A run header starts with the date immediately after
     `##`: `## YYYY-MM-DD HH:MM UTC (…)`. Match that shape and nothing else.
   - **Skip any section whose `##` does not begin with a digit.** The digest also carries
     hand-authored entries (e.g. `## Fact-check pass — YYYY-MM-DD HH:MM UTC (hand-authored, not a
     tracker run)`), which are *not* runs. Treating one as the last run silently narrows this
     sweep's window and skips everything published in between — a coverage hole nothing would
     report. Added 20260906 after such an entry was written directly above a real run header.
   - Record that run's date as `last_run_date`
3. Get the current UTC time by running:
   ```bash
   TZ=UTC date '+%Y-%m-%d %H:%M UTC'
   ```
   Record the date part as `today` and the full output as `run_time`.
   Always use UTC — never estimate the time or substitute a local timezone.

## Phase 2 — Per-source search

**A source's key is its `SOURCES.md` Actor cell and type, written `<Actor> [<type>]`** — e.g.
`Sabrina Ramonov [x]`, `Sabrina Ramonov [rss]`, `X search — loop engineering [x-search]`. Use the
key verbatim in `sources_done` and in coverage records; it is what lets the re-run and
`integrate-loop-news` match a record to its row (two rows can share an Actor).

Launch one subagent per source — **skipping any source listed in `sources_done`** from the
Phase 1 resume check. Each subagent receives the source row and its key, the full keywords list,
and `last_run_date`. Two lanes:

- **Browser-bound sources (`x`, `x-search`, `linkedin`) run at most 3 at a time.** They all drive
  the same Chrome. On 2026-09-28 about 20 subagents ran at once, 12 of them sharing one tab
  group: 7 X sweeps ended partial (stalled scrolls, evicted tabs, one timeline pass never ran),
  an eighth ran out of budget before expanding its threads, and the run still published as if
  complete. A retry at 3 at a time closed all 8 (backlog
  `A17`; `plans/20260928_1401-retry-of-20260928-run-evidence.md`). Start the next browser
  subagent only when one returns.
- **Everything else (`rss`, `html`, `github`, `github-search`) runs in parallel**, alongside the
  browser lane — none of it touches Chrome.

(`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` would enforce a cap mechanically, but it caps *every*
subagent and would serialise the ~70 non-browser sources too; the lane rule is the cap.)

**Checkpoint as results arrive.** This stage costs ~23 minutes and real money, and it can die at
any point — a session limit, a killed process, a closed laptop. After each batch of subagents
returns, rewrite `.loop-news/findings.json` with everything banked so far:

```json
{ "schema": 1, "today": "...", "run_time": "...", "last_run_date": "...",
  "complete": false,
  "sources_done": ["Boris Cherny [x]", "Cobus Greyling loop-engineering [github]", "..."],
  "findings": [ ... everything gathered so far ... ],
  "coverage": [ ... one record per browser-bound source swept so far ... ],
  "sources_to_consider": [ ... so far ... ], "source_updates": [ ... so far ... ] }
```

Rules that make the checkpoint trustworthy:
- **`complete` stays `false` for the whole of Phase 2 and 3.** It is set to `true` exactly once,
  in Phase 4. The wrapper reads that flag to decide whether a later run may skip this stage — set
  it early and a dead run looks finished.
- **Add a source to `sources_done` only after its subagent has returned.** A source listed but not
  actually swept is silently dropped from the run, and no error will ever be raised.
- **Every browser-bound source in `sources_done` has exactly one `coverage` record** (format under
  *Browser rules* below) — a later record for the same key *replaces* the earlier one, never sits
  beside it. If a browser subagent returns no record, write `{"status": "partial", "passes": [],
  "gap": "no coverage record returned"}` for it. **Never write `complete` on a subagent's
  behalf** — a record nobody earned is the defect this whole mechanism exists to prevent.
- Write the whole file each time rather than appending — a half-appended JSON file does not parse,
  and the wrapper treats an unparseable artifact as unusable, discarding the very work this is
  meant to protect.

**The goal is to find relevant content from that source — not just recent content.**
Search *within* the source for the keywords. Do not limit to posts newer than
`last_run_date` for the search itself; use `last_run_date` only to de-prioritise
already-seen items during deduplication (which `integrate-loop-news` does).

---

### Browser rules — every subagent that uses Chrome

Each rule below closes a failure measured on the 2026-09-28 run or its retry.

- **One tab of your own.** Create it with `tabs_create_mcp`, use only its `tabId`, and close only
  that tab when done. Never navigate, read or close another tab, a window or a tab group — up to
  two other sweeps share the browser, and in the retry one sweep's tab vanished when a peer tore
  down a shared window. If a call reports your tab gone, open a fresh one and carry on.
- **Read X from the DOM, not with `get_page_text`.** X's timeline is virtualised:
  `get_page_text` returns "No text content found" (54 of the run's 81 failed tool calls). Use
  `javascript_tool` to read each `article` — its `time[datetime]`, text, author handle, and the
  `a[href*="/status/"]` that wraps the `time` element. Posts unmount once scrolled past, so read
  after every scroll step and accumulate by status ID.
- **Pinned posts and reposts do not count as the source's posts in time.** Both show an older
  date — a pinned post its own, a repost the original's. On a profile or `from:` page, an article
  counts toward how far back you have read only if its status link path starts with
  `/<handle>/status/` and no social-context line above it says "Pinned" or "reposted". Judge
  reposts for relevance like any post, but never let one end a scroll or set `reached`.
- **A finding that is an X post carries a `/status/<id>` URL read from the DOM** — never a profile
  URL, never a composed ID. The run published 7 findings citing only a profile because the ID was
  not captured. To confirm a post's date or text without the browser,
  `https://api.fxtwitter.com/<handle>/status/<id>` returns its author, `created_at` and full
  text. If the ID truly cannot be read, write `"url": null, "url_unresolved": true`, say so in the
  summary, and name it in the coverage `gap`. (A link-expansion finding carries the linked page's
  URL, as before.)
- **Scroll with real wheel events** (the `computer` tool's `scroll` action), not
  `window.scrollBy`, which the retry saw stop loading in a background tab.
- **Tell a stall from an end before trusting either.** When a page stops growing
  (`document.documentElement.scrollHeight` stable across two scrolls), read `document.hidden`
  with `javascript_tool`. If it is `true`, the tab lost foreground and X stopped loading — a
  stall. Bring your tab to the front, or do what worked in the retry: run
  `Object.defineProperty(document, 'hidden', {get: () => false})` and dispatch a
  `visibilitychange` event, then keep scrolling. **A page counts as ended — or as genuinely
  empty — only if it stopped growing while `document.hidden` was `false`.** This applies to
  profile timelines, search pages and day-range pages alike.
- **Report coverage.** A browser subagent returns an object, not a bare array:
  ```json
  { "findings": [ ... ],
    "coverage": { "source": "Boris Cherny [x]", "status": "complete",
                  "passes": ["search", "timeline", "expansion"],
                  "reached": "YYYY-MM-DD", "gap": "" } }
  ```
  - `source` is the source's key. `passes` names what ran (`search`, `timeline`, `day-range`,
    `expansion`). `reached` is the oldest post date actually read (pinned posts and reposts
    excluded). `gap` says exactly what was not covered and why.
  - **`x` sources are `complete` or `partial`.** `complete` requires all of: `search` ran;
    `timeline` reached a date on or before `last_run_date`, or `day-range` covered the rest; and
    `expansion` ran if the sweep produced any Tier 1–2 finding. Anything else is `partial`.
  - **`x-search`, `linkedin` and the Phase 3 X search are `sampled`, by design** — their
    procedures read a sample (20+ posts, or the first page), so they are never `complete`, and
    they are not re-run. `reached` records how far back the sample went.
  - **Any non-empty `gap` makes the record `partial`** — `complete` with a gap is a contradiction,
    and the gap would be lost. A quiet source is `complete` with no findings and no gap — it is
    not a failure.
  - When you bank a record, **check it against these rules** and downgrade an inconsistent one to
    `partial` with `gap` "record inconsistent: <what is missing>". `integrate-loop-news` applies
    the same check, so a self-reported `complete` is never taken on trust alone.

---

### For `type: x` sources

> **Both passes below are mandatory, and neither substitutes for the other.**
> Measured on @bcherny, 20260906, minutes apart: the search pass returned **7** posts, the profile
> pass **4**, the union **9** — and the overlap was **2**. Each is blind where the other sees.
> Search cannot match vocabulary no tier tracks (*"Background computer use is underrated"* — eight
> words, zero keyword hits, from the creator of Claude Code). A profile read cannot reach past where
> X stops rendering — it stalled three days back on a 2,267-post account. Evidence:
> `plans/20260906_1259-c11-x-linkedin-baseline.md`.
> **If a sweep does only one pass, its coverage record is `partial` and says which pass is
> missing** — `integrate-loop-news` publishes that in the digest's Coverage section. (This line
> used to say "say so in the digest", but this skill never writes the digest, so on 2026-09-28
> six coverage caveats never reached it.)

**Pass 1 — keyword search.** Reaches back in time; blind to untracked vocabulary.

1. Use Chrome to navigate to:
   `https://x.com/search?q=from%3A<handle>%20(<url-encoded-keyword-query>)&f=live`

   Build the keyword query as an OR of the most specific keywords, **inside parentheses**:
   `from:<handle> ("loop engineering" OR "Claude Code" OR "agent loop" OR agentic OR subagent OR MCP OR worktree)`.
   Without the parentheses X drops the author scope and returns unrelated global results
   (`SOURCES.md`'s `x-search` row and its type table say the same; this line used to omit them).

2. Read the search results (latest posts matching those keywords from that account).
3. For each result collect: post text (first line), URL, date, one-sentence summary.

**Pass 2 — profile timeline.** Catches untracked vocabulary; blind past where X stops rendering.

4. Navigate to the profile page `https://x.com/<handle>` and read **every** post newer than
   `last_run_date` — not the first visible page. **Scroll until a post by the handle — not
   pinned, not a repost — dated before `last_run_date` has been read. That is the only end
   condition.**

   If the timeline stops growing first, apply *Tell a stall from an end* (Browser rules). A
   stall is **not the end**: it looks exactly like "nothing more was posted". If un-hiding the
   tab does not get it loading again, cover the rest of the window with **day-range searches**,
   one day per query, from the day the timeline stopped back to `last_run_date`'s day, each
   read until it ends by that same test:
   `https://x.com/search?q=from%3A<handle>%20since%3A<YYYY-MM-DD>%20until%3A<next-day>&f=live`
   (this also catches replies). A day page that stops while `document.hidden` is `true` has not
   been read — name that day in the coverage `gap`. Add `day-range` to the record's `passes`. In
   the 2026-09-28 retry, date-restricted searches closed the gaps they were used on, though not
   perfectly: for @steipete a later profile cross-check found 193 in-window posts against 191
   already listed, the 2 extra being off-topic replies. Only if the day-range searches fail too
   is the source `partial`.

   **Do not filter this pass by keyword.** Judge each post on whether it is substantively about
   loop / harness / agent practice, as you would any Tier 3–4 candidate. The keyword tiers are a
   *recall* device for search; applying them here re-creates the exact blind spot this pass exists
   to cover — which is what the previous wording did, while its own parenthetical claimed the
   opposite.

   Record **how far back the timeline actually reached** — it is the coverage record's
   `reached`. A stall is a coverage limit, and an unreported one reads as "nothing was posted".
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
2. **Scroll to load posts**: after the initial page load, scroll down at least 3 times (waiting briefly between scrolls) to load a minimum of 20 posts. Scroll with real wheel events and read the DOM after each step (see *Browser rules*).
3. Read all visible posts. For each collect: author handle, post text (first 2 lines), URL, date, one-sentence summary.
4. Score each post against the keyword tiers.
5. **Link expansion** — for every Tier 1 or Tier 2 post: apply the same thread-and-link expansion as `type: x` sources (navigate to thread URL, collect external links, WebFetch the 3 most innovative).

---

### For `type: linkedin` sources

LinkedIn search results are dynamically loaded. A single page read returns very few posts.

1. Use Chrome to navigate to the search URL from SOURCES.md.
2. **Scroll to load posts**: scroll down at least 3 times to load a minimum of 20 posts, with real wheel events (see *Browser rules*), waiting 1–2 seconds between each scroll.
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

Each non-browser subagent returns a JSON array (empty if no matches); a browser subagent returns
the same array as the `findings` of its `{findings, coverage}` object (see *Browser rules*):
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

When you bank a browser source, check its coverage record (*Browser rules*) and store it in the
artifact's `coverage` array under the source's key.

**Before Phase 3, re-run every `partial` coverage record that lacks `"rerun": true` — once each,
one at a time**, with the browser otherwise idle (`sampled` records are not re-run). Keep the
findings of both attempts — union by `url`, and by source + title + date for findings whose `url`
is `null` — then *replace* that source's record with whichever attempt covered more, with
`"rerun": true` added, and checkpoint after each one, so a resumed run
re-runs only what is left. A source still `partial` after its re-run stays `partial` — the record
carries the gap to the digest; it is never quietly upgraded or dropped. This is the retry that
closed the 2026-09-28 gaps, moved inside the run.

## Phase 3 — General search (bonus pass)

After all per-source subagents return, run two additional searches:

**X.com keyword search** — a browser source like any other: follow *Browser rules*, give it the
key `X general search [phase-3]`, and when it returns add that key to `sources_done` and its
`sampled` record to `coverage` (replacing any earlier one). On a resumed run, skip it if the key
is already in `sources_done`. Use Chrome to navigate to:
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
     "complete": true,
     "sources_done": ["...every source swept this run..."],
     "today": "YYYY-MM-DD",
     "run_time": "YYYY-MM-DD HH:MM UTC",
     "last_run_date": "YYYY-MM-DD",
     "findings": [
       { "source": "@handle", "title": "...", "url": "https://...",
         "date": "YYYY-MM-DD", "tier": 1, "summary": "..." }
     ],
     "coverage": [
       { "source": "Boris Cherny [x]", "status": "complete",
         "passes": ["search", "timeline", "expansion"], "reached": "YYYY-MM-DD", "gap": "" }
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
   - `coverage` holds one record per browser-bound source, after the pre-Phase-3 re-runs.
     **Before setting `complete: true`, every `x`, `x-search` and `linkedin` row in `SOURCES.md`,
     plus `X general search [phase-3]`, must have a record.** Any that has none — a dispatch
     refused at the subagent limit, a subagent that errored, Chrome not connected — gets
     `{"status": "partial", "passes": [], "gap": "not swept: <reason>"}`. An unswept browser
     source must be visible in the artifact, not merely absent from `sources_done`.
   - **`complete: true` means Stage A finished, not that every source was fully covered** — a
     `partial` record is a finished sweep with a stated gap, and it travels to the digest
     through this array. Never leave a partial out to make the run look clean.
   - **`complete: true` is set here and only here** — this is the signal that Stage A finished.
     `sources_done` should by now name, by key, every source in `SOURCES.md` you swept,
     including any carried over from a resumed attempt.
   - On a zero-finding day, still write the file with `"findings": []` **and
     `"complete": true`** — a quiet day is a finished run, not a failed one. The wrapper
     distinguishes the two by the flag, never by whether the array is empty.
3. Close any Chrome tabs this run opened that are still open — tabs only, never a window or a
   tab group (other sessions may be using the same browser).
4. **Stop here — unconditionally, with no exceptions.** Do not edit the KB, do not
   commit, and do not invoke `/integrate-loop-news` yourself — not via the Skill tool,
   not by reading and following its SKILL.md inline, under any circumstance, including
   when you believe you were invoked interactively. You cannot reliably tell interactive
   invocation from a headless wrapper run, and the two-session split (context isolation,
   independent retry, independent model/effort) is deliberate — collapsing it back into
   one session defeats the reason it was split. If a human wants to complete the
   pipeline, **they** run `/integrate-loop-news` themselves, as their own explicit,
   separate step.

   **This instruction alone is not sufficient — do not rely on it.** In production this
   exact escalation happened twice in a row even with wording this explicit (2026-07-04,
   2026-07-06): the model self-invoked the integrate stage anyway, both by using it as
   permission and via tools the classifier approved beyond the session's allowlist. The
   wrapper (`scripts/run-loop-news.sh`) now also structurally denies `Bash(git *)`,
   `Bash(gh *)`, and `Skill` for this stage via `--disallowedTools` — a real deny-list,
   verified to hold even under `--permission-mode auto` (unlike `--allowedTools`, which
   the auto classifier can approve beyond). That technical enforcement, not this prose,
   is what actually prevents the collapse when run through the wrapper. A human running
   this skill interactively outside the wrapper has no such enforcement and must rely on
   this instruction alone.
