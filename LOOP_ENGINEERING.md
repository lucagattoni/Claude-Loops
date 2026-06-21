# Claude Code Loop Engineering — Best Practices

> Stop writing prompts. Start designing loops.

Loop engineering is the shift from typing prompts into a coding agent to **writing the
system that prompts the agent for you**. Instead of a single one-shot instruction, you
design a workflow that observes, plans, acts, verifies, and iterates — autonomously,
while you sleep.

---

## Topics

| # | Topic | Summary |
|---|---|---|
| 1 | [The Paradigm Shift](docs/paradigm-shift.md) | Old-way prompting vs. autonomous loop design |
| 2 | [The Core Agent Loop Cycle](docs/agent-loop-cycle.md) | Observe → Reason → Plan → Act → Verify |
| 3 | [The Six Building Blocks](docs/building-blocks.md) | Automations, Worktrees, Skills, Connectors, Sub-agents, Memory |
| 4 | [Verification](docs/verification.md) | The non-negotiable foundation — always give Claude a check it can run |
| 5 | [CLAUDE.md](docs/claude-md.md) | Persistent context layer — keep it short and surgical |
| 6 | [Skills](docs/skills.md) | Reusable on-demand workflows stored in `.claude/skills/` |
| 7 | [Subagents](docs/subagents.md) | Keep main context clean; writer/reviewer pattern |
| 8 | [Permissions & Auto Mode](docs/permissions.md) | Allowlists, auto mode, bypassPermissions |
| 9 | [Headless & Non-Interactive Mode](docs/headless-mode.md) | `claude -p` — the entry point for all automation |
| 10 | [Fan-Out](docs/fan-out.md) | Parallelizing at scale across many Claude invocations |
| 11 | [Cost & Turn Control](docs/cost-control.md) | `--max-turns`, `--max-budget-usd`, effort levels |
| 12 | [Hooks](docs/hooks.md) | Deterministic side effects — PreToolUse, PostToolUse, Stop |
| 13 | [Context Management](docs/context-management.md) | `/clear`, `/compact`, subagents for investigation |
| 14 | [Human-in-the-Loop Escalation](docs/human-in-the-loop.md) | When to pause and ask for human input |
| 15 | [Explore → Plan → Implement → Commit](docs/explore-plan-implement.md) | The four-phase workflow for complex tasks |
| 16 | [Memory Patterns](docs/memory-patterns.md) | Progress files, GitHub Issues as task queue, spec-driven loops |
| 17 | [Common Failure Patterns](docs/failure-patterns.md) | Kitchen-sink sessions, correction loops, uncapped runs |
| 18 | [Quick Reference](docs/quick-reference.md) | Commands and flags cheat sheet |

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
