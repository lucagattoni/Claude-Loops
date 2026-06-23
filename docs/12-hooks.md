# Hooks — Deterministic Loop Control

Hooks inject deterministic logic at specific points in the Claude Code lifecycle.
Unlike `CLAUDE.md` instructions (advisory), hooks **always run** — they cannot be
skipped, forgotten, or overridden by the model.

This makes hooks the right tool for loop control: verification gates, circuit
breakers, audit logging, and automatic continuation.

## Five hook types

| Type | What it does | Timeout |
|---|---|---|
| `command` | Runs a shell command; stdout parsed as JSON | 60 s |
| `http` | POSTs JSON to an HTTP endpoint | 30 s |
| `mcp_tool` | Calls an MCP tool | 30 s |
| `prompt` | Sends a prompt to an LLM for yes/no decisions (experimental) | 30 s |
| `agent` | Spawns a subagent for verification (experimental) | 60 s |

## Exit codes (`command` hooks)

| Code | Meaning | Effect |
|---|---|---|
| `0` | Success | Parse stdout as JSON; apply output fields |
| `2` | **Blocking** | PreToolUse: deny tool. Stop/SubagentStop: prevent stopping. UserPromptSubmit: block prompt |
| Other | Non-blocking warning | Show first line of stderr; continue |

Exit code `2` is the **loop control signal**: returning `2` from a `Stop` hook
tells Claude "you are not done — re-enter the loop."

After 8 consecutive blocks from a Stop hook, Claude Code overrides and ends the
turn to prevent infinite loops.

## Key lifecycle events

| Event | Fires when | Can block (exit 2)? |
|---|---|---|
| `SessionStart` | Session begins | No |
| `Setup` | Before first user turn | No |
| `UserPromptSubmit` | User sends a message — can inject context or block | Yes |
| `PreToolUse` | Before any tool call — can modify input or deny | Yes |
| `PermissionRequest` | Instead of interactive permission dialog | Yes |
| `PostToolUse` | After tool completes — can rewrite what Claude sees | No |
| `PostToolBatch` | After all parallel tool calls, before next model turn | Yes |
| `SubagentStart` | Subagent session begins | No |
| `SubagentStop` | Subagent ends — can validate output and continue | Yes |
| `Stop` | Claude is about to stop — can inject more work | Yes |
| `StopFailure` | Claude stopped due to error (rate limit, billing, etc.) | No |
| `PreCompact` | Before context compaction | No |
| `PostCompact` | After context compaction | No |
| `post-session` | After session ends, before workspace deletion | No |

## JSON output API

Every hook can return a JSON object on stdout to influence what happens next:

```json
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "Context added to Claude's system prompt for this session",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",

    "permissionDecision": "allow",   // PreToolUse/PermissionRequest: allow|deny|ask|defer
    "updatedInput": {},              // PreToolUse: replace the tool's input before execution

    "updatedToolOutput": "...",      // PostToolUse: replace what Claude sees as output

    "additionalContext": "..."       // Stop/SubagentStop: inject context and keep the loop going
  }
}
```

Key fields for loop engineering:

- **`additionalContext`** — inject a message and *continue the loop* (Stop/SubagentStop:
  prevents stopping, Claude reads the context and acts on it next turn)
- **`updatedInput`** — rewrite a tool's input before execution (PreToolUse)
- **`updatedToolOutput`** — rewrite what Claude sees after a tool runs (PostToolUse)
- **`continue: false`** — halt the entire session immediately
- **`suppressOutput`** — hide the hook result from the transcript (clean logs)

## Async hooks and the circuit breaker pattern

By default, hooks run synchronously and Claude waits. Two async modes:

```json
{
  "event": "PostToolUse",
  "matcher": "Bash",
  "type": "command",
  "command": "audit-log.sh",
  "async": true             // run in background; Claude does not wait
}
```

```json
{
  "event": "Stop",
  "type": "command",
  "command": "verify-output.sh",
  "async": true,
  "asyncRewake": true       // if script exits 2, Claude is woken back up
}
```

**`asyncRewake`** is the circuit breaker pattern: verification runs in the background
after Claude stops. If the check fails (exit code 2), Claude is automatically re-woken
with the verification output as context — without blocking the main loop while
verification runs.

```bash
#!/bin/bash
# verify-output.sh
npm test > /tmp/test-results.txt 2>&1
if [ $? -ne 0 ]; then
  RESULTS=$(cat /tmp/test-results.txt)
  # Use jq to safely escape the test output into JSON
  jq -n --arg ctx "Tests failed:\n$RESULTS" \
    '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":$ctx}}'
  exit 2   # re-wake Claude with failure context
fi
```

## Conditional hooks (`if` field)

Run a hook only when the tool input matches a pattern:

```json
{
  "event": "PreToolUse",
  "matcher": "Bash",
  "if": "Bash(rm *)",
  "type": "command",
  "command": "confirm-delete.sh"
}
```

Uses the same pattern syntax as `permissions.allow`/`permissions.deny`.
Avoids running expensive hooks on every tool call.

## Environment variables in hooks

| Variable | Value |
|---|---|
| `CLAUDE_PROJECT_DIR` | Absolute path to project root |
| `CLAUDE_CODE_SESSION_ID` | Current session ID |
| `CLAUDE_EFFORT` | Current effort level (`low`/`medium`/`high`/`xhigh`/`max`) |
| `CLAUDE_CODE_REMOTE` | `"1"` if running in a Routine (cloud session) |
| `CLAUDE_ENV_FILE` | Write `KEY=VALUE` here to persist env vars across Bash tool calls |

`CLAUDE_ENV_FILE` is useful for hooks that inject credentials or state for subsequent
Bash tool calls in the same session.

## Configuration example

```json
// .claude/settings.json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "scripts/verify.sh",
        "async": true,
        "asyncRewake": true
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "if": "Bash(rm -rf *)",
        "type": "command",
        "command": "scripts/confirm-destruct.sh"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "type": "command",
        "command": "scripts/auto-lint.sh",   // receives tool input as JSON on stdin
        "async": true
      }
    ]
  }
}
```

## Scope hierarchy

Hooks from multiple sources are merged in order (later overrides earlier):
1. Managed policy
2. `~/.claude/settings.json` (user-wide)
3. `.claude/settings.json` (project)
4. `.claude/settings.local.json` (local, gitignored)
5. Plugin `hooks.json`
6. Skill or agent frontmatter (skill-scoped hooks)

## Loop engineering patterns

**Verify-before-stop** (asyncRewake circuit breaker):
```json
{ "event": "Stop", "type": "command", "command": "run-tests.sh",
  "async": true, "asyncRewake": true }
```
The loop stops only when tests pass. Failures automatically re-enter the loop
with the test output as context.

**Block destructive commands in unattended runs:**
```json
{ "event": "PreToolUse", "matcher": "Bash", "if": "Bash(rm -rf *)",
  "type": "command",
  "command": "echo '{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\"}}'" }
```

**Audit log every tool call (fire-and-forget):**
```json
{ "event": "PostToolUse", "type": "http", "async": true,
  "url": "https://audit.example.com/events",
  "headers": { "Authorization": "Bearer ${AUDIT_TOKEN}" },
  "allowedEnvVars": ["AUDIT_TOKEN"] }
```

**Chain background agents via SubagentStop:**
```json
{ "event": "SubagentStop", "type": "command", "command": "scripts/trigger-next.sh" }
```
When a background agent finishes, inspect its output and fire the next step.

## Related

- [Verification](04-verification.md) — the broader verification philosophy
- [Human-in-the-Loop Escalation](14-human-in-the-loop.md) — when hooks should escalate vs. loop
- [Background Agents](29-background-agents.md) — SubagentStart/SubagentStop patterns
- [Failure Patterns](17-failure-patterns.md) — missing circuit breaker anti-pattern
