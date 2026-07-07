# Loop Engineering News

Newest-first digest. Updated by the `fetch-loop-news` skill on each run.
Sources are defined in [`SOURCES.md`](https://lucagattoni.github.io/Claude-Loops/sources/).

---

## 2026-07-07 04:00 UTC (run)

Largest run by raw source count (52 tracked sources + general web search, 9 parallel
research agents), driven by wide social reaction to the official Anthropic/ClaudeDevs
"Getting started with loops" taxonomy post — over a dozen independent X/LinkedIn reactions
converged on the same four-loop-type framing within 24 hours, and a new primary source
("The Making of Claude Code" oral history) surfaced the internal codename ("clide") and
2022-era harness-design origins for the first time. The GitHub-search API pass had its
best yield to date: 6 new repos directly targeting open `KB_GAPS.md` items (reviewer
freshness, held-out eval sizing, fleet maturity, cross-model pairing).

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | via Addy Osmani article link | "Peter Steinberger post: 'You shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents.'" | [link](https://x.com/steipete/status/2063697162748260627) | Primary-source origin quote for the 'designing loops that prompt agents' framing cited as the thesis of Osmani's Loop Engineering piece. |
| 1 | via Addy Osmani article link | "Boris Cherny (Claude Code lead, Anthropic) post: 'I don't prompt Claude anymore... My job is to write loops'" | [link](https://x.com/rohanpaul_ai/status/2063289804708835412) | Direct quote from Claude Code's lead stating his job is now to write loops that prompt Claude rather than prompting directly, a Tier 1 exact-phrase match. |
| 1 | MindStudio Blog | "Loop Engineering vs Prompt Engineering: What's the Difference and Which Do You Need?" | [link](https://www.mindstudio.ai/blog/loop-engineering-vs-prompt-engineering/) | Defines loop engineering as automating the user's own role as agent prompter, distinct from prompt optimization. |
| 1 | arXiv | "Stop Hand-Holding Your Coding Agent: Engineering the Loops that Replace Step-by-Step Prompting" | [link](http://arxiv.org/abs/2607.00038v1) | Defines a loop specification (trigger, goal, verification, stopping rules, memory) as a reusable artifact agents pursue autonomously within a harness. |
| 1 | MindStudio Blog | "How to Use Claude Code's /goal Command with Routines for Fully Autonomous Scheduled Workflows" | [link](https://www.mindstudio.ai/blog/claude-code-goal-routines-autonomous-scheduled-workflows/) | Combines /goal completion conditions with cron-based routines for unattended recurring agent workflows. |
| 1 | @bcherny | "Getting started with loops (Claude Code team loop taxonomy)" | [link](https://x.com/ClaudeDevs/status/2074208949205881033) | Boris Cherny reposted this @ClaudeDevs X Article defining 4 loop types (turn-based, goal-based /goal, time-based /loop+/schedule, proactive/dynamic workflows) with stop conditions, SKILL.md-based self-verification, adversarial second-agent code review, and parallel worktrees. |
| 1 | via @swyx thread | "The Making of Claude Code (oral history, by Anthropic)" | [link](https://www.anthropic.com/features/making-of-claude-code) | Anthropic's own builders (Boris Cherny, Ben Mann, Dawn Drain, Adam Wolff, etc.) narrate Claude Code's origin, explicitly discussing '2022... harness design—the scaffolding around the model that lets it actually act' and the early Claude desktop app being 'tool definitions in a loop and a simple REPL UI.' |
| 1 | LinkedIn search | "Loop Engineering Explained for Developers!" | [link](https://www.linkedin.com/pulse/loop-engineering-explained-developers-pavan-belagatti-znhlc/) | Argues for autonomous self-iterating systems over manual prompting, defining loop components as automations, skills, sub-agents, connectors, and state files, illustrated via a CI-failure workflow. |
| 1 | X search | "Loop engineering defined via objective/constraints/verification/stop condition" | [link](https://x.com/tugrateng/status/2074280598877683935) | Substantive thread defining loop engineering as specifying objective, constraints, acceptance criteria, verification method, and stopping condition rather than narrating steps. |
| 1 | X search | "Citing Boris Cherny/Cat Wu explainer on agent loops" | [link](https://x.com/Kazu_AIagent/status/2074310848869544246) | Japanese practitioner cites primary sources (Claude Code creators' 2026-06-09 agent-loops explainer via theneuron.ai, and thenewstack.io on the 'loop engineering' trend) as background reading. |
| 1 | X search | "Mega-prompts are hitting a wall — Loop Engineering not adjectives" | [link](https://x.com/prompthon_io/status/2074343934197633131) | Promotional but substantive post arguing reliable AI needs state machines and agent loops over single prompts. |
| 1 | runtimeking | "My new product is now running in a loop" | [link](https://x.com/runtimeking/status/2074326384894456011) | Concrete practitioner example: an agent loop fed by ads/analytics/errors/usage that autonomously opens PRs or takes actions daily toward a goal. |
| 1 | ising_ | "Most practical/concrete loop engineering article seen" | [link](https://x.com/ising_/status/2074321322956697708) | Japanese reaction praising the ClaudeDevs 'Getting started with loops' article as the most practical, concrete piece on the topic. |
| 1 | Karadokuy | "Deep-dive reaction to ClaudeDevs loops article" | [link](https://x.com/Karadokuy/status/2074312386597851481) | Chinese practitioner breaks down ClaudeDevs' loop framework as an operationalizable structure for making agents 'truly run, keep running, run stably,' aligning with own experimental loop framework. |
| 1 | explainx.ai | "Claude Code Loops Guide: /goal, /loop, /schedule (2026)" | [link](https://explainx.ai/blog/claude-code-loops-official-guide-turn-goal-schedule-2026/) | Categorizes Claude Code loops into turn-based (manual, verification-skill checked), goal-based (/goal, evaluator decides completion), time-based (/loop local vs /schedule cloud), and proactive (scheduling+goals combined). Core principle: identify which loop component to automate (verification, exit criteria, trigger, or whole routine). Quality tactics: clean codebases, measurable verification skills, low-friction docs access, secondary review agents, encoding failures into system improvements. Token tips: right-size model per task, explicit completion criteria + turn caps, pilot before scaling, deterministic scripts over re-reasoning. |
| 2 | via Cobus Greyling article link | "The Rise of AI Harness Engineering" | [link](https://cobusgreyling.medium.com/the-rise-of-ai-harness-engineering-5f5220de393e) | Positions the 'harness' as a fourth distinct architectural pattern (beyond SDK/framework/scaffolding) that governs agent tool, memory, and lifecycle behavior. |
| 2 | via Cobus Greyling article link | "Two-Thirds of Multi-Agent Intelligence Is Harness" | [link](https://cobusgreyling.medium.com/two-thirds-of-multi-agent-intelligence-is-harness-c46fc481fefa) | Argues via an IEEE three-layer framework that most multi-agent system performance comes from harness/orchestration engineering, not the model. |
| 2 | arXiv | "Open-SWE-Traces: Advancing Dual-Mode Multilingual Distillation for Software Engineering Agents" | [link](http://arxiv.org/abs/2606.16038v1) | 207K trajectories sourced via OpenHands and SWE-agent harnesses for long-horizon training. |
| 2 | arXiv | "Dissecting model behavior through agent trajectories" | [link](http://arxiv.org/abs/2606.17454v2) | Formalizes the 'intent-execution gap' between model intentions and harness execution using a generalizable Simple Strands Agent. |
| 2 | MindStudio Blog | "7 Agentic Loop Use Cases You Can Run Today: From SEO Audits to Error Sweeps" | [link](https://www.mindstudio.ai/blog/agentic-loop-use-cases/) | Practical templates for running recurring agent loops for business automation tasks. |
| 2 | MindStudio Blog | "What Is an Agentic Loop? The Core Pattern Behind Autonomous AI Agents" | [link](https://www.mindstudio.ai/blog/what-is-an-agentic-loop-autonomous-ai-agents/) | Explains the reason-act-observe repeating pattern underlying autonomous agent design. |
| 2 | MindStudio Blog | "Agentic Loop Design: How to Define Goals and Verification Criteria That Actually Work" | [link](https://www.mindstudio.ai/blog/agentic-loop-design-goals-verification-criteria/) | Explains that loop quality hinges on defining completion/verification criteria to prevent runaway autonomous sessions. |
| 2 | arXiv | "Code Isn't Memory: A Structural Codebase Index Inside a Coding Agent" | [link](http://arxiv.org/abs/2606.22417v1) | Ablation study on whether adding a structural codebase index to the agent harness improves SWE-bench localization/resolution. |
| 2 | MindStudio Blog | "How to Design Agent Loops with Verifiable Stop Conditions" | [link](https://www.mindstudio.ai/blog/agent-loops-verifiable-stop-conditions/) | Covers designing objective, verifiable completion criteria for autonomous agent loops. |
| 2 | MindStudio Blog | "Agent Loops Explained: Trigger, Action, and Stop Condition" | [link](https://www.mindstudio.ai/blog/agent-loops-explained-trigger-action-stop-condition/) | Breaks agent loop design into trigger, action, and stop-condition components. |
| 2 | MindStudio Blog | "What Is a Loop of Loops? How to Build AI Agents That Coordinate Recurring Work" | [link](https://www.mindstudio.ai/blog/what-is-loop-of-loops-ai-agents-recurring-work-2/) | Describes coordinating multiple recurring agent loops that share information and delegate tasks to each other. |
| 2 | MindStudio Blog | "What Is the Agent Harness? Why It Matters More Than the Model You Choose" | [link](https://www.mindstudio.ai/blog/what-is-agent-harness-matters-more-than-model/) | Argues the harness (rules, tools, context, guardrails) drives ~90% of agentic system performance vs. ~10% from the LLM. |
| 2 | arXiv | "Evaluating Agentic Harness Systems for Autonomous Computational Pathology" | [link](http://arxiv.org/abs/2607.02598v1) | Evaluates 9 models across 3 harness groups (Claude Code, Codex, Open Code) on clinical pathology workflow tasks. |
| 2 | arXiv | "ORBIT-Q: Dual-axis benchmarking of autonomous agents in scientific quantum programming" | [link](http://arxiv.org/abs/2607.03105v1) | Benchmarks different agent harness and model configurations on quantum programming tasks. |
| 2 | @swyx | "Field Guide to Fable — Thariq Shihipar (Anthropic), AI Engineer World Fair keynote" | [link](https://www.youtube.com/watch?v=9fubhllmsBU) | Anthropic's Claude Code lead engineer's keynote on building Claude Code (internal codename Fable), reposted by swyx; quote-tweets note it covers system-prompt reduction and harness design choices. |
| 2 | LinkedIn search | "Prompt vs Loop vs Context Engineering" | [link](https://www.linkedin.com/pulse/prompt-vs-loop-context-engineering-blockchaincouncil-7a3vf/) | Explainer positioning loop engineering as the automation layer that lets systems prompt/verify/rerun agents autonomously, complementing prompt and context engineering. |
| 2 | Lenny's Newsletter | "How I AI: Sonnet 5 Review & Autonomous Coding Agents" | [link](https://www.lennysnewsletter.com/p/how-i-ai-sonnet-5-review-and-how) | Claire Vo builds a repeatable eval harness with Claude Code to blind-benchmark 5 frontier models on agentic tasks. |
| 2 | arXiv | "AgenticPD: A Stage-Aware Agentic Framework for Physical Design QoR Optimization" | [link](http://arxiv.org/abs/2607.04758v1) | Organizes an agent harness around stage boundaries with structured execution history for checkpoint reuse and branching. |
| 2 | TLDR AI | "Own the Loop: A Field Guide to Agent Harnesses" | [link](https://x.com/aparnadhinak/status/2073079029624943040) | Argues the real differentiator between agent products is the harness — the control loop managing tools, workflows, orchestration, and model routing. |
| 2 | X search | "Prompt → Context → Harness → Loop engineering progression" | [link](https://x.com/yanli1122/status/2074314151741317256) | Frames a 2-year evolution from prompting to harness engineering to loop engineering as 'less prompting, more control.' |
| 2 | X search | "Progression: prompt → context → vibe coding → agentic → loop → learned orchestration engineering" | [link](https://x.com/tugrateng/status/2074280511262883943) | Companion tweet mapping the full terminology progression and noting model behavior drifts a few releases after each stage is named. |
| 2 | X search | "Loop Engineering vs. Harness Engineering: When to Use Each" | [link](https://x.com/MediaRings/status/2074300691636535730) | Zoltan Szabo distinguishes loop engineering from harness engineering as commonly confused practices (links to ift.tt-redirected blog post, not independently verified). |
| 2 | erniesg | "Loop engineering is a pre-IPO marketing phase!?" | [link](https://x.com/erniesg/status/2074323457563881731) | Skeptical take that loop engineering (via /goal + Fable) is largely a token-burn marketing phase — counter-narrative worth tracking. |
| 2 | domore_xu | "Loop engineering as PID control / cascade control analogy" | [link](https://x.com/domore_xu/status/2074296796558635246) | Novel framing comparing single-loop engineering to PID control and nested loop engineering to cascade control, emphasizing humans' role in defining problem/goal/evaluation criteria. |
| 2 | omnigent-ai/omnigent | "docs(harness-bench): refresh design doc to shipped reality; expand (#2023)" | [link](https://github.com/omnigent-ai/omnigent/commit/5269f70) | Design doc rewrite documents a shipped harness-capability bench with three transport drivers (sdk-inproc, full-server, native-tui) and a self-enforcing capability table that catches real declaration drift (e.g. kiro/cursor/qwen wrongly declared streaming-capable) by correcting the source model rather than the bench, plus a note that the remaining plugin-seamlessness gap is the server's hardcoded native-agent seeding list. |
| 2 | github | "KristopherGBaker/Sparra — adversarial build harness with cross-model judging and holdout wall" | [link](https://github.com/KristopherGBaker/Sparra) | Generator implements a negotiated 'done' contract while an independent evaluator actually runs the artifact. Cross-model pairing is manually configured per role (e.g. Claude builds, Codex judges) via `.sparra/` config, not auto-selected. Holdout wall: evaluator-only acceptance checklist the builder never sees; role-runner passes holdout only by path to the evaluator and returns just the parsed verdict to the builder, preventing overfitting to known checks. Directly addresses gap on held-out eval sizing/overfitting and cross-model reviewer pairing, though pairing criteria are user-chosen rather than benchmarked. |
| 2 | github | "chf3198/megingjord-harness — fleet governance harness with baton workflow" | [link](https://github.com/chf3198/megingjord-harness) | Governance-first harness ("Kubernetes for coding agents") enforcing shared policy across Copilot, Claude Code, and Codex via a two-tier deployment (global home-dir layer + per-repo workspace layer). Baton workflow: responsibility handoff via role labels (Manager to Collaborator to Admin to Consultant), applied only to active execution states. Documentation implies F0-F3 fleet-maturity progression alongside fleet-aware routing, telemetry, and policy enforcement, plus multi-project idempotent deployment. Relevant to the F0-F3 fleet maturity gap, though the README summary doesn't give concrete per-stage indicator definitions. |
| 2 | github | "ruvnet/metaharness — factory model for branded agent harnesses" | [link](https://github.com/ruvnet/metaharness) | "Factory for agent frameworks": generates branded harnesses (own CLI, MCP server, scoped memory, governance policy) as npm packages for org-wide standardization. Witness-signed release provenance (Ed25519, SLSA L2, npm attestation). Darwin Mode (`@metaharness/darwin`) mutates its own config, sandbox-tests each change, and keeps only mutations that measurably improve held-out benchmarks (SWE-bench Lite, LiveCodeBench) with strict train/eval disjointness — directly addresses held-out eval sizing/overfitting-detection gap. Model router learns cheapest-sufficient model per task from fleet eval logs (fleet-maturity relevant). Cost-Pareto leaderboard requires Wilson 95% CIs on submissions for reproducibility. |
| 2 | github | "Aditya-Nagariya/harness-forge — self-improving Claude Code harness" | [link](https://github.com/Aditya-Nagariya/harness-forge) | Failure-tracking + lesson-memory system: tool failures get normalized signatures stored locally, repeat failures surfaced at session start and promoted into durable lessons via vote-weighted promotion (>=3.0 weight advances a lesson into an enforced hook). Confirmed failures become permanent regression checks in a living test suite. Claims mechanized rules get ~100% compliance vs ~70-90% for prose guidance. README does not address held-out eval sizing or train/test-split strategy for harness evolution (gap remains only partially addressed). |
| 3 | github | "beingcognitive/unprimed-dialectic — reviewer freshness enforcement" | [link](https://github.com/beingcognitive/unprimed-dialectic) | Argues priming a reviewer with your expected verdict yields compliance, not review. Distinguishes model independence (different AI systems catch different error classes) from perspective independence (same model, no shared conversation history, prevents context-poisoning). Fresh reviewers must see only the problem/constraints, never the draft; divergence between independent solutions and your draft is the highest-signal output, exposing hidden framing assumptions. Also flags the 'synthesizer problem': the decision-maker remains most biased, mitigated by logging rejections vs acceptances and defining convergence as 'no draft changes after synthesis.' Directly addresses the reviewer-freshness-enforcement gap. |
| 3 | Addy Osmani | "Agentic Code Review" | [link](https://addyo.substack.com/p/agentic-code-review) | Argues review has become software engineering's key bottleneck (4x AI code output, ~10% net productivity gain) and advocates tiered/heterogeneous AI reviewers, a maker-checker practice central to loop design. |
| 3 | Anthropic | "Steering Claude Code: CLAUDE.md files, skills, hooks, rules, subagents and more" | [link](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more) | Covers customizing Claude Code via subagents (isolated markdown-defined assistants in .claude/agents/, nestable 5 levels deep), hooks, skills, rules; describes orchestrating background agents via script variables. |
| 3 | Anthropic | "Building effective human-agent teams" | [link](https://claude.com/blog/building-effective-human-agent-teams) | Discusses org practices for human-agent collaboration; references a 'Doer-Verifier' agent harness pattern (one agent does the task, another checks it) — a maker-checker approach. |
| 3 | Lenny's Newsletter | "How Top PMs Increase Leverage with AI" | [link](https://www.lennysnewsletter.com/p/how-top-pms-increase-their-leverage) | Describes a leverage ladder where top rung is full task delegation via MCP connections (e.g., Claude to PostHog/Figma) for autonomous analytics/design work. |
| 3 | TLDR AI | "Agent-Assisted SGLang Development" | [link](https://www.lmsys.org/blog/2026-07-02-agent-assisted-sglang-development) | Describes turning agent workflows into reusable SKILL.md files, benchmark contracts, review loops, and production debugging playbooks. |
| 3 | Addy Osmani | "Agentic Autonomy Levels" | [link](https://addyo.substack.com/p/agentic-autonomy-levels) | Proposes six autonomy levels for agentic engineering across agency and orchestration dimensions, arguing verification (defensible evidence, not trust) is the bottleneck for higher-autonomy loops; links OpenAI's Symphony orchestration proposal. |
| 3 | TLDR AI | "Fable's judgement" | [link](https://simonwillison.net/2026/Jul/3/judgement/) | Simon Willison on delegating routine coding to subagents on lower-tier models while keeping judgment/review/synthesis in the main loop, reviewing subagent output before committing. |
| 3 | TLDR AI | "Autoresearch, Claude, and Constrained Optimization" | [link](https://www.elliotcsmith.com/autoresearch-claude-and-constrained-optimization/) | Examines when autonomous research loops work well — specifically constrained-optimization problems with clear gradients/metrics. |
| 3 | TLDR AI | "Devin Security Swarm" | [link](https://threadreaderapp.com/thread/2072368168182432109.html) | Introduces an 'Agentic MapReduce' architecture: agents map signals across a codebase, fan out over bounded sections, reduce findings, and verify vulnerabilities in sandboxes. |
| 3 | @bcherny | "Announcing 'The Making of Claude Code' oral history" | [link](https://x.com/bcherny/status/2074247226038063316) | Boris Cherny announces Anthropic's first told-from-the-inside history of Claude Code's origins in Anthropic safety/agentic-coding research; thread reveals early harness-design and agentic-loop struggles (internal codename "clide"). |
| 3 | @steipete | "Crabbox — remote execution control plane for agent sandboxes" | [link](https://crabbox.sh) | Steinberger endorses Crabbox (with Blacksmith) for leasing cloud machines/agent sandboxes to run and validate coding-agent workflows remotely, relevant to worktree/sandbox-style loop infrastructure. |
| 3 | via Lenny's Newsletter article link | "Linear" | [link](https://linear.app) | Used as a state-machine backend for tracking and handing off asynchronous autonomous coding agent tasks. |
| 3 | TLDR AI | "Closing the Verification Loop" | [link](https://thinkroom.kieranklaassen.com/d/njrS5TJhis) | Guide on agents autonomously verifying production-readiness by driving browsers through user journeys, with a 'fix loop governor' escalating non-trivial decisions; dispatches fresh subagents per verification altitude rather than standing agents. |
| 3 | omnigent-ai/omnigent | "fix(harnesses): re-check idleness before the reaper releases an entry (#1834)" | [link](https://github.com/omnigent-ai/omnigent/commit/8236c72) | Fixes a race in the idle-reaper for agent harness subprocesses where a turn starting during a slow teardown pass could be SIGTERMed mid-flight; release() now re-checks idleness atomically under the registry lock before tearing down, mirroring the pane reaper's busy re-check pattern. |
| 3 | github | "erikhuang76821/fable-harness-kit — tiered cross-model review harness" | [link](https://github.com/erikhuang76821/fable-harness-kit) | Tiered orchestration: a planning/arbitration model (Opus-tier) plus an execution model (Sonnet-tier), with external CLIs (Codex or Agy) called in as single-worker reviewers, never as orchestrator. Explicitly discloses degradation to same-family review when external tools are unavailable rather than silently reducing capability. Risk-tiered review: single-lens review for low-risk steps, mandatory dual (cross-family) verification for high-risk operations. Relevant to cross-model reviewer pairing selection criteria gap. |
| 4 | Simon Willison | "Datasette Apps: Host custom HTML applications inside Datasette" | [link](https://simonwillison.net/2026/Jun/18/datasette-apps/) | Claude Fable's agentic security review caught a privilege-escalation vulnerability in the new sandboxed-apps plugin, an example of AI-driven adversarial review in practice. |
| 4 | TLDR AI | "Alibaba Reportedly Restricted Claude Code" | [link](https://techcrunch.com/2026/07/04/alibaba-reportedly-bans-employees-from-using-claude-code/) | Alibaba reportedly banned employee use of Claude Code starting July 10, directing staff to internal tool Qoder instead. |
| 4 | The New Stack | "Getting Claude Code to grunt in Caveman-speak might not save as many tokens as you think" | [link](https://thenewstack.io/caveman-mode-token-savings/) | Real measured numbers: a viral Claude Code skill claimed 65% token reduction but JetBrains testing found only ~8.5% realistic savings for production coding tasks. |
| 4 | X search (phase 3) | "Overlap check on 'loop engineering'/'agent loop'/'Claude Code'" | [link](https://x.com/search?q=%22loop+engineering%22+OR+%22agent+loop%22+OR+%22Claude+Code%22&src=typed_query&f=live) | First page was dominated by generic/noisy Claude Code mentions (tool comparisons, promos, jokes) with no substantive loop-engineering content beyond what phase 1 already surfaced; no new items met the bar. |

### No new content

- The Batch (DeepLearning.AI) — feed still 404 after trying `/the-batch/feed/`, `/feed/`, `/the-batch/rss/`, `/the-batch.rss`, and an rsshub.app mirror (403 Cloudflare challenge); no working feed found
- AI Breakfast — feed still 404/403 after trying `aibreakfast.beehiiv.com/feed`, `/rss`, `/feed.xml` and a web search for a beehiiv feed ID
- Harness Books / AgentWay — 403 Forbidden on the root URL this run
- Daily Dose of Data Science — homepage yields only paywalled course promos, no article content this run
- @swyx (direct posts) — broadened query (agent OR "Claude Code" OR agentic OR harness) still returns only old/passing mentions (Jun 9–24); the two findings credited to @swyx this run came from a repost + its thread, not his own writing
- @karpathy, @AndrewYNg — no posts matching Tier 1/2 keywords since last run
- @Sabrina_Ramonov — strong Tier 1/2 posts exist but all predate last_run_date (Jun 22–28); already covered in prior runs
- swyx.io, Cobus Greyling (rss), cobusgreyling/loop-engineering, cobusgreyling/goal-engineering, cobusgreyling/fleet-engineering, getzep/graphiti, eugenelim/agent-ready-repo, JeiKeiLim/tenet, faisalishfaq2005/loopflow, uppifyagency/loop-kernel, krishddd/Strive_Engineering, Happenmass/Cliclaw, Happenmass/omux, firegnu/herdr-loop-lab, peterCheng123321/loop-engineering, Sungmin-Cho/claude-deep-loop, shouryasrivastava/ctxcarry, the-open-engine/zeroshot, JasonxzWen/harness-hub, edonadei/caliper, affaan-m/ecc — no commits or releases newer than 2026-07-06

### Docs updated this run

- `docs/04-verification.md` — new "Reviewer Freshness Enforcement" subsection (beingcognitive/unprimed-dialectic) directly fills the `KB_GAPS.md` reviewer-freshness-enforcement gap; extended the Held-Out Test Layer pattern with an evaluator-only "holdout wall" refinement (KristopherGBaker/Sparra)
- `docs/24-harness-patterns.md` — added Darwin Mode (ruvnet/metaharness: train/eval-disjoint held-out benchmark gating) to Self-Improving Harnesses, closing the SEAGym snapshot-collapse risk flagged in a prior run; added harness-forge's mechanized-vs-prose compliance metric (~100% vs ~70-90%); extended harness-bench with its capability-table self-correction mechanism; added a primary-source citation to the harness-design origin story from "The Making of Claude Code" oral history
- `docs/23-fleet-engineering.md` — noted megingjord-harness as a partial (not sufficient) contribution to the F0-F3 observable-indicators gap
- `docs/10-fan-out.md` — added the Agentic MapReduce pattern (map signals → fan out over bounded sections → reduce findings → verify in sandboxes)
- `docs/32-reading-list.md` — added ruvnet/metaharness (Darwin Mode) to Self-Improving Harnesses
- `KB_GAPS.md` — marked the reviewer-freshness-enforcement gap and the held-out-eval-sizing gap filled; kept F0-F3 fleet-maturity and cross-model-pairing-selection gaps open with this run's partial contributions noted
- `SOURCES.md` — applied 4 discovered feed URLs (TLDR AI, The Rundown AI, Ben's Bites, and an unofficial Anthropic blog mirror), flagged orobsonn/claude-harness as dead (404, candidate for removal), added explainx.ai's already-tracked status confirmed, noted @swyx's continued low yield

### Sources to consider adding to SOURCES.md

- **KristopherGBaker/Sparra** — adversarial build harness with evaluator-only holdout wall; directly targets two open KB gaps
- **ruvnet/metaharness** — factory-model harness with Darwin Mode (held-out benchmark-gated self-mutation); one data point so far
- **houshuang/compound-review**, **beingcognitive/unprimed-dialectic**, **chf3198/megingjord-harness**, **cocodedk/loop-engineering** — each cited directly in docs this run but not yet at the "2+ pieces" bar for a tracked row
- **hhamja** — prolific single actor with 5+ same-day loop-engineering/harness repos (loopkit, loopkit-b, my-loopkit, loop-harness, loop-engineering-architecture, claude-code-flywheel); watch for a second wave before promoting

---

## 2026-07-06 15:56 UTC (run)

The largest run to date by raw volume (93 findings pre-dedup across 51 sources, 69 new
after dedup) — split across 7 parallel search agents (Chrome/X/LinkedIn, 2× RSS batch,
HTML sites, 2× GitHub-repo batch, GitHub-search API) plus a manual Phase 3 web/X pass.
A viral (and partly misattributed) "11-page Anthropic loop-engineering PDF" tweet
surfaced this week; traced it back to Addy Osmani's original Jun 2026 Substack post
plus Anthropic's Prithvi Rajasekaran and Stripe's Steve Kaliski as the real primary
sources rather than the "Anthropic senior engineer" the viral tweet claimed.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "'That's loop engineering' — designing the system that prompts the agent" | [link](https://x.com/Sabrina_Ramonov/status/2069763219279773709) | Concise framing of loop engineering as the shift from grinding prompts to designing a system that prompts the agent, checks the work, and runs again. |
| 1 | @bcherny / @ClaudeDevs | "'Reflecting on a year of Claude Code' — anniversary video" | [link](https://www.youtube.com/watch?v=Hth_tLaC2j8) | Boris Cherny and Cat Wu's one-year-anniversary interview covering why auto mode replaced plan mode, how routines fix bugs before the user sees them, and verification best practices. |
| 1 | Addy Osmani | "Loop Engineering (Substack, 'Elevate')" | [link](https://addyo.substack.com/p/loop-engineering) | The primary/origin source of the term 'loop engineering' — defines it as replacing yourself as the person who prompts, lays out five building blocks (automations, worktrees, skills, connectors, sub-agents) plus memory, quotes Peter Steinberger and Boris Cherny from the same week; warns on verification, comprehension loss, token cost. |
| 1 | Andrew Ng (@AndrewYNg) | "The 3 key loops for building 0-to-1 products" | [link](https://x.com/AndrewYNg/status/2071988145667928442) | Framework naming three nested loops at different cadences — agentic coding loop (minutes), developer feedback loop (tens of minutes-hours), external feedback loop (hours-weeks) — citing the loop-engineering buzz sparked by Cherny and Steinberger. |
| 1 | André Lindenberg (LinkedIn, "Artificial Engineering") | "Plan the Loop Before You Build It — the Loop Engineering Canvas" | [link](https://www.linkedin.com/pulse/plan-loop-before-you-build-andr%C3%A9-lindenberg-y0t1e/) | A nine-field planning canvas (modeled on the Business Model Canvas) for deciding whether/how to build a loop before writing harness code — independently converges on the KB's Loop Contract SCOPE/TRIGGER/BUDGET/STOP/verifier structure. |
| 1 | MindStudio Blog | "Claude Code Auto Mode, /goal, and Routines: How to Run Agents Without You" | [link](https://www.mindstudio.ai/blog/claude-code-auto-mode-goal-routines-autonomous-agents-2/) | Explains Auto Mode, /goal, and Routines as composable primitives for unsupervised Claude Code loops — external trigger, goal-anchored execution, stopping conditions. |
| 1 | Nick Puru (@NicholasPuru) | "X Article: 'The Creator of Claude Code Stopped Prompting. He Loops Instead'" | [link](https://x.com/NicholasPuru/status/2074163542954217849) | Field-guide article laying out the five parts every loop needs, /goal and /loop commands, generator/evaluator split, three common failure modes, and where loops are hype vs. genuinely useful. |
| 1 | arXiv | "What makes a harness a harness: necessary and sufficient conditions for an agent harness" | [link](https://arxiv.org/abs/2606.10106) | Operational inclusion/exclusion test distinguishing agent harnesses from frameworks, SDKs, and orchestrators, validated against Claude Code, Codex CLI, Aider, Cline, OpenHands, SWE-agent — a foundational definitional paper for the KB's core vocabulary. |
| 1 | cn-knight/easy-loop-engineering | "easy-loop-engineering — Claude Code/Codex skill configuring loop engineering per-project" | [link](https://github.com/cn-knight/easy-loop-engineering) | Explicitly derived from Addy Osmani + Karpathy's LOOPS.md; agent-neutral skill installer. Not yet deep-read. |
| 1 | cocodedk/loop-engineering | "loop-engineering — fact-checked KB on Boris Cherny's loop methodology" | [link](https://github.com/cocodedk/loop-engineering) | Documents Cherny's three-stage evolution (hand-written code -> parallel Claude sessions -> autonomous loops), core loop anatomy, tags every claim by verification level (primary-source/secondary-coverage/unverifiable) sourced from Sequoia AI Ascent, Lenny's Podcast, X/Threads, Steinberger, Osmani — useful for cross-checking our own KB's citations. |
| 1 | hhamja/loop-harness | "loop-harness — Claude Code plugin: implement-verify cycles, independent verifier, disk-based state" | [link](https://github.com/hhamja/loop-harness) | Cross-model verifier split ('the model that writes the code never grades it'), machine-verifiable stop conditions, 10-iteration safety cap with escalation, disk-based .claude/loop/ state surviving session death. Note: same author published 5 near-duplicate repos same day (loopkit, loopkit-b, loop-engineering-architecture, claude-code-flywheel, my-loopkit) — likely iterative naming churn on one idea. |
| 1 | hiphapis/loopcraft | "loopcraft — persistent memory vault + 5-stage failure-to-knowledge distillation" | [link](https://github.com/hiphapis/loopcraft) | Claude Code plugin framing self-improvement as a system property via self-correction hooks and a 5-stage failure distillation protocol; README not yet deep-read. |
| 1 | krishddd/Strive_Engineering | "feat: close the loop on GitHub — scheduled CI triage, PR proposer, read-only GitHub connector" | [link](https://github.com/krishddd/Strive_Engineering/commit/9e0e6f1d941ff89a43bcc5bc842317f3cb40fcd9) | Ships a daily cron self-triage L1 loop plus a narrowly-scoped GitHub PR proposer as 'the one sanctioned L2 write' — pushes loop/* branches only, never force, PR body carries verifier evidence. |
| 1 | via @sairahul1 thread (X) | "'Loop Engineering: The Anthropic Playbook for Designing Systems That Prompt Your Agents' (11-page PDF)" | [link](https://drive.google.com/file/d/1qzKI4DKnyHRpXK1J3ATPqwaqLc0iNu-M/view) | Independent synthesis (by HuaShu/Alchain, misattributed to an Anthropic engineer in the viral tweet) formalizing loop engineering as a fourth layer above prompt/context/harness engineering, five-move turn cycle, five anti-pattern failures, case studies (Osmani's morning triage, Stripe's 1,300-PR/week 'Minions' pipeline); credits Osmani, Anthropic's Prithvi Rajasekaran, Stripe's Steve Kaliski as actual primary sources. |
| 2 | @Sabrina_Ramonov | "Claude routines run agents on a schedule (claude.ai/code/routines)" | [link](https://x.com/Sabrina_Ramonov/status/2071322746613555386) | Practical routines example (runs skills, connects to MCP, calls APIs to clean up tickets and plan a newsletter) with a linked video tutorial. |
| 2 | Cobus Greyling (Substack) | "LLM Wiki" | [link](https://cobusgreyling.substack.com/p/llm-wiki) | Explains Karpathy's LLM Wiki pattern (raw/, wiki/, index.md, log.md, claude.md; ingest/query/lint workflows) where an LLM compiles and maintains a persistent, cross-linked KB instead of re-deriving it each query. |
| 2 | Daily Dose of Data Science | "The Anatomy of an Agent Harness" | [link](https://www.dailydoseofds.com/p/the-anatomy-of-an-agent-harness/) | Linked from the Loop Engineering piece; lays out an 11-component harness architecture (orchestration loop, verification loops, subagent orchestration, guardrails) and 7 architectural decisions — older (Apr 2026) so may already be covered. |
| 2 | Edwin Lisowski (LinkedIn, "AI-NOVATION CORNER") | "Loop Engineering Explained" | [link](https://www.linkedin.com/pulse/loop-engineering-explained-edwin-lisowski-feime/) | Five-building-blocks overview plus a failure taxonomy addition: thrashing, overfitting to tests, context drift, unsafe autonomy as the four ways loops break. |
| 2 | Happenmass/omux | "omux — tmux-based parallel orchestration of Claude Code/Codex with cross-session memory" | [link](https://github.com/Happenmass/omux) | 106 stars. Orchestrates agents via tmux panes (regex-based state detection) rather than APIs. Auto-continue gate checks goal completion. Execute-then-review: Claude implements, Codex reviews diff independently. Two-tier SQLite memory (global + project) with vector + BM25 search. |
| 2 | JasonxzWen/harness-hub | "Modernize agent harness contracts" | [link](https://github.com/JasonxzWen/harness-hub/commit/bb378e05e04fda7928c71f4ec1737510d659d6fa) | Introduces an 'autonomy envelope' (allowed/forbidden paths, path leases, maxIterations) and a 'Main-Agent Auto-Arbiter' letting the main agent absorb low-risk subagent interrupt questions instead of escalating to the user. |
| 2 | Lenny's Newsletter | "How I run autonomous coding agents from my phone with OpenAI Symphony + Linear" | [link](https://www.lennysnewsletter.com/p/how-i-run-autonomous-coding-agents) | Reframes the operator as an 'agent manager' rather than a step-by-step prompter, using Linear as a state machine and OpenAI Symphony to run parallel autonomous coding agents unsupervised from a phone. |
| 2 | Medium (Adnan Masood) | "Loop Engineering: A Guide for Engineers and Practitioners" | [link](https://medium.com/@adnanmasood/loop-engineering-a-guide-for-engineers-and-practitioners-893bb65ea943) | Argues that designing triggers, topologies, verifiers, and stop rules — not prompt optimization — determines whether agents succeed in production workloads. |
| 2 | MindStudio Blog | "Human-in-the-Loop Checkpoints for AI Agents: Why Full Autonomy Is the Wrong Goal" | [link](https://www.mindstudio.ai/blog/human-in-the-loop-checkpoints-ai-agents-2/) | Argues full autonomy fails via compounding errors; proposes checkpoints before irreversible actions with narrow decision surfaces, instrumenting per-step error rates. |
| 2 | The New Stack | "Andrej Karpathy, Google and Garry Tan agree Markdown is the answer, but they're not solving the same problem" | [link](https://thenewstack.io/markdown-agent-memory-moat/) | Compares three convergent takes on Markdown-as-agent-memory (Karpathy's LLM Wiki, Google's Open Knowledge Format, Garry Tan's 23-role gstack), arguing the moat is shifting to the organizational knowledge agents read/maintain. |
| 2 | arXiv | "NOVA: A Verification-Aware Agent Harness for Architecture Evolution in Industrial Recommender Systems" | [link](http://arxiv.org/abs/2606.27243v2) | Production verification-aware harness using an SGD-inspired 'architecture gradient' to guide modifications, reporting 54.5%/60.0% pass rates on real industrial tasks. |
| 2 | arXiv | "ActPlane: Programmable OS-Level Policy Enforcement for Agent Harnesses" | [link](http://arxiv.org/abs/2606.25189v2) | OS-level policy engine enforcing safety guardrails via kernel integration at 1.9-8.4% overhead, closing the gap between natural-language policy and concrete system actions. |
| 2 | arXiv | "The Hitchhiker's Guide to Agentic AI: From Foundations to Systems" | [link](http://arxiv.org/abs/2606.24937v1) | Comprehensive survey covering the full agentic stack — agent harness design, context management, inter-agent coordination, memory systems — a candidate durable reference for the KB. |
| 2 | arXiv | "AOHP: An Open-Source OS-Level Agent Harness for Personalized, Efficient and Secure Interaction" | [link](http://arxiv.org/abs/2606.23449v1) | Android-based OS-level agent harness treating agents as OS actors, reporting +21.12% task completion and -51.55% token cost versus baseline. |
| 2 | arXiv | "StaminaBench: Stress-Testing Coding Agents over 100 Interaction Turns" | [link](http://arxiv.org/abs/2606.19613v1) | Sustained agent performance benchmark: feedback loops improve results up to 12x and harness quality alone creates up to a 6x performance gap between otherwise-similar models. |
| 2 | arXiv | "SEAGym: An Evaluation Environment for Self-Evolving LLM Agents" | [link](http://arxiv.org/abs/2606.17546v1) | Evaluation environment for self-improving harnesses, showing useful intermediate snapshots can collapse later and source diversity affects harness reliability. |
| 2 | arXiv | "LLM-as-Code: Agentic Programming for Agent Harness" | [link](http://arxiv.org/abs/2606.15874v2) | Proposes program-controlled execution where the LLM is an adaptive component within the program rather than the orchestrator — a novel inversion of the typical harness control-flow model. |
| 2 | arXiv | "ClayBuddy: A Framework, Evaluation, & Mitigation of Coding Agent Failures" | [link](http://arxiv.org/abs/2606.19380v3) | Categorizes coding-agent failures into underspecification, capability errors, and harness errors, proposing agent-editable context with deterministic guardrails as mitigation. |
| 2 | arXiv | "APEX: Adaptive Principle EXtraction — A Three-Layer Self-Evolution Framework" | [link](http://arxiv.org/abs/2606.15363v1) | Co-evolution framework simultaneously improving harness, principles, and workflow topology, raising a composite 'Health Score' from 0.300 to 0.570. |
| 2 | arXiv | "HarnessX: A Composable, Adaptive, and Evolvable Agent Harness Foundry" | [link](http://arxiv.org/abs/2606.14249v2) | Foundry using typed primitives and trace-driven evolution to auto-improve harnesses, reporting average +14.5% (up to +44.0%) gains across five benchmarks. |
| 2 | arXiv | "EurekAgent: Agent Environment Engineering is All You Need For Autonomous Scientific Discovery" | [link](http://arxiv.org/abs/2606.13662v2) | Environment- and budget-engineered system reached state-of-the-art 26-circle packing results for under $11 total API cost — evidence for the KB's BUDGET dimension of the Loop Contract. |
| 2 | arXiv | "Recursive Agent Harnesses" | [link](http://arxiv.org/abs/2606.13643v1) | RAH pattern lets parent agents spawn subagents in parallel recursively, improving a baseline from 71.75% to 89.77% on Oolong-Synthetic with a stronger backbone. |
| 2 | arXiv | "Claw-SWE-Bench: A Benchmark for Evaluating OpenClaw-style Agent Harnesses on Coding Tasks" | [link](http://arxiv.org/abs/2606.12344v1) | Same backbone model scores only 19.1% with a minimal adapter versus 73.4% with a full adapter — strong quantified evidence that harness design, not model choice, drives outcomes. |
| 2 | cobusgreyling/loop-engineering | "feat(loop-guard): size the token budget from loop-cost per pattern (#165)" | [link](https://github.com/cobusgreyling/loop-engineering/commit/927fb7fd936bb39f4620a7bd9f5f83b1989745d5) | loop-init now seeds pattern/level into loop-ledger.json so loop-guard derives its --token-budget automatically from loop-cost's per-run estimate — operationalizes the BUDGET element of a loop's contract. |
| 2 | houshuang/compound-review | "compound-review — multi-model (Claude+Codex+Gemini) review reconciliation" | [link](https://github.com/houshuang/compound-review) | Addresses the cross-model checker arbitration gap: ~85-90% of findings caught by exactly one reviewer (favoring model-family diversity over consensus voting), verdict-driven severity, reconciles via SQLite findings.db with agreement_n tracking. |
| 2 | maxicontieri (Substack) | "The Dirty Secret Behind Loop Engineering" | [link](https://maxicontieri.substack.com/p/the-dirty-secret-behind-loop-engineering) | Contrarian take worth including for balance: argues loop engineering is TDD's red-green-refactor cycle rebranded, and the only real change is who executes the loop (AI vs. human). |
| 2 | via Cobus Greyling (LLM Wiki) article link | "Karpathy's LLM Wiki gist (original source)" | [link](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) | The primary-source gist behind the LLM Wiki pattern cited by both The New Stack and Cobus Greyling this week — worth citing directly per the KB's citation rule. |
| 2 | via Lenny's Newsletter article link | "OpenAI Symphony (open-source multi-agent orchestration framework)" | [link](https://github.com/openai/symphony) | Open-source framework cited as the backbone of a 'zero babysitting' parallel coding-agent loop — an orchestration tool not yet tracked in the KB. |
| 2 | wikieden/vloop | "vloop — three-layer closed-loop engineering across 12 agent backends" | [link](https://github.com/wikieden/vloop) | Plan-execute, acceptance-redesign, and human-review as three distinct loop layers, supporting claude/codex/opencode/gemini/aider/copilot/cursor-agent/droid/amp/qwen/goose/kiro-cli — relevant for cross-harness portability; README not deep-read. |
| 3 | @bcherny | "Subagents run in the background by default (next Claude Code version)" | [link](https://x.com/bcherny/status/2071647677591466098) | Harness design change: subagents now default to running in background so the user can keep talking to the primary agent while subagents work. |
| 3 | @bcherny | "Permission requests forwarded from subagents to main agent" | [link](https://x.com/bcherny/status/2071658948109983827) | Design detail on how sub-agent permission prompts surface to the human via the main agent, plus a 'zoom in' UX to message a subagent directly. |
| 3 | @bcherny | "Five archetypes for engineering/product roles as they melt together" | [link](https://x.com/bcherny/status/2071379474277613732) | Taxonomy (Prototyper, Builder, Sweeper, Grower, Maintainer) for how human roles reorganize on AI-native teams. |
| 3 | @steipete | "Crabbox — remote execution/sandbox tool for coding agents" | [link](https://x.com/steipete/status/2074007001802367446) | Peter Steinberger recommends Crabbox (crabbox.sh), a remote testing/execution control plane for agent sandboxes — leases a cloud machine, syncs local files, streams output, records auditable evidence. |
| 3 | @steipete | "'That's what happens when you use a harness without computer vision'" | [link](https://x.com/steipete/status/2073191273239064731) | Harness-engineering observation that computer-vision integration is a maturity differentiator for agent harnesses. |
| 3 | MindStudio Blog | "Multi-Perspective AI Research: How Sub-Agents Beat Single-Prompt Deep Research" | [link](https://www.mindstudio.ai/blog/multi-perspective-ai-research-sub-agents-vs-deep-research/) | 5-non-overlapping-expert-subagent-plus-synthesis pattern (with a second 'what did they miss' pass) beating single-prompt and massive-parallel-swarm research. |
| 3 | MindStudio Blog | "How to Use the STORM Research Method in Your AI Agent Workflows" | [link](https://www.mindstudio.ai/blog/storm-research-method-ai-agent-workflows/) | Implementing Stanford's STORM multi-perspective research method as a reusable Claude Code skill, claiming 25% more organized output than single-pass research. |
| 3 | MindStudio Blog | "What Is an AI Second Brain Knowledge Base? How to Build One with Claude Code" | [link](https://www.mindstudio.ai/blog/ai-second-brain-knowledge-base-claude-code/) | Building a semantically-searchable personal KB with Claude Code driven by automated hourly processing — a routine/scheduling pattern relevant to loop triggers. |
| 3 | Simon Willison | "sqlite-utils 4.0rc2, mostly written by Claude Fable" | [link](https://simonwillison.net/2026/Jul/5/sqlite-utils-fable/) | Real case study of an agent-driven release cycle (37 prompts, 34 commits, $149.25 in API cost) plus a cross-model maker-checker pattern where GPT-5.5 reviewed Claude Fable's work and vice versa, catching a data-loss transaction bug. |
| 3 | The New Stack | "Why cheaper models alone won't save your AI budget" | [link](https://thenewstack.io/agentic-ai-token-costs/) | Argues token consumption rather than model choice drives agentic cost (150k-200k tokens/task, compounding across multi-agent handoffs); covers context compression/hierarchical routing/semantic caching as mitigations. |
| 3 | Vinay Kolla (LinkedIn, "From Prompt to Product") | "Loop Engineering + Loop Library" | [link](https://www.linkedin.com/pulse/loop-engineering-library-vinay-kolla-mba-wc04c/) | Newsletter framing loops as repeatable workflows with goals/checkpoints/stop-conditions, referencing a resource called 'Loop Library' worth checking as a potential new source. |
| 3 | arXiv | "Reasoning effort, not tool access, buys first-try reliability in agentic code generation" | [link](http://arxiv.org/abs/2607.02436v1) | Observational study of 90 agent runs: raising reasoning effort from High to xHigh lifted first-try-perfect runs from 28% to 89%, while added tools gave minimal benefit. |
| 3 | arXiv | "SWE-Router: Routing in Multi-turn Agentic Software Engineering Tasks" | [link](http://arxiv.org/abs/2607.00053v1) | Routes cheaper models for exploratory turns before escalating to expensive models, conditioning on partial trajectory — a concrete cost-control pattern for loop harness design. |
| 3 | arXiv | "Buildrix: An Open Platform for Sharing and Benchmarking Agentic AI Skills in Building Engineering" | [link](http://arxiv.org/abs/2606.25139v1) | Domain-specific platform combining a local agent harness with skill discovery and progressive context loading for building-engineering tasks. |
| 3 | arXiv | "Building Agent Harnesses for Scientific Curation from Multimodal Sources" | [link](http://arxiv.org/abs/2606.21005v1) | Beaver harness for structured extraction from multimodal scientific sources, outperforming frontier agents by over 23 points on a gold-referenced attribute score. |
| 3 | arXiv | "Transferable Self-Evolving Playbooks for Agentic Security Auditing" | [link](http://arxiv.org/abs/2606.16420v1) | EvoHunt environment evolves security-audit playbooks open-source, improving Codex exploit rate from 1.1% to 6.2% and transferring gains to weaker models. |
| 3 | arXiv | "HarnessBridge: Learnable Bidirectional Controller for LLM Agent Harness" | [link](http://arxiv.org/abs/2606.12882v1) | Learnable bidirectional controller for observations/actions matches or surpasses specialized harnesses while substantially cutting token usage. |
| 3 | cobusgreyling/loop-engineering | "docs: add Cursor PR Babysitter example (#156)" | [link](https://github.com/cobusgreyling/loop-engineering/commit/df8c039a1f0132d8e7f51ba0e72282407fa20b18) | Worked example maps a PR-babysitter loop onto Cursor's Automations, with an explicit progressive-autonomy path — report-only week one, then allowlisted minimal fixes in an isolated worktree, then a separate verifier agent gating fixes with a 3-attempt escalation cap. |
| 3 | codeafix/agent-assistant | "agent-assistant — bounded agent runtime with default-deny MCP policy + Inspect AI eval suite on production code path" | [link](https://github.com/codeafix/agent-assistant) | Touches two gaps: default-deny MCP permission policy, and an Inspect AI eval suite that runs the same code path as production — potentially relevant to held-out-eval-sizing gap. Description-only. |
| 3 | edonadei/caliper | "v0.8.0 — Token & wall-clock tracking, raw-rate scoring, and a unified compare view" | [link](https://github.com/edonadei/caliper/releases/tag/v0.8.0) | Makes raw per-attempt success rate (not pass@k) the primary metric and adds a unified before/after compare view with token/wall-clock deltas. |
| 3 | mcpharbour/mcpharbour | "mcpharbour — MCP agent identity verification + default-deny daemon" | [link](https://github.com/mcpharbour/mcpharbour) | Addresses SECURITY_MATRIX default-deny loading gap: standalone daemon proxying MCP servers with agent identity verification and default-deny tool-level permissions — distinct loading mechanism from CLAUDE.md import/SessionStart hook. Description-only. |
| 3 | omnigent-ai/omnigent | "feat(intent-gate): return ASK instead of DENY for off-task tool calls (#2024)" | [link](https://github.com/omnigent-ai/omnigent/commit/c2060cdf90dc4e18a48f50e49fdd950241055d5b) | Renames intent_gate to Intent Based Authorization and switches its off-task tool-call policy from hard-blocking to prompting the user for approval. |
| 3 | omnigent-ai/omnigent | "docs: add client-side queue + steer design (#1999)" | [link](https://github.com/omnigent-ai/omnigent/commit/91255320663914ad2ba484c5b8ae56fb3784bbb1) | Design doc for a pre-POST client-side message queue (edit/delete/steer/reorder, auto-flush-on-idle) formalizing per-harness steer semantics — a pattern for redirecting a running agent loop mid-turn without breaking it. |
| 3 | saagpatel/cross-provider-egress-guard | "cross-provider-egress-guard — default-deny egress control at tool-dispatch layer" | [link](https://github.com/saagpatel/cross-provider-egress-guard) | Destination-aware default-deny egress control shared across Claude Code and Codex from one policy, enforced at tool-dispatch layer (not CLAUDE.md/SessionStart). |
| 3 | thirai-classlab/hirai-method | "hirai-method — defense-first harness with F1-F3 gates, forced delegation" | [link](https://github.com/thirai-classlab/hirai-method) | Enforcement gate layers (F1 GateGuard requires facts before edits; F2 requires draft-doc approval; F3 ConfidenceGate blocks low-confidence subagent reports), separate from an L1-L5 self-improvement layer. Forced delegation blocks main-agent edits to protected paths. NOT a fleet-maturity model despite F1-F3 naming — false lead on that specific KB gap. |
| 4 | The New Stack | "Apple just turned Safari into something AI agents can control" | [link](https://thenewstack.io/safari-mcp-platform-infrastructure/) | Apple shipped an MCP server in Safari Technology Preview letting agents control the browser, screenshot, inspect DOM, and run accessibility checks — MCP becoming standard platform infrastructure. |

### No new content

- Anthropic (rss) — feed 404 (both `/rss.xml` and `/news/rss.xml` tried); needs URL rediscovery
- The Batch / DeepLearning.AI (rss) — feed 404 (both `/the-batch/feed/` and `/feed/` tried); needs URL rediscovery
- The Rundown AI, TLDR AI, Ben's Bites, AI Breakfast (rss) — all four feeds 404 this run; need URL rediscovery
- Harness Books / AgentWay (html) — fully inaccessible this run (403 on root, `/feed`, `/essays`, `/about`)
- @swyx (x) — keyword search returned zero relevant results; recent activity is unrelated (GPU programming reposts)
- @karpathy (x) — targeted search mostly surfaced old (Feb–Apr) content already covered in prior runs
- explainx.ai (html) — no working `/blog/feed`; index scan (41 pages, all Jul 4–6 dates) found Claude Code/Codex-adjacent posts but none cleared the Tier 3/4 substantive-discussion bar
- swyx.io (rss) — recent posts are off-topic (personal/non-technical)
- Addy Osmani (rss, addyosmani.com) — most recent post (16 Jun) predates last run; see Sources section below — the actual active blog was at the wrong URL all along

### Docs updated this run

- `docs/33-agent-security-hardening.md` — new "Where Default-Deny Actually Gets Loaded" section synthesizing 4 concrete enforcement points (MCP proxy, tool-dispatch layer, OS/kernel, session-bootstrap+eval-parity) that substantially fill the SECURITY_MATRIX loading-mechanism gap; updated the `intent_gate` → "Intent Based Authorization" rename and its DENY→ASK policy softening
- `docs/07-subagents.md` — added primary-source citation for the depth=5 nesting cap (was documented but uncited) plus quantified evidence for recursive subagent spawning (RAH pattern, arXiv 2606.13643)
- `docs/04-verification.md` — added cross-model reviewer arbitration mechanism (houshuang/compound-review: verdict-driven severity, "promote-on-confirm", bounded 3-round reconciliation) — fills half of the cross-model-arbitration KB gap
- `docs/17-failure-patterns.md` — added a 3-category root-cause taxonomy intro (underspecification / capability errors / harness errors, ClayBuddy arXiv 2606.19380) framing the existing pattern table
- `docs/24-harness-patterns.md` — added the definitional-paper citation ("What makes a harness a harness"), StaminaBench + Claw-SWE-Bench quantified harness>model evidence (6x and 4x gaps), and SEAGym + APEX additions to the Self-Improving Harnesses section
- `docs/11-cost-control.md` — added EurekAgent's sub-$11 frontier-result cost benchmark as a BUDGET-dimension example
- `docs/16-memory-patterns.md` — new **Pattern H: LLM Wiki** (dominant theme this run — Karpathy's gist, The New Stack, and Cobus Greyling all covered the same pattern independently this week)
- `docs/23-fleet-engineering.md` — added Org-Chart Coordination pattern (Alook: agents mapped onto reporting lines, coordinating over email)
- `docs/32-reading-list.md` — added HarnessX (arXiv 2606.14249) to Self-Improving Harnesses; **fixed a structural defect**: an orphaned `**Why here:**`/`**Summary:**` pair with no title or citation had been left in "Loops in Production" (likely from a botched edit in a prior run) — removed since it had no verifiable source
- `KB_GAPS.md` — marked 2 gaps filled (SECURITY_MATRIX loading mechanism; the disagreement-resolution half of cross-model arbitration), refined the remaining arbitration question into "which model to pair" (family-diversity evidence, not yet specific pairing criteria), advanced the held-out-eval gap with SEAGym's snapshot-collapse finding, ruled out thirai-classlab/hirai-method as a false lead on F0-F3 fleet maturity
- `SOURCES.md` — fixed Addy Osmani's feed (was pointing at a dormant site; the active "Elevate" Substack carries the origin loop-engineering post), switched OpenAI and Sabrina Ramonov from `html` to `rss` (feeds discovered this run), flagged 6 dead RSS feeds for rediscovery, added Happenmass/omux (2nd repo from an already-tracked author), noted @swyx's low yield

### Sources to consider adding to SOURCES.md

- **Nick Puru** (@NicholasPuru, X) — detailed, well-researched loop-engineering field-guide articles; only one data point so far, watch for a second before promoting to a tracked row
- **André Lindenberg** (LinkedIn, "Artificial Engineering" newsletter) — planning/governance framing (Loop Engineering Canvas) distinct from most sources; one data point so far
- **Prithvi Rajasekaran** (Anthropic) and **Steve Kaliski** (Stripe) — cited as primary sources behind this week's viral PDF; their original posts/talks not yet located directly
- **OpenAI Symphony** (github.com/openai/symphony) — open-source multi-agent orchestration framework, cross-vendor relevance
- Several single-repo GitHub candidates from this run (gomilesf/convergo, houshuang/compound-review, mcpharbour/mcpharbour, codeafix/agent-assistant, saagpatel/cross-provider-egress-guard) were valuable enough to cite directly in docs this run but don't yet clear the "2+ pieces" bar for a tracked SOURCES.md row

---

## 2026-07-04 07:33 UTC (run)

The widest-yield run to date (103 new findings after dedup, from 10 parallel search
subagents across every tracked source plus X/LinkedIn/web). Two genuine additions stand
out against a very large "plateaued wave": an **official Anthropic/Claude-team loop
taxonomy** (turn-based/goal-based/time-based/proactive, with the actual `/goal`/`/loop`/
`/schedule` commands) that complements the existing Claire Vo trigger taxonomy, and a
**quantified cost case** for harness-over-model spend (Hugging Face: 7x cost reduction at
matched accuracy, 3.5%–80.1% score swing from harness quality alone, model+tasks fixed).
The rest of the field is dominated by a much larger version of last run's plateaued
maker/checker + loop-kit wave — dozens of low-star repos re-implementing trigger/state/
verifier primitives already in the KB — with a handful of genuinely new mechanisms pulled
out individually (findings ratchet, blind-spot ledger, severity-proportional reviewer
routing, tamper-evident contract hashing, harness security scorecard, skill-ingestion
security gate).

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | arXiv | "Stop Hand-Holding Your Coding Agent: Engineering the Loops that Replace Step-by-Step Prompting" | [link](https://arxiv.org/abs/2607.00038v1) | Formal definitional paper: loop specification (trigger, goal, verification, stopping rule, memory) as a reusable artifact, naming comprehension debt and cognitive surrender as risks — restates the KB's existing framing with academic rigor, no doc change needed. |
| 1 | Anthropic (claude.com blog) | "Getting started with loops" | [link](https://claude.com/blog/getting-started-with-loops) | Official Claude team loop taxonomy (turn-based/goal-based/time-based/proactive) with the actual `/goal`/`/loop`/`/schedule` commands. **New — added to docs/24** alongside the existing Claire Vo taxonomy. |
| 1 | via Hugging Face (Joel Niklaus) | "Don't train the model, evolve the harness" | [link](https://huggingface.co/spaces/joelniklaus/harness-optimization) | Proposer/accept-reject loop rewriting only harness code around a frozen model: matches Sonnet 4.6 at ~7x lower cost; 3.5%–80.1% score swing from harness quality alone. **Added to docs/24 and the reading list.** |
| 1 | via TLDR AI | "WTF Is a Loop? Peter Steinberger vs. Boris Cherny" (Matt Van Horn) | [link](https://x.com/mvanhorn/status/2063865685558903149) | Traces the "loop" meme's five-year lineage (ReAct 2022 → AutoGPT → ralph loop → /loop and /goal) and captures Cherny's verbatim on-stage quote — good lineage reference, already well-covered by existing reading-list entries; no doc change. |
| 1 | dailydoseofds.com (Avi Chawla) | "Loop Engineering, Clearly Explained" | [link](https://www.dailydoseofds.com/p/loop-engineering-clearly-explained/) | Four-layer stack (prompt/context/harness/loop) + four failure modes (false completion, context rot, tool design, self-grading) closely paralleling the KB's own framing. **Source added to SOURCES.md** (3+ high-engagement pieces this cycle). |
| 1 | LinkedIn — Nabheet Madan | "Loop engineering: an agentic coding agent closes its own loop" | [link](https://www.linkedin.com/pulse/loop-engineering-agentic-coding-agent-closes-its-own-nabheet-madan-tkpwf/) | Case study ("FlashStock"): Claude Code self-corrected a race condition and idempotency bug across iterations; argues evals — not codegen — are what let a loop run unattended. Consistent with existing KB thesis; no doc change. |
| 2 | gomilesf/convergo | "Fresh-reviewer exit gate + findings ratchet" | [link](https://github.com/gomilesf/convergo) | Hard 3-round cap escalating to human; a findings ratchet prevents re-litigating previously-invalidated findings without fresh evidence; final exit requires a newly-spawned reviewer. **New failure-pattern row added to docs/17** ("Zombie finding"). |
| 2 | ohyesgocool/feature-loop + hiphapis/loopcraft | "Blind-spot ledger — append-only 'why I missed it' log" | [link](https://github.com/ohyesgocool/feature-loop) | Two independent implementations of a review-miss ledger read by the next cycle so recurring finding categories get pre-checked; success metric is "reviewers stop finding the same category twice." **New subsection added to docs/16.** |
| 2 | orobsonn/claude-harness | "v0.20.0 — severity-proportional eye routing + conditional re-gate" | [link](https://github.com/orobsonn/claude-harness/releases/tag/v0.20.0) | Extends "strong eyes, cheap hands" from a fixed role split to a `resolveEyeTier` function that routes by change severity/sensitivity; grave fixes require a fresh full-Opus pass. **Added to docs/07.** |
| 2 | Aitne-sh/loop-kit | "Contract-hash tamper defense + 8 named exit codes" | [link](https://github.com/Aitne-sh/loop-kit) | Hashes the Product Contract at approval time (`NEEDS_SPEC_DECISION` on tamper); expands the 3-exit-code stop taxonomy to 8 named codes distinguishing failure classes. **Added to docs/27** as an extension of the existing 3-exit-code reference. |
| 3 | saagpatel/harness-scorecard | "A-F security maturity grader for harnesses" | [link](https://github.com/saagpatel/harness-scorecard) | Grades harnesses across 10 security dimensions with capability gates and vulnerable/fixed fixture pairs. **Added to docs/33** as a complementary audit tool. |
| 3 | eugenelim/agent-ready-repo | "OWASP Agentic Skills Top 10 (AST01-AST10) + mandatory reviewer-only ingestion gate" | [link](https://github.com/eugenelim/agent-ready-repo/commit/715144f) | Skill-ingestion supply-chain security checklist plus a non-automatable human/independent-reviewer gate before a new skill is assimilated. **Added to docs/33**, fills the "skill supply-chain security" KB gap. |
| 2 | JeiKeiLim/tenet | "Model-tier-adaptive plans, grounded/ungrounded critic split, doctrine drift, Delivery Modes" | [link](https://github.com/JeiKeiLim/tenet/commit/c37b246) | Repositions as "the agent harness for long, reliable autonomous development"; self-healing doctrine-drift and autonomous-vs-agile delivery cadence. Extends already-tracked repo; no new primitive beyond what docs/24's harness-agnostic framing covers — noted, no doc change this run. |
| 2 | via @akshay_pachaar thread | "Alook — turn coding agents into a real AI company org chart" | [link](https://github.com/alookai/alook) | ~540★; gives each agent session a role, a real email inbox, and an org-chart position for unattended coordination — a new fleet-coordination surface; noted for a future fleet-engineering pass, no doc change this run. |
| 2 | via @akshay_pachaar thread | "Google Agents CLI (built on ADK)" | [link](https://github.com/google/agents-cli) | ~4.7k★; unifies scaffolding, LLM-as-judge evaluation, and deployment for agentic engineering — a major-vendor tooling entrant; noted, no doc change this run. |
| 1 | dailydoseofds.com / @GAZUA_KOR repost, arXiv, Cobus Greyling, TLDR AI, Ben's Bites, MindStudio, VibeReady, explainx.ai, Flowtivity, Blake Crosley, LinkedIn (Vinay Kolla, Linas Beliūnas), @dnvhariprasad, @Sabrina_Ramonov | ~25 additional origin-story / definitional / "getting started" pieces | — | Large convergent wave restating the KB's existing paradigm-shift and getting-started framing (Steinberger's viral tweet, Cherny's WorkOS quote, Osmani's five-building-blocks thread, LangSmith Engine, Factory 2.0, Crabfleet). All already well-covered by docs/01–03, docs/21, docs/28, and the reading list; no doc changes warranted. Full list in `.loop-news/findings.json`. |

### No new content — plateaued wave (no new primitive)
- **~75 additional GitHub repos** from github-search (maker/checker clones, loop-kit starters, harness marketplaces, review-orchestration plugins) restate trigger/state/verifier/maker-checker primitives already documented across docs/04, docs/07, docs/24, docs/27, docs/34. None introduced a mechanism not already covered or pulled out above. Full list with per-repo summaries in `.loop-news/findings.json`.
- Large arXiv harvest (SEAGym, APEX, Recursive Agent Harnesses, LLM-as-Code, EvoHunt, NOVA, Hitchhiker's Guide to Agentic AI, StaminaBench, ClayBuddy, ActPlane, AOHP, Code Isn't Memory, Beaver, HarnessBridge, Claw-SWE-Bench, EurekAgent, AutoMegaKernel, MyPCBench, "What makes a harness a harness", SWE-Router) — all reinforce the already-documented self-improving-harness and harness>model theses with additional benchmarks; no new primitive.
- Addy Osmani full back-catalogue, Simon Willison, Anthropic harness-design article, Martin Fowler, vtrivedy HaaS piece — all predate `last_run_date` and are already integrated into the KB (docs/01, docs/03, docs/24).
- cobusgreyling/loop-engineering — new CLI tooling (loop-audit/init/cost/sync/context) reported again this run; same toolchain already tracked and noted in a prior digest (2026-06-29). Already a SOURCES.md row — no action.
- Kanevry/session-orchestrator, BicaMindLabs/FuguNano — re-surfaced with the same features already noted in the 2026-06-30 and 2026-07-02 digests respectively; no new activity.
- OpenAI news, Harness Books (agentway.dev) — 403 (ongoing)
- Sabrina Ramonov (sabrina.dev) — no discoverable RSS feed; no Tier 1-3 content this run

### Docs updated this run
- `docs/24-harness-patterns.md` — added the official Claude-team loop taxonomy (turn-based/goal-based/time-based/proactive) cross-referenced against Claire Vo's; added the Hugging Face harness-cost quantification (7x cost reduction).
- `docs/33-agent-security-hardening.md` — new "Skill Ingestion Security (OWASP Agentic Skills Top 10)" section; new "Grading Harness Security Posture" section (saagpatel/harness-scorecard).
- `docs/27-loop-contract.md` — new "Extension: tamper-evident contracts and named exit codes" subsection under the three-exit-code reference (Aitne-sh/loop-kit).
- `docs/17-failure-patterns.md` — new "Zombie finding" failure-pattern row (findings ratchet, gomilesf/convergo).
- `docs/16-memory-patterns.md` — new "blind-spot ledger" subsection (ohyesgocool/feature-loop, hiphapis/loopcraft).
- `docs/07-subagents.md` — extended "Strong Eyes, Cheap Hands" with severity-proportional eye-tier routing (orobsonn/claude-harness v0.20.0).
- `docs/32-reading-list.md` — added "Don't Train the Model, Evolve the Harness" (Hugging Face) to Self-Improving Harnesses.

### Structural review this run (Phase 4c)
- The finding-set was **not** theme-shifting — a very large plateaued wave (see above) plus a handful of genuinely new, individually-addable mechanisms, each already owned by an existing doc's topic (verification/subagents/security/memory/loop-contract). No dominant theme lacking a canonical home; no new thesis; no unrepresented primitive.
- Two items sharpen existing theses rather than fragment them: the official Claude-team loop taxonomy sits *alongside* Claire Vo's in docs/24 (same section, cross-referenced, not a competing doc) and the Hugging Face cost finding extends the harness-conformance/self-improving-harness passage already in docs/24 with a cost multiplier.
- No index restructure, doc merges, or renames → PATCH, not MAJOR.

### Sources to consider adding to SOURCES.md
- All actionable candidates from this run were added directly (see SOURCES.md changes below) rather than left pending: [JasonxzWen/harness-hub](https://github.com/JasonxzWen/harness-hub) and [edonadei/caliper](https://github.com/edonadei/caliper) (both deep-read this run per last run's flag, scored ≥3.5/5 avg), [explainx.ai](https://explainx.ai/blog/) (3+ runs of "worth tracking" flags, now overdue), and [Daily Dose of Data Science](https://www.dailydoseofds.com) (Avi Chawla — 3+ high-engagement pieces this cycle).
- Not added: [jahwag/clem](https://github.com/jahwag/clem) is already the foundational source for docs/33 (mis-flagged as new by this run's github-search subagent, which lacked the full tracked-source list); [Armin Ronacher](https://lucumr.pocoo.org/) — still only the one 2026-06-23 piece, continue watching per the 2026-07-01 note.

---

## 2026-07-03 04:12 UTC (run)

A **gap-sharpening** run. The standout is a quantified BUDGET finding that inverts a common
instinct: a 90-run observational study shows **reasoning effort — not tool access — buys
first-try reliability** (first-try-perfect 28%→89% for +9–29% cost; a bolted-on testing tool
added 42–68% cost with *zero* reliability gain). It lands cleanly on the design spine's
*how much?* question and extends `docs/11`'s effort-levels section with the counterintuitive
rule: when reasoning is the bottleneck, spend the marginal dollar on effort before adding
checker passes. The rest of the field is the **plateaued maker/checker + orchestrator wave**
the last run flagged — dozens of low-star Claude-author⇄Codex-reviewer clones and orchestrators,
plus a HarnessX-derived failure-taxonomy restatement and an incremental omnigent release — none
adding a new primitive.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 2 | arXiv | "Reasoning effort, not tool access, buys first-try reliability in agentic code generation" | [link](https://arxiv.org/abs/2607.02436) | **BUDGET finding (new to KB).** 90-run study (same spec'd app, 14-criterion rubric): raising effort high→xhigh lifts first-try-perfect **28%→89%** (~5× fewer corrective prompts) for **+9–29%** cost; a testing tool added **42–68%** cost with **no** functional/reliability gain. Reasoning budget beats checking mechanisms when weak reasoning is the root cause. Folded into `docs/11`. |
| 2 | Cobus Greyling | "The Anatomy of Agent Failure" | [link](https://cobusgreyling.substack.com/p/the-anatomy-of-agent-failure) | Five *contextual* failure signatures across benchmarks (GAIA blocked-source 39%, ALFWorld search-inefficiency ~89%, WebShop attribute-mismatch, τ-Bench premature actions, SWE-bench incomplete-fix 62%); argues for trace-driven adaptation over bigger models. Derived from the HarnessX paper already in `docs/24` — restatement + data, no doc change. |
| 1 | omnigent-ai/omnigent | "v0.4.0 — Polly fan-out orchestration, Harness Plugin SDK, model-routing judge" | [link](https://github.com/omnigent-ai/omnigent/releases/tag/v0.4.0) | Meta-harness release: fan-out across coding sub-agents; a server-side judge that picks the best harness+model per turn (a selection loop); Harness Plugin SDK packaging custom agents as installable plugins; sub-agent cost budgeting + intent-gating. Extends the already-documented meta-harness (docs/24) — no new primitive, no doc change. |
| 3 | eugenelim/agent-ready-repo | "agentbundle show <pack> — live pack inventory (RFC-0060)" | [link](https://github.com/eugenelim/agent-ready-repo/commit/94a9dda11bbbe6526427dd6d39e530dce9ce4a19) | Derives pack contents *fresh* on each call by walking the `.apm/` source tree rather than persisting, to prevent drift between reported and actual inventory — a small "verify-don't-cache" packaging pattern. Already implied by docs/24's harness-agnostic projection; no doc change. |

### No new content
- Anthropic RSS / The Batch / The Rundown AI / TLDR AI / Ben's Bites / AI Breakfast — feed 404 (ongoing)
- OpenAI news / Harness Books (agentway.dev) — 403 (ongoing, not re-fetched this run)
- Tracked repos with no post-cutoff substantive commit: cobusgreyling (all three), graphiti, tenet, loopflow, loop-kernel, claude-harness, ecc, Strive_Engineering, Cliclaw, herdr-loop-lab, peterCheng, claude-deep-loop, ctxcarry, zeroshot
- github-search — high volume but all plateaued-wave clones (maker/checker, orchestrators, eval harnesses); only harness-hub / caliper noted below
- X profiles / X live search / LinkedIn — browser pass not run this session (budget); no X/LinkedIn findings recorded

### Docs updated this run
- `docs/11-cost-control.md` — **new "Reasoning effort is the dominant reliability lever" subsection** under Effort levels: quantified table (first-try-perfect 28%→89% for +9–29%; testing tool +42–68%, no gain) + the rule to spend on effort before checker passes when reasoning is the bottleneck; cross-linked to docs/04 so it does not read as overriding the independent-verifier mandate (arXiv 2607.02436).
- `LOOP_ENGINEERING.md` — refreshed the docs/11 index summary.

### Structural review this run (Phase 4c)
- The finding-set was **not** theme-shifting — one genuine new data point plus restatements of already-owned themes (failure-mode taxonomy → docs/24 self-improving harnesses; meta-harness release → docs/24). No dominant theme lacking a home; no new thesis; no primitive unrepresented.
- The reasoning-effort finding sharpens the design spine's **BUDGET / *how much?*** question and sits in its canonical home (docs/11) — a consolidation, not a fragmentation. Added exactly one cross-reference (docs/11 → docs/04) so the new "effort beats checkers" guidance can't be misread as weakening the independent-verification mandate.
- No index restructure, doc merges, or renames → PATCH, not MAJOR.

### Sources to consider adding to SOURCES.md
- [JasonxzWen/harness-hub](https://github.com/JasonxzWen/harness-hub) (85★) — a release-oriented "harness skill hub" + CLI that analyzes repos and installs harness profiles; a *harness-distribution/marketplace* angle not yet tracked. Deep-read next run before adding.
- [edonadei/caliper](https://github.com/edonadei/caliper) (24★) — local-first eval harness for Claude Code / Codex / Pi skills; watch as an eval-harness reference alongside affaan-m/ecc.

---

## 2026-07-02 04:14 UTC (run)

A **theme-shifting** run, not gap-filling. Two convergent themes dominated, and the first of
them fills a standing KB gap: **(1) self-improving harnesses** — three independent sources
(two arXiv papers + one article/preprint) all report a harness that *evolves itself from its
own execution traces*, model held fixed, with real Terminal-Bench numbers (one **beats a
human-designed baseline**); and **(2) durable, repo-owned state that survives compaction** —
progress files as dynamic-programming memo tables, `.ctxcarry/`-style repo-owned context, and a
kernel that is the *sole authorized writer* to that state. The self-improving-harness theme
closes the documented "self-scaffolding / model-generated harness" gap; the state theme
sharpens the memory-vs-context boundary rather than adding a new primitive.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | arXiv | "Self-Harness: Harnesses That Improve Themselves" | [link](https://arxiv.org/abs/2606.09498) | **Self-improving harness**: 3-stage loop (Weakness Mining from traces → minimal Harness Proposal → regression Validation) with no external engineer; Terminal-Bench-2.0 gains, model fixed (MiniMax 40.5→61.9%, Qwen3.5 23.8→38.1%, GLM-5 42.9→57.1%). Fills the model-generated-harness gap. |
| 1 | arXiv | "Agentic Harness Engineering (AHE): observability-driven evolution" | [link](https://arxiv.org/abs/2604.25850) | Harness auto-evolves via three observability pillars (component/experience/decision); each edit is a **verified prediction contract**. Pass@1 69.7→77.0% over 10 iters, **beats human Codex-CLI baseline (71.9%)**, 12% fewer tokens, cross-family transfer; **ablation: gains from tools/middleware/memory, not prompts**. |
| 2 | Cobus Greyling | "HarnessX: When the Harness Starts Learning From Its Own Runs" (+ [arXiv 2606.14249](https://arxiv.org/abs/2606.14249)) | [link](https://cobusgreyling.substack.com/p/harnessx-when-the-harness-starts) | Third self-improving-harness source: **typed harness primitives over a substitution algebra** + AEGIS evolution engine refining prompts/tools/memory/control-flow from traces; +14.5% avg across 5 benchmarks (up to +44%). |
| 1 | peterCheng123321/loop-engineering | "Progress-ledger as a DP memo table" | [link](https://github.com/peterCheng123321/loop-engineering) | **Durable convergence**: a checklist caches solved steps and an append-only decision log prunes failed branches, so the loop never recomputes a settled sub-problem after a context reset — convergence moves from model memory to durable artifacts. Convergence layer over /loop, ralph-loop, Agent SDK. |
| 1 | shouryasrivastava/ctxcarry | "The repo should own your context, not the agent" | [link](https://github.com/shouryasrivastava/ctxcarry) | Local-first `.ctxcarry/` durable memory (state/events/summaries) vs. cloud transcript replay; worktree generators, evaluators-assume-broken, token-budgeted multi-tool (Claude/Codex/local) handoff. |
| 1 | Sungmin-Cho/claude-deep-loop | "2-plane kernel control plane" | [link](https://github.com/Sungmin-Cho/claude-deep-loop) | **Control-plane/execution-plane split**: kernel is the *only* authorized writer (state machines, budget, circuit breakers, integrity log, handoff); skill agents are read-only and mutate only via kernel subcommands — governance enforced by architecture, not model compliance. |
| 1 | MindStudio | "Claude Code Auto Mode, /goal, and Routines: Run Agents Without You" | [link](https://www.mindstudio.ai/blog/claude-code-auto-mode-goal-routines-autonomous-agents-2) | Combines auto mode + /goal + routines for hands-off scheduled runs. On-thesis for TRIGGER/BUDGET/STOP but a restatement of material already in docs/08/28/30 — no doc change. |
| 3 | the-open-engine/zeroshot | "Blind validation / information-asymmetry reviewers" (~1.6k★) | [link](https://github.com/the-open-engine/zeroshot) | Validators receive **only outputs, never the maker's reasoning** — so they can't inherit buried assumptions or collude ("can't lie about code they didn't write"); reject-and-retry until all approve. Anti-collusion rationale, now a first-class rule in docs/04. |
| 3 | MindStudio | "Multi-Perspective AI Research: Sub-Agents beat single-prompt" | [link](https://www.mindstudio.ai/blog/multi-perspective-ai-research-sub-agents-vs-deep-research) | Five role-differentiated expert sub-agents + a synthesis layer that maps agreements/disagreements; value from perspective *diversity*, not redundancy. Maps to existing docs/07 synthesis-bottleneck + confidence-gate coverage — no doc change. |
| 4 | The New Stack | "OpenClaw's app doesn't run AI on your phone — that's the point" | [link](https://thenewstack.io/openclaw-persistent-agent-architecture/) | Persistent long-running agents run off-device; the phone app is just an authenticated endpoint (pattern shared by Claude Dispatch, OpenAI). Architectural context for where the loop runs; already covered by routines (docs/28). No doc change. |

### No new content
- Anthropic RSS / The Batch / The Rundown AI / TLDR AI / Ben's Bites / AI Breakfast — feed 404 (ongoing)
- OpenAI news / Harness Books (agentway.dev) — 403 (ongoing)
- @bcherny, @karpathy, @AndrewYNg, @swyx, @steipete (OpenClaw community banter, no new technique), @Sabrina_Ramonov (newest post Jun 27, pre-cutoff), @akshay_pachaar — no new keyword-matching posts after last run
- swyx.io, sabrina.dev, Addy Osmani, Simon Willison, Lenny's — nothing after 2026-07-01
- X live keyword search — only promo (StrategiX) and generic vibe-coding noise
- Tracked repos with no substantive new concept: cobusgreyling (all three), omnigent, graphiti, tenet, loopflow, loop-kernel, ecc, Strive_Engineering, Cliclaw, herdr-loop-lab; ~7 new maker/checker clones skipped (plateaued wave)
- orobsonn/claude-harness — new commit (run-record-anchored capture-verified gate) folded into docs/04 as a refinement, not a separate row (repo URL already in the digest)

### Docs updated this run
- `docs/24-harness-patterns.md` — **new section "Self-Improving Harnesses"** (Self-Harness / AHE / HarnessX; trace-driven evolution, verified prediction contracts, ablation — fills the model-generated-harness gap) + **"Control-Plane / Execution-Plane Split"** (kernel-gated mutation; claude-deep-loop)
- `docs/16-memory-patterns.md` — **new "Pattern G: Repo-Owned Durable Ledger"** (ctxcarry — repo owns context; progress.md as DP memo table — peterCheng)
- `docs/04-verification.md` — **information-asymmetry / blind validation** (zeroshot: checker never sees the maker's reasoning) + **run-record-anchored capture gate** (orobsonn refinement to frozen-tests pattern)
- `docs/32-reading-list.md` — **new group "Self-Improving Harnesses"** with AHE (anchor — beats human baseline + ablation) and Self-Harness
- `LOOP_ENGINEERING.md` — refreshed the docs 24 / 16 / 04 summaries and the reading-list row
- `KB_GAPS.md` — closed "self-scaffolding / model-generated harness"; added "held-out eval construction for harness evolution"
- `SOURCES.md` — added arXiv research feed + 4 repos (peterCheng123321/loop-engineering, Sungmin-Cho/claude-deep-loop, shouryasrivastava/ctxcarry, the-open-engine/zeroshot)

### Structural review this run (Phase 4c)
The finding-set was theme-shifting, so the review was substantive:
- **Dominant theme with no canonical home → consolidated, not fragmented.** Self-improving harnesses recurred across 3 findings and had no home. Per the consolidation rule, it became a **named section inside docs/24** (which owns the harness parent-topic) rather than a new doc — cross-referenced to docs/22 (learned orchestration is *training a model*; self-improving harness keeps the model fixed and evolves the *config*) and docs/04 (the validate stage is a verification gate). If it keeps growing it can be promoted to its own doc later.
- **Missing thesis added.** The three papers converge on a claim the KB only implied — *the harness is an optimization target with measurable returns, and it can optimize itself*. Stated outright at the top of the new docs/24 section, extending the existing quantified harness>model thesis.
- **Second theme sharpened an existing boundary, no new doc.** Durable repo-owned state landed as docs/16 Pattern G, cross-linked to docs/13 (compaction) and the docs/24 kernel section (the sole-writer that governs such a ledger) — keeping the memory/context/harness spine coherent instead of spawning a "state" doc.
- No index restructure or doc renames → not MAJOR.

### Sources to consider adding to SOURCES.md
- All four candidate repos were added this run (see Docs updated). No further additions pending.
- Next arXiv pass: now that the arXiv feed is tracked, watch for follow-ups citing Self-Harness / AHE (held-out-eval methodology is the open question — see KB_GAPS).

---

## 2026-07-01 12:35 UTC (run)

A **gap-driven** run, not another saturation pass. The harness-repo wave has plateaued
(≈6–8 new-but-redundant maker/checker clones seen and skipped), but the KB-gap-targeted
searches paid off: this run **filled three documented gaps** — mid-session credential
rotation, a-priori goal-cost estimation, and (partially) the SECURITY_MATRIX default-deny
mechanism — plus added the first *quantified* evidence for the harness-over-model thesis.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 2 | LangChain | "The Anatomy of an Agent Harness" | [link](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness) | **Quantified harness>model**: moved a coding agent "Top 30 → Top 5 on Terminal Bench 2.0 by only changing the harness" (Opus 4.6, model held fixed) — hardest evidence yet that harness design is the accessible leverage. |
| 3 | rashmi1112/Credential-Sentinel | "Discover-and-rotate loop with verify-before-revoke" | [link](https://github.com/rashmi1112/Credential-Sentinel) | **Fills the credential-rotation gap**: promote→repoint→verify cutover, old credential revoked only after verify passes (rollback to still-valid old on fail); 4-state classify with default-deny on unknowns; two human gates. |
| 2 | cobusgreyling/goal-engineering | "goal-cost CLI (v1.1.0)" | [link](https://github.com/cobusgreyling/goal-engineering) | **Fills the goal-cost gap**: `goal-cost --pattern <p> --level <G>` forecasts token/budget for a goal *pattern* before the run — a-priori, pattern-keyed, feeds the Budget primitive. |
| 2 | omnigent-ai/omnigent | "Runtime policy engine + harness-bench" | [link](https://github.com/omnigent-ai/omnigent/commits/main) | Policy layer: `blast_radius` (bound action impact), `intent_gate` (default-deny vs. stated intent — partial SECURITY_MATRIX fill), `detect_task_switch` (mid-run goal-change detection), phase-scoped tool access; plus `harness-bench` (harness capability conformance testing — a new eval primitive). |
| 3 | Simon Willison | "shot-scraper video" | [link](https://simonwillison.net/2026/Jun/30/shot-scraper-video/) | Two patterns: **video-as-proof-of-work** (agent writes a YAML storyboard, Playwright records a demo as a human-viewable verification artifact) and **`--help` as embedded SKILL.md** (write help detailed enough that an agent self-onboards — capability travels with the binary). |
| 3 | MindStudio | "Human-in-the-Loop Checkpoints" | [link](https://www.mindstudio.ai/blog/human-in-the-loop-checkpoints-ai-agents) | **Where** to place checkpoints: 4 tests (irreversibility / confidence / external-visibility / context-gap), 2–3 checkpoints at ~80/20 auto:human, and the **override-rate** calibration ("approving 95% unchanged → the checkpoint is unnecessary"). |
| 4 | Claire Vo (Lenny's) | "Sonnet 5 review: 64 generations / How I AI Bench" | [link](https://www.lennysnewsletter.com/p/sonnet-5-review-i-ran-64-generations) | Reusable eval harness built in Claude Code <45 min from stored sessions; blind model comparison scored **70% human vibe / 30% LLM-judge** with a local HTML→JSON scoring page — an explicit blended-grading weight. |
| 3 | orobsonn/claude-harness | "Thinking-quality Stop hook + loop-design-check" | [link](https://github.com/orobsonn/claude-harness/commits/main) | A Stop hook that adjudicates *reasoning-trace* quality at session end (distinct from output-correctness gates) + a skill that lints the loop's own design. Marginal; noted. |
| 2 | cobusgreyling/loop-engineering | "loop CLI toolchain (loop-init/audit/cost)" | [link](https://github.com/cobusgreyling/loop-engineering) | Tracked repo shipped a CLI toolchain (`loop-init` scaffold, `loop-audit` inspect agent loops, `loop-cost` track spend) + opencode/openclaw 7/7 harness coverage. |

### No new content
- Anthropic RSS / The Batch / The Rundown AI / TLDR AI / Ben's Bites / AI Breakfast — feed 404/403 (ongoing; The Batch feed URL still needs revisiting)
- OpenAI news / Harness Books (agentway.dev) — 403 (ongoing)
- @bcherny, @karpathy, @AndrewYNg (0-to-1 framework being re-amplified — already in KB), @swyx, @steipete, @Sabrina_Ramonov, @akshay_pachaar — no new keyword-matching posts after last run
- swyx.io, sabrina.dev, Addy Osmani, Simon Willison (other posts), Cobus Greyling (Substack) — nothing after 2026-06-29
- X live keyword search — promo (EverMind "Raven"), jokes, thesis restatements, and a quant-trading *application* (no new technique)
- Tracked repos with no substantive new concept: getzep/graphiti, agent-ready-repo, loopflow, Monad-Harness, loop-kernel, JeiKeiLim/tenet (release-loop commit not yet documented — recheck next run), ecc (v0.18.x "second-eye nudge" = redundant with strong-eyes/cross-model review)
- GitHub search — ~6–8 new maker/checker/harness clones, none novel; `"halt condition" claude loop` and `acting_on` → 0 results

### Docs updated this run
- `docs/33-agent-security-hardening.md` — added **Credential Rotation Mid-Session** (verify-before-revoke cutover; fills gap) and **Runtime Policy Gating** (blast_radius / intent_gate / phase-scoped; partial SECURITY_MATRIX default-deny fill)
- `docs/30-goal-engineering.md` — added **A-Priori Goal-Cost Estimation** (pattern-keyed pre-run forecast; fills gap)
- `docs/14-human-in-the-loop.md` — added **Where to Place a Checkpoint** (4 tests, 80/20, override-rate calibration)
- `docs/24-harness-patterns.md` — added quantified harness>model evidence (LangChain Top30→Top5) + **harness conformance testing** (harness-bench)
- `docs/04-verification.md` — added **70/30 human-LLM blended grading** and **proof-of-work demo artifacts** (video-as-verification)
- `docs/06-skills.md` — added **agent-legible tools** (`--help` as embedded SKILL.md)
- `docs/17-failure-patterns.md` — enriched the Context-drift row with `detect_task_switch` (mechanical mid-run goal-change detection)
- `KB_GAPS.md` — closed credential-rotation and goal-cost gaps; re-scoped SECURITY_MATRIX to the loading mechanism

### Structural review this run (Phase 4c)
The finding-set was gap-filling, not theme-shifting: each finding landed in an existing
canonical home (security→33, verification/eval→04, HITL→14, harness→24, goal→30, skills→06),
so no new docs and no index restructure were needed — the design spine absorbed it. The
one thesis-level upgrade is that "the harness matters more than the model" now carries a
**quantified** anchor (LangChain Top30→Top5) rather than only quotes; added to docs/24
where the thesis already lives.

### Sources to consider adding to SOURCES.md
- **arXiv** — "Self-Harness: Harnesses That Improve Themselves" (2606.09498) and "Agentic Harness Engineering" (2604.25850): self-improving harnesses with Terminal-Bench gains; pre-cutoff but not yet mined — worth a dedicated arXiv pass next run
- LangChain blog (langchain.com/blog) — now a strong quantified harness source; consider tracking
- jtoemion/revolver-plugin — credential rotation-on-auth-error fallback (README 404 this run; recheck via master/docs)

---

## 2026-06-30 04:00 UTC (run)

A third consecutive GitHub-dominated run, and the live repo searches converged on a
single, sharper theme: **cross-model maker/checker** — harnesses where **Claude
implements and a *different* model (Codex) reviews**. Four independent repos updated
Jun 28–30 (Cliclaw, loope, herdr-loop-lab, forja) all build the same shape: the reviewer
runs on a different model so it doesn't share the implementer's training blind spots, emits
a structured `VERDICT: PASS / BLOCK` (+ advisory `SUGGEST`), and completion is gated on a
**dual stop condition** — mechanical test exit 0 *and* no reviewer `BLOCK`. This is the
genuinely new mechanism of the run: prior verifier-integrity work kept the checker
*structurally* independent (fresh context, external command); this adds a **model-diversity**
axis. Canonised as **Pattern 5 (cross-model independence)** in the Verifier Integrity section
of `docs/04`, with a cross-ref from `docs/07`. Strive_Engineering also shipped a second new
verifier mechanism — the **isomorphic-perturbation check** (validate each claim under two
independent-but-equivalent tests; passing one but not its equivalent flags a single-predicate
reward-hack). On the article side, Lenny's published the strongest production case study in
weeks (Gusto's "trash-can method"), added to the reading list.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | Happenmass/Cliclaw | "Claude + Codex parallel subagents over tmux" | [link](https://github.com/Happenmass/Cliclaw) | Cross-model execute-then-review (Claude implements, Codex reviews, roles swappable); auto-continue *gate model* decides at natural stopping points whether to iterate; tmux-pane state scraping for hook-free state detection; two-tier hybrid memory (sqlite-vec + FTS5 BM25). 107★. |
| 1 | mateaix/loope | "Claude implements, Codex reviews until code is right" | [link](https://github.com/mateaix/loope) | Clean cross-model maker/checker; **dual stop**: terminates only when test cmd exits 0 AND reviewer issues no `BLOCK`; structured `VERDICT: PASS/BLOCK` + non-blocking `SUGGEST`; parallel reviewers aggregate "any blocker ⇒ blocked"; full transcript traceability per run. |
| 1 | firegnu/herdr-loop-lab | "Verification-driven bounded-convergence loops (inner/fleet/epic)" | [link](https://github.com/firegnu/herdr-loop-lab) | Three-layer: inner loop (writer → mechanical gate → cross-model adversarial judge), fleet layer (parallel worktree tasks), epic layer (decompose → dispatch → integrate); exit codes as contracts (0 satisfied / 2 stalled / 3 quota); stateless worktree rounds enable resume; AC-N acceptance criteria decoupled from agent output. |
| 1 | Llicklair/forja | "Finder→Tester→Fixer→Evaluator self-correcting loop" | [link](https://github.com/Llicklair/forja) | Tester writes FAILING tests before fixes (anti false-positive); Evaluator runs the suite adversarially on a SEPARATE model to catch cross-test contamination; stop conditions = class-level exhaustion + suite integrity (no `-k` filtering) + blast-radius veto; "honesty principle": coverage% = breadth of first contact, untestable marked "correct by construction, unverified". |
| 1 | Synaptic-Labs-AI/PACT-Plugin | "Prepare-Architect-Code-Test agentic harness" | [link](https://github.com/Synaptic-Labs-AI/PACT-Plugin) | 12 specialists + orchestrator; **concurrent Auditor** observes via `git diff` (structural evidence, not prose attestation); Conversation-Theory teachback (restate understanding before work); two-call atomic acceptance; falsifiable-by-construction (only verifies on-disk conditions); SQLite vector+graph memory + append-only JSONL journal survives compaction. 68★. |
| 1 | Lenny's Newsletter | "No Figma. No Jira. No docs. How Gusto built a product line with Claude Code" (Eddie Kim, CTO) | [link](https://www.lennysnewsletter.com/p/no-figma-no-jira-no-docs-how-gusto) | 5-person team shipped a tier-one AI product in 10 weeks; the **trash-can method** turns Claude-generated PRs into disposable product proposals (close to discard), making failed experiments cheap; eval-first bug-fixing loop. Added to reading list (Loops in Production). |
| 2 | krishddd/Strive_Engineering | "2026 research upgrade — isomorphic verifier, compaction, anomaly guard, authoring CLI" | [link](https://github.com/krishddd/Strive_Engineering/commit/0be1771) | **Isomorphic-perturbation verifier** (Rust `verify-iso`): validates each claim under two independent-but-equivalent checks (literal `git cat-file -e` + full OID re-derivation); passing one but not its equivalent signals a reward-hack and exits non-zero. Plus compaction+notebook durable memory, scheduler oscillation halting, spec-authoring CLI (init/cost/audit). |
| 2 | eugenelim/agent-ready-repo | "Per-loop self-coverage tuning + design-time reviewer (RFC-0050/0053, #454–456)" | [link](https://github.com/eugenelim/agent-ready-repo/commit/525a13d) | Reframes self-coverage as a *per-loop* goal: discovery loop runs the full seven-module gate, work loop runs only a "thin" net-new slice (avoid ceremony); "resolve-vs-surface" — substitute rigorous checklists for what would escalate to a human; adds a forked-context design-time reviewer ("experience-reviewer") + "Ground Taste" to stop re-litigating preference. |
| 2 | omnigent-ai/omnigent | "Idle-reaper window + dead-letter replay + polly visual-proof check (#1627)" | [link](https://github.com/omnigent-ai/omnigent/commit/62dd103) | Tunable harness idle-reaper (`OMNIGENT_HARNESS_IDLE_TIMEOUT_S`) as a cleanup stop-condition for long-lived sessions; dead-letter recovery classifies forwarding failures (proven-undelivered replayable / ambiguous forensic-only / permanent) for at-most-once crash recovery; polly-review now flags missing screenshots/videos on UI PRs (verifier checklist for visual proof). |
| 2 | adha9990/dev-workflows | "7-stage closed-loop development workflow plugin" | [link](https://github.com/adha9990/dev-workflows) | dispatch → goal → explore → plan → build → verify → iterate; human-gated only at genuine decision points (routine transitions auto-advance); build uses red-green separation (test author isolated from implementer); verify deploys six parallel reviewers across distinct axes; mandatory re-verify of delta + blast radius after each fix; three-cycle iteration cap. |
| 2 | Lenny's Newsletter | "How I AI: GLM-5.2 review & How Gusto built a new product line" | [link](https://www.lennysnewsletter.com/p/how-i-ai-glm-52-review-and-how-gusto) | Pairs a live GLM-5.2 open-weight coding-model review (~$3.36 for 6M tokens of agentic work) with the Gusto case study — framing open weights as production-grade for long-running agent loops. |
| 2 | via Lenny's Newsletter | "How to build a new AI product in 10 weeks using the no-process method" | [link](https://www.chatprd.ai/how-i-ai/workflows/how-to-build-a-new-ai-product-in-10-weeks-using-the-no-process-method) | The trash-can method written up as a reusable workflow: disposable PRs as proposals let non-engineers ship features developers later refine — a loop-driven planning practice. |
| 2 | MindStudio Blog | "Self-Scaffolding AI Models: How Ornith 1.0 Writes Its Own Agent Harness" | [link](https://www.mindstudio.ai/blog/self-scaffolding-ai-models-ornith-1-0) | Ornith 1.0 generates a discrete, inspectable Python harness per task (tool selection, state, branches, termination criteria) instead of running inside a fixed human-written loop — model-generated harnesses (new KB gap). |
| 3 | via Lenny's Newsletter | "Fix bugs using an AI-powered TDD workflow" | [link](https://www.chatprd.ai/how-i-ai/workflows/how-to-fix-bugs-using-an-ai-powered-test-driven-development-tdd-workflow) | Concrete verification loop: agent writes a failing test to reproduce the bug, fixes, re-runs the test as the stopping condition, gates on human review before commit. |
| 3 | MindStudio Blog | "Context Rot in AI Agents: Fix with Session Handoffs" | [link](https://www.mindstudio.ai/blog/context-rot-ai-agents-session-handoff-fix-2) | Long loops degrade as old instructions lose weight; session handoffs (summarize state, clear, restart) + persistent external memory (CLAUDE.md) treat context management as a deliberate infra layer (restates docs/13). |
| 3 | MindStudio Blog | "What Is Sakana Fugu? Multi-Model Orchestrator" | [link](https://www.mindstudio.ai/blog/what-is-sakana-fugu-multi-model-orchestrator-2) | Routes prompts via a *trained classifier* (not rule heuristics) matching complexity to a model pool to optimize cost vs quality (restates docs/22 learned orchestration). |

### No new content
- Anthropic RSS (404 across rss.xml/rss/news variants), The Batch feed (404 — content reachable only via HTML index; issue-359 three-loops material already tracked v2.4.1), The Rundown AI (403), Ben's Bites / AI Breakfast (beehiiv 404), Harness Books (agentway.dev 403), OpenAI news (403) — persistent feed/access issues; nothing new
- @bcherny, @karpathy, @AndrewYNg, @swyx, @steipete, @Sabrina_Ramonov, @akshay_pachaar — no new keyword-matching posts after last run (X live + per-handle scans not re-run this cycle; newest known matches already in KB)
- Simon Willison — recent posts are Claude-Code-assisted project writeups (Tier 4 incidental), not loop-design practice
- swyx.io, Sabrina.dev — no substantively new loop-engineering articles after last run
- Addy Osmani (Loop Engineering, Orchestration Tax, Factory Model, Intent Debt) — all predate last_run and already tracked in KB
- The New Stack runtime-verification piece — already in the 2026-06-29 digest (excluded as duplicate)
- cobusgreyling/loop-engineering, goal-engineering, fleet-engineering, getzep/graphiti — no commits after 2026-06-29; tenet, loopflow, loop-kernel, claude-harness — latest commits on/before cutoff
- GitHub search (`acting_on` claude loop) — 0 results; replaced with a cross-model maker/checker query in SOURCES.md. (`claude code harness` search increasingly polluted by Claude-Code reverse-engineering/snapshot repos — refinement noted)

### Docs updated this run
- `docs/04-verification.md` — added **Pattern 5: cross-model independence** to Verifier Integrity (checker runs a *different* model than the maker — Claude implements / Codex reviews; model-diversity defeats shared blind spots; structured `VERDICT: PASS/BLOCK` + `SUGGEST`; dual stop condition) and the **isomorphic-perturbation check** refinement (anti single-predicate reward-hacking); updated section count 3→5 and the closing synthesis to "these five together" (Cliclaw, loope, herdr-loop-lab, forja, Strive_Engineering)
- `docs/07-subagents.md` — added "**Independence has two axes**" note distinguishing context-independence (fresh session) from model-independence (different model for the checker), cross-linking to docs/04 Pattern 5 — the run's findings showed model-diversity is a distinct axis the DOER/CHECKER section did not name
- `docs/32-reading-list.md` — added Gusto "no-process / trash-can method" case study to Loops in Production (strongest process-replacement case study with hard outcome data); Reference Implementations kept stable (cross-model pattern already canonised in docs/04; existing 5 entries not clearly beaten)
- `LOOP_ENGINEERING.md` — updated docs/04 index summary to list isomorphic-perturbation + cross-model independence
- `SOURCES.md` — replaced low-yield `acting_on` github-search with a cross-model maker/checker query; added Happenmass/Cliclaw and firegnu/herdr-loop-lab as github sources; noted isomorphic verifier on Strive_Engineering
- `KB_GAPS.md` — added two gaps surfaced by this run's findings (cross-model checker arbitration/model-selection; self-scaffolding model-generated harness)

### Structural review this run (Phase 4c)
Reading the finding-set as a whole, the dominant theme (≥4 findings) is **cross-model
maker/checker**. Per the canonical-home rule, this did **not** warrant a new doc: the parent
topic (verifier integrity / keeping the check unfakeable) already lives in `docs/04`, so the
new mechanism was consolidated there as Pattern 5 with a single cross-ref from `docs/07`,
keeping one canonical home rather than fragmenting. The theme *strengthens* the design spine's
fifth question ("How do you know it's done?") by adding an independence axis (model diversity)
the KB previously conflated with context-independence — the only structural correction needed.
No thesis was missing (docs/01 already states the harness/verifier matters more than the
model), no index reorder or merge was warranted, and centrality of the design spine is intact.
Tier-3 article findings (context rot, Sakana Fugu) restated existing docs (13, 22) and were
recorded as findings without doc edits.

### Sources to consider adding to SOURCES.md
- Synaptic-Labs-AI/PACT-Plugin (68★) and Llicklair/forja — strong cross-model/maker-checker repos; tracked via the new cross-model github-search query rather than as standalone rows (avoid SOURCES bloat); promote to dedicated rows if they ship a second distinct contribution
- mateaix/loope, adha9990/dev-workflows — same; surfaced by the cross-model search query

---

## 2026-06-29 04:02 UTC (run)

Another GitHub-dominated run. The live repo searches surfaced a *second* wave of
fresh Claude-Code loop harnesses (all updated Jun 29) converging — again — on
**verifier integrity and anti-self-grading**: SHA-cited "ungameable" verifiers,
adversarial read-only verifier agents, eval-gate + independent monitor councils, and
reject-until-proven reviewers. The genuinely new mechanism this run is
**provenance-bound claims** (every assertion must cite a git SHA re-checked via
`git cat-file`, plus majority-vote to block collusion) — canonised as a 4th pattern in
the Verifier Integrity section of `docs/04`. The article sources (Slashdot, O'Reilly,
The Innermost Loop) restated the now-familiar thesis and added the
"model-harness-sandbox-eval **flywheel**" framing, but introduced no concept the KB
lacks.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | krishddd/Strive_Engineering | "SHA-cited ungameable verifier + L0-L3 autonomy ladder" | [link](https://github.com/krishddd/Strive_Engineering) | Every finding must cite a git SHA verified by `loopguard` via `git cat-file`; diff-integrity + injection scanning; `majority_vote` blocks self-grading — **provenance-bound claims** as a new verifier-integrity mechanism. |
| 1 | grapheneaffiliate/Harness | "The RIG — deterministic read→pick→dispatch→verify→record loop" | [link](https://github.com/grapheneaffiliate/Harness) | Adversarial read-only verifier agent + `verify.sh` source-of-truth exit-0 gate; iteration caps (RIG_MAX_ITERS/STOPS); Stop gate won't release until the tree is clean and pushed. |
| 1 | kok1eee/flywheel | "Sensors-first loop engine" | [link](https://github.com/kok1eee/flywheel) | Hooks observe natural tool use to advance phases; gates physically block implementation until design validates; completion requires both an eval exit-code gate AND an independent monitor council (cap 8) — never model self-assessment. |
| 2 | patrick-toulme/harnessgym | "Capability-gap reflection → one reusable artifact per iteration" | [link](https://github.com/patrick-toulme/harnessgym) | Runs agents on hard tasks, reflects on missing capabilities, builds one reusable artifact (skill/MCP/test) per iteration, qualifies it in a clean workspace, restarts fresh with accumulated harness context; failed artifacts quarantine with evidence. |
| 2 | manok4/ensemble | "Documentation-as-truth maker/checker harness" | [link](https://github.com/manok4/ensemble) | Independent read-only reviewers (correctness/testing/maintainability/standards) return structured findings; two verification gates around each build unit; 6-verdict triage before merge. |
| 2 | vibhasdutta/loop-engineer | "7-agent team iterating to verified done" | [link](https://github.com/vibhasdutta/loop-engineer) | Scaffolds tool-scout/researcher/developer/QA/verifier/auditor/memory-keeper iterating until all tasks pass or a 20-turn budget exhausts; verifiers default to "reject until proven"; auto-skip on repeated failure. |
| 2 | happy-ryo/loop-agent | "Embeddable loop with five injection seams + dual termination" | [link](https://github.com/happy-ryo/loop-agent) | Fixed orchestration with gather/act/verify/conditions/gate seams; a dual-termination model combining goal achievement with synthetic stop conditions to guarantee halt; swappable providers via an ActHook protocol. |
| 2 | iamraven-tw/loop-engineering | "Claude Code skill teaching ten reusable loop patterns" | [link](https://github.com/iamraven-tw/loop-engineering) | Ten patterns (retry/reflection/evaluation/planning/tool-calling/research/memory/multi-agent/human-in-the-loop/continuous-improvement) unified by iterate-with-checkpoints-until-success-or-termination. |
| 1 | Slashdot | "Forget Prompt Engineering: 'Loop Engineering' Is All the Rage Now" | [link](https://developers.slashdot.org/story/26/06/25/0546238/forget-prompt-engineering-loop-engineering-is-all-the-rage-now) | Boris Cherny says Claude now writes his prompts; Peter Steinberger urges engineers to design the loops that prompt the agents — mainstream press confirming the discipline. |
| 1 | O'Reilly Radar | "Loop Engineering" — Addy Osmani | [link](https://www.oreilly.com/radar/loop-engineering/) | Definitional piece: self-directed loops from automations/worktrees/skills/MCP connectors + a verifier subagent and a measurable stop condition; warns against cognitive surrender. |
| 2 | The Innermost Loop | "Welcome to June 28, 2026" | [link](https://theinnermostloop.substack.com/p/welcome-to-june-28-2026) | Frames every enterprise as spinning its own **model-harness-sandbox-eval flywheel**; notes loop engineering has gone so far Claude Code's creator lets Claude write his prompts. |
| 2 | via Innermost Loop | "Aravind Srinivas on the model-harness-sandbox-eval flywheel" | [link](https://x.com/aravsrinivas/status/2070938739350900944) | Perplexity's CEO frames each enterprise's flywheel as tuned for token value per watt — the flywheel thesis from an operator. |
| 1 | via Lenny's Newsletter | "How Mozilla Fixed 500 Security Bugs with Mythos" | [link](https://www.chatprd.ai/how-i-ai/how-mozilla-fixed-500-security-bugs-with-mythos) | Mozilla's Mythos combines relentless analysis loops with verification + patching agents to find/patch ~500 Firefox bugs — the harness, not the model, is the leverage (extends the Firefox case study already in docs/04). |
| 2 | MindStudio Blog | "What Is a Loop of Loops?" | [link](https://www.mindstudio.ai/blog/what-is-loop-of-loops-ai-agents-recurring-work) | Coordinator agent manages multiple child agents on recurring cycles, sharing context and handling dependencies — restates multi-loop coordination already in docs/34. |
| 2 | omnigent-ai/omnigent | "Emit CompactionComplete on SDK context compaction (#1505)" | [link](https://github.com/omnigent-ai/omnigent/commit/a8157fa) | Cross-harness event-propagation: emit CompactionComplete (summary + post-compaction token count + model) before TurnComplete so resumed sessions use the compacted summary, not a full transcript replay. |
| 3 | The New Stack | "Runtime verification of coding agents" | [link](https://thenewstack.io/runtime-verification-coding-agents/) | Greptile/Cursor/Devin agree agents should run their code before handoff; sandboxes miss integration bugs, making *what code runs against* the key design choice. |
| 3 | The Batch (DeepLearning.AI) | "Agentic tests beyond the bug hunt (DeepSWE / ProgramBench / ITBench-AA)" | [link](https://www.deeplearning.ai/the-batch/agentic-tests-beyond-the-bug-hunt) | New benchmarks stress agent harnesses on feature implementation, program-from-scratch, and root-cause diagnosis — harder than SWE-bench bug-fixing. |
| 3 | JeiKeiLim/tenet | "gzip db snapshots by default with auto-detecting restore" | [link](https://github.com/JeiKeiLim/tenet/commit/069d562) | Git-safe agent-state snapshots: gzip the SQLite snapshot (70-90% smaller to stay under GitHub's 100MB limit), auto-detect via magic bytes (0x1f 0x8b) on restore. |

### No new content
- Anthropic RSS (404, recovered via search — foundational pieces predate last run), The Rundown AI (403), Ben's Bites / AI Breakfast (beehiiv 404), Harness Books (agentway.dev 403), OpenAI news (403) — all ongoing feed/access issues; nothing new surfaced
- @bcherny, @AndrewYNg, @swyx, @steipete, @karpathy, @Sabrina_Ramonov, @akshay_pachaar — no posts after last run matching keywords (newest matches already in KB)
- Simon Willison, swyx.io — only incidental Claude/Codex mentions, not loop-engineering practice
- X live keyword search — mostly non-English promo / trivial Claude Code mentions; the one "loop engineering" hit was a 1-view throwaway, excluded
- cobusgreyling/loop-engineering, goal-engineering, fleet-engineering, getzep/graphiti, faisalishfaq2005/loopflow, uppifyagency/loop-kernel, orobsonn/claude-harness — no substantive commits strictly after 2026-06-28
- GitHub search (`acting_on` claude loop, `stopping condition` claude loop) — 0 results each; suggested refinements: `"halt condition" claude loop`, broader `"gather" "verify" "gate" claude loop`

### Docs updated this run
- `docs/04-verification.md` — added **4th Verifier Integrity pattern: provenance-bound claims** (every assertion cites a git SHA re-checked via `git cat-file`; majority-vote monitor council blocks self-grading) + a closing synthesis tying all four patterns to the Verifier-Theater cure (krishddd/Strive_Engineering, kok1eee/flywheel, grapheneaffiliate/Harness)
- `LOOP_ENGINEERING.md` — updated the docs/04 index summary to list provenance-bound claims + majority-vote council
- `SOURCES.md` — added krishddd/Strive_Engineering as a github source (novel SHA-citation verifier pattern canonised this run)
- `docs/32-reading-list.md` — added Strive_Engineering to Reference Implementations (provenance-bound verification — a technique no other reference impl demonstrates; group now at the 5-entry cap)

### Structural review this run (Phase 4c)
Reading the finding-set as a whole, the dominant theme is — for the second consecutive
run — **verifier integrity and anti-self-grading** (Strive, The RIG, flywheel, ensemble,
loop-engineer all centre on unfakeable checks and independent judges). This *reinforced*
the canonical home established 2026-06-26/28 rather than fragmenting it: the one new
mechanism (provenance-bound claims) slotted in as a 4th pattern inside the existing
`docs/04` Verifier Integrity section, and a closing synthesis now states the converging
thesis outright. The secondary theme — the "model-harness-sandbox-eval **flywheel**"
framing (Innermost Loop, Aravind Srinivas) — is already covered by the
[Factory Model](https://lucagattoni.github.io/Claude-Loops/26-factory-model/) and [Harness Patterns](https://lucagattoni.github.io/Claude-Loops/24-harness-patterns/)
docs (harness > model thesis); it added vocabulary, not a missing primitive, so no
structural change. No new docs, no index restructure — the design spine absorbed the run
cleanly.

### Sources to consider adding to SOURCES.md
- grapheneaffiliate/Harness ("The RIG") and kok1eee/flywheel — strong Tier-1 verifier-integrity designs; monitor for ≥2 substantive contributions before adding as standing sources
- The Innermost Loop (theinnermostloop.substack.com) — newsletter with the flywheel framing; watch for a second on-topic issue before tracking
- MindStudio is already tracked; its Jun-25 cluster (loop-of-loops, /goal+/routines, G Stack) was high-volume but restated covered concepts

---

## 2026-06-28 16:25 UTC (run)

GitHub-dominated run: the live searches surfaced a wave of small Claude-Code loop
harnesses (Jun 27–28) converging on the same patterns — exit-code stops, external
verifiers, frozen tests, maker/checker isolation. The convergence itself is the
signal: the patterns this KB documents are now the de-facto community standard.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | uppifyagency/loop-kernel | "Simplest autonomous loop that provably halts" | [link](https://github.com/uppifyagency/loop-kernel) | Three deterministic exit-code stops (0=pass / 3=score flat K iters / 2=cap), external unfakeable verifier, `score=<fraction>` contract; "progress is the score moving, not did-files-change". |
| 1 | @mateclawai / mateaix/loope | "Loope — open-source Loop Engineering workspace for AI coding" | [link](https://github.com/mateaix/loope) | Cross-model maker/checker: Claude implements, Codex reviews; parallel read-only reviewers emit PASS/BLOCK, converge when verify passes & no blocker (max-iters 3); agents isolated via `--isolate-home`. |
| 1 | shumatsumonobu/loop-engineering-playbook | "Ralph-pattern loop playbook" | [link](https://github.com/shumatsumonobu/loop-engineering-playbook) | Ralph pattern (fresh context each cycle, state in `.claude/loop/TASKS.md` + git + tests) with a Stop-hook hard floor blocking completion while tests fail; verifier `verdict.json` separation. |
| 1 | VioletScar-Hui/Build_Great_Loop | "Composable 5-skill loop group" | [link](https://github.com/VioletScar-Hui/Build_Great_Loop) | Five composable skills (loop-spec/engineering/eval/review/ops) producing paste-ready loop prompts; crash-safe idempotent resumption; machine-checkable success standards. |
| 2 | orobsonn/claude-harness | "Barbell 'strong eyes, cheap hands' delivery" | [link](https://github.com/orobsonn/claude-harness) | Cheap Ollama models write code, Opus judges at gates, Sonnet orchestrates for throughput; tests content-hashed & frozen before impl; completion verified independently (git diff + real test run). |
| 2 | firegnu/herdr-loop-lab | "Verification-driven bounded-convergence toolkit" | [link](https://github.com/firegnu/herdr-loop-lab) | Three-tier nested loops (inner adjudicated / fleet across worktrees / epic auto-merge); mechanical gates kept separate from adjudicators; correctness rests on git + exit codes + JSON contracts. |
| 2 | KranzL/jje | "Planner/Executor/Jury/Judge generator-critic harness" | [link](https://github.com/KranzL/jje) | Tool-backed independent juries (gitleaks/semgrep/pytest); **oscillation guard** escalates on recurring/contradictory findings (repeat_threshold 2); PreToolUse commit gate enforcing accept + green CI. |
| 2 | ruvnet/agent-harness-generator | "MetaHarness — meta-harness factory" | [link](https://github.com/ruvnet/agent-harness-generator) | Generates branded harnesses with cost-aware model routing learned from eval logs, Darwin self-mutating configs, default-deny MCP governance, Ed25519/SLSA-L2 signed provenance. |
| 2 | BicaMindLabs/FuguNano | "Repo-native multi-agent harness (Sakana Fugu reimpl)" | [link](https://github.com/BicaMindLabs/FuguNano) | Provider-neutral routing with a self-harness learning loop that mines failed runs and promotes only non-regressing harness edits (model frozen); join-barrier non-convergence detection. |
| 2 | adha9990/dev-workflows | "7-stage closed-loop dev workflow" | [link](https://github.com/adha9990/dev-workflows) | dispatch→goal→explore→plan→build→verify→iterate; decision-point gating pauses only on genuine choices to conserve budget; red-green test/impl separation; iteration cap 3. |
| 2 | Llicklair/forja | "Claude Code autonomous loop plugin" | [link](https://github.com/Llicklair/forja) | Class-wide scanning hard gate (fix all instances with proof), allowlist-by-command-name gate execution, sandbox mode for untrusted repos, "forja max 300k" token-budget stop. |
| 2 | eugenelim/agent-ready-repo | "RFC-0055 correction convention + R10 sidecar privacy boundary" | [link](https://github.com/eugenelim/agent-ready-repo) | New RFC/ADR governance for correcting accepted specs (Errata/Amendments) and a privacy boundary for sidecar data; extends the traceability model already in KB. |
| 2 | Kanevry/session-orchestrator | "v3.10.0 — repeatable session loops" | [link](https://github.com/Kanevry/session-orchestrator) | Five typed waves with inter-wave session-reviewer gates, `blocked-commands.json` policy file, STATE.md crash recovery across Claude Code/Codex/Cursor/Pi. |
| 3 | @Sabrina_Ramonov | "Claude posts to social media for me now" | [link](https://x.com/Sabrina_Ramonov) | Applied headless content loop in Claude Code: write → grade for virality → check brand voice → post; a checker gate before the irreversible publish step. |
| 4 | omnigent-ai/omnigent | "Authoritative per-session cost_usd" | [link](https://github.com/omnigent-ai/omnigent) | Surfaces authoritative AI-credit cost as `cost_usd` per session (#1486) — a concrete cost-tracking mechanism relevant to the goal-cost estimation gap. |

### No new content
- Anthropic RSS / The Rundown AI / TLDR AI / Ben's Bites / AI Breakfast / The Batch — RSS 404/403 (ongoing; The Batch feed URL needs revisiting)
- OpenAI news / Harness Books (agentway.dev) — 403 (ongoing)
- @bcherny — newest matching post is Jun 23 (Claude Everywhere, already in KB); nothing after last_run
- @AndrewYNg, @swyx, @steipete, Addy Osmani, Simon Willison, Cobus Greyling, Lenny's, Sabrina.dev, MindStudio — nothing dated after 2026-06-26 (newest items predate last run / already in KB)
- cobusgreyling/goal-engineering, fleet-engineering, getzep/graphiti, JeiKeiLim/tenet, faisalishfaq2005/loopflow, Monad-Harness — no substantive new commits since last run
- GitHub search (`acting_on` claude loop) — 0 results; suggested: `"stopping condition" claude loop`
- GitHub search (SECURITY_MATRIX claude agent) — 0 results; suggested: `"default-deny" MCP policy agent`

### Docs updated this run
- `docs/04-verification.md` — added **Verifier Integrity: Keeping the Check Unfakeable** (consolidated, canonical home): external verifier (loop-kernel), mechanical gates vs. adjudicators (herdr-loop-lab), frozen content-hashed tests (claude-harness)
- `docs/27-loop-contract.md` — extended the canonical Stop Condition Taxonomy with the three-exit-code reference implementation (loop-kernel) and the "score the goal, not the activity" refinement to the no-progress stop
- `docs/07-subagents.md` — added **"Strong Eyes, Cheap Hands"** cost-asymmetric DOER/CHECKER model allocation (claude-harness)
- `docs/17-failure-patterns.md` — added **Verdict oscillation** failure pattern + oscillation-guard mitigation (jje)
- `docs/32-reading-list.md` — added loop-kernel to Reference Implementations
- `SOURCES.md` — added uppifyagency/loop-kernel and orobsonn/claude-harness as github sources

### Structural review this run (Phase 4c)
Reading the finding-set as a whole, the dominant theme was **stopping-condition rigor + verifier integrity** (loop-kernel, herdr-loop-lab, jje, claude-harness all center on provable halting and unfakeable checks). This *reinforced* the canonical homes established 2026-06-26 rather than fragmenting them: the stop-condition material consolidated into `docs/27` and the verifier-integrity sub-theme into a single new section in `docs/04`. No new docs, no index restructure — the existing design spine absorbed the run cleanly.

### Sources to consider adding to SOURCES.md
- The New Stack — two Jun 27 Tier-3 candidates (runtime verification of coding agents; vibe-coding "context debt"); article bodies were not retrievable via WebFetch, so excluded pending verification
- "How to actually master loop engineering" — an X Article surfaced in the live search (Plan→Act→Learn `/loop` diagram); URL not captured this run — re-check next run
- Several new harness repos not yet tracked individually: firegnu/herdr-loop-lab, KranzL/jje, mateaix/loope, ruvnet/agent-harness-generator (MetaHarness) — monitor for ≥2 substantive contributions before adding as standing sources

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
