# Loop Engineering News Sources

The `fetch-loop-news` skill reads this file on every run. Add, remove, or edit rows
here to change what gets tracked — no changes to the skill needed.

## Relevance keywords

Search each source for posts or articles matching **at least one** of:

`loop engineering` · `agentic` · `Claude Code` · `subagent` · `MCP` · `headless` ·
`worktree` · `verification loop` · `AI agent` · `computer use` · `agent loop` ·
`multi-agent` · `tool use` · `agent harness` · `autonomous agent`

## Sources

| Actor | Type | Handle / URL | Notes |
|---|---|---|---|
| Anthropic | rss | https://www.anthropic.com/rss.xml | Primary source for Claude Code updates |
| Boris Cherny | x | @bcherny | Creator of Claude Code |
| Andrej Karpathy | x | @karpathy | Influential ML researcher |
| Andrew Ng | x | @AndrewYNg | Agentic AI education |
| OpenAI | html | https://openai.com/news | RSS blocked (403); scrape news index |
| Addy Osmani | rss | https://addyosmani.com/rss.xml | Co-defined loop engineering |
| Simon Willison | rss | https://simonwillison.net/atom/entries/ | LLM tooling practitioner |
| Swyx | x | @swyx | AI engineering community |
| swyx.io | html | https://www.swyx.io/writing | AI engineering long-form posts |
| The New Stack | rss | https://thenewstack.io/feed/ | Active loop engineering coverage |
| Sabrina Ramonov | html | https://www.sabrina.dev | Wrote loop engineering + /goal + Routines guide (Jun 19 2026) |
| Cobus Greyling | rss | https://cobusgreyling.substack.com/feed | Loop Engineering Substack post |

## Type reference

| Type | Fetch strategy |
|---|---|
| `x` | Chrome browser → search `from:<handle> <keywords>` in X.com search; also scan profile's recent posts |
| `rss` | WebFetch the feed URL → parse `<item>` / `<entry>` elements → score against keywords |
| `html` | WebFetch page URL → extract article links, titles, and snippets → score against keywords |

## Adding new sources

If a general search surfaces a person or company that consistently publishes
high-quality content on the topic, add a row here. Criteria:
- Writes specifically about loop engineering, agentic AI, Claude Code, or MCP
- Has published at least 2 relevant pieces
- Has a meaningful audience (engagement, not just follower count)
