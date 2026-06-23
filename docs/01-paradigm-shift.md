# The Paradigm Shift

> Stop writing prompts. Start designing loops.

| Old way | Loop engineering |
|---|---|
| Prompt → wait → review → prompt again | Design the loop once, let it run |
| Tactical, one-shot | Strategic, systemic |
| You are the verification step | The loop verifies itself |
| Session dies when you close your laptop | Loop runs on schedule or event trigger |

The key insight (credited to Boris Cherny, who built Claude Code):
**replace yourself as the person who prompts the agent**.

See [The Factory Model](26-factory-model.md) for the deeper treatment: what the
engineer's role becomes once implementation speed is no longer the bottleneck.

## AI Leverage Formula

> AI Leverage = Your Skill × Your Clarity

Where **Clarity** is your ability to articulate exactly what "done" looks like.

| Low clarity | High clarity |
|---|---|
| "Make the auth better" | "Fix the token refresh race condition described in ISSUE-42" |
| Produces plausible-looking output | Produces verifiable, targeted output |
| No stopping condition | The loop knows when to stop |

The formula implies two things:
1. **You cannot outsource clarity** — an agent given a vague brief produces vague work
2. **Skill multiplies clarity** — a skilled engineer's precise spec produces exponentially better output than a non-engineer's vague spec, even with the same model

(Sabrina Ramonov, "AI Loop Engineering", Jun 2026.)

## The New Software Lifecycle

AI agents have collapsed implementation speed. This changes where engineering
effort concentrates:

| Old bottleneck | New bottleneck |
|---|---|
| Writing the code | Writing the spec |
| Implementation speed | Specification quality |
| Debugging your own code | Verifying agent output |
| Tool expertise | Harness design |

Engineers who thrive are those who excel at thinking at the right level of abstraction,
specifying work precisely, and verifying output rigorously — not those who type fastest.

The harness and the spec are now first-class engineering artefacts. "Vibe coding"
(accepting plausible-looking output without verification) is the new technical debt.
(Addy Osmani, "The New Software Lifecycle", Jun 2026.)
