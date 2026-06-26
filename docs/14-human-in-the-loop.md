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
