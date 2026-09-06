# The Six Building Blocks of a Loop

Addy Osmani frames every well-designed loop around six components in his June 2026 post ["Loop Engineering"](https://addyosmani.com/blog/loop-engineering/) — building on the shift from prompting to loop design voiced by Peter Steinberger ("you shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents") and echoed by Boris Cherny, head of Claude Code at Anthropic (["I don't prompt Claude anymore ... my job is to write loops"](https://www.youtube.com/watch?v=RkQQ7WEor7w&t=11m45s), *Acquired Unplugged*, presented by WorkOS, Jun 2026).

## 1. Automations (local) and Routines (cloud)

What triggers the loop: a cron/schedule, a GitHub event, a Slack message, a CI
failure, a file watcher. The loop starts because *something happened*, not because
you typed.

```bash
# Local: run Claude from GitHub Actions on every push
claude -p "$(cat .claude/prompts/review.md)" --permission-mode auto
```

**Routines** (a research preview — behavior, limits, and the API surface may change) extend automations to the cloud: Anthropic-hosted loop execution that
runs without your machine. Three trigger types — Schedule (cron), API (webhook), and
GitHub events (PR open/close, Release). Your laptop can be off; the loop runs.

```bash
# Inside a Claude Code session:
/schedule   # create a scheduled Routine, or attach a GitHub trigger (CLI needs v2.1.225+);
            # API triggers must be added on the web at claude.ai/code/routines
```

See [Routines](28-routines.md) for the full model.

*Source: [Routines reference](https://code.claude.com/docs/en/routines) — research-preview
status, the three trigger types, the API-trigger-is-web-only rule and the v2.1.225 CLI floor
for GitHub triggers all confirmed there; cross-checked against `claude --version` **2.1.263**,
2026-09-06.*

## 2. Worktrees

Parallel work in isolated git checkouts so edits from different loop instances do
not collide. Each worktree is its own sandbox.

```bash
git worktree add .worktrees/feature-auth -b feature/auth
# Run a Claude session inside it
claude --permission-mode auto -p "implement OAuth in this worktree"
```

### The built-in flag: `claude --worktree`

`git worktree add` is the manual path. `claude --worktree <name>` (short `-w`) does the same setup
and then *enforces* the isolation, which the manual path cannot.

| Behaviour | Contract |
|---|---|
| Path | `.claude/worktrees/<name>/` at the repository root |
| Branch | `worktree-<name>` |
| No name given | Claude generates one, e.g. `bright-running-fox` |
| From a PR/MR | `--worktree "#1234"`, a GitHub pull request URL, or a GitLab merge request URL → worktree at `.claude/worktrees/pr-<number>`, branched from that change's head commit fetched from `origin` |
| Base ref | `worktree.baseRef` takes `fresh` or `head` only — never a branch name. To start from a specific branch, create it with git directly |

Which ref gets fetched depends on the host `origin` points at:

| Host | Ref fetched |
|---|---|
| `github.com` | `pull/<number>/head` |
| `gitlab.com` | `merge-requests/<number>/head` |
| GitHub Enterprise, self-managed GitLab, any other host | tries `pull/<number>/head` first, then `merge-requests/<number>/head` |

Before v2.1.233, `--worktree` accepted only `#<number>` and GitHub-style PR URLs, and always
fetched `pull/<number>/head`.

`--tmux` (requires `--worktree`) opens a tmux session for the worktree — iTerm2 native panes when
available, `--tmux=classic` for traditional tmux. It is in the
[CLI reference](https://code.claude.com/docs/en/cli-reference) and `claude --help`, but not on the
worktrees page.

#### `.worktreeinclude` — getting `.env` into the worktree

A worktree is a fresh checkout, so gitignored files such as `.env` and `.env.local` are not there.
A `.worktreeinclude` file at the project root copies them in whenever Claude creates a worktree.

```text
# .worktreeinclude
.env
.env.local
config/secrets.json
```

- Uses `.gitignore` syntax.
- **Only files that match a pattern *and* are gitignored are copied** — tracked files are never
  duplicated. So yes: this is the supported way to get real secrets into the worktree, and it puts
  a second copy of them inside the repo tree. Know that before pointing an unattended loop at it.
- Applies to every worktree Claude Code creates with git: `--worktree` worktrees, subagent
  worktrees, and parallel sessions in the desktop app.
- **Not** processed when a `WorktreeCreate` hook replaces the default git logic (non-git VCS) —
  copy the files inside the hook script instead.
- A `**/` pattern reaches into a wholly-gitignored directory only when that directory itself
  matches the pattern, or the first name after the `**/` is one of the names in the directory's
  path. Name the directory instead: `vendor/**/config.json`, not `**/config.json`.

#### Resume and cleanup

| Situation | What happens |
|---|---|
| Resume a session that was in a worktree | The session returns to that worktree — interactive resume, `--continue` and `--resume` with `-p`, and the Agent SDK. Claude can still leave with `ExitWorktree` |
| Exit, worktree clean, unnamed session | Worktree and branch removed automatically |
| Exit, worktree clean, named session | Prompts first, so you can keep it |
| Exit, worktree has work (changed or untracked files, or new commits) | Prompts to keep or remove. Removing deletes the directory and branch with everything in them |
| `-p` run | No exit prompt and no cleanup. The lock taken at creation stays until a later session's stale-lock sweep. Remove with `git worktree remove`; if git refuses because it is locked, `git worktree unlock` first |

A periodic sweep also removes worktrees Claude created for subagents and background sessions once
they are older than your `cleanupPeriodDays` setting. Separately, `claude rm <id>` deletes a
background session "and its worktree when that is safe", including for sessions that have already
exited (`claude --help`; not documented on the worktrees page).

**Do not assume the sweep covers your case.** On 11 Aug 2026 the creator of Claude Code described
handling this himself, in full:

> Worktrees can be rough when they pile up. I use a loop to clean up stale worktrees. Should we
> build this into Claude Code?

— [Boris Cherny (@bcherny), 11 Aug 2026](https://x.com/bcherny/status/2087024157196489117).

Read narrowly, that is one practitioner's setup and an open product question — not proof the
built-in sweep was absent or inadequate. Read for what it is good for: the sweep above is scoped to
worktrees **Claude created** for subagents and background sessions, so worktrees you create with
`git worktree add` are outside it, and a cleanup loop of your own is the documented-by-example
remedy. The numeric default of `cleanupPeriodDays` is still unpublished — logged as `V4` in
`KB_GAPS.md`; **publish no day count until someone reads it.**

#### Four isolation checks — enforcement, not convention

While a session is in a worktree, Claude Code applies **four** checks:

| # | Check | What it blocks |
|---|---|---|
| 1 | **File edits** | An `Edit`, `Write`, or `NotebookEdit` that targets a path in the main checkout |
| 2 | **Command working directory** | A `Bash`, `PowerShell`, or `Monitor` command whose working directory resolves to the main checkout, or whose working directory it can't verify stays outside it |
| 3 | **Git redirects** | A `Bash` or `Monitor` command that redirects git into the main checkout — via `git -C`, `--git-dir`, a `GIT_DIR` or `GIT_WORK_TREE` variable, or a `cd` into the main checkout before running git |
| 4 | **Command shape** | A `Bash` or `Monitor` command whose text can't be verified to keep git inside the worktree — a command name computed at runtime, or syntax that can't be parsed. Claude Code tells Claude how to rewrite it, such as splitting it into plain, separate commands |

Scope, exactly:

- The checks cover the repository Claude Code was launched from, and the main checkout that a
  linked worktree is linked from.
- PowerShell commands get check 2 only.
- The same enforcement covers **every subagent** spawned from the isolated session, interactive or
  background; subagents running in their own worktree carry the same checks.
- *"You can't turn this check off"* is stated for **check 4 only**. The reference attaches it to
  Command shape, not to the set of four — don't quote it as if all four were undisableable.

**Why this is the interesting part.** A repo convention like this one's — *"Always work in a git
worktree — never in the primary checkout"* — is prose in a `CLAUDE.md`. It holds only while the
agent reads it, retains it through a long session, and resolves an edge case the way you would; a
subagent three layers down may never have seen it. `--worktree` converts the same rule into a
property of the harness: an `Edit` at the wrong path is *refused*, not discouraged, and the refusal
propagates to every subagent below without being restated. That is the difference between a STOP
condition **stated in the prompt** and one **enforced by the runtime** — the same distinction as
`permissions.deny` versus "please don't push to `main`". Where a constraint actually matters, take
the mechanical version and keep the prose for what the harness cannot check. See
[Permissions](08-permissions.md) and [The Loop Contract](27-loop-contract.md).

#### Gotchas

| Gotcha | Detail |
|---|---|
| Workspace trust | Interactive `--worktree` needs trust already accepted in that directory — run `claude` once there first, or it exits with an error. `-p` skips the trust check |
| Symlinks | Creation is refused when `.claude`, `.claude/worktrees`, or the worktree directory itself is a symlink, and the error names the path. Before v2.1.212 it followed a committed symlink and could create files outside the repository |
| Git LFS | With `git lfs install --local`, a Claude-created worktree holds LFS **pointer files**: Claude Code deliberately skips the repository's filter drivers, because a filter driver is a shell command and anything that can write to the repo could have put one there. Run `git lfs pull` inside the worktree |
| Shared state | A worktree shares the repository's `.git`, project-scope plugins, and saved permission approvals with the main checkout. "Yes, and don't ask again" for a Bash command saves to the **main checkout's** `.claude/settings.local.json` (v2.1.211+), applies everywhere in the repo, and survives the worktree's removal |
| `EnterWorktree` prompt | Entering a path outside `.claude/worktrees/` always asks first — it moves the session's working directory, write access, and project config. An `EnterWorktree` allow-rule or "don't ask again" does not suppress it; only `bypassPermissions` does. Before v2.1.206 Claude could enter any existing worktree path without asking |
| Non-git VCS | Worktrees require a git repository; other version control systems need `WorktreeCreate`/`WorktreeRemove` hooks replacing the git logic entirely |

Background sessions compose with all of this: `claude --bg --worktree <name> "<task>"` gives each
worker its own enforced sandbox — pass the worktree name explicitly, because `--worktree [name]`
takes an optional value and will otherwise swallow the prompt as the name (reproduced on 2.1.263:
`state: failed`, "Error creating worktree: Invalid worktree name", no worktree created) — see [Background Agents](29-background-agents.md).

*Source: [worktrees reference](https://code.claude.com/docs/en/worktrees),
[CLI reference](https://code.claude.com/docs/en/cli-reference), and
[settings reference](https://code.claude.com/docs/en/settings-reference); cross-checked against
`claude --version` **2.1.261**, 2026-09-05.*

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

*Source: [Skills reference](https://code.claude.com/docs/en/skills) — the `SKILL.md` layout and
`disable-model-invocation: true` confirmed there; cross-checked against `claude --version`
**2.1.263**, 2026-09-06.*

## 4. Plugins / Connectors

MCP servers that give the loop access to external systems: databases, browsers,
APIs, Linear, Figma, Slack, GitHub. Add them once, and every loop session inherits
the tools.

```bash
# `name` and `commandOrUrl` are both required — there is no interactive form
claude mcp add my-server -- npx my-mcp-server                      # stdio (default transport)
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp  # HTTP
claude mcp add --scope user my-server -- npx my-mcp-server         # all projects (default: local)
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
- Works with Chrome, Edge, and other Chromium-based browsers (Brave, Arc, Vivaldi, Opera); not supported on WSL
- Requires a direct Anthropic plan (Pro/Max/Team/Enterprise); not available via Amazon Bedrock, Google Cloud's Agent Platform (formerly Vertex AI), or Microsoft Foundry

```bash
# Enable by default so every session has browser access
# Run /chrome → "Enabled by default"

# Or per-session
claude --chrome -p "go to x.com/mikenevermiss and extract his last 5 posts about Claude"
```

**For scraping research inputs into a loop:** this is the cleanest path — navigate
directly, extract text, write it to a local file, then pipe it into your loop prompt.

*Source: [Chrome reference](https://code.claude.com/docs/en/chrome) — the shared login session,
visible window, CAPTCHA pause, the Chromium browser list (Brave, Arc, Vivaldi, Opera), the WSL
exclusion and the direct-plan requirement (not Bedrock, Google Cloud's Agent Platform, or
Microsoft Foundry) all confirmed there; `claude mcp add`'s required `name` argument reproduced
on the CLI. Cross-checked against `claude --version` **2.1.263**, 2026-09-06.*

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
model: claude-sonnet-5
---
You are a senior security engineer. Flag: SQL/XSS/command injection,
auth/authz flaws, secrets in code, insecure data handling.
Provide file:line references and suggested fixes.
```

*Source: [Sub-agents reference](https://code.claude.com/docs/en/sub-agents) — `name` and
`description` required, `tools` and `model` optional, confirmed in its frontmatter table;
cross-checked against `claude --version` **2.1.263**, 2026-09-06.*

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
