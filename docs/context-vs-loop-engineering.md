# Context Engineering vs. Loop Engineering

An emerging debate in the AI coding community (surfaced Jun 2026) about which layer of the system
deserves the most engineering attention.

---

## The positions

**Loop engineering is primary** (Cherny / Osmani view):
The architecture of the loop — when it fires, what it monitors, how it verifies, when it stops —
is the fundamental shift. Get the loop right and the prompts inside it are a detail.

**Context engineering is primary** (@techtasium and others):
What you put *into* the agent at each step — the right files, the right instructions, the right
memory — determines output quality more than any loop structure. A well-contextualised one-shot
beats a poorly-contextualised loop.

---

## Why both matter

The debate is partly definitional. In practice:

- **Loop engineering** determines *when* and *what* gets run — it's the system-level concern.
- **Context engineering** determines *how well* each turn goes — it's the per-invocation concern.

They compose: a loop that fires correctly but feeds the agent a context window full of irrelevant
code will produce poor results. A perfectly crafted context with no loop is still manual work.

The more useful frame: context engineering is one of the most important *inputs* to loop
engineering, not a competitor to it.

---

## Practical implication

When debugging a failing loop:
1. First check the loop structure (stopping condition, trigger, verification step).
2. Then check the context — what is the agent actually seeing at decision time?
   Wrong files in context, stale CLAUDE.md, or missing task state are the most common causes
   of loops that run correctly but produce wrong outputs.

---

## Related

- [The Core Agent Loop Cycle](agent-loop-cycle.md)
- [Context Management](context-management.md)
- [CLAUDE.md](claude-md.md)
- [Memory Patterns](memory-patterns.md)
