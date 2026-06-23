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
