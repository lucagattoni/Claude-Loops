# Headless & Non-Interactive Mode

`claude -p "prompt"` runs Claude without a session — no terminal UI, no interactive
prompts. This is the entry point for all loop automation: scripts, CI pipelines,
and scheduled jobs.

## Core flags

```bash
claude -p "task"                                     # non-interactive, output to stdout
claude -p "task" --output-format json                # structured JSON output
claude -p "task" --output-format stream-json         # streaming JSON for real-time processing
claude -p "task" --no-stream                         # wait for full response (verify flag name)
claude -p "task" --max-turns 30                      # hard turn cap
claude -p "task" --max-budget-usd 2.00               # hard cost cap
claude -p "task" --permission-mode auto              # skip permission prompts (unattended)
claude -p "task" --allowedTools "Edit,Bash(git *)"  # scope tools per invocation
```

## Session continuation

Resume a previous session rather than starting fresh — preserves context, file state,
and in-progress work across interrupted runs:

```bash
claude --continue                                  # resume most recent session
claude --resume <session-id>                       # resume a specific session
claude --continue -p "continue fixing the remaining type errors"
```

Use `--continue` in long-running loops to pick up after a crash, budget cap, or
rate limit without losing accumulated context.

## Prompt and model overrides

```bash
# Replace the system prompt entirely
claude -p "task" --system-prompt "You are a security auditor."

# Append to the default system prompt (verify flag name)
claude -p "task" --append-system-prompt "Always return structured JSON."

# Override model
claude -p "task" --model claude-opus-4-8

# Override effort level
claude -p "task" --effort high

# Fallback if primary model is unavailable (loop resilience)
claude -p "task" --fallback-model claude-sonnet-4-6,claude-haiku-4-5
```

## Background sessions

`claude --bg "task"` starts a session detached from the terminal — the session
continues running after your shell exits. Manage with `claude agents`, `claude attach`,
`claude logs`. See [Background Agents](29-background-agents.md) for the full pattern.

## Prompt cache optimisation for CI

In CI or multi-machine setups, the system prompt varies per machine (working directory,
hostname, git config), invalidating the prompt cache on every run:

```bash
claude -p "task" --exclude-dynamic-system-prompt-sections  # verify flag name
```

Moves machine-specific sections to the first user message — the system prompt stays
identical across machines, cache hits occur, and cost per run drops significantly.

## CI-specific flags

```bash
# Don't persist session to disk (ephemeral CI runs)
claude -p "task" --no-session-persistence

# Disable ALL customizations (troubleshoot hook/skill/plugin conflicts)
claude -p "task" --safe-mode

# Skip all setup: hooks, skills, MCP, CLAUDE.md, auto-memory (fastest start; verify flag name)
claude -p "task" --bare
```

`--bare` is the fastest possible headless start — use it for self-contained tasks
that do not need any project configuration.

## Structured output

For loops that hand off results to downstream processes:

```bash
# JSON output
claude -p "List all API endpoints missing auth middleware." \
  --output-format json \
  --append-system-prompt 'Return JSON: [{"file":"...","line":N,"endpoint":"..."}]'

# Stream-JSON for real-time step monitoring
claude -p "Refactor src/auth" --output-format stream-json --verbose \
  | jq 'select(.type=="tool_use") | .name'
```

## Fault-tolerant headless loop

```bash
#!/bin/bash
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $attempt..."
  claude -p "Fix all TypeScript errors in src/" \
    --max-turns 50 \
    --max-budget-usd 3.00 \
    --permission-mode auto \
    --exclude-dynamic-system-prompt-sections \
    --no-session-persistence \
    && { echo "Done."; exit 0; }
  echo "Attempt $attempt failed — retrying in 15s..."
  sleep 15
done
echo "All attempts failed."
exit 1
```

## Related

- [Background Agents](29-background-agents.md) — detached, persistent sessions
- [Routines](28-routines.md) — cloud-native alternative (no local machine needed)
- [Cost & Turn Control](11-cost-control.md) — `--max-turns`, `--max-budget-usd`
- [Permissions & Auto Mode](08-permissions.md) — `--permission-mode auto` details
