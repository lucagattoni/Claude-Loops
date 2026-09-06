# Claude Loops

> Two disciplines, kept separate.

> 📖 **Read this on the docs site: <https://lucagattoni.github.io/Claude-Loops/>** — a 3-column layout with search and
> navigation. This file is a flat index; the site is the intended reading experience.

This knowledge base covers two related but distinct things. Most confusion about working with
coding agents comes from treating them as one.

| | **Part I — Loop Engineering** | **Part II — Developing with Claude Code** |
|---|---|---|
| **What it is** | Designing a system that prompts an agent *for* you — it fires on a trigger, works, verifies, and stops | You and Claude Code building software together, iteratively, with you in the loop |
| **You are** | Not at the keyboard | At the keyboard |
| **Scope** | General, tool-agnostic | Claude Code specific, version-stamped |
| **Start at** | [The Loop Contract](https://lucagattoni.github.io/Claude-Loops/27-loop-contract/) | [Choosing Your Mode](https://lucagattoni.github.io/Claude-Loops/35-choosing-your-mode/) |

**Not sure which you need?** [Choosing Your Mode](https://lucagattoni.github.io/Claude-Loops/35-choosing-your-mode/) is the router.

For **building software**, the honest default is Part II — *"most effective coding agent use is a
complex, highly iterative process"* ([Andrew Ng](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map-in-detail-using-coding-agents/),
2026-09-04, explicitly *not* autonomous long-horizon execution). Part I is where **recurring,
well-specified, verifiable** work belongs, and there the payoff compounds.

Row numbers are stable identifiers — they do not change when docs are regrouped.

---

# Part I — Loop Engineering

*General and tool-agnostic. Claude Code appears here as an example, never as a prerequisite.*

**The central act is designing the loop** — deciding *what* it is for, *how* it does it, *when* it
fires, *how much* it may spend, and *how you know it's done* (the question verification answers, and
the one most loops get wrong). The [Loop Contract](https://lucagattoni.github.io/Claude-Loops/27-loop-contract/) is the instrument for
answering all five.

## 1. Foundations

| # | Topic | Summary |
|---|---|---|
| 1 | [The Paradigm Shift](https://lucagattoni.github.io/Claude-Loops/01-paradigm-shift/) | Old-way prompting vs. loops; compound probability argument (0.9^10 = 35%); the New Software Lifecycle; five Anthropic canonical patterns; >80% Anthropic engineers use self-improving loops; domain expertise (not coding background) predicts work delegated per instruction (Anthropic, 400K sessions, Jul 2026) |
| 2 | [The Core Agent Loop Cycle](https://lucagattoni.github.io/Claude-Loops/02-agent-loop-cycle/) | Observe → Reason → Plan → Act → Verify; Universal Agent Thesis; two lenses on primitives (functional: execution/verification/orchestration/observability vs. mechanical: six building blocks); runtime termination signals mapped to the stop-condition taxonomy |
| 20 | [Loop Maturity Model](https://lucagattoni.github.io/Claude-Loops/20-loop-maturity-model/) | 14-step progression from manual prompter to loop engineer; per-loop L1/L2/L3 operational readiness levels |
| 21 | [Context vs. Loop Engineering](https://lucagattoni.github.io/Claude-Loops/21-context-vs-loop-engineering/) | Debate and vocabulary consolidation: four named disciplines — Loop, Context, Harness, Fleet Engineering (+ contested fifth, Graph); Sep 2026 continuation — Karpathy's loop-as-intermediate-stage progression, the "chorus not ensemble" parallel-review cost argument, control-theory reframing of loop failure modes, dissenting "bro code" skeptic view; academic corroboration doubled (two independent papers three weeks apart naming the same graph/loop/harness split); a practical graph-vs-loop decision rule (explainx.ai); harness→loop→graph naming-progression essay (ikangai) |
| 26 | [The Factory Model](https://lucagattoni.github.io/Claude-Loops/26-factory-model/) | Orchestrating agent factories — spec quality and verification replace coding speed; dark-factory maturity ceiling (underspecified input as the surviving bottleneck, MindStudio); cross-provider adoption corroboration (OpenAI: 99% of output tokens via agents); named deployments (Droid Shield 2.0 coordinator+droids, auto-merge-as-terminal-stage, Bun's granular porting-guide→mechanical-port→compiler-errors→tests-green decomposition); "lit" vs. "dark" factory naming + where judgment relocates (Osmani); scientific-computing field report outside software; primary source for the "dark factory" name (Dan Shapiro's six-level taxonomy, NHTSA-analogy) cited directly; first concrete Level 5 case (AI tutor chatbot, zero human code review) |

## 2. Designing a Loop

| # | Topic | Summary |
|---|---|---|
| 27 | [The Loop Contract](https://lucagattoni.github.io/Claude-Loops/27-loop-contract/) | **The design spine** — what/how/when/how-much framing mapped to TRIGGER/SCOPE/ACTION/BUDGET/STOP/REPORT; canonical **stop-condition taxonomy** (completion-check/budget/max-iterations/no-progress; rice-cooker problem; three-exit-code reference impl — loop-kernel; 8-named-exit-code + contract-hash tamper defense extension); job-description framing; Event Modeling; two quality gates; experience encoding; governed cross-session learning; YAML-declarative loop definition + VERDICT: PASS gate; 2-layer budget ceiling; self-discovery pattern; cross-run memory persistence (.loopflow/memory/); gate feedback injection to all agent prompts; plan-as-contract (PLAN.md per dispatch, walidboulanouar); quota-aware should-run gate (proceed/wait/ask/idle, loopx); concrete Sept 2026 STOP+verifier implementations (dream-machine, autogenous, openAVO, sparc, loop.js, loop-contract-skill, DeMARS); LoopArena controller benchmark (24.69% best strict success rate); Anthropic's 1σ/2σ/3σ control-band autonomy ladder (AI-Native SDLC); loopgain's Barkhausen-criterion stopping condition (92.8% spend cut, documented 4.5% false-converge rate); deterministic trigram-similarity circuit breaker + 95%-confidence design gate + tenth-man critic (huvii174); "done" scaled by org size (MindStudio) |
| 30 | [Goal Engineering](https://lucagattoni.github.io/Claude-Loops/30-goal-engineering/) | Goals vs. Loops decision framework; four Goal Primitives; GOAL.md schema; six canonical goal patterns; G0-G3 readiness scoring; a-priori pattern-keyed goal-cost estimation (cobusgreyling, Jun 2026); 107M-row single-goal case study with auditor subagent; Aspire vague-goal self-evolution benchmark |
| 24 | [Harness Patterns](https://lucagattoni.github.io/Claude-Loops/24-harness-patterns/) | Harness vs. Loop layers; harness as org-level artifact (Karpathy); harness vs. environment engineering (in-process vs. OS-level controls); three deployment patterns (Approval-First/Allow-list/Sandboxed); three-agent full-stack harness; unstable components axiom; ledger closure; five-wave model; runtime republic vs. constitutional control plane; harness-agnostic projection + .apm/ primitive manifest + backend-agnostic dual MCP/CLI seam (athena-loops); 8-phase DAG + steer messages; task-shaped DAG orchestration (fail-closed exit gates, classifier-gated parallelism, Kaola-Workflow); meta-harness 3-tier policy hierarchy + compaction persistence + resume; agent YAML definition schema; organizational learning stage; harness update file safety contract; quantified harness>model (Terminal-Bench Top30→Top5, harness-only; 7x cost reduction, HuggingFace Jul 2026); harness conformance testing (harness-bench + cross-vendor PolicyDeniedEvent, self-correcting capability tables) + schema-level conformance (Temper); self-improving harnesses (Self-Harness/AHE/HarnessX/SEAGym/APEX/Darwin Mode — trace-driven evolution, verified prediction contracts, ablation: gains from tools/middleware/memory not prompts, snapshot-collapse risk closed by train/eval-disjoint held-out gating, co-evolution, mechanized-vs-prose compliance ~100% vs 70-90%; insights hill-climbing subcommand, claude-deep-loop); control-plane/execution-plane kernel-gated mutation; official Claude-team loop-type taxonomy (turn/goal/time-based/proactive); dynamic workflow patterns (six orchestration shapes vs. agentic laziness/self-preferential bias/goal drift, Anthropic); cross-model division of labor (advisor loop, codex-first, Puppetmaster, official openai/codex-plugin-cc reviewer gate); quantified harness>model corpus (StaminaBench 6x, Claw-SWE-Bench 4x); harness-design origin story (Making of Claude Code); fix-the-process-not-the-code (Bun's manual harness-level fix for repeated dangerous git commands, vs. automated self-improving harnesses); quantified benchmark-harness-disclosure gap (ARC-AGI-3 two-settings 13.3%→38.3% tripling; undisclosed GPT-6 Astra harness); self-improving-harness cluster extension (JIT-Agent, HarnessLens, EvoUndo, HarnessDev, Harness-of-Harness multi-day case study); generic-harness-beats-bespoke finding (CAE simulation agents); query-loop-as-heartbeat + Ten Principles of Harness Engineering + object-oriented/code-as-action agents (NOOA, 82.2% SWE-bench Verified at half token cost); YAML-defined process DAGs (Archon, 23k★); Unified Harness Protocol; Warp's inner/outer self-improving skill pattern; mechanically-enforced review-before-merge; a second controlled harness-token-efficiency data point (5.2x token gap at matched success) |
| 34 | [Loop Patterns Catalog](https://lucagattoni.github.io/Claude-Loops/34-loop-patterns/) | Seven named loop patterns (Daily Triage, PR Babysitter, CI Sweeper, Dependency Sweeper, Post-Merge Cleanup, Changelog Drafter, Issue Triage); L1/L2/L3 readiness levels; token costs; multi-loop coordination with concrete STATE.md example; per-agent heartbeat coordination (harnery pattern); three-loop onboarding sequence; Debt Audit + Docs Sync patterns; DEPBENCH dependency-upgrade benchmark (51.2% best-harness solve rate) |

## 3. Verification & Failure

| # | Topic | Summary |
|---|---|---|
| 4 | [Verification](https://lucagattoni.github.io/Claude-Loops/04-verification/) | The non-negotiable foundation — verification = the completion-check stop; verifier integrity (external unfakeable verifier, mechanical gates vs. adjudicators, frozen content-hashed tests, provenance-bound claims + majority-vote council, isomorphic-perturbation checks, cross-model independence — Claude implements / Codex reviews — with VERDICT BLOCK/SUGGEST + dual stop; information-asymmetry/blind validation — checker never sees the maker's reasoning; run-record-anchored capture gate); reviewer freshness enforcement (model vs. perspective independence, never-see-the-draft rule, synthesizer-bias mitigation); held-out evaluator-only holdout wall; eval metrics (pass@k vs. pass^k, 3 grader types, 70/30 human-LLM blend); proof-of-work demo artifacts; strategies, Type A/B classification, verdict taxonomy, cross-run patterns, belief state machine + R0-R5 risk levels, A/A baseline, LLM-as-a-judge (Opik), Firefox case study (423 fixes); "Surface" vocabulary; verification mode discipline (TDD/goal-based/visual); self-coverage gate (RFC-0051); traceability-lint; oracle problem (~6% precision); structured critic finding taxonomy (6 categories); reviewer non-overlap corroborated in production tools (93.4% of 679 findings caught by exactly one of 4 code-review tools); per-criterion independent verification (manifest-dev); 43% fabrication rate caught by an adversarial gate in production (walidboulanouar); language-independent test suite as cross-language-rewrite verifier + blind adversarial review quantified at 64-agent scale (Bun Zig→Rust, 128 bugs/19 regressions); non-probabilistic node rule + "chorus not ensemble" cost argument for correlated same-model reviewers; benchmark/eval integrity corpus (SWE-Bench Pro 30% broken, undisclosed-harness benchmark scores, DISH, eval-gates-as-product); ARC-AGI-3's own efficiency framing (humans 100% vs. frontier AI <1%); rubric-induced-before-execution verifier (AutoSciRub); early-vs-late-trajectory confidence unreliability (AUROC 0.60 at 50% progress vs. 0.85 at completion) |
| 17 | [Common Failure Patterns](https://lucagattoni.github.io/Claude-Loops/17-failure-patterns/) | Cognitive surrender, orchestration tax, reward hacking, context pollution, amplification effect, State Rot, Verifier Theater, Notification Fatigue, Fixing flakes with code, Over-Reach, Parallel Collision, Verdict oscillation (now with control-theory framing), Zombie finding (findings ratchet), Ghosting under review feedback (AUC 0.96 early-effort prediction), Teardown blindness, Comprehension debt, and more; Scheduler-invisible loop (three structural flaws — implicit dependencies, unbounded recovery, mutable history); reward hacking extended to transcript/tool-call spoofing (METR/OpenAI, 20% of agents); a second cognitive-surrender study (Anthropic/Trio, 50% vs. 67%); Willison's Winchester Mystery House quote on comprehension debt |
| 14 | [Human-in-the-Loop Escalation](https://lucagattoni.github.io/Claude-Loops/14-human-in-the-loop/) | When to pause and ask for human input; checkpoint placement (4 tests, 80/20 split, override-rate calibration); the three nested feedback loops (agent/developer/user cadences) and the human "context advantage" (Andrew Ng); Claude asks for clarification 2x more often than humans interrupt it (Anthropic, "Measuring agent autonomy"); persona document as a calibration feedback channel (Rally News) |

## 4. Scaling

| # | Topic | Summary |
|---|---|---|
| 10 | [Fan-Out](https://lucagattoni.github.io/Claude-Loops/10-fan-out/) | Parallelizing at scale; scope-verified parallelism via Pre-Edit hooks; multi-loop coordination with priority ordering and collision detection; Agentic MapReduce (map signals → bounded fan-out → reduce → sandbox-verify); classifier-gated pre-claim parallelism (green/yellow/red/blocked, Kaola-Workflow) |
| 23 | [Fleet Engineering](https://lucagattoni.github.io/Claude-Loops/23-fleet-engineering/) | Managing many loops at enterprise scale; Fleet Four Pillars (Delegate/Improve/Approve/Connect); F0-F3 fleet maturity; Fleet Economics cost attribution; Claw vs. Assistant identity choice (cobusgreyling, Jun 2026); org-chart coordination over email as an alternative to graph topology (Alook); swarm topology via consensus protocols (queen-led + Raft/Byzantine/Gossip, ruflo); Gas Town case study (20-30 parallel instances via git-persisted Beads, merge-queue, crash-surviving identities); Bun case study (64 parallel instances / 4 worktrees / ~1,300 LOC-min, plain-worktree coordination with no queue layer, 535K-line Zig→Rust rewrite in 11 days); trust-driven runtime isolation (rvm coherence domains); ecosystem composition map (ruClip); desktop multi-agent office / "GOD agent" coordinator pattern (munder-difflin, 6,448★) |
| 22 | [Learned Orchestration](https://lucagattoni.github.io/Claude-Loops/22-learned-orchestration/) | Training the orchestrator instead of coding it — Sakana Fugu's Thinker/Worker/Verifier; training the harness as a control layer instead (Harness Maturity Score, advantage-weighted RL); GOAP A* replanning + behavioral trust scoring (ruflo); training-environment evolution for terminal agents; Harness-RL central-controller training; MemoryWalker train/inference-mismatch fix |
| 25 | [Long-Running Agents](https://lucagattoni.github.io/Claude-Loops/25-long-running-agents/) | Ralph loop (origin: ghuntley.com), planner-worker-judge, Inner/Outer Dual Loop, git-based recovery; session watchdog + 2h hard limit; multi-day Harness-of-Harness case study (70+ iterations); codex-maxxing megathread persistence; NVIDIA AVO 100% ARC-AGI-3 case study (persistent memory + supervisory intervention, 7-day GPU-kernel optimization beating cuDNN); 11-day/dozens-of-agents Fermat's Last Theorem Lean formalization (Prove2Me DAG coordination) |

---

# Part II — Developing with Claude Code

*Concrete and version-stamped. Platform facts carry the version they were true in, because they
move — this KB corrected eight stale facts in `v3.0.0` for exactly that reason.*

## 5. Start Here

| # | Topic | Summary |
|---|---|---|
| 35 | [Choosing Your Mode](https://lucagattoni.github.io/Claude-Loops/35-choosing-your-mode/) | **The router.** Interactive or autonomous? Three tests a task must pass before a loop is worth building (stop condition expressible as a passing command; more than ~5 runs; acceptable unattended blast radius); task-properties decision table; the middle ground of supervised-autonomy primitives where most real work sits; the compound-probability argument re-scoped as an argument for a *correction* loop rather than an *unattended* one; cost per unit of work over token volume (Ng, post-tokenmaxxing) |

## 6. The Workflow

| # | Topic | Summary |
|---|---|---|
| 36 | [The Development Workflow](https://lucagattoni.github.io/Claude-Loops/36-development-workflow/) | **Part II spine.** Ng's three phases (plan / execute / deploy-and-monitor) x five skills (directing the workflow, enabling agent autonomy, reviewing the work, customizing the agent and environment, coding agent foundations), each mapped to the Claude Code primitive that implements it; the spec scales with risk not with task; phase 3 as the handoff point to Part I; ClaudeWarp as worked reference implementation and the shrink-on-native design rule |
| 37 | [Session Architecture](https://lucagattoni.github.io/Claude-Loops/37-session-architecture/) | **One session or many.** Split by context boundary, never by job title; Anthropic's three justifications for multiple agents and the one that is absent (a different role in the same pipeline); the telephone game; the 90.2% figure and the population it was actually measured on; token multiples (3-10x, 15x vs chat) and single-agent parity under equal thinking-token budgets; the official four-way primitive decision matrix; specialise by framing not by role; Pinakes case study (36.8% of delegated spend on review, ~95.8% file re-derivation, value-biased fan-out truncation, refuted-claims table); the multiagent turf-war study |
| 15 | [Explore → Plan → Implement → Commit](https://lucagattoni.github.io/Claude-Loops/15-explore-plan-implement/) | The four-phase workflow for complex tasks |

## 7. Your Setup

| # | Topic | Summary |
|---|---|---|
| 5 | [CLAUDE.md](https://lucagattoni.github.io/Claude-Loops/05-claude-md/) | Persistent context layer — hierarchy, path-scoped rules, import syntax, HTML comments; rules have a half-life — periodic audit, not just one-time trim |
| 6 | [Skills](https://lucagattoni.github.io/Claude-Loops/06-skills/) | Reusable on-demand workflows; SDLC phases as non-skippable skill steps; agent-legible tools (`--help` as embedded SKILL.md); compiling expert corpora into skills (mimeo); skill-bundle compression (SkillZip Pro, 38% token reduction) |
| 12 | [Hooks](https://lucagattoni.github.io/Claude-Loops/12-hooks/) | Deterministic loop control — types, JSON output API, asyncRewake circuit breaker; exit code safety contract (never exit 1 in denial hooks) |
| 8 | [Permissions & Auto Mode](https://lucagattoni.github.io/Claude-Loops/08-permissions/) | Allow/deny/ask lists, auto mode, risk-tiered authorization by consequence, safety path denylist, agent trust ramp (4-stage), Reject+Replan pattern; ASK verdict + soft warning thresholds (`ask_thresholds_usd`); session-fires-first evaluation order |
| 3 | [The Six Building Blocks](https://lucagattoni.github.io/Claude-Loops/03-building-blocks/) | Automations, Worktrees, Skills, Connectors, Sub-agents, Memory; Routines for cloud execution |
| 16 | [Memory Patterns](https://lucagattoni.github.io/Claude-Loops/16-memory-patterns/) | **Native auto memory (v2.1.32/v2.1.59) and why it is not a loop's state** — scope, limits, off switches, subagent isolation, three issue-tracker failure modes, and the in-the-repo test; progress files, GitHub Issues as task queue, spec-driven loops; multi-backend task queue; 3-tier document lifecycle (per-cycle/doctrine/knowledge); STATE.md wave recovery; temporal knowledge graph (Graphiti); repo-owned durable ledger (ctxcarry — repo owns context, not the agent) + progress-file-as-memo-table (cache solved steps, prune failed branches); blind-spot ledger (append-only review-miss log, pre-checked next cycle); LLM Wiki (compiled, cross-linked organizational knowledge base — raw/wiki/index/log/claude.md; Karpathy); durable objectives with evidence logs + claimed_by todo ownership (loopx); learned memory substrates (RuVector adapter-based learning, funes cross-CLI trace indexing, OpenAI Computer History); a documented negative result on vector memory (0/6 vs. plain `rg`, orchestra) |
| 13 | [Context Management](https://lucagattoni.github.io/Claude-Loops/13-context-management/) | `/clear`, `/compact`, context resets vs. compaction, context anxiety; input governance pipeline; reactive compact with circuit breaker; Claude 5-gen system-prompt rewrite (80% removed, judgement over rules / progressive disclosure over upfront / interfaces over examples, Anthropic) |

## 8. Parallel Work

| # | Topic | Summary |
|---|---|---|
| 7 | [Subagents](https://lucagattoni.github.io/Claude-Loops/07-subagents/) | Keep main context clean; DOER/CHECKER; "strong eyes, cheap hands" cost-asymmetric role allocation + severity-proportional eye-tier routing; synthesis as non-delegable bottleneck; confidence-scored quality gates (≥80%); adversarial reviewer checklists (spec-stage + impl-stage); rationalizations to refuse; cache-safe forking + isolated child state by default + SubagentStart/Stop hook payloads; tenth-man critic + citation/prior-art collision review axes |
| 38 | [Agent Teams](https://lucagattoni.github.io/Claude-Loops/38-agent-teams/) | Lead plus teammates in their own context windows messaging each other directly, versus subagents reporting back to one caller; experimental and off by default; shared task list with file-locked claiming, mailboxes, TeammateIdle/TaskCreated/TaskCompleted hooks; model-selection precedence; hard limits (no session resumption, one team per session, no nesting); the official when-NOT-to guidance; the gotcha that a named subagent launches as a teammate when teams are enabled |
| 39 | [Dynamic Workflows](https://lucagattoni.github.io/Claude-Loops/39-dynamic-workflows/) | The runtime, where docs/24 holds the patterns. Script API (agent/pipeline/parallel/phase/log/args) with the pipeline-vs-parallel barrier distinction worked through; ultracode triggers; .claude/workflows persistence; hard limits (16 concurrent, 4,096 per call, 1,000 per run) and advisory size guidelines; resume-and-replay semantics; an honest cost section pairing practitioner token-burn reports against vendor-reported internal gains |

## 9. Running Unattended

| # | Topic | Summary |
|---|---|---|
| 9 | [Headless & Non-Interactive Mode](https://lucagattoni.github.io/Claude-Loops/09-headless-mode/) | `claude -p` — headless automation, session continuation, background sessions, CI flags |
| 28 | [Routines](https://lucagattoni.github.io/Claude-Loops/28-routines/) | Cloud-hosted loop execution: Schedule / API / GitHub triggers — no local machine needed; first-party production example (Anthropic field marketer, weekly BigQuery→Slack routine) |
| 29 | [Background Agents](https://lucagattoni.github.io/Claude-Loops/29-background-agents/) | `--bg` detached sessions, agent view, fan-out pattern, worktree isolation; zero-polling terminal-interrupt signaling (walidboulanouar); cloud/mobile background execution (Claude Cowork); OpenClaw restart resumability (for comparison) + sub-second cloud-session snapshotting (steipete) |
| 31 | [Claude Tag](https://lucagattoni.github.io/Claude-Loops/31-claude-tag/) | Ambient loops in Slack: channel-scoped identity, self-scheduling, org-wide context; the third LLM paradigm; production on-call for CI/CD (14-min median first-analysis, durable lessons.md across incidents) |

## 10. Cost & Safety

| # | Topic | Summary |
|---|---|---|
| 11 | [Cost & Turn Control](https://lucagattoni.github.io/Claude-Loops/11-cost-control/) | `--max-turns`, `--max-budget-usd`, effort levels; token cost by loop pattern (noop 3-5K → action run 200-250K); early exit rule; operational kill/pause/slow-down thresholds; reasoning effort as the dominant reliability lever (first-try-perfect 28%→89% for +9–29%; testing tools add 42–68% cost, no benefit); confidence-scheduled verification (skip passes when confidence is high, DeepSpark); multi-dimensional budget pressure (single scalar across tokens/tool-calls/wall-time/dollars, degradation thresholds); Ponytail overengineering countermeasure (-54% LOC/-22% tokens/-20% cost, 100% safety held) |
| 19 | [MCP Security](https://lucagattoni.github.io/Claude-Loops/19-mcp-security/) | AgentJacking and indirect prompt injection via MCP connectors |
| 33 | [Agent Security Hardening](https://lucagattoni.github.io/Claude-Loops/33-agent-security-hardening/) | OS-user-per-agent isolation, credential broker/sidecar/firewall dispositions, SECURITY_MATRIX.md, runtime policy gating (blast_radius/Intent Based Authorization/phase-scoped), credential rotation mid-session (verify-before-revoke cutover), fail-safe secret gate; credbroker resolution pattern (no model exposure); skill-ingestion security (OWASP Agentic Skills Top 10 + reviewer-only gate); A-F harness security scorecard; where default-deny actually gets loaded (MCP proxy / tool-dispatch layer / OS-kernel / session-bootstrap eval-parity); cross-org federation (zero-trust mTLS+ed25519, behavioral trust scoring formula, PII detection, ruflo); hook/context trust attacks (HookPry 92.5% success across 7 harnesses, Context Privilege Escalation across 12 harnesses); emergent multi-agent coordination risk (rogue-agent wiki collusion, DeepMind swarm self-governance); instruction-privilege-escalation corpus extended (13 attack objectives x 6 harnesses, automatic permission review does not close the gap) |

---

# 11. Reference

| # | Topic | Summary |
|---|---|---|
| 18 | [Quick Reference](https://lucagattoni.github.io/Claude-Loops/18-quick-reference/) | Commands and flags cheat sheet |
| 32 | [Reading List](https://lucagattoni.github.io/Claude-Loops/32-reading-list/) | Curated best articles — grouped by Why Loops / Getting Started / Harness Design / Self-Improving Harnesses / Goal Engineering / Production / Reference Implementations (session-orchestrator, goal-engineering, fleet-engineering, loopx, loop-contract-skill) |

---

## Sources

- [Claude Code Best Practices (official docs)](https://code.claude.com/docs/en/best-practices)
- [Claude Code — Subagents](https://code.claude.com/docs/en/sub-agents) · [Agent teams](https://code.claude.com/docs/en/agent-teams) · [Dynamic workflows](https://code.claude.com/docs/en/workflows)
- [When to use multi-agent systems (and when not to) — Anthropic](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them)
- [How we built our multi-agent research system — Anthropic](https://www.anthropic.com/engineering/multi-agent-research-system)
- [How the Agent Loop Works (Claude Agent SDK)](https://code.claude.com/docs/en/agent-sdk/agent-loop)
- [The AI Engineering Skills Map — Andrew Ng, The Batch](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map/)
- [Loop Engineering — Addy Osmani](https://addyosmani.com/blog/loop-engineering/)
- [The Anthropic leader who built Claude Code now writes loops — The New Stack](https://thenewstack.io/loop-engineering/)
- [Loop Engineering GitHub repo — cobusgreyling](https://github.com/cobusgreyling/loop-engineering)
- [Claude Code Agentic Workflow Patterns — MindStudio](https://www.mindstudio.ai/blog/claude-code-agentic-workflow-patterns)
- [ClaudeWarp — a loop harness for Claude Code](https://github.com/lucagattoni/Claude-Warp)
