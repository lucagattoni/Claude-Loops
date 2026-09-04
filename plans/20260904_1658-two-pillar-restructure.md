# Two-Part Restructure — Loop Engineering (general) + Developing with Claude Code

**Written** 20260904 16:58 UTC · **revised** 20260904 18:12 UTC
**Branch** `20260904_1658-two-pillar-restructure` · base `43e86f6`
**Target release** `v3.0.0` (MAJOR — index restructured, docs reassigned)

---

## 1. Why

Three independent sources converge on a claim the KB does not currently make:
**for software development specifically, the dominant productive mode is human-guided
iteration, not autonomous long-horizon loops.**

| Source | Tier | What it says |
|---|---|---|
| Andrew Ng, ["…Using Coding Agents"](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map-in-detail-using-coding-agents/), 2026-09-04 | practitioner | Effective coding-agent use is *"a complex, highly iterative process"*; utility comes from human intervention with *"high-skill judgement"*, not autonomous long-horizon tasks |
| Anthropic, ["When to use multi-agent systems"](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them), 2026-01-23 | official | Role-split agents (*"planning, execution, review"*) is a named anti-pattern; the *"telephone game"*; multi-agent uses *"3-10x more tokens"* |
| Anthropic, ["multi-agent research system"](https://www.anthropic.com/engineering/multi-agent-research-system) | official | *"Most coding tasks involve fewer truly parallelizable tasks than research"* |
| Tran & Kiela, arXiv (sweep finding #32) | academic | Single-agent matches or exceeds multi-agent on multi-hop reasoning **under equal thinking-token budgets** — unaccounted compute is the usual explanation for reported multi-agent wins |

The KB's front page reads *"Stop writing prompts. Start designing loops"* and *"autonomously,
while you sleep."* That is **correct for a class of work** and **wrong as a universal default for
building software**. 34 docs cover the autonomous mode; nothing routes a reader between the two.

Nothing is deleted. The fix is to **separate the two subjects, give the second one a spine, and
put a router in front of both.**

---

## 2. The structure

**Decision (user, 20260904): full reassignment. Every doc lands in exactly one part.
Part I must remain GENERAL — a reader on another tool can use it.**

Editorial rule for Part I: general in *framing*. Claude Code may appear as an **example**, never as
a **prerequisite**. This is not a mandate to purge every Claude mention from 48KB of harness
patterns — that would destroy value for no gain.

### Part I — Loop Engineering (general, tool-agnostic)

| § | Docs |
|---|---|
| 1. Foundations | `01` Paradigm Shift · `02` Core Agent Loop Cycle · `20` Loop Maturity Model · `21` Context vs Loop Engineering · `26` Factory Model |
| 2. Designing a Loop | `27` Loop Contract · `30` Goal Engineering · `24` Harness Patterns · `34` Loop Patterns Catalog |
| 3. Verification & Failure | `04` Verification · `17` Failure Patterns · `14` Human-in-the-Loop |
| 4. Scaling | `10` Fan-Out · `23` Fleet Engineering · `22` Learned Orchestration · `25` Long-Running Agents |

### Part II — Developing with Claude Code

| § | Docs |
|---|---|
| 5. Start Here | `35` **Choosing Your Mode** *(new)* |
| 6. The Workflow | `36` **Development Workflow** *(new)* · `37` **Session Architecture** *(new)* · `15` Explore→Plan→Implement→Commit |
| 7. Your Setup | `05` CLAUDE.md · `06` Skills · `12` Hooks · `08` Permissions & Auto Mode · `03` Building Blocks · `16` Memory Patterns · `13` Context Management |
| 8. Parallel Work | `07` Subagents · `38` **Agent Teams** *(new)* · `39` **Dynamic Workflows** *(new)* |
| 9. Running Unattended | `09` Headless · `28` Routines · `29` Background Agents · `31` Claude Tag |
| 10. Cost & Safety | `11` Cost & Turn Control · `19` MCP Security · `33` Agent Security Hardening |

Neutral scaffolding: **11. Reference** (`18`, `32`) · **12. Project** (news, sources, changelog).

Row numbers stay stable per `CLAUDE.md` — files are re-grouped, never renumbered.
Touches `LOOP_ENGINEERING.md`, `mkdocs.yml` (nav + `site_name` → **Claude Loops**), `README.md`, `docs/index.md`.

### The five new docs

| File | Content |
|---|---|
| `35-choosing-your-mode` | **The router.** Task properties → mode. When a loop pays for itself vs. when it is overhead. The compound-probability argument re-scoped: it argues for a *correction* loop, not necessarily an *unattended* one. Cost per unit of work (Ng, post-tokenmaxxing). |
| `36-development-workflow` | **Part II spine.** Ng's three phases (Plan → Execute → Deploy/Monitor) × five skills (directing the workflow · enabling agent autonomy · reviewing the work · customizing the agent and environment · coding agent foundations), each mapped to the Claude Code primitive that implements it. |
| `37-session-architecture` | **The multi-session question.** Context-centric vs role-centric decomposition. The three situations that justify multiple agents, and the one that does not. Anthropic's own four-way decision matrix. **Named Pinakes case study** (§ 4). |
| `38-agent-teams` | Shipped primitive with **zero KB coverage**. `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`; lead + teammates; shared task list with file-locked claiming; mailboxes; `TeammateIdle`/`TaskCreated`/`TaskCompleted` hooks; limits (no session resumption, one team per session, no nesting). Official "when NOT to use". |
| `39-dynamic-workflows` | The concrete Workflow tool, vs. the abstract blog concept already in `24`. `agent()`/`pipeline()`/`parallel()`/`phase()`; `.claude/workflows/*.js`; `ultracode`; limits (16 concurrent, 4,096 per call, 1,000 per run); resume semantics. |

---

## 3. KB errors found — fix these regardless of the restructure

A wrong fact in a reference table is what readers copy. These outrank new content.

| # | File | KB says | Truth | Status |
|---|---|---|---|---|
| 1 | `docs/07-subagents.md` ~L158 | `Explore \| Haiku` | *"Inherits from main conversation, capped at Opus on Claude API (v2.1.198+)"* | Confirmed by round 1 |
| 2 | `docs/07-subagents.md` | nested subagents capped at depth **5** | Nesting disabled 2026-07-21 (v2.1.217), reinstated at depth **3** 2026-07-24 (v2.1.219) | Round 2 verifying |
| 3 | `docs/08-permissions.md` | auto mode framed as opt-in for unattended runs | *"On Pro, Max, and Team plans, the built-in starting permission mode is auto mode"* | Confirmed by round 1 |
| 4 | `docs/07` / global rule | `CLAUDE_CODE_SUBAGENT_MODEL` as override | Precedence reordered in v2.1.251 (explicit `model:` wins); `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` added v2.1.257 | Confirmed by round 1 |

A round-2 `factcheck` agent is sweeping the KB's remaining version-specific claims.

---

## 4. The Pinakes case study — publication rules

Decision 20260904: **named case study, absolute dollar figures dropped.** The repo is PUBLIC.

| Publish | Do not publish |
|---|---|
| Project name "Pinakes"; the architecture question and its verdict | `$3.38k` / `$699.99` / `$1.72k` absolute spend |
| Ratios: 36.8% of delegated spend on review; ~95.8% file re-derivation across passes; median fragment lifetime 2.1 h | Anything resembling PII, credentials, private endpoints |
| Named failure modes: value-biased fan-out truncation; `.filter(Boolean)` erasing dead agents; VACUOUS/PARTIAL/CLEAN coverage reporting | |
| The refuted-claims table — publishing what did **not** survive checking is the most valuable part | |

**Blocking gate:** re-read the drafted section against this table before commit.

---

## 5. Evidence base

**Round 1** (`wf_ff75ed78-134`): 9 sweep angles + 2 critics, 11/11 agents, 0 errors, coverage
`FINDINGS`. 86 findings, 80 verified, 67 pass the ≥3.0 gate. 41 `claude-code-dev` / 22
`loop-engineering` / 23 both. 1.18M tokens, 12m15s.

**Round 1 critics found real holes**, which is why there is a round 2:

| Gap | Severity |
|---|---|
| 2026-07-01→07-14 essentially uncovered by all 9 agents | high |
| Willison, "Breaking Claude Code Opus 5 Auto Mode" (2026-08-27) missed; the angle reported `NONE` | high |
| X/Twitter never swept; Boris Cherny never checked as a primary source | high |
| Sonnet 5 / Opus 5 announcement pages never fetched | high |
| HN never searched; a Bun line-count discrepancy (750K vs the KB's 535,496) unresolved | medium |
| LinkedIn MCP tool available but never invoked | low |

**Do not integrate** (critic-flagged): the Sonnet5/Opus5 finding citing `anthropic.com/news/claude-opus-4-6`
(URL matches no model); finding #79 "SYNTHESIS" (no URL, agent editorialising); MindStudio
"Dreaming"/"Outcomes" without a primary source — hedge as *"reported by"* or drop.
**Collapse** the ~16-20 changelog findings (v2.1.235–v2.1.260) into **one** digest entry with per-doc
line items; they are one news event sliced many ways.

**Round 2** (`wf_d9d27518-8b0`): 8 gap agents + 1 KB fact-checker. Running.

---

## 6. Order of work

| # | Step | Gate |
|---|---|---|
| 1 | Round 2 completes; merge findings; drop the flagged-suspect items | Coverage `CLEAN`, not `PARTIAL` |
| 2 | **Fix the KB errors in § 3** — smallest diff, highest value, ships even if nothing else does | Each fix quotes the official page it came from |
| 3 | Write `35`, `36`, `37`, `38`, `39` | Every external reference is a markdown hyperlink (citation rule) |
| 4 | Pinakes section re-read against § 4 | **Blocking.** Public repo. |
| 5 | Restructure index + `mkdocs.yml` + `README.md` + `docs/index.md` | `mkdocs build --strict` passes |
| 6 | Revise existing docs against round-1/2 findings | Links resolve |
| 7 | Catch-up digest → `LOOP_ENGINEERING_NEWS.md`; update `SOURCES.md` (add The Batch; prune dead rows) | Digest states what was swept AND what was not |
| 8 | `CHANGELOG.md` → `[3.0.0]`; commit; PR; adversarial review; merge | |
| 9 | Tag `v3.0.0`, push tags, `gh release create --latest` | |
| 10 | Re-arm launchd; validate against a real run | Not before step 8 lands |

**Standing gates:** `mkdocs build --strict` (CI runs it) and
`grep -rn 'repo: github\.com' docs/ | grep -v '\[github'`.

---

## 7. Tracker re-arm

**Root cause of the 2026-07-20 outage, established this session:** the run log shows
`ANTHROPIC_API_KEY or another auth source is set and takes precedence over your claude.ai login`,
then `Credit balance is too low`. A pay-as-you-go key with no credit was shadowing the subscription.

**That key is gone** — verified: absent from every shell profile, no `scripts/run-loop-news.env`,
unset in the current environment. A re-arm should run on the claude.ai login.

Sequenced **last** so a 05:00 scheduled run cannot race this branch:
`cp scripts/com.luca.loop-news.plist ~/Library/LaunchAgents/` →
`launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.luca.loop-news.plist` →
`launchctl print gui/$(id -u)/com.luca.loop-news`.
**Then validate against an actual run** — a schedule firing is not evidence the pipeline worked.

---

## 8. What would change this plan

| Observable | Revised approach |
|---|---|
| Round 2 shows agent teams left experimental with reliable handoff | `37`'s anti-pattern becomes version-scoped; `38` leads with "this changed" |
| Round 2 refutes the depth-3 claim | Drop error #2; keep the KB text and record the check |
| Round 2 returns `PARTIAL` | Do not publish a digest claiming eight weeks of coverage — state what was swept and what was not |
| Ng's fourth letter ("Shaping the Build", ~2026-09-11) lands before this ships | Hold `36` open, or ship and add it as a PATCH |
