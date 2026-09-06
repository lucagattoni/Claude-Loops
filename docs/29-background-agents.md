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

# With a turn cap. NOTE: --max-budget-usd does NOT apply to --bg — see "What --bg does not get"
claude --bg --max-turns 50 "run all tests and fix failures"

# In an isolated worktree (prevents file conflicts with your active session).
# Name the worktree explicitly — `--worktree [name]` takes an optional value and will
# otherwise consume the prompt as the worktree name and fail.
claude --bg --worktree api-validation "add input validation to all API endpoints"

# With a specific model and effort level
claude --bg --model claude-opus-5 --effort high "architect the new plugin system"

# With custom permissions (bypass prompts for CI-like tasks)
claude --bg --permission-mode auto "apply all lint fixes across src/"
```

`--bg` prints the session ID and returns immediately. The session continues running.

## What `--bg` does not get

`--bg` and `-p`/`--print` are **mutually exclusive**, and since v2.1.198 the CLI rejects the
combination up front instead of guessing:

```text
$ claude --bg -p "run the tests"
--bg and --print conflict: --print never starts the interactive session that `claude agents`
attaches to, so the job would be unattachable. The prompt is the positional — drop --print:
`claude --bg '<task>'`.
```

Before v2.1.198 the same command was accepted and silently created a session nothing could attach
to. That fix matters more than it looks, because **every documented way to bound a background
session's work is scoped to `--print`, and therefore unreachable from `--bg`**:

| Flag | `claude --help` says | Consequence for `--bg` |
|---|---|---|
| `--max-budget-usd <amount>` | "Maximum dollar amount to spend on API calls **(only works with --print)**" | A background session has **no dollar ceiling**. The flag is accepted without warning and does nothing |
| `--permission-prompts <target>` | "Who answers permission prompts **with --print**: `host` … or `none`" | The fail-closed `--permission-prompts none` this KB recommends for unattended loops is **not available**. Prompts surface in the agent view and wait for a human |

Verified on 2.1.261: `claude --bg --max-budget-usd 5.00 "<task>"` starts normally and reports no
conflict. The cap is accepted and silently inert — the same defect shape this KB keeps returning to,
where **a control that cannot take effect must fail loudly, not pass quietly**
(see [Failure Patterns](17-failure-patterns.md)).

!!! danger "`--max-turns` is inert on `--bg` as well — measured, not inferred"
    An earlier version of this page listed `--max-turns` as a working ceiling for `--bg`. It is
    not. Paired test on 2.1.261, identical multi-step prompt (three sequential shell commands),
    identical model:

    ```text
    $ claude -p  --max-turns 1 "<task>"   →  Error: Reached max turns (1)
    $ claude --bg --max-turns 1 "<task>"  →  ran all three commands, printed a summary, "done"
    ```

    The flag is accepted and does nothing, and `claude --help` no longer lists it at all. The
    original claim here was written from help text and the CLI reference instead of from running
    the thing — the exact failure this KB names elsewhere: **reading finds the fact, executing
    finds the consequence.**

So a `--bg` session has **no in-band ceiling at all**. What remains:

- an explicit `--model` and `--effort` — the only levers that bound spend *before* the fact, and
  the cost floor below scales with the model rather than the task
- `claude stop <id>` — out-of-band, and it only helps if something is watching

Budget a background fan-out by **model and fleet size**, and supervise it. Neither
`--max-budget-usd` nor `--max-turns` will stop it.

## The per-session cost floor

A fresh session pays a fixed cost before doing any work: its system prompt and tool definitions are
written into the prompt cache. Measured by the ClaudeWarp project on a session that lived **64
seconds** and produced 2 input / 4 output tokens with **zero** thinking tokens
([v0.42.1](https://github.com/lucagattoni/Claude-Warp/releases/tag/v0.42.1)):

| Recorded `cost-state` | Value |
|---|---|
| `totalCostUSD` | $0.242504 |
| of which Opus 5 | $0.240609 |
| Cache write | 22,659 tokens, 1-hour TTL |
| Thinking tokens | 0 |

At Opus 5 list price (1-hour cache write, $10/MTok — see [Cost Control](11-cost-control.md)), that
write alone is **$0.2266, or 93% of the session's whole cost**. Effort did not drive it; the session
writing its own scaffolding into a 1-hour cache did, at Opus's 2× rate, for 64 seconds of life.

> **The generalisable claim:** a fresh session pays *(system prompt + tool definitions) × the model's
> cache-write rate* before any work happens. A fan-out's budget is therefore
> **(items × floor) + actual work**, and the floor scales with the **model's price, not the task's
> difficulty**. The operator move is *pin a cheaper model*, not *lower the effort* — the identical
> 22,659-token write costs $0.09 on Sonnet 5 and $0.05 on Haiku 4.5.

Combined with the missing `--max-budget-usd` above, that is the whole cost story for a `--bg`
fan-out: you cannot cap it in dollars, and every worker costs something before it starts. Size the
fleet and pin the model.

!!! note "What is and is not verified here"
    The recorded figures are ClaudeWarp's first-hand `cost-state`; we have not reproduced the
    measurement. The arithmetic above is ours. **$0.0139 of the recorded $0.240609 — 5.8% — is not
    explained by the three published token counts**, so the floor is a lower bound on that session,
    not an exact reconciliation. The 94% conclusion and the cross-model comparison do not depend on
    the residual.

## The silent-idle trap: variadic flags eat the prompt

The prompt is a **positional** argument — `claude [options] [command] [prompt]` — and seven flags
take variadic lists. A variadic flag consumes every following non-flag token, **including your
prompt**. On 2.1.261 they are:

`--add-dir <directories...>` · `--allowedTools` / `--allowed-tools <tools...>` ·
`--betas <betas...>` · `--disallowedTools` / `--disallowed-tools <tools...>` ·
`--file <specs...>` · `--mcp-config <configs...>` · `--tools <tools...>`

```bash
# BROKEN — "fix the flaky test" is parsed as a third tool name, not the prompt
claude --bg --allowedTools Bash Edit "fix the flaky test"

# CORRECT — prompt first, or put the variadic flag last
claude --bg "fix the flaky test" --allowedTools Bash Edit
```

With a flag whose values are validated, the swallow is visible:

```text
$ claude -p --mcp-config /nonexistent-abc.json "reply with OK"
Error: Invalid MCP configuration:
MCP config file not found: /nonexistent-abc.json
MCP config file not found: /Users/…/reply with OK
```

**On `--bg` the same mistake is silent.** The launcher prints a session id and exits 0:

```text
$ claude --bg --allowedTools Bash Edit "fix the flaky test"
backgrounded · 5a92d93a (idle — send a prompt to start)
```

A live background session with no prompt, which sits idle indefinitely — reproduced on **2.1.263**,
still `"state": "blocked"` with a live `pid` twenty seconds later. `claude agents` lists it, the
exit status is 0, and no work happens.

Pick the demonstrating flag with care: the same mistake made with `--mcp-config` does **not** idle.
That session dies within ~10s because the swallowed prompt is then parsed as a second, invalid
config path — visibly failing rather than silently idling. The variadic flags that leave a session
genuinely stuck are the ones whose values are never validated. **A fan-out that builds its command line flags-first can
start fifty of these and report complete success.** Assert on the artifact each worker was supposed
to produce — never on the launch succeeding.

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

### Reading `claude agents --json`

`--json` prints active sessions — interactive **and** background — as a JSON array and exits; it
does not need a TTY. `--all` additionally includes completed background sessions, and
`--cwd <path>` narrows to background sessions started under that path.

**The object shape depends on the session's kind and liveness.** Observed on 2.1.263:

| Field | Present on | Notes |
|---|---|---|
| `id` | **background sessions only** | The 8-hex short id that `attach` / `logs` / `stop` / `rm` take |
| `sessionId` | all | Full UUID — what `--resume` takes |
| `pid` | running sessions only | Absent once a session has exited |
| `kind` | all | `background` or `interactive` |
| `cwd`, `startedAt`, `name` | all | `startedAt` is epoch milliseconds |
| `status` | running sessions | e.g. `busy` |
| `state` | background sessions | observed: `working`, `done`, `failed`, `blocked` — `blocked` means waiting on input, including a session whose prompt was swallowed at launch |

Two scripting consequences, both easy to get wrong:

```bash
# WRONG — interactive sessions carry no `id`, so this emits nulls; and it returns
# every session on the machine, not the ones your loop started.
claude agents --json | jq -r '.[].id'

# RIGHT — let the CLI filter, then read the ids.
claude agents --json --cwd "$PWD" | jq -r '.[].id'
claude agents --json | jq -r '.[] | select(.kind=="background") | .id'
```

Most reliable of all: `claude --bg` prints the short id at launch. Capture it there rather than
reconstructing the set afterwards from a machine-wide listing.

## Agent view

`claude agents` opens the dashboard for all running and completed sessions:
- One status line per session row — drawn from the session's own recent output and refreshed at most every 15 s, rewritten by a Haiku-class model at the end of each turn (and every few minutes during a long one). Press `Space` to peek at the full sentence, or `Enter`/`→` to attach and see one session's live transcript, which replaces the table
- Permission prompts from any background session surface here for your approval
- `! <command>` in the agent view runs a shell command as a background *job* — no Claude session, no model call — appearing as its own row you can attach to, watch and detach from; the row cleans up about five minutes after the command exits

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
claude --resume                      # picker of past sessions; background ones are marked "bg"
claude --resume <session-id-or-name>  # resume by session ID, or by a name set with --name/-n
claude attach <id>                   # attach to a background session still listed in `claude agents`
# `claude --continue` does NOT work here — it loads the most recent conversation in the
# current directory but explicitly skips background sessions (and -p / SDK / /loop ones).
```

After resuming, the session can run interactively or be sent back to background.

## Fan-out pattern

Launch many independent background agents in a shell loop:

```bash
#!/bin/bash
MODULES=(auth payments notifications search)
declare -a SIDS

for mod in "${MODULES[@]}"; do
  # Capture the id `claude --bg` prints at launch — more reliable than reconstructing
  # the set afterwards from a machine-wide listing.
  out=$(claude --bg --permission-mode auto \
    "Review the $mod module for security issues. Write findings to findings-$mod.md")
  sid=$(echo "$out" | grep -oE '[0-9a-f]{8}' | head -1)
  SIDS+=("$sid")
  echo "Started $mod ($sid)"
done

# Get the session IDs this loop started — filter by cwd, not the whole machine
claude agents --json --cwd "$PWD" | jq -r '.[].id'
```

See [Fan-Out](10-fan-out.md) for the full pattern.

## Hooks for background sessions

| Event | When | Loop use |
|---|---|---|
| `SubagentStart` / `SubagentStop` | A subagent (Agent-tool call) is spawned or finishes *inside* a session — never when a `--bg` session itself starts or stops | Chain steps within one session's own subagent calls |
| `Notification` (matcher `agent_completed` / `agent_needs_input`) | A background session finishes, fails, or starts waiting on input — fires only while agent view is open in a terminal | React to a background session's own completion |
| `WorktreeRemove` | The session's worktree is being removed — at session exit, when a subagent finishes, or when you delete a background session with `claude rm` | Snapshot final state before the worktree is gone |

Use `Notification` with the `agent_completed` matcher, not `SubagentStop`, to chain
background agents — when one finishes, the hook fires and can inspect the output before
starting the next step.

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

## Restart Resumability (OpenClaw, for comparison)

A different vendor's background-agent harness shows what resumability looks like when
built in rather than left to the loop's own state file: OpenClaw v2026.9.2 lets an
eligible **Full Access** task interrupted by a gateway restart inspect its own saved
conversation and continue with fresh, currently-authorized shell commands or delegated
work — without the user re-sending the original request. This is the harness restoring
the session itself, as distinct from this doc's `PROGRESS.md`-style pattern where the
*agent* externalises state for its own next invocation to read; OpenClaw's version
ships in the same release as a separate long-conversation performance improvement (bounded
transcript pages, shortened tool-output previews for large histories) — a distinct feature, not
part of the restart-recovery path.
([OpenClaw v2026.9.2 release notes](https://docs.openclaw.ai/releases/2026.9.2), Sep 2026.)
Separately, [Peter Steinberger](https://x.com/steipete) — OpenClaw's developer — describes
working toward second-scale cloud-session starts via repo snapshotting, to replace the
latency of a fresh clone on every detached session start.
([@steipete](https://x.com/steipete/status/2096400749869830325), Sep 2026.)

## Related

- [Fan-Out](10-fan-out.md) — parallelism patterns using background agents
- [Long-Running Agents](25-long-running-agents.md) — multi-day execution strategies
- [Hooks](12-hooks.md) — SubagentStop for post-execution validation
- [Headless & Non-Interactive Mode](09-headless-mode.md) — single-session alternative
- [Routines](28-routines.md) — cloud-hosted alternative when machine is not available
