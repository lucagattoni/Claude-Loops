# Cost & Turn Control

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
        model="claude-sonnet-5",
    )
):
    ...
```

## Model Reference (September 2026)

Four models are current as of this writing. Figures are from Anthropic's own model comparison
and pricing pages, fetched 2026-09-04.

| Model | API ID | Context | Max output | Reliable knowledge cutoff | Positioning |
|---|---|---|---|---|---|
| Claude Fable 5.1 | `claude-fable-5-1` | 1M | 128K | Jun 2026 | "For demanding reasoning and long-horizon agentic work" |
| Claude Opus 5 | `claude-opus-5` | 1M | 128K | May 2026 | "For complex agentic coding and enterprise work" |
| Claude Sonnet 5 | `claude-sonnet-5` | 1M | 128K | Jan 2026 | "The best combination of speed and intelligence" |
| Claude Haiku 4.5 | `claude-haiku-4-5` | 200K | 64K | Feb 2025 | "The fastest model with near-frontier intelligence" |

(Anthropic, [Models overview](https://platform.claude.com/docs/en/about-claude/models/overview), fetched 2026-09-04.)

Pricing per MTok — base input / 5-minute cache write / 1-hour cache write / cache read / output:

| Model | Base input | 5m cache write | 1h cache write | Cache read | Output |
|---|---|---|---|---|---|
| Fable 5.1 | $10 | $12.50 | $20 | $0.25 | $50 |
| Mythos 5.1 (limited availability) | $10 | $12.50 | $20 | $0.25 | $50 |
| Fable 5 (legacy, still available) | $10 | $12.50 | $20 | $1.00 | $50 |
| Opus 5 | $5 | $6.25 | $10 | $0.50 | $25 |
| Sonnet 5 | $2 | $2.50 | $4 | $0.20 | $10 |
| Haiku 4.5 | $1 | $1.25 | $2 | $0.10 | $5 |

Note the cache-read column: Fable 5.1 reads at **4× cheaper** than the Fable 5 it replaced
($0.25 vs $1.00/MTok) — a Fable-tier judge pass that leans on a warm cache got meaningfully
cheaper for free on the upgrade. The general cache-pricing rule, verbatim:

> "5-minute cache write: 1.25x base input price... 1-hour cache write: 2x base input
> price... Cache read (hit): 0.1x base input price (0.025x on Claude Fable 5.1 and Claude
> Mythos 5.1)."

(Anthropic, [Pricing](https://platform.claude.com/docs/en/about-claude/pricing#prompt-caching), fetched 2026-09-04.)

**Context footnote, verbatim:** "1M tokens is roughly 555k words or 2.5M Unicode characters on
the current tokenizer (introduced with Claude Opus 4.7); models before it fit about 750k words
in 1M tokens." (Same source.) Part of a 1M-context model's headroom pays for its own tokenizer:
the newer tokenizer produces roughly 30% more tokens for the same text than the one Sonnet 4.6
and earlier models used.

### Timeline

- **Sonnet 5** — released 2026-06-30, became the default for Free and Pro, replacing Sonnet
  4.6. "Sonnet 5 narrows the gap: its performance is close to that of Opus 4.8, but at lower
  prices." Its launch pricing turned out to be permanent, not introductory: "The $2/$10 per
  million input/output token pricing for Claude Sonnet 5, announced at launch as introductory
  pricing through August 31, 2026, is now the standard price. The previously scheduled
  increase to $3/$15 per million input/output tokens on September 1, 2026 will not occur."
  (Anthropic, [Introducing Claude Sonnet 5](https://www.anthropic.com/news/claude-sonnet-5);
  pricing note from [Pricing](https://platform.claude.com/docs/en/about-claude/pricing#model-pricing).)
- **Opus 5** — released 2026-07-24 (Claude Code v2.1.219), the new default on Max and the
  strongest model on Pro, replacing Opus 4.8: "a thoughtful and proactive model that comes
  close to the frontier intelligence of Claude Fable 5 at half the price." Fast mode runs at
  twice the base rate — $10/$50 per MTok. (Anthropic, [Introducing Claude Opus 5](https://www.anthropic.com/news/claude-opus-5).)
- **Fable 5.1** — released 2026-09-01 (Claude Code v2.1.257), now the default Fable model.
  Changelog, verbatim: "Added Claude Fable 5.1 (`claude-fable-5-1`), now the default Fable
  model — 1M context, $10/$50 per Mtok with $0.25/Mtok cache reads." ([v2.1.257 release
  notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.257).)

## Choosing a Model for the Job

A table alone tells nobody what to do. Three levers actually decide the model bill on a loop:
which role gets which tier, how effort is set on top of it, and whether a mid-session switch
busts the prompt cache you were relying on.

### Main loop, subagents, and a judge pass are not the same purchase

[Subagents](07-subagents.md#strong-eyes-cheap-hands-cost-asymmetric-role-allocation)
already makes the case for allocating models by role rather than uniformly — cheap hands do
the high-volume work, strong eyes decide only at the gates. Mapped onto the current lineup:

| Role | Typical tier | Why |
|---|---|---|
| Main loop / interactive session | Sonnet 5 | Now $2/$10 per MTok list price — Opus-4.8-adjacent capability at Sonnet price, per Anthropic's own comparison above |
| Subagents, high-volume (search, test execution, log triage) | Haiku 4.5, or Sonnet 5 where more judgment is needed | Cheapest capable model; subagent output rarely needs Opus-tier reasoning |
| Judge / adjudicator pass (the gate that decides "confirmed" vs. "refuted") | Opus 5 or Fable 5.1 | Rare, high-stakes, decision-only calls — exactly where Anthropic frames Opus 5 ("half the price" of Fable 5) and Fable 5.1 ("demanding reasoning and long-horizon agentic work") as fitting |

This is the same principle the [reasoning-effort finding](#effort-levels) below applies to
effort — spend the marginal dollar where it changes the outcome — applied to model choice
instead of reasoning depth. A judge that flips one bad "confirmed" into a shipped defect costs
far more than the price delta between Sonnet and Opus on that one call.

### Which model a subagent actually runs on

Whether a subagent honours the tier you intended depends on precedence, not on what you wrote
in its frontmatter. Official docs give the resolution order, verbatim:

> 1. The per-invocation `model` parameter
> 2. The subagent definition's `model` frontmatter, where `inherit` selects the main
>    conversation's model
> 3. The `CLAUDE_CODE_SUBAGENT_MODEL` environment variable, when you set it to a model alias
>    or model ID
> 4. The main conversation's model

(Anthropic, [Sub-agents](https://code.claude.com/docs/en/sub-agents#choose-a-model), fetched
2026-09-04.)

This order is not old. It **reordered in v2.1.251**: "Changed `CLAUDE_CODE_SUBAGENT_MODEL` to
set the default subagent model rather than override everything: an agent definition's `model:`
and an explicit per-spawn model now take precedence over it." Before that release the env var
won outright — a subagent definition's pinned `model:` field could be silently overridden by
whatever `CLAUDE_CODE_SUBAGENT_MODEL` happened to be set to in the shell. ([v2.1.251 release
notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.251).)

v2.1.257 added the knob back for when a hard override is actually wanted:
`CLAUDE_CODE_SUBAGENT_MODEL_FORCE`. Verbatim: "`CLAUDE_CODE_SUBAGENT_MODEL` is a default, so a
subagent's definition or a model Claude passes still takes precedence over it. To apply one
model to every subagent, teammate, and workflow agent, also set
`CLAUDE_CODE_SUBAGENT_MODEL_FORCE` to `1`. Requires Claude Code v2.1.257 or later." Two kinds
of subagent stay exempt even with FORCE on: a `fork` (inherits the parent's context and model
directly) and a skill run in a subagent with `model: inherit`. (Anthropic, [Sub-agents — run
every subagent on one model](https://code.claude.com/docs/en/sub-agents#run-every-subagent-on-one-model),
fetched 2026-09-04.)

**Practical read:** `CLAUDE_CODE_SUBAGENT_MODEL=haiku` sets a floor for anything not explicitly
pinned, without fighting a subagent definition that pins something more expensive on purpose.
Reach for `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` only when that floor must hold with zero
exceptions — a cost audit, a compliance run — because it also overrides the built-in Explore
and Plan subagents' own `model` fields.

**The precedence order, version-stamped:**

| Rank | Source | Since | Notes |
|---|---|---|---|
| 1 (highest) | Per-invocation `model` parameter (what Claude passes when spawning this specific subagent) | Always | Wins even over a pinned agent definition |
| 2 | Subagent definition's `model:` frontmatter (`inherit` = main conversation's model) | Always | Wins over `CLAUDE_CODE_SUBAGENT_MODEL` **since v2.1.251 only** |
| 3 | `CLAUDE_CODE_SUBAGENT_MODEL` env var | Sets only the *default* since v2.1.251 | **Before v2.1.251** this rung was highest-precedence and silently overrode rungs 1 **and** 2 — including `model: inherit` |
| 4 (lowest) | Main conversation's model | Always | Applies when nothing above is set |
| — override — | `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` | v2.1.257+ | Ignores ranks 1–2 (per-spawn and agent-definition overrides), forcing rank 3 — or rank 4 if `CLAUDE_CODE_SUBAGENT_MODEL` is unset — onto every subagent, teammate, and workflow agent, except a `fork` and a skill run with `model: inherit` |

**What this means in plain terms:** setting `CLAUDE_CODE_SUBAGENT_MODEL` is a **default**, not a
guarantee. Since v2.1.251, an agent definition's own `model:` field — or a `model` Claude passes
at spawn time — silently outranks it, so a fleet you believe is capped at Haiku can still run
individual subagents on Opus if their definitions say so. Anyone who set the env var expecting a
hard cost ceiling, not just a fallback, needs `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` (v2.1.257+) —
without it, the cap is advisory.

This is no longer something to assume and hope: **`/tasks` and the agent detail dialogs show the
model (and effort level) each subagent actually ran on, as of v2.1.243** — "Added the model (and
effort level) each subagent ran on to `/tasks` and the agent detail dialogs." ([v2.1.243 release
notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.243); the official [Sub-agents
reference](https://code.claude.com/docs/en/sub-agents#checking-which-model-a-subagent-uses) cites
"Requires Claude Code v2.1.242 or later" for the same `/tasks` display.) **Practical advice:**
after setting a model floor, check `/tasks` on a real run rather than trusting the env var alone
— it is the cheapest way to catch an agent definition that quietly opted out of the cap.

See [Subagents → Custom agents](07-subagents.md#custom-agents-claudeagents) for where the
`model:` frontmatter that outranks the env var is actually set.

**The Explore trap this interacts with:** `Explore` is a built-in subagent, so it is not
exempt from any of the above — and since v2.1.198 it inherits the *main conversation's* model
by default rather than always running on Haiku, so "Explore is cheap because it's Haiku" is no
longer true unless you pin it. See [Subagents → built-in subagent types](07-subagents.md#built-in-subagent-types)
for the full mechanics and the fix (a project `Explore` agent definition with `model: haiku`).

## Token consumption benchmarks

Real-world multipliers relative to standard single-turn chat:

| Mode | Approximate token multiplier |
|---|---|
| Single agent | ~4× |
| Multi-agent | ~15× |

Set `--max-budget-usd` conservatively on first deployment (e.g. $2–5 for a single-agent
loop), then raise after observing actual consumption on real runs.

(Data Science Dojo, ["Agentic Loops: From ReAct to Loop Engineering"](https://datasciencedojo.com/blog/agentic-loops-explained-from-react-to-loop-engineering-2026-guide/), 2026.)

## Real project cost benchmarks

From Anthropic's own harness engineering work (Prithvi Rajasekaran, Mar 2026):

| Task | Architecture | Time | Cost | Result |
|---|---|---|---|---|
| Retro game maker | Solo agent | 20 min | $9 | Broken core functionality |
| Retro game maker | Full harness (Planner + Generator + QA) | 6 hours | $200 | Fully playable, 16-feature spec, 10 sprints |
| Digital audio workstation | Simplified harness (no sprints) | 3h 50min | $124.70 | Working application |

The DAW cost breakdown: Planner $0.46 · Build phases $113.85 · QA phases $10.39.

**Key takeaway:** the 20× cost increase (solo → harness) on the game maker yielded
qualitatively different output — not incrementally better. Budget for this step-change
when reliability and completeness are non-negotiable.

At the other extreme, tight environment- and budget-engineering can make *frontier*
results cheap: a system budget-engineered around a narrow, well-defined environment
reached state-of-the-art results on a 26-circle packing benchmark for **under $11 total
API cost** — evidence that BUDGET ([Loop Contract](27-loop-contract.md)) is not just a
runaway-cost guard but a design lever that, tightened around a narrow enough SCOPE, can
buy frontier-level output cheaply. ([EurekAgent, arXiv 2606.13662](http://arxiv.org/abs/2606.13662), Jun 2026.)

## Token cost by loop pattern

Concrete benchmarks from operating named loop patterns (Cobus Greyling, [cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering), Jun 2026):

| Run type | Token cost |
|---|---|
| Noop pass (empty watchlist, early exit) | ~3,000–5,000 |
| Report-only triage run | ~50,000–80,000 |
| Action run (implementer + verifier) | ~200,000–250,000 |
| CI Sweeper at 5 min cadence, no early exit | ~5,000,000/day |

**The early exit rule:** every loop must check for work before doing any triage.
If the watchlist is empty, exit immediately at <5k tokens. Never run the full loop
body if there is nothing to act on.

Without early exit, a CI Sweeper running every 5 minutes against a green repo burns
~5M tokens per day on no-ops. The early exit rule converts it to ~3k tokens per pass.
This is not an optimisation — it is a correctness requirement for always-on loops.

See [Loop Patterns](34-loop-patterns.md) for the seven named loop patterns and their
typical token envelopes.

## Cost Per Loop, Now First-Party

Until **v2.1.243**, the benchmarks above were the closest a loop engineer could get to a
per-loop cost figure without hand-rolled instrumentation — someone else's operating
experience, not a measurement of *your* loop. That release added it as a built-in report,
verbatim: "Added a Loops breakdown to `/usage`: per-loop run count, total tokens, tokens per
run, and last run, so runaway or chatty `/loop` tasks are easy to spot." ([v2.1.243 release
notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.243).)

This is the number [Ng's cost-per-unit-of-work argument](35-choosing-your-mode.md) asks
for, now first-party instead of hand-instrumented: tokens per run *is* cost per closed unit
for any loop whose unit of work is one wake-up (Daily Triage, Debt Audit); divide by
units-closed-per-run for a loop like PR Babysitter that can close several in one pass. It is
also the direct instrument for the [Loop Contract](27-loop-contract.md)'s **BUDGET** leg — a
LOOP.md that sets a per-run token cap can check that cap against `/usage` instead of
estimating it from a benchmark table, and a loop whose tokens-per-run climbs without a
matching rise in units closed is the runaway-cost signal to slow down or kill (see
[Operational Kill / Pause / Slow-Down Thresholds](#operational-kill-pause-slow-down-thresholds)
below), read directly instead of inferred from the bill.

The same release also made `/loop` itself quieter about doing nothing: "Improved `/loop`:
consecutive wake-ups where Claude has nothing to do now fold into a single line in the
terminal instead of printing each one." (Same source.) And as of **v2.1.248**, self-paced
dynamic mode and the no-prompt autonomous default lost their platform gate — see [Loop
Patterns → Loop Command Modes](34-loop-patterns.md#loop-command-modes).

## Effort levels

| Level | Use when |
|---|---|
| `low` | File lookups, listing directories |
| `medium` | Routine edits, standard tasks |
| `high` | Refactors, debugging |
| `xhigh` | Complex coding tasks (Fable 5 / Opus 4.7+) |
| `max` | Multi-step problems requiring deep analysis |

### Reasoning effort is the dominant reliability lever — not tool access

A 90-run observational study (building the same spec'd app — a real-time retro board —
across multiple model generations, two harnesses, two effort levels, a testing tool, and
two design prompts; scored on a 14-criterion / 42-point rubric) found that **reasoning
budget, not extra tooling, is what buys first-try reliability**:

| Lever | Effect on *first-try-perfect* (all 14 criteria, zero corrective prompts) | Cost delta |
|---|---|---|
| Raise effort `high` → `xhigh` | **28% → 89%** first-try-perfect; ~5× fewer corrective prompts | **+9–29%** |
| Add a testing tool | No improvement in functional score *or* reliability (even on interface-visible criteria) | **+42–68%** |

The counterintuitive result: **checking mechanisms and tool access do not fix failures
whose root cause is weak reasoning.** When the model's reasoning is the bottleneck, spend
the marginal dollar on reasoning budget (or a stronger model) before adding testing tools
or checker passes — the effort bump is both cheaper and dramatically more effective. This
does not override the [verification](04-verification.md) mandate (an *independent* verifier
still catches what the maker cannot self-see); it says a *self*-run testing tool bolted
onto a weak-reasoning maker is a poor trade against simply raising effort.

([*Reasoning effort, not tool access, buys first-try reliability in agentic code generation*](https://arxiv.org/abs/2607.02436), arXiv, Jul 2026.)

### Effort levels, officially

The table above is this KB's own framing. Official per-level guidance, verbatim (Anthropic,
[Model Config → Effort Level Guidance](https://code.claude.com/docs/en/model-config), fetched
2026-09-04):

| Level | Official guidance |
|---|---|
| `low` | "Reserve for short, scoped, latency-sensitive tasks that are not intelligence-sensitive" |
| `medium` | "Reduces token usage for cost-sensitive work that can trade off some intelligence" |
| `high` | "Balances token usage and intelligence. The default on every model except Opus 4.7" |
| `xhigh` | "Deeper reasoning at higher token spend. The default on Opus 4.7" |
| `max` | "Can improve performance on demanding tasks but may show diminishing returns and is prone to overthinking. Test before adopting broadly" |
| `ultracode` | "A Claude Code setting that plans a dynamic workflow for each substantive task with `xhigh` per-message reasoning" |

Two things worth pulling out of that table:

- **`high` is the default on every current model** — Fable 5.1, Opus 5, and Sonnet 5 alike
  default to `high`, per Anthropic's own [models comparison table](https://platform.claude.com/docs/en/about-claude/models/overview).
  Opus 4.7 (a legacy model, not Opus 5) is the sole exception that still defaults to `xhigh`.
  Don't assume a newer or pricier model defaults to deeper reasoning — check `/model`.
- **`ultracode` is not "one level deeper than `max`."** It is a qualitatively different
  setting: layered on top of `xhigh` reasoning, it **auto-triggers a [dynamic
  workflow](39-dynamic-workflows.md)** for every substantive task in the session — Claude
  decides on its own to fan a task out into a scripted multi-agent workflow rather than only
  thinking longer about it inline. That changes orchestration strategy, not just per-turn
  token spend, so treat `/effort ultracode` as "hand this session a harness," not as a
  five-star `max`. `ultrathink` is a separate, one-off in-prompt keyword for deeper reasoning
  on a single turn — it does not change the session's effort setting or trigger a workflow.

### Effort persists per model, or scoped to one session

Two related changes to how `/effort` remembers its setting:

- v2.1.251, verbatim: "Changed `/effort` to save your default effort level per model, so each
  model keeps its own setting when you switch." Before this, one `/effort` choice applied
  across every model; a deliberate "raise effort on the hard model, leave the cheap one at
  default" split now survives a `/model` switch instead of needing to be re-set each time.
- v2.1.257, verbatim: "Added `s` in `/effort` to change effort for the current session only,
  matching `/model`." Use it for a one-off bump on a single hard turn without changing the
  default that future sessions on that model will pick up.

([v2.1.251](https://github.com/anthropics/claude-code/releases/tag/v2.1.251) and
[v2.1.257](https://github.com/anthropics/claude-code/releases/tag/v2.1.257) release notes.)

## The Cache Cost of Switching Model or Effort Mid-Session

Every model, and on most models every effort level, keeps its own prompt cache. Official docs,
verbatim (Anthropic, [Prompt caching → Actions that invalidate the
cache](https://code.claude.com/docs/en/prompt-caching#actions-that-invalidate-the-cache),
fetched 2026-09-04):

> "Two settings don't appear in the layer table but still affect what stays cached: **Model**:
> each model has its own cache. Switching models recomputes the entire request even when the
> content is identical... **Effort level**: on most models, each effort level has its own
> cache, so changing effort mid-session recomputes the entire request. On Fable 5.1 with an
> API key or a Claude subscription, the cache stays intact by default."

That Fable 5.1 exception is new, and it shipped broken: "Before v2.1.260, changing effort on
Fable 5.1 with an API key or a Claude subscription also invalidated the cache" — the same
release ([v2.1.257](https://github.com/anthropics/claude-code/releases/tag/v2.1.257)) that
shipped Fable 5.1 itself shipped it with that bug, fixed three versions later.

### Setting the cache TTL directly

For API-key and cloud-provider (Bedrock/Vertex/Foundry) users, the cache TTL is also a
configurable setting rather than a fixed default:

- v2.1.243, verbatim: "Added `promptCacheTtl` and `subagentPromptCacheTtl` settings so
  API-key and cloud-provider users can keep a 1-hour prompt cache on the main conversation
  while subagents stay at 5 minutes"
- v2.1.248, verbatim: "Added `experimental.cacheTtl` (`\"5m\"` or `\"1h\"`) to agent
  frontmatter: a per-agent prompt cache TTL used when no subagent TTL setting is configured"

([v2.1.243](https://github.com/anthropics/claude-code/releases/tag/v2.1.243) and
[v2.1.248](https://github.com/anthropics/claude-code/releases/tag/v2.1.248) release notes.)

**Loop engineering read:** a 1-hour cache write costs 2× base input price against a 5-minute
write's 1.25× (the cache-pricing rule quoted above) — so `promptCacheTtl: "1h"` is a bet that
the main conversation will still be warm an hour from now, worth it for a long-running
interactive session but wasted spend on a short-lived subagent. `subagentPromptCacheTtl` sets
that bet session-wide for every subagent; per-agent `experimental.cacheTtl` frontmatter
overrides it for one agent definition specifically, and only applies when no subagent-level TTL
setting is configured. Together they let a fleet keep the main loop's cache warm at 1h while
short-lived worker subagents default to the cheaper 5m write.

**A measured case of that bet losing.** ClaudeWarp recorded a background session that lived **64
seconds**, did zero thinking, and produced 4 output tokens — and still cost $0.2425, of which
$0.2406 was Opus 5. The driver was a **22,659-token 1-hour cache write**: $0.2266 at Opus 5's
$10/MTok 1h rate, or **94% of the session's entire cost**, paid for a cache with 59 minutes of life
left when the session ended. The identical write is **$0.09 on Sonnet 5** and **$0.05 on Haiku 4.5**.

The lesson generalises past the TTL setting. Any short-lived session pays *(system prompt + tool
definitions) × the model's cache-write rate* before doing any work, so **the floor of a fan-out
scales with the model's price, not the task's difficulty**. For short-lived workers the lever is to
*pin a cheaper model*, not to lower effort — effort was already zero here. Full figures and caveats
in [Background Agents § The per-session cost
floor](29-background-agents.md#the-per-session-cost-floor). (Measured by ClaudeWarp
[v0.42.1](https://github.com/lucagattoni/Claude-Warp/releases/tag/v0.42.1); the arithmetic is ours,
and 5.8% of the recorded total is not explained by the published token counts.)

**Consequence for a loop:** switching model or effort mid-run to save money on the harder half
of a task can cost more than it saves, because the next request re-processes the *entire*
conversation history uncached. Two corollaries:

- **Pick model and effort at the top of a session** (or at the top of each subagent spawn) and
  hold them for the run. A DOER→CHECKER handoff that also changes model is not "free
  role-switching" — it is a cache-busting event, on top of whatever the role switch itself
  costs.
- **A judge/adjudicator pass is the exception that doesn't need this warning** — it should
  already run in a fresh context (see [Session Architecture](37-session-architecture.md) and
  [Verification](04-verification.md)), so it pays the uncached first turn regardless of which
  model it runs on. The trap is switching *mid-session*, not spawning a differently-modeled
  pass in its own context.

`/usage` now surfaces this directly rather than leaving it to be inferred: the `Prompt cache
(main)` line reports request count, the percentage of input tokens served from cache, and miss
count with the tokens re-cached by the last miss (Claude Code v2.1.251+). A session with a
persistently low cache-hit percentage and no `/compact`/`/clear` in its history is very likely
switching model or effort somewhere in its loop. (Anthropic, [Costs → Prompt cache
statistics](https://code.claude.com/docs/en/costs#prompt-cache-statistics), fetched
2026-09-04.)

## Confidence-Scheduled Verification

Not every iteration needs a full verification pass. A **confidence-scheduled**
approach skips a verification pass when the maker's own confidence signal is high
enough that the expected value of re-checking is low, and runs it in full when
confidence is low — spending verification compute where it is likely to change the
outcome rather than uniformly on every iteration. This is a budget-allocation
refinement to [Verification](04-verification.md), not a replacement for it: the
default disposition is still "verify," and the schedule only skips the check when a
calibrated confidence signal (not the maker's self-report of correctness — see
[Verifier Theater](17-failure-patterns.md)) crosses a threshold. Framed by the source
as a way to cut wasted GPU compute in long-running agent loops.
(MindStudio, ["Confidence-Scheduled Verification: How DeepSpark Cuts Wasted GPU Compute"](https://www.mindstudio.ai/blog/deepspark-confidence-scheduled-verification-ai-agents/), Jul 2026.)

## Multi-Dimensional Budget Pressure

Rather than one ceiling (e.g. `--max-budget-usd`), track several budget dimensions at once
— tokens, tool calls, wall-time, dollars — and collapse them into a single **pressure**
scalar (the maximum utilization ratio across all four), so the loop degrades gracefully
as *any* dimension approaches its limit rather than only reacting to whichever one happens
to run out first:

| Pressure | Behaviour |
|---|---|
| < 0.7 | Full pipeline runs (Planner → Worker → Critic, all verification passes) |
| > 0.9 | Skip the Critic stage — degrade quality checks before halting entirely |
| = 1.0 | Halt, return partial results |

The design intent stated by the source: budget pressure makes *degradation* deterministic,
not the LLM's own behaviour — the loop's response to running low on any resource is a
designed step function, not an emergent property of the model deciding to wrap up.
Pairs directly with this doc's [Operational Kill/Pause/Slow-Down
Thresholds](#operational-kill-pause-slow-down-thresholds) below, one level down: those
thresholds are inter-run policy (should this loop keep running at all); this is intra-run
degradation (how one run's remaining budget should shape what it still attempts).
([explainx.ai, "Basic Agent Loop to Production Harness"](https://explainx.ai/blog/agent-harness-dag-planner-worker-critic-budget-pressure-2026), Aug 2026.)

## A Concrete Countermeasure to Intent Debt: Ponytail

[Intent debt](17-failure-patterns.md) — an agent silently filling gaps with plausible-
sounding but undocumented decisions — has a measured countermeasure at the
implementation-pattern level. Ponytail is a Claude Code/Codex skill/plugin enforcing a
six-step decision ladder before an agent is allowed to write new code: does it need to
exist at all → is it already in the codebase → does the standard library cover it → is
there a native platform feature → is there an installed dependency → only then write new
code. (Example: a date picker becomes a native HTML `<input type="date">` instead of a
new library dependency.) Benchmarked on 12 feature tasks against a FastAPI template:
**-54% lines of code, -22% tokens, -20% cost, +27% faster execution**, with safety ratings
held at 100% in both runs — the rules explicitly protect validation, error handling,
security, and accessibility work, and only target unnecessary abstractions, wrappers,
config, and dependencies. A rare case of a named overengineering countermeasure with a
same-task, before/after benchmark rather than an anecdote.
([MindStudio, "Ponytail Benchmark"](https://www.mindstudio.ai/blog/ponytail-benchmark-lines-of-code-reduction/), Sep 2026 — plugin by Dietrich Ayala, MIT-licensed.)

## Handle result subtypes

```python
if message.subtype == "error_max_turns":
    # Resume the session with a higher limit
    resume_session(session_id, max_turns=60)
elif message.subtype == "error_max_budget_usd":
    alert("Budget exceeded — review and restart")
```

## Operational Kill / Pause / Slow-Down Thresholds

Define explicit decision rules for three escalation levels before deploying any production loop:

| Signal | Action | Threshold example |
|---|---|---|
| Budget overspend mid-period | **Slow down** — reduce cadence or skip non-urgent runs | Budget >80% consumed before week mid-point |
| High false-positive rate | **Slow down** — human reviews before loop re-runs | False positives >30% of runs in a 7-day window |
| Production incident or schema migration | **Pause** — halt loop until incident resolved | Any active Sev-1 or open migration PR |
| Two consecutive weeks of negative cost-to-value | **Kill** — decommission the loop | 14 days: every run costs more than the defects it catches |
| Consistent loop failures | **Kill** | Loop fails to complete successfully 3+ times per week for 2 weeks |
| Team disengagement | **Kill** | No human has read a loop report in 14 days |

These thresholds are deployment prerequisites, not optional monitoring. Define them before
the first production run — they cannot be calibrated after a runaway event.

([cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering), Jun 2026.)
