# Memory Patterns for Long-Running Loops

A loop that runs for hours or days needs external memory. Build it into the loop.

## First: the harness has its own memory now — and it is not this

Since **v2.1.32** Claude Code writes memory for itself, without being asked. Named
**auto memory** at **v2.1.59** (*"Claude automatically saves useful context to auto-memory.
Manage with /memory"*), it is **on by default**. So the first question this doc has to answer is
no longer "how do I give the loop memory" but **"the harness already remembers — do I still need
Patterns A–J?"**

For a loop: **yes, and auto memory is not a substitute.** Not because it works badly — it works as
designed — but because every property that makes it good at its job makes it wrong as a loop's
system of record.

### What it actually is

Claude saves four kinds of note for itself, tagged by a `type` frontmatter field:

> Auto memory lets Claude accumulate knowledge across sessions without you writing anything. As it
> works, Claude saves four kinds of notes for itself. Claude records the kind as a `type` field in
> the memory file's frontmatter:
>
> - `user`: your role, expertise, and working preferences
> - `feedback`: corrections you give Claude and approaches you confirm
> - `project`: ongoing work, deadlines, and decisions that Claude can't derive from the code or git history
> - `reference`: where to find information outside the project

It also decides *whether* to save at all: *"Claude doesn't save something every session. It decides
what's worth remembering based on whether the information would be useful in a future
conversation."* And it deliberately skips *"anything your CLAUDE.md files already say."*

| | |
|---|---|
| **Storage** | `~/.claude/projects/<project>/memory/` — a `MEMORY.md` index plus one file per memory. Override with `autoMemoryDirectory` (added **v2.1.74**; per-config-directory behaviour requires **v2.1.234+**) |
| **Scope** | Per **git repository** — *"All worktrees and subdirectories within the same git repository share one auto memory directory"* (worktree sharing added **v2.1.63**) |
| **Portability** | *"Auto memory is machine-local. […] Files are not shared across machines or cloud environments."* |
| **Loaded** | *"the first 200 lines of MEMORY.md, or the first 25KB, whichever comes first"*, every session. Beyond that is not loaded |
| **Over-limit** | Since **v2.1.210** an over-limit index write *"produce[s] an explicit error instead of silent truncation."* Before that it was truncated silently |
| **Subagents** | *"The main conversation's auto memory isn't loaded into subagents; the exception is a fork […]. A subagent's own auto memory, enabled with the subagent `memory` field, is a separate directory"* — `~/.claude/agent-memory/<name-of-agent>/` (user scope) or `.claude/agent-memory/<name-of-agent>/` (project scope), added **v2.1.33** |
| **Off switch** | `/memory` toggle → `autoMemoryEnabled` in settings; or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`. Setting it to **`0` forces it on** even where `--bare` or `autoMemoryEnabled: false` would disable it |
| **Timestamps** | An ISO-8601 `modified` frontmatter field, **v2.1.214+** |

(All quotations from [How Claude remembers your project](https://code.claude.com/docs/en/memory)
and [Subagents](https://code.claude.com/docs/en/sub-agents); every version number verified against
the [official changelog](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md),
fetched 20260906.)

### The sentence that decides it for loop design

> Claude treats them as context, **not enforced configuration**. To block an action regardless of
> what Claude decides, use a `PreToolUse` hook instead.

That is the official framing of both CLAUDE.md and auto memory. A loop's STOP condition, budget
and scope must **hold**; a memory note is advice the model may or may not take. This is the same
distinction [Failure Patterns](17-failure-patterns.md) draws between a rule written as prose and a
rule written as a gate — and the same one this KB keeps re-learning about its own `SKILL.md` files.

### Five properties, and why each one disqualifies it as loop state

| Auto memory is… | A loop's durable state must be… |
|---|---|
| **Agent-curated** — Claude decides what is worth saving, and may save nothing | **Complete for the contract.** A resume file that omits a step because the agent judged it uninteresting cannot resume |
| **Machine-local**, never synced to other machines or cloud | **Portable.** A loop that resumes in a Routine, a cloud session, or on a colleague's machine finds no memory there at all |
| **Invisible to subagents** (fork excepted) | **Shared with the workers.** Fan-out patterns ([Fan-Out](10-fan-out.md)) need every worker to see the same state |
| **Unenforced** — context, not configuration | **Binding**, or verified by something that is |
| **Not under version control** — outside the repo, no diff, no review, no history | **Auditable.** *Who wrote this and when* is the first question when a loop goes wrong |

Every Pattern A–J below is the opposite on the property that matters: a `PROGRESS.md`, a
[repo-owned ledger](#pattern-g-repo-owned-durable-ledger) or a
[STATE.md](#pattern-e-statemd-wave-recovery) lives **in the repo** — so it is portable, diffable,
reviewable, visible to every subagent and machine, and it survives the harness being swapped out.

### Three failure modes, from the issue tracker

These are **user reports on `anthropics/claude-code`**, not vendor-confirmed defects — cited
because they are reproducible descriptions of the risk shape, and because two of the three were
**closed as `stale` rather than fixed**. Verified open/closed state and labels on 20260906.

| Issue | Shape | State |
|---|---|---|
| [#37314](https://github.com/anthropics/claude-code/issues/37314) — *"Claude repeatedly fails to apply its own memory/feedback — same mistakes recur across sessions"* | Stored ≠ applied. The note is written, acknowledged, even strengthened — and the same mistake follows. Memory is a **pull**, and the pull can simply not happen | closed, labelled `memory` + `stale` |
| [#75405](https://github.com/anthropics/claude-code/issues/75405) — *"Reliability: model asserted untrustworthy 'tested/ready' status from stale memory without verifying artifacts"* | **The dangerous one for a loop.** A recalled summary was trusted over the on-disk artifacts, and a pipeline was reported ready when the evidence had been lost. *"Memory says it was tested"* is not *"artifacts prove it was tested"* | open, labelled `stale` |
| [#47959](https://github.com/anthropics/claude-code/issues/47959) — *"Auto Dream deletes memory files without user consent — 23 files lost in one day"* | A memory-consolidation behaviour removed 23 accumulated files with no confirmation and no deletion log. It is **not described on the official memory page**, so treat it as an unannounced behaviour reported by a user, not a documented contract | closed, labelled `memory`, `data-loss`, `has repro`, `stale` |

#75405 is the one to design against, and it generalises past this feature: **a loop that verifies
against remembered state is not verifying.** The verifier must read the artifact — the test output,
the file, the exit code — exactly as [Verification](04-verification.md) argues. Auto memory makes
that mistake easier to make, because the recalled summary arrives already in context and reads as
fact.

### So use it for what it is

Auto memory is genuinely useful, at a different job: **an interactive session's memory of you**.
Preferences, corrections, the standing "don't do it that way" — the things a colleague would
remember and you would resent re-explaining. Nothing in Patterns A–J covers that, and hand-writing
it into CLAUDE.md is exactly the manual effort it removes.

**The rule:** if losing it would break the loop, it goes **in the repo**. If losing it would only
mean repeating yourself, auto memory is the right home.

**One consequence worth planning for.** Because auto memory is per-repository and machine-local, a
loop's own repo accumulates memory on the machine that runs it — and a scheduled or unattended loop
is exactly the case where nobody reads it. When it is not wanted, turn it off for that project with
`autoMemoryEnabled: false` in the project's settings rather than globally; `--bare` also skips it,
along with hooks, LSP and CLAUDE.md auto-discovery (see [Headless Mode](09-headless-mode.md)).

---

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
1. Discord: the agent claims a `#tasks` forum thread by renaming its title prefix from "[TODO]" to "[IN PROGRESS]"
2. Slack: the agent claims a top-level `#tasks` message by adding a reaction emoji to it
3. Agent posts progress updates to the thread as it works
4. Agent posts final result and marks the thread resolved
```

**GitHub Issue label workflow:**
```
1. Maintainer labels an issue "clem:todo"
2. Agent detects the label, self-assigns the issue, and swaps "clem:todo" for "clem:in-progress"
3. Agent implements the fix, opens a PR referencing the issue
4. Agent labels the issue "clem:done" (or "clem:blocked" if it cannot finish) and removes "clem:in-progress"
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

**[Graphiti](https://github.com/getzep/graphiti)** (open-source, 30.6k★ as of Sep 2026, [arXiv:2501.13956](https://arxiv.org/abs/2501.13956)) is a
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

Supports alternative graph backends: FalkorDB, Kuzu, Amazon Neptune. (Kuzu was marked deprecated upstream in Jun 2026 — still functional, but Neo4j or FalkorDB are the forward-looking choices.)
Supports alternative LLMs: Anthropic, Groq, Google Gemini.

### Loop integration pattern

```python
from datetime import datetime, timezone

from graphiti_core import Graphiti

g = Graphiti("bolt://localhost:7687", "neo4j", "password")

# After each loop step — ingest the step's output as an episode
await g.add_episode(
    name="pr-88-merged",
    episode_body="PR #88 merged. Auth migration complete. Branch: feature/auth-v2.",
    source_description="CI Sweeper loop run 2026-06-25",
    reference_time=datetime.now(timezone.utc),
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

**The blind-spot ledger.** A doctrine-tier artifact specifically for *review misses*: an
append-only log where each review cycle records *why* a finding was missed, categorised
(not just what was missed). The next review cycle reads the ledger and pre-checks those
categories before starting, so the same class of miss cannot recur silently. The success
metric is explicit and falsifiable — "reviewers stop finding the same category twice" —
rather than a vague aspiration to "learn from mistakes." Two independent implementations
converge on the same shape: one as a `docs/reviews/blind-spots.md` log feeding a
`/build-feature` loop, the other as a 5-stage Fail→Investigate→Verify→Distill→Consult
protocol writing to an Obsidian-readable vault, both gated by a stop-hook that blocks
session exit until the ledger is updated.
([ohyesgocool/feature-loop](https://github.com/ohyesgocool/feature-loop);
[hiphapis/loopcraft](https://github.com/hiphapis/loopcraft), Jul 2026.)

## Pattern H: LLM Wiki

Where Patterns A–G externalise a single loop's *task* memory, the LLM Wiki externalises
**organisational knowledge** the agent compiles and maintains across many unrelated
runs — a persistent, cross-linked knowledge base an LLM both writes to and queries,
rather than re-deriving the same facts from scratch each session:

```
raw/       ← unprocessed source material (transcripts, docs, notes)
wiki/      ← the compiled, cross-linked knowledge base pages
index.md   ← entry point / table of contents into wiki/
log.md     ← append-only record of what was ingested and when
claude.md  ← instructions for how the agent should ingest/query/lint this wiki
```

Three workflows operate on the structure: **ingest** (raw material → new or updated wiki
pages, with cross-links to related pages), **query** (answer a question by reading wiki/
first, falling back to raw/ only if the wiki doesn't cover it), and **lint** (periodically
check the wiki for orphaned pages, broken cross-links, and pages that duplicate content
better owned elsewhere — the wiki's own version of [KB_GAPS.md](https://github.com/lucagattoni/Claude-Loops/blob/main/KB_GAPS.md) hygiene).

This converged from three independent directions within a single quarter — Karpathy's
original gist (April), Google's Open Knowledge Format (published about two months later),
and Garry Tan's 23-role "gstack" — suggesting the
underlying idea (Markdown-as-agent-memory, compiled and maintained rather than replayed)
is becoming a convention rather than one person's technique. The shared thesis: as models
improve, the differentiator shifts from model quality to *the organisational knowledge the
agent reads and maintains* — the wiki, not the transcript, becomes the durable asset.
([Karpathy gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f);
[Cobus Greyling](https://cobusgreyling.substack.com/p/llm-wiki);
[The New Stack](https://thenewstack.io/markdown-agent-memory-moat/), Jul 2026.)

---

## Pattern I: Durable Objectives with Evidence Logs

For a local control plane coordinating one or more agent CLIs (Codex, Claude Code,
Cursor) across many restarts, persist state as a small set of typed artifacts rather
than one flat progress file:

- **Durable objectives** — the goal survives individual chat sessions and agent
  restarts; a new session picks up the same objective rather than re-deriving it
  from conversation history.
- **`claimed_by` todo ownership** — each todo item records which agent instance
  owns it, so multiple agents (or restarted instances of the same agent) never
  silently duplicate or collide on the same unit of work — a lighter-weight
  alternative to the Slack/GitHub claim workflows in
  [Pattern D](#pattern-d-multi-backend-task-queue) for setups without a shared
  chat/issue surface.
- **Append-only evidence logs** — every state change is written, never rewritten,
  so a later session (or a human) can reconstruct *why* the state is what it is,
  not just what it currently says.
- **Verifiable handoffs** — a handoff between sessions or agents preserves the
  original scope and boundaries explicitly, rather than trusting the receiving
  session to infer them from context.
- **Public/private boundary scanning** — before any artifact is committed or
  published, a scan checks for credentials and raw traces that shouldn't leave the
  private evidence log.

The project's own framing is a useful discipline: it explicitly refuses to be "an
autonomous production controller" — dangerous permissions, publishing, and
production writes stay with the human operator; the durable state exists to make
*resumption* safe, not to expand what the loop is allowed to do unattended.
([huangruiteng/loopx](https://github.com/huangruiteng/loopx), Jul 2026. See also the
[quota-aware should-run gate](27-loop-contract.md#quota-aware-should-run-gate) from
the same project, which governs *when* a claimed todo may actually be worked.)

---

## Pattern J: Learned Memory Substrates

Patterns A–I above are file- or ledger-based: memory is a document the loop reads and
writes. A different family of tools makes memory a **trained substrate** that improves from
its own recorded use rather than staying a static store.

- **RuVector** — a persistent agent-memory database (semantic/episodic/procedural/working/
  causal layers) that *learns* from recorded trajectories and rewards via small SONA
  MicroLoRA adapters, with EWC++ consolidation against catastrophic forgetting — a
  local-first parallel to [ruflo's AgentDB](22-learned-orchestration.md). The distinction
  from every flat-file pattern above: retrieval quality itself improves with use, rather
  than staying fixed at whatever the original schema supported.
  ([ruvnet/RuVector](https://github.com/ruvnet/RuVector), Sep 2026.)
- **funes** — an open-source persistent memory layer that indexes session traces from
  Claude Code, Codex, and other CLI agents (vector search + BM25 + reranking) so an agent
  can recall prior reasoning across machines and tool boundaries, rather than only within
  one CLI's own session store. Complements [Pattern F](#pattern-f-temporal-knowledge-graph)'s
  structured-fact approach with raw-trace retrieval for reasoning that was never distilled
  into a fact. ([huggingface.co/blog/funes](https://huggingface.co/blog/funes), Sep 2026.)
- **Computer History** — OpenAI's rebuild of its structured-memory research preview
  ("Chronicle") converts captured interaction events into memories and timelines, a
  vendor-native instance of the same session-state-persistence problem this doc otherwise
  documents via repo-owned files.
  ([learn.chatgpt.com, "Computer History"](https://learn.chatgpt.com/docs/customization/computer-history), Jun 2026.)

**A documented negative result, worth weighing against the above.** Not every learned
substrate earns its complexity. One harness builder added a vector-memory layer for
cross-session recall, ran it against a holdout of real retrieval tasks, and found it
scored **0 of 6** against plain `rg` (ripgrep) — and demoted it rather than keeping it as
a default. The lesson isn't "vector memory doesn't work," it's that a memory substrate is
itself a claim that should clear the same bar as any other harness component: measured
against the boring alternative, on your own tasks, before it becomes infrastructure other
agents depend on. ([DrSeedon/orchestra](https://github.com/DrSeedon/orchestra), Sep 2026.)

---

See [Long-Running Agents](25-long-running-agents.md) for the architectural pattern
(Ralph loop / planner-worker-judge) that uses these memory strategies to coordinate
work across multiple context windows.
