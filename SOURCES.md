# Loop Engineering News Sources

The `fetch-loop-news` skill reads this file on every run. Add, remove, or edit rows
here to change what gets tracked — no changes to the skill needed.

## Relevance keywords

A post is scored as relevant if its title or snippet matches **at least one** of:

`loop engineering` · `agentic` · `Claude Code` · `subagent` · `MCP` · `headless` ·
`worktree` · `verification loop` · `AI agent` · `computer use` · `agent loop` ·
`multi-agent` · `tool use`

## Sources

| Actor | Type | Handle / URL | Why |
|---|---|---|---|
| Anthropic | rss | https://www.anthropic.com/blog | Claude Code and loop engineering originator |
| Boris Cherny | x | @bcherny | Creator of Claude Code |
| Andrej Karpathy | x | @karpathy | Influential ML researcher |
| Andrew Ng | x | @AndrewYNg | Agentic AI education |
| OpenAI | rss | https://openai.com/blog | Competitor loop patterns and agents |
| Addy Osmani | rss | https://addyosmani.com/blog | Co-defined loop engineering |
| Simon Willison | rss | https://simonwillison.net | LLM tooling practitioner |
| Swyx | x | @swyx | AI engineering community |
| swyx.io | html | https://www.swyx.io/blog | AI engineering long-form posts |
| The New Stack | rss | https://thenewstack.io | Published the Boris Cherny loop-engineering piece |

## Type reference

| Type | Fetch strategy |
|---|---|
| `x` | Chrome browser → navigate `x.com/<handle>` → extract posts from last 24h |
| `rss` | WebFetch common RSS paths (`/feed`, `/rss.xml`, `/atom.xml`) → parse `<item>` entries |
| `html` | WebFetch blog index URL → extract link titles and text snippets |
