# Context Engineering vs. Loop Engineering

An emerging debate in the AI coding community (surfaced Jun 2026) about which layer of the system
deserves the most engineering attention.

---

## The positions

**Loop engineering is primary** (Cherny / Osmani view):
The architecture of the loop — when it fires, what it monitors, how it verifies, when it stops —
is the fundamental shift. Get the loop right and the prompts inside it are a detail.

**Context engineering is primary** ([@techtasium](https://x.com/techtasium) and others):
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

## A second debate: loops vs. graphs (Jul 2026)

A month after the framing above became common vocabulary, a louder debate broke out over the
KB's own central metaphor — the loop itself.

On 2026-07-18, [Peter Steinberger](https://x.com/steipete) — the developer behind OpenClaw —
posted a single line that, per X's own view count as reported by the outlet that tracked the
discourse, was seen by 3.1 million people:

> "Are we still talking loops or did we shift to graphs yet?"
>
> — Peter Steinberger, [@steipete](https://x.com/steipete/status/2078277297791189132), 2026-07-18

Neither this nor the companion piece it triggered — Hamel Husain's X article "Loop Engineering
Is Dead. Enter Graph Engineering," posted the same day — was a serious technical argument.
"Neither founding post was serious," the outlet that later analysed the thread reports, quoting
[Louis-François Bouchard](https://x.com/Whats_AI): "my whole feed decided we have a new
discipline. To be honest, both tweets were jokes." But the joke landed on a real fault line and
triggered weeks of "loop engineering is dead, graph engineering is next" commentary through
August 2026, including dedicated write-ups from
[Carlos E. Perez / Intuition Machine](https://medium.com/intuitionmachine/from-loop-engineering-to-graph-engineering-d3ebeb08511c)
and [AI Builder Club](https://www.aibuilderclub.com/blog/graph-engineering-vs-loop-engineering).

### The graph position, stated fairly

The strongest version of the challenge is not "loops are wrong." It is that a loop is one
control-flow shape, and it is the wrong one whenever work has genuinely independent parts.
[David Khourshid](https://x.com/DavidKPiano), creator of the state-machine library XState, made
the formal version of the point:

> "Surprise… loops are graphs: directed, cyclic ones."
>
> — David Khourshid, quoted in [WEC Docs, *Loop Engineering, Graph Engineering: What Survives*](https://wec.wiline.com/docs/news/loop-engineering-graph-engineering-what-survives/), 2026-08-05

A DAG (directed acyclic graph) makes dependency explicit — which step needs which other step's
output, and which steps have no dependency on each other at all — and that is information a
single sequential loop discards. [AI Builder Club](https://www.aibuilderclub.com/blog/graph-engineering-vs-loop-engineering)
states the practical trigger for reaching past a loop:

> "You reach for a graph only when a single loop is genuinely straining — roughly, when the
> work splits into distinct specialties, needs parallel-then-join, wants different models or
> tools per step, or needs auditable control flow."
>
> — [AI Builder Club, *Graph Engineering vs Loop Engineering*](https://www.aibuilderclub.com/blog/graph-engineering-vs-loop-engineering)

That is a real challenge to this KB's central metaphor: [The Core Agent Loop Cycle](02-agent-loop-cycle.md)
describes one shape — observe → act → verify → repeat — and independent work that could run
concurrently instead waits its turn inside it.

### Where each is the better frame

| | Loop | Graph / DAG |
|---|---|---|
| Work shape | Sequential — each step depends on the last | Branching — some steps depend on others, some don't |
| What it optimizes | Convergence on one thread of work | Concurrency — parallel legs joining at a merge point |
| Stop condition | One stopping condition for the whole cycle | Per-node exit gates; the graph as a whole may have none |
| Failure mode it invites | Serializing work that didn't need to be serial | Coordination overhead between nodes — the "telephone game" handoff cost documented in [Session Architecture](37-session-architecture.md) |
| Right call when | The task is genuinely one thread: discover → plan → execute → verify → retry | The task decomposes into distinct specialties, parallel-then-join work, or steps needing different tools/models |

### The synthesis

The debate mostly resolves the way [Harrison Chase](https://x.com/hwchase17) (LangChain) framed
it — not as a rivalry but as containment:

> "Loops are simple graphs. Loop engineering isn't an alternative to graphs, so much as a simple
> version of them."
>
> — Harrison Chase, quoted in [WEC Docs, *Loop Engineering, Graph Engineering: What Survives*](https://wec.wiline.com/docs/news/loop-engineering-graph-engineering-what-survives/), 2026-08-05

And Eric Osiu's formulation names what each layer is actually for:

> "Graph is the rails. Loop is the motor. Rails keep you from crashing. The motor is what
> actually moves."
>
> — Eric Osiu, quoted in [WEC Docs, *Loop Engineering, Graph Engineering: What Survives*](https://wec.wiline.com/docs/news/loop-engineering-graph-engineering-what-survives/), 2026-08-05

A graph of steps and a loop around the graph are not exclusive, and this KB already documents
the composition. [Task-Shaped DAG Orchestration](24-harness-patterns.md#task-shaped-dag-orchestration)
builds a per-issue DAG — a single node for a simple fix, parallel research and implementation
legs for a complex feature — where **every node still runs its own act → check → close cycle**:
a loop at each node, inside a graph shaped by dependency rather than by a fixed role count. The
graph decides what can run concurrently; the loop inside each node decides when that piece of
work is done.

### Is "Graph Engineering" a named discipline?

Contested, and younger than the other four. It traces to a joke, not a consolidation piece —
unlike Cobus Greyling's June 2026 article below, no single source has yet folded it into that
same taxonomy. But independent of the joke's origin, multiple publishers now maintain dedicated
guides that define it as a practice with its own vocabulary (nodes, edges, shared state,
fan-out/fan-in) rather than just reacting to Steinberger's post — including
[AI Builder Club's *Graph Engineering Guide (2026)*](https://www.aibuilderclub.com/blog/graph-engineering-guide-2026)
alongside its existing *Loop Engineering Guide*, and
[explainx.ai's *Graph Engineering* guide](https://explainx.ai/blog/graph-engineering-ai-agents-multi-agent-organizations-2026).
That is enough independent, sustained use to list it below — but treat it as newer and less
settled than the four Greyling named.

---

## The four disciplines (2026 vocabulary consolidation)

As of mid-2026 the community has consolidated around four named engineering disciplines
(Cobus Greyling, "The Evolving Vocabulary of AI", Jun 2026):

| Discipline | Focus |
|---|---|
| **Loop Engineering** | The system that runs the agent: triggers, stopping conditions, verification, harness |
| **Context Engineering** | What the agent sees at each turn: files, instructions, memory, task state |
| **Harness Engineering** | The scaffolding around the agent: prompts, tools, sandboxes, feedback loops |
| **Fleet Engineering** | Managing many agents at enterprise scale: governance, observability, routing |
| **Graph Engineering** *(post-Jul 2026, not part of Greyling's original consolidation — see above)* | Wiring multiple agents or steps into a DAG: nodes, edges, shared state, fan-out/fan-in |

These are not competing disciplines — they compose. A well-designed agentic system
requires deliberate engineering at all four (now arguably five) levels.

---

## Related

- [The Core Agent Loop Cycle](02-agent-loop-cycle.md)
- [Context Management](13-context-management.md)
- [CLAUDE.md](05-claude-md.md)
- [Memory Patterns](16-memory-patterns.md)
- [Harness Patterns](24-harness-patterns.md) — Task-Shaped DAG Orchestration, where a graph and a loop compose
- [Session Architecture](37-session-architecture.md) — the coordination-overhead cost graphs of agents share
