# Claude Code Loop Engineering — Best Practices

> Stop writing prompts. Start designing loops.

Loop engineering is the shift from typing prompts into a coding agent to **writing the
system that prompts the agent for you**. Instead of a single one-shot instruction, you
design a workflow that observes, plans, acts, verifies, and iterates — autonomously,
while you sleep.

---

## 1. The Paradigm Shift

| Old way | Loop engineering |
|---|---|
| Prompt → wait → review → prompt again | Design the loop once, let it run |
| Tactical, one-shot | Strategic, systemic |
| You are the verification step | The loop verifies itself |
| Session dies when you close your laptop | Loop runs on schedule or event trigger |

The key insight (credited to Boris Cherny, who built Claude Code):
**replace yourself as the person who prompts the agent**.

---

## 2. The Core Agent Loop Cycle

Every Claude Code session — whether interactive or headless — follows this cycle:

```
Observe → Reason → Plan → Act (tool calls) → Verify → repeat
```

Claude is **not** a chatbot that waits for input between turns. Within a single
session it chains tool calls autonomously: read files, run commands, edit code, run
tests, read results, iterate. Each full round-trip (Claude output → tool execution →
result back to Claude) is one **turn**.

The loop ends when:
- Claude produces a text-only response (no tool calls) — `success`
- `max_turns` is reached — `error_max_turns`
- `max_budget_usd` is exceeded — `error_max_budget_usd`
- A Stop hook rejects the result — loop re-enters
- An unrecoverable error occurs — `error_during_execution`

---

## 3. The Six Building Blocks of a Loop

Addy Osmani (Google) and Boris Cherny frame every well-designed loop around six
components:

### 3.1 Automations
What triggers the loop: a cron/schedule, a GitHub event, a Slack message, a CI
failure, a file watcher. The loop starts because *something happened*, not because
you typed.

```bash
# Example: run Claude on every push via GitHub Actions
claude -p "$(cat .claude/prompts/review.md)" --permission-mode auto
```

### 3.2 Worktrees
Parallel work in isolated git checkouts so edits from different loop instances do
not collide. Each worktree is its own sandbox.

```bash
git worktree add .worktrees/feature-auth -b feature/auth
# Run a Claude session inside it
claude --permission-mode auto -p "implement OAuth in this worktree"
```

### 3.3 Skills
Reusable, invokable workflows packaged as `.claude/skills/<name>/SKILL.md` files.
Skills give Claude domain knowledge and step-by-step procedures it can execute on
command — without bloating `CLAUDE.md`.

```markdown
<!-- .claude/skills/fix-issue/SKILL.md -->
---
name: fix-issue
description: Fix a GitHub issue end-to-end
disable-model-invocation: true
---
Fix GitHub issue: $ARGUMENTS

1. `gh issue view $ARGUMENTS` — understand the problem
2. Search codebase for relevant files
3. Implement the fix
4. Write tests, run them, fix failures
5. Lint and typecheck
6. `git commit` with descriptive message
7. `gh pr create`
```

Invoke it: `/fix-issue 1234`

### 3.4 Plugins / Connectors
MCP servers that give the loop access to external systems: databases, browsers,
APIs, Linear, Figma, Slack, GitHub. Add them once, and every loop session inherits
the tools.

```bash
claude mcp add          # interactive setup
claude mcp add --global # available in all projects
```

### 3.5 Sub-agents
Isolated Claude sessions spawned from the parent loop to handle focused subtasks.
Each subagent starts with a **fresh context window** — it does not see the parent's
turns. Only its final summary returns to the parent. Use sub-agents for:

- Investigation (reads many files without polluting parent context)
- Verification (a reviewer that never saw the code it's judging)
- Parallel work (multiple agents working on independent parts simultaneously)

```text
Use a subagent to review the diff in @src/auth/ for edge cases.
Report only issues that affect correctness, not style preferences.
```

Define a specialized subagent in `.claude/agents/`:

```markdown
<!-- .claude/agents/security-reviewer.md -->
---
name: security-reviewer
description: Audits code for injection, auth flaws, and secrets
tools: Read, Grep, Glob, Bash
model: claude-opus-4-8
---
You are a senior security engineer. Flag: SQL/XSS/command injection,
auth/authz flaws, secrets in code, insecure data handling.
Provide file:line references and suggested fixes.
```

### 3.6 Memory
State that survives across conversations. Without memory, every loop starts blind.
Memory is anything that lives **outside a single conversation**:

- A markdown file committed to the repo (`PROGRESS.md`, `PLAN.md`)
- A GitHub issue or project board
- A Linear ticket
- A file the loop writes at the end of each run

```text
After completing each task, update PROGRESS.md with: task name,
status (done/blocked), files changed, and what comes next.
```

---

## 4. Verification: The Non-Negotiable Foundation

> A loop is only as trustworthy as its ability to check its own work.

Without verification, the loop has no stopping condition — it either halts too early
("looks done") or spins forever. **Always give Claude a check it can run.**

A check is anything that returns a pass/fail signal Claude can read:

- Test suite (`npm test`, `pytest`, `cargo test`)
- Build exit code (`npm run build`)
- Linter (`eslint`, `ruff`)
- Script that diffs output against a fixture
- Browser screenshot compared against a design
- A separate evaluator model (a subagent that did not write the code)

### Verification strategies

| Scope | Mechanism | How to set it up |
|---|---|---|
| Single prompt | Ask Claude to run the check and iterate in the same message | `"implement X. run tests after. fix any failures."` |
| Across a session | `/goal` condition | `"my goal is: all tests pass and the build succeeds"` |
| Deterministic gate | Stop hook | Runs a script; blocks the turn from ending until it passes |
| Independent review | Verification subagent | Fresh model reviews the diff, not the work-in-progress |

### The self-verifying loop pattern
```text
1. Claude implements the feature
2. Claude runs: npm test
3. If tests fail → Claude reads output, edits code, re-runs
4. Loop ends only when tests pass
5. Stop hook runs linter as a final gate before the turn closes
```

**Show evidence, not assertions.** Have Claude output the test result, the command
it ran, and what it returned. Reviewing evidence is faster than re-running
verification yourself.

---

## 5. CLAUDE.md — Your Persistent Context Layer

`CLAUDE.md` is loaded at the start of every session. It is **re-injected on every
request**, so rules survive context compaction.

### The rule: short and surgical

Keep it ruthlessly concise. If Claude already does something correctly without the
rule, delete the rule. Bloated `CLAUDE.md` files cause Claude to ignore instructions.

```markdown
# Code style
- ES modules (import/export), not CommonJS
- Destructure imports when possible

# Workflow
- Typecheck after every series of edits: npx tsc --noEmit
- Run single tests, not the full suite: npx jest <file>

# Commit conventions
- Conventional commits: feat:, fix:, chore:, docs:
- Never commit directly to main

# Environment
- Node 22+, pnpm (not npm)
- .env.local for secrets (never commit)
```

### What belongs where

| Content | Put it in |
|---|---|
| Rules that apply to every session | `CLAUDE.md` |
| Project overview and commands | `CLAUDE.md` (brief) or linked via `@README.md` |
| Domain-specific workflows | A Skill |
| Personal overrides | `CLAUDE.local.md` (gitignored) |
| Team-wide rules | `CLAUDE.md` (committed) |
| Rules for a subdirectory | `subdir/CLAUDE.md` (auto-loaded when Claude reads files there) |

### Import syntax

```markdown
# CLAUDE.md
See @README.md for project overview and @package.json for available scripts.

- Git workflow: @docs/git-instructions.md
```

### Customizing compaction

Tell the compactor what to preserve when context is summarized:

```markdown
# Summary instructions
When compacting this conversation, always preserve:
- The current task objective and acceptance criteria
- File paths modified during this session
- Test results and error messages
- Decisions made and their reasoning
```

---

## 6. Skills — Reusable Workflows

Skills are on-demand procedures stored in `.claude/skills/<name>/SKILL.md`. Unlike
`CLAUDE.md`, they load only when invoked — keeping every-session context lean.

**When to create a skill:**
- Any multi-step process you invoke more than twice
- Processes involving external tools (`gh`, `aws`, `docker`)
- Workflows your whole team should share

**Commit skills to git.** Place team skills in `.claude/skills/`. Claude auto-discovers
them. Any developer gets the same capabilities.

```markdown
<!-- .claude/skills/deploy/SKILL.md -->
---
name: deploy
description: Deploy to production after running full checks
---
Deploy the current branch to production:

1. Run: pnpm test && pnpm build
2. If either fails, stop and report what failed
3. `gh pr view --json mergeable` — confirm PR is mergeable
4. `aws ecr get-login-password | docker login ...`
5. `docker build -t app:$(git rev-parse --short HEAD) .`
6. `docker push ...`
7. `kubectl rollout restart deployment/app`
8. `kubectl rollout status deployment/app`
9. Report deploy SHA and confirm pods are Running
```

---

## 7. Subagents — Keep Main Context Clean

The context window is your most critical resource. Subagents protect it.

```text
Use subagents to investigate how our auth system handles token refresh.
Report a summary — I don't need the full file contents in this session.
```

The subagent reads dozens of files, runs grep searches, and reports back a concise
summary. Your main context grows by that summary only, not by every file read.

**Writer/Reviewer pattern:**

```text
Session A (Writer): "Implement rate limiting for /api/v1 endpoints"

Session B (Reviewer): "Review @src/middleware/rateLimiter.ts.
  Check for race conditions, edge cases, and consistency
  with existing middleware. Report gaps only."

Session A: "Here's the review: [Session B output]. Address the issues."
```

---

## 8. Permissions & Auto Mode

Repeated permission prompts break autonomy. Three options, in order of trust:

### 8.1 Permission allowlists (surgical)
Allow specific commands you know are safe:

```bash
# In .claude/settings.json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git *)", "Bash(pnpm *)", "Edit", "Read"]
  }
}
```

### 8.2 Auto mode (recommended for unattended runs)
A separate classifier model reviews each tool call. Blocks scope escalation, unknown
infrastructure changes, and prompt-injection-driven actions. Lets routine work proceed
without interruption.

```bash
claude --permission-mode auto -p "fix all lint errors and commit"
```

If the classifier blocks the same action 3 consecutive times (or 20 total), it
escalates to the human rather than looping forever.

### 8.3 bypassPermissions (CI / containers only)
Runs all tools without asking. Only use in isolated environments (Docker, CI, VMs)
where the agent's actions cannot affect systems you care about.

```bash
claude --permission-mode bypassPermissions -p "run migration"
```

---

## 9. Headless & Non-Interactive Mode

`claude -p "prompt"` runs Claude without a session — no terminal UI, no interactive
prompts. This is the entry point for all automation.

```bash
# One-off task
claude -p "summarize what changed in the last 10 commits"

# Structured output for scripting
claude -p "list all exported functions in src/" --output-format json

# Streaming JSON for real-time processing
claude -p "analyze error.log" --output-format stream-json --verbose
```

**Key flags:**
- `--permission-mode auto` — safe unattended execution
- `--max-turns 20` — cap turns; start conservative, raise with data
- `--allowedTools "Edit,Bash(git *)"` — scope permissions per invocation
- `--output-format json|stream-json` — machine-readable output

**Build explicit halt conditions.** In headless mode there is no UI to escalate to.
If the loop hits an unrecoverable state, it terminates. Log everything at the step
where it fails, not silently at the end.

---

## 10. Fan-Out — Parallelizing at Scale

For large migrations, analyses, or batch operations, distribute work across many
parallel Claude invocations:

```bash
# Step 1: Generate task list
claude -p "list all Python files that need migrating to async. output one path per line" \
  > files_to_migrate.txt

# Step 2: Fan out across files
while IFS= read -r file; do
  claude -p "Migrate $file to async/await. Preserve all behavior. Return OK or FAIL." \
    --permission-mode auto \
    --allowedTools "Read,Edit,Bash(git commit *)" \
    --max-turns 15 &
done < files_to_migrate.txt
wait
```

**Test on 2-3 files first.** Refine the prompt on small batch failures, then run
the full set. The `--allowedTools` flag prevents the fan-out from touching anything
outside its intended scope.

**Pipe Claude into your existing pipelines:**

```bash
cat error.log | claude -p "identify the root cause" --output-format json | jq '.result'
```

---

## 11. Cost & Turn Control

Uncapped loops are expensive and can run indefinitely on open-ended prompts. Always
set limits for unattended runs.

```python
# Agent SDK (Python)
from claude_agent_sdk import query, ClaudeAgentOptions

async for message in query(
    prompt="refactor the auth module",
    options=ClaudeAgentOptions(
        max_turns=30,          # hard turn cap
        max_budget_usd=2.00,   # hard cost cap
        effort="high",         # reasoning depth: low|medium|high|xhigh|max
        model="claude-sonnet-4-6",
    )
):
    ...
```

**Effort levels:**

| Level | Use when |
|---|---|
| `low` | File lookups, listing directories |
| `medium` | Routine edits, standard tasks |
| `high` | Refactors, debugging |
| `xhigh` | Complex coding tasks (Fable 5 / Opus 4.7+) |
| `max` | Multi-step problems requiring deep analysis |

**Handle result subtypes:**

```python
if message.subtype == "error_max_turns":
    # Resume the session with a higher limit
    resume_session(session_id, max_turns=60)
elif message.subtype == "error_max_budget_usd":
    alert("Budget exceeded — review and restart")
```

---

## 12. Hooks — Deterministic Side Effects

Hooks are shell scripts (or SDK callbacks) that fire at specific points in the loop.
Unlike `CLAUDE.md` instructions (advisory), hooks are **deterministic guarantees**.

```json
// .claude/settings.json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [{ "type": "command", "command": "npx eslint $CLAUDE_TOOL_INPUT_PATH --fix" }]
      }
    ],
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": "npm test" }]
      }
    ]
  }
}
```

**Key hook events:**

| Hook | When it fires | Common uses |
|---|---|---|
| `PreToolUse` | Before a tool executes | Validate inputs, block dangerous commands |
| `PostToolUse` | After a tool returns | Auto-lint, auto-format, audit outputs |
| `Stop` | When the agent finishes | Run tests as a final gate; block turn if they fail |
| `PreCompact` | Before context compaction | Archive full transcript |
| `SubagentStop` | When a subagent completes | Aggregate parallel results |

A Stop hook that returns a non-zero exit code blocks the turn from ending. Claude
re-reads the hook output and tries again. After 8 consecutive blocks, Claude Code
overrides and ends the turn — preventing infinite loops.

---

## 13. Context Management

The context window is your most important resource. Performance degrades as it fills.

### Rules:
- `/clear` between unrelated tasks — start each task with clean context
- `/compact` to summarize before starting a large new section
- Use subagents for investigation — their reads don't consume your context
- Never ask Claude to "explore the whole codebase" — scope narrowly
- After two failed corrections, `/clear` and write a better prompt

### Compaction shortcuts:
```
/compact Focus on the API changes only
/compact Preserve: task objective, modified files, test results
```

### What eats context fastest:
- Large file reads (every file read accumulates)
- Verbose bash output (`--verbose` on for dev, off for production loops)
- Long CLAUDE.md files
- Many MCP tool schemas (use MCP tool search to defer loading)

---

## 14. Human-in-the-Loop Escalation

Full autonomy is not always the goal. Build escalation points for situations the
loop cannot resolve:

```markdown
# In CLAUDE.md
If you encounter any of the following, stop and ask for human input:
- A destructive database operation (DROP, DELETE without WHERE)
- A push to main or production infrastructure
- A cost estimate exceeding $10
- Ambiguity about which of two approaches to take
- Three consecutive test failures with no clear fix
```

**Auto mode escalates automatically** when:
- The classifier blocks the same action 3 consecutive times
- Total denied actions reach 20 in a session

---

## 15. The Explore → Plan → Implement → Commit Workflow

For complex, multi-file tasks, always separate phases:

```bash
# Phase 1: Explore (plan mode — no edits)
# Press Ctrl+R to enter plan mode, or:
claude --permission-mode plan
> "Read src/auth and understand how sessions work. 
   Also look at how we handle environment secrets."

# Phase 2: Plan
> "I want to add Google OAuth. What files change? 
   What's the session flow? Write a detailed plan."
# Press Ctrl+G to open plan in editor before Claude proceeds

# Phase 3: Implement (exit plan mode)
> "Implement the OAuth flow from the plan. Write tests 
   for the callback handler. Run tests and fix failures."

# Phase 4: Commit
> "Commit with a descriptive message and open a PR"
```

**Skip planning for small, clear tasks.** Planning adds overhead. If you can describe
the diff in one sentence, go directly to implementation.

---

## 16. Memory Patterns for Long-Running Loops

A loop that runs for hours or days needs external memory. Build it into the loop.

### Pattern A: Progress file
```text
At the end of each task, append to PROGRESS.md:
- Task: [name]
- Status: [done|blocked|in-progress]  
- Files changed: [list]
- Next: [what the loop should do when it resumes]
```

### Pattern B: GitHub Issues as a task queue
```text
1. Loop reads open issues labeled "loop-task"
2. Picks the highest-priority one
3. Implements, tests, commits, opens PR
4. Labels issue "loop-done" and moves to next
```

### Pattern C: Spec-driven loop
```text
1. Write SPEC.md with all requirements and acceptance criteria
2. Loop implements one requirement at a time
3. Each requirement has a verifiable test
4. Loop stops when all tests pass
```

---

## 17. Common Failure Patterns

| Pattern | Symptom | Fix |
|---|---|---|
| Kitchen-sink session | Unrelated tasks mixed, context polluted | `/clear` between tasks |
| Correction loop | Same mistake corrected 2+ times | `/clear` + rewrite the prompt with what you learned |
| Over-specified CLAUDE.md | Claude ignores some rules | Prune ruthlessly — if Claude does it right without the rule, delete it |
| Trust-then-verify gap | Plausible implementation with hidden edge cases | Always give Claude a runnable check |
| Infinite exploration | Claude reads hundreds of files, context full | Scope investigations narrowly or use subagents |
| No stopping condition | Loop runs forever or halts randomly | Define a verifiable success criterion before starting |
| Uncapped headless run | Expensive, hard to debug after the fact | Set `--max-turns` and `--max-budget-usd` |
| Reviewer bias | Claude reviews code it wrote, misses issues | Always use a subagent for final review |

---

## 18. Quick Reference

```bash
# Non-interactive with safety limits
claude -p "prompt" --permission-mode auto --max-turns 20

# Fan-out across files
for f in $(cat files.txt); do
  claude -p "process $f" --permission-mode auto --allowedTools "Read,Edit" &
done; wait

# Structured output
claude -p "prompt" --output-format json | jq '.result'

# Resume a session
claude --continue           # most recent
claude --resume             # pick from list

# Plan mode (explore without editing)
# Ctrl+R in interactive, or --permission-mode plan

# Clear context
/clear

# Compact with instructions
/compact Preserve: task objective, modified files, open questions

# Set a goal (loop until verified)
/goal all tests pass and build succeeds

# Run a skill
/fix-issue 1234
/deploy staging
```

---

## Sources

- [Claude Code Best Practices (official docs)](https://code.claude.com/docs/en/best-practices)
- [How the Agent Loop Works (Claude Agent SDK)](https://code.claude.com/docs/en/agent-sdk/agent-loop)
- [Loop Engineering — Addy Osmani](https://addyosmani.com/blog/loop-engineering/)
- [The Anthropic leader who built Claude Code now writes loops — The New Stack](https://thenewstack.io/loop-engineering/)
- [Stop Prompting Your Agent. Start Writing Loops. — Medium](https://medium.com/@garbarok/stop-prompting-your-agent-start-writing-loops-73608223f075)
- [I Don't Prompt Claude Anymore. I Write Loops. — Medium](https://medium.com/@fahey_james/i-dont-prompt-claude-anymore-i-write-loops-that-prompt-claude-57e48a4f28d7)
- [Loop Engineering GitHub repo — cobusgreyling](https://github.com/cobusgreyling/loop-engineering)
- [Claude Code Agentic Workflow Patterns — MindStudio](https://www.mindstudio.ai/blog/claude-code-agentic-workflow-patterns)
