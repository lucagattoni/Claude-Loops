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
| The Batch (DeepLearning.AI) | rss | https://www.deeplearning.ai/the-batch/feed/ | Andrew Ng's weekly newsletter; recurring loop engineering / agentic coverage (e.g. "Loop Engineering for 0-to-1 Product Development", Jun 2026) |
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
| MindStudio Blog | html | https://www.mindstudio.ai/blog | Published 3+ loop engineering articles covering loop design, agent harness architecture, and verification patterns (Jun 2026) |
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
| orobsonn/claude-harness | github | https://github.com/orobsonn/claude-harness | "Strong eyes, cheap hands" cost-asymmetric maker/checker (Ollama writes, Opus judges); content-hashed frozen tests before impl; independent completion capture (Jun 2026) |
| affaan-m/ecc | github | https://github.com/affaan-m/ecc | Flagship multi-harness "agent operator system" (224k★): eval-harness (pass@k/pass^k, 3 grader types), verification-loop, /loop-start, instinct learning; watch for focused loop-engineering skills (Jun 2026) |
| krishddd/Strive_Engineering | github | https://github.com/krishddd/Strive_Engineering | Provenance-bound verification: every finding cites a git SHA re-checked via `git cat-file` (loopguard), majority_vote blocks self-grading, L0-L3 autonomy ladder; isomorphic-perturbation verifier (Jun 2026) |
| Happenmass/Cliclaw | github | https://github.com/Happenmass/Cliclaw | Cross-model maker/checker (Claude implements / Codex reviews) over tmux; auto-continue gate model, tmux-pane state scraping (hook-free), two-tier hybrid memory; 107★ (Jun 2026) |
| firegnu/herdr-loop-lab | github | https://github.com/firegnu/herdr-loop-lab | Three-layer (inner/fleet/epic) cross-model adversarial judge + mechanical gate; exit-code stop contracts (0/2/3), stateless worktree rounds, AC-N acceptance criteria (Jun 2026) |
| arXiv — harness/loop research | rss | http://export.arxiv.org/api/query?search_query=all:%22agent+harness%22+OR+%22loop+engineering%22+OR+%22self-improving+harness%22&sortBy=submittedDate&sortOrder=descending&max_results=30 | arXiv Atom API; primary source for harness-engineering research (Self-Harness 2606.09498, AHE 2604.25850, HarnessX 2606.14249). Added Jul 2026 after 3 arXiv findings in one run |
| peterCheng123321/loop-engineering | github | https://github.com/peterCheng123321/loop-engineering | Convergence layer over /loop, ralph-loop, Agent SDK loops; progress.md as DP "memo table" — cache solved steps, prune failed branches, survive compaction (Jul 2026) |
| Sungmin-Cho/claude-deep-loop | github | https://github.com/Sungmin-Cho/claude-deep-loop | Control-plane/execution-plane split: kernel is sole authorized writer, skill agents read-only and write via kernel subcommands; content-hash-anchored state + append-only events across sessions (Jul 2026) |
| shouryasrivastava/ctxcarry | github | https://github.com/shouryasrivastava/ctxcarry | "Repo owns your context, not the agent": local-first .ctxcarry/ durable memory, worktree generators, evaluators-assume-broken, token-budgeted multi-tool handoff (Jul 2026) |
| the-open-engine/zeroshot | github | https://github.com/the-open-engine/zeroshot | ~1.6k★; blind validation / information-asymmetry reviewers — validators see only outputs, never the maker's reasoning; anti-collusion reject-and-retry until all approve (Jul 2026) |

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
| `github-search` | WebFetch the GitHub API URL (returns JSON) → parse `items[].full_name`, `description`, `updated_at`, `stargazers_count` → score against keyword tiers → for high-scoring repos WebFetch the raw README URL and summarise; check `updated_at > last_run_date` to flag new/recently-active repos |

---

## Adding new sources

Add a row if a general search surfaces someone who:
- Published ≥ 2 pieces specifically on loop engineering, agentic AI, Claude Code, or MCP
- Has meaningful audience engagement (quality over follower count)
