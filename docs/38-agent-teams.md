# Agent Teams

Agent teams are a second way to run multiple Claude Code instances at once, distinct from
[subagents](07-subagents.md). The defining difference is who reports to whom.

> "One session acts as the team lead, coordinating work, assigning tasks, and synthesizing
> results. Teammates work independently, each in its own context window, and communicate
> directly with each other. You can also talk to any teammate directly without going through
> the lead."
>
> — [Agent teams](https://code.claude.com/docs/en/agent-teams)

A subagent reports a summary back to whichever session spawned it. A teammate does not report
back through anyone — it messages other teammates and the lead directly, and it can be messaged
directly in return. The official diagram caption states the contrast plainly:

> "Subagents report results back to the main agent. In agent teams, teammates share a task
> list, claim work, and communicate directly with each other."
>
> — [Agent teams](https://code.claude.com/docs/en/agent-teams)

## Experimental, off by default

Agent teams ship disabled. Enabling them is one environment variable:

```json
// settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

> "Agent teams are experimental and disabled by default. Enable them by setting
> `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your settings.json or environment. Without that
> variable, no team is set up at session start, no team directories are written, and Claude
> does not spawn or propose teammates."
>
> — [Agent teams](https://code.claude.com/docs/en/agent-teams)

Spawning a teammate also requires an interactive session — in [headless mode](09-headless-mode.md)
(`-p`), including Agent SDK sessions, a subagent Claude names runs as an ordinary subagent even
with the flag set.

As of v2.1.178, no separate setup step is needed once the flag is set — spawning a teammate no
longer requires Claude to create and name a team first, and cleanup happens automatically when
the session exits. Before that version, Claude used now-removed `TeamCreate` and `TeamDelete`
tools to do this explicitly.

## Subagents vs. agent teams

Anthropic's own comparison table:

| | Subagents | Agent teams |
|---|---|---|
| **Context** | Own context window; results return to the caller | Own context window; fully independent |
| **Communication** | Return a result to the caller | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Self-coordination through messages, plus a shared task list for agents with the Task tools |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

> "Use subagents when you need quick, focused workers that report back. Use agent teams when
> teammates need to share findings, challenge each other, and coordinate on their own."
>
> — [Agent teams](https://code.claude.com/docs/en/agent-teams)

The strongest named use cases are research and review split by lens, new modules each owned by
a teammate, debugging via competing hypotheses that actively try to disprove each other, and
cross-layer work (frontend/backend/tests) each owned by a different teammate.

## Architecture

| Component | Role |
|---|---|
| **Team lead** | The main Claude Code session that spawns teammates and coordinates work |
| **Teammates** | Separate Claude Code instances that each work on assigned tasks |
| **Task list** | Shared list of work items that teammates claim and complete |
| **Mailbox** | Messaging system for communication between agents |

— [Agent teams](https://code.claude.com/docs/en/agent-teams)

**Task list.** Tasks have three states — pending, in progress, and completed — and can depend
on other tasks: "a pending task with unresolved dependencies cannot be claimed until those
dependencies are completed." The lead can assign a task explicitly, or a teammate can self-claim
the next unassigned, unblocked task after finishing its own. "Task claiming uses file locking to
prevent race conditions when multiple teammates try to claim the same task simultaneously."
Dependent tasks unblock automatically when a task they depend on completes, with no action from
the user. Agents without the Task tools coordinate through messages instead of the shared task
list. (Quotes: [Agent teams](https://code.claude.com/docs/en/agent-teams).)

**File locking needs a forced-interleaving test to pin a race, not a hope of flaky
reproduction.** A file-locked task-claiming scheme can still admit two holders if a reclaim's
staleness check runs before the rename that frees the lock path — a third contender's
`O_CREAT|O_EXCL` can win the momentarily-free path in between. The fix is a narrowing
(re-confirm the lock still holds the judged-stale file immediately before moving it), not an
elimination — POSIX has no rename-if-unchanged. Root-causing this class of bug reliably means
writing a test that forces the interleaving rather than waiting for it to reproduce naturally.
([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Sep 2026.)

**Mailboxes.** Each agent's mailbox is a JSON file at
`~/.claude/teams/{team-name}/inboxes/{agent-name}.json`. Claude Code validates every entry it
reads; a malformed entry is reported as an error and removed, and the valid messages are still
delivered. A message is reported as sent only when the write to the recipient's mailbox file
succeeds — a full disk or an unwritable mailbox directory returns an error to the sender and
delivers nothing. Teams and their tasks are stored under a session-derived name
(`session-<first 8 chars of the session ID>`): team config at
`~/.claude/teams/{team-name}/config.json`, task list under `~/.claude/tasks/{team-name}/`. The
team config directory is removed when the session ends; the task list directory persists
locally (never uploaded), so a resumed session keeps its tasks.

**Display modes.** Two modes govern how teammates render:

- **In-process** (the default) — all teammates run inside the main terminal; arrow keys select
  a teammate in the agent panel, Enter opens its transcript. Works in any terminal.
- **Split panes** — each teammate gets its own pane, requiring [tmux](https://github.com/tmux/tmux/wiki)
  or iTerm2 with the [`it2` CLI](https://github.com/mkusaka/it2). Not supported in VS Code's
  integrated terminal, Windows Terminal, or Ghostty.

Set the default via `teammateMode` in `~/.claude/settings.json`, or per session with
`claude --teammate-mode auto` (an experimental flag not shown in `claude --help`).

**Model-selection precedence.** Claude Code picks each teammate's model from the first of these
that applies:

1. The model your spawn prompt names for that teammate.
2. For a teammate spawned from a subagent definition, the definition's `model` (`inherit`
   selects the lead's model).
3. `CLAUDE_CODE_SUBAGENT_MODEL`, when set to anything other than `inherit`.
4. The lead's current model.

Before v2.1.251, `CLAUDE_CODE_SUBAGENT_MODEL` came first in this order.
`CLAUDE_CODE_SUBAGENT_MODEL_FORCE` applies to teammates as well as to subagents, and teammates
inherit the lead's effort level. (— [Agent teams](https://code.claude.com/docs/en/agent-teams).)

## Hooks

Three hooks target agent-team events specifically:

| Hook | Fires when | Exit code 2 |
|---|---|---|
| [`TeammateIdle`](https://code.claude.com/docs/en/hooks#teammateidle) | A teammate is about to go idle | Sends feedback and keeps the teammate working |
| [`TaskCreated`](https://code.claude.com/docs/en/hooks#taskcreated) | A task is being created | Prevents creation and sends feedback |
| [`TaskCompleted`](https://code.claude.com/docs/en/hooks#taskcompleted) | A task is being marked complete | Prevents completion and sends feedback |

This is the same deterministic-vs-advisory pattern covered in [Hooks](12-hooks.md), applied to
team coordination instead of tool calls — a quality gate a teammate cannot talk its way past.

## Limits

Stated plainly by the docs, as of the same page:

- **No session resumption for in-process teammates.** `/resume` and `/rewind` do not restore
  them; after a resume the lead may try to message teammates that no longer exist, and has to
  spawn replacements.
- **One team per session.** A session has exactly one team, scoped to that session — no
  additional named teams, no sharing a team across sessions.
- **No nested teams.** "Teammates cannot spawn their own teammates. Only the lead can manage the
  team."
- **No background subagents from in-process teammates.** An in-process teammate's own subagents
  run in the foreground, because "a teammate's background work can't outlive the lead's
  process" — Claude Code errors if a teammate spawns a subagent whose definition sets
  `background: true`, and a teammate's `run_in_background: true` request either errors or runs
  silently in the foreground.
- **Permissions fixed at spawn.** All teammates start with the lead's permission mode — if the
  lead runs `--dangerously-skip-permissions`, so do all teammates. Individual teammate modes can
  be changed after spawning, but not set per-teammate at spawn time. Teammate permission prompts
  surface in the lead session.
- **Lead is fixed** for the session's lifetime — no promoting a teammate to lead, no leadership
  transfer.
- **Split panes require tmux or iTerm2** and are unsupported in VS Code's integrated terminal,
  Windows Terminal, or Ghostty.
- **Task tools may not exist at all.** As of **v2.1.233**, the todo/task-tracking tools
  (`TaskCreate`/`TaskGet`/`TaskList`/`TaskUpdate`, `TodoWrite`) are no longer available by default
  on Opus 4.8, Sonnet 5, Fable 5, Mythos 5, and newer models; set `CLAUDE_CODE_ENABLE_TODO_TOOLS=1`
  to bring them back ([v2.1.233 release
  notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.233).) The shared **Task
  list** described above, and the reuse-property note that an in-process teammate gets
  `TaskCreate`/`TaskGet`/`TaskList`/`TaskUpdate` "where the session has the Task tools," both
  assume this variable is set on a current default model — without it, teammates fall back to
  coordinating through messages only, with no shared claimable list.

(— [Agent teams: Limitations](https://code.claude.com/docs/en/agent-teams#limitations).)

## When not to

> "Agent teams add coordination overhead and use significantly more tokens than a single
> session. They work best when teammates can operate independently. For sequential tasks,
> same-file edits, or work with many dependencies, a single session or subagents are more
> effective."
>
> — [Agent teams](https://code.claude.com/docs/en/agent-teams)

Token usage "scales linearly" with teammate count, since each has its own context window, and
returns diminish beyond a certain size. The stated starting point:

> "Start with 3-5 teammates for most workflows. This balances parallel work with manageable
> coordination. If you have 15 independent tasks, 3 teammates is a good starting point."
>
> — [Agent teams](https://code.claude.com/docs/en/agent-teams)

Same page, on task sizing: "too small" wastes coordination overhead on trivial work, "too
large" leaves teammates working too long without check-ins, and "just right" is "self-contained
units that produce a clear deliverable, such as a function, a test file, or a review." Agent
teams also do not isolate teammates in worktrees the way subagents and manually-run sessions can
— two teammates editing the same file overwrite each other, so "partition the work so each
teammate owns a different set of files"
([Run agents in parallel](https://code.claude.com/docs/en/agents)).

For the underlying argument against splitting standing work by role rather than by context
boundary — which applies to agent teams as much as to a planner/coder/reviewer session split —
see [Session Architecture](37-session-architecture.md); it is not re-argued here.

## Do teams pay off? Measured evidence (Oct 2026)

"Significantly more tokens" is Anthropic's own wording; two October 2026 studies put numbers on it.
Both measure a lead delegating to workers, which is the shape of agent teams and of
[subagent fan-out](07-subagents.md), not the Claude Code experimental flag specifically.

**[Vals AI](https://www.vals.ai/blogs/multi-agent-vibe-code-bench) (Katrina Drozdov, 2026-10-09)**
ran GPT 6 Sol and Claude Opus 5.5 on [Vibe Code Bench](https://www.vals.ai/benchmarks/vibe-code)
(50 full-stack web apps, graded by browser agents) as a single agent and as a team (a lead plus up to
five subagents, which cannot spawn their own). Each of the eight setups ran **once**.

| Setup | Single agent: score, cost/app | Team: score, cost/app | Team cost multiple |
|---|---|---|---|
| Sol, medium effort | 77.6%, $1.22 | 84.9%, $3.07 | 2.5x |
| Sol, max effort | 89.0%, $4.82 | 90.4%, $8.54 | 1.8x |
| Opus 5.5, medium effort | 91.5%, $4.08 | 91.2%, $9.10 | 2.2x |
| Opus 5.5, max effort | 89.8%, $23.77 | 93.2%, $122 | 5.1x |

Only the first row's gain (+7.3 points, p = 0.005) was statistically significant; the other three
differences (-0.3 to +3.4 points) were not. For Sol, raising effort lifted the score more than adding a
team did, although the max-effort single agent cost 1.6x the medium-effort team. Vals attributes most of
the extra spend to cached input: every subagent re-sends its own context (spec plus working state) on each
model call. The two leads also orchestrated differently: Sol split the work in parallel within minutes,
while Opus wrote a shared contract first and then delegated in sequential waves, so its teams ran up to
2.3x longer. Vals cautions that this is one benchmark of web apps and may not generalise.

**[Scaling Inference-Time Compute with Teams of Coding Agents](https://arxiv.org/abs/2610.17471)**
(arXiv 2610.17471, v1, 2026-10-12, not peer reviewed) builds a minimal harness and varies *where* the lead
delegates (planning, implementation, verification), the team's models and the worker count. Per the
abstract: on ProgramBench teams beat solo agents at three to seven times the cost, and allocation moves the
reward-cost frontier:

- A heterogeneous 17-agent team came within 1.4 points of a strong homogeneous 5-agent team at 70% lower cost.
- A lead that delegated only planning, then implemented and verified itself, matched full delegation at half the cost.
- Cheap models paid off as planners (a strong lead with cheap planners recovered 47.5% of an all-strong
  team's reward gain for 13.9% of its extra cost) but not as implementers, where they lowered reward.
- Planners kept improving reward as the team grew; implementers and verifiers plateaued beyond four workers.

Read together: a team is a compute-allocation decision, not a free speed-up. Spend the extra agents on
planning, keep the strong model on implementation and the final check, and compare against simply raising
effort on one agent before adopting a team. The finding that cheap implementers hurt complicates the "cheap
hands" tier in [Subagents](07-subagents.md#strong-eyes-cheap-hands-cost-asymmetric-role-allocation);
that tier assumes strong deterministic rails around the cheap worker, which this harness did not add.

The opinion piece [More Agents, Same Mythical Month](https://www.brokenrobot.xyz/blog/more-agents-same-mythical-month)
(Broken Robot, 2026-10-14) frames the same cost as Brooks's Law: cheap code moves the bottleneck to
deciding, verifying and coordinating, and more agents amplify whatever coordination an organisation
already has. It is an argument, not a measurement; the human-attention version is the "orchestration tax"
in [Failure Patterns](17-failure-patterns.md).

### Other vendors' team shapes (secondary sources)

Four MindStudio explainers (secondary posts, weaker than a vendor primary; linked in the table)
describe team harnesses that all pair workers with a checker role. None has been verified against a primary here.

| Harness | Shape, per the explainer | Caveat in the same post |
|---|---|---|
| [Google Antigravity "teamwork" preview](https://www.mindstudio.ai/blog/google-anti-gravity-teamwork-preview/) (2026-10-15) | Lead interviews the user and plans, delegates to parallel workers, auditor/critic agents check them under an orchestrator; runs unattended for hours with human spot-checks at milestones; Ultra-tier preview | Secondary description of a preview |
| [CodeAF crew mode](https://www.mindstudio.ai/blog/codeaf-crew-feature-benchmark/) (2026-10-06) | Go coding harness with separate worker, planner and checker models per task, parallel task splitting, per-task spend tracking | The author could not confirm in a short test that the checker reduces bugs; benchmark claims are the vendor's own |
| [Paperclip](https://www.mindstudio.ai/blog/paperclip-ai-agent-team-manager/) (2026-10-06) | Open-source (MIT) coordinator over Claude Code, Codex and others: review/approval gates before a task is done, optional per-task git worktrees, scheduled routines, budgets with warning thresholds and hard stops | Budget enforcement relies on reported usage, so work can overshoot |
| [Turnstone](https://www.mindstudio.ai/blog/turnstone-ai-orchestration-local-hardware/) (2026-10-08) | Manager persona spawns workers plus an evaluator across registered local nodes; a strong model (e.g. Opus) judges while cheaper local models do token-heavy work | Tiered-model pattern; no measured result |

The shared lesson is the one above: the checker role is where these harnesses spend their trust, and a
checker's value has to be measured (see [Verification](04-verification.md)), not assumed from its existence.

## The gotcha: teams can form uninvited

Enabling agent teams changes what an ordinary subagent spawn does, not just what is possible:

> "Enabling agent teams also changes ordinary delegation. Claude may name a subagent on its own,
> and while agent teams are enabled, a subagent that Claude names launches as a teammate, so
> teams can form even when you didn't ask for one."
>
> — [Agent teams](https://code.claude.com/docs/en/agent-teams)

Concretely: Claude names subagents on its own so it can message them later; with the flag set,
any named subagent — including one spawned mid-task for an unrelated reason — becomes a
full independent teammate instead of a lighter subagent, with the token-cost and coordination
consequences above. To get named subagents back, set
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to `0`; Claude Code rereads the variable each time it
spawns a subagent, so no new session is required. A higher-precedence settings source (project,
local, `--settings`, or managed settings) can still re-enable the flag, so check those before
assuming it is off.

## The reuse property

A subagent definition is not a separate artifact from a teammate role — the same file serves
both:

> "This lets you define a role once, such as a security-reviewer or test-runner, and reuse it
> both as a delegated subagent and as an agent team teammate."
>
> — [Agent teams: Use subagent definitions for teammates](https://code.claude.com/docs/en/agent-teams#use-subagent-definitions-for-teammates)

Naming a [subagent definition](07-subagents.md#custom-agents-claudeagents) at spawn time
(`Spawn a teammate using the security-reviewer agent type...`) carries over its `tools` list (an
in-process teammate additionally gets `SendMessage`, and `TaskCreate`/`TaskGet`/`TaskList`/
`TaskUpdate` where the session has the Task tools), its `model` (subject to the precedence order
above), and its body — appended to the default system prompt for an in-process teammate, used in
place of it for a split-pane teammate. `skills` is not applied in either mode; the teammate loads
skills from project and user settings instead.

## Related

- [Session Architecture](37-session-architecture.md) — the context-boundary rule for when to
  split into more than one agent at all, argued in full there
- [Subagents](07-subagents.md) — the lighter primitive agent teams are compared against
  throughout this page
- [Dynamic Workflows](39-dynamic-workflows.md) — the scripted alternative for work that outgrows
  turn-by-turn coordination by a lead
- [Hooks](12-hooks.md) — the general deterministic-control pattern behind `TeammateIdle`,
  `TaskCreated`, and `TaskCompleted`
