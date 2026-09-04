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

> "The AI was never the hard part — the CHECKER is." — Sabrina Ramonov, Jun 2026

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

([orobsonn/claude-harness](https://github.com/orobsonn/claude-harness), Jun 2026.)

**Refinement: route eye-tier by severity, not by role alone.** A fixed cheap/mid/strong
split still spends "strong eyes" budget on low-stakes reviews. A `resolveEyeTier`
function instead computes the reviewer tier per-change: Opus for high-severity,
sensitive-path, or architectural-boundary changes; a Sonnet floor elsewhere; trivial
changes skip review entirely. It also **conditionally re-gates**: a grave fix
(irreversible, sensitive-path, re-architecture, multi-integration) demands a fresh
full Opus pass, while other HIGH-severity fixes only need a locked-test-plus-spot-check
pass — spending the expensive reviewer where the blast radius, not just the role,
justifies it. ([orobsonn/claude-harness v0.20.0](https://github.com/orobsonn/claude-harness/releases/tag/v0.20.0), Jul 2026.)

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
| Concurrent subagents per session | **20** — spawning a 21st fails with `Concurrent subagent limit reached` | `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` (requires v2.1.217+) |
| Total subagent spawns per session | **200** | `CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION` |

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
