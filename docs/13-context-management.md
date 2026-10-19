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

**An Anthropic engineer's practice on the same point.** In the Latent Space interview
([29 Sep 2026](https://www.latent.space/p/thariq), transcript read), Thariq Shihipar said "it might be better
to start a new project without a Claude.md" and that "if you see very repeated failure modes, you add them to
your Claude.md". His reason for not accumulating them: a failure mode can disappear from one model version to
the next, and a running log of old ones "will probably over constrain Claude". One interviewee's view, not
documentation; it agrees with the half-life rule above.

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
- Claude Opus 4.5 largely removed this behaviour on its own — compaction is often sufficient

**Practical rule:** If you observe a model re-litigating earlier decisions or
drifting from the original goal across turns, switch from compaction to resets.
Encode the learnings externally first (see [Experience Encoding](27-loop-contract.md)),
then start the next iteration from a clean window.

A reset that recurs on every iteration is worth escalating past prompt-level fixes: if
state keeps needing an explicit handoff between clean windows, the task may be better
modelled as an explicit graph of steps than as a single loop leaning on compaction — see
[the loops-vs-graphs debate](21-context-vs-loop-engineering.md#a-second-debate-loops-vs-graphs-jul-2026).

### A managed reset at a threshold: aigent-OS

[wrg32786/aigent-os](https://github.com/wrg32786/aigent-os) (MIT) automates the reset half of the table
above. Its Managed Auto-Refresh asks Claude for a resume-ready checkpoint file (a "capsule") when
context reaches a configurable threshold (default 80%), waits for an exact completion acknowledgement,
sends one `/clear`, confirms a fresh session started, and tells it to load the capsule and carry on. It
refuses to resume from a capsule that records no next step, and its README says an audit on 1 Aug 2026
found three of four live vaults would otherwise have resumed into a checkpoint with no actionable content. It sets
`"idleCompaction": false` (see [below](#idle-compaction-version-stamped)) so Claude Code's own compaction cannot replace the
boundary it controls.

Read its evidence as the README states it: 11 of 11 observed cycles, on one Windows seat, in one live run
for v1.1.0-rc.1. The README does not claim to beat compaction, and notes that release can stall at the
clear step (open issues #90 and #91, acknowledgement edge cases). This is the same shape as the
handoff-artifact reset this section recommends, with the ack-before-clear step made mechanical.

### Fork-and-flush: clear the chat, keep the workspace

[*Fork-and-Flush: Escaping Idea Basins in Autoresearch Agents*](https://arxiv.org/abs/2610.07447)
(arXiv, submitted 5 Oct 2026) reports that independent runs of the same agent on the same task plateau
at substantially different scores, and that trajectories stay in localized regions of the solution space
the authors call "idea basins". The intervention is periodic: fork the agent into parallel trajectories
that each inherit the accumulated **workspace** but start with a **fresh chat context**, run each for a
fixed horizon, then continue from the highest-scoring one. Across 13 long-horizon research and
engineering tasks (individual runs up to several days) the abstract reports relative improvements of
66.0% over a single run and 44.4% over best-of-N, on min-max normalized average score at equal compute.
Those are the authors' figures on their own benchmark; the abstract does not say the result transfers to
coding loops. For this KB it is a measured case for resetting *context* while preserving *state on
disk*, with a scored selection step; compare Claude Code's [session forking](37-session-architecture.md#branching-and-forking-a-session),
which copies the transcript rather than flushing it.
([explainx.ai summary](https://explainx.ai/blog/fork-and-flush-idea-basins-autoresearch-agents-microsoft-2026), a secondary write-up.)

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

## Idle compaction (version-stamped)

Claude Code now compacts a long conversation *while you are away*, so a resumed loop does not pay to
reprocess it. Per the [changelog](https://code.claude.com/docs/en/changelog), v2.1.299 (14 Oct 2026):

> "Added idle compaction in the terminal: a 200K+ token conversation left idle for about 54 minutes is
> compacted before its one-hour prompt cache expires, so your next message doesn't reprocess it all"

The same entry adds `CLAUDE_CODE_IDLE_COMPACT_MIN_TOKENS` to change the 200K-token minimum and
`"idleCompaction": false` in `settings.json` to turn it off (the entry says both need v2.1.290 or later).
v2.1.302 (16 Oct 2026) added an **Idle compaction** row to `/config` and made the notice shown after an
idle compaction say how to turn it off.

Why it matters to a loop: a loop that sleeps between iterations (a `/loop` wait, a slow external gate)
can now have its context compacted after roughly 54 idle minutes, and compaction is lossy (see above). If
your loop depends on exact earlier tool output, either write it to disk before sleeping or turn idle
compaction off for that project, as [aigent-OS](#a-managed-reset-at-a-threshold-aigent-os) does.
Secondary write-ups ([MindStudio](https://www.mindstudio.ai/blog/claude-code-3-0-parallel-sessions/),
[explainx.ai](https://explainx.ai/blog/claude-code-v2-1-301-v2-1-302-auto-mode-model-idle-compaction-fork-subagents-2026))
describe the same feature; the changelog entry above is the primary source.

## Input Governance Pipeline

Before the model sees context, a governance pipeline can pre-process it to prevent
bloat from accumulating in the first place. Run these steps at session or turn start:

| Step | What it does |
|---|---|
| **Prefetch** | Preload memory and skill-discovery state before the model call, not the whole file tree |
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

**A different failure mode from the same root cause: what compaction throws away can be
unrecoverable, not just lossy.** After thread compaction, the actual executed Python code in one
long-running session became unrecoverable — only a prose summary of what it had done remained.
The lesson generalizes beyond any one vendor's compaction implementation: any LLM system using
compaction must preserve or expose pre-compaction *artifacts* (the tool calls themselves) rather
than relying on a prose summary standing in for them. ([Simon Willison, "Generating running routes
with GPT-6 Astra and ChatGPT
Work"](https://simonwillison.net/2026/Sep/12/astra-running-routes/), Sep 2026.)

**Keep the original, pass a handle.** The two context mechanisms in [SoL-Pi](https://github.com/NVlabs/SoL-Pi)
(NVIDIA; design per its [paper](https://arxiv.org/abs/2609.20519) and README; cost results in
[Cost & Turn Control](11-cost-control.md#where-the-money-goes-turns-not-observations)) archive before they
shrink. Tool results over 10 KiB are stored locally and, from the third request on, replaced by a stable handle,
the original size and a short head-and-tail excerpt, with exact pages retrievable on demand. Long build/test
logs are replaced by a cheap-model "receipt" only if every quoted line matches the archived source; otherwise
the original stays. Compaction is deferred to completed plan steps (or a nearly full window) and runs only when
projected input savings exceed the cost of rewriting the prompt cache. Costs to plan for: archives are "not
automatically deleted" when the session ends, and the log reducer sends content to a second model, so keep it
off for logs that must stay local. These are the authors' design and results for the
[Pi](https://github.com/earendil-works/pi) harness; this KB has not run them.

## What eats context fastest

- Large file reads (every file read accumulates)
- Verbose bash output (`--verbose` on for dev, off for production loops)
- Long CLAUDE.md files
- Many MCP tool schemas (use MCP tool search to defer loading)
