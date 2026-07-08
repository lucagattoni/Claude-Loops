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
