# C11 evidence pack — X profile reads and LinkedIn person-search, measured

**Run 20260906 10:24–12:59 UTC**, by hand in Chrome (logged-in session) and via the LinkedIn MCP
server. Closes backlog item **C11**. Serves `SOURCES.md`, `fetch-loop-news/SKILL.md`, `docs/34`.

## Why this existed

Not a hypothesis — a **self-disclosure**. The 2026-09-04 catch-up run wrote its own coverage gap
into `LOOP_ENGINEERING_NEWS.md:661-666`:

> **X/Twitter** was swept only via search and archived reproductions; x.com was not fetched directly.
> […] **LinkedIn** was swept for posts only; person-level search was not run.

C11 is that paragraph promoted to a backlog item. Both halves have now been run.

---

## Part 1 — X: profile timeline vs. keyword search, head to head

Subject: **@bcherny** (Boris Cherny, creator of Claude Code) — the highest-value `x` row, and the
one whose `docs/26` / `docs/32` / `docs/20` quote is still unpinned (**H4**).

Both methods run against the same account, minutes apart, from the same logged-in browser.

| | Direct profile read (`x.com/bcherny`) | Keyword search (`from:bcherny (<tier1-2 OR-query>)`) |
|---|---|---|
| Posts recovered | **4** | **7** |
| Oldest reached | 2026-09-01 | **2026-08-11** |
| Behaviour | **stalled** after ~5 articles; further scrolling loaded nothing (`scrollHeight` stopped growing at 9037px against a 2,267-post account) | paginated normally |

**Union: 9 posts. Overlap: 2. Neither method found ~⅔ of the union.**

- **Timeline-only (2):** `2095378890370019683`, `2095276133214491086`
- **Search-only (5):** `2095006371976753273`, `2094864063478276288`, `2094864062186426373`,
  `2088014489438621990`, `2087024157196489117`
- **Both (2):** `2095590515765060076`, `2094864060609376748`

### The finding that matters

The backlog assumed direct profile reads are the fix. **They are not — they are the other half.**
Each method is blind in a different direction, and the blindness is structural:

1. **Keyword search cannot see vocabulary it does not track.** The clearest case is
   [`2095378890370019683`](https://x.com/bcherny/status/2095378890370019683) (2026-09-03),
   in full: *"Background computer use is underrated"* — eight words, zero matches across all four
   keyword tiers, from the creator of Claude Code. Only a timeline read finds it.
2. **A profile read cannot see past where X stops rendering.** The timeline stalled three days
   back. Everything older is reachable only by search.

So the `x` strategy needs **both**, and needs to say why — otherwise the next agent
"simplifies" it back to one.

### The regression this uncovered

`git log -S` shows the `x` strategy was **originally** a direct timeline read, and was replaced:

| Commit | `x` fetch strategy |
|---|---|
| `e4cdce6` (initial) | `Chrome browser → navigate x.com/<handle> → extract posts from last 24h` |
| `4fc6fca` | `Chrome → search from:<handle> (<tier1-tier2-query>) in X.com search; also scan profile's recent posts` |

The direct read was demoted to a trailing clause. And `fetch-loop-news/SKILL.md:95-97` — which
*does* still instruct a profile visit — **keyword-gates it too**:

> Also navigate to the profile page […] and scan the first visible page of posts for anything
> posted after `last_run_date` **that matches ≥ 1 keyword**

That is the actual defect, and it is subtler than "X is never fetched directly": **the keyword
filter is applied on both paths**, so an untracked-vocabulary post is invisible to the pipeline no
matter which path runs. The parenthetical on that very line — *"(catches posts that don't use exact
keyword phrasing)"* — states an intent the instruction then forbids.

Corroborating trace, in the digests' own words: `LOOP_ENGINEERING_NEWS.md` lines
1162, 1215, 1287, 1361 each record Cherny as *"no new **keyword-matching** posts"*, and
`:1287` adds *"X live + per-handle scans **not re-run this cycle**"*.

### Two primary-source posts the KB does not have

Both surfaced by the search half, both absent from `docs/`, `LOOP_ENGINEERING_NEWS.md` and
`KB_GAPS.md` (greped by phrase and by status id).

**1. [2026-08-13 — Claude maintaining Anthropic's own apps](https://x.com/bcherny/status/2088014489438621990)**
Verbatim, in relevant part:

> A weird experiment I've been trying the last few weeks is having Claude take over day-to-day
> maintenance of our apps. […] we have a Slack channel called proj-claude-maintains-apps. In it,
> Claude Tag runs a bunch of daily routines across iOS, Android, Desktop, web, CLI, and Agent SDK:
> - Crash fuzzer: open the app in a simulator and tap around to find ways to crash it, then root
>   cause and fix the crashes
> - Dup unifier: scans the codebase for similar-yet-slightly-divergent abstractions, and puts up
>   PRs to unify them
> - Dead-code remover: removes statically unreachable code, and adds logging to suspected dead code
>   to check if it's really dead and if so, remove it the next day
> - Abstraction police: fixes leaky abstractions
> - a bunch more..
>
> Results have been surprisingly positive. Over the last few weeks, these routines have opened 388
> PRs across our repos, 180 of which we merged after Claude Code Review + human review. […]
> Claude generally gets these PRs right on the first shot, and if it doesn't, we ask Claude to tune
> its routines so it's better the next day. Sometimes it takes a few days of tuning.

Why it matters to this KB, beyond being quotable:
- A **named, measured production loop fleet** from the creator of Claude Code — 388 opened / 180
  merged is a **46% merge rate**, and one of very few real hit-rate numbers in the corpus.
- The stop/verify contract is explicit: **Claude Code Review + human review** before merge.
- The dead-code remover is a **two-day loop** — instrument on day 1, decide on day 2. A loop whose
  verifier needs a night to produce evidence is a shape `docs/34` does not currently carry.
- *"we ask Claude to tune its routines so it's better the next day"* is a **self-improving outer
  loop** stated plainly by a primary source — `docs/22`/`docs/27` material.
- The post's closing line asks *"Has anyone experimented with similar workflows?"*, and the thread's
  promised prompts (*"A few of the actual prompts I used below"*) did **not** render for a
  logged-in reader after two scroll rounds. **Unretrieved, not absent** — worth one retry.

**2. [2026-08-11 — a loop for worktree cleanup](https://x.com/bcherny/status/2087024157196489117)**, in full:

> Worktrees can be rough when they pile up. I use a loop to clean up stale worktrees. Should we
> build this into Claude Code?

Relevant to `docs/03`'s worktree section and adjacent to `KB_GAPS` **V4** (the undefined
`cleanupPeriodDays` default): as of 2026-08-11 the creator of Claude Code was doing this with a
**loop rather than a built-in**, which dates the native retention sweep's arrival.

**Attribution of the miss — stated carefully.** Both posts fall inside the tracker's eight-week
outage (2026-07-08 → 2026-09-05), so *nothing ran* when they were published. The 2026-09-04
catch-up run was supposed to cover exactly that window and reported no Cherny findings, while the
Aug 11 post matches `worktree` — a keyword in the query. Whether that run's search was not run for
this handle, or ran against a shorter window, **cannot be determined from the artifacts**. What is
established: the posts exist, they are on-topic, and they are not in the KB.

---

## Part 2 — LinkedIn: person-search baseline

Run via the LinkedIn MCP server, three queries plus one profile deep-read.

| Query | Kind | Result |
|---|---|---|
| `loop engineering Claude Code agent harness` | people | **0 results** |
| `"loop engineering"` | people | 10 shown, 10 pages |
| `"harness engineering"` | people | 10 shown, 10 pages |
| `"loop engineering" OR "harness engineering" Claude Code`, past-month | content | **3 substantive posts** |

### What person-search actually returns

Not publishers — **claimants**. Every one of the 20 people surfaced across the two person queries
matched on a *headline or skills string*, not on anything published. Two independent defects:

1. **It is network-biased, not topic-ranked.** The same mutual connections recur across both
   unrelated queries, and results skew to the account holder's own city. A person-search row would
   return *the operator's professional network*, re-ranked by keyword — not the field. That makes
   it unreproducible across operators and worthless as a shared source row.
2. **Headline keywords do not predict published content.** Deep-read of the strongest single
   candidate — highest follower count of any hit, headline naming harness engineering explicitly —
   loaded **120 posts**. Substantively on-topic: **2**. The remainder is company marketing for an
   unrelated product: reposts of colleagues, launch clips, weekly business reviews.

### The comparison that settles it

The content search returned three on-topic posts from the past month, including two LinkedIn Pulse
articles. **None of their three authors appeared anywhere in the person-search results** — they are
outside the account's network, which is precisely where the content search can reach and the person
search cannot.

### Recommendation — do NOT add the person-search row

**This contradicts C11 as written, and the measurement is the reason.** The backlog said *"add a
`linkedin` person-search row and run a baseline."* The baseline was run and it argues against the
row: it would cost a browser session per run, return the operator's own network, and surface zero
of the authors the existing content row already finds.

What to do instead — cheaper and strictly better:

1. **Broaden the existing `linkedin` content row's keywords.** It currently searches
   `loop engineering` alone. Adding `harness engineering` is what surfaced 2 of the 3 posts here.
2. **Record the negative result in `SOURCES.md`**, so the next agent does not re-derive it. A
   ruled-out source strategy is worth as much as an adopted one, and this KB has already paid twice
   for un-annotated dead ends.

### One genuine finding, kept

*"Loop engineering"* has crossed into **résumé vocabulary** — it appears in LinkedIn headlines and
skills sections, across at least four countries, held by people who are not publishing on it.
That is evidence about the term's diffusion, and it belongs in the KB's own framing of the
discipline's spread. **No individual is named**: this repo is public, the people are private
individuals, and the aggregate is the whole finding.

---

## Provenance and limits

- Every number above was measured on **20260906** between 10:24 and 12:59 UTC. X is a live surface;
  the counts are a snapshot and the timeline-stall depth in particular may vary by session, account
  and rate-limit state. The **direction** of the result (two-way blindness) does not depend on the
  exact counts; the exact counts should not be re-quoted as stable.
- The head-to-head is **n=1 account**. It is enough to prove each method misses what the other
  finds — a single counterexample settles that — but it does not establish a *rate* across handles.
- The LinkedIn person-search deep-read is **n=1 profile**, chosen as the strongest candidate. A
  weaker candidate would not have strengthened the case against the row.
- The Aug 13 thread's *"actual prompts I used below"* were **not retrieved**. Recorded as
  unretrieved.
