# Claude Code Loop Engineering — Best Practices

> Stop writing prompts. Start designing loops.

Loop engineering is the shift from typing prompts into a coding agent to **writing the
system that prompts the agent for you**. Instead of a single one-shot instruction, you
design a workflow that observes, plans, acts, verifies, and iterates — autonomously,
while you sleep.

---

## Topics

Row numbers are stable identifiers — they do not change when docs are reorganised.

### Foundations

| # | Topic | Summary |
|---|---|---|
| 1 | [The Paradigm Shift](docs/01-paradigm-shift.md) | Old-way prompting vs. autonomous loop design; the New Software Lifecycle |
| 26 | [The Factory Model](docs/26-factory-model.md) | Orchestrating agent factories — spec quality and verification replace coding speed |
| 2 | [The Core Agent Loop Cycle](docs/02-agent-loop-cycle.md) | Observe → Reason → Plan → Act → Verify; Universal Agent Thesis |
| 20 | [Loop Maturity Model](docs/20-loop-maturity-model.md) | 14-step progression from manual prompter to loop engineer |
| 21 | [Context vs. Loop Engineering](docs/21-context-vs-loop-engineering.md) | Debate and vocabulary consolidation: four named disciplines — Loop, Context, Harness, Fleet Engineering |

### Designing a Loop

| # | Topic | Summary |
|---|---|---|
| 27 | [The Loop Contract](docs/27-loop-contract.md) | TRIGGER/SCOPE/ACTION/BUDGET/STOP/REPORT — six properties; two quality gates; experience encoding between cycles |
| 24 | [Harness Patterns](docs/24-harness-patterns.md) | Harness vs. Loop layers; three-agent full-stack harness; sprint contracts; load-bearing vs. optional components; EDA and serverless |
| 3 | [The Six Building Blocks](docs/03-building-blocks.md) | Automations, Worktrees, Skills, Connectors, Sub-agents, Memory; Routines for cloud execution |
| 28 | [Routines](docs/28-routines.md) | Cloud-hosted loop execution: Schedule / API / GitHub triggers — no local machine needed |
| 15 | [Explore → Plan → Implement → Commit](docs/15-explore-plan-implement.md) | The four-phase workflow for complex tasks |

### Components

| # | Topic | Summary |
|---|---|---|
| 5 | [CLAUDE.md](docs/05-claude-md.md) | Persistent context layer — hierarchy, path-scoped rules, import syntax, HTML comments |
| 6 | [Skills](docs/06-skills.md) | Reusable on-demand workflows; SDLC phases as non-skippable skill steps |
| 7 | [Subagents](docs/07-subagents.md) | Keep main context clean; DOER/CHECKER; built-in types (fork/Explore/Plan); custom agents |
| 12 | [Hooks](docs/12-hooks.md) | Deterministic loop control — types, JSON output API, asyncRewake circuit breaker |
| 8 | [Permissions & Auto Mode](docs/08-permissions.md) | Allow/deny/ask lists, auto mode, Tool(param:value) patterns, PermissionRequest hook |
| 9 | [Headless & Non-Interactive Mode](docs/09-headless-mode.md) | `claude -p` — headless automation, session continuation, background sessions, CI flags |

### State & Long-Running Loops

| # | Topic | Summary |
|---|---|---|
| 13 | [Context Management](docs/13-context-management.md) | `/clear`, `/compact`, subagents for investigation |
| 16 | [Memory Patterns](docs/16-memory-patterns.md) | Progress files, GitHub Issues as task queue, spec-driven loops |
| 25 | [Long-Running Agents](docs/25-long-running-agents.md) | Ralph loop, planner-worker-judge, Inner/Outer Dual Loop, git-based recovery |
| 29 | [Background Agents](docs/29-background-agents.md) | `--bg` detached sessions, agent view, fan-out pattern, worktree isolation |

### Quality & Safety

| # | Topic | Summary |
|---|---|---|
| 4 | [Verification](docs/04-verification.md) | The non-negotiable foundation — always give Claude a check it can run |
| 17 | [Common Failure Patterns](docs/17-failure-patterns.md) | Cognitive surrender, orchestration tax, reward hacking, context pollution, context drift, dark factory, circuit breakers, and more |
| 14 | [Human-in-the-Loop Escalation](docs/14-human-in-the-loop.md) | When to pause and ask for human input |
| 11 | [Cost & Turn Control](docs/11-cost-control.md) | `--max-turns`, `--max-budget-usd`, effort levels; token multipliers + real project benchmarks ($9 broken → $200 working) |
| 19 | [MCP Security](docs/19-mcp-security.md) | AgentJacking and indirect prompt injection via MCP connectors |

### Scaling

| # | Topic | Summary |
|---|---|---|
| 10 | [Fan-Out](docs/10-fan-out.md) | Parallelizing at scale across many Claude invocations |
| 23 | [Fleet Engineering](docs/23-fleet-engineering.md) | Managing many loops at enterprise scale: governance, observability, routing |
| 22 | [Learned Orchestration](docs/22-learned-orchestration.md) | Training the orchestrator instead of coding it — Sakana Fugu's Thinker/Worker/Verifier |

### Reference

| # | Topic | Summary |
|---|---|---|
| 18 | [Quick Reference](docs/18-quick-reference.md) | Commands and flags cheat sheet |

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
