# Loop Engineering News Sources

The `fetch-loop-news` skill reads this file on every run. Add, remove, or edit rows
here to change what gets tracked — no changes to the skill needed.

---

## Relevance keywords

Scored in four tiers. A post matching **Tier 1 or 2** is always included in the
digest. A post matching **Tier 3 or 4 only** is included if the subagent judges it
substantively relevant to loop engineering practice (not just a passing mention).

### Tier 1 — Boris Cherny's exact language
*Any post using these terms is directly on-topic.*

- `"write loops"` / `"writing loops"`
- `"my job is to write loops"`
- `routines` (in a Claude Code / agentic context)
- `"loops that prompt"`
- `"the thing that writes the code"`

### Tier 2 — Named discipline (Osmani / Steinberger framing, built on Cherny)
*Widely adopted community terminology.*

- `"loop engineering"`
- `"replace yourself as the person who prompts"`
- `"designing loops"`
- `"agent loop"`
- `"agent harness"` / `"harness engineering"`
- `"factory model"` (AI software factory)

### Tier 3 — Named concepts within the space
*Specific patterns and failure modes; include if the post discusses them in an agentic context.*

- `worktree` (isolated git checkout per agent)
- `subagent` / `sub-agent`
- `"maker checker"` / `"writer reviewer"`
- `"intent debt"`
- `"comprehension debt"`
- `"cognitive surrender"`
- `"orchestration tax"`
- `"adversarial code review"`
- `"verification loop"`
- `"stopping condition"` (+ agent / loop context)
- `headless` (+ Claude / agent)
- `MCP` (+ agent / connector)

### Tier 4 — Tool and feature names
*Surface on-topic content; include only if the post discusses agentic / loop patterns, not just general usage.*

- `Claude Code`
- `/goal` (Claude Code command)
- `"permission mode auto"`
- `Codex` (OpenAI, agentic context)
- `OpenClaw`
- `agentic` / `multi-agent`
- `"tool use"` (+ agent context)

---

## Sources

> **A source row that returns nothing looks identical to a quiet week.**
> The Batch row below was configured as `rss` against a feed that had 404'd. For two months it
> produced zero findings and nothing flagged it — because "no new posts" and "the feed is gone"
> are the same empty result. It cost the KB an entire four-part Andrew Ng series that turned out
> to be the spine of Part II.
>
> **A source yielding nothing for more than ~3 consecutive runs must be re-fetched by hand before
> its silence is believed.** Rows carrying a `404` note are in that state now: treat them as
> *unswept*, not as *quiet*.
>
> **Revalidated 2026-09-06 00:26 UTC.** Every one of the 47 checkable URLs in this table was
> fetched. **45 returned 200.** One was dead — AI Breakfast, fixed below by the same `rss` → `html`
> switch The Batch needed, because no discoverable feed exists. One stored an `http://` URL that
> 301-redirects; it now stores the `https://` form. The remaining 7 rows carry handles or search
> queries rather than URLs and are not URL-checkable. **No other row is broken.**

| Actor | Type | Handle / URL | Notes |
|---|---|---|---|
| Anthropic | html | https://claude.com/blog | Primary source for Claude Code updates. No RSS feed exists (confirmed Jul 2026 — `/rss.xml`, `/news`, `/blog/rss.xml` all 404, no `<link rel=alternate>` in page head); official blog moved to claude.com/blog, scrape the index page directly |
| Boris Cherny | x | @bcherny | Creator of Claude Code; coined "write loops" |
| Andrej Karpathy | x | @karpathy | Influential ML researcher |
| Andrew Ng | x | @AndrewYNg | Agentic AI education |
| The Batch — Ng's letters (DeepLearning.AI) | html | https://www.deeplearning.ai/the-batch/tag/letters | **High value; was silently unswept for two months.** Andrew Ng's weekly letter. **Read the OPENING SECTION of every letter regardless of its title** — the coding-agent material is usually at the start, so a letter titled about export controls or course design still carries concrete agentic-coding guidance. Filtering by title loses most of the signal. Switched `rss` → `html` on 2026-09-04: the official feed (`/the-batch/feed/`) has been 404 since at least 2026-07-08 and no `<link rel=alternate>` exists, so the RSS row silently returned nothing for two months while looking configured. The tag page scrapes fine and paginates. A 2026-09-04 sweep of 57 letters found 37 with on-topic content, including the four-part [AI Engineering Skills Map](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map/) whose "Using Coding Agents" letter is the spine of KB Part II |
| OpenAI | rss | https://openai.com/news/rss.xml | Feed discovered Jul 2026 (was html-scraped; 250+ articles returned, root-level path works despite prior 403 note) |
| Addy Osmani | rss | https://addyo.substack.com/feed | Corrected Jul 2026 — his active blog is the "Elevate" Substack (addyo.substack.com), which carries the origin "loop engineering" post (Jun 2026); the previously-tracked addyosmani.com feed was a different, largely-dormant site |
| Simon Willison | rss | https://simonwillison.net/atom/entries/ | LLM tooling practitioner |
| Swyx | x | @swyx | AI engineering community. Low yield Jul 2026, confirmed again with a broadened query — his own posts are consistently off-topic reposts; findings so far have come only from reposts/threads, not his own writing. Keep tracking (profile scan is cheap) but do not expect direct-post yield |
| swyx.io | rss | https://www.swyx.io/rss.xml | AI engineering long-form posts; feed URL discovered Jul 2026 (was html-scraped). Feed is alive (200 OK) but most recent post is dated 2026-07-05 — no new content in ~2 months as of 2026-09-06; low priority until it resumes posting |
| The New Stack | rss | https://thenewstack.io/feed/ | Active loop engineering coverage |
| Sabrina Ramonov | rss | https://www.sabrina.dev/feed | Loop engineering + /goal + Routines (Jun 2026); feed URL discovered Jul 2026 (was html-scraped) |
| Sabrina Ramonov | x | @Sabrina_Ramonov | Active X presence posting loop engineering definitions and techniques (Jun 2026) |
| Cobus Greyling | rss | https://cobusgreyling.substack.com/feed | Loop Engineering Substack + GitHub repo |
| Peter Steinberger | x | @steipete | Creator of OpenClaw; "designing loops" framing |
| Lenny's Newsletter (Claire Vo) | rss | https://www.lennysnewsletter.com/feed | Four-type loop taxonomy article; high-engagement AI practitioner audience (Jun 2026); Substack RSS |
| Cobus Greyling loop-engineering | github | https://github.com/cobusgreyling/loop-engineering | Reference implementation and patterns repo; watch for new docs, examples, and releases |
| The Rundown AI | rss | https://rss.beehiiv.com/feeds/2R3C6Bt5wj.xml | Daily AI newsletter (Beehiiv); scan for loop engineering / agentic workflow coverage. Feed URL rediscovered Jul 2026 (original `/feed` 404'd) |
| TLDR AI | rss | https://tldr.tech/api/rss/ai | Daily AI digest RSS; scan for Claude Code, agent loop, agentic workflow coverage. Feed URL rediscovered Jul 2026 (`/ai/rss` 404'd; `tldr.tech/rss` is the general-tech feed, not AI-specific) |
| Ben's Bites | rss | https://bensbites.com/feed | Daily AI news digest RSS; scan for loop engineering / agent loop coverage. Feed URL rediscovered Jul 2026 (moved off beehiiv to its own domain) |
| AI Breakfast | html | https://aibreakfast.beehiiv.com/ | Daily AI newsletter; scan for agentic workflow and Claude Code coverage. Switched `rss` → `html` on 2026-09-06 after the same failure as The Batch: `/feed` has 404'd since at least 2026-07-08, `/feed.xml` and `/rss` also 404, `rss.beehiiv.com/feeds/aibreakfast.xml` 404s, and the homepage carries **no `<link rel=alternate>` and no beehiiv feed id** — so no discoverable feed exists. The index page resolves 200 and lists ~9 posts as `/p/<slug>` links; scrape it directly. The row's previous note said "try `/rss` next run" and sat unactioned for two months |
| X search — loop engineering | x-search | https://x.com/search?q=loop%20engineering&src=typed_query&f=live | Live keyword search; dynamically loaded — scroll ≥3 times to surface 20+ posts |
| LinkedIn search — loop engineering | linkedin | https://www.linkedin.com/search/results/content/?keywords=%22loop%20engineering%22%20OR%20%22harness%20engineering%22 | Professional community posts; dynamically loaded — scroll ≥3 times to surface 20+ posts. **Keywords broadened 2026-09-06** from `loop engineering` alone: adding `harness engineering` is what surfaced 2 of the 3 substantive posts in that day's baseline |
| Harness Books (AgentWay) | html | https://harness-books.agentway.dev | Essay collection on harness design theory — unstable components, ledger closure, input governance, reactive compact |
| MindStudio Blog | rss | https://www.mindstudio.ai/rss.xml | Published 3+ loop engineering articles covering loop design, agent harness architecture, and verification patterns (Jun 2026); feed URL discovered Jul 2026 (root-level path — /blog/rss.xml 404s) |
| GitHub search — loop engineering claude | github-search | https://api.github.com/search/repositories?q=%22loop+engineering%22+claude&sort=updated | Search GitHub repos combining "loop engineering" + claude; returns JSON — no auth needed (10 req/hr limit); find new implementations |
| GitHub search — claude code harness | github-search | https://api.github.com/search/repositories?q=%22claude+code%22+harness&sort=updated | Search GitHub repos combining "claude code" + harness; returns JSON — surface new harness design repos |
| cobusgreyling/goal-engineering | github | https://github.com/cobusgreyling/goal-engineering | Reference implementation: GOAL.md schema, six canonical goal patterns, G0-G3 readiness scoring tool (Jun 2026) |
| cobusgreyling/fleet-engineering | github | https://github.com/cobusgreyling/fleet-engineering | Reference implementation: six fleet governance patterns, Fleet Economics cost attribution, F0-F3 maturity (Jun 2026) |
| omnigent-ai/omnigent | github | https://github.com/omnigent-ai/omnigent | Meta-harness (4771★): 3-tier governance, harness-swap, cross-device session continuity (Jun 2026) |
| GitHub search — cross-model maker/checker | github-search | https://api.github.com/search/repositories?q=claude+codex+reviewer+loop&sort=updated | Replaced low-yield `acting_on` query (0 results; that STATE.md gap is filled). Surfaces cross-model maker/checker harnesses (Claude implements / Codex reviews) — the Jun 2026 dominant theme |
| Akshay Pachaar | x | @akshay_pachaar | Co-founder @dailydoseofds_; loop engineering internals diagrams and practitioner breakdowns (Jun 2026) |
| getzep/graphiti | github | https://github.com/getzep/graphiti | Temporal knowledge graph for agent state layer: invalidates stale facts, multi-modal search (vector+full-text+graph) (Jun 2026) |
| eugenelim/agent-ready-repo | github | https://github.com/eugenelim/agent-ready-repo | Agent-ready repo spec: Surface vocabulary, adversarial reviewer checklists, verification modes, org learning stage (Jun 2026) |
| JeiKeiLim/tenet | github | https://github.com/JeiKeiLim/tenet | Structured loop critic framework: oracle problem, 3-tier document lifecycle, critic finding taxonomy (Jun 2026) |
| faisalishfaq2005/loopflow | github | https://github.com/faisalishfaq2005/loopflow | Loop orchestration: cross-run memory persistence, gate feedback injection, debt-audit + docs-sync patterns (Jun 2026) |
| uppifyagency/loop-kernel | github | https://github.com/uppifyagency/loop-kernel | Provably-halting loop kernel: three exit-code stops (0/2/3), external unfakeable verifier, score=<fraction> contract, LEDGER across compaction (Jun 2026) |
| affaan-m/ecc | github | https://github.com/affaan-m/ecc | Flagship multi-harness "agent operator system" (224k★): eval-harness (pass@k/pass^k, 3 grader types), verification-loop, /loop-start, instinct learning; watch for focused loop-engineering skills (Jun 2026) |
| krishddd/Strive_Engineering | github | https://github.com/krishddd/Strive_Engineering | Provenance-bound verification: every finding cites a git SHA re-checked via `git cat-file` (loopguard), majority_vote blocks self-grading, L0-L3 autonomy ladder; isomorphic-perturbation verifier (Jun 2026) |
| Happenmass/omux | github | https://github.com/Happenmass/omux | **Renamed from Happenmass/Cliclaw 2026-09 (confirmed via GitHub API — the old repo ID no longer resolves; not a second repo from the same author, as this row previously read)**: cross-model maker/checker (Claude implements / Codex reviews) over tmux, auto-continue gate model, tmux-pane state scraping (hook-free), two-tier hybrid/SQLite memory; 95★ |
| firegnu/herdr-loop-lab | github | https://github.com/firegnu/herdr-loop-lab | Three-layer (inner/fleet/epic) cross-model adversarial judge + mechanical gate; exit-code stop contracts (0/2/3), stateless worktree rounds, AC-N acceptance criteria (Jun 2026) |
| arXiv — harness/loop research | rss | https://export.arxiv.org/api/query?search_query=all:%22agent+harness%22+OR+%22loop+engineering%22+OR+%22self-improving+harness%22&sortBy=submittedDate&sortOrder=descending&max_results=30 | arXiv Atom API; primary source for harness-engineering research (Self-Harness 2606.09498, AHE 2604.25850, HarnessX 2606.14249). Added Jul 2026 after 3 arXiv findings in one run |
| peterCheng123321/loop-engineering | github | https://github.com/peterCheng123321/loop-engineering | Convergence layer over /loop, ralph-loop, Agent SDK loops; progress.md as DP "memo table" — cache solved steps, prune failed branches, survive compaction (Jul 2026) |
| Sungmin-Cho/claude-deep-loop | github | https://github.com/Sungmin-Cho/claude-deep-loop | Control-plane/execution-plane split: kernel is sole authorized writer, skill agents read-only and write via kernel subcommands; content-hash-anchored state + append-only events across sessions (Jul 2026) |
| shouryasrivastava/ctxcarry | github | https://github.com/shouryasrivastava/ctxcarry | "Repo owns your context, not the agent": local-first .ctxcarry/ durable memory, worktree generators, evaluators-assume-broken, token-budgeted multi-tool handoff (Jul 2026). **Default branch is `master`, not `main`** — use `/commits/master` |
| the-open-engine/zeroshot | github | https://github.com/the-open-engine/zeroshot | ~1.6k★; blind validation / information-asymmetry reviewers — validators see only outputs, never the maker's reasoning; anti-collusion reject-and-retry until all approve (Jul 2026) |
| JasonxzWen/harness-hub | github | https://github.com/JasonxzWen/harness-hub | Deep-read Jul 2026 (avg 3.5/5) — lock-versioned, state-separated distribution of skills/harness templates; a harness-marketplace angle distinct from typical skill package managers |
| edonadei/caliper | github | https://github.com/edonadei/caliper | Deep-read Jul 2026 (avg 3.67/5) — local-first eval harness for Claude Code/Codex/Pi/Hermes skills; automatic with/without-skill baseline comparison isolates skill-attributable gains from base-model gains |
| explainx.ai | html | https://explainx.ai/blog/ | Consistent loop/harness engineering coverage across 3+ runs (Loop Contract Model guide, context/prompt/loop/harness stack piece); overdue add per repeated "worth tracking" flags |
| Daily Dose of Data Science | html | https://www.dailydoseofds.com | Avi Chawla; 3+ high-engagement (100K-250K+ views) loop/harness/agentic-engineering explainers in one cycle, promoted via @akshay_pachaar (Jul 2026) |
| hhamja | github | https://github.com/hhamja/claude-code-harness | **Renamed from hhamja/loop-harness (2026-09, confirmed via GitHub API repo-id redirect; old URL 301s)**, description unchanged. Prolific single actor flagged twice now (Jun/Jul 2026) with 5+ same-day loop-engineering/harness repos (loopkit, loopkit-b, my-loopkit, loop-harness, loop-engineering-architecture, claude-code-flywheel); this repo itself ships a cross-model verifier split and disk-based state — promoted to tracked after repeated "worth watching" flags |
| ruvnet | github | https://github.com/ruvnet | Prolific actor, now 8+ relevant contributions: metaharness, ruflo, dream-machine, autogenous, openAVO, sparc, ruClip, RuVector, rvm, ruos — an entire ecosystem of Loop Contract / self-improving-harness / fleet-infrastructure repos; track the profile for new repos, this list is not final (Sep 2026) |
| huangruiteng/loopx | github | https://github.com/huangruiteng/loopx | 5,616★, updated 2026-09-05; local-first control plane above Claude Code/Codex/Cursor explicitly framed as "loop engineering" (quota-aware should-run gate, durable objectives+evidence logs — cited in docs/27 and docs/16); strongest new-repo candidate flagged this run, promoted to a tracked row (Sep 2026) |
| ARC Prize Foundation | html | https://arcprize.org/blog | Publishes independent harness-vs-model benchmark breakdowns (ARC-AGI-3) that repeatedly surface harness-engineering findings ahead of mainstream coverage — cited in docs/04, docs/24, docs/25 this run (Sep 2026) |
| coleam00/archon | github | https://github.com/coleam00/archon | 23,389★ — YAML-DAG harness builder (mixes deterministic and AI process nodes, isolated per-node git worktrees), by far the most externally validated harness-builder in this KB's corpus; near-daily merged PRs and semver releases every 1-2 weeks (Sep 2026) |
| Hanako | x | https://x.com/hanakoxbt | Published 2+ substantive loop-vs-graph explainer threads/videos this month (Aug 23 full course + Sep 5-6 "Loops vs Graphs" thread) with meaningful engagement (Sep 2026) |
| Kirill | x | https://x.com/kirillk_web3 | Published 2+ loop/graph-engineering guides this month (Aug 20 "Kimi K3 - From Loops to Graphs", Sep 6 "Loop and Graph Engineering — Full Guide") (Sep 2026) |
| ikangai | html | https://ikangai.com | Independent blog running a coherent harness/loop/graph-engineering naming-progression thesis ("Graph Engineering Is Harness Engineering With a Diff" — cited in docs/21); worth periodic monitoring (Sep 2026) |
| Bruno Gonçalves / Data For Science | rss | https://data4sci.substack.com | Primary source for original harness-engineering essays (OODA-loop/air-campaign framing) cited by explainx.ai's DAG-harness piece; **most content is paywalled** — only free previews are fetchable (Sep 2026) |
| METR | html | https://metr.org | Source of transcript-tampering/tool-call-spoofing/reward-hacking research cited across multiple MindStudio posts this run (docs/17) — directly relevant to this KB's verification-loop and "a default that means success" material (Sep 2026) |

---

## Type reference

| Type | Fetch strategy |
|---|---|
| `x` | **Two passes, both required.** (1) Chrome → search `from:<handle> (<tier1-tier2-query>)` in X.com search. (2) Chrome → read the profile timeline at `x.com/<handle>` **unfiltered**, back to `last_run_date` or until the timeline stalls. Measured 20260906 on @bcherny: 7 posts / 4 posts / union 9 / **overlap 2** — each pass is blind where the other sees. Report how far the timeline reached |
| `rss` | WebFetch feed URL → parse `<item>` / `<entry>` → score against keyword tiers |
| `html` | WebFetch page URL → extract article links + snippets → score against keyword tiers |
| `github` | WebFetch repo URL + `/commits/main` → score new commits since `last_run_date`; also check `/releases` for tagged releases |
| `x-search` | Chrome → navigate to the search URL → scroll down ≥3 times to load 20+ posts → read all posts → score against keyword tiers |
| `linkedin` | Chrome → navigate to the search URL → scroll down ≥3 times to load 20+ posts → use JavaScript to extract post text → score against keyword tiers; WebFetch any linked Pulse articles for Tier 1/2 matches. **Content search only — see the ruled-out note below before adding a person-search row** |
| `github-search` | WebFetch the GitHub API URL (returns JSON) → parse `items[].full_name`, `description`, `updated_at`, `stargazers_count` → score against keyword tiers → for high-scoring repos WebFetch the raw README URL and summarise; check `updated_at > last_run_date` to flag new/recently-active repos |

---

## Ruled-out source strategies

Recorded so they are not re-proposed. A strategy that was measured and rejected is worth as much as
one adopted — this KB has twice paid for un-annotated dead ends.

### LinkedIn person-search — evaluated 2026-09-06, **not adopted**

The backlog asked for a `linkedin` person-search row (`search/results/people/`). A baseline was run
before adding it, and the baseline argues against the row.

| Query | Kind | Result |
|---|---|---|
| `loop engineering Claude Code agent harness` | people | **0 results** |
| `"loop engineering"` | people | 10 shown, all matching on headline/skills text |
| `"harness engineering"` | people | 10 shown, same pattern |
| `"loop engineering" OR "harness engineering" Claude Code` (past month) | **content** | **3 substantive posts, 2 with Pulse articles** |

Two independent reasons it fails as a source row:

1. **It is network-biased, not topic-ranked.** The same mutual connections recurred across two
   unrelated queries and results skewed to the operator's own city. The row would return *whoever
   runs it* — unreproducible across operators, and not a property of the field.
2. **Headline keywords do not predict published work.** Deep-reading the strongest candidate
   (highest follower count, headline naming harness engineering) loaded **120 posts**; **2** were
   on-topic. The rest was company marketing for an unrelated product.

Decisive comparison: **none of the three authors the content search found appeared anywhere in the
person-search results.** They sit outside the operator's network, which is exactly where content
search reaches and person search cannot.

**Instead:** the existing content row's keywords were broadened (above). Full evidence in
[`plans/20260906_1259-c11-x-linkedin-baseline.md`](https://github.com/lucagattoni/Claude-Loops/blob/main/plans/20260906_1259-c11-x-linkedin-baseline.md).

One finding was kept from the exercise: **"loop engineering" has crossed into résumé vocabulary** —
it appears in LinkedIn headlines and skills sections across at least four countries, held by people
who publish nothing on it. That is evidence about the term's diffusion, not a source lead. No
individual is named: this repo is public and they are private individuals.

---

## Adding new sources

Add a row if a general search surfaces someone who:
- Published ≥ 2 pieces specifically on loop engineering, agentic AI, Claude Code, or MCP
- Has meaningful audience engagement (quality over follower count)
