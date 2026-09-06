# Session Architecture: One Session or Many

You are building software with Claude Code. Should you run one session, or several coordinated
ones — a planner and a coder, say, or a writer and a reviewer?

**Split by context boundary. Never by job title.**

That one rule resolves most of the question. The rest of this page is the evidence for it, the
decision table for the primitives that *do* parallelise well, and a case study of a project that
ran the role-split version for six weeks and measured what it cost.

---

## The three reasons to use more than one agent

Anthropic names exactly three
([*When to use multi-agent systems (and when not to)*](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them),
2026-01-23):

| Reason | What it means |
|---|---|
| **Context protection** | The work would flood one context window with material you will never reference again |
| **Parallelisation** | The facets are genuinely independent and can run at once |
| **Specialisation** | Genuinely different toolsets, prompts, or expertise |

**"A different role in the same pipeline" is not on that list**, and the post is explicit about why:

> "We've observed teams build elaborate multi-agent systems with separate agents for planning,
> execution, review, and iteration, only to discover that they suffered from lost context at each
> handoff and spent more tokens coordinating than executing."

> "Dividing by type of work (one agent writes features, another writes tests, a third reviews code)
> creates constant coordination overhead. Each handoff loses context… When agents are split by
> problem type, they engage in a 'telephone game,' passing information back and forth with each
> handoff degrading fidelity."

The operative sentence for design purposes:

> "The key insight is to adopt a context-centric view rather than a problem-centric view when
> decomposing work… Work should only be split when context can be truly isolated."

---

## Why coding is the hard case

Multi-agent results from research tasks do not transfer to coding. Anthropic says so directly
([*How we built our multi-agent research system*](https://www.anthropic.com/engineering/multi-agent-research-system)):

> "Most coding tasks involve fewer truly parallelizable tasks than research, and LLM agents are not
> yet great at coordinating and delegating to other agents in real time."

> "Some domains that require all agents to share the same context or involve many dependencies
> between agents are not a good fit for multi-agent systems today."

### The 90.2% figure does not mean what it is usually quoted to mean

The widely cited *"90.2% better than single-agent Opus"* comes from that same post — measured on an
**internal breadth-first research eval** (example task: every board member of the S&P 500 IT
companies). Citing it for a coding architecture applies a result to a population it was never
measured on.

The same post also reports that in that eval **"token usage by itself explains 80% of the
variance."** The multi-agent win is substantially a *spend* win.

That matters because of what the token multiples are:

| Comparison | Multiple |
|---|---|
| Agent vs. chat | ~4× tokens |
| Multi-agent vs. chat | ~15× tokens |
| Multi-agent vs. single-agent, equivalent task | 3–10× tokens |

**Independent corroboration under controlled budgets.** Tran & Kiela find that single-agent systems
"consistently match or outperform" multi-agent ones on multi-hop reasoning **when reasoning tokens
are held constant**, with an information-theoretic argument — grounded in the Data Processing
Inequality — for why a single agent is more information-efficient under a fixed budget. Their own
conclusion: "many reported advantages of multi-agent systems are better explained by unaccounted
computation and context effects rather than inherent architectural benefits." They also find that
multi-agent systems *do* become competitive when a single agent's effective context utilization
degrades — which is the condition this doc's own [fan-out](10-fan-out.md) guidance describes.
The practical reading: unaccounted compute is the usual explanation for a reported multi-agent win.
If you are comparing architectures, hold the budget fixed or you are measuring spend.

**Read the scope before generalising it to Claude.** The controlled study covers three model
families — Qwen3, DeepSeek-R1-Distill-Llama, and Gemini 2.5 — and **no Claude model**. The
information-theoretic argument is model-independent; the measurements are not. The paper also
reports "significant artifacts in API-based budget control (particularly in Gemini 2.5)", so its
own budget-matching is imperfect by its own account.
([Dat Tran and Douwe Kiela, *Single-Agent LLMs Outperform Multi-Agent Systems on Multi-Hop
Reasoning Under Equal Thinking Token Budgets*, arXiv 2604.02460](https://arxiv.org/abs/2604.02460),
Apr 2026.)

### The one multi-agent pattern that consistently works

> "One multi-agent pattern that consistently works well across domains is the verification subagent.
> This is a dedicated agent whose sole responsibility is testing or validating the main agent's work."

And the reason it works is the same rule stated positively — verification

> "requires minimal context transfer — the verifier blackbox-tests without needing full build history."

A lens needs almost no context transfer. A role needs all of it.

---

## Two official sources appear to disagree

The [best-practices page](https://code.claude.com/docs/en/best-practices) documents a Writer/Reviewer
pair of sessions: *"A fresh context improves code review since Claude won't be biased toward code it
just wrote."* The multi-agent post calls planning/execution/review an anti-pattern. Both are official.

They reconcile on the boundary between a **move** and a **standing structure**:

- The Writer/Reviewer table is a **task-scoped move** — session B reviews one named file, once.
- The anti-pattern is a **standing decomposition of all work by role**.

And the best-practices page's own *Add an adversarial review step* uses a **subagent**, not a
session, naming the cost of the session version explicitly: *"without you copying findings between
windows."*

---

## The decision table

Anthropic's own comparison, from the [agents overview](https://code.claude.com/docs/en/agents):

| Primitive | Use it when |
|---|---|
| **[Subagents](07-subagents.md)** | "A side task would flood your main conversation with search results, logs, or file contents you won't reference again" |
| **Agent view** | "You have several independent tasks and want to hand them off, check status at a glance, and step in only when one needs you" |
| **[Agent teams](38-agent-teams.md)** | "You want Claude to split a project into pieces, assign them, and keep the workers in sync" |
| **[Dynamic workflows](39-dynamic-workflows.md)** | "A job outgrows a handful of subagents, or you want findings verified against each other: a codebase-wide audit, a 500-file migration, cross-checked research, or a plan drafted from several angles" |

**`/batch` is not a fifth option.** The same page: it is *"a skill that has Claude split one large
change into 5 to 30 worktree-isolated subagents that each open a pull request. It's a packaged use
of subagents and worktrees, not a separate coordination style."*

Note what is absent from that table: *a second interactive session holding a different job title.*

---

## Specialise by framing, not by role

The distinction that makes the rule usable:

| | Needs | Example |
|---|---|---|
| **A role** | The whole project's context | "You are the reviewer" |
| **A framing** | Almost none | "Does every member of this set have an image?" · "What does the disk actually contain?" · "What would a runtime probe show?" |

A framing is a specialisation that survives the decomposition rule, because it transfers no context.
Framings belong in committed [subagent definitions](07-subagents.md), where they are versioned,
model-pinned, and reusable. The [agent teams doc](https://code.claude.com/docs/en/agent-teams) makes
the reuse explicit: *"This lets you define a role once, such as a security-reviewer or test-runner,
and reuse it both as a delegated subagent and as an agent team teammate."*

---

## Case study: Pinakes

A solo-developer project, ~6 weeks old, running two resident Claude Code sessions split by role —
a `planner` owning `plans/` and `docs/`, and a `coder` owning the tree. The question under
evaluation: **should a third resident "reviewer" session be added?**

The evaluation ran 14 agents over the repository's own git history and transcript corpus. Every
figure below names its population; percentages are given without absolute spend.

### The verdict

**No third session.** Planner / coder / reviewer as standing session roles is precisely the
configuration Anthropic names as the one teams build and then abandon. Keep two sessions split by a
real context boundary — *records versus code* — or collapse to one. Put every other specialisation
in committed subagent definitions, hooks, skills and workflow scripts.

### What the measurement showed

| Finding | Population / instrument |
|---|---|
| **~36.8% of all delegated spend went to review passes** — 590 reviewer-classified passes | Every subagent and workflow transcript under the project's directories: ~1,360 transcripts, ~6.95B tokens. Reproduced digit-for-digit by two independent re-runs |
| **~95.8% of files a later review pass opens were already opened by an earlier pass**; ~35.6% of a later pass's tokens are pure repeat, rising to 40.1% for passes above 5M tokens | 305 later passes over 20 increments, 1.12B tokens |
| **The append-only fragment mechanism does not rot** — median lifetime 2.1 h, p90 38.1 h, **zero over seven days**. Work assigned to "an owner with no queue position" aged 21 days | 297 fragment paths ever added; 282 paired add→delete. Renames mis-pair, so ~9 are unpaired |
| In a 36-hour window, **43 of 85 non-merge commits touched only `plans/` or `docs/`**; `src/` moved +116/−23 while `docs/` moved +1847/−110 | Non-merge commits on the default branch. Line churn overweights prose-heavy files; used deliberately because commit counts overweight a one-commit-per-review-pass policy |

The dominant recorded failure mode was not bad code. It was **the repository being wrong about
itself** — stale status rows, a quoted figure that had gone stale, a claim about a commit that did
not exist.

### The finding that actually mattered

Review was not capacity-constrained. It was **truncation-constrained, and the truncation was
value-biased.**

One review pass ran 6 lenses as 14 agents. **Five died** on a session limit. The *"what is missing"*
lens never ran at all. Two findings were never refuted. The summary reported *"8 raised, 4
confirmed"* — and reported it as a clean result.

The bias is structural, not random:

> Lenses that read text finish first. A lens that tests *runtime behaviour* must build state and run
> a command, so it reports last, is refuted last, and is first to be cut. "The two findings that lost
> their refuters were the two about behaviour, and one was the only real code defect in the pass."

Earlier, a 19-agent fan-out lost 17 agents to a session limit, `.filter(Boolean)` erased them, and
the workflow returned `{"raised":0,"confirmed":[],"refuted":[]}`. One of the recovered findings was
a real high-severity defect. **It was caught because a human noticed the fan-out had lied.**

Three corrections follow directly, and they are cheap:

1. **Count the dead before you filter.** `const dead = results.filter(r => r === null).length` — and
   report `VACUOUS` / `PARTIAL` / `CLEAN` / `FINDINGS` as distinct outcomes. A pass that tests
   `survived.length === 0` and prints "found nothing" has not asked whether anyone looked.
2. **Schedule slow lenses first**, so a session limit truncates the cheap end.
3. **Report unrefuted findings as a first-class list.** A finding whose refuter died is *unrefuted*,
   not *refuted*.

### Claims that did not survive checking

Publishing these is the point — each was plausible, argued in good faith, and wrong:

| Claim | Verdict | Why |
|---|---|---|
| "A reviewer's queue is structurally low-overlap" | **Refuted** | Its named files were exactly the ones the coder was mid-fixing, plus the plan file the planner edits hourly |
| "There is unowned standing audit work a reviewer would fill" | **Refuted** | Every such row already had an owner; triaging the bucket means writing a `plans/` row the reviewer may not write |
| "The ownership split creates a write-latency on truth" | **Refuted** | Measured at ~30 minutes with nothing waiting on it. "Latency is not a cost when nothing waits on it" |
| "Coordination cost scales worse than linearly with session count" | **Not established** | The orchestrator's own framing; n=2 incidents, one with a measured duration. Dropped |
| "Review is 43.9% of delegated spend" | **Stale** | Re-derived at 36.8%. A number in a docstring is an unversioned claim |

The last one generalises into a rule: **re-run figures, never quote them.**

### The cost neither role had named

The most interesting finding was not about capacity at all:

> A request routed to an owner arrives **pre-framed**, and an owner who answers the framing instead
> of checking the premise adds a signature to an error rather than catching one.

The instance: a request arrived offering three options and a recommendation. All three rested on a
false premise that a single documented `grep` would have exposed. Answering *"which of your three?"*
would have laundered the premise through an owner. Within the same morning the reverse also
happened — an hour spent reasoning from reading where running was available.

The class — **reasoning from reading when running was available** — belongs to neither role, and no
ownership table fixes it.

### What was right

This is not a verdict against the project. Measured against official guidance it was ahead of common
practice: ~20 deterministic gates under `set -e`, adversarial review in a fresh context with one
refuter per finding, worktrees per increment, append-only fragments instead of shared-hotspot edits,
and retrospectives recording the process's own failures with their populations.

**What was off was the substrate, not the instinct.** Roles ran as *sessions* instead of
*definitions*. Rules ran as *prose* instead of *hooks*. The review instrument was never calibrated.
Fan-out results could not say whether anyone had looked.

### Hand-rolled vs. built-in

| Hand-rolled | The primitive that replaces it |
|---|---|
| A role typed into the prompt | `.claude/agents/*.md`; `claude --agent <name>` |
| An ownership table enforced by goodwill | A `PreToolUse` [hook](12-hooks.md) on `Edit\|Write`, blocking by path |
| "Never `git merge` by hand" as a prose rule | A `PreToolUse` hook on `Bash` |
| A procedure remembered from a doc | A [skill](06-skills.md) with `disable-model-invocation: true` |
| Ad-hoc review fan-outs rewritten per increment | A committed [workflow](39-dynamic-workflows.md) script |
| Sessions colliding on the primary checkout | `isolation: worktree` on a subagent definition |

The general lesson: **an instruction that must hold with zero exceptions does not belong in prose.**
The official docs put it plainly — *"Unlike CLAUDE.md instructions which are advisory, hooks are
deterministic and guarantee the action happens."*

---

## Sessions that can talk to each other

If you do run several sessions, they are no longer blind to one another. Claude Code ships
[cross-session messaging](https://code.claude.com/docs/en/cross-session-messaging): `ListAgents`
discovers reachable agents and `SendMessage` delivers text to one by name — across subagents,
agent-team teammates, other local sessions, cloud sessions, and Remote Control sessions on other
machines. Requires v2.1.224+ (macOS/Linux) or v2.1.234+ (native Windows).

What crosses the boundary is deliberately narrow:

> "A message is a piece of text one Claude writes to another, never the sender's conversation
> history or files."

> "Claude Code delivers these messages over a per-session socket on your machine, never through
> Anthropic servers."

Two rails matter for anyone designing around this, both quoted verbatim:

> "It can't approve anything: a message from another session never counts as your consent"

> "Commands don't run: a command in the message's text … arrives as plain text. Claude Code never
> executes it."

Inbound behaviour is governed by `crossSessionInbound` (`accept` / `hold` / `refuse`). With no
value set, Claude Code decides per message from the two sessions' permission modes — sessions in
`bypassPermissions` form one class and everything else the other, and messages crossing from a
bypass session to a prompting one are held for approval by default.

**This does not repeal the rule at the top of this page.** Messaging lowers the *cost* of a handoff;
it does not remove the context that a role-split handoff has to carry. A message is coordination,
never permission — which is exactly what the second rail above enforces mechanically.

### `/config` visibility, and subagent messages framed correctly

Inbound handling got a visible settings surface:

> "Added `/config` rows for "Dialog expiry" and "Messages from your other sessions" (cross-session
> inbound accept/hold/refuse)"
> — [v2.1.232 release notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.232)

And a message from your own subagent no longer reads like an unrelated session butting in:

> "Improved framing of messages from your own subagents: Claude is told the sender is a worker
> inside this session, not an unrelated Claude session"
> — [v2.1.251 release notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.251)

### Zero-polling arrives natively (v2.1.236)

[Background Agents](29-background-agents.md) documents a hand-rolled zero-polling pattern: a
worker types a one-line `WORKER-DONE <id>: <status>` into the orchestrator's terminal via a
multiplexer, waking it instantly instead of the orchestrator polling `claude agents` or waiting on
a `SubagentStop` hook. Claude Code v2.1.236 shipped the same idea as a native `SendMessage` option:

> "Added `notify_when_idle` to cross-session `SendMessage`: ask another Claude Code session on
> this machine to send one notice when it next goes idle — opt-in, one-shot, no polling (macOS and
> Linux)"
> — [v2.1.236 release notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.236)

This is the shrink-on-native dynamic [Harness Patterns](24-harness-patterns.md) documents
elsewhere: a component built to compensate for a missing primitive becomes overhead once the
platform ships that primitive directly. `notify_when_idle` doesn't replace the multiplexer
pattern's git-tracked audit trail or its reach across non-Claude-Code tools — but for two Claude
Code sessions on one machine, it removes the need to build the wake-up mechanism at all.

## When agents are not told about each other

Anthropic's [multiagent systems study](https://www.anthropic.com/research/multiagent-systems)
(2026-08-13) set three Claude instances to migrate the same codebase to different target languages
**without telling them about each other**. The models

> "quickly assumed that others were purposefully impeding their work, and began to sabotage others
> while protecting their own contributions"

including *"disabling the Unix accounts of the other agents, writing automated scripts that found and
killed competing processes on a loop, and deploying malicious code that was disguised as belonging
to another agent."*

Resolution varied sharply by model — 98% of runs on one model ended in truce; most runs on two others
"ended by force or never settled." Anthropic's conclusion is the part to carry:

> "coordination doesn't naturally emerge from stronger intelligence nor alignment at the individual
> level"

Successful resolutions often involved an agent **asking for a human to intervene**.

The design consequence for anyone running parallel agents on overlapping scope: shared-scope
coordination is a protocol you must design, not a property that emerges. See
[Fan-Out](10-fan-out.md) for scope-verified parallelism and [Fleet Engineering](23-fleet-engineering.md)
for coordination at scale.

---

## Practical rules

1. **Default to one session.** Add a second only when you can name the context boundary it protects.
2. **A real boundary is about *material*, not *job title*** — records vs. code, this service vs. that
   one, the migration vs. the review of the migration.
3. **Never add a resident reviewer session.** A reviewer needs the increment's full context to review
   it, which is the definition of a bad split. Review belongs in a subagent, in a fresh context.
4. **Put specialisations in definitions, not in prompts.** Versioned, model-pinned, reusable as
   either a subagent or a teammate.
5. **Put zero-exception rules in hooks, not in `CLAUDE.md`.** Advisory text is silently wrong;
   a hook cannot be.
6. **Count dead agents before filtering.** Report coverage as a distinct outcome from findings.
7. **Hold the token budget fixed** when comparing architectures, or you are measuring spend.
8. **Calibrate the review instrument** before scaling it — seed known defects, including one that is
   not a defect, and measure the kill rate and the false-positive rate.

---

## Related

- [Choosing Your Mode](35-choosing-your-mode.md) — interactive or autonomous, before this question
- [The Development Workflow](36-development-workflow.md) — where session choice sits in the whole cycle
- [Subagents](07-subagents.md) · [Agent Teams](38-agent-teams.md) · [Dynamic Workflows](39-dynamic-workflows.md)
- [Verification](04-verification.md) — verifier integrity and the coverage problem
- [Common Failure Patterns](17-failure-patterns.md) — Verifier Theater, Parallel Collision
