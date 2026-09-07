# Headless & Non-Interactive Mode

`claude -p "prompt"` runs Claude without a session — no terminal UI, no interactive
prompts. This is the entry point for all loop automation: scripts, CI pipelines,
and scheduled jobs.

## Core flags

```bash
claude -p "task"                                     # non-interactive, output to stdout
claude -p "task" --output-format json                # structured JSON output
claude -p "task" --output-format stream-json         # streaming JSON for real-time processing
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
# Replace the system prompt entirely (--system-prompt-file <path> for the file form)
claude -p "task" --system-prompt "You are a security auditor."

# Append to the default system prompt
#   also: --append-system-prompt-file <path>
#   also: --append-subagent-system-prompt (every subagent; -p only; v2.1.205+)
claude -p "task" --append-system-prompt "Always return structured JSON."

# Override model
claude -p "task" --model claude-opus-5

# Override effort level
claude -p "task" --effort high

# Fallback if primary model is unavailable (loop resilience)
claude -p "task" --fallback-model claude-sonnet-5,claude-haiku-4-5
```

## Background sessions

`claude --bg "task"` starts a session detached from the terminal — the session
continues running after your shell exits. Manage with `claude agents`, `claude attach`,
`claude logs`. See [Background Agents](29-background-agents.md) for the full pattern.

## Bash commands that hang no longer kill the turn (v2.0.19+)

> "Auto-background long-running bash commands instead of killing them. Customize with
> BASH_DEFAULT_TIMEOUT_MS"
> — [CHANGELOG.md](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md), v2.0.19

Before v2.0.19, a Bash command that ran past its timeout was killed and reported as a failure.
Now it is auto-backgrounded instead: the tool call returns, Claude is told the command is still
running, and the turn continues. This is a different mechanism from `claude --bg` above — that
backgrounds a whole *session*; this backgrounds one long-running Bash *command* inside an
otherwise normal session.

For an unattended loop, this changes what "the command didn't finish" looks like — and headless
mode changes it again. Before v2.0.19, a hung command printed a timeout failure your retry
wrapper's `ERROR_REGEX` (see [Fault-tolerant headless loop](#fault-tolerant-headless-loop)) could
catch. Now it's moved to the background instead, and in a `claude -p` run [that backgrounded shell
is terminated about five seconds after Claude returns its final result and stdin
closes](https://code.claude.com/docs/en/headless#background-tasks-at-exit) — a grace period for
output that arrives right after, not a wait for the command to finish. So a long build or deploy
step that overruns the timeout inside a headless loop's task can be silently killed mid-run: the
`-p` process still exits with whatever code the turn produced (typically `0`), nothing matches
`ERROR_REGEX`, and the command's work is simply gone.

- `BASH_DEFAULT_TIMEOUT_MS` — how long a command runs before being backgrounded (2 minutes by default)
- `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` (v2.1.4+) — set to disable auto-backgrounding
  entirely, if a loop needs a hang to fail loudly instead

## Prompt cache optimisation for CI

In CI or multi-machine setups, the system prompt varies per machine (working directory,
hostname, git config), invalidating the prompt cache on every run:

```bash
claude -p "task" --exclude-dynamic-system-prompt-sections
```

Moves machine-specific sections to the first user message — the system prompt stays
identical across machines, cache hits occur, and cost per run drops significantly.

## CI-specific flags

```bash
# Don't persist session to disk (ephemeral CI runs)
claude -p "task" --no-session-persistence

# Disable ALL customizations (troubleshoot hook/skill/plugin conflicts). Differs from --bare:
#   auth, model selection, built-in tools and permissions still work normally, and managed
#   settings policy still applies. Sets CLAUDE_CODE_SAFE_MODE.
claude -p "task" --safe-mode

# Skip all setup: hooks, skills, commands, subagents, plugins, MCP, auto-memory, CLAUDE.md
#   Keeps Bash + file read/edit. Skills under --add-dir still load. Sets CLAUDE_CODE_SIMPLE.
claude -p "task" --bare
```

`--bare` is the fastest possible headless start — use it for self-contained tasks
that do not need any project configuration.

## Fail-closed unattended runs (v2.1.259+)

For a headless host with nobody watching, the default direction a prompt fails matters more than
usual:

> "Added `--permission-prompts none` for unattended headless hosts: anything that would prompt is
> denied automatically while the active permission mode (including auto mode) keeps deciding"
> — [v2.1.259 release notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.259)

```bash
claude -p "task" --permission-mode auto --permission-prompts none
```

Contrast the two ways to remove a prompt from a headless loop:

| Flag | What happens to a prompt | Direction |
|---|---|---|
| `--permission-prompts none` | Denied automatically; the active mode's own decisions still apply | Fail-**closed** |
| `--dangerously-skip-permissions` | Never asked; the action runs regardless | Fail-**open** |

For a scheduled or unattended `--print` loop — nobody at the terminal to answer a prompt —
`--permission-prompts none` is the safer default: an action that would have needed a human's yes
is skipped, not silently allowed. See [Permissions & Auto Mode](08-permissions.md) for the full
permission-mode picture.

!!! warning "This is a `--print`-only guarantee"
    `claude --help` scopes the flag explicitly — *"Who answers permission prompts **with --print**"*
    — and `--bg` conflicts with `--print` outright, so a **background session cannot fail closed
    this way**. Its prompts surface in the agent view and wait for a human. The same applies to
    `--max-budget-usd`, whose help reads *"(only works with --print)"*. Verified on `claude`
    **2.1.261**; see [Background Agents § What `--bg` does not
    get](29-background-agents.md#what-bg-does-not-get).

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

**Before hand-rolling this, know what the CLI already does.** Claude Code has its own
retry/backoff for transient failures:

- `CLAUDE_CODE_RETRY_WATCHDOG` (persistent retry mode, meant for unattended sessions such as CI
  jobs or eval harnesses) raises the default retry count for non-capacity transient errors to
  **300** and lifts the earlier cap of 15 on `CLAUDE_CODE_MAX_RETRIES` (v2.1.199), but fails at
  once — rather than waiting indefinitely — on a `429` that reports an organization spend limit
  or exhausted usage credits (v2.1.239).
- `API_TIMEOUT_MS` governs the per-request timeout, including how long a retry waits when the
  API sends no response headers at all: **10 minutes by default** (600000ms) as of v2.1.261,
  raised from 3 minutes.

*Source: [environment variables reference](https://code.claude.com/docs/en/env-vars), verified
against `claude` **2.1.261**, 2026-09-07.*

The wrapper below still earns its place for the git-safety and idempotency checks further down —
but a bare retry-on-transient-error loop may now just be duplicating what the CLI already does on
its own.

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

**Exit code alone is not enough — scan the output too.** Two cases break the simple
`&& exit 0` pattern above:

1. **PTY wrappers mask the exit code.** If you wrap the call in `script` (to force
   live, unbuffered logging — see above), macOS `script(1)` does **not** reliably
   propagate the child's exit code; it often returns `0` even when `claude` failed.
2. **Transient API drops** (`API Error: ... ECONNRESET`, `socket hang up`,
   `overloaded_error`) are exactly the failures worth retrying, and they print to the
   output stream.

So treat an attempt as failed if the exit code is non-zero **or** a transient-error
marker appears in that attempt's output:

```bash
ERROR_REGEX='API Error:|ECONNRESET|ETIMEDOUT|Unable to connect to API|socket hang up|overloaded_error|529 |503 Service'
script -q "$tmp" /opt/homebrew/bin/claude --permission-mode auto -p "/my-loop"; code=$?
if [[ $code -eq 0 ]] && ! grep -Eq "$ERROR_REGEX" "$tmp"; then
  echo "success"; exit 0
fi
# else: back off (e.g. 30s → 90s) and retry
```

Use exponential-ish backoff (30s, 90s) so a brief provider blip does not lose the
whole scheduled run. The production version of this is `scripts/run-loop-news.sh`.

**Only retry when a retry is safe.** Blind retries are dangerous when the loop has
side effects (file writes, commits, releases): a fresh re-run can duplicate work or
hit a tag/release collision. A retry wrapper should refuse to make things worse:

- **Cap the cost** — pass `--max-budget-usd` so 3 attempts can't become an unbounded bill.
- **Retry only on a clean, traceless failure.** Before retrying, check that the failed
  attempt left no durable trace: the tracked tree is still clean **and** `HEAD` has not
  moved. If it already committed or made partial edits, *stop and notify a human* instead
  of re-running.
- **Notify on give-up.** A silent `exit 1` to a log nobody reads is how a daily loop dies
  unnoticed. Emit a notification (e.g. macOS `osascript -e 'display notification …'`) on
  final failure.

```bash
head_before="$(git rev-parse HEAD)"
run_attempt || {
  [[ "$(git rev-parse HEAD)" != "$head_before" ]] && { notify "failed after commit"; exit 1; }
  git diff --quiet && git diff --cached --quiet || { notify "partial edits"; exit 1; }
  # clean + HEAD unchanged → safe to back off and retry
}
```

The deeper fix for true safe-to-retry is *idempotency inside the loop itself* (e.g. a
digest section keyed by date that is updated rather than appended, and the commit as the
single final atomic step) — the wrapper guard above only refuses to compound damage.

### Worktree isolation + a two-session pipeline (the production shape)

`scripts/run-loop-news.sh` evolved past the single-checkout guard above into a shape worth
copying for any self-writing daily loop:

1. **Run in a throwaway git worktree branched off `origin/main`.** The daily cron must not
   inherit whatever branch or dirty state the primary checkout happens to be in. A worktree
   (`git worktree add -b <temp> <wt> origin/main`) gives every run a clean, isolated base
   and makes a failed attempt's filesystem fully disposable. A `trap cleanup EXIT` removes
   it in every path.

2. **Split the loop into two sessions with an artifact handoff.** The search half
   (`fetch-loop-news`) writes a compact `.loop-news/findings.json` and stops; the KB half
   (`integrate-loop-news`) starts a *fresh* session that consumes only that artifact,
   integrates, and pushes. The session boundary keeps the search stage's bulky retrieval
   context out of the reasoning stage, and makes each half independently testable and
   retryable.

3. **Granular retry via a per-attempt tree reset.** The worktree is created once per run;
   each attempt `git reset --hard origin/main` + `git clean -fd` first. Because the artifact
   lives in the *gitignored* `.loop-news/`, it survives the reset — so a failure in the KB
   half re-runs **only** that half against the saved findings, never repeating the expensive
   search.

4. **Adapt the retry guard to the durable side effect.** Worktree isolation makes the tree
   disposable, but the final `git push origin HEAD:main` is durable and outlives the
   worktree. So the guard is retargeted from "primary `HEAD` moved" to "**`origin/main`
   advanced past the base SHA**": on failure, if `origin/main` moved, a prior attempt already
   published → stop and notify, never retry (a blind retry would double-commit the digest).
   A zero-finding day makes no commit, so success stays judged by exit code, not by whether
   `main` advanced.

On success the wrapper fast-forwards the primary checkout (`git pull --ff-only`) only if it
is on `main`, so the local checkout tracks the published run without disturbing other work.

### Pitfall: a skill can't tell interactive from headless invocation

A multi-stage pipeline split across skills (search → integrate, in this repo's case) relies
on each stage stopping at its boundary so the *orchestrator* — not the model — decides when
the next stage runs. It is tempting to write an escape hatch into the first stage's skill
like *"if you were invoked interactively, run the next skill yourself"* — so a human typing
the command by hand still gets the full pipeline without two manual steps.

**Don't.** A model running headlessly via `-p` has no reliable signal that distinguishes
"interactive" from "orchestrated" — it cannot introspect how it was launched. In production
this caused a single search-stage session to also execute the entire integrate stage
(digest, KB writes, release, commit, push) inside itself, collapsing a deliberately
two-session design (context isolation, independent retry, independent model/effort) back
into one — and it happened even with the extra stage's tools (`Bash`, git) absent from
`--allowedTools`, because `--permission-mode auto`'s classifier approved them anyway (see
[Core flags](#core-flags) on the classifier, not the allowlist, being the real gate).

**Rewording the prompt is not the fix — it is not even reliable.** The first attempt at a
fix removed the interactive exception and told the model, in strong unambiguous language,
to stop unconditionally under all circumstances. It collapsed into one session again on
the very next real production run anyway. Prose instructions — no matter how forcefully
worded — are not a substitute for an actual permission boundary; a headless session under
`--permission-mode auto` has demonstrated willingness to route around them when it decides
the surrounding context justifies it.

**The actual fix is `--disallowedTools`, verified experimentally, not assumed.** Unlike
`--allowedTools` (a pre-approval list the auto classifier can freely expand beyond),
`--disallowedTools` is a genuine deny-list — confirmed by isolated testing (a minimal
session with `--disallowedTools "Bash(git *)"` under `--permission-mode auto`, asked to
run a git command, reported the call was denied — not routed around). Scope the deny to
the specific capability that enables the escalation, not a blanket tool name, if the stage
has any other legitimate narrow use of that tool (here, Stage A still needs plain `Bash`
for a `date` call, so the deny is `Bash(git *),Bash(gh *),Skill` — scoped to git/gh/Skill,
not `Bash` outright).

The full fix layers as follows, from primary to defense-in-depth:
1. **Primary, structural** — deny the escalation capability itself via `--disallowedTools`
   on the first stage's session (verified to hold even under `--permission-mode auto`).
2. **Prose** — the skill still says to stop unconditionally, for the case where it's run
   interactively outside the wrapper (no `--disallowedTools` applies there) — necessary,
   but demonstrated insufficient alone.
3. **Skill-level defense-in-depth** — the second stage's Phase 0 checks (via `git log
   --grep`) whether this exact run has already been committed, before doing any real work,
   and aborts immediately if so.
4. **Wrapper-level defense-in-depth (cheapest — zero LLM cost)** — after the first stage
   completes, the orchestrator checks whether the shared remote ref advanced with a commit
   matching this run (not just "did it move" — an unrelated concurrent commit must not be
   mistaken for this); if matched, skip the second stage entirely rather than paying for a
   full session just to have it discover the same thing via reasoning.

## Scheduling with macOS LaunchAgent

For daily headless loops that require local tools (Chrome browser automation, local
filesystem, system credentials), a LaunchAgent is more reliable than cron — it
respects login sessions, restarts on failure, and survives reboots.

```xml
<!-- ~/Library/LaunchAgents/com.user.my-loop.plist -->
<dict>
    <key>Label</key>
    <string>com.user.my-loop</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/path/to/repo/scripts/run-my-loop.sh</string>
    </array>

    <!-- Run at 05:00 local time daily -->
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key><integer>5</integer>
        <key>Minute</key><integer>0</integer>
    </dict>

    <!-- launchd has minimal PATH — supply homebrew explicitly -->
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key>
        <string>/Users/yourname</string>
    </dict>

    <key>WorkingDirectory</key>
    <string>/path/to/repo</string>

    <key>StandardOutPath</key>
    <string>/path/to/repo/logs/launchd.log</string>
    <key>StandardErrorPath</key>
    <string>/path/to/repo/logs/launchd.log</string>

    <key>RunAtLoad</key><false/>
</dict>
```

```bash
# Register and trigger
launchctl load ~/Library/LaunchAgents/com.user.my-loop.plist
launchctl start com.user.my-loop   # immediate manual run

# Check status
launchctl list com.user.my-loop

# Remove
launchctl unload ~/Library/LaunchAgents/com.user.my-loop.plist
```

**When to prefer LaunchAgent over Routines:** the loop uses `--chrome` (browser
automation), needs local credentials, or reads files not in a git repo.
**When to prefer Routines:** laptop needs to be off during the run, or you want
cloud-managed infrastructure. See [Routines](28-routines.md) — but note Routines
cannot access local Chrome sessions.

## Related

- [Background Agents](29-background-agents.md) — detached, persistent sessions
- [Routines](28-routines.md) — cloud-native alternative (no local machine needed)
- [Cost & Turn Control](11-cost-control.md) — `--max-turns`, `--max-budget-usd`
- [Permissions & Auto Mode](08-permissions.md) — `--permission-mode auto` details
