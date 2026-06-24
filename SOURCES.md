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

| Actor | Type | Handle / URL | Notes |
|---|---|---|---|
| Anthropic | rss | https://www.anthropic.com/rss.xml | Primary source for Claude Code updates |
| Boris Cherny | x | @bcherny | Creator of Claude Code; coined "write loops" |
| Andrej Karpathy | x | @karpathy | Influential ML researcher |
| Andrew Ng | x | @AndrewYNg | Agentic AI education |
| OpenAI | html | https://openai.com/news | RSS blocked (403); scrape news index |
| Addy Osmani | rss | https://addyosmani.com/rss.xml | Co-defined loop engineering |
| Simon Willison | rss | https://simonwillison.net/atom/entries/ | LLM tooling practitioner |
| Swyx | x | @swyx | AI engineering community |
| swyx.io | html | https://www.swyx.io/writing | AI engineering long-form posts |
| The New Stack | rss | https://thenewstack.io/feed/ | Active loop engineering coverage |
| Sabrina Ramonov | html | https://www.sabrina.dev | Loop engineering + /goal + Routines (Jun 2026) |
| Sabrina Ramonov | x | @Sabrina_Ramonov | Active X presence posting loop engineering definitions and techniques (Jun 2026) |
| Cobus Greyling | rss | https://cobusgreyling.substack.com/feed | Loop Engineering Substack + GitHub repo |
| Peter Steinberger | x | @steipete | Creator of OpenClaw; "designing loops" framing |
| Lenny's Newsletter (Claire Vo) | rss | https://www.lennysnewsletter.com/feed | Four-type loop taxonomy article; high-engagement AI practitioner audience (Jun 2026); Substack RSS |
| Cobus Greyling loop-engineering | github | https://github.com/cobusgreyling/loop-engineering | Reference implementation and patterns repo; watch for new docs, examples, and releases |
| The Rundown AI | rss | https://www.therundown.ai/feed | Daily AI newsletter (Beehiiv); scan for loop engineering / agentic workflow coverage |
| TLDR AI | rss | https://tldr.tech/ai/rss | Daily AI digest RSS; scan for Claude Code, agent loop, agentic workflow coverage |
| Ben's Bites | rss | https://bensbites.beehiiv.com/feed | Daily AI news digest RSS; scan for loop engineering / agent loop coverage |
| AI Breakfast | rss | https://aibreakfast.beehiiv.com/feed | Daily AI newsletter (Beehiiv RSS); scan for agentic workflow and Claude Code coverage |
| X search — loop engineering | x-search | https://x.com/search?q=loop%20engineering&src=typed_query&f=live | Live keyword search; dynamically loaded — scroll ≥3 times to surface 20+ posts |
| LinkedIn search — loop engineering | linkedin | https://www.linkedin.com/search/results/content/?keywords=loop+engineering | Professional community posts; dynamically loaded — scroll ≥3 times to surface 20+ posts |
| Harness Books (AgentWay) | html | https://harness-books.agentway.dev | Essay collection on harness design theory — unstable components, ledger closure, input governance, reactive compact |
| GitHub search — loop engineering claude | github-search | https://github.com/search?q=%22loop+engineering%22+claude&type=repositories&sort=updated | Search GitHub repos combining "loop engineering" + claude; find new implementations and patterns |
| GitHub search — claude code harness | github-search | https://github.com/search?q=%22claude+code%22+harness&type=repositories&sort=updated | Search GitHub repos combining "claude code" + harness; surface new harness design repos |

---

## Type reference

| Type | Fetch strategy |
|---|---|
| `x` | Chrome → search `from:<handle> (<tier1-tier2-query>)` in X.com search; also scan profile's recent posts |
| `rss` | WebFetch feed URL → parse `<item>` / `<entry>` → score against keyword tiers |
| `html` | WebFetch page URL → extract article links + snippets → score against keyword tiers |
| `github` | WebFetch repo URL + `/commits/main` → score new commits since `last_run_date`; also check `/releases` for tagged releases |
| `x-search` | Chrome → navigate to the search URL → scroll down ≥3 times to load 20+ posts → read all posts → score against keyword tiers |
| `linkedin` | Chrome → navigate to the search URL → scroll down ≥3 times to load 20+ posts → use JavaScript to extract post text → score against keyword tiers; WebFetch any linked Pulse articles for Tier 1/2 matches |
| `github-search` | WebFetch the search URL → parse repo titles, descriptions, star counts → score against keyword tiers → for high-scoring repos WebFetch README for summary; also check if repo was updated since `last_run_date` |

---

## Adding new sources

Add a row if a general search surfaces someone who:
- Published ≥ 2 pieces specifically on loop engineering, agentic AI, Claude Code, or MCP
- Has meaningful audience engagement (quality over follower count)
