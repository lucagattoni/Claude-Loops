# The Factory Model

The factory model describes the transformation of the engineering role from
**writing code** to **orchestrating agent factories** — systems where AI agents
are the workers and engineers are the production managers.

## The Shift in Bottlenecks

AI agents have collapsed implementation speed. The new engineering bottlenecks are:

- **Specification quality** — poorly specified work produces plausible-looking but
  wrong output. The agent cannot ask clarifying questions mid-task; ambiguity in
  the spec becomes defects in the output.
- **Architectural thinking** — designing which agents do what, in which order,
  with what handoffs, and what verification gates between them
- **Output verification** — confirming the agent's output is actually correct,
  not just plausible-looking

Engineers who thrive in this model excel at thinking at the right level of abstraction
and verifying output rigorously — not at typing fast.

## The Manager Analogy

Factory model engineers think like engineering managers:
- Write precise specs before delegating
- Design the workflow, not just the task
- Verify output at each stage before handing it to the next agent

"My job is to write loops" (Boris Cherny) is the factory model expressed in one
sentence: the engineer's output is the production system, not the individual work
product.

## Practical Signals

You are operating in factory-model territory when:
- A task takes < 1 hour of agent time but > 1 hour of spec-writing time
- You have more than one agent running in parallel on sub-tasks of the same goal
- The bottleneck on your velocity is review bandwidth, not implementation bandwidth
- You are writing `PLAN.md` files more often than you are writing functions

## Relationship to Other Concepts

- [Loop Contract](loop-contract.md) — the factory spec: what the loop is allowed to do and when it stops
- [Harness Patterns](harness-patterns.md) — the factory floor: how the workers are orchestrated
- [Verification](verification.md) — quality control: how finished work is checked before shipping
