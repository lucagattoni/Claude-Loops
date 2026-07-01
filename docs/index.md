# Loop Engineering

> Stop writing prompts. Start designing loops.

Loop engineering is the shift from typing prompts into a coding agent to **writing the
system that prompts the agent for you**. Instead of a single one-shot instruction, you
design a workflow that observes, plans, acts, verifies, and iterates — autonomously,
while you sleep.

**The central act is designing the loop** — deciding *what* it is for, *how* it does it,
*when* it fires, *how much* it may spend, and *how you know it's done* (the question
verification answers, and the one most loops get wrong). Everything else serves that
design. The [Loop Contract](27-loop-contract.md) is the instrument for answering those
questions; start there, then use the component and safety docs to fill each property in.

## Start here

- [1.1 The Paradigm Shift](01-paradigm-shift.md) — why loops beat single prompts (the compound-probability argument).
- [2.1 The Loop Contract](27-loop-contract.md) — the design spine: TRIGGER / SCOPE / ACTION / BUDGET / STOP, and the canonical stop-condition taxonomy.
- [5.1 Verification](04-verification.md) — the non-negotiable foundation: a loop is only as trustworthy as its ability to check its own work.

## Browse the knowledge base

Use the left sidebar for the full catalogue. One-line summaries for every topic live in
[`LOOP_ENGINEERING.md`](https://github.com/lucagattoni/Claude-Loops/blob/main/LOOP_ENGINEERING.md).

### 1. Foundations

- [1.1 The Paradigm Shift](01-paradigm-shift.md)
- [1.2 The Factory Model](26-factory-model.md)
- [1.3 The Core Agent Loop Cycle](02-agent-loop-cycle.md)
- [1.4 Loop Maturity Model](20-loop-maturity-model.md)
- [1.5 Context vs. Loop Engineering](21-context-vs-loop-engineering.md)

### 2. Designing a Loop

- [2.1 The Loop Contract](27-loop-contract.md)
- [2.2 Goal Engineering](30-goal-engineering.md)
- [2.3 Harness Patterns](24-harness-patterns.md)
- [2.4 Loop Patterns Catalog](34-loop-patterns.md)
- [2.5 The Six Building Blocks](03-building-blocks.md)
- [2.6 Routines](28-routines.md)
- [2.7 Claude Tag](31-claude-tag.md)
- [2.8 Explore → Plan → Implement → Commit](15-explore-plan-implement.md)

### 3. Components

- [3.1 CLAUDE.md](05-claude-md.md)
- [3.2 Skills](06-skills.md)
- [3.3 Subagents](07-subagents.md)
- [3.4 Hooks](12-hooks.md)
- [3.5 Permissions & Auto Mode](08-permissions.md)
- [3.6 Headless & Non-Interactive Mode](09-headless-mode.md)

### 4. State & Long-Running Loops

- [4.1 Context Management](13-context-management.md)
- [4.2 Memory Patterns](16-memory-patterns.md)
- [4.3 Long-Running Agents](25-long-running-agents.md)
- [4.4 Background Agents](29-background-agents.md)

### 5. Quality & Safety

- [5.1 Verification](04-verification.md)
- [5.2 Common Failure Patterns](17-failure-patterns.md)
- [5.3 Human-in-the-Loop Escalation](14-human-in-the-loop.md)
- [5.4 Cost & Turn Control](11-cost-control.md)
- [5.5 MCP Security](19-mcp-security.md)
- [5.6 Agent Security Hardening](33-agent-security-hardening.md)

### 6. Scaling

- [6.1 Fan-Out](10-fan-out.md)
- [6.2 Fleet Engineering](23-fleet-engineering.md)
- [6.3 Learned Orchestration](22-learned-orchestration.md)

### 7. Reference

- [7.1 Quick Reference](18-quick-reference.md)
- [7.2 Reading List](32-reading-list.md)

## Stay current

This knowledge base is updated by a daily news-tracking loop that scans the community for
new loop-engineering practice and folds verified findings back into these docs.

- [8.1 News digest](news.md)
- [8.2 Sources](sources.md)
- [8.3 Changelog](changelog.md)
