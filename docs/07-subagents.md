# Subagents — Keep Main Context Clean

The context window is your most critical resource. Subagents protect it.

```text
Use subagents to investigate how our auth system handles token refresh.
Report a summary — I don't need the full file contents in this session.
```

The subagent reads dozens of files, runs grep searches, and reports back a concise
summary. Your main context grows by that summary only, not by every file read.

## Writer/Reviewer pattern

```text
Session A (Writer): "Implement rate limiting for /api/v1 endpoints"

Session B (Reviewer): "Review @src/middleware/rateLimiter.ts.
  Check for race conditions, edge cases, and consistency
  with existing middleware. Report gaps only."

Session A: "Here's the review: [Session B output]. Address the issues."
```

## DOER/CHECKER Pattern

A named, explicit form of the writer/reviewer pattern with a stronger principle:

- **DOER**: executes the task
- **CHECKER**: independently validates output — *never* the same agent that did the work

```text
Agent A (DOER): "Implement the login endpoint. Write tests."

Agent B (CHECKER): "Review the login endpoint in @src/auth/login.ts.
  Does it handle the three failure modes in SPEC.md?
  Report gaps only — do not suggest fixes."
```

The core rule: **never let the AI grade its own output.** A DOER is biased toward the
work it produced — the CHECKER must be a fresh session with no attachment to the
implementation.

> "The AI was never the hard part. The CHECKER is."
>
> — Sabrina Ramonov, ["Loop Engineering"](https://www.sabrina.dev/p/loop-engineering-claude-code-goal-routines), Jun 2026

**Why external evaluation enables improvement** (and self-assessment does not):
A generator agent assessing its own output has no gradient — it rated the work
acceptable before it generated it. An external evaluator with concrete, objective
criteria creates a signal the generator can actually improve against. This is
analogous to the GAN (Generative Adversarial Network) training dynamic: the
generator improves because the discriminator provides real pressure.

**Independence has two axes, not one.** A fresh session removes *context* bias, but a
same-model CHECKER still shares the DOER's *training* blind spots — it can rationalise the
same mistakes because it reasons from the same priors. A growing Jun 2026 pattern adds a
**model-diversity** axis: run the CHECKER on a *different model* (the recurring config is
Claude implements, Codex reviews). This is distinct from the cost-asymmetry below — the goal
here is catching what one model is systematically blind to, not saving tokens. See
[Verifier Integrity → cross-model independence](04-verification.md#verifier-integrity-keeping-the-check-unfakeable)
for the full pattern and its dual stop condition.

### "Strong Eyes, Cheap Hands" — cost-asymmetric role allocation

The DOER and CHECKER do not need the same model. Because judgment is rarer and
higher-stakes than typing, allocate models by role rather than uniformly:

| Role | Job | Model class |
|---|---|---|
| **Cheap hands** | Write code, author tests, execute — constrained by deterministic rails | Cheapest capable model (e.g. local Ollama) |
| **Throughput middle** | Orchestrate, route, high token volume | Mid model (e.g. Sonnet) for throughput, not deep judgment |
| **Strong eyes** | Plan, review the plan, adversary, security — the decision points | Most capable model (e.g. Opus), used *only at the gates* |

> "Cheap orchestration at high volume, expensive reasoning only at the edges."

The economics: the expensive model makes rare, critical decisions while the cheap
model does high-volume work — and crucially, **"the cheaper the orchestrator, the more
the deterministic rails must carry the judgment."** A cheap DOER is only safe when the
verifier and gates around it are strong (frozen tests, external checks — see
[Verifier Integrity](04-verification.md#verifier-integrity-keeping-the-check-unfakeable)).
This pairs the maker/checker split with the cost discipline in [Cost & Turn Control](11-cost-control.md).

([orobsonn/claude-harness](https://github.com/orobsonn/claude-harness) — repo no longer publicly reachable; 404 as of 2026-09-05, Jun 2026. **The quotes above cannot be re-verified:** this source was live when they were captured (Jun–Jul 2026) and has since been withdrawn, with no Wayback snapshot (checked 2026-09-06). They are kept, dated, and flagged rather than deleted — see `CLAUDE.md` § *Quoting a source that has since died*.)

**Refinement: route eye-tier by severity, not by role alone.** A fixed cheap/mid/strong
split still spends "strong eyes" budget on low-stakes reviews. A `resolveEyeTier`
function instead computes the reviewer tier per-change: Opus for high-severity,
sensitive-path, or architectural-boundary changes; a Sonnet floor elsewhere; trivial
changes skip review entirely. It also **conditionally re-gates**: a grave fix
(irreversible, sensitive-path, re-architecture, multi-integration) demands a fresh
full Opus pass, while other HIGH-severity fixes only need a locked-test-plus-spot-check
pass — spending the expensive reviewer where the blast radius, not just the role,
justifies it. ([orobsonn/claude-harness v0.20.0](https://github.com/orobsonn/claude-harness/releases/tag/v0.20.0) — repo no longer publicly reachable; 404 as of 2026-09-05, Jul 2026.)

### Tuning evaluator agents

Out-of-the-box, Claude exhibits poor QA discipline in evaluator roles:
- Identifies issues but then talks itself into accepting them ("it works in most cases")
- Tests the happy path only; does not probe edge cases
- Grades against intent rather than observable behaviour

Fix with explicit prompt refinement against real examples of divergent judgment:
- Show the evaluator an example where it should have blocked but did not, and explain why
- Require it to output *evidence* (test output, stack trace, reproduction steps) — not verdicts
- Instruct it to fail loudly on any criterion not met, with no partial credit

Tuning the evaluator is iterative: expect 3–5 prompt refinement cycles before it
produces reliable results. (Anthropic Engineering, Mar 2026.)

## Synthesis — The Non-Delegable Bottleneck

DOER/CHECKER captures verification independence. A second, harder-to-see bottleneck
is **synthesis** — the coordinator converting distributed results into concrete next
prompts.

The failure mode is "task forwarding masquerading as coordination": the orchestrator
receives outputs from multiple agents and passes them verbatim to the next agent
without synthesising them. The next agent then does synthesis work inside a cluttered
context, without the coordinator's full picture.

| Delegable to subagents | Must stay with the coordinator |
|---|---|
| Research, implementation, verification | Integrating findings across agents |
| Specific checks, targeted reads | Deciding what matters from combined outputs |
| Parallel execution of defined tasks | Writing the concrete next prompt |

If your orchestrator's output is "here are the results from agents A, B, C" — that
is task forwarding. Synthesis looks like: "Based on A's auth race condition finding
and B's retry logic finding, the next step is exactly X."

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

## Confidence-Scored Quality Gates

Between phases, a quality gate can suppress low-confidence findings rather than
propagating noise upstream:

- A reviewer audits deliverables across a defined set of dimensions
- Each finding is scored for confidence (0–100%)
- Only findings above a confidence threshold surface to the orchestrator or user
  (the session-orchestrator uses **≥80%** as its threshold; calibrate to your
  verifier's false-positive rate)
- Low-confidence findings are logged but suppressed — they do not block or notify

Use confidence scoring for heuristic checks (code quality, design coherence) where
the verifier itself has inherent uncertainty. Keep binary gates (exit 0 / exit 2) for
deterministic checks (test pass/fail, lint errors) — those are never confidence-scored.

(session-orchestrator — [Kanevry/session-orchestrator](https://github.com/Kanevry/session-orchestrator), Jun 2026.)

## A capped subagent used to look finished — it doesn't anymore

**Fixed in v2.1.246:** "Improved subagent results: a subagent that stops at its `maxTurns` limit
now returns its output marked as partial, with a hint to continue it via `SendMessage`, instead of
appearing finished."

This is the platform fixing, at the runtime level, close to what [Session
Architecture](37-session-architecture.md#the-finding-that-actually-mattered) documents by hand as a
case study: a fan-out where agents died mid-work and the coordinator reported a clean result anyway,
because nothing distinguished "returned everything" from "returned whatever it had when it got cut
off." That case study's deaths came from a *session limit* killing background agents outright; a
`maxTurns` cap is a different, gentler trigger — the agent stops on its own, by design — but before
v2.1.246 the two were indistinguishable to whatever consumed the result: a coordinating session, a
CHECKER in the DOER/CHECKER pattern above, or a workflow's `agent()` call (see [Dynamic
Workflows](39-dynamic-workflows.md#the-script-api) for the workflow-side half of this).

It's a partial fix, not the whole one — the result now carries the flag, but a caller still has to
check for it before treating "returned" as "done." The corrective is the same one that case study
drew: don't collapse completion into pass/fail. See [Verification → Loop Verdict
Taxonomy](04-verification.md#loop-verdict-taxonomy) for the six-verdict shape (`pass` / `fail` /
`handoff` / `timeout` / `stopped` / `awaiting-merge`) a bare pass/fail hides exactly this kind of
truncation inside.

## Running in the background (version-stamped)

| Version | Change |
|---|---|
| v2.1.198 | "Subagents now run in the background by default, so Claude keeps working while they run and is notified when they finish (previously a gradual rollout)" |
| v2.1.259 | "Improved nested background subagent results to be saved in the parent subagent's transcript, so resumed subagents keep them and shared transcripts show the delivery" |
| v2.1.260 | "Removed the one-hour time limit on background commands started by subagents; they now run until they exit or are stopped, matching the main session" |

Before v2.1.198, delegating a subagent meant your own turn blocked until it returned — the
wall-clock cost of "spawn a subagent" was the subagent's full runtime, paid synchronously. Once
subagents run in the background by default, that cost changes shape: the session keeps working
and is notified when the subagent finishes, so the immediate cost of delegating is closer to
sending a message than to making a blocking call — the runtime cost is still there, it's just no
longer sitting on your turn.

v2.1.259 matters specifically for [nested](#nesting) delegation: before it, a background subagent
spawned by another subagent could return a result the *parent* subagent's own transcript never
recorded — a resumed parent, or a shared transcript view, could silently miss a delivery that
happened while nobody was looking at that layer.

v2.1.260 removed a cap that applied to subagents but not the main session: a background Bash
process a subagent started used to get killed after an hour regardless of whether it was still
useful; it now runs until it exits or is stopped, the same rule the main session already had.

## Built-in subagent types

Claude Code ships with named subagent types you can invoke directly:

| Type | Model | Tools | Use when |
|---|---|---|---|
| `fork` | Same as parent | All (inherits context) | Fast parallel work — shares parent's prompt cache |
| `general-purpose` | Same as parent | All | Standard isolated subtask |
| `Explore` | Inherits main conversation's model[^explore] | Read-only | Fast codebase search; skips CLAUDE.md and git status for speed |
| `Plan` | Same as parent | Read-only | Architecture planning in plan mode |

`fork` is the cheapest subagent — it inherits the parent's context and prompt cache,
so it starts fast and shares what the parent already knows.

[^explore]: **Changed in v2.1.198.** Explore previously always ran on Haiku. Official docs now
    state it *"inherits from the main conversation, capped at Opus on the Claude API, so Explore
    never runs on a more expensive model than the one you already chose for the session, unless you
    set `CLAUDE_CODE_SUBAGENT_MODEL` and force it onto every subagent."* On Bedrock, Vertex,
    Foundry and Claude Platform on AWS it inherits directly, with no Opus cap. **Cost consequence:**
    "Explore is cheap because it's Haiku" is no longer true by default — a session on Opus runs
    Explore on Opus. To pin it, define a project subagent named `Explore` with `model: haiku`; a
    user or project subagent of that name overrides the built-in and keeps its own `model` field.
    ([subagents reference](https://code.claude.com/docs/en/sub-agents))

## Custom agents (`.claude/agents/`)

Define reusable agent roles with frontmatter in `.claude/agents/<name>.md`:

```markdown
---
name: security-reviewer
description: Audits code for injection, auth flaws, and exposed secrets
model: claude-sonnet-5
tools: Read, Grep, Glob, Bash
permissionMode: auto
---
You are a senior security engineer. Flag: SQL/XSS/command injection,
auth/authz flaws, secrets in code, insecure data handling.
Provide file:line references and suggested fixes.
```

Invoke with: `Use a subagent: security-reviewer — review @src/auth/`.

Agent files are loaded from (in priority order): managed settings → `--agents` CLI
flag → `.claude/agents/` → `~/.claude/agents/` → plugin `agents/`.

**Hand-editing that file is now the only path — the wizard is gone.** v2.1.198, verbatim:

> Removed the `/agents` wizard; ask Claude to create or manage subagents, or edit `.claude/agents/`
> directly.

`/agents` still exists as a command; running it now prints that reminder rather than opening the
interactive **Running** / **Library** interface it opened on v2.1.197 and earlier. The file format,
frontmatter fields and the two directory locations are unchanged — only the authoring UI went.
The nudges went with it: v2.1.232 also removed *"the startup tip and `/powerup` nudge to create
custom subagents."*

For a loop this is the useful direction of travel, not a loss: a subagent defined by a **file in the
repo** is reviewable, diffable and reproducible on another machine, which a wizard-created one never
was. Generate the file from a template if you make many.

(Three of this KB's other claims also come from v2.1.198 — background-by-default subagents above,
`claude --bg -p` rejection in [Background Agents](29-background-agents.md), and the Explore agent's
model inheritance below. They are four separate bullets in one release; do not merge them.)

### Which model actually wins — the env var is a default, not a ceiling

A pinned `model:` field above looks authoritative, but it is not the only thing that decides
what a subagent runs on. Four sources compete, and the ranking **changed in v2.1.251**:

| Rank | Source | Since |
|---|---|---|
| 1 (highest) | `model` Claude passes at spawn time (per-invocation) | Always |
| 2 | This agent definition's `model:` frontmatter (`inherit` = main conversation's model) | Wins over `CLAUDE_CODE_SUBAGENT_MODEL` **only since v2.1.251** |
| 3 | `CLAUDE_CODE_SUBAGENT_MODEL` env var | Default-only since v2.1.251; was rank 1 before that |
| 4 (lowest) | Main conversation's model | Always |

**Setting `CLAUDE_CODE_SUBAGENT_MODEL` is a default, not a guarantee.** An agent definition's own
`model:` field silently outranks it — a `security-reviewer` pinned to `opus` still runs on Opus
even if the shell exports `CLAUDE_CODE_SUBAGENT_MODEL=haiku`. To force a hard ceiling with no
exceptions, set `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` (v2.1.257+), which skips ranks 1–2 for every
subagent, teammate, and workflow agent (a `fork` and a `model: inherit` skill run stay exempt).

Verify rather than assume: `/tasks` and the agent detail dialogs show the model **and effort
level** each subagent actually ran on (v2.1.243+), so which rung applied on a given run is
checkable, not guessed. Full precedence table, the `_FORCE` mechanics, and the practical read on
using `/tasks` to audit it: [Cost & Turn Control → Which model a subagent actually runs
on](11-cost-control.md#which-model-a-subagent-actually-runs-on).

## Cache-Safe Forking and Isolated Child State

A third-party technical analysis of Claude Code's published package (file/line-cited, not
an Anthropic disclosure — treat as this analysis's own findings about a specific build,
not a stable public API) describes the concrete mechanics behind "a subagent has its own
context window": forking preserves a specific set of **cache-critical parameters**
(system prompt, user context, system context, tool-use context, forked-context messages)
so the fork still hits the parent's prompt cache, while everything else about the child's
state starts isolated by default — a fresh `abortController` not shared with the parent, a
wrapped app-state getter that suppresses permission prompts, and a no-op state setter. A
subagent shares nothing beyond the cache-critical set unless the caller explicitly opts
in (shared abort controller, shared state setter, shared response length). One practical
warning from the same source: changing `maxOutputTokens` on a fork is not free — the
thinking-config is part of the cache key, so casually varying it defeats the cache hit the
whole scheme exists to preserve.

The same analysis identifies the concrete hook payloads around a subagent's lifecycle:
`SubagentStart` carries `agent_id`/`agent_type`; `SubagentStop` carries
`agent_transcript_path`; and a `SubagentStop` hook that exits with code 2 feeds its stderr
back to the subagent and keeps it running rather than ending the task — the same
non-zero-exit-continues-the-loop contract [Hooks](12-hooks.md) documents for the main
session's own stop hook.
([Harness Books — AgentWay, "Multi-Agent & Verification"](https://harness-books.agentway.dev/book1-claude-code/chapter-07-multi-agent-and-verification.html), undated, fetched Sep 2026.)

## Nesting

Subagents can spawn their own subagents **up to three layers below the main conversation by
default** — a configurable default, not a fixed cap. Use this for hierarchical delegation:
orchestrator → specialist → verifier.

> "By default, a subagent can spawn subagents of its own, up to three layers below the main
> conversation. At the depth limit, Claude Code withholds the Agent tool from every subagent except
> a fork, so a subagent at the limit does its delegated work itself and returns one summary."
>
> — [Subagents reference](https://code.claude.com/docs/en/sub-agents)

### Limits, and how they have moved

| Limit | Default | Override |
|---|---|---|
| Nesting depth below the main conversation | **3** | `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` (set to `1` to disable nesting) |
| Concurrent subagents per session | **20** — the Agent tool refuses to spawn another until one finishes. The variable takes a positive whole number in plain digits; anything else is ignored, so it can raise or lower the cap but **cannot disable it** | `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` (requires v2.1.217+) |

There is **no cap on total spawns over a session** — only the two limits above. A 200-spawn
per-session cap did exist (added v2.1.212) and was **removed in v2.1.224**: *"Removed the
200-subagent-per-session spawn cap; long-running sessions no longer refuse new agents (concurrency
and depth limits still apply)."* The current [subagents reference](https://code.claude.com/docs/en/sub-agents)
says plainly: *"Two limits control subagent use, each with its own variable… There's no limit on the
total number of subagents Claude can spawn over a session."*

**Version history — the number changed twice in one week, so pin your assumptions to a version:**

| Versions | Default depth |
|---|---|
| v2.1.172 – v2.1.216 | 5, and **not changeable** |
| v2.1.217 – v2.1.218 (from 2026-07-21) | **1** — *"Changed subagents to no longer spawn nested subagents by default; set `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` to allow deeper nesting."* |
| v2.1.219 onward (from 2026-07-24) | **3** — *"Subagents can now spawn nested subagents up to depth 3 by default (was 1); set `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` to disable nesting."* |

!!! warning "This entry corrects an error"
    Earlier versions of this page stated *"up to 5 levels deep"*, citing a June 2026 source. That
    was true for v2.1.172–v2.1.216 and is now wrong on two counts: the default is **3**, and it is
    **configurable** rather than fixed. A platform limit sourced from a dated post is an
    unversioned claim — the lesson generalises to every number in this knowledge base.

Forked subagents (`subagent_type: "fork"`) inherit the full parent context and
prompt cache — ideal when the subtask needs all the context the parent has built up.

**Quantified payoff of recursive spawning.** A Recursive Agent Harness (RAH) pattern —
parent agents spawn subagents in parallel, recursively, rather than a fixed one-level
fan-out — improved a baseline from 71.75% to 89.77% on Oolong-Synthetic when paired with
a stronger backbone model, evidence that the *depth* of delegation (not just breadth) is
a real lever, not just an organisational convenience.
([arXiv 2606.13643](https://arxiv.org/abs/2606.13643), Jun 2026.)

## Controlling subagent permissions

Restrict which subagents can be spawned or what models they can use:

```json
// .claude/settings.json
{
  "permissions": {
    "deny": [
      "Agent(model:opus)",    // block Opus subagents (cost control)
      "Agent(Explore)"        // disable the Explore built-in
    ]
  }
}
```

Disable all subagent delegation:
```json
{ "permissions": { "deny": ["Agent"] } }
```

Disable built-in agents in headless mode only:
```bash
CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS=1 claude -p "task"
```

**These restrictions had real enforcement gaps before specific versions — verify you're past all
four before treating a deny rule or MCP restriction here as load-bearing for cost or security:**

| Fixed in | Gap |
|---|---|
| v2.1.153 | A subagent's own frontmatter `mcpServers` ignored `--strict-mcp-config`, `--bare`, remote mode, enterprise managed MCP config, and managed-settings MCP server allow/deny policies — a subagent-declared server could bypass a policy the session was meant to enforce. |
| v2.1.178 | Server-level MCP specs in a subagent's `disallowedTools` (`mcp__server`, `mcp__server__*`, `mcp__*`) were silently ignored; a per-tool spec (`mcp__server__toolname`) was unaffected. |
| v2.1.178 | *"Subagent spawns are now evaluated by the classifier before launch, closing a gap where a subagent could request a blocked action without review"* — auto mode previously reviewed a session's own tool calls but not the spawn itself. |
| v2.1.186 | The `Agent(model:opus)`-style `deny` rule above, and `Agent(x,y)` allowlists, were **not enforced for named subagent spawns** before this version — the syntax only became reliable here. |

(All four: [CHANGELOG.md](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md).)

## Adversarial Reviewer Checklists

A reviewer subagent that works from a structured checklist catches categories of failure
that open-ended review misses. Apply two sequential checklists: one at the spec stage
before implementation begins, one at the implementation stage before merge.

### Spec-stage checklist (9 checks)

| Check | Failure signal | Fix |
|---|---|---|
| **Vague Objective** | Untestable outcome ("it should be fast") | Demand measurable numbers |
| **Boundaries underspecified** | Empty Always/Ask/Never sections | Fills → scope creep guarantee |
| **Missing Acceptance Criteria** | No done-checklist | "Done" must be enumerated items |
| **No `Constrained by:` citation** | Unlinked ADRs/RFCs | Spec must cite constraints explicitly |
| **Implementation detail in spec** | How, not What | Spec = outcomes; code = how |
| **Plan/spec mismatch** | Task ↛ AC or AC ↛ task | Every task maps to an AC; every AC has a task |
| **Contract vs. construction confusion** | Conflating interface design with module layout | Keep interface decisions in spec; layout in code |
| **Missing `Depends on:` per task** | Implicit dependency graph | Make dependencies explicit |
| **No verification mode per task** | Ambiguous validation intent | Name TDD / goal-based / visual-manual per task |

### Implementation-stage checklist (9 checks)

| Check | Failure signal | Fix |
|---|---|---|
| **AC coverage** | An AC has no verification artifact that would fail if broken | Add test or goal-check per AC |
| **Edge cases** | Empty/max/malformed/concurrent/partial failure untested | Must be enumerated |
| **Error surface** | Caller cannot distinguish error types | Name the error surface |
| **Scope** | Out-of-scope change present | Requires `Bundled fixes:` justification |
| **Spec drift** | Status not updated, AC not `[x]`-ed, deferred items not in backlog, broken intra-repo refs | 4 invariants must hold |
| **Security and privacy** | No review | Explicit check required |
| **Architectural fit** | New module boundary without ADR | Block until ADR written |
| **Backward compatibility** | Breaking change unmarked | Must be flagged |
| **Project anti-patterns** | Violations of `AGENTS.md` conventions | Cite the violation and block |

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Jun 2026.)

**The "tenth-man" variant**: rather than a checklist, a fresh-context critic is given an
explicit standing prior — assume the signed-off plan is wrong and find out why — before it
reads anything. Paired with a design-interview gate that withholds implementation until
confidence reaches ≥95% across every dimension of the spec. See [Concrete STOP+Verifier
Implementations](27-loop-contract.md#concrete-stopverifier-implementations-sept-2026-cohort)
for the full citation. Two further review-axis additions worth naming alongside the two
checklists above: **citation verification** (does a cited source actually say what the
document claims — catches misattribution a plain "reviewers agree" pass misses) and
**prior-art collision search** (does this "novel" claim already exist uncited elsewhere) —
two axes orthogonal to reviewer agreement, motivated by the author's own documented
citation-misattribution slip that a cross-source review pass had missed.
([maskshell/solidforge](https://github.com/maskshell/solidforge), Sep 2026.)

## Rationalizations Reviewers Must Refuse

Reviewer subagents can be prompted (via context accumulation or sycophancy pressure)
to soften verdicts. Name these rationalizations explicitly to make them blockable:

| Rationalization | Rebuttal |
|---|---|
| "Diff looks clean — return Clean after one pass" | One pass is insufficient for critical paths. Read twice before Clean. |
| "Spec was reviewed last PR — skip spec checks" | Spec drift is in scope every PR. |
| "Author is senior — soften the severity" | Severity is about the change, not the author. |

These must be listed in the reviewer's system prompt, not just the CLAUDE.md. A reviewer
that wasn't told to refuse them will rationalize.

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Jun 2026.)

## Related

- [Background Agents](29-background-agents.md) — sessions running independently (not within a parent session)
- [Fan-Out](10-fan-out.md) — parallelism using multiple subagents
- [Hooks](12-hooks.md) — SubagentStart/SubagentStop lifecycle events
- [Session Architecture](37-session-architecture.md#the-finding-that-actually-mattered) — the
  Pinakes case study on dead agents reporting a clean result
- [Dynamic Workflows](39-dynamic-workflows.md) — `agent()`, the workflow-script call that spawns a
  subagent the way this page describes, plus its own `maxTurns`-adjacent structured-output limits
- [Verification](04-verification.md#loop-verdict-taxonomy) — the six-verdict taxonomy that a bare
  pass/fail hides truncation inside
- [Agent Teams](38-agent-teams.md) — teammates that message each other directly instead of reporting back; the same definition can serve as either
