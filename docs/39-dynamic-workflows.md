# Dynamic Workflows: The Shipped Runtime

[Harness Patterns](24-harness-patterns.md) already covers the *abstract* half of this feature —
Anthropic's six named orchestration shapes (classify-and-act, fan-out-and-synthesize, adversarial
verification, generate-and-filter, tournament, loop-until-done) and the failure modes each one
guards against. Read that section first if you haven't; this page does not repeat it.

**24 holds the patterns. 39 holds the runtime.** This page is the concrete, version-stamped
mechanics of the thing those patterns run on: the script API, the hard limits, the trigger
conditions, and — critically — what happens when a run fails partway through and you relaunch it.

---

## What a dynamic workflow is

> "A dynamic workflow is a JavaScript script that orchestrates many subagents at once. Claude
> writes the script for the task you describe, and a runtime executes it in the background while
> your session stays responsive."
>
> — Anthropic, [Orchestrate subagents at scale with dynamic workflows](https://code.claude.com/docs/en/workflows)

The runtime's own bundled example is `/deep-research`: it fans out web searches across several
angles, cross-checks the sources it finds against each other, and returns one cited report instead
of a turn-by-turn transcript — the shape every workflow follows, just with a different task inside
the fan-out.

---

## Who holds the plan: the four-way comparison

Subagents, skills, agent teams, and workflows can all run a multi-step task. The docs frame the
difference as *who holds the plan*:

| | Subagents | Skills | Agent teams | Workflows |
|---|---|---|---|---|
| What it is | A worker Claude spawns | Instructions Claude follows | A lead agent supervising peer sessions | A script the runtime executes |
| Who decides what runs next | Claude, turn by turn | Claude, following the prompt | The lead agent, turn by turn | The script |
| Where intermediate results live | Claude's context window | Claude's context window | A shared task list | Script variables |
| What's repeatable | The worker definition | The instructions | The team definition | The orchestration itself |
| Scale | A few delegated tasks per turn | Same as subagents | A handful of long-running peers | Dozens to hundreds of agents per run |
| Interruption | Restarts the turn | Restarts the turn | Teammates keep running | Resumable in the same session |

(Anthropic, [Orchestrate subagents at scale with dynamic workflows](https://code.claude.com/docs/en/workflows))

The load-bearing sentence:

> "A workflow moves the plan into code. With subagents, skills, and agent teams, Claude is the
> orchestrator: it decides turn by turn what to spawn or assign next, and every result lands in a
> context window. A workflow script holds the loop, the branching, and the intermediate results
> itself, so Claude's context holds only the final answer."

That's also why a workflow survives interruption in a way the others don't — the plan isn't sitting
in a conversation that just got cut off. It's sitting in a script variable the runtime already
checkpointed. See [Resume semantics](#resume-what-reruns-and-what-doesnt) below.

---

## The script API

> "The body is plain JavaScript with top-level `await`. `agent()` spawns one subagent, `pipeline()`
> runs one per item in a list, and `parallel()` runs a set of agent tasks at the same time and
> waits for all of them."
>
> — [Orchestrate subagents at scale with dynamic workflows](https://code.claude.com/docs/en/workflows)

| Call | What it does |
|---|---|
| `agent(prompt, opts)` | Spawns one subagent and resolves to its result |
| `pipeline(items, fn)` | Runs `fn` once per item in a list |
| `parallel(tasks)` | Runs a set of agent tasks at the same time and waits for all of them |
| `phase(title)` | Groups the agents that follow under a title in the progress view |
| `log(message)` | Shows a message above the phases |
| `args` | Global holding whatever was passed to a saved workflow at invocation; `undefined` if omitted |

> "An `agent()` call resolves to `null` if you stop it mid-run or it hits an unrecoverable API
> error. `pipeline()` keeps that `null` in the results array, which is why the example ends with
> `.filter(Boolean)` to drop those entries."
>
> — [Orchestrate subagents at scale with dynamic workflows](https://code.claude.com/docs/en/workflows)

That `.filter(Boolean)` deserves a second look before you paste it in. [Session
Architecture](37-session-architecture.md#what-the-measurement-showed) documents a real run where a
19-agent fan-out lost 17 agents to a session limit, `.filter(Boolean)` silently erased them, and the
workflow reported `{"raised":0,"confirmed":[],"refuted":[]}` as a clean result — one of the
discarded findings was a real high-severity defect. Count the nulls before you filter them out.

### `pipeline()` vs `parallel()` — the distinction people get wrong

This is the single most common mistake in a hand-written workflow script, and it's easy to miss
because both calls take a list and return an array.

- **`pipeline()` has no barrier between stages.** Each item moves through its stages
  independently — item 3 can be finishing while item 1 is still on its first stage. Wall-clock time
  is roughly the slowest single item's chain, not the sum of every item's time at each stage.
- **`parallel()` is a barrier.** It starts every task at once, but nothing after the call runs
  until *all* of them have returned — including the straggler.

The failure mode is reaching for `parallel()` out of habit when the stages don't actually need each
other's full result set — which burns the wall-clock time of the barrier for no reason. The correct
default is `pipeline()`; reach for a barrier only when a later stage genuinely needs *every* prior
result together — deduplicating findings before an expensive verification pass, for example, or
early-exiting when a total count is zero.

A worked pair, same underlying task, two different needs:

```javascript
// pipeline: each file moves through audit → fix independently.
// File 12 can be in "fix" while file 1 is still in "audit" — no stage
// waits on the others. Wall-clock ≈ the slowest single file's chain.
const results = await pipeline(files, file =>
  agent(`Audit ${file} for missing auth checks.`, { label: file }),
)

// parallel: every dimension's finder runs at once, but the line after
// this call does not execute until the LAST straggler finder returns —
// because the next step (dedup) genuinely needs every result together.
const found = await parallel(DIMENSIONS.map(d => () =>
  agent(d.prompt, { schema: FINDINGS_SCHEMA }),
))
const deduped = dedupe(found.filter(Boolean).flatMap(r => r.findings))
```

If you catch yourself writing `await parallel(...)` immediately followed by a plain
flatten/map/filter with no cross-item dependency, that transform belongs inside a `pipeline()`
stage instead — the barrier isn't buying you anything, and it's forcing every fast task to wait for
the slowest one.

---

## Triggers: how a workflow starts

| Trigger | How | Version note |
|---|---|---|
| The `ultracode` keyword | Type `ultracode` in a prompt; Claude Code highlights it and writes a script instead of working turn by turn | Before v2.1.160 the literal keyword was `workflow`, not `ultracode` |
| Natural language | Asking in your own words — "use a workflow", "run a workflow" — works identically to the keyword | Works in both the pre- and post-v2.1.160 versions |
| `/effort ultracode` | Combines `xhigh` reasoning effort with automatic workflow orchestration for every substantive task in the session, not just one prompt | `claude --effort ultracode` at launch requires v2.1.203+; the `/effort` menu only offers `ultracode` on models that support `xhigh` effort |

The keyword is an opt-in only from a prompt a human actually typed — the interactive prompt, an IDE
panel, a Remote Control client, or an Agent SDK call that stamps input as `{ kind: "human" }`. It
does **not** trigger from a `-p` prompt, an un-stamped Agent SDK call, a scheduled task prompt, or a
webhook/PR-comment relay. (Before v2.1.210 it did trigger from those routes too, including webhook
and PR-comment relays — a real behavior change worth knowing if you're running Claude Code in CI.)

To back out of an accidental trigger: `Option+W` (macOS) / `Alt+W` (Windows/Linux) dismisses the
highlight for that prompt, or backspace right after the highlighted keyword. To stop the keyword
from firing at all, turn off *Ultracode keyword trigger* in `/config`.

---

## Where a workflow lives

A run that did what you wanted can be saved as a reusable slash command. From `/workflows`, select
the run and press `s`; the save dialog toggles between two locations:

| Location | Scope | Runs as |
|---|---|---|
| `.claude/workflows/*.js` | Project — shared with everyone who clones the repo | `/<name>` |
| `~/.claude/workflows/*.js` | Personal — every project, visible only to you (or under `CLAUDE_CONFIG_DIR` if set) | `/<name>` |

If a project workflow and a personal workflow share a name, the project one wins. A saved workflow
can take input through `args`, so the script reads a research question, a target-path list, or a
config object at invocation time rather than being edited per run — `Run /triage-issues on issues
1024, 1025, and 1030` passes that list straight through as the `args` global.

The shape of a small saved script — a `meta` block, then plain JavaScript:

```javascript
export const meta = {
  name: 'audit-routes',
  description: 'Audit every route handler for missing auth checks',
}

const found = await agent('List every .ts file under src/routes/.', {
  schema: { type: 'object', required: ['files'], properties: { files: { type: 'array', items: { type: 'string' } } } },
})

const audits = await pipeline(found.files, file =>
  agent(`Audit ${file} for missing authentication checks.`, { label: file }),
)

return audits.filter(Boolean)
```

(Anthropic, [Orchestrate subagents at scale with dynamic workflows](https://code.claude.com/docs/en/workflows))

---

## Hard limits (version-stamped)

The runtime enforces these regardless of any size setting — a size guideline (below) shapes what
Claude *chooses* to write; these are what the runtime will actually *run*.

| Limit | Value | Stated reason |
|---|---|---|
| Concurrent agents | Up to 16, fewer when Claude Code has fewer CPUs available — including inside a CPU-limited container | "Bounds local resource use" |
| Items per single `parallel()` or `pipeline()` call | 4,096 — a longer list is rejected with an explicit error, not silently truncated | "A silent cap would drop part of the workload without telling the script" |
| Total agents per run | 1,000 | "Prevents runaway loops" |
| Large-workflow warning | Fires once a run has scheduled more than 25 agents, or its projected token total passes 1.5 million | Shows a `Large workflow` label in the task panel — advisory only, "doesn't pause or limit the run" |

(Anthropic, [Orchestrate subagents at scale with dynamic workflows](https://code.claude.com/docs/en/workflows); current
as of the docs page fetched 2026-09-04 — the page carries no version number for these specific
runtime caps.)

Two exceptions to the 25-agent warning threshold worth knowing: if you set a [size
guideline](#size-guidelines-are-advice-not-a-cap) yourself, its agent count replaces the 25-agent
number as the warning threshold; and sessions with `ultracode` on never show the warning at all,
because turning ultracode on is itself the opt-in to large runs.

---

## Size guidelines are advice, not a cap

A size guideline tells Claude how many agents to *aim for* when it writes a workflow — it's sent as
advice, not enforced, so a prompt that calls for a different scale still overrides it. (Requires
v2.1.202+.)

| Value | Agent count Claude aims for |
|---|---|
| `unrestricted` | No guideline — Claude sizes the workflow to the task |
| `small` | Fewer than 5 agents |
| `medium` | Fewer than 15 agents |
| `large` | Fewer than 50 agents |

**The default is `medium`, as of v2.1.219.** Earlier versions default to `unrestricted`. Set it with
`/config workflowSizeGuideline=small`, or as of v2.1.219 with the `workflowSizeGuideline` key in any
settings file — a settings-file value takes precedence over `/config` and hides the `/config` row
while it's set. The runtime's [hard limits](#hard-limits-version-stamped) above still apply no
matter what the guideline says.

---

## Resume: what reruns and what doesn't

This is the detail that determines whether relaunching after a partial failure is safe or wasteful.

> "Completed: returns its saved result. The first agent whose prompt differs from the previous run,
> because you edited the script or an earlier agent returned something different, runs again, and
> so does every agent after it, even ones that completed."
>
> "Still running when you stopped: starts over. Stopping the whole run doesn't count any agent as
> failed."
>
> "Failed: runs again, and so does every agent that started after it, even ones that completed.
> Stopping one agent alone, by selecting it in `/workflows` and pressing `x`, counts as failing."
>
> — [Orchestrate subagents at scale with dynamic workflows](https://code.claude.com/docs/en/workflows)

The docs give the worked case directly:

> "If a script starts A, B, C, and D in that order and B fails, relaunching returns A from cache and
> runs B, C, and D again."

So resume is cheap when a failure is near the end of a run — the completed prefix replays instantly
from cache — and expensive when the failure is near the start, because everything downstream of it
reruns regardless of whether it had already finished. A run can be resumed within the same session;
whether it survives leaving the session depends on how you leave (backgrounding carries it over,
exiting with *"Exit and stop tasks"* does not, though the saved results persist under the session's
directory for a later `--resume` to replay from).

---

## Turning workflows off

| Scope | How |
|---|---|
| Yourself, this session onward | Toggle *Dynamic workflows* off in `/config` |
| Yourself, persistent | `"disableWorkflows": true` in `~/.claude/settings.json` |
| Yourself, persistent, env var | `CLAUDE_CODE_DISABLE_WORKFLOWS=1` — read at startup |
| Whole organization | `"disableWorkflows": true` in managed settings, or the toggle on the Claude Code admin settings page |

With workflows disabled, the bundled workflow commands and the `/workflow-authoring` skill become
unavailable, the `ultracode` keyword stops triggering, and `ultracode` disappears from the `/effort`
menu.

---

## The cost is real

Set this against the framing above: a workflow "spawns many agents, so a single run can use
meaningfully more tokens than working through the same task in conversation," and runs "count
toward your plan's usage and rate limits like any other session" — Anthropic's own words, from the
same docs page. Two practitioner reports from the launch post's [Hacker News
discussion](https://news.ycombinator.com/item?id=48311705) put a number on that:

> "I just hit my Claude Max limit for the first time _ever_ thanks to workflows lol. Like 90 agents
> ran to do a code review of a fairly small package I have."
>
> — [ncphillips, Hacker News](https://news.ycombinator.com/item?id=48313908)

> "Tested this out on a 5x max plan, turns out I spun up 62 Opus 4.8 1M sub-agents for my dynamic
> workflow and maxed out my ~5hr cap in..... 18 minutes? Oops, but probably good to know that this
> is not a cheap feature."
>
> — [Syntaf, Hacker News](https://news.ycombinator.com/item?id=48336974)

These are attributed practitioner reports of one run each — not measurements over a stated
population, and neither post names the model mix, agent count Claude actually chose, or what the
task would have cost run interactively instead. Treat them as evidence that the failure mode is
real and reachable on an ordinary plan, not as a rate.

The same thread carries a counterweight: Boris Cherny, posting as `bcherny` in reply to a question
about his own use of the feature, listed six internal results from "the last few weeks":

> "1. Autonomously landed 20+ optimizations to reduce Claude Code's token usage by ~15%
> 2. Ported tree-sitter, color-diff, yoga-layout, and a number of other WASM and Rust native
> modules to TypeScript, improving CPU and memory use by 2-10x in the process
> 3. Made our CI faster, and repeatedly found and fixed flaky tests (with /loop)
> 4. Migrated from regex-based bash static analysis to tree-sitter, reducing false positive
> permission prompts by 45%
> 5. Reduced Claude Agent SDK startup time by 61%, by repeatedly profiling and optimizing the
> startup path, putting up a number of PRs in the process
> 6. Shipped 69 code simplification PRs, deleting >10k lines of code"
>
> — [Boris Cherny (bcherny), Hacker News](https://news.ycombinator.com/item?id=48312433)

Read these plainly for what they are: vendor-reported internal numbers, posted informally in a
comment thread by the person who built the feature, with no stated population, no baseline
methodology, and a time window no more specific than "the last few weeks." They are not
independently reproduced, and this KB has no way to verify them. They belong here as the other half
of the same conversation — the token-burn reports above are real, and so, on the same evidence
standard, is the claim that the same mechanism does useful unattended work at Anthropic's own scale.
Neither side proves the other wrong; both are single-source and unaudited. Weigh a workflow's
expected cost against the size of what you're pointing it at, per [Cost & Turn
Control](11-cost-control.md), and start large runs on a narrow slice before committing to the whole
repo.

---

## Related

- [Harness Patterns](24-harness-patterns.md) — the six orchestration shapes this runtime executes
- [Subagents](07-subagents.md) — the worker primitive a workflow spawns via `agent()`
- [Choosing Your Mode](35-choosing-your-mode.md) — where workflows sit in the interactive/autonomous
  middle ground
- [Session Architecture](37-session-architecture.md) — the four-way primitive comparison in context,
  and the Pinakes case study on counting dead agents before filtering
- [Cost & Turn Control](11-cost-control.md) — per-loop token accounting, the instrument to use before
  believing either side of "the cost is real"
- [Headless Mode](09-headless-mode.md) — where the `ultracode` keyword does *not* trigger
