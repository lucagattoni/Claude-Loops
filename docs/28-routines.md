# Routines — Cloud-Hosted Loop Execution

Routines are Claude Code's cloud execution primitive: a saved loop configuration
(prompt + repos + connectors) that runs on Anthropic infrastructure. Your laptop can
be closed — the loop keeps running until its stopping condition is met.

## Routines vs. local headless runs

| | Headless (`claude -p`) | Routines |
|---|---|---|
| Runs on | Your machine or CI | Anthropic cloud |
| Survives laptop close | No | Yes |
| Trigger types | CI event or cron | Schedule / API / GitHub event |
| Permission prompts during run | Auto-denied | Routed to your main session |
| Setup | Shell script / CI YAML | `/schedule` CLI command |

## Three trigger types

### Schedule
Cron-style scheduling (minimum interval: 1 hour) or one-off timestamps:

```bash
# Set up a nightly schedule inside any Claude Code session
/schedule  # interactive setup → choose "Schedule" → enter cron expression
```

```
/schedule list          # view all active Routines and next run times
/schedule update        # edit an existing Routine
/schedule run           # trigger an immediate manual run
```

### API
Fire a Routine via HTTP POST — connect to webhooks, alerts, CI pipelines:

```bash
# Verify the exact endpoint, path, and beta header in the official Routines docs
# before using in production — this is an experimental API.
POST /v1/claude_code/routines/<routine-id>/fire
Authorization: Bearer <your-api-key>
anthropic-beta: experimental-cc-routine-2026-04-01

{ "text": "optional context injected into this run" }
```

Returns immediately with `{"session_id": "...", "session_url": "..."}` — the run
continues asynchronously in the cloud.

### GitHub
Trigger on repository events:
- **PR events**: opened / closed / labeled / synchronize / ready_for_review
- **Release events**: published / created / edited

Pair with path filters to scope which changes invoke the Routine.

## Loop engineering patterns

**Nightly quality gate:**
```
Trigger: schedule 0 2 * * *
Prompt: Run all tests. If any fail, open a GitHub issue listing the failures 
        with file paths and error messages.
STOP: issue opened or all tests pass
```

**PR review on every open:**
```
Trigger: GitHub PR opened
Prompt: Review the diff against the patterns in CLAUDE.md. Post a PR comment 
        with findings — blocking issues first, suggestions second.
STOP: PR comment posted
```

**Alert-driven investigation:**
```
Trigger: API (from PagerDuty webhook or monitoring alert)
Context: { "text": "OOM error on payment-service pod at 03:12 UTC" }
Prompt: Investigate the error described in the context. Check recent commits, 
        logs, and open a GitHub issue with findings and a reproduction hypothesis.
STOP: issue opened
```

## Constraints to design around

- **No permission prompts during run** — prompts route to your main session asynchronously;
  design the Routine to not need interruption, or accept that it may pause waiting for you
- **Branch policy** — by default Routines push only to `claude/`-prefixed branches;
  configure if you need direct pushes to feature branches
- **Network allowlist** — Anthropic-managed (package registries, cloud APIs, common dev
  domains); custom internal endpoints require a connector (MCP server)
- **Connectors** — MCP tools must be pre-configured in the Routine; local filesystem
  is not available (everything goes through git + connectors)

## Related

- [The Loop Contract](27-loop-contract.md) — define TRIGGER/SCOPE/STOP before creating a Routine
- [Headless & Non-Interactive Mode](09-headless-mode.md) — local headless alternative when cloud is not needed
- [Background Agents](29-background-agents.md) — detached sessions within a single machine session
- [Hooks](12-hooks.md) — `post-session` hook fires after a Routine run completes
