# Context Management

The context window is your most important resource. Performance degrades as it fills.

## The New Rules for Claude 5-Generation Models (version-stamped)

Anthropic rewrote how it prompt-engineers Claude Code's *own* system prompt for the Opus
5 / Fable 5 generation, removing **over 80% of it with no measurable loss on internal
coding evaluations** — a direct, first-party data point on the shift from prescriptive
rules to model judgement. Three stated framing shifts, each with a concrete before/after:

| Then | Now |
|---|---|
| Give Claude rules | Let Claude use judgement |
| Put it all upfront | Use progressive disclosure |
| Give Claude examples | Design interfaces |

The comments-style-rule example makes this concrete. The old system-prompt text: *"In
code: default to writing no comments. Never write multi-paragraph docstrings or
multi-line comment blocks — one short line max. Don't create planning, decision, or
analysis documents unless the user asks for them — work from conversation context, not
intermediate files."* The replacement: *"Write code that reads like the surrounding code:
match its comment density, naming, and idiom."* One long enumerated rule became one
judgement-calibrating sentence. Progressive disclosure moved verification guidance out of
the system prompt entirely, into optional Skills loaded only when the task needs them —
the same "load only what's needed, when it's needed" principle this doc's own [Input
Governance Pipeline](#input-governance-pipeline) applies to conversation history.

**What this means for a `CLAUDE.md` you maintain, not just Anthropic's own prompt**: this
is the same direction as [CLAUDE.md's "Rules Have a Half-Life"](05-claude-md.md), now with
an official data point behind it — an enumerated rule a newer model already gets right by
judgement is a rule worth cutting, not just tolerating.
([Anthropic, "The new rules of context engineering for Claude 5-generation models"](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models), Jul 2026.)

## Rules

- `/clear` between unrelated tasks — start each task with clean context
- `/compact` to summarize before starting a large new section
- Use subagents for investigation — their reads don't consume your context
- Never ask Claude to "explore the whole codebase" — scope narrowly
- After two failed corrections, `/clear` and write a better prompt

## `/context` — checking what's actually filling the window

Before reaching for `/compact` or a full reset, run `/context` (added **v1.0.86**) to see what is
actually consuming the window: a breakdown by tool definitions, skills, MCP servers, memory, and
message history. Later releases added actionable suggestions — the command now flags
context-heavy tools, memory bloat, and capacity warnings with specific fixes. (On a build before
**v2.1.129**, calling it repeatedly had its own cost: `/context` injected its own rendered ASCII
visualization grid into the conversation, ~1.6K tokens per call — fixed since, but a reason to
prefer the status line's percentage over polling `/context` on an older CLI.) Check it before
choosing between `/compact` and a hard reset, not after.
([v1.0.86](https://code.claude.com/docs/en/changelog#1-0-86) and
[v2.1.129](https://code.claude.com/docs/en/changelog#2-1-129) changelog entries;
[Commands](https://code.claude.com/docs/en/commands); [Debug your
configuration](https://code.claude.com/docs/en/debug-your-config).)

## Compaction shortcuts

```
/compact Focus on the API changes only
/compact Preserve: task objective, modified files, test results
```

## Context resets vs. compaction

Two strategies when a context window fills during a long task:

| Strategy | What it does | When to use |
|---|---|---|
| **`/compact`** | Summarizes earlier content in-place | When continuity matters and the model handles large context well |
| **Context reset** | Clears the window entirely; passes state via structured handoff artifacts | When the model shows "context anxiety" — degraded reasoning caused by accumulated history |

**Context anxiety** is the observable degradation that occurs when a model's earlier
mistakes, reversals, and dead ends remain in context: subsequent reasoning is anchored
to that accumulated wreckage rather than the current goal.

Findings from Anthropic engineering ([Prithvi Rajasekaran, "Harness design for long-running application development"](https://www.anthropic.com/engineering/harness-design-long-running-apps), Mar 2026):
- Claude Sonnet 4.5 exhibited significant context anxiety — resets were essential for reliable output
- Claude Opus 4.6 largely eliminated this behaviour — compaction is often sufficient

**Practical rule:** If you observe a model re-litigating earlier decisions or
drifting from the original goal across turns, switch from compaction to resets.
Encode the learnings externally first (see [Experience Encoding](27-loop-contract.md)),
then start the next iteration from a clean window.

A reset that recurs on every iteration is worth escalating past prompt-level fixes: if
state keeps needing an explicit handoff between clean windows, the task may be better
modelled as an explicit graph of steps than as a single loop leaning on compaction — see
[the loops-vs-graphs debate](21-context-vs-loop-engineering.md#a-second-debate-loops-vs-graphs-jul-2026).

## Auto-compact thresholds by model (version-stamped)

The point at which auto-compact fires has moved as 1M-context models' compaction windows were
tuned closer to the actual limit:

| Model | Auto-compact point | Since |
|---|---|---|
| Sonnet 5 (1M context) | ~967K tokens | v2.1.247 |
| Opus and Fable (1M context) | shortly before the 1M-token limit | v2.1.260 |

> "Changed Sonnet 5's default auto-compact window to its full 1M context, so sessions on the 1M
> window now auto-compact at about 967K tokens instead of about 934K"
> — [v2.1.247 release notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.247)

> "Improved auto-compact for 1M-context models: Opus and Fable sessions now compact shortly
> before the 1M-token limit, and recovery compaction on very large contexts no longer times out
> at 10 minutes"
> — [v2.1.260 release notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.260)

If auto-compact is off, the error a loop hits mid-run now says so instead of just reporting the
limit:

> "Improved the context-limit error to say when auto-compact is off and point to `/config` to
> re-enable it"
> — [v2.1.235 release notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.235)

## Input Governance Pipeline

Before the model sees context, a governance pipeline can pre-process it to prevent
bloat from accumulating in the first place. Run these steps at session or turn start:

| Step | What it does |
|---|---|
| **Prefetch** | Load only the files and state actually needed for this turn |
| **Snip** | Truncate or summarise oversized inputs before they enter context |
| **Microcompact** | Compress completed subtask summaries into one-line records |
| **Collapse** | Merge redundant assistant-turn repetitions |
| **Autocompact** | Apply `/compact` automatically when context exceeds a threshold |

"Clean the site first, then execute." Proactive governance keeps context lean
throughout the session; reactive compaction triggered when the window is full is
more expensive and disruptive.

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

## Reactive Compact — Emergency Mid-Loop Compaction

Distinct from planned `/compact`: a reactive compact fires when context pressure
becomes critical mid-loop. Treat it as a failure-prone operation with its own
defensive budgeting:

- **Reserve output tokens**: keep ≥20,000 tokens free for the compact summary;
  compaction that runs out of output space produces a truncated summary that is
  worse than no summary
- **Early-warning buffer**: trigger at ≥13,000 tokens remaining — not when the
  window is already full
- **Circuit breaker**: if compaction fails 3 consecutive times, halt and escalate
  rather than continuing with degraded context

```
context usage > (window − 13,000 tokens)
  → fire reactive compact
  → verify summary completeness
  → if 3 consecutive failures → halt + escalate to human
```

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

## What eats context fastest

- Large file reads (every file read accumulates)
- Verbose bash output (`--verbose` on for dev, off for production loops)
- Long CLAUDE.md files
- Many MCP tool schemas (use MCP tool search to defer loading)
