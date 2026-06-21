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
