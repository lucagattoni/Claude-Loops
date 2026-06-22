# Loop Engineering News

Append-only daily digest. Updated by the `fetch-loop-news` skill each day at 08:00 UTC.
Sources are defined in [`SOURCES.md`](SOURCES.md).

---

## 2026-06-21 09:07 IST (initialized)

_No entries yet — first automated run pending._

---

## 2026-06-21 19:33 IST (run)

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
- `docs/mcp-security.md` — new doc: AgentJacking via Sentry MCP, indirect prompt injection, mitigations
- `docs/failure-patterns.md` — added "Polling loop" anti-pattern

### Sources to consider adding to SOURCES.md
Web search for "loop engineering" surfaced active blogs not yet in SOURCES.md:
- sabrina.dev — wrote "AI Loop Engineering: Build Autonomous Agents with Claude Code /goal + Routines" (Jun 19)
- explainx.ai — published a 2026 loop engineering guide (recent)
- datasciencedojo.com — "Agentic Loops: From ReAct to Loop Engineering (2026 Guide)"
- the-ai-corner.com — "Loop Engineering: Build Self-Running Coding Agents 2026"

---

## 2026-06-21 21:20 IST (run)

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
- The New Stack — no new articles since 19:33 IST
- Cobus Greyling — last post Jun 18
- OpenAI news — 403 blocked
- swyx.io — no new posts since last run
- sabrina.dev — no new posts since last run

### Docs updated this run
- `docs/context-vs-loop-engineering.md` — new doc: emerging debate on whether context engineering supersedes loop engineering
- `docs/loop-maturity-model.md` — new doc: 14-step progression from prompter to loop designer
- `docs/failure-patterns.md` — added "Loop as wrong unit" entry

### Sources to consider adding to SOURCES.md
- @0xCodez — AI content creator; high-engagement loop engineering explainers (402+ views, 27 likes); published 14-step roadmap article Jun 9
- @AnatoliKopadze — conference reporter; captured Claude Code AI Engineer Europe live demo

---
