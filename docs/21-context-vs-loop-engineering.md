# Context Engineering vs. Loop Engineering

An emerging debate in the AI coding community (surfaced Jun 2026) about which layer of the system
deserves the most engineering attention.

---

## The positions

**Loop engineering is primary** ([Boris Cherny](https://www.youtube.com/watch?v=RkQQ7WEor7w&t=11m45s) / [Addy Osmani](https://addyosmani.com/blog/loop-engineering/) view):
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

**The earliest academic source, predating both papers below.** A 35-author arXiv paper
proposes "Graph Engineering" for multi-agent LLM systems explicitly aimed at
system-level intelligence rather than single-agent capability — chronologically the first
academic treatment of the term this KB has found, ahead of the two cloud-engineering papers
that independently reach the same three-way split below. Its scale (35 authors) is itself
evidence the term had moved from social-media joke to a framing multiple research groups
were independently willing to co-author.
([arXiv 2608.21156, "Graph Engineering in the Era of LLM Agents"](https://arxiv.org/abs/2608.21156), Aug 2026.)

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
as orthogonal concerns, now appearing in two independent papers three weeks apart rather than one, with the 35-author graph-engineering paper above as an earlier precursor that names only the graph layer.
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

**A diagnostic test for which layer a failure belongs to.** A separate five-layer framing —
Prompts → Context → Harness → Loops → Graphs — pairs the stack with a practical debugging
question: when something goes wrong, ask which layer the failure actually belongs to before
reaching for a fix at a different one (a bad prompt fixed by adding more orchestration, or a
harness gap papered over with a better prompt, both treat the wrong layer). Notable as an
independent primary-source use of this KB's own "Loop Engineering" / "Harness Engineering"
vocabulary — the author's own paid course names layer 4 "Loop Engineering" and layer 3
"Harness Engineering" without reference to this KB.
([@hanakoxbt](https://x.com/hanakoxbt/status/2096710886782386540), Sep 2026.)

**First official cloud-vendor use, in production marketing rather than a report about the
term.** Distinct from the secondhand Graph Engineering report above: Google Cloud's Indonesia
account posted, in Indonesian, "Building a loop engineering project? Avoid common pitfalls
like ballooning token costs & unverified autonomy!", linking a YouTube explainer titled "4
ways loop engineering fails (and how to fix them)" and a "Loop Engineering Codelab." The
codelab link resolves to a live, real Google Codelabs page ("Table for N: eval as the gate,
evolution as the loop," `codelabs.developers.google.com`) built on Google's ADK,
self-evolving via `adk optimize` (GEPA) — independent corroboration the campaign points at
real technical content, not a dead or placeholder link. One caveat: the codelab page itself
never uses the phrase "loop engineering," and its authorship metadata does not resolve to a
confirmed Google Cloud DevRel byline — the vendor-terminology claim rests on the tweet and
video title, not the codelab's own text. ([Google Cloud Indonesia, X post](https://x.com/GoogleCloud_ID/status/2097505270783983647), Sep 2026; codelab at [g.dev/cloud/loop-lab-table](https://g.dev/cloud/loop-lab-table).)

### The convergence continues (late Sep 2026) — a LinkedIn wave, and a real production loop among it

A single sweep this run surfaced roughly a dozen LinkedIn posts and a dozen X posts
independently converging on the same harness/loop/graph vocabulary this section already
tracks — evidence of continued diffusion, not a new claim. Two are worth citing directly
rather than folding into the count. **The strongest single find**: a real, running
production loop, not just a framing post — Rust `clippy` fixes proposed via GitLab MRs on
an NVIDIA DGX Spark sandbox, with a `state.json` checkpoint/resume, worktree restoration,
and a CI regression gate, reporting **27 merges** to a lint-free codebase. Its own framing
positions Loop Engineering as a subdiscipline of Harness Engineering — consistent with this
doc's four-discipline consolidation below rather than competing with it.
([LinkedIn — Halldor Fannar, Sr. Director at NVIDIA, "Loop Engineering"](https://www.linkedin.com/pulse/loop-engineering-halldor-fannar-acgzc/), Jul 2026.) A second post
states the same three-way harness/loop/graph split this doc already documents almost
verbatim — "Harness: can it operate (environment). Loop: can it improve (feedback — loop on
evidence not confidence). Graph: can the process be controlled (flow/branching/approvals)" —
independently arrived at, with a diagnostic checklist per layer for triaging which one a
given failure belongs to, the same move as the five-layer framing above.
([LinkedIn — Steve Nouri, "Harness vs Loop vs Graph engineering"](https://www.linkedin.com/pulse/harness-vs-loop-graph-engineering-your-transformation-steve-nouri-aaqnc/), Aug 2026.)

The rest of the wave corroborates diffusion without adding a new mechanism: a six-step loop
lifecycle citing Claude Code, Codex CLI, Hermes, OpenClaw and OpenAI Agents as all
implementing the same core loop ([LinkedIn — Zahiruddin Tavargere](https://www.linkedin.com/pulse/every-ai-agent-runs-loop-most-engineers-dont-know-tavargere-x8cec/), Aug 2026); a
prompt→context→loop progression framing Claude Code's core as "a simple while-loop that
calls the model, runs tools, and repeats" ([LinkedIn — Nakul Goyal](https://www.linkedin.com/pulse/prompt-engineering-context-loop-nakul-goyal-znwdc/), Jul 2026); a four-loop
framework (Do / Check / Run-when-work-arrives / Improve-the-system) explicit that human
approval can sit inside every stage ([LinkedIn — Maryam Miradi](https://www.linkedin.com/search/results/content/?keywords=%22loop%20engineering%22), Sep 2026); and an
architecture diagram placing a "Loop Engineering" sub-box at the retry/replan stage of an
Agent Harness wrapping an Execution Graph ([LinkedIn — Pallavi Singh](https://www.linkedin.com/search/results/content/?keywords=%22loop%20engineering%22), Sep 2026). A
further ~12-post batch carries quantified practitioner claims (a harness-pairing accuracy
lift, an enterprise-agent-project failure rate, a no-harness-vs-full-harness cost
comparison) that are **not** independently verified against a primary source here — treat
as reported claims from the practitioner cluster, not confirmed figures, before citing any
specific number from it. On X, a numbered "Harness Engineering" series
([@its_meseba](https://x.com/its_meseba/status/2104472784218792133), Sep 2026), a Chinese-language
course lecture titled "Loop Engineering" inside a broader harness-engineering curriculum
([@Leexiaopa](https://x.com/Leexiaopa/status/2104490517149241841), Sep 2026), and a 2-hour Andrew Ng
course thread with timestamped "loop engineering" and "graph engineering" chapters
([@snskritinaruka](https://x.com/snskritinaruka/status/2104479140841767378), Sep 2026) show the same
vocabulary now stable enough to anchor course curricula, not just single posts.

### The vocabulary is now being formalised and contested (Oct 2026)

A mid-October LinkedIn sweep shows the terms moving from slogans to attempts at definition,
and being pushed back on. All items below are practitioner posts; none is independently
verified beyond what is noted.

- **A shared anatomy.** One synthesis gives a loop six parts — trigger, stop condition, state,
  verifier, limits, escalation — and argues the verifier should be designed first because a loop
  satisfies the written gate, not the goal ([LinkedIn — Desai, "Loop Engineering: The 6-Part System…"](https://www.linkedin.com/pulse/loop-engineering-6-part-system-behind-ai-agents-work-while-desai-2gaaf/)).
  It maps onto the [Loop Contract](27-loop-contract.md) (TRIGGER / STOP / BUDGET plus verifier)
  with state and escalation made explicit. A second essay defines the loop as running until a
  verifier, not the agent itself, says the goal is met, and adds that the costly failure is an
  agent forgetting what the previous lap learned, so carry-over memory is a loop-design question
  ([LinkedIn — Padmanabhan, "Recursive Self-Improvement Starts in Context"](https://www.linkedin.com/pulse/recursive-self-improvement-starts-context-padmanabhan-v-lylrf/), 2026-09-25).
- **A formalisation.** Another post writes the loop as Action(t) → Observation(t) → Evaluation(t) →
  Action(t+1) with an evaluator V and a target score q* ([LinkedIn — Chakraborty, "From Prompt
  Engineering to Loop Engineering: A Mathematical Framework…"](https://www.linkedin.com/pulse/from-prompt-engineering-loop-mathematical-framework-ai-chakraborty-fvnhe/)).
  This post and the six-part synthesis both cite an empirical study; the primary source is
  [Lulla et al., arXiv 2608.21884](https://arxiv.org/abs/2608.21884) (Aug 2026, under review),
  whose abstract reports confirming autonomous agent loops in 217 of the 256 repositories its
  heuristics matched out of 36,710 mined, with almost none committing the state files the
  discourse prescribes — see [Loop Maturity Model](20-loop-maturity-model.md).
- **Spread beyond code, and its first pushback.** A go-to-market post applies the pattern to
  sales/marketing agents (trigger, context enrichment, action, grader evaluation, feedback that
  updates prompts and scoring) ([LinkedIn — Alex Lindahl](https://www.linkedin.com/in/alexlindahl/), a profile page rather than a post; on 2026-10-19 the post could not be re-found there, so this description is the search stage's summary and is unconfirmed);
  a counterpoint post says GTM teams keep adding context, connected systems and feedback loops
  but things break once agents are given real autonomy (only the opening was read, so the failure
  argument itself is not captured). Treat the pair as evidence of use outside coding and of an
  unresolved autonomy question, not as a result.
- **Academia versus practice.** A Tampere professor's summary of a review of 114 sources on LLM
  multi-agent code generation (74 peer-reviewed, 40 industry; only 15 percent of the industry
  sources used any benchmark, and 2 of 114 used a security benchmark) says practitioners now
  call the surrounding discipline harness engineering and loop engineering — the vocabulary
  here is practitioner-led and mostly unmeasured ([LinkedIn — a Tampere professor relaying Rasheed et al.](https://www.linkedin.com/in/profabrahamsson/);
  the figures are the post's summary of the review; the 15 percent figure could not be traced in the review itself on 2026-10-19, so treat it as unverified).
- **Terminology critique.** One essay applies a replace-the-new-word-with-the-old-one test and
  argues "harness" is partly a rename of the older test and benchmarking harness while the core
  idea — a designed environment around the model — is genuinely new ([LinkedIn — Trivedi, "Harness Is Not Everything Minus the Model"](https://www.linkedin.com/pulse/harness-everything-minus-model-hasit-trivedi-cjthf/); opening only). Another defines the harness
  as the software that calls the model, exposes tools, manages task state and decides when work may
  continue or must stop, illustrating it with a retry after a dropped connection in which an agent
  re-creates a workspace and repeats assignments — an idempotency and resumable-state point
  ([LinkedIn — Tadros](https://www.linkedin.com/pulse/harness-engineering-reliable-ai-agents-hany-tadros-acn6c/); opening only).
- **Verifier independence.** One essay argues the bottleneck moves to the outer loop (verify, ship,
  operate, learn) and that automating it unchanged fails because the independence between author,
  test-writer and reviewer disappears when one model interprets the ticket, writes the code and
  writes the tests ([LinkedIn — Puneet Singh, "The Great Compression of Software Engineering"](https://www.linkedin.com/pulse/great-compression-software-engineering-puneet-singh-cfpme/);
  opening only) — the same argument as [Verification](04-verification.md)'s fresh-reviewer rule.
- **Curricula.** The Daily Dose of DS AI-agents course defines harness engineering as engineering
  the execution environment and policies around an agent loop, implemented as LangChain middleware
  ([Part 3](https://www.dailydoseofds.com/ai-agents-with-langgraph-course-part-3-with-implementation/)),
  and its Part 4 argues the default loop hands the stop decision to the model so "done" is claimed,
  not established ([Part 4](https://www.dailydoseofds.com/ai-agents-with-langgraph-course-part-4-with-implementation/)). Both are paywalled beyond
  the introduction, and the series features a product (Jev) that this KB's tracker flags as a likely sponsor push,
  so read the framing as vendor-adjacent.

One counter-thesis is worth recording at low confidence: the episode outline for a Lenny's
Newsletter interview with OpenAI's head of ChatGPT and Codex lists "Why loops, graphs, and
fine-tuning agent workflows are a passing phase" as a topic ([Lenny's Newsletter](https://www.lennysnewsletter.com/p/openais-head-of-chatgpt-were-entering)).
The post is paywalled and only that outline was readable, so the argument itself is unverified.

### Discourse snapshot, 2026-10-19

Dated posts and talks from the three weeks to 2026-10-19, each opened at its source (translations from Chinese
are mine). They date and test the vocabulary; none is evidence that loops work.

- **Is it over? And a measured counterpoint.** [@jun_song](https://x.com/jun_song/status/2110345547764969915) (2026-10-14)
  lists loop engineering and "Graph" among things that "disappeared" this year, quoting his own 2026-07-18 post "Loop
  engineering will be gone in few months" (94,738 views at the 2026-10-19 fetch; replies not read). Gautham Pai
  ([blog, read in full](https://jnaapti.com/blog/2026/10/18/harness-engineering-loop-engineering-fundamentals), 2026-10-18)
  writing independently four days later, offers data: Google Trends shows "loop engineering" interest spiking "around June" then declining, but "That
  measures attention, not usefulness." The June wave and the token-spend objection are dated in
  [The Paradigm Shift](01-paradigm-shift.md).
- **The "Cron Engineering" critique.** [@uudonX](https://x.com/uudonX/status/2106875762351743129) (2026-10-04) calls loops and
  graphs orchestration repackaged because models are not yet capable enough, and notes Linux never hyped writing cron
  jobs as "Cron Engineering"; he quotes a [Lenny Rachitsky post](https://x.com/lennysan/status/2106772428861149683) listing
  "Why loops and graphs are a passing phase" — the counter-thesis above (episode not heard).
  [@guoda2066](https://x.com/guoda2066/status/2106435847738560846) (2026-10-03) says loop engineering is a best practice on
  top of the harness, not part of it. One reading each, not independently checked.
- **A conference deck.** Guillaume Laforge and Wietse Venema (Google Cloud developer advocates, per slide 1) posted their
  Devoxx talk ([post](https://x.com/glaforge/status/2107467103070474729), 2026-10-06) as
  [Loop Engineering, beyond prompt, context, and harness engineering](https://speakerdeck.com/glaforge/loop-engineering-beyond-prompt-context-and-harness-engineering),
  a "3-hour deep dive" (68-page PDF text layer read; one slide image checked). It defines loop engineering as how
  "we make the model iterate autonomously until a verifiable goal is met" and graph engineering as "designing the
  deterministic network (the graph)" and, in the next bullet, "that connects, routes, and orchestrates (the edges)
  individual loops (the nodes)"; for the complexity-ceiling failure mode it prescribes "Transition from basic loop
  structures to structured graph workflows" — this doc's composition rule, stated rather than argued. Its four loop
  structures are in the [Maturity Model](20-loop-maturity-model.md#four-loop-structures-by-trigger-and-exit).
- **Two more sessions.** [@omarsar0](https://x.com/omarsar0/status/2104999107131797638) live-tweeted a talk he opened with "What
  comes after loops?" (2026-09-29; speaker and event not named; second-hand); a
  [later tweet in the thread](https://x.com/omarsar0/status/2105000667463237801) says: "Problem was informing the agent when to
  stop. Then came loop engineering." IBM Technology's
  [What Is Loop Engineering? Building Better AI Agents](https://www.youtube.com/watch?v=DQBqh6gcx7U) (2026-10-19, 10:48)
  is described as "Martin Keen explains loop engineering and how AI agents act, observe, adjust, and repeat toward measurable
  goals"; only the description and chapter list were read, so the video's own claims are unchecked.
- **Attribution is unsettled.** [@GeoffreyHuntley](https://x.com/GeoffreyHuntley/status/2105213624105259504) (2026-09-30)
  posted "out: loop engineering" and "in: petrinet engineering" with no definition. Josh Wulf's
  [video with him](https://www.youtube.com/watch?v=ziXOV0b134s) is described on its YouTube page as featuring "the creator of the 'Ralph Wiggum' loop and the person behind loop engineering" (the
  description's wording; the video was not watched); [The Register](https://www.theregister.com/ai-and-ml/2026/06/24/loop-engineering-latest-ai-buzzword-still-needs-humans-in-the-loop/5261735)
  credits the recent focus "in part" to [Steinberger](https://x.com/steipete/status/2063697162748260627)'s post. Huntley's
  Ralph loop is the earlier technique ([Long-Running Agents](25-long-running-agents.md)).
- **Another decision rule.** [@its_meseba](https://x.com/its_meseba/status/2104472784218792133) ("Loops, graphs, or both",
  2026-09-28, read in full) asks whether one agent can do the whole job *and* a cheap, real check can confirm it (if not,
  a team of agents, his "graph"), and whether the job comes back or its size is unknown (if so, wrap it in a loop). Its
  product-behaviour claims are the author's, unverified.
- **Promotion to discount.** Two Jev pitches drew the largest view counts among the posts read for this pass:
  [@Mr_Buzzoni](https://x.com/Mr_Buzzoni/status/2103689373774483815) (2026-09-26, 876,588 views at the 2026-10-19 fetch, an article
  post) and [@beamnxw](https://x.com/beamnxw/status/2108101310515925217) (2026-10-08, 799,928 views at the first fetch), which pitches Jev, which its article
  calls "TypeSafe AI's decision model" (no product page was found on 2026-10-19; the promoting posts are the only sources); [@kirillk_web3](https://x.com/kirillk_web3/status/2108679649006129271) amplifies a
  piece titled "Loop Engineering Meets Jev Engineering: How to Cut Your Claude Bill From $765 to $3 a Month". The saving
  is the promoter's arithmetic, not measured here, and `SOURCES.md` already flags cross-promotion of Jev by other
  accounts as one coordinated push.

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
([Cobus Greyling, "The Evolving Vocabulary of AI"](https://cobusgreyling.substack.com/p/the-evolving-vocabulary-of-ai), Jun 2026):

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
