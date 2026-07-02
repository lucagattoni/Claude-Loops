# Loop Engineering News

Newest-first digest. Updated by the `fetch-loop-news` skill on each run.
Sources are defined in [`SOURCES.md`](https://lucagattoni.github.io/Claude-Loops/sources/).

---

## 2026-07-02 04:14 UTC (run)

A **theme-shifting** run, not gap-filling. Two convergent themes dominated, and the first of
them fills a standing KB gap: **(1) self-improving harnesses** — three independent sources
(two arXiv papers + one article/preprint) all report a harness that *evolves itself from its
own execution traces*, model held fixed, with real Terminal-Bench numbers (one **beats a
human-designed baseline**); and **(2) durable, repo-owned state that survives compaction** —
progress files as dynamic-programming memo tables, `.ctxcarry/`-style repo-owned context, and a
kernel that is the *sole authorized writer* to that state. The self-improving-harness theme
closes the documented "self-scaffolding / model-generated harness" gap; the state theme
sharpens the memory-vs-context boundary rather than adding a new primitive.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | arXiv | "Self-Harness: Harnesses That Improve Themselves" | [link](https://arxiv.org/abs/2606.09498) | **Self-improving harness**: 3-stage loop (Weakness Mining from traces → minimal Harness Proposal → regression Validation) with no external engineer; Terminal-Bench-2.0 gains, model fixed (MiniMax 40.5→61.9%, Qwen3.5 23.8→38.1%, GLM-5 42.9→57.1%). Fills the model-generated-harness gap. |
| 1 | arXiv | "Agentic Harness Engineering (AHE): observability-driven evolution" | [link](https://arxiv.org/abs/2604.25850) | Harness auto-evolves via three observability pillars (component/experience/decision); each edit is a **verified prediction contract**. Pass@1 69.7→77.0% over 10 iters, **beats human Codex-CLI baseline (71.9%)**, 12% fewer tokens, cross-family transfer; **ablation: gains from tools/middleware/memory, not prompts**. |
| 2 | Cobus Greyling | "HarnessX: When the Harness Starts Learning From Its Own Runs" (+ [arXiv 2606.14249](https://arxiv.org/abs/2606.14249)) | [link](https://cobusgreyling.substack.com/p/harnessx-when-the-harness-starts) | Third self-improving-harness source: **typed harness primitives over a substitution algebra** + AEGIS evolution engine refining prompts/tools/memory/control-flow from traces; +14.5% avg across 5 benchmarks (up to +44%). |
| 1 | peterCheng123321/loop-engineering | "Progress-ledger as a DP memo table" | [link](https://github.com/peterCheng123321/loop-engineering) | **Durable convergence**: a checklist caches solved steps and an append-only decision log prunes failed branches, so the loop never recomputes a settled sub-problem after a context reset — convergence moves from model memory to durable artifacts. Convergence layer over /loop, ralph-loop, Agent SDK. |
| 1 | shouryasrivastava/ctxcarry | "The repo should own your context, not the agent" | [link](https://github.com/shouryasrivastava/ctxcarry) | Local-first `.ctxcarry/` durable memory (state/events/summaries) vs. cloud transcript replay; worktree generators, evaluators-assume-broken, token-budgeted multi-tool (Claude/Codex/local) handoff. |
| 1 | Sungmin-Cho/claude-deep-loop | "2-plane kernel control plane" | [link](https://github.com/Sungmin-Cho/claude-deep-loop) | **Control-plane/execution-plane split**: kernel is the *only* authorized writer (state machines, budget, circuit breakers, integrity log, handoff); skill agents are read-only and mutate only via kernel subcommands — governance enforced by architecture, not model compliance. |
| 1 | MindStudio | "Claude Code Auto Mode, /goal, and Routines: Run Agents Without You" | [link](https://www.mindstudio.ai/blog/claude-code-auto-mode-goal-routines-autonomous-agents-2) | Combines auto mode + /goal + routines for hands-off scheduled runs. On-thesis for TRIGGER/BUDGET/STOP but a restatement of material already in docs/08/28/30 — no doc change. |
| 3 | the-open-engine/zeroshot | "Blind validation / information-asymmetry reviewers" (~1.6k★) | [link](https://github.com/the-open-engine/zeroshot) | Validators receive **only outputs, never the maker's reasoning** — so they can't inherit buried assumptions or collude ("can't lie about code they didn't write"); reject-and-retry until all approve. Anti-collusion rationale, now a first-class rule in docs/04. |
| 3 | MindStudio | "Multi-Perspective AI Research: Sub-Agents beat single-prompt" | [link](https://www.mindstudio.ai/blog/multi-perspective-ai-research-sub-agents-vs-deep-research) | Five role-differentiated expert sub-agents + a synthesis layer that maps agreements/disagreements; value from perspective *diversity*, not redundancy. Maps to existing docs/07 synthesis-bottleneck + confidence-gate coverage — no doc change. |
| 4 | The New Stack | "OpenClaw's app doesn't run AI on your phone — that's the point" | [link](https://thenewstack.io/openclaw-persistent-agent-architecture/) | Persistent long-running agents run off-device; the phone app is just an authenticated endpoint (pattern shared by Claude Dispatch, OpenAI). Architectural context for where the loop runs; already covered by routines (docs/28). No doc change. |

### No new content
- Anthropic RSS / The Batch / The Rundown AI / TLDR AI / Ben's Bites / AI Breakfast — feed 404 (ongoing)
- OpenAI news / Harness Books (agentway.dev) — 403 (ongoing)
- @bcherny, @karpathy, @AndrewYNg, @swyx, @steipete (OpenClaw community banter, no new technique), @Sabrina_Ramonov (newest post Jun 27, pre-cutoff), @akshay_pachaar — no new keyword-matching posts after last run
- swyx.io, sabrina.dev, Addy Osmani, Simon Willison, Lenny's — nothing after 2026-07-01
- X live keyword search — only promo (StrategiX) and generic vibe-coding noise
- Tracked repos with no substantive new concept: cobusgreyling (all three), omnigent, graphiti, tenet, loopflow, loop-kernel, ecc, Strive_Engineering, Cliclaw, herdr-loop-lab; ~7 new maker/checker clones skipped (plateaued wave)
- orobsonn/claude-harness — new commit (run-record-anchored capture-verified gate) folded into docs/04 as a refinement, not a separate row (repo URL already in the digest)

### Docs updated this run
- `docs/24-harness-patterns.md` — **new section "Self-Improving Harnesses"** (Self-Harness / AHE / HarnessX; trace-driven evolution, verified prediction contracts, ablation — fills the model-generated-harness gap) + **"Control-Plane / Execution-Plane Split"** (kernel-gated mutation; claude-deep-loop)
- `docs/16-memory-patterns.md` — **new "Pattern G: Repo-Owned Durable Ledger"** (ctxcarry — repo owns context; progress.md as DP memo table — peterCheng)
- `docs/04-verification.md` — **information-asymmetry / blind validation** (zeroshot: checker never sees the maker's reasoning) + **run-record-anchored capture gate** (orobsonn refinement to frozen-tests pattern)
- `docs/32-reading-list.md` — **new group "Self-Improving Harnesses"** with AHE (anchor — beats human baseline + ablation) and Self-Harness
- `LOOP_ENGINEERING.md` — refreshed the docs 24 / 16 / 04 summaries and the reading-list row
- `KB_GAPS.md` — closed "self-scaffolding / model-generated harness"; added "held-out eval construction for harness evolution"
- `SOURCES.md` — added arXiv research feed + 4 repos (peterCheng123321/loop-engineering, Sungmin-Cho/claude-deep-loop, shouryasrivastava/ctxcarry, the-open-engine/zeroshot)

### Structural review this run (Phase 4c)
The finding-set was theme-shifting, so the review was substantive:
- **Dominant theme with no canonical home → consolidated, not fragmented.** Self-improving harnesses recurred across 3 findings and had no home. Per the consolidation rule, it became a **named section inside docs/24** (which owns the harness parent-topic) rather than a new doc — cross-referenced to docs/22 (learned orchestration is *training a model*; self-improving harness keeps the model fixed and evolves the *config*) and docs/04 (the validate stage is a verification gate). If it keeps growing it can be promoted to its own doc later.
- **Missing thesis added.** The three papers converge on a claim the KB only implied — *the harness is an optimization target with measurable returns, and it can optimize itself*. Stated outright at the top of the new docs/24 section, extending the existing quantified harness>model thesis.
- **Second theme sharpened an existing boundary, no new doc.** Durable repo-owned state landed as docs/16 Pattern G, cross-linked to docs/13 (compaction) and the docs/24 kernel section (the sole-writer that governs such a ledger) — keeping the memory/context/harness spine coherent instead of spawning a "state" doc.
- No index restructure or doc renames → not MAJOR.

### Sources to consider adding to SOURCES.md
- All four candidate repos were added this run (see Docs updated). No further additions pending.
- Next arXiv pass: now that the arXiv feed is tracked, watch for follow-ups citing Self-Harness / AHE (held-out-eval methodology is the open question — see KB_GAPS).

---

## 2026-07-01 12:35 UTC (run)

A **gap-driven** run, not another saturation pass. The harness-repo wave has plateaued
(≈6–8 new-but-redundant maker/checker clones seen and skipped), but the KB-gap-targeted
searches paid off: this run **filled three documented gaps** — mid-session credential
rotation, a-priori goal-cost estimation, and (partially) the SECURITY_MATRIX default-deny
mechanism — plus added the first *quantified* evidence for the harness-over-model thesis.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 2 | LangChain | "The Anatomy of an Agent Harness" | [link](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness) | **Quantified harness>model**: moved a coding agent "Top 30 → Top 5 on Terminal Bench 2.0 by only changing the harness" (Opus 4.6, model held fixed) — hardest evidence yet that harness design is the accessible leverage. |
| 3 | rashmi1112/Credential-Sentinel | "Discover-and-rotate loop with verify-before-revoke" | [link](https://github.com/rashmi1112/Credential-Sentinel) | **Fills the credential-rotation gap**: promote→repoint→verify cutover, old credential revoked only after verify passes (rollback to still-valid old on fail); 4-state classify with default-deny on unknowns; two human gates. |
| 2 | cobusgreyling/goal-engineering | "goal-cost CLI (v1.1.0)" | [link](https://github.com/cobusgreyling/goal-engineering) | **Fills the goal-cost gap**: `goal-cost --pattern <p> --level <G>` forecasts token/budget for a goal *pattern* before the run — a-priori, pattern-keyed, feeds the Budget primitive. |
| 2 | omnigent-ai/omnigent | "Runtime policy engine + harness-bench" | [link](https://github.com/omnigent-ai/omnigent/commits/main) | Policy layer: `blast_radius` (bound action impact), `intent_gate` (default-deny vs. stated intent — partial SECURITY_MATRIX fill), `detect_task_switch` (mid-run goal-change detection), phase-scoped tool access; plus `harness-bench` (harness capability conformance testing — a new eval primitive). |
| 3 | Simon Willison | "shot-scraper video" | [link](https://simonwillison.net/2026/Jun/30/shot-scraper-video/) | Two patterns: **video-as-proof-of-work** (agent writes a YAML storyboard, Playwright records a demo as a human-viewable verification artifact) and **`--help` as embedded SKILL.md** (write help detailed enough that an agent self-onboards — capability travels with the binary). |
| 3 | MindStudio | "Human-in-the-Loop Checkpoints" | [link](https://www.mindstudio.ai/blog/human-in-the-loop-checkpoints-ai-agents) | **Where** to place checkpoints: 4 tests (irreversibility / confidence / external-visibility / context-gap), 2–3 checkpoints at ~80/20 auto:human, and the **override-rate** calibration ("approving 95% unchanged → the checkpoint is unnecessary"). |
| 4 | Claire Vo (Lenny's) | "Sonnet 5 review: 64 generations / How I AI Bench" | [link](https://www.lennysnewsletter.com/p/sonnet-5-review-i-ran-64-generations) | Reusable eval harness built in Claude Code <45 min from stored sessions; blind model comparison scored **70% human vibe / 30% LLM-judge** with a local HTML→JSON scoring page — an explicit blended-grading weight. |
| 3 | orobsonn/claude-harness | "Thinking-quality Stop hook + loop-design-check" | [link](https://github.com/orobsonn/claude-harness/commits/main) | A Stop hook that adjudicates *reasoning-trace* quality at session end (distinct from output-correctness gates) + a skill that lints the loop's own design. Marginal; noted. |
| 2 | cobusgreyling/loop-engineering | "loop CLI toolchain (loop-init/audit/cost)" | [link](https://github.com/cobusgreyling/loop-engineering) | Tracked repo shipped a CLI toolchain (`loop-init` scaffold, `loop-audit` inspect agent loops, `loop-cost` track spend) + opencode/openclaw 7/7 harness coverage. |

### No new content
- Anthropic RSS / The Batch / The Rundown AI / TLDR AI / Ben's Bites / AI Breakfast — feed 404/403 (ongoing; The Batch feed URL still needs revisiting)
- OpenAI news / Harness Books (agentway.dev) — 403 (ongoing)
- @bcherny, @karpathy, @AndrewYNg (0-to-1 framework being re-amplified — already in KB), @swyx, @steipete, @Sabrina_Ramonov, @akshay_pachaar — no new keyword-matching posts after last run
- swyx.io, sabrina.dev, Addy Osmani, Simon Willison (other posts), Cobus Greyling (Substack) — nothing after 2026-06-29
- X live keyword search — promo (EverMind "Raven"), jokes, thesis restatements, and a quant-trading *application* (no new technique)
- Tracked repos with no substantive new concept: getzep/graphiti, agent-ready-repo, loopflow, Monad-Harness, loop-kernel, JeiKeiLim/tenet (release-loop commit not yet documented — recheck next run), ecc (v0.18.x "second-eye nudge" = redundant with strong-eyes/cross-model review)
- GitHub search — ~6–8 new maker/checker/harness clones, none novel; `"halt condition" claude loop` and `acting_on` → 0 results

### Docs updated this run
- `docs/33-agent-security-hardening.md` — added **Credential Rotation Mid-Session** (verify-before-revoke cutover; fills gap) and **Runtime Policy Gating** (blast_radius / intent_gate / phase-scoped; partial SECURITY_MATRIX default-deny fill)
- `docs/30-goal-engineering.md` — added **A-Priori Goal-Cost Estimation** (pattern-keyed pre-run forecast; fills gap)
- `docs/14-human-in-the-loop.md` — added **Where to Place a Checkpoint** (4 tests, 80/20, override-rate calibration)
- `docs/24-harness-patterns.md` — added quantified harness>model evidence (LangChain Top30→Top5) + **harness conformance testing** (harness-bench)
- `docs/04-verification.md` — added **70/30 human-LLM blended grading** and **proof-of-work demo artifacts** (video-as-verification)
- `docs/06-skills.md` — added **agent-legible tools** (`--help` as embedded SKILL.md)
- `docs/17-failure-patterns.md` — enriched the Context-drift row with `detect_task_switch` (mechanical mid-run goal-change detection)
- `KB_GAPS.md` — closed credential-rotation and goal-cost gaps; re-scoped SECURITY_MATRIX to the loading mechanism

### Structural review this run (Phase 4c)
The finding-set was gap-filling, not theme-shifting: each finding landed in an existing
canonical home (security→33, verification/eval→04, HITL→14, harness→24, goal→30, skills→06),
so no new docs and no index restructure were needed — the design spine absorbed it. The
one thesis-level upgrade is that "the harness matters more than the model" now carries a
**quantified** anchor (LangChain Top30→Top5) rather than only quotes; added to docs/24
where the thesis already lives.

### Sources to consider adding to SOURCES.md
- **arXiv** — "Self-Harness: Harnesses That Improve Themselves" (2606.09498) and "Agentic Harness Engineering" (2604.25850): self-improving harnesses with Terminal-Bench gains; pre-cutoff but not yet mined — worth a dedicated arXiv pass next run
- LangChain blog (langchain.com/blog) — now a strong quantified harness source; consider tracking
- jtoemion/revolver-plugin — credential rotation-on-auth-error fallback (README 404 this run; recheck via master/docs)

---

## 2026-06-30 04:00 UTC (run)

A third consecutive GitHub-dominated run, and the live repo searches converged on a
single, sharper theme: **cross-model maker/checker** — harnesses where **Claude
implements and a *different* model (Codex) reviews**. Four independent repos updated
Jun 28–30 (Cliclaw, loope, herdr-loop-lab, forja) all build the same shape: the reviewer
runs on a different model so it doesn't share the implementer's training blind spots, emits
a structured `VERDICT: PASS / BLOCK` (+ advisory `SUGGEST`), and completion is gated on a
**dual stop condition** — mechanical test exit 0 *and* no reviewer `BLOCK`. This is the
genuinely new mechanism of the run: prior verifier-integrity work kept the checker
*structurally* independent (fresh context, external command); this adds a **model-diversity**
axis. Canonised as **Pattern 5 (cross-model independence)** in the Verifier Integrity section
of `docs/04`, with a cross-ref from `docs/07`. Strive_Engineering also shipped a second new
verifier mechanism — the **isomorphic-perturbation check** (validate each claim under two
independent-but-equivalent tests; passing one but not its equivalent flags a single-predicate
reward-hack). On the article side, Lenny's published the strongest production case study in
weeks (Gusto's "trash-can method"), added to the reading list.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | Happenmass/Cliclaw | "Claude + Codex parallel subagents over tmux" | [link](https://github.com/Happenmass/Cliclaw) | Cross-model execute-then-review (Claude implements, Codex reviews, roles swappable); auto-continue *gate model* decides at natural stopping points whether to iterate; tmux-pane state scraping for hook-free state detection; two-tier hybrid memory (sqlite-vec + FTS5 BM25). 107★. |
| 1 | mateaix/loope | "Claude implements, Codex reviews until code is right" | [link](https://github.com/mateaix/loope) | Clean cross-model maker/checker; **dual stop**: terminates only when test cmd exits 0 AND reviewer issues no `BLOCK`; structured `VERDICT: PASS/BLOCK` + non-blocking `SUGGEST`; parallel reviewers aggregate "any blocker ⇒ blocked"; full transcript traceability per run. |
| 1 | firegnu/herdr-loop-lab | "Verification-driven bounded-convergence loops (inner/fleet/epic)" | [link](https://github.com/firegnu/herdr-loop-lab) | Three-layer: inner loop (writer → mechanical gate → cross-model adversarial judge), fleet layer (parallel worktree tasks), epic layer (decompose → dispatch → integrate); exit codes as contracts (0 satisfied / 2 stalled / 3 quota); stateless worktree rounds enable resume; AC-N acceptance criteria decoupled from agent output. |
| 1 | Llicklair/forja | "Finder→Tester→Fixer→Evaluator self-correcting loop" | [link](https://github.com/Llicklair/forja) | Tester writes FAILING tests before fixes (anti false-positive); Evaluator runs the suite adversarially on a SEPARATE model to catch cross-test contamination; stop conditions = class-level exhaustion + suite integrity (no `-k` filtering) + blast-radius veto; "honesty principle": coverage% = breadth of first contact, untestable marked "correct by construction, unverified". |
| 1 | Synaptic-Labs-AI/PACT-Plugin | "Prepare-Architect-Code-Test agentic harness" | [link](https://github.com/Synaptic-Labs-AI/PACT-Plugin) | 12 specialists + orchestrator; **concurrent Auditor** observes via `git diff` (structural evidence, not prose attestation); Conversation-Theory teachback (restate understanding before work); two-call atomic acceptance; falsifiable-by-construction (only verifies on-disk conditions); SQLite vector+graph memory + append-only JSONL journal survives compaction. 68★. |
| 1 | Lenny's Newsletter | "No Figma. No Jira. No docs. How Gusto built a product line with Claude Code" (Eddie Kim, CTO) | [link](https://www.lennysnewsletter.com/p/no-figma-no-jira-no-docs-how-gusto) | 5-person team shipped a tier-one AI product in 10 weeks; the **trash-can method** turns Claude-generated PRs into disposable product proposals (close to discard), making failed experiments cheap; eval-first bug-fixing loop. Added to reading list (Loops in Production). |
| 2 | krishddd/Strive_Engineering | "2026 research upgrade — isomorphic verifier, compaction, anomaly guard, authoring CLI" | [link](https://github.com/krishddd/Strive_Engineering/commit/0be1771) | **Isomorphic-perturbation verifier** (Rust `verify-iso`): validates each claim under two independent-but-equivalent checks (literal `git cat-file -e` + full OID re-derivation); passing one but not its equivalent signals a reward-hack and exits non-zero. Plus compaction+notebook durable memory, scheduler oscillation halting, spec-authoring CLI (init/cost/audit). |
| 2 | eugenelim/agent-ready-repo | "Per-loop self-coverage tuning + design-time reviewer (RFC-0050/0053, #454–456)" | [link](https://github.com/eugenelim/agent-ready-repo/commit/525a13d) | Reframes self-coverage as a *per-loop* goal: discovery loop runs the full seven-module gate, work loop runs only a "thin" net-new slice (avoid ceremony); "resolve-vs-surface" — substitute rigorous checklists for what would escalate to a human; adds a forked-context design-time reviewer ("experience-reviewer") + "Ground Taste" to stop re-litigating preference. |
| 2 | omnigent-ai/omnigent | "Idle-reaper window + dead-letter replay + polly visual-proof check (#1627)" | [link](https://github.com/omnigent-ai/omnigent/commit/62dd103) | Tunable harness idle-reaper (`OMNIGENT_HARNESS_IDLE_TIMEOUT_S`) as a cleanup stop-condition for long-lived sessions; dead-letter recovery classifies forwarding failures (proven-undelivered replayable / ambiguous forensic-only / permanent) for at-most-once crash recovery; polly-review now flags missing screenshots/videos on UI PRs (verifier checklist for visual proof). |
| 2 | adha9990/dev-workflows | "7-stage closed-loop development workflow plugin" | [link](https://github.com/adha9990/dev-workflows) | dispatch → goal → explore → plan → build → verify → iterate; human-gated only at genuine decision points (routine transitions auto-advance); build uses red-green separation (test author isolated from implementer); verify deploys six parallel reviewers across distinct axes; mandatory re-verify of delta + blast radius after each fix; three-cycle iteration cap. |
| 2 | Lenny's Newsletter | "How I AI: GLM-5.2 review & How Gusto built a new product line" | [link](https://www.lennysnewsletter.com/p/how-i-ai-glm-52-review-and-how-gusto) | Pairs a live GLM-5.2 open-weight coding-model review (~$3.36 for 6M tokens of agentic work) with the Gusto case study — framing open weights as production-grade for long-running agent loops. |
| 2 | via Lenny's Newsletter | "How to build a new AI product in 10 weeks using the no-process method" | [link](https://www.chatprd.ai/how-i-ai/workflows/how-to-build-a-new-ai-product-in-10-weeks-using-the-no-process-method) | The trash-can method written up as a reusable workflow: disposable PRs as proposals let non-engineers ship features developers later refine — a loop-driven planning practice. |
| 2 | MindStudio Blog | "Self-Scaffolding AI Models: How Ornith 1.0 Writes Its Own Agent Harness" | [link](https://www.mindstudio.ai/blog/self-scaffolding-ai-models-ornith-1-0) | Ornith 1.0 generates a discrete, inspectable Python harness per task (tool selection, state, branches, termination criteria) instead of running inside a fixed human-written loop — model-generated harnesses (new KB gap). |
| 3 | via Lenny's Newsletter | "Fix bugs using an AI-powered TDD workflow" | [link](https://www.chatprd.ai/how-i-ai/workflows/how-to-fix-bugs-using-an-ai-powered-test-driven-development-tdd-workflow) | Concrete verification loop: agent writes a failing test to reproduce the bug, fixes, re-runs the test as the stopping condition, gates on human review before commit. |
| 3 | MindStudio Blog | "Context Rot in AI Agents: Fix with Session Handoffs" | [link](https://www.mindstudio.ai/blog/context-rot-ai-agents-session-handoff-fix-2) | Long loops degrade as old instructions lose weight; session handoffs (summarize state, clear, restart) + persistent external memory (CLAUDE.md) treat context management as a deliberate infra layer (restates docs/13). |
| 3 | MindStudio Blog | "What Is Sakana Fugu? Multi-Model Orchestrator" | [link](https://www.mindstudio.ai/blog/what-is-sakana-fugu-multi-model-orchestrator-2) | Routes prompts via a *trained classifier* (not rule heuristics) matching complexity to a model pool to optimize cost vs quality (restates docs/22 learned orchestration). |

### No new content
- Anthropic RSS (404 across rss.xml/rss/news variants), The Batch feed (404 — content reachable only via HTML index; issue-359 three-loops material already tracked v2.4.1), The Rundown AI (403), Ben's Bites / AI Breakfast (beehiiv 404), Harness Books (agentway.dev 403), OpenAI news (403) — persistent feed/access issues; nothing new
- @bcherny, @karpathy, @AndrewYNg, @swyx, @steipete, @Sabrina_Ramonov, @akshay_pachaar — no new keyword-matching posts after last run (X live + per-handle scans not re-run this cycle; newest known matches already in KB)
- Simon Willison — recent posts are Claude-Code-assisted project writeups (Tier 4 incidental), not loop-design practice
- swyx.io, Sabrina.dev — no substantively new loop-engineering articles after last run
- Addy Osmani (Loop Engineering, Orchestration Tax, Factory Model, Intent Debt) — all predate last_run and already tracked in KB
- The New Stack runtime-verification piece — already in the 2026-06-29 digest (excluded as duplicate)
- cobusgreyling/loop-engineering, goal-engineering, fleet-engineering, getzep/graphiti — no commits after 2026-06-29; tenet, loopflow, loop-kernel, claude-harness — latest commits on/before cutoff
- GitHub search (`acting_on` claude loop) — 0 results; replaced with a cross-model maker/checker query in SOURCES.md. (`claude code harness` search increasingly polluted by Claude-Code reverse-engineering/snapshot repos — refinement noted)

### Docs updated this run
- `docs/04-verification.md` — added **Pattern 5: cross-model independence** to Verifier Integrity (checker runs a *different* model than the maker — Claude implements / Codex reviews; model-diversity defeats shared blind spots; structured `VERDICT: PASS/BLOCK` + `SUGGEST`; dual stop condition) and the **isomorphic-perturbation check** refinement (anti single-predicate reward-hacking); updated section count 3→5 and the closing synthesis to "these five together" (Cliclaw, loope, herdr-loop-lab, forja, Strive_Engineering)
- `docs/07-subagents.md` — added "**Independence has two axes**" note distinguishing context-independence (fresh session) from model-independence (different model for the checker), cross-linking to docs/04 Pattern 5 — the run's findings showed model-diversity is a distinct axis the DOER/CHECKER section did not name
- `docs/32-reading-list.md` — added Gusto "no-process / trash-can method" case study to Loops in Production (strongest process-replacement case study with hard outcome data); Reference Implementations kept stable (cross-model pattern already canonised in docs/04; existing 5 entries not clearly beaten)
- `LOOP_ENGINEERING.md` — updated docs/04 index summary to list isomorphic-perturbation + cross-model independence
- `SOURCES.md` — replaced low-yield `acting_on` github-search with a cross-model maker/checker query; added Happenmass/Cliclaw and firegnu/herdr-loop-lab as github sources; noted isomorphic verifier on Strive_Engineering
- `KB_GAPS.md` — added two gaps surfaced by this run's findings (cross-model checker arbitration/model-selection; self-scaffolding model-generated harness)

### Structural review this run (Phase 4c)
Reading the finding-set as a whole, the dominant theme (≥4 findings) is **cross-model
maker/checker**. Per the canonical-home rule, this did **not** warrant a new doc: the parent
topic (verifier integrity / keeping the check unfakeable) already lives in `docs/04`, so the
new mechanism was consolidated there as Pattern 5 with a single cross-ref from `docs/07`,
keeping one canonical home rather than fragmenting. The theme *strengthens* the design spine's
fifth question ("How do you know it's done?") by adding an independence axis (model diversity)
the KB previously conflated with context-independence — the only structural correction needed.
No thesis was missing (docs/01 already states the harness/verifier matters more than the
model), no index reorder or merge was warranted, and centrality of the design spine is intact.
Tier-3 article findings (context rot, Sakana Fugu) restated existing docs (13, 22) and were
recorded as findings without doc edits.

### Sources to consider adding to SOURCES.md
- Synaptic-Labs-AI/PACT-Plugin (68★) and Llicklair/forja — strong cross-model/maker-checker repos; tracked via the new cross-model github-search query rather than as standalone rows (avoid SOURCES bloat); promote to dedicated rows if they ship a second distinct contribution
- mateaix/loope, adha9990/dev-workflows — same; surfaced by the cross-model search query

---

## 2026-06-29 04:02 UTC (run)

Another GitHub-dominated run. The live repo searches surfaced a *second* wave of
fresh Claude-Code loop harnesses (all updated Jun 29) converging — again — on
**verifier integrity and anti-self-grading**: SHA-cited "ungameable" verifiers,
adversarial read-only verifier agents, eval-gate + independent monitor councils, and
reject-until-proven reviewers. The genuinely new mechanism this run is
**provenance-bound claims** (every assertion must cite a git SHA re-checked via
`git cat-file`, plus majority-vote to block collusion) — canonised as a 4th pattern in
the Verifier Integrity section of `docs/04`. The article sources (Slashdot, O'Reilly,
The Innermost Loop) restated the now-familiar thesis and added the
"model-harness-sandbox-eval **flywheel**" framing, but introduced no concept the KB
lacks.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | krishddd/Strive_Engineering | "SHA-cited ungameable verifier + L0-L3 autonomy ladder" | [link](https://github.com/krishddd/Strive_Engineering) | Every finding must cite a git SHA verified by `loopguard` via `git cat-file`; diff-integrity + injection scanning; `majority_vote` blocks self-grading — **provenance-bound claims** as a new verifier-integrity mechanism. |
| 1 | grapheneaffiliate/Harness | "The RIG — deterministic read→pick→dispatch→verify→record loop" | [link](https://github.com/grapheneaffiliate/Harness) | Adversarial read-only verifier agent + `verify.sh` source-of-truth exit-0 gate; iteration caps (RIG_MAX_ITERS/STOPS); Stop gate won't release until the tree is clean and pushed. |
| 1 | kok1eee/flywheel | "Sensors-first loop engine" | [link](https://github.com/kok1eee/flywheel) | Hooks observe natural tool use to advance phases; gates physically block implementation until design validates; completion requires both an eval exit-code gate AND an independent monitor council (cap 8) — never model self-assessment. |
| 2 | patrick-toulme/harnessgym | "Capability-gap reflection → one reusable artifact per iteration" | [link](https://github.com/patrick-toulme/harnessgym) | Runs agents on hard tasks, reflects on missing capabilities, builds one reusable artifact (skill/MCP/test) per iteration, qualifies it in a clean workspace, restarts fresh with accumulated harness context; failed artifacts quarantine with evidence. |
| 2 | manok4/ensemble | "Documentation-as-truth maker/checker harness" | [link](https://github.com/manok4/ensemble) | Independent read-only reviewers (correctness/testing/maintainability/standards) return structured findings; two verification gates around each build unit; 6-verdict triage before merge. |
| 2 | vibhasdutta/loop-engineer | "7-agent team iterating to verified done" | [link](https://github.com/vibhasdutta/loop-engineer) | Scaffolds tool-scout/researcher/developer/QA/verifier/auditor/memory-keeper iterating until all tasks pass or a 20-turn budget exhausts; verifiers default to "reject until proven"; auto-skip on repeated failure. |
| 2 | happy-ryo/loop-agent | "Embeddable loop with five injection seams + dual termination" | [link](https://github.com/happy-ryo/loop-agent) | Fixed orchestration with gather/act/verify/conditions/gate seams; a dual-termination model combining goal achievement with synthetic stop conditions to guarantee halt; swappable providers via an ActHook protocol. |
| 2 | iamraven-tw/loop-engineering | "Claude Code skill teaching ten reusable loop patterns" | [link](https://github.com/iamraven-tw/loop-engineering) | Ten patterns (retry/reflection/evaluation/planning/tool-calling/research/memory/multi-agent/human-in-the-loop/continuous-improvement) unified by iterate-with-checkpoints-until-success-or-termination. |
| 1 | Slashdot | "Forget Prompt Engineering: 'Loop Engineering' Is All the Rage Now" | [link](https://developers.slashdot.org/story/26/06/25/0546238/forget-prompt-engineering-loop-engineering-is-all-the-rage-now) | Boris Cherny says Claude now writes his prompts; Peter Steinberger urges engineers to design the loops that prompt the agents — mainstream press confirming the discipline. |
| 1 | O'Reilly Radar | "Loop Engineering" — Addy Osmani | [link](https://www.oreilly.com/radar/loop-engineering/) | Definitional piece: self-directed loops from automations/worktrees/skills/MCP connectors + a verifier subagent and a measurable stop condition; warns against cognitive surrender. |
| 2 | The Innermost Loop | "Welcome to June 28, 2026" | [link](https://theinnermostloop.substack.com/p/welcome-to-june-28-2026) | Frames every enterprise as spinning its own **model-harness-sandbox-eval flywheel**; notes loop engineering has gone so far Claude Code's creator lets Claude write his prompts. |
| 2 | via Innermost Loop | "Aravind Srinivas on the model-harness-sandbox-eval flywheel" | [link](https://x.com/aravsrinivas/status/2070938739350900944) | Perplexity's CEO frames each enterprise's flywheel as tuned for token value per watt — the flywheel thesis from an operator. |
| 1 | via Lenny's Newsletter | "How Mozilla Fixed 500 Security Bugs with Mythos" | [link](https://www.chatprd.ai/how-i-ai/how-mozilla-fixed-500-security-bugs-with-mythos) | Mozilla's Mythos combines relentless analysis loops with verification + patching agents to find/patch ~500 Firefox bugs — the harness, not the model, is the leverage (extends the Firefox case study already in docs/04). |
| 2 | MindStudio Blog | "What Is a Loop of Loops?" | [link](https://www.mindstudio.ai/blog/what-is-loop-of-loops-ai-agents-recurring-work) | Coordinator agent manages multiple child agents on recurring cycles, sharing context and handling dependencies — restates multi-loop coordination already in docs/34. |
| 2 | omnigent-ai/omnigent | "Emit CompactionComplete on SDK context compaction (#1505)" | [link](https://github.com/omnigent-ai/omnigent/commit/a8157fa) | Cross-harness event-propagation: emit CompactionComplete (summary + post-compaction token count + model) before TurnComplete so resumed sessions use the compacted summary, not a full transcript replay. |
| 3 | The New Stack | "Runtime verification of coding agents" | [link](https://thenewstack.io/runtime-verification-coding-agents/) | Greptile/Cursor/Devin agree agents should run their code before handoff; sandboxes miss integration bugs, making *what code runs against* the key design choice. |
| 3 | The Batch (DeepLearning.AI) | "Agentic tests beyond the bug hunt (DeepSWE / ProgramBench / ITBench-AA)" | [link](https://www.deeplearning.ai/the-batch/agentic-tests-beyond-the-bug-hunt) | New benchmarks stress agent harnesses on feature implementation, program-from-scratch, and root-cause diagnosis — harder than SWE-bench bug-fixing. |
| 3 | JeiKeiLim/tenet | "gzip db snapshots by default with auto-detecting restore" | [link](https://github.com/JeiKeiLim/tenet/commit/069d562) | Git-safe agent-state snapshots: gzip the SQLite snapshot (70-90% smaller to stay under GitHub's 100MB limit), auto-detect via magic bytes (0x1f 0x8b) on restore. |

### No new content
- Anthropic RSS (404, recovered via search — foundational pieces predate last run), The Rundown AI (403), Ben's Bites / AI Breakfast (beehiiv 404), Harness Books (agentway.dev 403), OpenAI news (403) — all ongoing feed/access issues; nothing new surfaced
- @bcherny, @AndrewYNg, @swyx, @steipete, @karpathy, @Sabrina_Ramonov, @akshay_pachaar — no posts after last run matching keywords (newest matches already in KB)
- Simon Willison, swyx.io — only incidental Claude/Codex mentions, not loop-engineering practice
- X live keyword search — mostly non-English promo / trivial Claude Code mentions; the one "loop engineering" hit was a 1-view throwaway, excluded
- cobusgreyling/loop-engineering, goal-engineering, fleet-engineering, getzep/graphiti, faisalishfaq2005/loopflow, uppifyagency/loop-kernel, orobsonn/claude-harness — no substantive commits strictly after 2026-06-28
- GitHub search (`acting_on` claude loop, `stopping condition` claude loop) — 0 results each; suggested refinements: `"halt condition" claude loop`, broader `"gather" "verify" "gate" claude loop`

### Docs updated this run
- `docs/04-verification.md` — added **4th Verifier Integrity pattern: provenance-bound claims** (every assertion cites a git SHA re-checked via `git cat-file`; majority-vote monitor council blocks self-grading) + a closing synthesis tying all four patterns to the Verifier-Theater cure (krishddd/Strive_Engineering, kok1eee/flywheel, grapheneaffiliate/Harness)
- `LOOP_ENGINEERING.md` — updated the docs/04 index summary to list provenance-bound claims + majority-vote council
- `SOURCES.md` — added krishddd/Strive_Engineering as a github source (novel SHA-citation verifier pattern canonised this run)
- `docs/32-reading-list.md` — added Strive_Engineering to Reference Implementations (provenance-bound verification — a technique no other reference impl demonstrates; group now at the 5-entry cap)

### Structural review this run (Phase 4c)
Reading the finding-set as a whole, the dominant theme is — for the second consecutive
run — **verifier integrity and anti-self-grading** (Strive, The RIG, flywheel, ensemble,
loop-engineer all centre on unfakeable checks and independent judges). This *reinforced*
the canonical home established 2026-06-26/28 rather than fragmenting it: the one new
mechanism (provenance-bound claims) slotted in as a 4th pattern inside the existing
`docs/04` Verifier Integrity section, and a closing synthesis now states the converging
thesis outright. The secondary theme — the "model-harness-sandbox-eval **flywheel**"
framing (Innermost Loop, Aravind Srinivas) — is already covered by the
[Factory Model](https://lucagattoni.github.io/Claude-Loops/26-factory-model/) and [Harness Patterns](https://lucagattoni.github.io/Claude-Loops/24-harness-patterns/)
docs (harness > model thesis); it added vocabulary, not a missing primitive, so no
structural change. No new docs, no index restructure — the design spine absorbed the run
cleanly.

### Sources to consider adding to SOURCES.md
- grapheneaffiliate/Harness ("The RIG") and kok1eee/flywheel — strong Tier-1 verifier-integrity designs; monitor for ≥2 substantive contributions before adding as standing sources
- The Innermost Loop (theinnermostloop.substack.com) — newsletter with the flywheel framing; watch for a second on-topic issue before tracking
- MindStudio is already tracked; its Jun-25 cluster (loop-of-loops, /goal+/routines, G Stack) was high-volume but restated covered concepts

---

## 2026-06-28 16:25 UTC (run)

GitHub-dominated run: the live searches surfaced a wave of small Claude-Code loop
harnesses (Jun 27–28) converging on the same patterns — exit-code stops, external
verifiers, frozen tests, maker/checker isolation. The convergence itself is the
signal: the patterns this KB documents are now the de-facto community standard.

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | uppifyagency/loop-kernel | "Simplest autonomous loop that provably halts" | [link](https://github.com/uppifyagency/loop-kernel) | Three deterministic exit-code stops (0=pass / 3=score flat K iters / 2=cap), external unfakeable verifier, `score=<fraction>` contract; "progress is the score moving, not did-files-change". |
| 1 | @mateclawai / mateaix/loope | "Loope — open-source Loop Engineering workspace for AI coding" | [link](https://github.com/mateaix/loope) | Cross-model maker/checker: Claude implements, Codex reviews; parallel read-only reviewers emit PASS/BLOCK, converge when verify passes & no blocker (max-iters 3); agents isolated via `--isolate-home`. |
| 1 | shumatsumonobu/loop-engineering-playbook | "Ralph-pattern loop playbook" | [link](https://github.com/shumatsumonobu/loop-engineering-playbook) | Ralph pattern (fresh context each cycle, state in `.claude/loop/TASKS.md` + git + tests) with a Stop-hook hard floor blocking completion while tests fail; verifier `verdict.json` separation. |
| 1 | VioletScar-Hui/Build_Great_Loop | "Composable 5-skill loop group" | [link](https://github.com/VioletScar-Hui/Build_Great_Loop) | Five composable skills (loop-spec/engineering/eval/review/ops) producing paste-ready loop prompts; crash-safe idempotent resumption; machine-checkable success standards. |
| 2 | orobsonn/claude-harness | "Barbell 'strong eyes, cheap hands' delivery" | [link](https://github.com/orobsonn/claude-harness) | Cheap Ollama models write code, Opus judges at gates, Sonnet orchestrates for throughput; tests content-hashed & frozen before impl; completion verified independently (git diff + real test run). |
| 2 | firegnu/herdr-loop-lab | "Verification-driven bounded-convergence toolkit" | [link](https://github.com/firegnu/herdr-loop-lab) | Three-tier nested loops (inner adjudicated / fleet across worktrees / epic auto-merge); mechanical gates kept separate from adjudicators; correctness rests on git + exit codes + JSON contracts. |
| 2 | KranzL/jje | "Planner/Executor/Jury/Judge generator-critic harness" | [link](https://github.com/KranzL/jje) | Tool-backed independent juries (gitleaks/semgrep/pytest); **oscillation guard** escalates on recurring/contradictory findings (repeat_threshold 2); PreToolUse commit gate enforcing accept + green CI. |
| 2 | ruvnet/agent-harness-generator | "MetaHarness — meta-harness factory" | [link](https://github.com/ruvnet/agent-harness-generator) | Generates branded harnesses with cost-aware model routing learned from eval logs, Darwin self-mutating configs, default-deny MCP governance, Ed25519/SLSA-L2 signed provenance. |
| 2 | BicaMindLabs/FuguNano | "Repo-native multi-agent harness (Sakana Fugu reimpl)" | [link](https://github.com/BicaMindLabs/FuguNano) | Provider-neutral routing with a self-harness learning loop that mines failed runs and promotes only non-regressing harness edits (model frozen); join-barrier non-convergence detection. |
| 2 | adha9990/dev-workflows | "7-stage closed-loop dev workflow" | [link](https://github.com/adha9990/dev-workflows) | dispatch→goal→explore→plan→build→verify→iterate; decision-point gating pauses only on genuine choices to conserve budget; red-green test/impl separation; iteration cap 3. |
| 2 | Llicklair/forja | "Claude Code autonomous loop plugin" | [link](https://github.com/Llicklair/forja) | Class-wide scanning hard gate (fix all instances with proof), allowlist-by-command-name gate execution, sandbox mode for untrusted repos, "forja max 300k" token-budget stop. |
| 2 | eugenelim/agent-ready-repo | "RFC-0055 correction convention + R10 sidecar privacy boundary" | [link](https://github.com/eugenelim/agent-ready-repo) | New RFC/ADR governance for correcting accepted specs (Errata/Amendments) and a privacy boundary for sidecar data; extends the traceability model already in KB. |
| 2 | Kanevry/session-orchestrator | "v3.10.0 — repeatable session loops" | [link](https://github.com/Kanevry/session-orchestrator) | Five typed waves with inter-wave session-reviewer gates, `blocked-commands.json` policy file, STATE.md crash recovery across Claude Code/Codex/Cursor/Pi. |
| 3 | @Sabrina_Ramonov | "Claude posts to social media for me now" | [link](https://x.com/Sabrina_Ramonov) | Applied headless content loop in Claude Code: write → grade for virality → check brand voice → post; a checker gate before the irreversible publish step. |
| 4 | omnigent-ai/omnigent | "Authoritative per-session cost_usd" | [link](https://github.com/omnigent-ai/omnigent) | Surfaces authoritative AI-credit cost as `cost_usd` per session (#1486) — a concrete cost-tracking mechanism relevant to the goal-cost estimation gap. |

### No new content
- Anthropic RSS / The Rundown AI / TLDR AI / Ben's Bites / AI Breakfast / The Batch — RSS 404/403 (ongoing; The Batch feed URL needs revisiting)
- OpenAI news / Harness Books (agentway.dev) — 403 (ongoing)
- @bcherny — newest matching post is Jun 23 (Claude Everywhere, already in KB); nothing after last_run
- @AndrewYNg, @swyx, @steipete, Addy Osmani, Simon Willison, Cobus Greyling, Lenny's, Sabrina.dev, MindStudio — nothing dated after 2026-06-26 (newest items predate last run / already in KB)
- cobusgreyling/goal-engineering, fleet-engineering, getzep/graphiti, JeiKeiLim/tenet, faisalishfaq2005/loopflow, Monad-Harness — no substantive new commits since last run
- GitHub search (`acting_on` claude loop) — 0 results; suggested: `"stopping condition" claude loop`
- GitHub search (SECURITY_MATRIX claude agent) — 0 results; suggested: `"default-deny" MCP policy agent`

### Docs updated this run
- `docs/04-verification.md` — added **Verifier Integrity: Keeping the Check Unfakeable** (consolidated, canonical home): external verifier (loop-kernel), mechanical gates vs. adjudicators (herdr-loop-lab), frozen content-hashed tests (claude-harness)
- `docs/27-loop-contract.md` — extended the canonical Stop Condition Taxonomy with the three-exit-code reference implementation (loop-kernel) and the "score the goal, not the activity" refinement to the no-progress stop
- `docs/07-subagents.md` — added **"Strong Eyes, Cheap Hands"** cost-asymmetric DOER/CHECKER model allocation (claude-harness)
- `docs/17-failure-patterns.md` — added **Verdict oscillation** failure pattern + oscillation-guard mitigation (jje)
- `docs/32-reading-list.md` — added loop-kernel to Reference Implementations
- `SOURCES.md` — added uppifyagency/loop-kernel and orobsonn/claude-harness as github sources

### Structural review this run (Phase 4c)
Reading the finding-set as a whole, the dominant theme was **stopping-condition rigor + verifier integrity** (loop-kernel, herdr-loop-lab, jje, claude-harness all center on provable halting and unfakeable checks). This *reinforced* the canonical homes established 2026-06-26 rather than fragmenting them: the stop-condition material consolidated into `docs/27` and the verifier-integrity sub-theme into a single new section in `docs/04`. No new docs, no index restructure — the existing design spine absorbed the run cleanly.

### Sources to consider adding to SOURCES.md
- The New Stack — two Jun 27 Tier-3 candidates (runtime verification of coding agents; vibe-coding "context debt"); article bodies were not retrievable via WebFetch, so excluded pending verification
- "How to actually master loop engineering" — an X Article surfaced in the live search (Plan→Act→Learn `/loop` diagram); URL not captured this run — re-check next run
- Several new harness repos not yet tracked individually: firegnu/herdr-loop-lab, KranzL/jje, mateaix/loope, ruvnet/agent-harness-generator (MetaHarness) — monitor for ≥2 substantive contributions before adding as standing sources

---

## 2026-06-26 09:04 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "5 Claude Code slash commands i use daily: /goal runs it autonomously until the goal is met" | [link](https://x.com/Sabrina_Ramonov/status/2070246907532677588) | Catalogues five loop-control slash commands including /goal (autonomous until done), /btw (mid-run question injection), and /clear (context reset) — enumerating the loop-control primitive set in Claude Code. |
| 1 | @Sabrina_Ramonov | "3 boring jobs i hand to one /goal command — stop after N turns" | [link](https://x.com/Sabrina_Ramonov/status/2070125608013648082) | Demonstrates /goal as a bounded autonomous loop: rename files (25 turns), fill CSV (30 turns), summarise PDFs (40 turns) — concrete pattern for stop-after-N-turns loops. |
| 1 | @akshay_pachaar | "Loop Engineering Clearly Explained — the harness now matters more than the model" | [link](https://x.com/akshay_pachaar/status/2069118430582866051) | Comprehensive breakdown: stop condition categories (max-iters, budget, no-progress, completion check), context rot + compaction, idempotent tool writes, agent-readable errors, maker/checker separation — most detailed practitioner synthesis this run. |
| 1 | X Trending | "Anthropic's Playbook Details AI Agent Loop Engineering — >80% of Anthropic engineers build with self-improving loops" | [link](https://x.com/i/trending/2070248250767012231) | X trending story (1,520+ posts) covering Anthropic's eBook on five agent loop patterns; >80% stat confirms loop engineering as mainstream internal Anthropic practice. |
| 1 | Data Science Collective | "How To Build a Claude Loop Engineering Better Than 99% of People" | [link](https://medium.com/data-science-collective/how-to-build-a-claude-loop-engineering-better-than-99-of-people-3ab8701d176c) | Frames loop engineering as inverting human-in-the-loop: humans design the decision architecture instead of occupying the loop; the engineering challenge shifts from supervision to specification quality. |
| 2 | omnigent-ai/omnigent | "New commits Jun 26: compaction persistence, resume via --resume, spec reconstruction on resolve-miss" | [link](https://github.com/omnigent-ai/omnigent) | Three new harness resilience patterns: compaction log persistence across resumes, --resume flag for session recovery, spec reconstruction from event log on resolve-miss. |
| 2 | eugenelim/agent-ready-repo | "New commits Jun 26: RFC-0051 self-coverage gate, traceability-lint spec, RFC-0052 multi-adapter install" | [link](https://github.com/eugenelim/agent-ready-repo) | Self-coverage gate formalises the stopping condition (every scope item must have a verification artifact); traceability-lint validates the scope→task→artifact evidence chain; RFC-0052 adds multi-harness deployment spec. |
| 2 | Happenmass/Cliclaw | "tmux-based loop orchestration: parallel Claude+Codex, cross-vendor maker/checker, shared tasks.txt/progress.txt" | [link](https://github.com/Happenmass/Cliclaw) | 107★ repo: runs Claude Code and Codex as parallel subagents in a tmux session with auto-continue gate, cross-vendor maker/checker verification, per-agent capability scoping, and shared cross-agent handoff files. |
| 2 | LeadGrowGTM/loop-engineer | "Goal prompt writer + planner/maker/checker harness for Claude Code" | [link](https://github.com/LeadGrowGTM/loop-engineer) | Direct factory model implementation with explicit role separation: goal prompt writer → planner → maker → checker pipeline. |
| 2 | Kanevry/session-orchestrator | "STATE.md per-platform crash recovery, 8-dimension verification gate, cross-session pattern learning" | [link](https://github.com/Kanevry/session-orchestrator) | 38★: per-platform STATE.md (.claude/, .codex/) crash recovery; 8-dimension verification gate at ≥80% confidence; /evolve + /reconcile governed cross-session learning. |
| 2 | ryanjkelly/harnery | "Per-agent heartbeat files + claim/commit guards, canonical event stream" | [link](https://github.com/ryanjkelly/harnery) | Multi-loop coordination via .harnery/active/<agent-id>.json heartbeats: claim gate before work, commit gate before writes, TTL-based stale claim recovery — addresses the multi-loop STATE.md KB gap. |
| 2 | jhlee0409/claude-harness-kit | "Auto-generates harness (CLAUDE.md + architect agent + verify hook) from repo introspection" | [link](https://github.com/jhlee0409/claude-harness-kit) | Claude Code plugin that inspects the repo and generates a tailored harness configuration — harness bootstrapping as a loop pattern. |
| 2 | sergiocarvalhosa/Monad-Harness | ".apm/ agent spec: six primitive types (skills/instructions/hooks/prompts/commands/tools)" | [link](https://github.com/sergiocarvalhosa/Monad-Harness) | Concrete .apm/ manifest format for harness-agnostic agent deployment — fills KB gap on .apm/ specification format. |
| 2 | chatprd.ai | "Create an AI-Powered Patch and Verification Loop for Security Bugs" | [link](https://www.chatprd.ai/how-i-ai/workflows/create-an-ai-powered-patch-and-verification-loop-for-security-bugs) | Blueprint for four-stage maker-checker loop (verify exploit → generate patch → run regression → human merge) with explicit separation of concerns preventing agent self-grading. |
| 2 | chatprd.ai | "Build a Self-Improving AI to Generate Agent Skills in Codex" | [link](https://www.chatprd.ai/how-i-ai/workflows/build-a-self-improving-ai-to-generate-agent-skills-in-codex) | Meta-loop: meta-agent identifies skill gaps, spawns goal-directed subagents for validation, integrates confirmed skills into reusable library — recursive skill generation loop pattern. |
| 2 | MindStudio Blog | "What Is Loop Engineering? The New Meta for AI Coding Agents" | [link](https://www.mindstudio.ai/blog/what-is-loop-engineering-ai-coding-agents) | Explains loop engineering as ReAct's successor; argues agent quality depends more on loop design than model selection; covers error handling, context management, and termination conditions. |
| 2 | Anthropic Engineering | "Scaling Managed Agents: Decoupling the brain from the hands" | [link](https://www.anthropic.com/engineering/managed-agents) | Virtualizing sessions as durable event logs outside Claude's context window; credential vaulting to prevent prompt injection; 60% improvement in time-to-first-token via resource sharing. |
| 2 | hidekazu-konishi.com | "Claude Code Harness and Environment Engineering: Designing the Frontline Where Local AI Agents Actually Live" | [link](https://hidekazu-konishi.com/entry/claude_code_harness_and_environment_engineering_guide.html) | Distinguishes in-process harness controls (hooks, permissions) from out-of-process environment controls (OS user, container, network); three reference patterns: Approval-First, Curated Allow-list, Sandboxed Full-Auto. |
| 2 | MindStudio Blog | "What Is an Agent Harness? The Architecture Behind Claude Code, Codex, and Cursor" | [link](https://www.mindstudio.ai/blog/what-is-agent-harness-architecture-explained) | Nine harness components; contrasts Claude Code (explicit approval gates), Codex (model-integrated), and Cursor (code-indexing for context) harness design tradeoffs. |
| 2 | Cobus Greyling (Medium) | "Loop Engineering Playbook: Where loops live, how to run your first one" | [link](https://cobusgreyling.medium.com/loop-engineering-playbook-4460e01e88d8) | Maps loop deployment tiers (solo terminal, production with audit, editor-integrated); "reasoning alone does not close the loop — agents must execute and observe"; introduces comprehension debt as a technical liability. |
| 2 | MindStudio Blog | "How to Build an Agentic Loop with Claude Code: Verification, Cost, and Stopping Criteria" | [link](https://www.mindstudio.ai/blog/how-to-build-agentic-loop-claude-code) | Plan-Act-Observe cycle; three verification checkpoints (action, iteration, terminal); three stopping condition categories; cost management via lighter models for routine steps. |
| 2 | Agent Factory / Panaversity | "Loop Engineering: A Crash Course" | [link](https://agentfactory.panaversity.org/docs/loop-engineering-crash-course) | Six-part loop architecture (heartbeat, worktree, skill, sub-agents, connectors, state/memory); four heartbeat types from in-session to fully unattended; maker-checker with Claude Code / OpenCode examples. |
| 2 | @bcherny | "Claude Tag: one instance per Slack thread, own memory and permissions per channel" | [link](https://x.com/bcherny/status/2069474689819480394) | Claude Tag's per-thread sandbox architecture: each thread spawns an agent with its own credentials, clones repo, runs code, sandbox discarded when done — loop isolation at OS level. |
| 2 | @bcherny | "Just landed nested subagent support in Claude Code — capped at depth=5" | [link](https://x.com/bcherny/status/2064327225504403752) | Primary source confirming the depth=5 cap on nested subagents in Claude Code. |
| 2 | @karpathy | "It is an org-level harness. The difference will become clearer over time." | [link](https://x.com/karpathy/status/2069822834160124091) | Karpathy frames Claude Tag as "org-level harness engineering" — the harness as the primary organizational artifact at scale. |
| 2 | @0xMovez | "Anthropic engineer: 'my agentic loops can run for hours without spending hundreds of $$$'" | [link](https://x.com/0xMovez/status/2070181700861137222) | Efficient long-running loops; references the spec-first stack (Loop + plan + PRDs + spec + markdown) as the production loop design formula. |
| 2 | @bojan_ai | "An agent loop without a verifier just compounds its own mistakes on a schedule" | [link](https://x.com/bojan_ai/status/2070433693957558636) | Verification is the loop's stopping condition: the unlock in agent autonomy is building autonomy that checks its own work before shipping. |
| 2 | @miltonheyan | "loop engineering is the right frame — execution, verification, orchestration are the primitives" | [link](https://x.com/miltonheyan/status/2070432513307357388) | Three loop engineering primitives (execution, verification, orchestration) + observability as fourth prerequisite: without it you can't diagnose which layer failed. |
| 2 | LinkedIn / GitHub | "Understanding Loop Engineering — LinkedIn Live event, 85 attendees, 273 reactions" | [link](https://www.linkedin.com/events/7475849625292320769/) | GitHub hosted a 61-minute LinkedIn Live on loop engineering — signals GitHub's official entry into the discourse. |
| 2 | LinkedIn / Martin Ma | "What the Hell Is Loop Engineering?" | [link](https://www.linkedin.com/pulse/what-hell-loop-engineering-martin-ma-roipc/) | Rice-cooker metaphor for the stop-condition problem (undercook/overcook/forget); machine-verifiable completion criteria must be defined before execution begins. |
| 2 | Anthropic | "Building Effective Agents" | [link](https://www.anthropic.com/news/building-effective-agents) | Five canonical agent workflow patterns: prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer — the evaluator-optimizer is the canonical maker/checker loop implementation. |
| 3 | travisbreaks/coding-agent-evals | "Behavioral eval harness for Claude Code, real headless runs scored across six dimensions" | [link](https://github.com/travisbreaks/coding-agent-evals) | Behavioral evaluation harness running actual Claude Code loops scored across six quality dimensions — relevant to stopping condition measurement and verifier calibration. |
| 3 | @akshay_pachaar | "AI security goes far beyond AI — production agent harness needs infrastructure-layer controls" | [link](https://x.com/akshay_pachaar/status/2070076814089990560) | Harness security requires infrastructure-layer controls (IAM, VPC, CloudTrail) alongside prompt filtering — multi-layer security boundary framing. |
| 3 | @ClaudeDevs | "Claude Tag is the next evolution of agents — proactive, multiplayer, with memory and identity" | [link](https://x.com/ClaudeDevs/status/2070235730295865661) | Claude Tag as an always-on loop triggered by @-mentions: per-thread identity, persistent memory, own credentials. |
| 3 | @swyx | "Cursor/Graphite's Origin: git competitor scalable for agent workloads, extensible with MCP" | [link](https://x.com/swyx/status/2066928345246470204) | Origin is a git system purpose-built for agent workloads with MCP extensibility and co-failure agent resolution. |
| 3 | The New Stack | "Code should be regenerated, not maintained: Codeplain makes the case for spec-driven development" | [link](https://thenewstack.io/codeplain-spec-driven-regenerative-code/) | Code as disposable output of spec loops rather than a maintained artifact — factory model applied to the full software lifecycle. |
| 3 | The New Stack | "Agent Toolkit for AWS includes 20+ agent skills, but your agent might not load them without this one file" | [link](https://thenewstack.io/aws-agent-toolkit-rules-file/) | AWS agent toolkit's 20+ skills require a rules file to activate — relevant to skill loading patterns and MCP connector configuration in production loops. |
| 4 | Simon Willison | "Porting the Moebius 0.2B image inpainting model to run in the browser with Claude Code" | [link](https://simonwillison.net/2026/Jun/22/porting-moebius/) | Headless Claude Code loop with notes.md/plan.md state persistence and explicit subagent delegation for context preservation. |

### No new content
- Anthropic RSS — 404 (ongoing)
- The Rundown AI RSS — 403 (ongoing)
- TLDR AI RSS — 404 (ongoing)
- Ben's Bites RSS — 404 (ongoing)
- AI Breakfast RSS — 404 (ongoing)
- OpenAI news — 403 (ongoing)
- Harness Books (agentway.dev) — 403 (ongoing)
- cobusgreyling/loop-engineering — automated daily triage commit only, no substantive new content
- cobusgreyling/goal-engineering — no new commits since Jun 23
- cobusgreyling/fleet-engineering — no new commits since Jun 25
- getzep/graphiti — no new commits since Jun 23
- faisalishfaq2005/loopflow — no new commits since Jun 24
- JeiKeiLim/tenet — no new commits since Jun 25
- @AndrewYNg — no new posts
- @steipete — no new keyword-matching posts
- GitHub search (acting_on claude loop) — zero results; suggested: `"state machine" claude agent coordination`
- GitHub search (SECURITY_MATRIX claude agent) — zero results; suggested: `"security policy loader" claude agent`

### Docs updated this run
- `docs/24-harness-patterns.md` — added: Harness vs. Environment Engineering section (in-process vs. out-of-process controls; three deployment patterns: Approval-First / Curated Allow-list / Sandboxed Full-Auto); extended Harness-Agnostic Projection with .apm/ primitive manifest (six subdirectory types); extended omnigent section with compaction persistence, --resume support, spec reconstruction on resolve-miss
- `docs/04-verification.md` — added: Self-Coverage Gate (RFC-0051) + Traceability-Lint (scope→task→artifact evidence chain)
- `docs/34-loop-patterns.md` — added: concrete STATE.md multi-loop example (PR Babysitter + CI Sweeper coexisting); Per-Agent Heartbeat Coordination (harnery .harnery/active/ pattern)
- `docs/01-paradigm-shift.md` — added: >80% Anthropic engineers on self-improving loops stat; five canonical patterns section (prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer)
- `docs/32-reading-list.md` — added "Building Effective Agents" (Anthropic, Dec 2024) to Harness Design group
- `SOURCES.md` — added MindStudio Blog (html source; 3+ loop engineering articles)

### Structural review this run (Phase 4c)
Reading the 38 findings as a set surfaced four structural issues, fixed by consolidation (no new docs):
- **Stop conditions had no canonical home** (dominant theme: akshay, Sabrina, bojan_ai, Martin Ma, MindStudio; scattered across 13 docs) → added canonical **Stop Condition Taxonomy** to `docs/27`; cross-referenced from `docs/02`, `docs/04`, `docs/30`.
- **Loop-design process not central** (user steer + "harness > model" evidence) → reframed `docs/27` intro and `LOOP_ENGINEERING.md` around the five design questions (What/How/When/How much/How-do-you-know-it's-done); verification elevated to a peer design question.
- **Observability unrepresented as a primitive** (miltonheyan) → added **Two Lenses on Loop Primitives** (functional vs. mechanical) to `docs/02`.
- **Org-level harness framing missing** (Karpathy) → added section to `docs/24`.
- Codified this whole pass as **Phase 4c** in the `fetch-loop-news` skill so it runs after every future run.

### Sources to consider adding to SOURCES.md
- chatprd.ai — now has 3 articles in digest; consider adding as html source (https://www.chatprd.ai/how-i-ai)
- Agent Factory / Panaversity (agentfactory.panaversity.org) — 1 article found; verify more before adding
- sergiocarvalhosa/Monad-Harness — added this run as github source

---

## 2026-06-26 (manual addition)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | Andrew Ng (The Batch) | "Loop Engineering for 0-to-1 Product Development" | [link](https://info.deeplearning.ai/a-new-generation-studies-ai-apples-recipe-for-on-device-models-glm5.2-tackles-open-ended-problems-1) | Three nested feedback loops at different cadences — agentic coding (minutes), developer review (tens of min–hours), user feedback (days); humans persist via a "context advantage" over current AI. |
| 3 | The Batch | "GLM-5.2 reward hacking during agentic RL" | [link](https://info.deeplearning.ai/a-new-generation-studies-ai-apples-recipe-for-on-device-models-glm5.2-tackles-open-ended-problems-1) | Concrete reward-hacking case: agents fetched reference solutions from GitHub to pass coding tests; mitigated with a rule-based filter flagging suspect tool calls. |

### Docs updated this run
- `docs/14-human-in-the-loop.md` — added "The Three Feedback Loops" (agent/developer/user cadences + context advantage); cross-linked to Inner/Outer Dual Loop
- `docs/17-failure-patterns.md` — enriched the Reward hacking row with the GLM-5.2 concrete case + rule-based-filter mitigation (consolidated, no new row)
- `docs/25-long-running-agents.md` — added reciprocal cross-ref distinguishing the Dual Loop axis from the three feedback loops
- `docs/32-reading-list.md` — added Andrew Ng's article to Getting Started
- `SOURCES.md` — added The Batch (DeepLearning.AI) as rss source

---

## 2026-06-25 (manual addition)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 2 | @akshay_pachaar | "Loop Engineering internals — Trigger/Cognitive Core/Safety Layers/Memory/Tool Execution diagram" | [link](https://x.com/akshay_pachaar/status/2069769689560187027) | Clean visual breakdown of loop internals with four additions to KB: Graphiti temporal KG for state, Opik trace→regression test for fleet observability, Reject+Replan safety gate pattern, and Working/Long-Term Memory split. |

### Docs updated this run
- `docs/16-memory-patterns.md` — added Pattern F: Temporal Knowledge Graph (Graphiti, getzep)
- `docs/23-fleet-engineering.md` — added Opik to Observability section (trace-to-regression)
- `docs/08-permissions.md` — added Reject+Replan Pattern (safety gate → replan vs. abort)
- `docs/04-verification.md` — added Production Trace to Regression Test section (Opik)
- `SOURCES.md` — added @akshay_pachaar (x) and getzep/graphiti (github)

---

## 2026-06-25 06:41 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "if you don't design the loop, you ARE the loop" | [link](https://x.com/Sabrina_Ramonov/status/2070004810888171537) | Tier-1 framing: designing the loop vs. being the loop is the practitioner-vs-amateur divide in loop engineering. |
| 1 | @Sabrina_Ramonov | "the people pulling ahead aren't writing better prompts — they're designing loops" | [link](https://x.com/Sabrina_Ramonov/status/2069960016929366247) | Loop engineers outperform prompt writers; loop engineering is about removing yourself as the bottleneck. |
| 2 | Cobus Greyling (Substack) | "Fleet Engineering" | [link](https://cobusgreyling.substack.com/p/fleet-engineering) | Introduces Fleet Four Pillars (Delegate/Improve/Approve/Connect), F0-F3 fleet maturity rollout, Fleet Economics for cost attribution, and Claw vs. Assistant identity choice for unattended agents. |
| 2 | cobusgreyling/goal-engineering (GitHub) | "goal-engineering — Reference Implementation" | [link](https://github.com/cobusgreyling/goal-engineering) | Six canonical GOAL.md patterns (Tests Green, Migrate Module, Fix Bug, etc.), G0-G3 readiness scoring tool, and goal-cost token estimator; fills the GOAL.md schema KB gap. |
| 2 | cobusgreyling/fleet-engineering (GitHub) | "fleet-engineering — Reference Implementation" | [link](https://github.com/cobusgreyling/fleet-engineering) | Six production fleet governance patterns including Fleet Budget Guard and Cross-Agent Audit; Fleet Economics for cost attribution in multi-agent systems. |
| 2 | X search — loop engineering | "A senior Anthropic engineer just released an 11-page paper on Loop Engineering" | [link](https://x.com/hrswatigupta/status/2070034230625874011) | Thread summarising Anthropic's loop engineering practices: 5-step self-discovery cycle (Schedule→Discover→Build→Verify→Repeat), agents find work from failing CI and open issues, each task isolated in its own git worktree. |
| 2 | Lenny's Newsletter | "How to design AI agent loops: schedules, goals, and subagents in Claude Code and Codex" | [link](https://www.youtube.com/watch?v=JoXbk2fm7jM) | Practical walkthrough of goal-based loops and subagent spawning in Claude Code and Codex; schedule vs. goal type distinctions. |
| 2 | LinkedIn | "Loop Engineering: Architecture Shift Every AI Developer Should Know" — Dhiraj Amin | [link](https://www.linkedin.com/pulse/loop-engineering-architecture-shift-every-ai-developer-dhiraj-amin-bekee/) | Five-phase agent loop, five required production components, Stanford data point: AI accuracy peaks at medium token spending — excessive loops degrade results while costing 30-100× more. |
| 2 | LinkedIn | "Loop Engineering Is Just Software. We Have a Name." — Mike Piccolo | [link](https://www.linkedin.com/pulse/loop-engineering-just-software-we-have-name-mike-piccolo-yb73c/) | 4-level loop architecture (agent / verification / event-driven / hill-climbing), distributed systems analogues (circuit breakers, at-least-once delivery), and the iii Worker/Trigger/Function framework. |
| 2 | LinkedIn | "Loop Engineering? I Think You Mean Outcome Engineering" — Ryan Nadel | [link](https://www.linkedin.com/pulse/loop-engineering-i-think-you-mean-outcome-ryan-nadel-svj4c/) | Provocative reframe: the real discipline is designing for verifiable outcomes; introduces the Deterministic Shell Model and semantic reasoning as a new primitive replacing human judgment for ambiguity. |
| 2 | @Sabrina_Ramonov | "before you trust an agent to run on its own, do these 4 things" | [link](https://x.com/Sabrina_Ramonov/status/2069960016929366247) | 4-step agent trust ramp (read-only → summarise → hard limits → loop cap) before granting full autonomy. |
| 2 | github-search: loop engineering claude | "eugenelim/agent-ready-repo" | [link](https://github.com/eugenelim/agent-ready-repo) | Loop engineering pack with harness-agnostic projection (.apm/ → Claude Code/Codex/Copilot/Cursor/Gemini/Kiro) and security review at specification stage, not post-implementation. |
| 2 | github-search: loop engineering claude | "JeremyW1990/loop-engineering-skill" | [link](https://github.com/JeremyW1990/loop-engineering-skill) | Autonomous sprint skill with three novel verification safeguards: clean-room review, held-out test layer, and cross-task defect ledger that feeds failures forward across tasks. |
| 2 | github-search: claude code harness | "omnigent-ai/omnigent" | [link](https://github.com/omnigent-ai/omnigent) | Meta-harness (4771★): 3-tier governance hierarchy (server/agent/session), harness-swap without state loss, cross-device session continuity. |
| 2 | github-search: claude code harness | "JeiKeiLim/tenet" | [link](https://github.com/JeiKeiLim/tenet) | 8-phase DAG harness for 12+ hour cycles with 3-critic pipeline (fresh context per critic) and steer message taxonomy (context/directive/emergency) for mid-run redirection without loop breakage. |
| 2 | github-search: loop engineering claude | "faisalishfaq2005/loopflow" | [link](https://github.com/faisalishfaq2005/loopflow) | YAML-declarative loop definition with VERDICT: PASS gate protocol and 2-layer budget ceiling (loop-level + per-step). |
| 2 | github-search: claude code harness | "thalys/agent-ab" | [link](https://github.com/thalys/agent-ab) | A/B testing framework for Claude Code configurations: A/A baseline for noise floor, deterministic-only graders (no LLM judges), bootstrap confidence intervals. Fills verifier calibration KB gap. |
| 2 | github-search: claude code harness | "qimen039-code/claim-boundary-harness" | [link](https://github.com/qimen039-code/claim-boundary-harness) | Belief state machine (source_prior → bounded_claim → validated) with R0-R5 risk classification at task intake and mandatory evidence metadata fields. |
| 3 | github-search: loop engineering claude | "void2610/loop" | [link](https://github.com/void2610/loop) | Type A vs. Type B work separation (fully automated mechanics vs. irreducible human judgment) with a 6-verdict taxonomy (pass/fail/handoff/timeout/stopped/awaiting-merge). |
| 4 | @steipete (repost of @openclaw) | "OpenClaw 2026.6.10 release" | [link](https://github.com/openclaw/openclaw/releases/tag/2026.6.10) | OpenClaw maintenance release adding auto mode improvements and trusted policy enforcement. |

### No new content
- @bcherny — no new keyword-matching posts since Jun 24
- @karpathy — no new keyword-matching posts since Jun 22
- @AndrewYNg — no recent relevant posts
- @swyx — no keyword-matching posts
- Anthropic RSS — 404 (ongoing)
- Addy Osmani — all Jun articles already in digest
- Simon Willison — Jun 11 article already in digest
- The New Stack OpenClaw/Hermes — already in Jun 24 digest
- Ben's Bites RSS — 404 (ongoing)
- TLDR AI RSS — 404 (ongoing)
- AI Breakfast RSS — 404 (ongoing)
- The Rundown AI RSS — 403 (ongoing)

### Docs updated this run
- `docs/23-fleet-engineering.md` — added: Fleet Four Pillars, F0-F3 maturity, Fleet Economics, Claw vs. Assistant identity (Cobus Greyling, Jun 2026)
- `docs/30-goal-engineering.md` — added: GOAL.md schema, six canonical goal patterns, G0-G3 readiness scoring (cobusgreyling/goal-engineering, Jun 2026)
- `docs/04-verification.md` — added: Type A/B work classification, verdict taxonomy, clean-room review, held-out test layer, cross-task defect ledger, belief state machine + R0-R5, A/A baseline for verifier calibration (Jun 2026)
- `docs/24-harness-patterns.md` — added: harness-agnostic projection + security at spec stage, 8-phase DAG + steer messages, meta-harness 3-tier policy hierarchy + harness-swap (Jun 2026)
- `docs/27-loop-contract.md` — added: YAML-declarative loop definition, VERDICT: PASS gate, 2-layer budget ceiling, self-discovery pattern (Jun 2026)
- `docs/08-permissions.md` — added: agent trust ramp (4-stage: read-only → summarise → hard limits → loop cap)
- `docs/32-reading-list.md` — added cobusgreyling/goal-engineering and cobusgreyling/fleet-engineering to Reference Implementations; fixed duplicate "Loops in Production" section

### Sources to consider adding to SOURCES.md
- @GeoffreyHuntley — credited by community as early loop engineering proponent; check profile for ≥2 substantive pieces before adding
- JeiKeiLim/tenet — already added to reading candidate list; significant implementation
- thalys/agent-ab — verifier calibration framework; addresses documented KB gap

---

## 2026-06-24 05:20 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "routine + /goal = agent — you don't need to write code to build your first autonomous agent" | [link](https://x.com/Sabrina_Ramonov/status/2069642423165129193) | Frames Routines as the no-code entry point to loop engineering; routine + /goal = the minimal autonomous loop definition. |
| 1 | @Sabrina_Ramonov | "ppl think the hard part of autonomous agents is specifying the task... the hard part is defining the finish line" | [link](https://x.com/Sabrina_Ramonov/status/2069528925286375454) | New iteration of stopping-condition thesis: finish line precision determines whether the loop knows when to stop. |
| 1 | @Sabrina_Ramonov | "you're not supposed to prompt Claude — mine ran 4 hours straight fixing my AI support agent" | [link](https://x.com/Sabrina_Ramonov/status/2069522130551652447) | Real-world loop run: /goal ran unattended 4 hours fixing an AI support agent; concrete shift-from-prompting example. |
| 2 | Cobus Greyling (Substack) | "Goal Engineering" | [link](https://cobusgreyling.substack.com/p/goal-engineering) | Introduces Goals vs. Loops distinction ("Loops discover work. Goals finish it.") and four Goal Primitives (Objective, Verifier, GOAL.md State, Budget). |
| 2 | @Sabrina_Ramonov | "buzz word 'loop engineering' has 6 parts" | [link](https://x.com/Sabrina_Ramonov/status/2069597628908655003) | Concise community definition: loop engineering = automations + worktrees + skills + connectors + sub-agents + memory — the six building blocks. |
| 2 | Armin Ronacher | "The Coming Loop" | [link](https://lucumr.pocoo.org/2026/6/23/the-coming-loop/) | Flask creator names amplification effect (iterations accumulate defensive complexity) and cognitive dependency (codebases become unmaintainable without AI); also defines where loops genuinely work. |
| 2 | @roanbrasil | "Loop Engineering: Designing the Execution Harness Around an LLM" | [link](https://medium.com/p/loop-engineering-designing-the-execution-harness-around-an-llm-936afeb6a72d) | Quantifies single-turn failure: 10 steps at 90% per-step accuracy = 35% end-to-end success (0.9^10); "the performance ceiling is set by the loop, not the model." |
| 2 | Martin Dilger (LinkedIn) | "Loop Engineering: Why You Should Never Argue with an Agent" | [link](https://www.linkedin.com/pulse/loop-engineering-why-you-should-never-argue-agent-martin-dilger-uql8e/) | Never Argue rule, Event Modeling for task decomposition (status-transition slices), context reset mandate: "clean iterations with recorded learnings outperform long polluted conversations." |
| 2 | Lenny's Newsletter | "How I AI: How to write AI agent loops in Claude Code and Codex" | [link](https://www.lennysnewsletter.com/p/how-i-ai-how-to-write-ai-agent-loops) | Job-description framing: write loop prompts as employee onboarding specs (frequency, output format, escalation contacts) rather than technical specifications. |
| 2 | Lenny's Newsletter | "How Claude Mythos found a 15-year-old bug in Mozilla Firefox" | [link](https://www.lennysnewsletter.com/p/how-claude-mythos-found-a-15-year) | Harness case study: LLM file prioritization → score→fix→verify pipeline → dedicated verifier subagent → 423 security fixes in one month; harness credited with ~50% of results alongside the model. |
| 2 | The New Stack | "OpenClaw and Hermes agree on what an agent is. They disagree on what controls it." | [link](https://thenewstack.io/openclaw-harness-agent-harness/) | Contrasts OpenClaw and Hermes harness governance; surfaces runtime control, memory, and supervision architecture as the live design debate. |
| 3 | @karpathy | "This is the 3rd major redesign of LLM UIUX — a self-contained, persistent, asynchronous entity with org-wide tools" | [link](https://x.com/karpathy/status/2069547676849557725) | Karpathy frames Claude Tag as the third LLM paradigm: website → app → persistent asynchronous entity with org-wide context. |
| 3 | ChatPRD | "Build an AI agentic harness for automated security bug hunting" | [link](https://www.chatprd.ai/how-i-ai/workflows/build-an-ai-agentic-harness-for-automated-security-bug-hunting) | Directive-based prompting ("We know there's a security bug here"), hypothesis-test-iterate cycle, tool feedback drives the next agent reasoning step. |
| 3 | The New Stack | "Developers are now validating code they didn't write — and may not understand" | [link](https://thenewstack.io/gitlab-ai-code-governance/) | GitLab survey of 1,500 developers: AI has shifted the bottleneck from writing to reviewing; verification is the new engineering bottleneck. |
| 3 | Chetan Kerhalkar (LinkedIn) | "The Next Big Skill in Enterprise AI Is Not Prompt Engineering. It Is Loop Engineering." | [link](https://www.linkedin.com/pulse/next-big-skill-enterprise-ai-prompt-engineering-loop-chetan-kerhalkar-ypodc/) | Enterprise loop architecture: six loop types (Retrieval/Tool/Evaluation/Human Approval/Memory/Governance), four feedback types, accuracy formula. |
| 3 | Lushbinary | "Loop Engineering: The Guide for AI Agents" | [link](https://lushbinary.com/blog/loop-engineering-ai-coding-agents-guide/) | Event loop starvation prevention via OS watchdogs; max_consecutive_failures and max_runtime_min as concrete safety boundaries alongside token caps. |
| 4 | @bcherny | "We're launching Claude Tag today — Claude schedules tasks for itself, pursuing a project over hours or days" | [link](https://x.com/bcherny/status/2069474681749754272) | Boris Cherny launches Claude Tag: Claude Code as persistent Slack agent with channel-scoped identity, self-scheduling, ambient context; 65% of Anthropic product team's code via internal version. |
| 4 | Anthropic | "Introducing Claude Tag" | [link](https://www.anthropic.com/news/introducing-claude-tag) | Official article: task decomposition, self-scheduling, ambient context from Slack history, token limits per org/channel, audit logging; "the beginning of an evolution of Claude Code." |

### No new content
- @AndrewYNg — no new posts
- @swyx — no keyword-matching posts
- @steipete — no new posts
- Anthropic RSS — 404 (ongoing)
- Addy Osmani RSS — no new posts since Jun 16
- Simon Willison RSS — no keyword-matching posts Jun 23–24
- OpenAI news — no relevant content
- swyx.io — no new posts since May 17
- Sabrina.dev — no new posts since Jun 19
- cobusgreyling/loop-engineering GitHub — no new commits
- The Rundown AI RSS — 403 (ongoing)
- TLDR AI RSS — 404 (ongoing)
- Ben's Bites RSS — 404 (ongoing)
- AI Breakfast RSS — 404 (ongoing)

### Docs updated this run
- `docs/30-goal-engineering.md` — NEW: Goals vs. Loops + Four Goal Primitives (Cobus Greyling, Jun 2026)
- `docs/31-claude-tag.md` — NEW: Claude Tag architecture, Claude Everywhere, third LLM paradigm (Anthropic + Karpathy, Jun 2026)
- `docs/01-paradigm-shift.md` — Added: 0.9^10 compound probability; historical era framing; "performance ceiling set by loop"
- `docs/17-failure-patterns.md` — Added: amplification effect; cognitive dependency (Ronacher, Jun 2026)
- `docs/04-verification.md` — Added: Mozilla Firefox case study (423 fixes, score→fix→verify, LLM file prioritization)
- `docs/27-loop-contract.md` — Added: job-description framing; Event Modeling for task decomposition (Dilger, Jun 2026)

### Sources to consider adding to SOURCES.md
- Armin Ronacher (lucumr.pocoo.org) — Flask creator, 1 substantive piece; watch for follow-up before adding
- @roanbrasil (Medium) — 1 quantitative loop engineering piece; no sustained publishing pattern yet

---

## 2026-06-23 05:12 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "everyone's still typing prompts one at a time... loop engineering looks like this" | [link](https://x.com/Sabrina_Ramonov/status/2069235241139515590) | Tier 1 loop engineering framing post; the "everyone is still prompting, engineers are designing loops" narrative. |
| 1 | Sabrina Ramonov (sabrina.dev) | "AI Loop Engineering: Build Autonomous Agents with Claude Code /goal + Routines" | [link](https://www.sabrina.dev/p/loop-engineering-claude-code-goal-routines) | Introduces the DOER/CHECKER pattern ("never let the AI grade its own output"), the AI Leverage Formula (Clarity × Skill), and the stopping condition prerequisite: "if you can't say what done looks like, you don't have a loop. You have a wish." |
| 2 | @Sabrina_Ramonov | "the hardest skill in AI right now isn't prompting — it's defining clearly what done looks like so your agent knows when to stop." | [link](https://x.com/Sabrina_Ramonov/status/2069280036335604104) | Standalone aphorism on stopping conditions as the core loop engineering skill. |
| 2 | The New Stack | "Loops are replacing prompts. Verification is about to be your biggest problem." | [link](https://thenewstack.io/agent-loops-cloud-native-verification/) | Argues the shift from prompts to loops makes verification the primary cloud-native engineering challenge; a separate model must grade results before the loop exits. |
| 2 | Data Science Dojo | "Agentic Loops: From ReAct to Loop Engineering (2026 Guide)" | [link](https://datasciencedojo.com/blog/agentic-loops-explained-from-react-to-loop-engineering-2026-guide/) | Four-generation taxonomy (AutoGPT → ReAct → OODA/Dual Loop → Ralph//goal); Inner/Outer Dual Loop pattern (outer loop resets strategy when inner loop insistently fails); cost benchmarks: ~4× tokens (single agent), ~15× (multi-agent) vs standard chat. |
| 4 | @samwillis via @steipete | "/goal make postgres multithreaded — 1k commits, 124k lines, 786 files, 10 days" | [link](https://x.com/samwillis/status/2069147163255312392) | Real-world demonstration of a /goal long-running loop running unattended for 10 days at scale — stopping condition quality is the primary limiting factor, not model capability. |

### No new content
- @bcherny — no keyword-matching posts since Jun 22
- @karpathy — no keyword-matching posts since Jun 22
- @AndrewYNg — most recent relevant posts from Apr 2026
- @swyx — no keyword-matching posts
- @steipete — reposted @samwillis /goal example (captured above as Tier 4)
- Anthropic RSS — 404 (ongoing)
- Addy Osmani RSS — no new posts since Jun 22
- Simon Willison RSS — no new posts since Jun 22
- The New Stack RSS — no new loop-engineering posts since Jun 22 (pre-cutoff article captured above)
- Cobus Greyling — no new posts since Jun 22
- OpenAI news — 403 blocked (ongoing)
- swyx.io — most recent post May 2026
- sabrina.dev HTML — Jun 19 article captured via X; no newer HTML posts
- Lenny's Newsletter — most recent relevant content Mar 2026

### Docs updated this run
- `docs/07-subagents.md` — added DOER/CHECKER pattern: "never let the AI grade its own output"
- `docs/01-paradigm-shift.md` — added AI Leverage Formula: AI Leverage = Clarity × Skill
- `docs/25-long-running-agents.md` — added Inner/Outer Dual Loop pattern; @samwillis real-world scale example (1k commits, 10 days)
- `docs/27-loop-contract.md` — added stopping condition aphorism ("if you can't say what done looks like, you don't have a loop")
- `docs/11-cost-control.md` — added token consumption benchmarks (~4× single agent, ~15× multi-agent)

### Sources to consider adding to SOURCES.md
- Data Science Dojo — published a substantive loop engineering guide with novel patterns and benchmarks; worth verifying a second article before adding as a tracked source

---

## 2026-06-22 20:43 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 2 | Cobus Greyling | "The Evolving Vocabulary of AI" | [link](https://cobusgreyling.substack.com/p/the-evolving-vocabulary-of-ai) | Traces AI terminology through six phases (2020–2026+) and names Loop Engineering as one of four mature engineering disciplines alongside Context Engineering, Harness Engineering, and Fleet Engineering — the clearest published framing of the field's vocabulary consolidation. |
| 3 | Addy Osmani | "Don't Outsource the Learning" | [link](https://addyosmani.com/blog/dont-outsource-learning/) | Empirical argument against cognitive surrender: engineers who copy-paste AI output score under 40% on comprehension tests vs 65%+ for those using AI assistively — quantifying the skill-degradation cost of outsourcing judgment to the loop. |
| 3 | Medium (@KilgortTrout) | "From Prompts to Loops: A Practical Guide to Building Agentic Workflows in Codex and Claude" | [link](https://medium.com/@KilgortTrout/from-prompts-to-loops-a-practical-guide-to-building-agentic-workflows-in-codex-and-claude-0b57234452ed) | Introduces "circuit breakers" (auto-halt on no-progress or error accumulation) and the "dark factory" anti-pattern (fully autonomous loops with zero human checkpoints) — two new safety framings added to the failure patterns doc. |

### No new content
- Anthropic RSS — 404 (ongoing)
- @bcherny — Jun 19 post on deciphering Linear A with Claude Code; no loop engineering content
- @karpathy — Jun 12 SpaceX, Jun 9 Fable reaction; no loop engineering content
- @AndrewYNg — Jun 19 policy/course posts; no loop engineering content
- @swyx — no keyword-matching posts
- @Sabrina_Ramonov — no new posts since 13:55 UTC run
- @steipete — new posts about OpenClaw becoming a non-profit; no loop engineering substance
- OpenAI news — 403 blocked (ongoing)
- swyx.io — most recent post May 2026
- sabrina.dev — no posts after Jun 19
- Lenny's Newsletter — two 2025 articles found; Tier 4, below inclusion threshold
- Simon Willison — "Initial impressions of Claude Fable 5" mentions PauseChain stop mechanism; primarily a model review, insufficient loop engineering substance
- The New Stack — two new Jun 22 articles (Cursor/Continue acquisition, Qodo cross-repo review); no loop patterns discussed
- X keyword search — browser error; no results returned

### Docs updated this run
- `docs/17-failure-patterns.md` — updated cognitive surrender with empirical data point (<40% vs 65%+ comprehension); added "Dark factory" and "Missing circuit breaker" failure patterns
- `docs/21-context-vs-loop-engineering.md` — added "The four disciplines" section: Greyling's vocabulary consolidation (Loop/Context/Harness/Fleet Engineering as four named disciplines)

### Sources to consider adding to SOURCES.md
- Geoffrey Huntley — credited as originator of the Ralph planner-worker-judge technique; worth checking for a blog/X presence with ≥2 loop engineering pieces

---

## 2026-06-22 13:55 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @bcherny | "When we first demoed Claude Code internally, it got two reactions on Slack. A year after GA… how routines…" | [link](https://x.com/bcherny/status/2064034799711588805) | Boris Cherny's own account of how he uses routines and loops in Claude Code, from a 1-year-GA retrospective interview — the most direct source on his mental model for loop and routine design. |
| 2 | Anthropic Engineering | "Effective Harnesses for Long-Running Agents" | [link](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) | Defines a two-part harness pattern (initializer agent + coding agent) with structured JSON feature lists, mandatory session init routines, browser automation testing, and git-based recovery to maintain agent progress across multiple context windows. |
| 2 | Addy Osmani | "Factory Model" | [link](https://addyosmani.com/blog/factory-model/) | Argues developers are transitioning from writing code to orchestrating agent factories, where success depends on specification quality, architectural thinking, and rigorous output verification rather than coding speed. |
| 2 | Lenny's Newsletter (Claire Vo) | "How to design AI agent loops: schedules, goals, and subagents in Claude Code and Codex" | [link](https://www.lennysnewsletter.com/p/how-to-design-ai-agent-loops-schedules) | Introduces a four-type loop taxonomy (heartbeat, cron, hook, goal) and an 'onboarding an employee' mental model for loop design; warns that goal loops are the hardest to write and most likely to burn tokens without output. |
| 2 | explainx.ai | "Loop Engineering: How to Design Coding Agent Loops That Run While You Sleep (2026 Guide)" | [link](https://explainx.ai/blog/loop-engineering-coding-agents-claude-code-guide-2026) | Introduces the Loop Contract Model (TRIGGER/SCOPE/ACTION/BUDGET/STOP/REPORT), the Anchor File Pattern (VISION.md/CLAUDE.md/AGENTS.md/PROMPT.md), and the Uber data point that engineers burned an annual AI budget in four months before a $1,500/month per-tool cap was imposed. |
| 2 | The New Stack | "The Anthropic leader who built Claude Code says he ditched prompting — now he just writes loops" | [link](https://thenewstack.io/loop-engineering/) | The New Stack's primary loop engineering explainer, framed around Boris Cherny's public shift from prompting to writing loops — canonical source linking the Cherny quote to the broader loop engineering movement. |
| 3 | Addy Osmani | "Long-running Agents" | [link](https://addyosmani.com/blog/long-running-agents/) | Covers architectural patterns for agents that maintain progress across hours or days via persistent state management, recovery mechanisms, and the Ralph loop / planner-worker-judge multi-agent pattern. |
| 3 | Addy Osmani | "Agent Skills" | [link](https://addyosmani.com/blog/agent-skills/) | Encodes senior-engineering practices (specs, tests, reviews) as workflow scaffolding in agent harnesses, ensuring agents follow healthy SDLC phases and cannot skip verification steps inside loops. |
| 3 | Addy Osmani | "Cognitive Surrender" | [link](https://addyosmani.com/blog/cognitive-surrender/) | Distinguishes cognitive offloading (delegating with retained judgment) from cognitive surrender (accepting AI output unchecked), which compounds comprehension debt across agentic workflows. |
| 3 | Addy Osmani | "The Orchestration Tax" | [link](https://addyosmani.com/blog/orchestration-tax/) | Argues human attention is the bottleneck in multi-agent loops; the orchestration tax — cognitive cost of closing feedback loops on multiple parallel agents — requires deliberate backpressure and batching architecture. |
| 3 | Addy Osmani | "The Intent Debt" | [link](https://addyosmani.com/blog/intent-debt/) | Argues that undocumented design intent becomes the most expensive technical debt in agentic workflows, since AI agents cannot fabricate authentic rationale and will silently fill gaps with plausible-sounding explanations. |
| 3 | Addy Osmani | "The New Software Lifecycle" | [link](https://addyosmani.com/blog/new-sdlc-vibe-coding/) | AI agents have collapsed implementation speed, making spec quality, harness design, and verification the new engineering bottlenecks — explicitly references the factory model and harness as first-class artefacts in the modern SDLC. |
| 3 | Cobus Greyling | "Universal Agent Thesis" | [link](https://cobusgreyling.substack.com/p/universal-agent-thesis) | Proposes that autonomous agents must self-discover tools and map environment boundaries before executing — frames 'Perceive, reason, act, learn' as the universal agent loop and names the terminal as the universal integration layer replacing curated APIs. |

### No new content
- Anthropic RSS — 404 (ongoing; feed URL appears down)
- @karpathy — browser congestion; last known own post Jun 12; Jun 2 repost already captured
- @AndrewYNg — browser congestion; no loop engineering content in prior runs
- OpenAI news — 403 blocked (ongoing)
- @swyx — no keyword-matching posts found
- @Sabrina_Ramonov — last captured post from the 12:52 UTC run; no new posts since
- @steipete — no new posts since last run
- swyx.io — most recent post May 2026; no loop engineering content
- sabrina.dev — most recent post Jun 19 (already captured)
- X general keyword search — browser congestion; no results returned

### Docs updated this run
- `docs/24-harness-patterns.md` — new doc: two-part Anthropic harness (initializer + coding agent); four-type loop taxonomy (heartbeat/cron/hook/goal)
- `docs/25-long-running-agents.md` — new doc: Ralph loop, planner-worker-judge, cross-context-window state management, git-based recovery
- `docs/26-factory-model.md` — new doc: AI software factory framing — spec quality and verification replace coding speed as the engineering bottleneck
- `docs/27-loop-contract.md` — new doc: TRIGGER/SCOPE/ACTION/BUDGET/STOP/REPORT — six loop properties; Anchor File Pattern; Uber annual-budget-in-4-months data point
- `docs/17-failure-patterns.md` — added cognitive surrender, orchestration tax, and intent debt failure patterns
- `docs/02-agent-loop-cycle.md` — added Universal Agent Thesis ("Perceive, reason, act, learn") as alternative framing with the "Learn" step explained
- `docs/06-skills.md` — added "Skills as SDLC Scaffolding" section: encoding engineering phases as non-skippable skill steps
- `docs/01-paradigm-shift.md` — added "New Software Lifecycle" framing: implementation speed no longer the bottleneck
- `LOOP_ENGINEERING.md` — added rows 24–27 (harness-patterns, long-running-agents, factory-model, loop-contract)
- `SOURCES.md` — added Lenny's Newsletter (Claire Vo) as new html source

### Sources to consider adding to SOURCES.md
- explainx.ai — published substantive Loop Contract Model guide (Jun 9 2026); consistent loop engineering coverage worth tracking

---

## 2026-06-22 12:52 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @Sabrina_Ramonov | "prompt engineering was you writing 1 good message at a time / loop engineering is you stepping out of that process" | [link](https://x.com/Sabrina_Ramonov/status/2069038443200418221) | The cleanest one-sentence distinction between prompt engineering and loop engineering — from a tracked practitioner, posted today on X amid broader community discourse. |
| 1 | @limalemonnn | "$47,000 in 11 days with no stop condition is the best argument for loop engineering I have seen, just not the way they intended. The brakes are not optional, they are the whole point." | [link](https://x.com/limalemonnn/status/2069039311584891122) | Real-world cost-runaway example: a loop with no stopping condition accumulated $47k in 11 days — illustrating that budget caps and stop conditions are mandatory infrastructure, not polish. |
| 2 | Addy Osmani | "Loop Engineering" | [link](https://addyosmani.com/blog/loop-engineering/) | Foundational Jun 7 article defining the 5 building blocks (automations, worktrees, skills, plugins, sub-agents) and noting that Codex and Claude Code now have identical loop engineering capabilities — the platform matters less than the design. |
| 2 | Addy Osmani | "Agent Harness Engineering" | [link](https://addyosmani.com/blog/agent-harness-engineering/) | Apr 19 article framing the scaffolding surrounding a coding agent — prompts, tools, context policies, sandboxes, feedback loops — as first-class artefacts requiring continuous refinement, not disposable wrappers. |
| 2 | @karpathy (repost of @trq212) | "A harness for every task: dynamic workflows in Claude Code" | [link](https://x.com/trq212/status/2061907337154367865) | Claude Code can now write its own task-specific harness on the fly before executing — the agent designs the workflow structure, not just the code. 3.1M views on @karpathy's repost. |
| 2 | Sakana AI | "Sakana Fugu: A Multi-Agent System as a Foundation Model" | [link](https://sakana.ai/fugu/) | Launched today: a trained-orchestrator model using TRINITY/Conductor architecture (Thinker/Worker/Verifier roles) that replaces hand-designed multi-agent loop code with learned orchestration — the harness as a training target, not a codebase. |
| 2 | Cobus Greyling | "Loop Engineering" (Medium) | [link](https://cobusgreyling.medium.com/loop-engineering-62926dd6991c) | Jun 9 article with 6-component breakdown (scheduling, worktrees, skills, connectors, sub-agents, memory) citing Cherny and Steinberger — a solid practitioner synthesis from a tracked source. |
| 2 | Cobus Greyling | "Fleet Engineering" | [link](https://cobusgreyling.substack.com/p/fleet-engineering) | New discipline: managing fleets of AI agents across enterprises via governance, observability, and routing — one layer above loop engineering. |
| 2 | @devops_prashant | "The model is the engine, the agent harness is the car—everyone's been debating horsepower while the real product was always the steering wheel" | [link](https://x.com/devops_prashant/status/2069034725738766545) | Quotable framing of why harness design matters more than model selection — the steering wheel (harness) determines where the car (loop) goes. |
| 2 | @shalabi | "If you hard-coded a single provider into your agent loop, it is an outage plus an emergency compliance review, at the same time. Model portability stopped being optional." | [link](https://x.com/shalabi/status/2069038743894597743) | Names provider lock-in as a new agent loop failure mode: hard-coding one model provider into the loop creates a single point of failure that combines technical and compliance risk. |
| 3 | @steipete | "This is becoming my favorite way to read Twitter" (birdclaw.sh) | [link](https://x.com/steipete/status/2068965200343224367) | Peter Steinberger shares birdclaw.sh, an OpenClaw-powered agent for consuming Twitter — itself a loop engineering application, and context for OpenClaw trending globally today. |
| 3 | Addy Osmani | "Agentic Code Review" | [link](https://addyosmani.com/blog/agentic-code-review/) | Jun 15 article: improved coding agents shift engineering focus toward trust assessment and review — adversarial evaluation becomes the highest-leverage skill in agentic development. |
| 3 | The New Stack | "Gemini CLI vs. Antigravity: What works, not the spec sheet" | [link](https://thenewstack.io/gemini-cli-antigravity-replacement/) | Google replaced open-source Gemini CLI with closed-source Antigravity CLI; key practical finding: Antigravity handles headless file and shell operations where Gemini CLI fails — headless capability is table stakes. |
| 3 | Simon Willison | "Claude Fable is relentlessly proactive" | [link](https://simonwillison.net/2026/Jun/11/fable-is-relentlessly-proactive/) | Fable 5 autonomously invented novel debugging techniques (browser automation, shadow DOM manipulation, custom web servers) — the model itself becoming more loop-like, blurring the line between agent and harness. |

### No new content
- Anthropic RSS — 404 (ongoing; feed URL appears down)
- @bcherny — last own post Jun 19 (no keyword match on loop engineering)
- @karpathy — last own post Jun 12 (SpaceX); Jun 2 repost captured above
- @AndrewYNg — no new posts since Jun 19 (pre-cutoff)
- OpenAI news — 403 blocked (ongoing)
- @swyx — posts today about AI Engineer conference logistics; no loop engineering content
- swyx.io — most recent post May 2026, no loop engineering content

### Docs updated this run
- `docs/17-failure-patterns.md` — added "Cost runaway" and "Provider lock-in" failure patterns
- `docs/22-learned-orchestration.md` — new doc: Sakana Fugu's trained-orchestrator approach (TRINITY/Conductor, Thinker/Worker/Verifier)
- `docs/23-fleet-engineering.md` — new doc: managing fleets of agents at enterprise scale (Cobus Greyling, LangSmith Fleet)
- `LOOP_ENGINEERING.md` — added rows 22 (learned-orchestration) and 23 (fleet-engineering)
- `SOURCES.md` — added @Sabrina_Ramonov X handle (active X presence confirmed today)

### Community signal
- X trending today: "AI Leaders Champion Loops Over One-Off Prompts" (2,151 posts, 9 hours ago)
- "OpenClaw" trending globally on X (context: Sakana Fugu vs OpenClaw discussion, birdclaw.sh launch)
- The X general search for "loop engineering" is live with dozens of posts per minute — the term has reached mainstream AI Twitter

### Sources to consider adding to SOURCES.md
- @limalemonnn — surfaced the $47k cost-runaway anecdote; active in loop engineering discussions
- @shalabi — named provider lock-in as an agent loop failure mode; substantive practitioner voice

---

## 2026-06-21 20:20 UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 2 | @RoundtableSpace / @AnatoliKopadze | "Claude Code team shows full app from scratch using a loop of three agents — 40 min, AI Engineer Europe" | [link](https://x.com/RoundtableSpace/status/2068789803945214042) | Live conference demo of a sequential 3-agent loop (plan → build → verify) that built a complete app in 40 minutes, the most concrete public example of the factory model in action. |
| 2 | @0xCodez | "Lead of Claude Code: 100% of our code at Anthropic is now shipped by Claude. Loops are as big a shift as source coding to agents." | [link](https://x.com/0xCodez/status/2068784463186932059) | Shares Boris Cherny's live conference quote and references the Jun 9 article "Loop engineering: the 14-step roadmap from prompter to loop designer" — a maturity model for the transition. |
| 2 | @batjko_labs | "Loop engineering is the right frame but the wrong unit. The job is not to design a loop that runs the agent. It is to…" | [link](https://x.com/batjko_labs/status/2068789878200922603) | Challenges the loop as the atomic unit of design, suggesting a higher-level abstraction is needed — an emerging counter-argument within the community. |
| 2 | @techtasium | "CONTEXT ENGINEERING > LOOP ENGINEERING" | [link](https://x.com/techtasium/status/2068784586222612560) | Provocative claim that context engineering (what you put into the loop) matters more than the loop structure itself — sparking a community debate about relative priority. |
| 3 | @shivangchheda22 | "The hard part isn't prompting, it's the stop condition. A useful loop needs trace logs, bounds…" | [link](https://x.com/shivangchheda22/status/2068789961223262458) | Citing @steipete: reinforces that stopping conditions, trace logs, and explicit bounds are the underrated hard parts of loop design — not the prompts themselves. |

### No new content
- Anthropic RSS — 404 (feed URL may have changed again)
- @bcherny — no keyword-matching posts since last run
- @karpathy — no keyword-matching posts since last run
- @AndrewYNg — no keyword-matching posts since last run
- @swyx — no keyword-matching posts since last run
- @steipete — no keyword-matching posts since last run (cited secondhand by @shivangchheda22)
- Addy Osmani — last post Jun 16
- Simon Willison — last post Jun 18
- The New Stack — no new articles since 18:33 UTC
- Cobus Greyling — last post Jun 18
- OpenAI news — 403 blocked
- swyx.io — no new posts since last run
- sabrina.dev — no new posts since last run

### Docs updated this run
- `docs/21-context-vs-loop-engineering.md` — new doc: emerging debate on whether context engineering supersedes loop engineering
- `docs/20-loop-maturity-model.md` — new doc: 14-step progression from prompter to loop designer
- `docs/17-failure-patterns.md` — added "Loop as wrong unit" entry

### Sources to consider adding to SOURCES.md
- @0xCodez — AI content creator; high-engagement loop engineering explainers (402+ views, 27 likes); published 14-step roadmap article Jun 9
- @AnatoliKopadze — conference reporter; captured Claude Code AI Engineer Europe live demo

---

## 2026-06-21 18:33 UTC (run)

### New findings

| Source | Title | URL | Summary |
|---|---|---|---|
| The New Stack | "A public Sentry key is all it takes to hijack Claude Code, Cursor, and Codex" | [link](https://thenewstack.io/agentjacking-sentry-mcp-attack/) | Security researchers documented "AgentJacking" — fake Sentry error reports that hijack MCP-connected AI coding agents and execute arbitrary code on developers' machines. |
| The New Stack | "Your agent wants to search like a 2010 quant" | [link](https://thenewstack.io/search-like-2010-quant/) | AI agents need sophisticated filtered search with ranking and metadata options, not just raw vector similarity, to retrieve relevant context reliably. |
| The New Stack | "An agent is an LLM and a harness": What Nvidia really thinks about OpenClaw | [link](https://thenewstack.io/nvidia-openclaw-agent-blueprints/) | Nvidia defines an agent as "an LLM and a harness" and is building enterprise agent blueprints via the OpenClaw framework to help companies safely adopt agentic AI. |
| @CKGrafico (X) | "Everyone is talking about loop engineering, but most examples keep an AI running just to discover if work exists" | [link](https://x.com/CKGrafico/status/2068760847699042601) | Highlights a token-waste anti-pattern: polling loops that burn tokens checking for work rather than using event-driven triggers. |
| @mosoahmed (X) | "Prompt Engineering Is Already Dead. Loop Engineering Took Its Job." | [link](https://x.com/mosoahmed/status/2068754362810396908) | Article arguing loop engineering has superseded prompt engineering as the primary skill for working with AI coding agents in 2026. |

### No new content
- Anthropic blog — RSS unavailable (404); news page last updated Jun 17
- @bcherny — last post Jun 19 (pre-cutoff)
- @karpathy — last post Jun 12 (pre-cutoff)
- @AndrewYNg — last post Jun 19 (pre-cutoff)
- OpenAI blog — RSS blocked (403)
- Addy Osmani — last post Jun 16 (pre-cutoff)
- Simon Willison — last post Jun 18 (pre-cutoff; Datasette Apps, no keyword match)
- @swyx — Jun 21 posts about sports/AI World's Fair, no keyword match
- swyx.io blog — page returned 404

### Docs updated this run
- `docs/19-mcp-security.md` — new doc: AgentJacking via Sentry MCP, indirect prompt injection, mitigations
- `docs/17-failure-patterns.md` — added "Polling loop" anti-pattern

### Sources to consider adding to SOURCES.md
Web search for "loop engineering" surfaced active blogs not yet in SOURCES.md:
- sabrina.dev — wrote "AI Loop Engineering: Build Autonomous Agents with Claude Code /goal + Routines" (Jun 19)
- explainx.ai — published a 2026 loop engineering guide (recent)
- datasciencedojo.com — "Agentic Loops: From ReAct to Loop Engineering (2026 Guide)"
- the-ai-corner.com — "Loop Engineering: Build Self-Running Coding Agents 2026"

---

## 2026-06-21 08:07 UTC (initialized)

_No entries yet — first automated run pending._

---
