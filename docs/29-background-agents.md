# Background Agents

A background agent is a Claude Code session running detached from your terminal.
It executes autonomously, streams progress to the agent view, and surfaces permission
prompts to your main session rather than blocking.

Background agents are how you run multiple parallel loops on one machine without
opening multiple terminals — and how you keep a long loop running after you close
the IDE.

## Starting a background agent

```bash
# Start and detach immediately (returns session ID)
claude --bg "refactor the auth module to use the new token service"

# With budget and turn caps
claude --bg --max-turns 50 --max-budget-usd 5.00 "run all tests and fix failures"

# In an isolated worktree (prevents file conflicts with your active session)
claude --bg --worktree "add input validation to all API endpoints"

# With a specific model and effort level
claude --bg --model claude-opus-4-8 --effort high "architect the new plugin system"

# With custom permissions (bypass prompts for CI-like tasks)
claude --bg --permission-mode auto "apply all lint fixes across src/"
```

`--bg` prints the session ID and returns immediately. The session continues running.

## Managing background sessions

```bash
claude agents                    # open the agent view (interactive dashboard)
claude agents --json             # list all sessions as JSON (for scripting)

claude attach <session-id>       # attach your terminal to a session
claude logs <session-id>         # print recent output non-interactively
claude stop <session-id>         # stop a running session
claude rm <session-id>           # remove from session list
claude respawn <session-id>      # restart session with conversation intact
```

## Agent view

`claude agents` opens the dashboard for all running and completed sessions:
- Live output streaming per session, side-by-side
- Permission prompts from any background session surface here for your approval
- `! <command>` in the agent view starts a new background session inline

## Worktree isolation

By default, background agents run in an isolated git worktree to prevent concurrent
file edits from colliding with your active session:

```json
// .claude/settings.json
{
  "worktree": {
    "bgIsolation": "none"   // disable: let background agents edit the working copy
  }
}
```

Use `"none"` when the background agent needs to read your in-progress uncommitted
changes. Keep the default (isolated worktree) when running parallel agents.

## Session resumption

Background sessions persist and can be resumed after interruption:

```bash
claude --continue                    # resume the most recent session
claude --resume <session-id>         # resume a specific session
```

After resuming, the session can run interactively or be sent back to background.

## Fan-out pattern

Launch many independent background agents in a shell loop:

```bash
#!/bin/bash
MODULES=(auth payments notifications search)
declare -a SIDS

for mod in "${MODULES[@]}"; do
  # Reliable: use claude agents --json after launch to get session IDs
  claude --bg --permission-mode auto \
    "Review the $mod module for security issues. Write findings to findings-$mod.md"
  echo "Started $mod"
done

# Get all session IDs from the agent view
claude agents --json | jq -r '.[].id'
```

See [Fan-Out](10-fan-out.md) for the full pattern.

## Hooks for background sessions

| Event | When | Loop use |
|---|---|---|
| `SubagentStart` | Agent begins | Log start time, record session ID |
| `SubagentStop` | Agent ends | Validate output; trigger next step |
| `post-session` | After session ends, before workspace deletion | Export logs, snapshot final state |

Use `SubagentStop` with `additionalContext` to chain background agents — when one
finishes, the hook can inspect the output and fire the next step.

## Zero-Polling Signaling (an alternative to the agent view)

`claude agents` and hook-driven chaining both work by the orchestrator *checking*
on background sessions — polling the agent view or waiting on a `SubagentStop` hook.
An alternative removes polling entirely: workers signal completion by **typing into
the orchestrator's own terminal** via a multiplexer (e.g. tmux/cmux), interrupting it
directly rather than being observed. The orchestrator's terminal receives a one-line
`WORKER-DONE <id>: <status>` keystroke as the worker's last action — an instant
wake-up rather than a poll interval — while all specs and audit trails still live in
git-tracked plan folders so a failed dispatch can be re-issued from the same file.
Production numbers from this pattern: 28 dispatch cycles and ~100 reviewed changes
in one overnight run, with a separate adversarial reviewer gate (see
[Verification](04-verification.md)) catching a 43% fabrication rate before
integration. ([walidboulanouar/loop-engineering](https://github.com/walidboulanouar/loop-engineering), Jul 2026.)

## Cloud/Mobile Background Execution

Background execution is not limited to one machine's terminal. Anthropic's Claude
Cowork moved to web and mobile, so an agent task keeps running headlessly in the
cloud while the initiating device is offline — the same "close the laptop, loop keeps
running" property `--bg` gives locally, extended to devices that were never running
a local session in the first place. This sits alongside [Routines](28-routines.md) as
a second cloud-hosted execution path, oriented at ad hoc cowork tasks rather than
scheduled/triggered loops.
([The New Stack, "Anthropic's Claude Cowork now keeps working when you close your laptop"](https://thenewstack.io/claude-cowork-cloud-mobile/), Jul 2026.)

## Related

- [Fan-Out](10-fan-out.md) — parallelism patterns using background agents
- [Long-Running Agents](25-long-running-agents.md) — multi-day execution strategies
- [Hooks](12-hooks.md) — SubagentStop for post-execution validation
- [Headless & Non-Interactive Mode](09-headless-mode.md) — single-session alternative
- [Routines](28-routines.md) — cloud-hosted alternative when machine is not available
