# Claude Tag — Ambient Loops in Team Tools

Claude Tag is Claude Code deployed as a persistent, ambient agent inside Slack.
Rather than a scheduled cron or a manually triggered terminal session, the loop
lives inside the communication layer where the team already works.

(Anthropic, ["Introducing Claude Tag"](https://www.anthropic.com/news/introducing-claude-tag), Jun 2026.)

## Architecture

### Channel-scoped identity
Each Slack channel gets a distinct Claude instance with isolated memory and tool
access. Sales Claude ≠ Engineering Claude — different permissions, different
context, different guardrails. Admins configure each instance per channel.

### Ambient context
Claude Tag reads the full channel history without requiring re-explanation. It
builds tacit knowledge from team conversations over time and can draw on other
accessible Slack channels and data sources (not private channels). This is
persistent memory built from natural team communication rather than explicit
knowledge files.

### Self-scheduling
Claude Tag can schedule tasks for itself and pursue projects autonomously over
hours or days. It supports ambient behaviour: proactively flagging relevant
information and following up on stalled threads without being asked.

### Isolated sandbox per invocation
Each invoked task spins up its own sandbox — clones repos, writes code, runs tests,
commits work. The pattern is identical to the worktree isolation model in
[Background Agents](29-background-agents.md).

## Governance
- Token spend limits per org and per channel
- Full audit logging for all agent actions
- Role-based memory separation enforced at the instance level

## The Third LLM Paradigm

> "Imo this is the 3rd major redesign of LLM UIUX. The first paradigm was that the LLM is a
> website you go to, the second was that it is an app you download to your computer. This
> third one is that it is a self-contained, persistent, asynchronous entity with org-wide
> tools and context, working alongside teams of humans." — Andrej Karpathy,
> [X, Jun 2026](https://x.com/karpathy/status/2069547676849557725)

| Generation | Form | Interaction model |
|---|---|---|
| 1st | Website / chat | One-shot conversation; user-directed |
| 2nd | App integration (IDE, terminal) | Session-based; user-initiated |
| 3rd | Ambient entity | Persistent; self-scheduling; org-wide context |

Claude Tag is Anthropic's first shipped instance of the third paradigm.
Boris Cherny (Claude Code's creator) frames it as "Claude Everywhere":
loops embedded across all team tools, not just the terminal.

## Signal data
- 65% of Anthropic's product team's code is created using their internal version of Claude Tag
- Powered by Claude Opus 4.8
- "We see Claude Tag as the beginning of an evolution of Claude Code: it makes the model even more proactive, and it works better with a full team." — Anthropic, ["Introducing Claude Tag"](https://www.anthropic.com/news/introducing-claude-tag)

## Production Deployment: On-Call for CI/CD

Anthropic runs Claude Tag as a persistent Slack on-call responder for CI/CD incidents,
running the same monitor → triage → investigate → verify loop as the architecture above,
specialized for infrastructure failures: it spins up parallel **executor subagents** to
investigate each candidate dependency via MCP connectors, then verifies the proposed fix
before reporting back.

**Speed:** Claude posts its first evidence-grounded analysis a median of **14 minutes**
after an incident opens (measuring time-to-first-analysis, not detection time), and in the
fastest observed cases names the root cause within 4 minutes.

**Durable memory across incidents (`lessons.md`):** a running log of every incident
resolved — what happened, the root cause, the fix, and the gotcha worth remembering —
that Claude appends to automatically. Every new investigation starts by reading it first.
A notable entry: *"query the data first, then theorize. Config tells you what could go
wrong; metrics tell you what did."* When the same pattern recurs often enough, it gets
promoted out of the log and into the investigation skill itself — a lighter-weight
version of [Warp's inner/outer skill-improvement loop](24-harness-patterns.md#self-improving-harnesses),
here triggered by pattern frequency in a log rather than a scheduled observer agent.
([Anthropic, "How Claude Tag runs on-call for CI/CD at Anthropic"](https://claude.com/blog/ai-ci-cd-on-call), Aug 2026.)

## Deployment mode comparison

| Mode | Trigger | Persistence | Context |
|---|---|---|---|
| Terminal session | Manual | Per-session | Local machine |
| [Routine](28-routines.md) | Schedule / API / GitHub event | Cloud-hosted | Configured per routine |
| [Background agent](29-background-agents.md) (`--bg`) | Manual flag | Session-isolated | Per worktree |
| Claude Tag | @mention in Slack | Persistent channel memory | Org-wide + channel history |
