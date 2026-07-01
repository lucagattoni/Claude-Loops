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

- [The Paradigm Shift](01-paradigm-shift.md) — why loops beat single prompts (the compound-probability argument).
- [The Loop Contract](27-loop-contract.md) — the design spine: TRIGGER / SCOPE / ACTION / BUDGET / STOP, and the canonical stop-condition taxonomy.
- [Verification](04-verification.md) — the non-negotiable foundation: a loop is only as trustworthy as its ability to check its own work.

## Browse the knowledge base

Use the left sidebar for the full catalogue. One-line summaries for every topic live in
[`LOOP_ENGINEERING.md`](https://github.com/lucagattoni/Claude-Loops/blob/main/LOOP_ENGINEERING.md).

### Foundations

- [The Paradigm Shift](01-paradigm-shift.md)
- [The Factory Model](26-factory-model.md)
- [The Core Agent Loop Cycle](02-agent-loop-cycle.md)
- [Loop Maturity Model](20-loop-maturity-model.md)
- [Context vs. Loop Engineering](21-context-vs-loop-engineering.md)

### Designing a Loop

- [The Loop Contract](27-loop-contract.md)
- [Goal Engineering](30-goal-engineering.md)
- [Harness Patterns](24-harness-patterns.md)
- [Loop Patterns Catalog](34-loop-patterns.md)
- [The Six Building Blocks](03-building-blocks.md)
- [Routines](28-routines.md)
- [Claude Tag](31-claude-tag.md)
- [Explore → Plan → Implement → Commit](15-explore-plan-implement.md)

### Components

- [CLAUDE.md](05-claude-md.md)
- [Skills](06-skills.md)
- [Subagents](07-subagents.md)
- [Hooks](12-hooks.md)
- [Permissions & Auto Mode](08-permissions.md)
- [Headless & Non-Interactive Mode](09-headless-mode.md)

### State & Long-Running Loops

- [Context Management](13-context-management.md)
- [Memory Patterns](16-memory-patterns.md)
- [Long-Running Agents](25-long-running-agents.md)
- [Background Agents](29-background-agents.md)

### Quality & Safety

- [Verification](04-verification.md)
- [Common Failure Patterns](17-failure-patterns.md)
- [Human-in-the-Loop Escalation](14-human-in-the-loop.md)
- [Cost & Turn Control](11-cost-control.md)
- [MCP Security](19-mcp-security.md)
- [Agent Security Hardening](33-agent-security-hardening.md)

### Scaling

- [Fan-Out](10-fan-out.md)
- [Fleet Engineering](23-fleet-engineering.md)
- [Learned Orchestration](22-learned-orchestration.md)

### Reference

- [Quick Reference](18-quick-reference.md)
- [Reading List](32-reading-list.md)

## Stay current

This knowledge base is updated by a daily news-tracking loop that scans the community for
new loop-engineering practice and folds verified findings back into these docs.

- [Latest news digest](https://github.com/lucagattoni/Claude-Loops/blob/main/LOOP_ENGINEERING_NEWS.md)
- [Tracked sources](https://github.com/lucagattoni/Claude-Loops/blob/main/SOURCES.md)
- [Changelog](https://github.com/lucagattoni/Claude-Loops/blob/main/CHANGELOG.md)
