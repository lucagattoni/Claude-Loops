# Subagents — Keep Main Context Clean

The context window is your most critical resource. Subagents protect it.

```text
Use subagents to investigate how our auth system handles token refresh.
Report a summary — I don't need the full file contents in this session.
```

The subagent reads dozens of files, runs grep searches, and reports back a concise
summary. Your main context grows by that summary only, not by every file read.

## Writer/Reviewer pattern

```text
Session A (Writer): "Implement rate limiting for /api/v1 endpoints"

Session B (Reviewer): "Review @src/middleware/rateLimiter.ts.
  Check for race conditions, edge cases, and consistency
  with existing middleware. Report gaps only."

Session A: "Here's the review: [Session B output]. Address the issues."
```

## DOER/CHECKER Pattern

A named, explicit form of the writer/reviewer pattern with a stronger principle:

- **DOER**: executes the task
- **CHECKER**: independently validates output — *never* the same agent that did the work

```text
Agent A (DOER): "Implement the login endpoint. Write tests."

Agent B (CHECKER): "Review the login endpoint in @src/auth/login.ts.
  Does it handle the three failure modes in SPEC.md?
  Report gaps only — do not suggest fixes."
```

The core rule: **never let the AI grade its own output.** A DOER is biased toward the
work it produced — the CHECKER must be a fresh session with no attachment to the
implementation.

> "The AI was never the hard part — the CHECKER is." — Sabrina Ramonov, Jun 2026

## Built-in subagent types

Claude Code ships with named subagent types you can invoke directly:

| Type | Model | Tools | Use when |
|---|---|---|---|
| `fork` | Same as parent | All (inherits context) | Fast parallel work — shares parent's prompt cache |
| `general-purpose` | Same as parent | All | Standard isolated subtask |
| `Explore` | Haiku | Read-only | Fast codebase search; skip CLAUDE.md for speed |
| `Plan` | Same as parent | Read-only | Architecture planning in plan mode |

`fork` is the cheapest subagent — it inherits the parent's context and prompt cache,
so it starts fast and shares what the parent already knows.

## Custom agents (`.claude/agents/`)

Define reusable agent roles with frontmatter in `.claude/agents/<name>.md`:

```markdown
---
name: security-reviewer
description: Audits code for injection, auth flaws, and exposed secrets
model: claude-opus-4-8
tools: [Read, Grep, Glob, Bash]
permission_mode: auto
---
You are a senior security engineer. Flag: SQL/XSS/command injection,
auth/authz flaws, secrets in code, insecure data handling.
Provide file:line references and suggested fixes.
```

Invoke with: `Use a subagent: security-reviewer — review @src/auth/`.

Agent files are loaded from (in priority order): managed settings → `--agents` CLI
flag → `.claude/agents/` → `~/.claude/agents/` → plugin `agents/`.

## Nesting

Subagents can spawn their own subagents, up to 5 levels deep. Use this for
hierarchical delegation: orchestrator → specialist → verifier.

Forked subagents (`subagent_type: "fork"`) inherit the full parent context and
prompt cache — ideal when the subtask needs all the context the parent has built up.

## Controlling subagent permissions

Restrict which subagents can be spawned or what models they can use:

```json
// .claude/settings.json
{
  "permissions": {
    "deny": [
      "Agent(model:opus)",    // block Opus subagents (cost control)
      "Agent(Explore)"        // disable the Explore built-in
    ]
  }
}
```

Disable all subagent delegation:
```json
{ "permissions": { "deny": ["Agent"] } }
```

Disable built-in agents in headless mode only:
```bash
CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS=1 claude -p "task"
```

## Related

- [Background Agents](29-background-agents.md) — sessions running independently (not within a parent session)
- [Fan-Out](10-fan-out.md) — parallelism using multiple subagents
- [Hooks](12-hooks.md) — SubagentStart/SubagentStop lifecycle events
