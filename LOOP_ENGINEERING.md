# Claude Code Loop Engineering — Best Practices

> 📖 **Read this on the docs site: <https://lucagattoni.github.io/Claude-Loops/>** —
> a 3-column layout with search and navigation. This file is a flat index; the site is
> the intended reading experience.

> Stop writing prompts. Start designing loops.

Loop engineering is the shift from typing prompts into a coding agent to **writing the
system that prompts the agent for you**. Instead of a single one-shot instruction, you
design a workflow that observes, plans, acts, verifies, and iterates — autonomously,
while you sleep.

**The central act is designing the loop** — deciding *what* it is for, *how* it does it,
*when* it fires, *how much* it may spend, and *how you know it's done* (the question that
verification answers, and the one most loops get wrong). Everything else serves that
design. The [Loop Contract](https://lucagattoni.github.io/Claude-Loops/27-loop-contract/) is the instrument for answering
those questions; start there, then use the component and safety docs to fill each
property in.

---

## Topics

Row numbers are stable identifiers — they do not change when docs are reorganised.

### Foundations

| # | Topic | Summary |
|---|---|---|
| 1 | [The Paradigm Shift](https://lucagattoni.github.io/Claude-Loops/01-paradigm-shift/) | Old-way prompting vs. loops; compound probability argument (0.9^10 = 35%); the New Software Lifecycle; five Anthropic canonical patterns; >80% Anthropic engineers use self-improving loops |
| 26 | [The Factory Model](https://lucagattoni.github.io/Claude-Loops/26-factory-model/) | Orchestrating agent factories — spec quality and verification replace coding speed |
| 2 | [The Core Agent Loop Cycle](https://lucagattoni.github.io/Claude-Loops/02-agent-loop-cycle/) | Observe → Reason → Plan → Act → Verify; Universal Agent Thesis; two lenses on primitives (functional: execution/verification/orchestration/observability vs. mechanical: six building blocks); runtime termination signals mapped to the stop-condition taxonomy |
| 20 | [Loop Maturity Model](https://lucagattoni.github.io/Claude-Loops/20-loop-maturity-model/) | 14-step progression from manual prompter to loop engineer; per-loop L1/L2/L3 operational readiness levels |
| 21 | [Context vs. Loop Engineering](https://lucagattoni.github.io/Claude-Loops/21-context-vs-loop-engineering/) | Debate and vocabulary consolidation: four named disciplines — Loop, Context, Harness, Fleet Engineering |

### Designing a Loop

| # | Topic | Summary |
|---|---|---|
| 27 | [The Loop Contract](https://lucagattoni.github.io/Claude-Loops/27-loop-contract/) | **The design spine** — what/how/when/how-much framing mapped to TRIGGER/SCOPE/ACTION/BUDGET/STOP/REPORT; canonical **stop-condition taxonomy** (completion-check/budget/max-iterations/no-progress; rice-cooker problem; three-exit-code reference impl — loop-kernel; 8-named-exit-code + contract-hash tamper defense extension); job-description framing; Event Modeling; two quality gates; experience encoding; governed cross-session learning; YAML-declarative loop definition + VERDICT: PASS gate; 2-layer budget ceiling; self-discovery pattern; cross-run memory persistence (.loopflow/memory/); gate feedback injection to all agent prompts |
| 30 | [Goal Engineering](https://lucagattoni.github.io/Claude-Loops/30-goal-engineering/) | Goals vs. Loops decision framework; four Goal Primitives; GOAL.md schema; six canonical goal patterns; G0-G3 readiness scoring; a-priori pattern-keyed goal-cost estimation (cobusgreyling, Jun 2026) |
| 24 | [Harness Patterns](https://lucagattoni.github.io/Claude-Loops/24-harness-patterns/) | Harness vs. Loop layers; harness as org-level artifact (Karpathy); harness vs. environment engineering (in-process vs. OS-level controls); three deployment patterns (Approval-First/Allow-list/Sandboxed); three-agent full-stack harness; unstable components axiom; ledger closure; five-wave model; runtime republic vs. constitutional control plane; harness-agnostic projection + .apm/ primitive manifest; 8-phase DAG + steer messages; meta-harness 3-tier policy hierarchy + compaction persistence + resume; agent YAML definition schema; organizational learning stage; harness update file safety contract; quantified harness>model (Terminal-Bench Top30→Top5, harness-only; 7x cost reduction, HuggingFace Jul 2026); harness conformance testing (harness-bench); self-improving harnesses (Self-Harness/AHE/HarnessX — trace-driven evolution, verified prediction contracts, ablation: gains from tools/middleware/memory not prompts); control-plane/execution-plane kernel-gated mutation; official Claude-team loop-type taxonomy (turn/goal/time-based/proactive) |
| 34 | [Loop Patterns Catalog](https://lucagattoni.github.io/Claude-Loops/34-loop-patterns/) | Seven named loop patterns (Daily Triage, PR Babysitter, CI Sweeper, Dependency Sweeper, Post-Merge Cleanup, Changelog Drafter, Issue Triage); L1/L2/L3 readiness levels; token costs; multi-loop coordination with concrete STATE.md example; per-agent heartbeat coordination (harnery pattern); three-loop onboarding sequence; Debt Audit + Docs Sync patterns |
| 3 | [The Six Building Blocks](https://lucagattoni.github.io/Claude-Loops/03-building-blocks/) | Automations, Worktrees, Skills, Connectors, Sub-agents, Memory; Routines for cloud execution |
| 28 | [Routines](https://lucagattoni.github.io/Claude-Loops/28-routines/) | Cloud-hosted loop execution: Schedule / API / GitHub triggers — no local machine needed |
| 31 | [Claude Tag](https://lucagattoni.github.io/Claude-Loops/31-claude-tag/) | Ambient loops in Slack: channel-scoped identity, self-scheduling, org-wide context; the third LLM paradigm |
| 15 | [Explore → Plan → Implement → Commit](https://lucagattoni.github.io/Claude-Loops/15-explore-plan-implement/) | The four-phase workflow for complex tasks |

### Components

| # | Topic | Summary |
|---|---|---|
| 5 | [CLAUDE.md](https://lucagattoni.github.io/Claude-Loops/05-claude-md/) | Persistent context layer — hierarchy, path-scoped rules, import syntax, HTML comments |
| 6 | [Skills](https://lucagattoni.github.io/Claude-Loops/06-skills/) | Reusable on-demand workflows; SDLC phases as non-skippable skill steps; agent-legible tools (`--help` as embedded SKILL.md) |
| 7 | [Subagents](https://lucagattoni.github.io/Claude-Loops/07-subagents/) | Keep main context clean; DOER/CHECKER; "strong eyes, cheap hands" cost-asymmetric role allocation + severity-proportional eye-tier routing; synthesis as non-delegable bottleneck; confidence-scored quality gates (≥80%); adversarial reviewer checklists (spec-stage + impl-stage); rationalizations to refuse |
| 12 | [Hooks](https://lucagattoni.github.io/Claude-Loops/12-hooks/) | Deterministic loop control — types, JSON output API, asyncRewake circuit breaker; exit code safety contract (never exit 1 in denial hooks) |
| 8 | [Permissions & Auto Mode](https://lucagattoni.github.io/Claude-Loops/08-permissions/) | Allow/deny/ask lists, auto mode, risk-tiered authorization by consequence, safety path denylist, agent trust ramp (4-stage), Reject+Replan pattern; ASK verdict + soft warning thresholds (`ask_thresholds_usd`); session-fires-first evaluation order |
| 9 | [Headless & Non-Interactive Mode](https://lucagattoni.github.io/Claude-Loops/09-headless-mode/) | `claude -p` — headless automation, session continuation, background sessions, CI flags |

### State & Long-Running Loops

| # | Topic | Summary |
|---|---|---|
| 13 | [Context Management](https://lucagattoni.github.io/Claude-Loops/13-context-management/) | `/clear`, `/compact`, context resets vs. compaction, context anxiety; input governance pipeline; reactive compact with circuit breaker |
| 16 | [Memory Patterns](https://lucagattoni.github.io/Claude-Loops/16-memory-patterns/) | Progress files, GitHub Issues as task queue, spec-driven loops; multi-backend task queue; 3-tier document lifecycle (per-cycle/doctrine/knowledge); STATE.md wave recovery; temporal knowledge graph (Graphiti); repo-owned durable ledger (ctxcarry — repo owns context, not the agent) + progress-file-as-memo-table (cache solved steps, prune failed branches); blind-spot ledger (append-only review-miss log, pre-checked next cycle) |
| 25 | [Long-Running Agents](https://lucagattoni.github.io/Claude-Loops/25-long-running-agents/) | Ralph loop, planner-worker-judge, Inner/Outer Dual Loop, git-based recovery; session watchdog + 2h hard limit |
| 29 | [Background Agents](https://lucagattoni.github.io/Claude-Loops/29-background-agents/) | `--bg` detached sessions, agent view, fan-out pattern, worktree isolation |

### Quality & Safety

| # | Topic | Summary |
|---|---|---|
| 4 | [Verification](https://lucagattoni.github.io/Claude-Loops/04-verification/) | The non-negotiable foundation — verification = the completion-check stop; verifier integrity (external unfakeable verifier, mechanical gates vs. adjudicators, frozen content-hashed tests, provenance-bound claims + majority-vote council, isomorphic-perturbation checks, cross-model independence — Claude implements / Codex reviews — with VERDICT BLOCK/SUGGEST + dual stop; information-asymmetry/blind validation — checker never sees the maker's reasoning; run-record-anchored capture gate); eval metrics (pass@k vs. pass^k, 3 grader types, 70/30 human-LLM blend); proof-of-work demo artifacts; strategies, Type A/B classification, verdict taxonomy, cross-run patterns, belief state machine + R0-R5 risk levels, A/A baseline, LLM-as-a-judge (Opik), Firefox case study (423 fixes); "Surface" vocabulary; verification mode discipline (TDD/goal-based/visual); self-coverage gate (RFC-0051); traceability-lint; oracle problem (~6% precision); structured critic finding taxonomy (6 categories) |
| 17 | [Common Failure Patterns](https://lucagattoni.github.io/Claude-Loops/17-failure-patterns/) | Cognitive surrender, orchestration tax, reward hacking, context pollution, amplification effect, State Rot, Verifier Theater, Notification Fatigue, Fixing flakes with code, Over-Reach, Parallel Collision, Verdict oscillation, Zombie finding (findings ratchet), and more |
| 14 | [Human-in-the-Loop Escalation](https://lucagattoni.github.io/Claude-Loops/14-human-in-the-loop/) | When to pause and ask for human input; checkpoint placement (4 tests, 80/20 split, override-rate calibration); the three nested feedback loops (agent/developer/user cadences) and the human "context advantage" (Andrew Ng) |
| 11 | [Cost & Turn Control](https://lucagattoni.github.io/Claude-Loops/11-cost-control/) | `--max-turns`, `--max-budget-usd`, effort levels; token cost by loop pattern (noop 3-5K → action run 200-250K); early exit rule; operational kill/pause/slow-down thresholds; reasoning effort as the dominant reliability lever (first-try-perfect 28%→89% for +9–29%; testing tools add 42–68% cost, no benefit) |
| 19 | [MCP Security](https://lucagattoni.github.io/Claude-Loops/19-mcp-security/) | AgentJacking and indirect prompt injection via MCP connectors |
| 33 | [Agent Security Hardening](https://lucagattoni.github.io/Claude-Loops/33-agent-security-hardening/) | OS-user-per-agent isolation, credential broker/sidecar/firewall dispositions, SECURITY_MATRIX.md, runtime policy gating (blast_radius/intent_gate/phase-scoped), credential rotation mid-session (verify-before-revoke cutover), fail-safe secret gate; credbroker resolution pattern (no model exposure); skill-ingestion security (OWASP Agentic Skills Top 10 + reviewer-only gate); A-F harness security scorecard |

### Scaling

| # | Topic | Summary |
|---|---|---|
| 10 | [Fan-Out](https://lucagattoni.github.io/Claude-Loops/10-fan-out/) | Parallelizing at scale; scope-verified parallelism via Pre-Edit hooks; multi-loop coordination with priority ordering and collision detection |
| 23 | [Fleet Engineering](https://lucagattoni.github.io/Claude-Loops/23-fleet-engineering/) | Managing many loops at enterprise scale; Fleet Four Pillars (Delegate/Improve/Approve/Connect); F0-F3 fleet maturity; Fleet Economics cost attribution; Claw vs. Assistant identity choice (cobusgreyling, Jun 2026) |
| 22 | [Learned Orchestration](https://lucagattoni.github.io/Claude-Loops/22-learned-orchestration/) | Training the orchestrator instead of coding it — Sakana Fugu's Thinker/Worker/Verifier |

### Reference

| # | Topic | Summary |
|---|---|---|
| 18 | [Quick Reference](https://lucagattoni.github.io/Claude-Loops/18-quick-reference/) | Commands and flags cheat sheet |
| 32 | [Reading List](https://lucagattoni.github.io/Claude-Loops/32-reading-list/) | Curated best articles — grouped by Why Loops / Getting Started / Harness Design / Self-Improving Harnesses / Goal Engineering / Production / Reference Implementations (session-orchestrator, goal-engineering, fleet-engineering) |

---

## Sources

- [Claude Code Best Practices (official docs)](https://code.claude.com/docs/en/best-practices)
- [How the Agent Loop Works (Claude Agent SDK)](https://code.claude.com/docs/en/agent-sdk/agent-loop)
- [Loop Engineering — Addy Osmani](https://addyosmani.com/blog/loop-engineering/)
- [The Anthropic leader who built Claude Code now writes loops — The New Stack](https://thenewstack.io/loop-engineering/)
- [Stop Prompting Your Agent. Start Writing Loops. — Medium](https://medium.com/@garbarok/stop-prompting-your-agent-start-writing-loops-73608223f075)
- [I Don't Prompt Claude Anymore. I Write Loops. — Medium](https://medium.com/@fahey_james/i-dont-prompt-claude-anymore-i-write-loops-that-prompt-claude-57e48a4f28d7)
- [Loop Engineering GitHub repo — cobusgreyling](https://github.com/cobusgreyling/loop-engineering)
- [Claude Code Agentic Workflow Patterns — MindStudio](https://www.mindstudio.ai/blog/claude-code-agentic-workflow-patterns)
