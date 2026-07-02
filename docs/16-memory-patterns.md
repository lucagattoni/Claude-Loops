# Memory Patterns for Long-Running Loops

A loop that runs for hours or days needs external memory. Build it into the loop.

## Pattern A: Progress file

```text
At the end of each task, append to PROGRESS.md:
- Task: [name]
- Status: [done|blocked|in-progress]  
- Files changed: [list]
- Next: [what the loop should do when it resumes]
```

## Pattern B: GitHub Issues as a task queue

```text
1. Loop reads open issues labeled "loop-task"
2. Picks the highest-priority one
3. Implements, tests, commits, opens PR
4. Labels issue "loop-done" and moves to next
```

## Pattern C: Spec-driven loop

```text
1. Write SPEC.md with all requirements and acceptance criteria
2. Loop implements one requirement at a time
3. Each requirement has a verifiable test
4. Loop stops when all tests pass
```

## Pattern D: Multi-Backend Task Queue

For multi-agent fleets, the task queue can live in the communication tools the team
already uses, enabling agents to self-assign work without a separate coordination
server:

**Slack/Discord thread claiming:**
```
1. Agent reads channel for messages tagged with a claim keyword (e.g. "clem:todo")
2. Agent replies to claim the thread (marks it as in-progress)
3. Agent posts progress updates to the thread as it works
4. Agent posts final result and marks the thread resolved
```

**GitHub Issue label workflow:**
```
1. Maintainer labels an issue "clem:todo"
2. Agent detects the label, self-assigns the issue
3. Agent implements the fix, opens a PR referencing the issue
4. Agent labels the issue "clem:done" and removes "clem:todo"
```

The advantage over a file-based queue: the task state is visible to the whole team
in the tools they already monitor, with no separate dashboard needed.

(clem — [jahwag/clem](https://github.com/jahwag/clem), Jun 2026.)

## Three-Tier Document Lifecycle

For long-running loops that accumulate knowledge across many cycles, a flat memory file
(Pattern A: PROGRESS.md) eventually becomes too large to prepend to every prompt. The
solution: separate memory into three tiers with different scopes and retention policies.

| Tier | Directory | What it stores | Retention |
|---|---|---|---|
| **Per-cycle** | `.tenet/runs/<slug>/` | Interview transcript, generated spec, cycle journal (what happened, deviations, decisions) | Retained per run; not prepended to future runs automatically |
| **Project doctrine** | `.tenet/project/` | Architecture decisions, testing practices, module boundary rules | Persistent; always prepended to agent context |
| **Reusable knowledge** | `.tenet/knowledge/` | Technical decisions, API contracts, cross-cycle patterns | Persistent; prepended when relevant (retrieved via similarity search) |

The key insight: project doctrine (what the team has decided) and per-cycle journals (what
happened this run) should not live in the same file. Mixing them causes the persistent
context to grow unboundedly across cycles.

**Comparison to other memory patterns in this doc:**
- Pattern A (PROGRESS.md) = per-cycle tier only; no separation between doctrine and journals
- Pattern E (STATE.md) = execution phase tracking, not content
- Pattern F (Graphiti) = entity state tracking with temporal validity
- Three-Tier Lifecycle = full knowledge management separating doctrine from per-run noise

([JeiKeiLim/tenet](https://github.com/JeiKeiLim/tenet), Jun 2026.)

## Pattern E: STATE.md Wave Recovery

For loops with multiple sequential phases (e.g. the five-wave execution model),
STATE.md tracks phase-level progress rather than just task completion:

```markdown
# STATE.md
current_wave: 3
waves_completed: [1, 2]
wave_3_status: in_progress
wave_3_started: 2026-06-24T05:20:00Z
deviations: []
```

On crash or interruption, the orchestrator reads STATE.md and **resumes from the
last completed wave** — not from the beginning. This is distinct from GOAL.md
(tracks the goal's done condition) and PROGRESS.md (tracks individual task completion):
STATE.md tracks multi-phase execution state.

The recovery check at startup:
```
Read STATE.md
→ if current_wave is in_progress → resume from wave N (restart this wave's agents)
→ if all waves completed → run finalization
→ if STATE.md missing → this is a first run, initialise
```

(session-orchestrator — [Kanevry/session-orchestrator](https://github.com/Kanevry/session-orchestrator), Jun 2026.)

## Pattern F: Temporal Knowledge Graph

For multi-loop deployments where stale state causes coordination failures, a temporal
knowledge graph is a richer alternative to flat STATE.md files.

**[Graphiti](https://github.com/getzep/graphiti)** (open-source, 27.9k★, [arXiv:2501.13956](https://arxiv.org/abs/2501.13956)) is a
temporal context graph engine built for AI agents. It is the open-source core of
[Zep](https://www.getzep.com), which runs it in production.

### Architecture

Graphiti represents memory as four interacting components:

| Component | What it stores |
|---|---|
| **Episodes** | Raw ingested data — the provenance layer; every derived fact traces here |
| **Entities (nodes)** | People, PRs, tasks, concepts — with summaries that update over time |
| **Facts (edges)** | Triplets (Entity → Relationship → Entity) with **validity windows** |
| **Custom Types** | Developer-defined entity/edge schemas via Pydantic models |

**How temporal invalidation works:** When a fact changes (PR merges, issue closes),
the old fact is invalidated with a timestamp — not deleted. The graph always knows
what was true *then* and what is true *now*. This is what prevents loops from acting
on stale state.

### Retrieval

Hybrid search combines three modes in a single query call:

```
semantic (embeddings) + keyword (BM25) + graph traversal
→ typically sub-second latency
```

No LLM summarization in the query path — retrieval is deterministic and fast.

### Installation

```bash
pip install graphiti-core             # base; uses Neo4j 5.26+ and OpenAI by default
pip install graphiti-core[anthropic]  # swap in Claude as the LLM provider
```

Supports alternative graph backends: FalkorDB, Kuzu, Amazon Neptune.
Supports alternative LLMs: Anthropic, Groq, Google Gemini.

### Loop integration pattern

```python
from graphiti_core import Graphiti

g = Graphiti("bolt://localhost:7687", "neo4j", "password")

# After each loop step — ingest the step's output as an episode
await g.add_episode(
    name="pr-88-merged",
    episode_body="PR #88 merged. Auth migration complete. Branch: feature/auth-v2.",
    source_description="CI Sweeper loop run 2026-06-25"
)
# Graphiti extracts entities (PR #88, branch feature/auth-v2) and facts
# (PR #88 → status → merged) and invalidates the previous "open" fact automatically.

# On next loop run — retrieve current-state context
results = await g.search("open PRs auth migration")
# Returns only facts within their validity window — stale "open" facts are excluded
```

### Distinction from flat-file patterns

| Pattern | What it tracks |
|---|---|
| **Pattern E (STATE.md)** | Execution phase: which loop wave is `in_progress`, which completed. A phase tracker. |
| **Pattern F (Graphiti)** | Entity state: current true status of every PR, issue, branch, and task the fleet has touched. An entity state store. |

The two complement each other: STATE.md says "wave 3 is running"; the knowledge graph
says "the three PRs wave 3 is working on are currently open, merged, and stale respectively."

([getzep/graphiti](https://github.com/getzep/graphiti), Jun 2026.)

## Pattern G: Repo-Owned Durable Ledger

The patterns above externalise memory to files; this pattern makes an explicit design claim
about *ownership*: **the repo should own the agent's context, not the agent** (or a cloud
transcript). Durable state lives in a versioned directory committed to the repo (`.ctxcarry/` —
state, events, session summaries), local-first, so context survives across tools, sessions, and
compaction without replaying a cloud transcript. Multi-tool handoff (Claude / Codex / local)
works because each tool reads the same token-budgeted summary files (`AGENTS.md` / `CLAUDE.md`).
([shouryasrivastava/ctxcarry](https://github.com/shouryasrivastava/ctxcarry), Jul 2026.)

**The ledger as a memo table.** A refinement of Pattern A (PROGRESS.md) that turns the progress
file into a *convergence* mechanism, not just a log. Treat a durable `progress.md` as a **memo
table** (in the dynamic-programming sense): a checklist caches already-solved steps and an
append-only decision log prunes failed branches, so the loop **never recomputes a settled
sub-problem** and never re-explores a dead end after a context reset. This shifts convergence
from implicit model memory (which compaction destroys) to explicit durable artifacts — a loop
that restarts mid-task resumes at the first unsolved step instead of from the beginning.
([peterCheng123321/loop-engineering](https://github.com/peterCheng123321/loop-engineering), Jul 2026.)

See [Context Management](13-context-management.md) for why compaction makes durable ledgers
necessary, and [Harness Patterns](24-harness-patterns.md#control-plane-execution-plane-split-kernel-gated-mutation)
for the kernel that can be the *sole authorized writer* to such a ledger.

---

See [Long-Running Agents](25-long-running-agents.md) for the architectural pattern
(Ralph loop / planner-worker-judge) that uses these memory strategies to coordinate
work across multiple context windows.
