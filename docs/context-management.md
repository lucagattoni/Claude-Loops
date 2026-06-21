# Context Management

The context window is your most important resource. Performance degrades as it fills.

## Rules

- `/clear` between unrelated tasks — start each task with clean context
- `/compact` to summarize before starting a large new section
- Use subagents for investigation — their reads don't consume your context
- Never ask Claude to "explore the whole codebase" — scope narrowly
- After two failed corrections, `/clear` and write a better prompt

## Compaction shortcuts

```
/compact Focus on the API changes only
/compact Preserve: task objective, modified files, test results
```

## What eats context fastest

- Large file reads (every file read accumulates)
- Verbose bash output (`--verbose` on for dev, off for production loops)
- Long CLAUDE.md files
- Many MCP tool schemas (use MCP tool search to defer loading)
