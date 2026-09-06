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

### The debate continues (Sep 2026) — cost, control theory, and a maturity ladder

Seven weeks after Steinberger's joke, the debate had not settled — it deepened into four
independent, non-joke arguments, each landing at a different point in this doc's own analysis.

**Karpathy names loop as an intermediate stage, not an alternative.** A Stanford lecture
positions the field's progression as LLM → Prompt → Agent → **Loop** → Graph, roughly
mapped to 10/30/50/70/100% autonomy. Read against the table above, this corroborates rather
than contests it: loop is where a single thread of work matures to reliable autonomy; graph
is what you reach for once that thread needs to split.
([@TechWithLilyAi](https://x.com/TechWithLilyAi/status/2096177729163215080), Sep 2026.)

**The strongest new argument is a cost claim, not a capability claim.** Most of the graph
case (this doc, above) argues graphs *can do more* — parallel legs, per-node tooling. Rubén
Domínguez's retrospective on the whole 41-day cycle argues the opposite failure mode is
underweighted: **parallel review graphs often cost *more* than the sequential loop they
replace**, because running N reviewers in parallel is not free just because it's concurrent —
it's N times the review cost, paid whether or not the reviewers disagree. He also names why
that spend frequently buys less than it appears to: **same-model parallel reviewers are
correlated, not independent** — "a chorus, not an ensemble" — so three GPT-5.6 reviewers in
parallel can share the same blind spot the way three microphones on one melody don't add
information. He credits the real turning point not to Steinberger's post but to Anthropic's
May 2026 dynamic-workflows preview (a model-authored JS script orchestrates subagents so only
the final result re-enters context — see [Dynamic Workflow Patterns](24-harness-patterns.md#dynamic-workflow-patterns-anthropic-engineering)),
and recommends at least one **non-probabilistic node** (a compiler, type-checker, or test run)
on every critical verification path — a concrete design rule, not just a caution. This is the
same finding as [Verification's cross-model independence](04-verification.md#verifier-integrity-keeping-the-check-unfakeable),
now with a cost argument attached: independence is not just more *effective*, correlated
reviewers are also a worse trade *per dollar* than a single well-verified pass.
([LinkedIn — Rubén Domínguez Ibar](https://www.linkedin.com/pulse/forget-loop-engineering-its-all-graph-now-rub%C3%A9n-dom%C3%ADnguez-ibar-2cyzf/), Sep 2026.)

**A control-theory reframing gives the failure modes this KB already names a shared
vocabulary.** Rajesh Kavasseri maps the generate → evaluate → revise → repeat loop onto
classical closed-loop feedback control, and reframes agent failure modes as textbook control
pathologies: oscillation (the loop's own [Verdict oscillation](17-failure-patterns.md) is
literally a control-theory oscillation — a system overshooting and overcorrecting around a
setpoint it never settles on), steady-state error (a persistent gap between output and goal
that more iterations don't close), coupled control channels (fixing one property destabilises
another), and poor observability/controllability (you cannot correct what you cannot measure
or influence). His sharpest line: `--max-rounds` is a **circuit breaker, not a convergence
guarantee** — a hard iteration cap stops a runaway, but nothing about capping iterations
implies the loop was converging toward the goal in the first place. See
[Failure Patterns](17-failure-patterns.md) for where this vocabulary now applies directly.
([LinkedIn — Rajesh Kavasseri](https://www.linkedin.com/pulse/loop-engineering-control-theory-marketing-budget-rajesh-kavasseri-r6v6c/), Sep 2026.)

**A skeptic view, for balance.** Not every voice treats the debate as substantive: "loop
engineering is just bro code for 'we're making it up as we go'" is a live dissent worth
recording alongside the pro-loop-engineering material this doc otherwise curates — the naming
churn (loop → graph → whatever comes next) is itself evidence for the skeptic's point, even
if the underlying design questions (SCOPE/ACTION/TRIGGER/BUDGET/STOP) are real regardless of
what the discipline is called this quarter. ([@thiagoTF](https://x.com/thiagoTF/status/2096165836348158464), Sep 2026.)

**Academic corroboration of the three-way split.** A cloud-engineering paper independently
converges on the same three-way distinction this doc's four/five-discipline table draws —
separating **graph engineering** (workflow progression), **loop engineering**
(diagnosis/repair), and **harness engineering** (zero-trust execution) as orthogonal concerns
for autonomous cloud agents, rather than competing framings of one thing.
([arXiv 2609.00050](https://arxiv.org/abs/2609.00050), Aug 2026.) Google has separately been
reported proposing "Graph Engineering" as a higher-level concept for coordinating multiple
connected agents, distinct from handling any one agent's Loop or Harness — another
independent publisher treating the term as a practice rather than a joke's residue, adding to
the two guides already cited below.
([@peaceandwhisky](https://x.com/peaceandwhisky/status/2096167196200439901), Sep 2026.)
A second cloud-engineering paper, published a week later, makes the identical three-way
split part of its own architecture rather than just naming it: a Graph Orchestrator
coordinates repo generation/review/execution/verification/release/monitoring agents, gates
lifecycle transitions on verifiable execution evidence, and separately constrains
repo-generation/review/repair via "agent harness engineering" — the same three disciplines
as orthogonal concerns, now appearing in two independent papers three weeks apart rather
than one.
([arXiv 2608.29615, "Forward-Deployed Full-Stack Engineering for Autonomous Cloud MLOps"](https://arxiv.org/abs/2608.29615), Aug 2026.)

**A practical decision rule for when to reach past a loop.** Untangling the debate from a
different angle — separating *knowledge graphs* (a data structure), *graph-orchestration*
(LangGraph-style explicit control flow), and *loops* (Claude Code/Codex-style
prompt→act→observe→repeat) as three distinct things colliding under one name —
explainx.ai proposes a concrete test: *"does my workflow have more than a handful of
branching states that need independent inspection and resumability? If yes, graph; if no,
loop."* Harrison Chase (LangChain's creator) is quoted making the same point this doc
already documents from a different angle: *"So i didn't really know what graph
engineering is, and i still don't really… but it's basically just langgraph?"*
([explainx.ai, "Graphs vs. Loops"](https://explainx.ai/blog/graphs-vs-loops-agentic-ai-debate-linear-andrew-ng-2026), Jul 2026.)

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

A separate essay traces the same churn as a naming *progression*, not a rivalry:
harness → loop → graph, each new term arriving once the previous abstraction's bottleneck
had been solved. Its account of what graphs specifically add is worth stating alongside
the synthesis above — graphs separate **topology** (versioned, reviewed like a schema)
from **prompts** (treated like queries against that topology), which clarifies which
architectural constraints are load-bearing (the topology) versus temporary implementation
detail (this quarter's prompt wording).
([ikangai.com, "Graph Engineering Is Harness Engineering With a Diff"](https://ikangai.com/graph-engineering-is-harness-engineering-with-a-diff/), Sep 2026.)

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
