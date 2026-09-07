# Hooks — Deterministic Loop Control

Hooks inject deterministic logic at specific points in the Claude Code lifecycle.
Unlike `CLAUDE.md` instructions (advisory), hooks **always run** — they cannot be
skipped, forgotten, or overridden by the model.

This makes hooks the right tool for loop control: verification gates, circuit
breakers, audit logging, and automatic continuation.

## Five hook types

| Type | What it does | Timeout |
|---|---|---|
| `command` | Runs a shell command; stdout parsed as JSON | 600 s (10 min) |
| `http` | POSTs JSON to an HTTP endpoint | 600 s (10 min) |
| `mcp_tool` | Calls an MCP tool | 600 s (10 min) |
| `prompt` | Sends a prompt to an LLM for yes/no decisions (experimental) | 30 s |
| `agent` | Spawns a subagent for verification (experimental) | 60 s |

Raised from 60 s to 10 minutes in **v2.1.3**. Claude Code lowers the `command`/`http`/`mcp_tool`
default back to 30 s specifically on `UserPromptSubmit`, `PreModelSwitch`, and `PostModelSwitch`
(and to 10 s on `MessageDisplay`), because those events block the model turn while they run — see
the [Hooks reference](https://code.claude.com/docs/en/hooks#timeouts).

## Exit codes (`command` hooks)

| Code | Meaning | Effect |
|---|---|---|
| `0` | Success | Parse stdout as JSON; apply output fields |
| `2` | **Blocking** | PreToolUse: deny tool. Stop/SubagentStop: prevent stopping. UserPromptSubmit: block prompt |
| Other (incl. `1`) | Non-blocking warning | Show first line of stderr; **continue** |

Exit code `2` is the **loop control signal**: returning `2` from a `Stop` hook
tells Claude "you are not done — re-enter the loop."

After 8 consecutive blocks from a Stop hook, Claude Code overrides and ends the
turn to prevent infinite loops.

### Safety contract: never exit 1 in a denial hook

Exit code `1` (or any non-2 non-zero exit) is treated as a **non-blocking warning**
— Claude logs the error and **continues**. A hook that intends to deny but crashes
with exit code `1` silently allows the action instead of blocking it.

**Rule:** All deny logic must be wrapped so that any exception exits `2`, not `1`.
Test every denial path explicitly.

```bash
#!/bin/bash
# deny-hook.sh — safe pattern
deny_reason() {
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny"}}'
  exit 2
}

# Wrap all logic — any unhandled error exits 2 (deny), not 1 (allow)
set -e
trap 'deny_reason' ERR

# ... your check logic ...
if [[ "$SOME_CONDITION" == "true" ]]; then
  deny_reason
fi
exit 0  # allow
```

(session-orchestrator — [Kanevry/session-orchestrator](https://github.com/Kanevry/session-orchestrator), Jun 2026.)

## Key lifecycle events

| Event | Fires when | Can block (exit 2)? |
|---|---|---|
| `SessionStart` | Session begins | No |
| `Setup` | Fires only on `claude --init-only`, or `claude -p --init`/`claude -p --maintenance` (v2.1.10+) — never on normal startup | No |
| `UserPromptSubmit` | User sends a message — can inject context or block | Yes |
| `PreToolUse` | Before any tool call — can modify input or deny | Yes |
| `PermissionRequest` | Instead of interactive permission dialog | **No**¹ |
| `PostToolUse` | After tool completes — can rewrite what Claude sees | No |
| `PostToolBatch` | After all parallel tool calls, before next model turn | Yes |
| `SubagentStart` | Subagent session begins | No |
| `SubagentStop` | Subagent ends — can validate output and continue | Yes |
| `Stop` | Claude is about to stop — can inject more work | Yes |
| `StopFailure` | Claude stopped due to error (rate limit, billing, etc.) | No |
| `PreCompact` | Before context compaction — can block by exiting 2 or returning `{"decision":"block"}` (v2.1.105) | Yes |
| `PostCompact` | After context compaction | No |
| `PreModelSwitch` | Before a model switch — block, confirm, or annotate it (v2.1.251+) | Yes |
| `PostModelSwitch` | After a model switch completes — annotate the outcome (v2.1.251+) | No* |
| `SessionEnd` | Session terminates | No |

¹ `PermissionRequest` is the trap in this column: it *is* a decision hook, but **exit code 2 is
not honored for it** — *"the permission flow proceeds unchanged. Deny through the decision object
instead"* ([Hooks reference — Exit code 2 behavior per
event](https://code.claude.com/docs/en/hooks), fetched 2026-09-07). A guard written as `exit 2`
here fails open and looks like it is working.

\* The switch has already happened by the time `PostModelSwitch` fires, so blocking applies to
`PreModelSwitch`; the changelog states both events together as "block, confirm, or annotate a
model switch." (Claude Code v2.1.251, [release
notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.251).)

**`SessionStart` resume hooks got richer in v2.1.251 too:** they now receive session staleness
and the estimated re-cache cost, verbatim: "`SessionStart` resume hooks now receive session
staleness and the estimated re-cache cost." A resume hook can use this to warn (or refuse to
resume) a session that has gone stale enough that resuming it would trigger an expensive
uncached re-processing of the whole history — see [Cost & Turn
Control](11-cost-control.md#the-cache-cost-of-switching-model-or-effort-mid-session) for why
that re-cache cost matters.

## JSON output API

Every hook can return a JSON object on stdout to influence what happens next:

```json
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "Context added to Claude's system prompt for this session",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",

    "permissionDecision": "allow",   // PreToolUse only: allow|deny|ask|defer
    "updatedInput": {},              // PreToolUse: replace the tool's input before execution

    "updatedToolOutput": "...",      // PostToolUse: replace what Claude sees as output

    "additionalContext": "..."       // injects context at the point the hook fired (see below)
  }
}
```

`PermissionRequest` does **not** use `permissionDecision` — it returns a `decision` object with
`behavior: "allow"|"deny"` instead. See [Permissions & Auto Mode → PermissionRequest
hook](08-permissions.md#permissionrequest-hook) for that event's own schema.

Key fields for loop engineering:

- **`additionalContext`** — inject a message into Claude's context at the point the hook fired.
  Originally Stop/SubagentStop-only; extended to `PreToolUse` in **v2.1.9**. As of the current
  [Hooks reference](https://code.claude.com/docs/en/hooks#add-context-for-claude) (fetched
  2026-09-07) it also works on `SessionStart`, `SubagentStart`, `UserPromptSubmit`,
  `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, and
  `PostModelSwitch`. Only on `Stop`/`SubagentStop` does it *continue the loop* by preventing the
  stop; elsewhere it just adds context to the next model turn without blocking anything.
- **`updatedInput`** — rewrite a tool's input before execution (PreToolUse)
- **`updatedToolOutput`** — rewrite what Claude sees after a tool runs (PostToolUse)
- **`continue: false`** — halt the entire session immediately. For `TeammateIdle`, and for
  `TaskCompleted` when a teammate finishing its turn triggered the event, it instead stops *that
  teammate* — the lead and other teammates in the [agent team](38-agent-teams.md) keep running
  (fixed to match `Stop` hook semantics in **v2.1.69**). `TaskCompleted` ignores `continue: false`
  when the `TaskUpdate` tool itself triggered the event — only exit code 2 blocks that completion.
- **`suppressOutput`** — hide the hook result from the transcript (clean logs)

**Hooks cannot loosen a static `deny` or `ask` rule.** Three fixes establish this as current
behavior:

- **v2.1.77**: "Fixed `PreToolUse` hooks returning `"allow"` bypassing `deny` permission rules,
  including enterprise managed settings."
- **v2.1.101**: "Fixed `permissions.deny` rules not overriding a `PreToolUse` hook's
  `permissionDecision: "ask"` — previously the hook could downgrade a deny into a prompt."
- **v2.1.110 / v2.1.211**: closed the same gap for `PermissionRequest`'s `updatedInput` and for
  auto mode overriding a hook's `ask` decision on unsandboxed Bash.

Net effect: a `PreToolUse`/`PermissionRequest` hook can make an action *stricter* than the static
rules (turn an allow into an ask, or deny outright) but cannot make it *looser* — not by returning
a laxer `permissionDecision`, and not by rewriting the tool input. Design permission hooks as a
restriction layered on top of `permissions.deny`/`ask`, never as a way to route around them.

*Source: [Permissions reference](https://code.claude.com/docs/en/permissions), verbatim: "Hook
decisions don't bypass permission rules." ([v2.1.77](https://github.com/anthropics/claude-code/releases/tag/v2.1.77),
[v2.1.101](https://github.com/anthropics/claude-code/releases/tag/v2.1.101),
[v2.1.110](https://github.com/anthropics/claude-code/releases/tag/v2.1.110),
[v2.1.211](https://github.com/anthropics/claude-code/releases/tag/v2.1.211) release notes.)*

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
| `CLAUDE_CODE_SESSION_ID` | Current session ID. Matches the `session_id` field in the hook JSON input, and is updated on `/clear` |
| `CLAUDE_EFFORT` | Current effort level (`low`/`medium`/`high`/`xhigh`/`max`) |
| `CLAUDE_CODE_REMOTE` | `true` in a cloud session (Routines run as cloud sessions) |
| `CLAUDE_CODE_REMOTE_SESSION_ID` | The cloud session's own ID — use it to build a link back to the session transcript |
| `CLAUDE_ENV_FILE` | Write `KEY=VALUE` here to persist env vars across Bash tool calls |

`CLAUDE_ENV_FILE` is useful for hooks that inject credentials or state for subsequent
Bash tool calls in the same session.

!!! warning "Two traps in the table above"
    **`CLAUDE_CODE_REMOTE` is `true`, not `"1"`.** A hook guarding on
    `[ "$CLAUDE_CODE_REMOTE" = "1" ]` never fires — the reference says it is *"Set automatically
    to `true` when Claude Code is running as a cloud session."*

    **`CLAUDE_CODE_SESSION_ID` is not a stable loop key across resumes.** It is reliable on a
    fresh session and on `--resume <session-id>`, but on `--continue`, or `--resume` without an
    explicit ID, *"it may receive the initial startup ID instead."* A loop that keys its state
    directory on this variable can silently write two runs into one bucket. An MCP server
    subprocess keeps the ID it was spawned with.

    *Source: [environment variables reference](https://code.claude.com/docs/en/env-vars),
    verified against `claude` **2.1.261**, 2026-09-05.*

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

Hook **entries merge** across sources rather than one replacing another — user, project, local,
and plugin hooks all add to the set that runs; a hook from one source doesn't remove or replace a
hook from another. (Settings *values* follow a different rule — highest level wins; see
[Permissions & Auto Mode → Settings precedence](08-permissions.md#settings-precedence).)
`disableAllHooks` and `allowManagedHooksOnly` are the exception: for these, managed policy is a
floor nothing below it can lower. Ordinary precedence still applies among the non-managed scopes —
Claude Code reads the value left after settings precedence applies, so a project's
`"disableAllHooks": false` overrides a user setting of `true`, and `claude --settings
'{"disableAllHooks": true}'` overrides both for one run — but **only `disableAllHooks` set at the
managed-settings level can disable hooks an administrator configured through managed policy**.
Fixed in **v2.1.49**, verbatim: "Fixed `disableAllHooks` setting to respect managed settings
hierarchy — non-managed settings can no longer disable managed hooks set by policy (#26637)."

*Source: [Hooks reference — Disable or remove hooks](https://code.claude.com/docs/en/hooks#disable-or-remove-hooks),
verified against `claude` **2.1.263**, 2026-09-07.*

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

**Gate a model switch (v2.1.251+):** before `PreModelSwitch`/`PostModelSwitch` existed, a model
switch mid-session (whether Claude's own choice or a user's `/model` call) was unobservable and
ungatable by a hook — the loop had no deterministic control point to stop, log, or confirm it.
`PreModelSwitch` makes an accidental downgrade to a cheaper/weaker model mid-task a blockable
event rather than a silent one, and `PostModelSwitch` gives an audit trail of every switch a
loop actually made — the same "always runs, cannot be skipped" property this doc opens with,
now applied to model choice instead of only tool calls.

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
