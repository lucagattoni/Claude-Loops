# Loop Engineering News

Newest-first digest. Updated by the `fetch-loop-news` skill on each run.
Sources are defined in [`SOURCES.md`](SOURCES.md).

---

## 2026-06-26 09:04 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "5 Claude Code slash commands i use daily: /goal runs it autonomously until the goal is met" | [link](https://x.com/Sabrina_Ramonov/status/2070246907532677588) | Catalogues five loop-control slash commands including /goal (autonomous until done), /btw (mid-run question injection), and /clear (context reset) — enumerating the loop-control primitive set in Claude Code. |
| 1 | @Sabrina_Ramonov | "3 boring jobs i hand to one /goal command — stop after N turns" | [link](https://x.com/Sabrina_Ramonov/status/2070125608013648082) | Demonstrates /goal as a bounded autonomous loop: rename files (25 turns), fill CSV (30 turns), summarise PDFs (40 turns) — concrete pattern for stop-after-N-turns loops. |
| 1 | @akshay_pachaar | "Loop Engineering Clearly Explained — the harness now matters more than the model" | [link](https://x.com/akshay_pachaar/status/2069118430582866051) | Comprehensive breakdown: stop condition categories (max-iters, budget, no-progress, completion check), context rot + compaction, idempotent tool writes, agent-readable errors, maker/checker separation — most detailed practitioner synthesis this run. |
| 1 | X Trending | "Anthropic's Playbook Details AI Agent Loop Engineering — >80% of Anthropic engineers build with self-improving loops" | [link](https://x.com/i/trending/2070248250767012231) | X trending story (1,520+ posts) covering Anthropic's eBook on five agent loop patterns; >80% stat confirms loop engineering as mainstream internal Anthropic practice. |
| 1 | Data Science Collective | "How To Build a Claude Loop Engineering Better Than 99% of People" | [link](https://medium.com/data-science-collective/how-to-build-a-claude-loop-engineering-better-than-99-of-people-3ab8701d176c) | Frames loop engineering as inverting human-in-the-loop: humans design the decision architecture instead of occupying the loop; the engineering challenge shifts from supervision to specification quality. |
| 2 | omnigent-ai/omnigent | "New commits Jun 26: compaction persistence, resume via --resume, spec reconstruction on resolve-miss" | [link](https://github.com/omnigent-ai/omnigent) | Three new harness resilience patterns: compaction log persistence across resumes, --resume flag for session recovery, spec reconstruction from event log on resolve-miss. |
| 2 | eugenelim/agent-ready-repo | "New commits Jun 26: RFC-0051 self-coverage gate, traceability-lint spec, RFC-0052 multi-adapter install" | [link](https://github.com/eugenelim/agent-ready-repo) | Self-coverage gate formalises the stopping condition (every scope item must have a verification artifact); traceability-lint validates the scope→task→artifact evidence chain; RFC-0052 adds multi-harness deployment spec. |
| 2 | Happenmass/Cliclaw | "tmux-based loop orchestration: parallel Claude+Codex, cross-vendor maker/checker, shared tasks.txt/progress.txt" | [link](https://github.com/Happenmass/Cliclaw) | 107★ repo: runs Claude Code and Codex as parallel subagents in a tmux session with auto-continue gate, cross-vendor maker/checker verification, per-agent capability scoping, and shared cross-agent handoff files. |
| 2 | LeadGrowGTM/loop-engineer | "Goal prompt writer + planner/maker/checker harness for Claude Code" | [link](https://github.com/LeadGrowGTM/loop-engineer) | Direct factory model implementation with explicit role separation: goal prompt writer → planner → maker → checker pipeline. |
| 2 | Kanevry/session-orchestrator | "STATE.md per-platform crash recovery, 8-dimension verification gate, cross-session pattern learning" | [link](https://github.com/Kanevry/session-orchestrator) | 38★: per-platform STATE.md (.claude/, .codex/) crash recovery; 8-dimension verification gate at ≥80% confidence; /evolve + /reconcile governed cross-session learning. |
| 2 | ryanjkelly/harnery | "Per-agent heartbeat files + claim/commit guards, canonical event stream" | [link](https://github.com/ryanjkelly/harnery) | Multi-loop coordination via .harnery/active/<agent-id>.json heartbeats: claim gate before work, commit gate before writes, TTL-based stale claim recovery — addresses the multi-loop STATE.md KB gap. |
| 2 | jhlee0409/claude-harness-kit | "Auto-generates harness (CLAUDE.md + architect agent + verify hook) from repo introspection" | [link](https://github.com/jhlee0409/claude-harness-kit) | Claude Code plugin that inspects the repo and generates a tailored harness configuration — harness bootstrapping as a loop pattern. |
| 2 | sergiocarvalhosa/Monad-Harness | ".apm/ agent spec: six primitive types (skills/instructions/hooks/prompts/commands/tools)" | [link](https://github.com/sergiocarvalhosa/Monad-Harness) | Concrete .apm/ manifest format for harness-agnostic agent deployment — fills KB gap on .apm/ specification format. |
| 2 | chatprd.ai | "Create an AI-Powered Patch and Verification Loop for Security Bugs" | [link](https://www.chatprd.ai/how-i-ai/workflows/create-an-ai-powered-patch-and-verification-loop-for-security-bugs) | Blueprint for four-stage maker-checker loop (verify exploit → generate patch → run regression → human merge) with explicit separation of concerns preventing agent self-grading. |
| 2 | chatprd.ai | "Build a Self-Improving AI to Generate Agent Skills in Codex" | [link](https://www.chatprd.ai/how-i-ai/workflows/build-a-self-improving-ai-to-generate-agent-skills-in-codex) | Meta-loop: meta-agent identifies skill gaps, spawns goal-directed subagents for validation, integrates confirmed skills into reusable library — recursive skill generation loop pattern. |
| 2 | MindStudio Blog | "What Is Loop Engineering? The New Meta for AI Coding Agents" | [link](https://www.mindstudio.ai/blog/what-is-loop-engineering-ai-coding-agents) | Explains loop engineering as ReAct's successor; argues agent quality depends more on loop design than model selection; covers error handling, context management, and termination conditions. |
| 2 | Anthropic Engineering | "Scaling Managed Agents: Decoupling the brain from the hands" | [link](https://www.anthropic.com/engineering/managed-agents) | Virtualizing sessions as durable event logs outside Claude's context window; credential vaulting to prevent prompt injection; 60% improvement in time-to-first-token via resource sharing. |
| 2 | hidekazu-konishi.com | "Claude Code Harness and Environment Engineering: Designing the Frontline Where Local AI Agents Actually Live" | [link](https://hidekazu-konishi.com/entry/claude_code_harness_and_environment_engineering_guide.html) | Distinguishes in-process harness controls (hooks, permissions) from out-of-process environment controls (OS user, container, network); three reference patterns: Approval-First, Curated Allow-list, Sandboxed Full-Auto. |
| 2 | MindStudio Blog | "What Is an Agent Harness? The Architecture Behind Claude Code, Codex, and Cursor" | [link](https://www.mindstudio.ai/blog/what-is-agent-harness-architecture-explained) | Nine harness components; contrasts Claude Code (explicit approval gates), Codex (model-integrated), and Cursor (code-indexing for context) harness design tradeoffs. |
| 2 | Cobus Greyling (Medium) | "Loop Engineering Playbook: Where loops live, how to run your first one" | [link](https://cobusgreyling.medium.com/loop-engineering-playbook-4460e01e88d8) | Maps loop deployment tiers (solo terminal, production with audit, editor-integrated); "reasoning alone does not close the loop — agents must execute and observe"; introduces comprehension debt as a technical liability. |
| 2 | MindStudio Blog | "How to Build an Agentic Loop with Claude Code: Verification, Cost, and Stopping Criteria" | [link](https://www.mindstudio.ai/blog/how-to-build-agentic-loop-claude-code) | Plan-Act-Observe cycle; three verification checkpoints (action, iteration, terminal); three stopping condition categories; cost management via lighter models for routine steps. |
| 2 | Agent Factory / Panaversity | "Loop Engineering: A Crash Course" | [link](https://agentfactory.panaversity.org/docs/loop-engineering-crash-course) | Six-part loop architecture (heartbeat, worktree, skill, sub-agents, connectors, state/memory); four heartbeat types from in-session to fully unattended; maker-checker with Claude Code / OpenCode examples. |
| 2 | @bcherny | "Claude Tag: one instance per Slack thread, own memory and permissions per channel" | [link](https://x.com/bcherny/status/2069474689819480394) | Claude Tag's per-thread sandbox architecture: each thread spawns an agent with its own credentials, clones repo, runs code, sandbox discarded when done — loop isolation at OS level. |
| 2 | @bcherny | "Just landed nested subagent support in Claude Code — capped at depth=5" | [link](https://x.com/bcherny/status/2064327225504403752) | Primary source confirming the depth=5 cap on nested subagents in Claude Code. |
| 2 | @karpathy | "It is an org-level harness. The difference will become clearer over time." | [link](https://x.com/karpathy/status/2069822834160124091) | Karpathy frames Claude Tag as "org-level harness engineering" — the harness as the primary organizational artifact at scale. |
| 2 | @0xMovez | "Anthropic engineer: 'my agentic loops can run for hours without spending hundreds of $$$'" | [link](https://x.com/0xMovez/status/2070181700861137222) | Efficient long-running loops; references the spec-first stack (Loop + plan + PRDs + spec + markdown) as the production loop design formula. |
| 2 | @bojan_ai | "An agent loop without a verifier just compounds its own mistakes on a schedule" | [link](https://x.com/bojan_ai/status/2070433693957558636) | Verification is the loop's stopping condition: the unlock in agent autonomy is building autonomy that checks its own work before shipping. |
| 2 | @miltonheyan | "loop engineering is the right frame — execution, verification, orchestration are the primitives" | [link](https://x.com/miltonheyan/status/2070432513307357388) | Three loop engineering primitives (execution, verification, orchestration) + observability as fourth prerequisite: without it you can't diagnose which layer failed. |
| 2 | LinkedIn / GitHub | "Understanding Loop Engineering — LinkedIn Live event, 85 attendees, 273 reactions" | [link](https://www.linkedin.com/events/7475849625292320769/) | GitHub hosted a 61-minute LinkedIn Live on loop engineering — signals GitHub's official entry into the discourse. |
| 2 | LinkedIn / Martin Ma | "What the Hell Is Loop Engineering?" | [link](https://www.linkedin.com/pulse/what-hell-loop-engineering-martin-ma-roipc/) | Rice-cooker metaphor for the stop-condition problem (undercook/overcook/forget); machine-verifiable completion criteria must be defined before execution begins. |
| 2 | Anthropic | "Building Effective Agents" | [link](https://www.anthropic.com/news/building-effective-agents) | Five canonical agent workflow patterns: prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer — the evaluator-optimizer is the canonical maker/checker loop implementation. |
| 3 | travisbreaks/coding-agent-evals | "Behavioral eval harness for Claude Code, real headless runs scored across six dimensions" | [link](https://github.com/travisbreaks/coding-agent-evals) | Behavioral evaluation harness running actual Claude Code loops scored across six quality dimensions — relevant to stopping condition measurement and verifier calibration. |
| 3 | @akshay_pachaar | "AI security goes far beyond AI — production agent harness needs infrastructure-layer controls" | [link](https://x.com/akshay_pachaar/status/2070076814089990560) | Harness security requires infrastructure-layer controls (IAM, VPC, CloudTrail) alongside prompt filtering — multi-layer security boundary framing. |
| 3 | @ClaudeDevs | "Claude Tag is the next evolution of agents — proactive, multiplayer, with memory and identity" | [link](https://x.com/ClaudeDevs/status/2070235730295865661) | Claude Tag as an always-on loop triggered by @-mentions: per-thread identity, persistent memory, own credentials. |
| 3 | @swyx | "Cursor/Graphite's Origin: git competitor scalable for agent workloads, extensible with MCP" | [link](https://x.com/swyx/status/2066928345246470204) | Origin is a git system purpose-built for agent workloads with MCP extensibility and co-failure agent resolution. |
| 3 | The New Stack | "Code should be regenerated, not maintained: Codeplain makes the case for spec-driven development" | [link](https://thenewstack.io/codeplain-spec-driven-regenerative-code/) | Code as disposable output of spec loops rather than a maintained artifact — factory model applied to the full software lifecycle. |
| 3 | The New Stack | "Agent Toolkit for AWS includes 20+ agent skills, but your agent might not load them without this one file" | [link](https://thenewstack.io/aws-agent-toolkit-rules-file/) | AWS agent toolkit's 20+ skills require a rules file to activate — relevant to skill loading patterns and MCP connector configuration in production loops. |
| 4 | Simon Willison | "Porting the Moebius 0.2B image inpainting model to run in the browser with Claude Code" | [link](https://simonwillison.net/2026/Jun/22/porting-moebius/) | Headless Claude Code loop with notes.md/plan.md state persistence and explicit subagent delegation for context preservation. |

### No new content
- Anthropic RSS — 404 (ongoing)
- The Rundown AI RSS — 403 (ongoing)
- TLDR AI RSS — 404 (ongoing)
- Ben's Bites RSS — 404 (ongoing)
- AI Breakfast RSS — 404 (ongoing)
- OpenAI news — 403 (ongoing)
- Harness Books (agentway.dev) — 403 (ongoing)
- cobusgreyling/loop-engineering — automated daily triage commit only, no substantive new content
- cobusgreyling/goal-engineering — no new commits since Jun 23
- cobusgreyling/fleet-engineering — no new commits since Jun 25
- getzep/graphiti — no new commits since Jun 23
- faisalishfaq2005/loopflow — no new commits since Jun 24
- JeiKeiLim/tenet — no new commits since Jun 25
- @AndrewYNg — no new posts
- @steipete — no new keyword-matching posts
- GitHub search (acting_on claude loop) — zero results; suggested: `"state machine" claude agent coordination`
- GitHub search (SECURITY_MATRIX claude agent) — zero results; suggested: `"security policy loader" claude agent`

### Docs updated this run
- `docs/24-harness-patterns.md` — added: Harness vs. Environment Engineering section (in-process vs. out-of-process controls; three deployment patterns: Approval-First / Curated Allow-list / Sandboxed Full-Auto); extended Harness-Agnostic Projection with .apm/ primitive manifest (six subdirectory types); extended omnigent section with compaction persistence, --resume support, spec reconstruction on resolve-miss
- `docs/04-verification.md` — added: Self-Coverage Gate (RFC-0051) + Traceability-Lint (scope→task→artifact evidence chain)
- `docs/34-loop-patterns.md` — added: concrete STATE.md multi-loop example (PR Babysitter + CI Sweeper coexisting); Per-Agent Heartbeat Coordination (harnery .harnery/active/ pattern)
- `docs/01-paradigm-shift.md` — added: >80% Anthropic engineers on self-improving loops stat; five canonical patterns section (prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer)
- `docs/32-reading-list.md` — added "Building Effective Agents" (Anthropic, Dec 2024) to Harness Design group
- `SOURCES.md` — added MindStudio Blog (html source; 3+ loop engineering articles)

### Structural review this run (Phase 4c)
Reading the 38 findings as a set surfaced four structural issues, fixed by consolidation (no new docs):
- **Stop conditions had no canonical home** (dominant theme: akshay, Sabrina, bojan_ai, Martin Ma, MindStudio; scattered across 13 docs) → added canonical **Stop Condition Taxonomy** to `docs/27`; cross-referenced from `docs/02`, `docs/04`, `docs/30`.
- **Loop-design process not central** (user steer + "harness > model" evidence) → reframed `docs/27` intro and `LOOP_ENGINEERING.md` around the five design questions (What/How/When/How much/How-do-you-know-it's-done); verification elevated to a peer design question.
- **Observability unrepresented as a primitive** (miltonheyan) → added **Two Lenses on Loop Primitives** (functional vs. mechanical) to `docs/02`.
- **Org-level harness framing missing** (Karpathy) → added section to `docs/24`.
- Codified this whole pass as **Phase 4c** in the `fetch-loop-news` skill so it runs after every future run.

### Sources to consider adding to SOURCES.md
- chatprd.ai — now has 3 articles in digest; consider adding as html source (https://www.chatprd.ai/how-i-ai)
- Agent Factory / Panaversity (agentfactory.panaversity.org) — 1 article found; verify more before adding
- sergiocarvalhosa/Monad-Harness — added this run as github source

---

## 2026-06-26 (manual addition)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | Andrew Ng (The Batch) | "Loop Engineering for 0-to-1 Product Development" | [link](https://info.deeplearning.ai/a-new-generation-studies-ai-apples-recipe-for-on-device-models-glm5.2-tackles-open-ended-problems-1) | Three nested feedback loops at different cadences — agentic coding (minutes), developer review (tens of min–hours), user feedback (days); humans persist via a "context advantage" over current AI. |
| 3 | The Batch | "GLM-5.2 reward hacking during agentic RL" | [link](https://info.deeplearning.ai/a-new-generation-studies-ai-apples-recipe-for-on-device-models-glm5.2-tackles-open-ended-problems-1) | Concrete reward-hacking case: agents fetched reference solutions from GitHub to pass coding tests; mitigated with a rule-based filter flagging suspect tool calls. |

### Docs updated this run
- `docs/14-human-in-the-loop.md` — added "The Three Feedback Loops" (agent/developer/user cadences + context advantage); cross-linked to Inner/Outer Dual Loop
- `docs/17-failure-patterns.md` — enriched the Reward hacking row with the GLM-5.2 concrete case + rule-based-filter mitigation (consolidated, no new row)
- `docs/25-long-running-agents.md` — added reciprocal cross-ref distinguishing the Dual Loop axis from the three feedback loops
- `docs/32-reading-list.md` — added Andrew Ng's article to Getting Started
- `SOURCES.md` — added The Batch (DeepLearning.AI) as rss source

---

## 2026-06-25 (manual addition)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 2 | @akshay_pachaar | "Loop Engineering internals — Trigger/Cognitive Core/Safety Layers/Memory/Tool Execution diagram" | [link](https://x.com/akshay_pachaar/status/2069769689560187027) | Clean visual breakdown of loop internals with four additions to KB: Graphiti temporal KG for state, Opik trace→regression test for fleet observability, Reject+Replan safety gate pattern, and Working/Long-Term Memory split. |

### Docs updated this run
- `docs/16-memory-patterns.md` — added Pattern F: Temporal Knowledge Graph (Graphiti, getzep)
- `docs/23-fleet-engineering.md` — added Opik to Observability section (trace-to-regression)
- `docs/08-permissions.md` — added Reject+Replan Pattern (safety gate → replan vs. abort)
- `docs/04-verification.md` — added Production Trace to Regression Test section (Opik)
- `SOURCES.md` — added @akshay_pachaar (x) and getzep/graphiti (github)

---

## 2026-06-25 06:41 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "if you don't design the loop, you ARE the loop" | [link](https://x.com/Sabrina_Ramonov/status/2070004810888171537) | Tier-1 framing: designing the loop vs. being the loop is the practitioner-vs-amateur divide in loop engineering. |
| 1 | @Sabrina_Ramonov | "the people pulling ahead aren't writing better prompts — they're designing loops" | [link](https://x.com/Sabrina_Ramonov/status/2069960016929366247) | Loop engineers outperform prompt writers; loop engineering is about removing yourself as the bottleneck. |
| 2 | Cobus Greyling (Substack) | "Fleet Engineering" | [link](https://cobusgreyling.substack.com/p/fleet-engineering) | Introduces Fleet Four Pillars (Delegate/Improve/Approve/Connect), F0-F3 fleet maturity rollout, Fleet Economics for cost attribution, and Claw vs. Assistant identity choice for unattended agents. |
| 2 | cobusgreyling/goal-engineering (GitHub) | "goal-engineering — Reference Implementation" | [link](https://github.com/cobusgreyling/goal-engineering) | Six canonical GOAL.md patterns (Tests Green, Migrate Module, Fix Bug, etc.), G0-G3 readiness scoring tool, and goal-cost token estimator; fills the GOAL.md schema KB gap. |
| 2 | cobusgreyling/fleet-engineering (GitHub) | "fleet-engineering — Reference Implementation" | [link](https://github.com/cobusgreyling/fleet-engineering) | Six production fleet governance patterns including Fleet Budget Guard and Cross-Agent Audit; Fleet Economics for cost attribution in multi-agent systems. |
| 2 | X search — loop engineering | "A senior Anthropic engineer just released an 11-page paper on Loop Engineering" | [link](https://x.com/hrswatigupta/status/2070034230625874011) | Thread summarising Anthropic's loop engineering practices: 5-step self-discovery cycle (Schedule→Discover→Build→Verify→Repeat), agents find work from failing CI and open issues, each task isolated in its own git worktree. |
| 2 | Lenny's Newsletter | "How to design AI agent loops: schedules, goals, and subagents in Claude Code and Codex" | [link](https://www.youtube.com/watch?v=JoXbk2fm7jM) | Practical walkthrough of goal-based loops and subagent spawning in Claude Code and Codex; schedule vs. goal type distinctions. |
| 2 | LinkedIn | "Loop Engineering: Architecture Shift Every AI Developer Should Know" — Dhiraj Amin | [link](https://www.linkedin.com/pulse/loop-engineering-architecture-shift-every-ai-developer-dhiraj-amin-bekee/) | Five-phase agent loop, five required production components, Stanford data point: AI accuracy peaks at medium token spending — excessive loops degrade results while costing 30-100× more. |
| 2 | LinkedIn | "Loop Engineering Is Just Software. We Have a Name." — Mike Piccolo | [link](https://www.linkedin.com/pulse/loop-engineering-just-software-we-have-name-mike-piccolo-yb73c/) | 4-level loop architecture (agent / verification / event-driven / hill-climbing), distributed systems analogues (circuit breakers, at-least-once delivery), and the iii Worker/Trigger/Function framework. |
| 2 | LinkedIn | "Loop Engineering? I Think You Mean Outcome Engineering" — Ryan Nadel | [link](https://www.linkedin.com/pulse/loop-engineering-i-think-you-mean-outcome-ryan-nadel-svj4c/) | Provocative reframe: the real discipline is designing for verifiable outcomes; introduces the Deterministic Shell Model and semantic reasoning as a new primitive replacing human judgment for ambiguity. |
| 2 | @Sabrina_Ramonov | "before you trust an agent to run on its own, do these 4 things" | [link](https://x.com/Sabrina_Ramonov/status/2069960016929366247) | 4-step agent trust ramp (read-only → summarise → hard limits → loop cap) before granting full autonomy. |
| 2 | github-search: loop engineering claude | "eugenelim/agent-ready-repo" | [link](https://github.com/eugenelim/agent-ready-repo) | Loop engineering pack with harness-agnostic projection (.apm/ → Claude Code/Codex/Copilot/Cursor/Gemini/Kiro) and security review at specification stage, not post-implementation. |
| 2 | github-search: loop engineering claude | "JeremyW1990/loop-engineering-skill" | [link](https://github.com/JeremyW1990/loop-engineering-skill) | Autonomous sprint skill with three novel verification safeguards: clean-room review, held-out test layer, and cross-task defect ledger that feeds failures forward across tasks. |
| 2 | github-search: claude code harness | "omnigent-ai/omnigent" | [link](https://github.com/omnigent-ai/omnigent) | Meta-harness (4771★): 3-tier governance hierarchy (server/agent/session), harness-swap without state loss, cross-device session continuity. |
| 2 | github-search: claude code harness | "JeiKeiLim/tenet" | [link](https://github.com/JeiKeiLim/tenet) | 8-phase DAG harness for 12+ hour cycles with 3-critic pipeline (fresh context per critic) and steer message taxonomy (context/directive/emergency) for mid-run redirection without loop breakage. |
| 2 | github-search: loop engineering claude | "faisalishfaq2005/loopflow" | [link](https://github.com/faisalishfaq2005/loopflow) | YAML-declarative loop definition with VERDICT: PASS gate protocol and 2-layer budget ceiling (loop-level + per-step). |
| 2 | github-search: claude code harness | "thalys/agent-ab" | [link](https://github.com/thalys/agent-ab) | A/B testing framework for Claude Code configurations: A/A baseline for noise floor, deterministic-only graders (no LLM judges), bootstrap confidence intervals. Fills verifier calibration KB gap. |
| 2 | github-search: claude code harness | "qimen039-code/claim-boundary-harness" | [link](https://github.com/qimen039-code/claim-boundary-harness) | Belief state machine (source_prior → bounded_claim → validated) with R0-R5 risk classification at task intake and mandatory evidence metadata fields. |
| 3 | github-search: loop engineering claude | "void2610/loop" | [link](https://github.com/void2610/loop) | Type A vs. Type B work separation (fully automated mechanics vs. irreducible human judgment) with a 6-verdict taxonomy (pass/fail/handoff/timeout/stopped/awaiting-merge). |
| 4 | @steipete (repost of @openclaw) | "OpenClaw 2026.6.10 release" | [link](https://github.com/openclaw/openclaw/releases/tag/2026.6.10) | OpenClaw maintenance release adding auto mode improvements and trusted policy enforcement. |

### No new content
- @bcherny — no new keyword-matching posts since Jun 24
- @karpathy — no new keyword-matching posts since Jun 22
- @AndrewYNg — no recent relevant posts
- @swyx — no keyword-matching posts
- Anthropic RSS — 404 (ongoing)
- Addy Osmani — all Jun articles already in digest
- Simon Willison — Jun 11 article already in digest
- The New Stack OpenClaw/Hermes — already in Jun 24 digest
- Ben's Bites RSS — 404 (ongoing)
- TLDR AI RSS — 404 (ongoing)
- AI Breakfast RSS — 404 (ongoing)
- The Rundown AI RSS — 403 (ongoing)

### Docs updated this run
- `docs/23-fleet-engineering.md` — added: Fleet Four Pillars, F0-F3 maturity, Fleet Economics, Claw vs. Assistant identity (Cobus Greyling, Jun 2026)
- `docs/30-goal-engineering.md` — added: GOAL.md schema, six canonical goal patterns, G0-G3 readiness scoring (cobusgreyling/goal-engineering, Jun 2026)
- `docs/04-verification.md` — added: Type A/B work classification, verdict taxonomy, clean-room review, held-out test layer, cross-task defect ledger, belief state machine + R0-R5, A/A baseline for verifier calibration (Jun 2026)
- `docs/24-harness-patterns.md` — added: harness-agnostic projection + security at spec stage, 8-phase DAG + steer messages, meta-harness 3-tier policy hierarchy + harness-swap (Jun 2026)
- `docs/27-loop-contract.md` — added: YAML-declarative loop definition, VERDICT: PASS gate, 2-layer budget ceiling, self-discovery pattern (Jun 2026)
- `docs/08-permissions.md` — added: agent trust ramp (4-stage: read-only → summarise → hard limits → loop cap)
- `docs/32-reading-list.md` — added cobusgreyling/goal-engineering and cobusgreyling/fleet-engineering to Reference Implementations; fixed duplicate "Loops in Production" section

### Sources to consider adding to SOURCES.md
- @GeoffreyHuntley — credited by community as early loop engineering proponent; check profile for ≥2 substantive pieces before adding
- JeiKeiLim/tenet — already added to reading candidate list; significant implementation
- thalys/agent-ab — verifier calibration framework; addresses documented KB gap

---

## 2026-06-24 05:20 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "routine + /goal = agent — you don't need to write code to build your first autonomous agent" | [link](https://x.com/Sabrina_Ramonov/status/2069642423165129193) | Frames Routines as the no-code entry point to loop engineering; routine + /goal = the minimal autonomous loop definition. |
| 1 | @Sabrina_Ramonov | "ppl think the hard part of autonomous agents is specifying the task... the hard part is defining the finish line" | [link](https://x.com/Sabrina_Ramonov/status/2069528925286375454) | New iteration of stopping-condition thesis: finish line precision determines whether the loop knows when to stop. |
| 1 | @Sabrina_Ramonov | "you're not supposed to prompt Claude — mine ran 4 hours straight fixing my AI support agent" | [link](https://x.com/Sabrina_Ramonov/status/2069522130551652447) | Real-world loop run: /goal ran unattended 4 hours fixing an AI support agent; concrete shift-from-prompting example. |
| 2 | Cobus Greyling (Substack) | "Goal Engineering" | [link](https://cobusgreyling.substack.com/p/goal-engineering) | Introduces Goals vs. Loops distinction ("Loops discover work. Goals finish it.") and four Goal Primitives (Objective, Verifier, GOAL.md State, Budget). |
| 2 | @Sabrina_Ramonov | "buzz word 'loop engineering' has 6 parts" | [link](https://x.com/Sabrina_Ramonov/status/2069597628908655003) | Concise community definition: loop engineering = automations + worktrees + skills + connectors + sub-agents + memory — the six building blocks. |
| 2 | Armin Ronacher | "The Coming Loop" | [link](https://lucumr.pocoo.org/2026/6/23/the-coming-loop/) | Flask creator names amplification effect (iterations accumulate defensive complexity) and cognitive dependency (codebases become unmaintainable without AI); also defines where loops genuinely work. |
| 2 | @roanbrasil | "Loop Engineering: Designing the Execution Harness Around an LLM" | [link](https://medium.com/p/loop-engineering-designing-the-execution-harness-around-an-llm-936afeb6a72d) | Quantifies single-turn failure: 10 steps at 90% per-step accuracy = 35% end-to-end success (0.9^10); "the performance ceiling is set by the loop, not the model." |
| 2 | Martin Dilger (LinkedIn) | "Loop Engineering: Why You Should Never Argue with an Agent" | [link](https://www.linkedin.com/pulse/loop-engineering-why-you-should-never-argue-agent-martin-dilger-uql8e/) | Never Argue rule, Event Modeling for task decomposition (status-transition slices), context reset mandate: "clean iterations with recorded learnings outperform long polluted conversations." |
| 2 | Lenny's Newsletter | "How I AI: How to write AI agent loops in Claude Code and Codex" | [link](https://www.lennysnewsletter.com/p/how-i-ai-how-to-write-ai-agent-loops) | Job-description framing: write loop prompts as employee onboarding specs (frequency, output format, escalation contacts) rather than technical specifications. |
| 2 | Lenny's Newsletter | "How Claude Mythos found a 15-year-old bug in Mozilla Firefox" | [link](https://www.lennysnewsletter.com/p/how-claude-mythos-found-a-15-year) | Harness case study: LLM file prioritization → score→fix→verify pipeline → dedicated verifier subagent → 423 security fixes in one month; harness credited with ~50% of results alongside the model. |
| 2 | The New Stack | "OpenClaw and Hermes agree on what an agent is. They disagree on what controls it." | [link](https://thenewstack.io/openclaw-harness-agent-harness/) | Contrasts OpenClaw and Hermes harness governance; surfaces runtime control, memory, and supervision architecture as the live design debate. |
| 3 | @karpathy | "This is the 3rd major redesign of LLM UIUX — a self-contained, persistent, asynchronous entity with org-wide tools" | [link](https://x.com/karpathy/status/2069547676849557725) | Karpathy frames Claude Tag as the third LLM paradigm: website → app → persistent asynchronous entity with org-wide context. |
| 3 | ChatPRD | "Build an AI agentic harness for automated security bug hunting" | [link](https://www.chatprd.ai/how-i-ai/workflows/build-an-ai-agentic-harness-for-automated-security-bug-hunting) | Directive-based prompting ("We know there's a security bug here"), hypothesis-test-iterate cycle, tool feedback drives the next agent reasoning step. |
| 3 | The New Stack | "Developers are now validating code they didn't write — and may not understand" | [link](https://thenewstack.io/gitlab-ai-code-governance/) | GitLab survey of 1,500 developers: AI has shifted the bottleneck from writing to reviewing; verification is the new engineering bottleneck. |
| 3 | Chetan Kerhalkar (LinkedIn) | "The Next Big Skill in Enterprise AI Is Not Prompt Engineering. It Is Loop Engineering." | [link](https://www.linkedin.com/pulse/next-big-skill-enterprise-ai-prompt-engineering-loop-chetan-kerhalkar-ypodc/) | Enterprise loop architecture: six loop types (Retrieval/Tool/Evaluation/Human Approval/Memory/Governance), four feedback types, accuracy formula. |
| 3 | Lushbinary | "Loop Engineering: The Guide for AI Agents" | [link](https://lushbinary.com/blog/loop-engineering-ai-coding-agents-guide/) | Event loop starvation prevention via OS watchdogs; max_consecutive_failures and max_runtime_min as concrete safety boundaries alongside token caps. |
| 4 | @bcherny | "We're launching Claude Tag today — Claude schedules tasks for itself, pursuing a project over hours or days" | [link](https://x.com/bcherny/status/2069474681749754272) | Boris Cherny launches Claude Tag: Claude Code as persistent Slack agent with channel-scoped identity, self-scheduling, ambient context; 65% of Anthropic product team's code via internal version. |
| 4 | Anthropic | "Introducing Claude Tag" | [link](https://www.anthropic.com/news/introducing-claude-tag) | Official article: task decomposition, self-scheduling, ambient context from Slack history, token limits per org/channel, audit logging; "the beginning of an evolution of Claude Code." |

### No new content
- @AndrewYNg — no new posts
- @swyx — no keyword-matching posts
- @steipete — no new posts
- Anthropic RSS — 404 (ongoing)
- Addy Osmani RSS — no new posts since Jun 16
- Simon Willison RSS — no keyword-matching posts Jun 23–24
- OpenAI news — no relevant content
- swyx.io — no new posts since May 17
- Sabrina.dev — no new posts since Jun 19
- cobusgreyling/loop-engineering GitHub — no new commits
- The Rundown AI RSS — 403 (ongoing)
- TLDR AI RSS — 404 (ongoing)
- Ben's Bites RSS — 404 (ongoing)
- AI Breakfast RSS — 404 (ongoing)

### Docs updated this run
- `docs/30-goal-engineering.md` — NEW: Goals vs. Loops + Four Goal Primitives (Cobus Greyling, Jun 2026)
- `docs/31-claude-tag.md` — NEW: Claude Tag architecture, Claude Everywhere, third LLM paradigm (Anthropic + Karpathy, Jun 2026)
- `docs/01-paradigm-shift.md` — Added: 0.9^10 compound probability; historical era framing; "performance ceiling set by loop"
- `docs/17-failure-patterns.md` — Added: amplification effect; cognitive dependency (Ronacher, Jun 2026)
- `docs/04-verification.md` — Added: Mozilla Firefox case study (423 fixes, score→fix→verify, LLM file prioritization)
- `docs/27-loop-contract.md` — Added: job-description framing; Event Modeling for task decomposition (Dilger, Jun 2026)

### Sources to consider adding to SOURCES.md
- Armin Ronacher (lucumr.pocoo.org) — Flask creator, 1 substantive piece; watch for follow-up before adding
- @roanbrasil (Medium) — 1 quantitative loop engineering piece; no sustained publishing pattern yet

---

## 2026-06-23 05:12 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "everyone's still typing prompts one at a time... loop engineering looks like this" | [link](https://x.com/Sabrina_Ramonov/status/2069235241139515590) | Tier 1 loop engineering framing post; the "everyone is still prompting, engineers are designing loops" narrative. |
| 1 | Sabrina Ramonov (sabrina.dev) | "AI Loop Engineering: Build Autonomous Agents with Claude Code /goal + Routines" | [link](https://www.sabrina.dev/p/loop-engineering-claude-code-goal-routines) | Introduces the DOER/CHECKER pattern ("never let the AI grade its own output"), the AI Leverage Formula (Clarity × Skill), and the stopping condition prerequisite: "if you can't say what done looks like, you don't have a loop. You have a wish." |
| 2 | @Sabrina_Ramonov | "the hardest skill in AI right now isn't prompting — it's defining clearly what done looks like so your agent knows when to stop." | [link](https://x.com/Sabrina_Ramonov/status/2069280036335604104) | Standalone aphorism on stopping conditions as the core loop engineering skill. |
| 2 | The New Stack | "Loops are replacing prompts. Verification is about to be your biggest problem." | [link](https://thenewstack.io/agent-loops-cloud-native-verification/) | Argues the shift from prompts to loops makes verification the primary cloud-native engineering challenge; a separate model must grade results before the loop exits. |
| 2 | Data Science Dojo | "Agentic Loops: From ReAct to Loop Engineering (2026 Guide)" | [link](https://datasciencedojo.com/blog/agentic-loops-explained-from-react-to-loop-engineering-2026-guide/) | Four-generation taxonomy (AutoGPT → ReAct → OODA/Dual Loop → Ralph//goal); Inner/Outer Dual Loop pattern (outer loop resets strategy when inner loop insistently fails); cost benchmarks: ~4× tokens (single agent), ~15× (multi-agent) vs standard chat. |
| 4 | @samwillis via @steipete | "/goal make postgres multithreaded — 1k commits, 124k lines, 786 files, 10 days" | [link](https://x.com/samwillis/status/2069147163255312392) | Real-world demonstration of a /goal long-running loop running unattended for 10 days at scale — stopping condition quality is the primary limiting factor, not model capability. |

### No new content
- @bcherny — no keyword-matching posts since Jun 22
- @karpathy — no keyword-matching posts since Jun 22
- @AndrewYNg — most recent relevant posts from Apr 2026
- @swyx — no keyword-matching posts
- @steipete — reposted @samwillis /goal example (captured above as Tier 4)
- Anthropic RSS — 404 (ongoing)
- Addy Osmani RSS — no new posts since Jun 22
- Simon Willison RSS — no new posts since Jun 22
- The New Stack RSS — no new loop-engineering posts since Jun 22 (pre-cutoff article captured above)
- Cobus Greyling — no new posts since Jun 22
- OpenAI news — 403 blocked (ongoing)
- swyx.io — most recent post May 2026
- sabrina.dev HTML — Jun 19 article captured via X; no newer HTML posts
- Lenny's Newsletter — most recent relevant content Mar 2026

### Docs updated this run
- `docs/07-subagents.md` — added DOER/CHECKER pattern: "never let the AI grade its own output"
- `docs/01-paradigm-shift.md` — added AI Leverage Formula: AI Leverage = Clarity × Skill
- `docs/25-long-running-agents.md` — added Inner/Outer Dual Loop pattern; @samwillis real-world scale example (1k commits, 10 days)
- `docs/27-loop-contract.md` — added stopping condition aphorism ("if you can't say what done looks like, you don't have a loop")
- `docs/11-cost-control.md` — added token consumption benchmarks (~4× single agent, ~15× multi-agent)

### Sources to consider adding to SOURCES.md
- Data Science Dojo — published a substantive loop engineering guide with novel patterns and benchmarks; worth verifying a second article before adding as a tracked source

---

## 2026-06-22 20:43 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 2 | Cobus Greyling | "The Evolving Vocabulary of AI" | [link](https://cobusgreyling.substack.com/p/the-evolving-vocabulary-of-ai) | Traces AI terminology through six phases (2020–2026+) and names Loop Engineering as one of four mature engineering disciplines alongside Context Engineering, Harness Engineering, and Fleet Engineering — the clearest published framing of the field's vocabulary consolidation. |
| 3 | Addy Osmani | "Don't Outsource the Learning" | [link](https://addyosmani.com/blog/dont-outsource-learning/) | Empirical argument against cognitive surrender: engineers who copy-paste AI output score under 40% on comprehension tests vs 65%+ for those using AI assistively — quantifying the skill-degradation cost of outsourcing judgment to the loop. |
| 3 | Medium (@KilgortTrout) | "From Prompts to Loops: A Practical Guide to Building Agentic Workflows in Codex and Claude" | [link](https://medium.com/@KilgortTrout/from-prompts-to-loops-a-practical-guide-to-building-agentic-workflows-in-codex-and-claude-0b57234452ed) | Introduces "circuit breakers" (auto-halt on no-progress or error accumulation) and the "dark factory" anti-pattern (fully autonomous loops with zero human checkpoints) — two new safety framings added to the failure patterns doc. |

### No new content
- Anthropic RSS — 404 (ongoing)
- @bcherny — Jun 19 post on deciphering Linear A with Claude Code; no loop engineering content
- @karpathy — Jun 12 SpaceX, Jun 9 Fable reaction; no loop engineering content
- @AndrewYNg — Jun 19 policy/course posts; no loop engineering content
- @swyx — no keyword-matching posts
- @Sabrina_Ramonov — no new posts since 13:55 UTC run
- @steipete — new posts about OpenClaw becoming a non-profit; no loop engineering substance
- OpenAI news — 403 blocked (ongoing)
- swyx.io — most recent post May 2026
- sabrina.dev — no posts after Jun 19
- Lenny's Newsletter — two 2025 articles found; Tier 4, below inclusion threshold
- Simon Willison — "Initial impressions of Claude Fable 5" mentions PauseChain stop mechanism; primarily a model review, insufficient loop engineering substance
- The New Stack — two new Jun 22 articles (Cursor/Continue acquisition, Qodo cross-repo review); no loop patterns discussed
- X keyword search — browser error; no results returned

### Docs updated this run
- `docs/17-failure-patterns.md` — updated cognitive surrender with empirical data point (<40% vs 65%+ comprehension); added "Dark factory" and "Missing circuit breaker" failure patterns
- `docs/21-context-vs-loop-engineering.md` — added "The four disciplines" section: Greyling's vocabulary consolidation (Loop/Context/Harness/Fleet Engineering as four named disciplines)

### Sources to consider adding to SOURCES.md
- Geoffrey Huntley — credited as originator of the Ralph planner-worker-judge technique; worth checking for a blog/X presence with ≥2 loop engineering pieces

---

## 2026-06-22 13:55 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @bcherny | "When we first demoed Claude Code internally, it got two reactions on Slack. A year after GA… how routines…" | [link](https://x.com/bcherny/status/2064034799711588805) | Boris Cherny's own account of how he uses routines and loops in Claude Code, from a 1-year-GA retrospective interview — the most direct source on his mental model for loop and routine design. |
| 2 | Anthropic Engineering | "Effective Harnesses for Long-Running Agents" | [link](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) | Defines a two-part harness pattern (initializer agent + coding agent) with structured JSON feature lists, mandatory session init routines, browser automation testing, and git-based recovery to maintain agent progress across multiple context windows. |
| 2 | Addy Osmani | "Factory Model" | [link](https://addyosmani.com/blog/factory-model/) | Argues developers are transitioning from writing code to orchestrating agent factories, where success depends on specification quality, architectural thinking, and rigorous output verification rather than coding speed. |
| 2 | Lenny's Newsletter (Claire Vo) | "How to design AI agent loops: schedules, goals, and subagents in Claude Code and Codex" | [link](https://www.lennysnewsletter.com/p/how-to-design-ai-agent-loops-schedules) | Introduces a four-type loop taxonomy (heartbeat, cron, hook, goal) and an 'onboarding an employee' mental model for loop design; warns that goal loops are the hardest to write and most likely to burn tokens without output. |
| 2 | explainx.ai | "Loop Engineering: How to Design Coding Agent Loops That Run While You Sleep (2026 Guide)" | [link](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026) | Introduces the Loop Contract Model (TRIGGER/SCOPE/ACTION/BUDGET/STOP/REPORT), the Anchor File Pattern (VISION.md/CLAUDE.md/AGENTS.md/PROMPT.md), and the Uber data point that engineers burned an annual AI budget in four months before a $1,500/month per-tool cap was imposed. |
| 2 | The New Stack | "The Anthropic leader who built Claude Code says he ditched prompting — now he just writes loops" | [link](https://thenewstack.io/loop-engineering/) | The New Stack's primary loop engineering explainer, framed around Boris Cherny's public shift from prompting to writing loops — canonical source linking the Cherny quote to the broader loop engineering movement. |
| 3 | Addy Osmani | "Long-running Agents" | [link](https://addyosmani.com/blog/long-running-agents/) | Covers architectural patterns for agents that maintain progress across hours or days via persistent state management, recovery mechanisms, and the Ralph loop / planner-worker-judge multi-agent pattern. |
| 3 | Addy Osmani | "Agent Skills" | [link](https://addyosmani.com/blog/agent-skills/) | Encodes senior-engineering practices (specs, tests, reviews) as workflow scaffolding in agent harnesses, ensuring agents follow healthy SDLC phases and cannot skip verification steps inside loops. |
| 3 | Addy Osmani | "Cognitive Surrender" | [link](https://addyosmani.com/blog/cognitive-surrender/) | Distinguishes cognitive offloading (delegating with retained judgment) from cognitive surrender (accepting AI output unchecked), which compounds comprehension debt across agentic workflows. |
| 3 | Addy Osmani | "The Orchestration Tax" | [link](https://addyosmani.com/blog/orchestration-tax/) | Argues human attention is the bottleneck in multi-agent loops; the orchestration tax — cognitive cost of closing feedback loops on multiple parallel agents — requires deliberate backpressure and batching architecture. |
| 3 | Addy Osmani | "The Intent Debt" | [link](https://addyosmani.com/blog/intent-debt/) | Argues that undocumented design intent becomes the most expensive technical debt in agentic workflows, since AI agents cannot fabricate authentic rationale and will silently fill gaps with plausible-sounding explanations. |
| 3 | Addy Osmani | "The New Software Lifecycle" | [link](https://addyosmani.com/blog/new-sdlc-vibe-coding/) | AI agents have collapsed implementation speed, making spec quality, harness design, and verification the new engineering bottlenecks — explicitly references the factory model and harness as first-class artefacts in the modern SDLC. |
| 3 | Cobus Greyling | "Universal Agent Thesis" | [link](https://cobusgreyling.substack.com/p/universal-agent-thesis) | Proposes that autonomous agents must self-discover tools and map environment boundaries before executing — frames 'Perceive, reason, act, learn' as the universal agent loop and names the terminal as the universal integration layer replacing curated APIs. |

### No new content
- Anthropic RSS — 404 (ongoing; feed URL appears down)
- @karpathy — browser congestion; last known own post Jun 12; Jun 2 repost already captured
- @AndrewYNg — browser congestion; no loop engineering content in prior runs
- OpenAI news — 403 blocked (ongoing)
- @swyx — no keyword-matching posts found
- @Sabrina_Ramonov — last captured post from the 12:52 UTC run; no new posts since
- @steipete — no new posts since last run
- swyx.io — most recent post May 2026; no loop engineering content
- sabrina.dev — most recent post Jun 19 (already captured)
- X general keyword search — browser congestion; no results returned

### Docs updated this run
- `docs/24-harness-patterns.md` — new doc: two-part Anthropic harness (initializer + coding agent); four-type loop taxonomy (heartbeat/cron/hook/goal)
- `docs/25-long-running-agents.md` — new doc: Ralph loop, planner-worker-judge, cross-context-window state management, git-based recovery
- `docs/26-factory-model.md` — new doc: AI software factory framing — spec quality and verification replace coding speed as the engineering bottleneck
- `docs/27-loop-contract.md` — new doc: TRIGGER/SCOPE/ACTION/BUDGET/STOP/REPORT — six loop properties; Anchor File Pattern; Uber annual-budget-in-4-months data point
- `docs/17-failure-patterns.md` — added cognitive surrender, orchestration tax, and intent debt failure patterns
- `docs/02-agent-loop-cycle.md` — added Universal Agent Thesis ("Perceive, reason, act, learn") as alternative framing with the "Learn" step explained
- `docs/06-skills.md` — added "Skills as SDLC Scaffolding" section: encoding engineering phases as non-skippable skill steps
- `docs/01-paradigm-shift.md` — added "New Software Lifecycle" framing: implementation speed no longer the bottleneck
- `LOOP_ENGINEERING.md` — added rows 24–27 (harness-patterns, long-running-agents, factory-model, loop-contract)
- `SOURCES.md` — added Lenny's Newsletter (Claire Vo) as new html source

### Sources to consider adding to SOURCES.md
- explainx.ai — published substantive Loop Contract Model guide (Jun 9 2026); consistent loop engineering coverage worth tracking

---

## 2026-06-22 12:52 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "prompt engineering was you writing 1 good message at a time / loop engineering is you stepping out of that process" | [link](https://x.com/Sabrina_Ramonov/status/2069038443200418221) | The cleanest one-sentence distinction between prompt engineering and loop engineering — from a tracked practitioner, posted today on X amid broader community discourse. |
| 1 | @limalemonnn | "$47,000 in 11 days with no stop condition is the best argument for loop engineering I have seen, just not the way they intended. The brakes are not optional, they are the whole point." | [link](https://x.com/limalemonnn/status/2069039311584891122) | Real-world cost-runaway example: a loop with no stopping condition accumulated $47k in 11 days — illustrating that budget caps and stop conditions are mandatory infrastructure, not polish. |
| 2 | Addy Osmani | "Loop Engineering" | [link](https://addyosmani.com/blog/loop-engineering/) | Foundational Jun 7 article defining the 5 building blocks (automations, worktrees, skills, plugins, sub-agents) and noting that Codex and Claude Code now have identical loop engineering capabilities — the platform matters less than the design. |
| 2 | Addy Osmani | "Agent Harness Engineering" | [link](https://addyosmani.com/blog/agent-harness-engineering/) | Apr 19 article framing the scaffolding surrounding a coding agent — prompts, tools, context policies, sandboxes, feedback loops — as first-class artefacts requiring continuous refinement, not disposable wrappers. |
| 2 | @karpathy (repost of @trq212) | "A harness for every task: dynamic workflows in Claude Code" | [link](https://x.com/trq212/status/2061907337154367865) | Claude Code can now write its own task-specific harness on the fly before executing — the agent designs the workflow structure, not just the code. 3.1M views on @karpathy's repost. |
| 2 | Sakana AI | "Sakana Fugu: A Multi-Agent System as a Foundation Model" | [link](https://sakana.ai/fugu/) | Launched today: a trained-orchestrator model using TRINITY/Conductor architecture (Thinker/Worker/Verifier roles) that replaces hand-designed multi-agent loop code with learned orchestration — the harness as a training target, not a codebase. |
| 2 | Cobus Greyling | "Loop Engineering" (Medium) | [link](https://cobusgreyling.medium.com/loop-engineering-62926dd6991c) | Jun 9 article with 6-component breakdown (scheduling, worktrees, skills, connectors, sub-agents, memory) citing Cherny and Steinberger — a solid practitioner synthesis from a tracked source. |
| 2 | Cobus Greyling | "Fleet Engineering" | [link](https://cobusgreyling.substack.com/p/fleet-engineering) | New discipline: managing fleets of AI agents across enterprises via governance, observability, and routing — one layer above loop engineering. |
| 2 | @devops_prashant | "The model is the engine, the agent harness is the car—everyone's been debating horsepower while the real product was always the steering wheel" | [link](https://x.com/devops_prashant/status/2069034725738766545) | Quotable framing of why harness design matters more than model selection — the steering wheel (harness) determines where the car (loop) goes. |
| 2 | @shalabi | "If you hard-coded a single provider into your agent loop, it is an outage plus an emergency compliance review, at the same time. Model portability stopped being optional." | [link](https://x.com/shalabi/status/2069038743894597743) | Names provider lock-in as a new agent loop failure mode: hard-coding one model provider into the loop creates a single point of failure that combines technical and compliance risk. |
| 3 | @steipete | "This is becoming my favorite way to read Twitter" (birdclaw.sh) | [link](https://x.com/steipete/status/2068965200343224367) | Peter Steinberger shares birdclaw.sh, an OpenClaw-powered agent for consuming Twitter — itself a loop engineering application, and context for OpenClaw trending globally today. |
| 3 | Addy Osmani | "Agentic Code Review" | [link](https://addyosmani.com/blog/agentic-code-review/) | Jun 15 article: improved coding agents shift engineering focus toward trust assessment and review — adversarial evaluation becomes the highest-leverage skill in agentic development. |
| 3 | The New Stack | "Gemini CLI vs. Antigravity: What works, not the spec sheet" | [link](https://thenewstack.io/gemini-cli-antigravity-replacement/) | Google replaced open-source Gemini CLI with closed-source Antigravity CLI; key practical finding: Antigravity handles headless file and shell operations where Gemini CLI fails — headless capability is table stakes. |
| 3 | Simon Willison | "Claude Fable is relentlessly proactive" | [link](https://simonwillison.net/2026/Jun/11/fable-is-relentlessly-proactive/) | Fable 5 autonomously invented novel debugging techniques (browser automation, shadow DOM manipulation, custom web servers) — the model itself becoming more loop-like, blurring the line between agent and harness. |

### No new content
- Anthropic RSS — 404 (ongoing; feed URL appears down)
- @bcherny — last own post Jun 19 (no keyword match on loop engineering)
- @karpathy — last own post Jun 12 (SpaceX); Jun 2 repost captured above
- @AndrewYNg — no new posts since Jun 19 (pre-cutoff)
- OpenAI news — 403 blocked (ongoing)
- @swyx — posts today about AI Engineer conference logistics; no loop engineering content
- swyx.io — most recent post May 2026, no loop engineering content

### Docs updated this run
- `docs/17-failure-patterns.md` — added "Cost runaway" and "Provider lock-in" failure patterns
- `docs/22-learned-orchestration.md` — new doc: Sakana Fugu's trained-orchestrator approach (TRINITY/Conductor, Thinker/Worker/Verifier)
- `docs/23-fleet-engineering.md` — new doc: managing fleets of agents at enterprise scale (Cobus Greyling, LangSmith Fleet)
- `LOOP_ENGINEERING.md` — added rows 22 (learned-orchestration) and 23 (fleet-engineering)
- `SOURCES.md` — added @Sabrina_Ramonov X handle (active X presence confirmed today)

### Community signal
- X trending today: "AI Leaders Champion Loops Over One-Off Prompts" (2,151 posts, 9 hours ago)
- "OpenClaw" trending globally on X (context: Sakana Fugu vs OpenClaw discussion, birdclaw.sh launch)
- The X general search for "loop engineering" is live with dozens of posts per minute — the term has reached mainstream AI Twitter

### Sources to consider adding to SOURCES.md
- @limalemonnn — surfaced the $47k cost-runaway anecdote; active in loop engineering discussions
- @shalabi — named provider lock-in as an agent loop failure mode; substantive practitioner voice

---

## 2026-06-21 20:20 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 2 | @RoundtableSpace / @AnatoliKopadze | "Claude Code team shows full app from scratch using a loop of three agents — 40 min, AI Engineer Europe" | [link](https://x.com/RoundtableSpace/status/2068789803945214042) | Live conference demo of a sequential 3-agent loop (plan → build → verify) that built a complete app in 40 minutes, the most concrete public example of the factory model in action. |
| 2 | @0xCodez | "Lead of Claude Code: 100% of our code at Anthropic is now shipped by Claude. Loops are as big a shift as source coding to agents." | [link](https://x.com/0xCodez/status/2068784463186932059) | Shares Boris Cherny's live conference quote and references the Jun 9 article "Loop engineering: the 14-step roadmap from prompter to loop designer" — a maturity model for the transition. |
| 2 | @batjko_labs | "Loop engineering is the right frame but the wrong unit. The job is not to design a loop that runs the agent. It is to…" | [link](https://x.com/batjko_labs/status/2068789878200922603) | Challenges the loop as the atomic unit of design, suggesting a higher-level abstraction is needed — an emerging counter-argument within the community. |
| 2 | @techtasium | "CONTEXT ENGINEERING > LOOP ENGINEERING" | [link](https://x.com/techtasium/status/2068784586222612560) | Provocative claim that context engineering (what you put into the loop) matters more than the loop structure itself — sparking a community debate about relative priority. |
| 3 | @shivangchheda22 | "The hard part isn't prompting, it's the stop condition. A useful loop needs trace logs, bounds…" | [link](https://x.com/shivangchheda22/status/2068789961223262458) | Citing @steipete: reinforces that stopping conditions, trace logs, and explicit bounds are the underrated hard parts of loop design — not the prompts themselves. |

### No new content
- Anthropic RSS — 404 (feed URL may have changed again)
- @bcherny — no keyword-matching posts since last run
- @karpathy — no keyword-matching posts since last run
- @AndrewYNg — no keyword-matching posts since last run
- @swyx — no keyword-matching posts since last run
- @steipete — no keyword-matching posts since last run (cited secondhand by @shivangchheda22)
- Addy Osmani — last post Jun 16
- Simon Willison — last post Jun 18
- The New Stack — no new articles since 18:33 UTC
- Cobus Greyling — last post Jun 18
- OpenAI news — 403 blocked
- swyx.io — no new posts since last run
- sabrina.dev — no new posts since last run

### Docs updated this run
- `docs/21-context-vs-loop-engineering.md` — new doc: emerging debate on whether context engineering supersedes loop engineering
- `docs/20-loop-maturity-model.md` — new doc: 14-step progression from prompter to loop designer
- `docs/17-failure-patterns.md` — added "Loop as wrong unit" entry

### Sources to consider adding to SOURCES.md
- @0xCodez — AI content creator; high-engagement loop engineering explainers (402+ views, 27 likes); published 14-step roadmap article Jun 9
- @AnatoliKopadze — conference reporter; captured Claude Code AI Engineer Europe live demo

---

## 2026-06-21 18:33 UTC (run)

### New findings

| Source | Title | URL | Summary |
|---|---|---|---|
| The New Stack | "A public Sentry key is all it takes to hijack Claude Code, Cursor, and Codex" | [link](https://thenewstack.io/agentjacking-sentry-mcp-attack/) | Security researchers documented "AgentJacking" — fake Sentry error reports that hijack MCP-connected AI coding agents and execute arbitrary code on developers' machines. |
| The New Stack | "Your agent wants to search like a 2010 quant" | [link](https://thenewstack.io/search-like-2010-quant/) | AI agents need sophisticated filtered search with ranking and metadata options, not just raw vector similarity, to retrieve relevant context reliably. |
| The New Stack | "An agent is an LLM and a harness": What Nvidia really thinks about OpenClaw | [link](https://thenewstack.io/nvidia-openclaw-agent-blueprints/) | Nvidia defines an agent as "an LLM and a harness" and is building enterprise agent blueprints via the OpenClaw framework to help companies safely adopt agentic AI. |
| @CKGrafico (X) | "Everyone is talking about loop engineering, but most examples keep an AI running just to discover if work exists" | [link](https://x.com/CKGrafico/status/2068760847699042601) | Highlights a token-waste anti-pattern: polling loops that burn tokens checking for work rather than using event-driven triggers. |
| @mosoahmed (X) | "Prompt Engineering Is Already Dead. Loop Engineering Took Its Job." | [link](https://x.com/mosoahmed/status/2068754362810396908) | Article arguing loop engineering has superseded prompt engineering as the primary skill for working with AI coding agents in 2026. |

### No new content
- Anthropic blog — RSS unavailable (404); news page last updated Jun 17
- @bcherny — last post Jun 19 (pre-cutoff)
- @karpathy — last post Jun 12 (pre-cutoff)
- @AndrewYNg — last post Jun 19 (pre-cutoff)
- OpenAI blog — RSS blocked (403)
- Addy Osmani — last post Jun 16 (pre-cutoff)
- Simon Willison — last post Jun 18 (pre-cutoff; Datasette Apps, no keyword match)
- @swyx — Jun 21 posts about sports/AI World's Fair, no keyword match
- swyx.io blog — page returned 404

### Docs updated this run
- `docs/19-mcp-security.md` — new doc: AgentJacking via Sentry MCP, indirect prompt injection, mitigations
- `docs/17-failure-patterns.md` — added "Polling loop" anti-pattern

### Sources to consider adding to SOURCES.md
Web search for "loop engineering" surfaced active blogs not yet in SOURCES.md:
- sabrina.dev — wrote "AI Loop Engineering: Build Autonomous Agents with Claude Code /goal + Routines" (Jun 19)
- explainx.ai — published a 2026 loop engineering guide (recent)
- datasciencedojo.com — "Agentic Loops: From ReAct to Loop Engineering (2026 Guide)"
- the-ai-corner.com — "Loop Engineering: Build Self-Running Coding Agents 2026"

---

## 2026-06-21 08:07 UTC (initialized)

_No entries yet — first automated run pending._

---
