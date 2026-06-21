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
