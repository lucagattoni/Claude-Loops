# Claude Loops

> Two disciplines, kept separate.

This knowledge base covers two related but distinct things. Most confusion about working with
coding agents comes from treating them as one.

| | **Part I — Loop Engineering** | **Part II — Developing with Claude Code** |
|---|---|---|
| **What it is** | Designing a system that prompts an agent *for* you — it fires on a trigger, works, verifies, and stops | You and Claude Code building software together, iteratively, with you in the loop |
| **You are** | Not at the keyboard | At the keyboard |
| **Scope** | General, tool-agnostic | Claude Code specific, version-stamped |
| **Start at** | [The Loop Contract](27-loop-contract.md) | [Choosing Your Mode](35-choosing-your-mode.md) |

**If you are not sure which you need, start at [Choosing Your Mode](35-choosing-your-mode.md).**
It is the router: three tests a task must pass before a loop is worth building, and a decision
table for everything that fails them.

---

## Which one is the default?

For **building software**, the honest answer is Part II.

> "most effective coding agent use is a complex, highly iterative process"
>
> — Andrew Ng, [*…Using Coding Agents*](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map-in-detail-using-coding-agents/), 2026-09-04 — explicitly *not* autonomous long-horizon execution

> "Most coding tasks involve fewer truly parallelizable tasks than research, and LLM agents are not
> yet great at coordinating and delegating to other agents in real time."
>
> — Anthropic, [*How we built our multi-agent research system*](https://www.anthropic.com/engineering/multi-agent-research-system), 2025-06-13

Part I is not the lesser half. It is where **recurring, well-specified, verifiable** work belongs —
triage, sweeps, dependency bumps, docs sync, digests. That work is genuinely better done by a loop
than by you, and the payoff compounds. But it is a *class* of work, not the default for everything.

---

## Part I — Loop Engineering

General and tool-agnostic. Claude Code appears here as an example, never as a prerequisite.

**The central act is designing the loop** — deciding *what* it is for, *how* it does it, *when* it
fires, *how much* it may spend, and *how you know it's done*. That last question is the one most
loops get wrong. The [Loop Contract](27-loop-contract.md) is the instrument for answering all five.

### 1. Foundations
- [1.1 The Paradigm Shift](01-paradigm-shift.md) — why a correction loop beats a single turn
- [1.2 The Core Agent Loop Cycle](02-agent-loop-cycle.md)
- [1.3 Loop Maturity Model](20-loop-maturity-model.md)
- [1.4 Context vs. Loop Engineering](21-context-vs-loop-engineering.md)
- [1.5 The Factory Model](26-factory-model.md)

### 2. Designing a Loop
- [2.1 The Loop Contract](27-loop-contract.md) — **the design spine**
- [2.2 Goal Engineering](30-goal-engineering.md)
- [2.3 Harness Patterns](24-harness-patterns.md)
- [2.4 Loop Patterns Catalog](34-loop-patterns.md)

### 3. Verification & Failure
- [3.1 Verification](04-verification.md) — **the non-negotiable foundation**
- [3.2 Common Failure Patterns](17-failure-patterns.md)
- [3.3 Human-in-the-Loop Escalation](14-human-in-the-loop.md)

### 4. Scaling
- [4.1 Fan-Out](10-fan-out.md)
- [4.2 Fleet Engineering](23-fleet-engineering.md)
- [4.3 Learned Orchestration](22-learned-orchestration.md)
- [4.4 Long-Running Agents](25-long-running-agents.md)

---

## Part II — Developing with Claude Code

Concrete and version-stamped. Platform facts here carry the version they were true in, because
they move — this knowledge base had to correct eight stale facts in `v3.0.0` for exactly that reason.

### 5. Start Here
- [5.1 Choosing Your Mode](35-choosing-your-mode.md) — **the router**

### 6. The Workflow
- [6.1 The Development Workflow](36-development-workflow.md) — plan → execute → operate, and the five skills
- [6.2 Session Architecture](37-session-architecture.md) — one session or many
- [6.3 Explore → Plan → Implement → Commit](15-explore-plan-implement.md)

### 7. Your Setup
- [7.1 CLAUDE.md](05-claude-md.md)
- [7.2 Skills](06-skills.md)
- [7.3 Hooks](12-hooks.md)
- [7.4 Permissions & Auto Mode](08-permissions.md)
- [7.5 The Six Building Blocks](03-building-blocks.md)
- [7.6 Memory Patterns](16-memory-patterns.md)
- [7.7 Context Management](13-context-management.md)

### 8. Parallel Work
- [8.1 Subagents](07-subagents.md)
- [8.2 Agent Teams](38-agent-teams.md)
- [8.3 Dynamic Workflows](39-dynamic-workflows.md)

### 9. Running Unattended
- [9.1 Headless & Non-Interactive Mode](09-headless-mode.md)
- [9.2 Routines](28-routines.md)
- [9.3 Background Agents](29-background-agents.md)
- [9.4 Claude Tag](31-claude-tag.md)

### 10. Cost & Safety
- [10.1 Cost & Turn Control](11-cost-control.md)
- [10.2 MCP Security](19-mcp-security.md)
- [10.3 Agent Security Hardening](33-agent-security-hardening.md)

---

## 11. Reference
- [11.1 Quick Reference](18-quick-reference.md)
- [11.2 Reading List](32-reading-list.md)

## Stay current

A daily loop scans the community for new practice and folds verified findings back into these docs.
It is itself a Part I loop — recurring, well-specified, and verified — which is why it exists.

- [12.1 News digest](news.md)
- [12.2 Sources](sources.md)
- [12.3 Changelog](changelog.md)
