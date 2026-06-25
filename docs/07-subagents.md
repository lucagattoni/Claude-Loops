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

**Why external evaluation enables improvement** (and self-assessment does not):
A generator agent assessing its own output has no gradient — it rated the work
acceptable before it generated it. An external evaluator with concrete, objective
criteria creates a signal the generator can actually improve against. This is
analogous to the GAN (Generative Adversarial Network) training dynamic: the
generator improves because the discriminator provides real pressure.

### Tuning evaluator agents

Out-of-the-box, Claude exhibits poor QA discipline in evaluator roles:
- Identifies issues but then talks itself into accepting them ("it works in most cases")
- Tests the happy path only; does not probe edge cases
- Grades against intent rather than observable behaviour

Fix with explicit prompt refinement against real examples of divergent judgment:
- Show the evaluator an example where it should have blocked but did not, and explain why
- Require it to output *evidence* (test output, stack trace, reproduction steps) — not verdicts
- Instruct it to fail loudly on any criterion not met, with no partial credit

Tuning the evaluator is iterative: expect 3–5 prompt refinement cycles before it
produces reliable results. (Anthropic Engineering, Mar 2026.)

## Synthesis — The Non-Delegable Bottleneck

DOER/CHECKER captures verification independence. A second, harder-to-see bottleneck
is **synthesis** — the coordinator converting distributed results into concrete next
prompts.

The failure mode is "task forwarding masquerading as coordination": the orchestrator
receives outputs from multiple agents and passes them verbatim to the next agent
without synthesising them. The next agent then does synthesis work inside a cluttered
context, without the coordinator's full picture.

| Delegable to subagents | Must stay with the coordinator |
|---|---|
| Research, implementation, verification | Integrating findings across agents |
| Specific checks, targeted reads | Deciding what matters from combined outputs |
| Parallel execution of defined tasks | Writing the concrete next prompt |

If your orchestrator's output is "here are the results from agents A, B, C" — that
is task forwarding. Synthesis looks like: "Based on A's auth race condition finding
and B's retry logic finding, the next step is exactly X."

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

## Confidence-Scored Quality Gates

Between phases, a quality gate can suppress low-confidence findings rather than
propagating noise upstream:

- A reviewer audits deliverables across a defined set of dimensions
- Each finding is scored for confidence (0–100%)
- Only findings above a confidence threshold surface to the orchestrator or user
  (the session-orchestrator uses **≥80%** as its threshold; calibrate to your
  verifier's false-positive rate)
- Low-confidence findings are logged but suppressed — they do not block or notify

Use confidence scoring for heuristic checks (code quality, design coherence) where
the verifier itself has inherent uncertainty. Keep binary gates (exit 0 / exit 2) for
deterministic checks (test pass/fail, lint errors) — those are never confidence-scored.

(session-orchestrator — [Kanevry/session-orchestrator](https://github.com/Kanevry/session-orchestrator), Jun 2026.)

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
