# The Six Building Blocks of a Loop

Addy Osmani (Google) and Boris Cherny frame every well-designed loop around six
components.

## 1. Automations

What triggers the loop: a cron/schedule, a GitHub event, a Slack message, a CI
failure, a file watcher. The loop starts because *something happened*, not because
you typed.

```bash
# Example: run Claude on every push via GitHub Actions
claude -p "$(cat .claude/prompts/review.md)" --permission-mode auto
```

## 2. Worktrees

Parallel work in isolated git checkouts so edits from different loop instances do
not collide. Each worktree is its own sandbox.

```bash
git worktree add .worktrees/feature-auth -b feature/auth
# Run a Claude session inside it
claude --permission-mode auto -p "implement OAuth in this worktree"
```

## 3. Skills

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

## 4. Plugins / Connectors

MCP servers that give the loop access to external systems: databases, browsers,
APIs, Linear, Figma, Slack, GitHub. Add them once, and every loop session inherits
the tools.

```bash
claude mcp add          # interactive setup
claude mcp add --global # available in all projects
```

### Chrome extension — authenticated web access

The Chrome integration (`claude --chrome`) is a first-class connector that gives the
loop access to **any site you're already logged into** — including X/Twitter, Google
Docs, Notion, Linear, and internal tools — without API keys or MCP setup.

```bash
claude --chrome
# then:
> "Go to x.com, open this tweet: <url>, and extract the full thread text"
> "Monitor my X notifications every hour and summarise new replies"
> "Read this GitHub discussion and pull the key decisions into DECISIONS.md"
```

Key properties:
- Shares your browser's **existing login session** — no OAuth setup
- Browser actions run in a **visible Chrome window** (you can watch)
- Claude pauses and asks you to handle CAPTCHAs or login walls manually
- Works with Chrome and Edge; not yet supported on Brave, Arc, or WSL
- Requires a direct Anthropic plan (Pro/Max/Team/Enterprise); not available via Bedrock/Vertex

```bash
# Enable by default so every session has browser access
# Run /chrome → "Enabled by default"

# Or per-session
claude --chrome -p "go to x.com/mikenevermiss and extract his last 5 posts about Claude"
```

**For scraping research inputs into a loop:** this is the cleanest path — navigate
directly, extract text, write it to a local file, then pipe it into your loop prompt.

## 5. Sub-agents

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

## 6. Memory

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
