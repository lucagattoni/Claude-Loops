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

["My job is to write loops"](https://www.youtube.com/watch?v=RkQQ7WEor7w&t=11m45s) (Boris Cherny, on stage at *Acquired Unplugged*, presented by WorkOS, Jun 2026) is the factory model expressed in one
sentence: the engineer's output is the production system, not the individual work
product.

## Practical Signals

You are operating in factory-model territory when:
- A task takes < 1 hour of agent time but > 1 hour of spec-writing time
- You have more than one agent running in parallel on sub-tasks of the same goal
- The bottleneck on your velocity is review bandwidth, not implementation bandwidth
- You are writing `PLAN.md` files more often than you are writing functions

## Spec-First, Conditioned on Maturity

[The Manager Analogy](#the-manager-analogy) and [Practical Signals](#practical-signals) above state
spec-first as unconditional. Andrew Ng conditions it on where the project is:

> "But when building quick 0-to-1 prototypes or applications in domains I'm unfamiliar with, I often
> move faster and with less deliberation. I find it convenient to jump quickly into directing a
> coding agent to start building, so I can examine what it has built in order to make the next set
> of decisions… Instead of 'spec drive development' becoming a new waterfall process where writing a
> spec is a gate to further progress, this allows me to more iteratively refine the spec."
>
> — Andrew Ng, [*Make All Your Tokens (and Your Brainwork)
> Count*](https://www.deeplearning.ai/the-batch/make-all-your-tokens-and-your-brainwork-count),
> 2026-07-10

The conditioning variable, stated directly in the same piece:

> "As a software project matures, coding agents will work longer (maybe hours) to build to more
> complex specs…"
>
> — Andrew Ng, [*Make All Your Tokens (and Your Brainwork)
> Count*](https://www.deeplearning.ai/the-batch/make-all-your-tokens-and-your-brainwork-count),
> 2026-07-10

The KB is not wrong, just unconditional where Ng is conditional: "write precise specs before
delegating" and the < 1 hour agent time / > 1 hour spec time signal are the **mature-project** case.
Early on, clarity is partly an *output* of the first loop iteration — build, inspect, refine — not a
precondition for starting one.

| | 0-to-1 / unfamiliar domain | Mature project / real users |
|---|---|---|
| Spec's role | Discovered by iterating: build, inspect, refine | Written before delegating |
| Spec effort vs. agent-time | Minutes writing a spec, agent runs briefly, repeat | Spec-writing time can legitimately exceed agent time |
| Failure mode if misapplied | **Spec-gating a prototype** — waterfall in a costume, the exact anti-pattern Ng names | **Skipping the spec on a brownfield service with users** — plausible, expensive, wrong output shipped |

Place the task on this table before applying the Practical Signals above as a rule rather than a
default.

## The Dark-Factory Ceiling and Its Bottleneck

Framing the factory model as a maturity progression: coding autonomy runs from
"spicy autocomplete" up to the **dark factory** — a fully autonomous spec-to-deploy
pipeline with no human bottleneck in the loop. A concrete five-layer version of that
pipeline is spec → planning agent → code-gen agents → testing → review agent →
deployment. The consistent finding across write-ups of this pipeline: the bottleneck
that remains once every layer is automated is **not** implementation speed or even
review throughput — it is **underspecified input** at the spec layer, i.e. exactly
the [New Software Lifecycle](01-paradigm-shift.md#the-new-software-lifecycle)
bottleneck this KB already names, restated as a pipeline-stage finding rather than a
general claim. Contrast this positive "dark factory" framing (a maturity target) with
[Failure Patterns' "Dark factory"](17-failure-patterns.md) entry (a warning) — the
difference is entirely whether mandatory human checkpoints exist; the pipeline shape
is the same either way.
([MindStudio](https://www.mindstudio.ai/blog/what-is-dark-factory-ai-coding-autonomous-pipeline-2/), Jul 2026.)

Cross-provider adoption data corroborates that engineers are already operating well
into this territory in practice, not just in theory: OpenAI reports its own engineers
now generate **99% of output tokens via Codex** rather than direct chat, with
99th-percentile users running 60+ hours of parallel agent turns per day. Read this as
external corroboration of the factory-model shift's direction, not as a Claude-Code
data point — the underlying pattern (agents doing the bulk of token-generating work,
humans orchestrating and reviewing) is provider-agnostic.
([OpenAI, "How agents are transforming work"](https://openai.com/index/how-agents-are-transforming-work/), Jun 2026.)

Anthropic's own house corroborates the same shift from the inside: Anthropic's engineers merged
**8x as much code per day in Q2 2026 vs. 2024**, and as of May 2026 **more than 80% of code merged
into Anthropic's codebase was Claude-authored** — though Anthropic states explicitly *"we are not
there yet, and recursive self-improvement is not inevitable."* ([Anthropic, "When AI Builds
Itself"](https://www.anthropic.com/institute/recursive-self-improvement), 2026.) The volume this
generates has its own infrastructure cost: Anthropic's CI saw a **25x increase in CI jobs** over
six months as agentic coding volume grew, forcing a redesign of test-impact analysis from a
stateful singleton (listener+selector) to a stateless, horizontally-scalable system — a 3-week fix
by one engineer that would previously have taken a quarter. ([Anthropic, "Agentic coding is
straining CI"](https://claude.com/blog/agentic-coding-is-straining-ci-heres-how-we-scaled-test-impact-analysis-at-anthropic), Sep 2026.)

**The primary source for the "dark factory" name, cited here directly rather than only
through secondary coverage.** [Dan Shapiro](https://www.danshapiro.com/blog/2026/01/the-five-levels-from-spicy-autocomplete-to-the-software-factory/)'s original taxonomy names six levels, explicitly
modeled on NHTSA's driving-automation levels: **0 Manual** ("not a character hits the disk
without your approval"), **1 Task Offloading** (discrete delegated tasks), **2
Collaborative Pairing** (working with the AI like a colleague), **3 Human-in-Loop Manager**
(reviewing diffs from parallel agent branches), **4 Autonomous Execution** (the developer
acts as PM, writing specs and checking results later), **5 Dark Factory** (spec in,
software out, no humans involved). His framing of Level 5, quoted directly: *"It's dark,
because it's a place where humans are neither needed nor welcome"* — referencing the Fanuc
factory staffed entirely by robots that gave the concept its name.
([Dan Shapiro, "The Five Levels: from Spicy Autocomplete to the Software Factory"](https://www.danshapiro.com/blog/2026/01/the-five-levels-from-spicy-autocomplete-to-the-software-factory/), Jan 2026.)
A later MindStudio piece reports the first concrete Level 5 case at this KB's [dark-factory
ceiling](#the-dark-factory-ceiling-and-its-bottleneck) above: an AI tutor chatbot
(simple chat-over-knowledge-base) built and shipped with zero human code review — framed
explicitly as *"reliable enough for prototypes and spiking product ideas,"* not yet
critical systems or complex state management.
([MindStudio, "What Is an AI Software Factory?"](https://www.mindstudio.ai/blog/ai-software-factory-dark-factory/), Sep 2026.)

**The best-known cases do not use the label, and only one forbids human review.** Ilko Kacharov's essay
([*The lights were never off*](https://kachar.dev/blog/the-lights-were-never-off), 29 Jul 2026, read in full; his X post of 30 Sep 2026 re-shares it) argues
the label outruns its sources. Checked against three primaries on 2026-10-19: [StrongDM's factory page](https://factory.strongdm.ai/) states
"Code must not be written by humans" and "Code must not be reviewed by humans"; [Stripe's Minions post, part 2](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents-part-2)
says over 1,300 weekly PRs are "human-reviewed, but containing no human-written code"; [OpenAI's harness-engineering article](https://openai.com/index/harness-engineering/)
(HTTP 403 on direct fetch, read from a Wayback copy) says "Humans may review pull requests, but aren’t required to." None of the three
contains the phrase "dark factory" (StrongDM says "software factory"). The essay's other claims, such as where Shapiro places himself on his own ladder, rest on interviews not opened here.

## When Merge Volume Is the Bottleneck: Source Control and CI

The [bottleneck shift](#the-shift-in-bottlenecks) does not stop at review. Once agents write most of the
code, the infrastructure built for human-paced merging becomes the limit. Anthropic's own account is the
clearest case so far (self-reported, from the company that sells the model doing the writing):

- **The numbers.** Merges to Anthropic's monorepo rose from about 2,500 a day in May 2026 to over 30,000 a
  day by September. The post says coding is no longer the bottleneck; the developer infrastructure built
  for human scale (source control, builds, CI) is. It built **Scion**, an in-house version control
  system, and migrated its monorepo off git in five months with a team of seven.
- **The design premise.** Nearly all clients are agents and jobs that are online by definition, so
  Scion drops git's offline-capable, full-copy-per-client model: the server answers history and blame
  queries, creates commits and performs merges, and CI jobs can often skip a checkout entirely.
- **What it did to the merge queue (the loop-design part).** The post says a proper merge queue "doesn't
  make much sense at agent scale", asks what CI even means when hundreds or thousands of changes can
  merge while tests are running, and reports it could not replicate a global repository lock. It
  invested in **post-merge and pre-deploy automated testing** instead, accepting that concurrent changes
  can conflict because (its claim) Claude can typically fix conflicts faster than humans can spot them.
  Read for loop design: when merge rate outruns pre-merge CI, the [verifier](04-verification.md) gate
  moves later in the pipeline rather than disappearing.
- **Where the humans went.** The engineers' recurring role was telling Claude "no": agents sometimes
  violated core system constraints, for example brute-force reading the commit log instead of asking the
  code review tool. Anthropic uses adversarial review heavily and reports it is effective but can be
  myopic (one review pushed Claude into excess validation), so skilled engineers steered away from
  over-engineering. Team members still review every change request, but examine the **intent** of the
  change rather than every line. Its review tool can express semantic constraints on approvals, such as
  separating comment-only changes from sensitive logic changes, so human reviewers focus on the
  consequential ones. It also runs one monitoring agent per component in a Slack channel ("superfans")
  alongside traditional alerts.
- **Not a product.** The post says Scion is not a suitable general replacement for git, and
  [The New Stack](https://thenewstack.io/anthropic-scion-git-replacement/) reports no public release is
  planned. The post's own suggestion is that git servers and forges can adopt the server-side ideas
  without leaving the git model.
  ([Anthropic, "Redesigning source control at Anthropic"](https://www.anthropic.com/engineering/redesigning-source-control),
  Oct 13 2026, updated Oct 15; [Simon Willison's summary](https://simonwillison.net/2026/Oct/13/redesigning-source-control-at-anthropic/).)

The same pressure shows up one layer over, at CI. The [25x CI-job growth](#the-dark-factory-ceiling-and-its-bottleneck)
Anthropic reported in September is picked up by a vendor-sponsored (Signadot) argument that making
pipelines faster is the wrong fix: the agent is fast and the loop around it is slow, so the
verification loop has to move to where the agent can run a change against real service dependencies.
Weigh it as a vendor's framing of a real problem.
([The New Stack, "Agents have made CI the bottleneck"](https://thenewstack.io/ci-bottleneck-agent-verification/), Oct 2026.)
The isolation idea extends to data: pgEdge Starfleet gives each parallel coding-agent experiment its own
copy-on-write Postgres branch with its own MCP address and token, a worktree per agent for the database
([The New Stack](https://thenewstack.io/pgedge-starfleet-postgres-branching/), Oct 2026).

## Named Factory Deployments

- **Warp's "Wilson" factory**: turns Slack/Linear/GitHub requests into merged PRs via a "foreman"
  agent orchestrating specialized coding agents through a configurable pipeline with
  human-approval checkpoints and failure-driven self-improvement loops, using LLM-as-judge scoring
  to grade output. Warp reports shipping **~2,000 PRs/month** this way and cutting cost-per-PR
  from $80 to $30. ([Lenny's Newsletter, "How Warp ships 2,000 PRs a month with AI
  factories"](https://www.lennysnewsletter.com/p/how-warp-ships-2000-prs-a-month-with), Sep 2026;
  [Warp, "Factories"](https://warp.dev/factories).) See also [Harness
  Patterns](24-harness-patterns.md) for Warp's inner/outer self-improving skill pattern.
- **monday.com's platform-wide agentic routines**: named, product-shipped agents — Intake
  & Triage, Knowledge, and Incident agents — each running as a standing loop against the
  monday.com platform rather than a one-off automation. A **"Brand Reviewer"** agent
  specifically keeps a human in the loop as a maker/checker pair: it drafts or reviews
  brand-sensitive output, but a human approves before anything ships, distinguishing which
  agentic routines in the platform are autonomous end-to-end from which keep a checkpoint — a
  live instance, inside one platform, of the ["lit" vs. "dark"
  distinction](#lit-vs-dark-factories-and-where-judgment-relocates) below.
  ([Anthropic, "How monday.com transformed its platform into an agent-first product"](https://claude.com/blog/how-monday-com-transformed-its-platform-into-an-agent-first-product-where-humans-and-agents-collaborate), Sep 2026.)
- **Droid Shield 2.0** (Factory.ai): a deterministic scanner that inspects every line of an autonomous commit/push for secret-shaped patterns and blocks the commit on a suspicious hit. The 2.0 release adds two new fine-tuned classifier models on top of the deterministic scanner — one ("Risk") optimized for recall, catching secrets the pattern-matcher misses; one ("Downgrade") optimized for precision, clearing false-positive flags on placeholders/fixtures/docs — reported as the strongest or tied-strongest classifiers on both tasks versus frontier models, at lower cost and latency; model weights released publicly.
  ([factory.ai/news/droid-shield-2-0](https://factory.ai/news/droid-shield-2-0), Jul 2026.)
- **Auto-merge as the factory's terminal stage**: a discussion (Thorsten Ball / Nate
  Berkopec) argues model-based code review now exceeds human review for routine PRs,
  and endorses a factory loop design that **auto-merges low-risk PRs within minutes**
  of opening — the review gate becomes a machine-speed stage rather than a
  human-paced one for the PRs it's confident about, with humans reserved for the
  PRs the gate itself flags as uncertain.
  ([@thorstenball repost via @steipete](https://x.com/thorstenball/status/2074377949181030491), Jul 2026.)
- **Stripe's "Kai"**: an internal agent platform used by 10,000+ employees per week (86%
  company-wide adoption), built by "1.5 engineers in 2 weeks." Its skill library holds
  ~2,000 skills, ~50 used company-wide every day. The governance mechanism is "Projects" —
  a permissions/data-access layer letting agents "query safely at scale" over
  infrastructure originally built for human developers, not agents. A near-incident
  (agents "nearly take down production systems") named identity management and
  load-shedding as the specific fixes, not a broader pullback. The team's own framing of
  where the actual difficulty sits: *"The hardest part of bringing AI into a large
  company isn't the model — it's governance."*
  ([Sharadh Krishnamurthy, "Build your own company brain: the enterprise AI playbook from
  Stripe's engineering team," Lenny's
  Newsletter](https://www.lennysnewsletter.com/p/build-your-own-company-brain-the), Sep 2026.)
- **Bun's granular decomposition of a total rewrite**: rather than dispatching
  "rewrite Bun in Rust" as one instruction, the work was broken into a sequence
  small enough for parallel agents to execute mechanically: generate porting guides
  (`PORTING.md`, a lifetimes table) → port files mechanically → fix compiler errors
  (16,000 of them, distributed as a checklist across 64 parallel Claude instances,
  see [Fleet Engineering's case
  study](23-fleet-engineering.md#case-study-bun-64-parallel-instances-rewriting-535k-lines-in-11-days))
  → get subcommands working → run the test suite to green. Each stage produces a
  checkable artifact the next stage consumes, which is what makes a 535,496-line
  rewrite decomposable into agent-sized units at all. ([Bun, "Bun, in
  Rust"](https://bun.com/blog/bun-in-rust), Jul 2026.)

- **Anthropic's own official Code Modernization plugin**: a first-party, human-gated
  eight-step workflow spinning up **50–200 concurrent agents per phase** for large legacy
  migrations, distinguished from the named deployments above by how it verifies: not model
  opinion, but **evidence-based verification** — side-by-side execution against the legacy
  system, independent re-derivation of the result, and deterministic
  **PROVEN / PARTLY PROVEN / NOT PROVEN** verdicts per migrated unit. The accompanying
  playbook frames stopping conditions the same way this KB's own STOP taxonomy does —
  tiered by **blast radius and agent confidence**, so a low-risk, high-confidence change
  clears with less human review than a high-blast-radius one — and structures work as
  dynamic Claude Code workflows distributing parallel subagent workstreams, with
  verification via testable "certificates" rather than a human eyeballing a diff.
  ([Anthropic, "How to prepare for AI-driven code modernization projects"](https://claude.com/blog/how-to-prepare-for-ai-driven-code-modernization-projects), Sep 2026;
  plugin: [anthropics/claude-plugins-official — code-modernization](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-modernization).)

- **Block's orchestrator-plus-workers migrations** (self-reported by Block's head of AI capabilities,
  in an Anthropic customer interview): for company-wide migrations of hundreds to thousands of PRs, a
  frontier model (Claude Fable 5) does the higher-level design work and directs up to dozens of smaller,
  cheaper models to make file edits and run tests, while a human engineer steers. Early results, in
  Block's words, show frontier tokens going to upfront planning and a higher share of tokens to worker
  models without a drop in quality; the whole setup runs on Buzz, which the interview describes as Block's open-source
  workspace for human-agent teams, and a migration can merge around a thousand orchestrated PRs. Block also runs
  daily or weekly agent passes over a codebase to find cleanup and consolidation, as a counter to the
  tech debt that a higher PR rate accumulates faster.
  ([Anthropic, "How Block orchestrates Claude Fable across thousands of pull requests"](https://claude.com/resources/articles/how-block-orchestrates-claude-fable-across-thousands-of-pull-requests), Oct 8 2026.)
- **Harness (the company) buys a "software factory"**: it acquired Augment's Cosmos, described as taking
  a requirement or bug report to a PR in isolated VMs, picking up failed checks and review comments, and
  connecting to delivery history over MCP — the post-merge half of the line, which the coding agents
  themselves usually stop short of.
  ([The New Stack](https://thenewstack.io/harness-augment-cosmos-acquisition/), Oct 2026.)
- **A ten-person team on the compound-engineering plugin** (Juma Labs; self-reported): the CTO says
  the team merged 469 PRs in the week of 5 October 2026, against about 70 a week a year earlier with the
  same ten people, and does not credit the plugin alone (models and Claude Code improved over the same
  year). The line is [Every's compound-engineering plugin](https://github.com/EveryInc/compound-engineering-plugin):
  brainstorm, plan, work, simplify, review, compound sequence, with humans at the two ends
  (the plan and the review) and agents unattended in the middle; the README's stated bet is 80% in
  planning and review, 20% in execution. Two honest limits from the same post: review fans out to
  parallel specialist agents and is the token cost (a public issue reports a 32-line change using 17.1
  million input tokens), and the author's own telemetry shows the `compound` step, the one that writes
  lessons down for the next plan, is the one the team mostly skips. Pair with the author's [earlier essay on the dark-factory label](https://kachar.dev/blog/the-lights-were-never-off).
  ([Ilko Kacharov, "Compound engineering is our factory floor"](https://kachar.dev/blog/compound-engineering-is-our-factory-floor), Oct 15 2026.)

- **[Tessl](https://tessl.io)'s five or six factories** (Patrick Debois, in an interview; self-reported, and the podcast is produced by [Camplight](https://camplight.net), whose episode notes say it
  builds dark factories for companies). From the auto-generated captions (segments 11:00-27:00 and 37:30-41:00, fetched 2026-10-19): Tessl's path was
  "first the prompts, then fix the context, then add the harness, then add the loop, and then eventually the factory"; its developers had to relearn
  operations (a proxy, a sandbox, security scanning, observability for the agent); the factory took over the marketing and sales boards unasked; and
  one morning it had filed "15 tickets about improving itself", with no owner. His conclusion on ownership: "can you redo it without ownership? No." He had the
  whole organisation build a factory "to understand the shape of a factory", which produced five or six, and advises a team starting out to "try to make the first loop better first before automating the whole loop".
  ([After the Last Engineer, "Is the Future of Software Engineering a Factory?"](https://www.youtube.com/watch?v=FnCnv2tGsK0), 15 Oct 2026.)

## "Lit" vs. "Dark" Factories, and Where Judgment Relocates

Addy Osmani's own naming for the [Dark-Factory Ceiling](#the-dark-factory-ceiling-and-its-bottleneck)
distinction above: a **"lit" factory** keeps a human in the loop by design; a **"dark"
factory** runs with no human checkpoint. Built on Dex Horthy's harness-engineering
framework, the piece argues **verification, not generation, is the real bottleneck** —
the same underspecified-input finding this doc already documents from MindStudio,
independently corroborated.
([Addy Osmani, "Software Factories, Light and Dark"](https://addyo.substack.com/p/software-factories-light-and-dark), Jul 2026.)

A follow-up piece surveys where **human judgment relocates** rather than disappears as
factories mature, mapping the shift against commercial platforms (Factory, Warp,
HumanLayer, Vercel) — corroborating this doc's [Named Factory Deployments](#named-factory-deployments)
above with a wider platform survey rather than single case studies.
([Addy Osmani, "Human judgment doesn't leave the software factory. It relocates."](https://addyo.substack.com/p/human-judgment-doesnt-leave-the-software), Aug 2026.)

**A field report from a domain outside software.** Eight real Codex/Claude Code
scientific-computing projects show the same shift happening in research labs: engineers
moved from writing code to orchestration (defining goals, chunking work, validating
outputs) because agents "could not reliably judge scientific validity" — a concrete,
outside-software instance of "replace yourself as the person who prompts," and further
evidence the factory-model shift is not specific to commercial software engineering.
([OpenAI, "Scientific computing in the age of agentic AI"](https://openai.com/index/scientific-computing-agentic-ai), Jul 2026.)

## What Open-Source Factory Floors Converge On (Oct 2026)

The word "factory" now covers at least four different things, which matters when comparing claims:
the system around *bought* coding agents (tickets or alerts as triggers, cloud execution, a model
gateway, agent identity, code review — [The AI Thinker's](https://www.theaithinker.com/p/how-to-build-an-ai-native-software)
reading of Uber's setup); a shared, scrutinized AI system for one recurring task that beats per-person
personal agents, with a "factory factory" that builds more of them
(["Against the Personal Agents Theory of Everything"](https://www.gettheleverage.com/p/against-the-personal-agents-theory)); a **user-defined
graph engine** ([zeroshot](https://github.com/the-open-engine/zeroshot), whose README now presents it
as an open-source software factory, "CI for coding agents"); and a model scoped to one release or epic
of 10-20 tickets with planning kept *outside* the automated loop
([MindStudio](https://www.mindstudio.ai/blog/how-to-build-ai-software-factory/), an AI-generated explainer, so weaker than a primary).

Independent projects that ship a working factory floor land on the same checker discipline. The rows
below are each project's own description, not an audited comparison:

| Project | Who builds | Who checks / what the gate demands | Who merges |
|---|---|---|---|
| [zeroshot](https://github.com/the-open-engine/zeroshot/commit/5423df24) (commit; [v10.13.0](https://github.com/the-open-engine/zeroshot/releases/tag/v10.13.0)) | A worker node in a user-defined graph | The engine, not the prompt, enforces review gates and retry limits; the writer cannot approve its own work. The delivery stage validates the **exact candidate PR head** before publication, review and merge (accept / wait / authored repair / refuse) and keeps credentials out of agent environments. A [review-loop guide](https://github.com/the-open-engine/zeroshot/commit/be185676) ships a worker plus two parallel reviewers in a bounded repair loop | The delivery stage, after the head check |
| [omnigent `feature-agent`](https://github.com/omnigent-ai/omnigent/blob/f30a9f3c1e3a81c30ab6998fc88a376430e2b23a/dev/feature-agent/AGENTS.md) | An unattended agent taking a Linear ticket through requirements, design, tests and a PR | "Implemented" needs at least one test and one recording per covered user journey plus a clean live review gate on the current head; otherwise `partially_implemented` with `remaining_work` | Never the agent |
| [Orchestra v2.46.0](https://github.com/DrSeedon/orchestra/releases/tag/v2.46.0) | Per-worker sparse worktrees | The merge gate runs mapped tests and requires the changed tests to **fail against the pre-change sources**; failed or inconclusive required gates block the merge. A shell guard enforces rules by mechanism and is described as "a narrow policy, not a sandbox" | The gate |
| [OpenRig v0.6.6](https://github.com/mvschwarz/openrig/releases/tag/v0.6.6) | Built-in factory team of seven seats: lead, advisor, builder, QA, design and two reviewers; the starter team pairs a Claude Code builder with a Codex reviewer | Separate QA and reviewer seats | Not stated in the release note |
| [agent-orchestrator v0.13.4](https://github.com/OrchestratorInc/agent-orchestrator/releases/tag/v0.13.4) | Worktree-per-worker agents | Agents can request native review of their own PRs; the release also lists action postconditions (the PR bodies were not read, so the mechanism is unverified) | Not stated |
| [magpie](https://github.com/yetone/magpie) (its `docs/code-standards.md` and `docs/contributors.md`, read 2026-10-19) | Claude Code `/loop` sessions, per [the maintainer's post](https://x.com/yetone/status/2109855710444237018); `LESSONS.md` says its code is "written, reviewed, merged and released by agents" | An acceptance list: a new test must fail when the old code is put back, a real-use check where possible, a check that was not run is listed as not run. A community PR is read for harm first, and a change to `.github/`, a release script, a credential file the goal does not need or a dependency stops the review until the maintainer has looked | Agents; the standard names the reviewed commit, `gh pr merge --match-head-commit <reviewed sha>`, so a push during review stops the merge |
| [MindStudio's factory loop](https://www.mindstudio.ai/blog/software-factory-ai-coding-agents/) (explainer, weaker) | Sandboxed worker | An independent verifier; the post reports workers self-reporting passing tests while the verifier found failures | A human; agents may open PRs but never merge |

Four shared properties across the rows: **the builder cannot
approve its own work**, and the rule is enforced by the engine or gate rather than by an instruction;
**approval is bound to the exact current head**, so a later push invalidates it; **evidence beats
self-report** (a test that must fail before the change, a recording per journey, a verifier that
re-runs the claim; see [Verification](04-verification.md)); and **a human or a mechanical gate, never the
agent, performs the merge**. The compound-engineering post above adds a fifth that costs nothing:
run the reviewer in a sub-agent so it does not inherit the author's reasoning. That is the same maker/checker rule as the [Loop Contract](27-loop-contract.md)'s STOP and verifier fields.

**An open-source factory maintained by its own loops: magpie.** The maintainer's post (Chinese, 13 Oct 2026) says
the workflow is Claude Code with Opus 5.5 (his wording) running three `/loop` prompts in parallel, plus his own nightly pass over UI and UX
issues. On my reading of the screenshots, each loop has one intake: GitHub issues and PRs plus every Discord channel (read a PR
line by line and run it before merging, because it may be untested agent output); X feedback, where a cheap decision model (the prompt names Jev, a product no official page could be found for on 2026-10-19; see [MCP Security](19-mcp-security.md))
first drops tweets that are not about magpie so the main model never sees them; and clean-up plus lessons, which is
[Memory Patterns, Pattern L](16-memory-patterns.md#pattern-l-a-lessons-file-with-a-count-based-promotion-rule). For platform
reports the standard says "the Windows box and its WSL2 distro are there". What went wrong is recorded in the repo's own file,
not in the posts (the file's own tallies, not independently checked): 2026-10-05 had "220 commits and ~170 releases", and "About 40 of them fixed something released earlier the same day or the day before."

**A vendor's version of the same list (not evidence).** [Mark Ajzenstadt](https://x.com/mardehaym/status/2112099730641555505), whose X bio
says he founded [Limestone](https://limestonedigital.com), which embeds AI engineers in PE-backed companies, describes its Velocity Core (19 Oct 2026): a run has 22 steps,
"Only three are left entirely to the agent. Fourteen are plain code." Credentials stay outside the agent; a run reads its rules from
its starting commit and changing them needs a person's approval; outbound requests pass an allowlist; CI decides "done" with a
cap of two CI runs; deleting or emptying a test sends the work back and "A second violation ends the run"; each run records prompt
versions, the exact model per step, the starting commit and the cost; "A person still reviews and merges every pull request."
It is a sales post with no evidence, and no product page was found (limestonedigital.com, checked 2026-10-19). Of its list, the test-deletion
tripwire is the item the rows above lack.

**Pricing the factory.** The AI Thinker piece prices each agent per unit of work, such as cost per
merged PR (its Uber account), and a commenter objects that merged-PR count is a throughput proxy and
proposes measuring instead whether a change survives 30 days without a revert. A post by [@zachlloydtweets](https://x.com/zachlloydtweets/status/2104957956794057068),
seen only through a TLDR summary and unverified, frames the same goal as reducing human touches per PR. See
[Cost & Turn Control](11-cost-control.md) for the BUDGET side and
[Fleet Engineering](23-fleet-engineering.md) for operating many such lines.

## Relationship to Other Concepts

- [Loop Contract](27-loop-contract.md) — the factory spec: what the loop is allowed to do and when it stops
- [Harness Patterns](24-harness-patterns.md) — the factory floor: how the workers are orchestrated
- [Verification](04-verification.md) — quality control: how finished work is checked before shipping
- [Fleet Engineering](23-fleet-engineering.md) — operating many factory lines: recovery, wake and control-plane mechanics
