# Human-in-the-Loop Escalation

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

## Where to Place a Checkpoint

The question is not *whether* to keep a human in the loop but *where*. Apply four tests
to each step; a "yes" argues for a checkpoint there:

| Test | Ask | Checkpoint when |
|---|---|---|
| **Irreversibility** | If this output is wrong and not caught immediately, how hard is it to fix? | Hard to undo (send customer email) — not internal CRM tags |
| **Confidence threshold** | Does this input type produce unreliable output? | Agent should flag its own low-confidence outputs for review |
| **External visibility** | Does the action leave your internal systems? | Customer-facing email, published content, outbound API call |
| **Context gap** | Does tacit human context materially change the decision? | Relationship history / account context the agent lacks |

**Place two to three well-placed checkpoints, not many** — target roughly an **80/20
split**: ~80% of cases handled autonomously, ~20% routed to a human. Too many
checkpoints recreate the bottleneck loops were meant to remove.

**Calibrate with the override rate.** Measure how often a reviewer actually changes
something at each checkpoint. "If reviewers are approving everything without changes 95%
of the time, the checkpoint is probably unnecessary" — move or remove it. A good
checkpoint is one where reviewers *frequently catch something meaningful*; track what
gets flagged and what reviewers change to tune placement empirically rather than by
assumption.

(MindStudio, ["Human-in-the-Loop Checkpoints for AI Agents"](https://www.mindstudio.ai/blog/human-in-the-loop-checkpoints-ai-agents), Jun 2026.)

## When the Checkpoint Has a Timeout

The four tests above decide *where* a checkpoint goes. A fifth decision is easy to skip:
what happens if nobody answers in time.

**A timeout on an approval gate converts it into an unattended gate whenever the default
is to continue.** The loop still asks the question and still pauses, so it looks like a
checkpoint — but if silence means "proceed," the gate has become a fixed delay before the
same unreviewed action, not a control on it.

**Worked example.** Claude Code's `AskUserQuestion` tool was changed to auto-continue after
60 seconds of no input instead of blocking indefinitely. The change shipped **unannounced** —
no changelog entry — and practitioners discovered it in production. Anthropic then reverted
the default, in `2.1.200`: *"Changed `AskUserQuestion` dialogs to no longer auto-continue by
default; opt into an idle timeout via `/config`."*

No public source names the version that introduced the behaviour, which is itself the point:
the reversal is in the changelog and the introduction is not. The thread drew 142 points and 127 comments
on Hacker News ([Hacker News, "Claude Code: Anatomy of a Misfeature"](https://news.ycombinator.com/item?id=48947776),
Jul 2026; article at [olafalders.com](https://www.olafalders.com/2026/07/17/claude-code-anatomy-of-a-misfeature/)).

The Anthropic engineer responsible for the change acknowledged the process failure
in-thread:

> "the rollout should have been opt-in (like it is now) and on the Changelog."

A practitioner objected to the 60-second window itself, independently of how it shipped:

> "How can I possibly provide any kind of informed answer in under 60 seconds? I can barely
> read some of its context for a question in 60 seconds!"

The two objections are distinct and both real: one is a process failure (an undocumented
default change), the other is a design failure (60 seconds is not enough time for an
informed answer to most questions worth interrupting a human for). A checkpoint that
fails on either axis has stopped functioning as a checkpoint.

**Design rule.** State what happens on timeout as part of the checkpoint's definition,
not as an implementation detail decided later:
- Does the checkpoint block indefinitely, or does it time out?
- If it times out, does the default action on silence continue the loop, or block it?
- Is that default consistent with what the Irreversibility test (above) already said
  about this action?

**Prefer default-block over default-continue wherever the action is not trivially
reversible.** A checkpoint on an irreversible action (a push to main, a cost overrun)
that silently defaults to "continue" on timeout provides no real protection — it adds a
delay before the unreviewed action happens anyway. Where a genuine liveness problem
exists (a long-running job that must not deadlock on an absent reviewer), fix it with a
timeout tuned to actual review effort, an escalation to a second reviewer, or a queued
retry — not a short default-continue timeout on a decision the checkpoint exists
precisely because it was not safe to make unreviewed.

This is one instance of the broader [Silent Default Drift](17-failure-patterns.md)
pattern: the gate was correct when the loop was designed, and it degraded without anyone
touching the loop's own configuration.

## The Three Feedback Loops

Human-in-the-loop is not one checkpoint — it is the **middle of three nested feedback
loops that run at different cadences** in AI-powered product development:

| Loop | Who closes it | Cadence | What it corrects |
|---|---|---|---|
| **Agentic coding loop** | The agent itself | Every few minutes (build + test a new version) | Code-level correctness |
| **Developer feedback loop** | The human engineer | Tens of minutes to hours (reviews the product) | Direction, judgment, taste |
| **External feedback loop** | End users | Days+ (usage data) | Whether the product is the right one |

> "Closing the loop" is what lets "coding agents work longer productively without
> human intervention."

The faster the inner loop closes on its own (verifiable checks, see [Verification](04-verification.md)),
the less often the human loop must fire — but the human loop never disappears, because
of the **context advantage**: the human understands user needs better than current AI
systems do. The engineer's job shifts from writing code to *holding the context the
agent lacks* and steering at the cadence the agent cannot self-correct.

This complements the [Inner/Outer Dual Loop](25-long-running-agents.md#innerouter-dual-loop):
the dual loop nests *execution inside strategy*; the three feedback loops nest
*agent inside developer inside user* by who provides the correcting signal.

(Andrew Ng, ["Loop Engineering for 0-to-1 Product Development"](https://info.deeplearning.ai/a-new-generation-studies-ai-apples-recipe-for-on-device-models-glm5.2-tackles-open-ended-problems-1), The Batch, Jun 2026.)

## Who Interrupts Whom, More Often

A first-party analysis of Claude Code/API traffic found that **Claude asks for
clarification more than twice as often as humans interrupt it** mid-task. Read
against the checkpoint-placement guidance above, this cuts against the intuition
that autonomous loops mainly fail by over-reaching without asking — in practice the
more common friction is the model pausing for input at a rate that itself needs
tuning. This argues for calibrating checkpoint *sensitivity* symmetrically: the
80/20 target above is not just about adding enough human checkpoints, it is equally
about not over-provisioning the model's own clarification triggers past the point
where they start recreating the bottleneck loops were meant to remove.
(Anthropic Research, ["Measuring agent autonomy"](https://www.anthropic.com/research/measuring-agent-autonomy), Jul 2026.)
