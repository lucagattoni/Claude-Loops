# Hooks — Deterministic Side Effects

Hooks are shell scripts (or SDK callbacks) that fire at specific points in the loop.
Unlike `CLAUDE.md` instructions (advisory), hooks are **deterministic guarantees**.

```json
// .claude/settings.json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [{ "type": "command", "command": "npx eslint $CLAUDE_TOOL_INPUT_PATH --fix" }]
      }
    ],
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": "npm test" }]
      }
    ]
  }
}
```

## Key hook events

| Hook | When it fires | Common uses |
|---|---|---|
| `PreToolUse` | Before a tool executes | Validate inputs, block dangerous commands |
| `PostToolUse` | After a tool returns | Auto-lint, auto-format, audit outputs |
| `Stop` | When the agent finishes | Run tests as a final gate; block turn if they fail |
| `PreCompact` | Before context compaction | Archive full transcript |
| `SubagentStop` | When a subagent completes | Aggregate parallel results |

A Stop hook that returns a non-zero exit code blocks the turn from ending. Claude
re-reads the hook output and tries again. After 8 consecutive blocks, Claude Code
overrides and ends the turn — preventing infinite loops.
