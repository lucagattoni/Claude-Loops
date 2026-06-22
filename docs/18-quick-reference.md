# Quick Reference

```bash
# Non-interactive with safety limits
claude -p "prompt" --permission-mode auto --max-turns 20

# Fan-out across files
for f in $(cat files.txt); do
  claude -p "process $f" --permission-mode auto --allowedTools "Read,Edit" &
done; wait

# Structured output
claude -p "prompt" --output-format json | jq '.result'

# Resume a session
claude --continue           # most recent
claude --resume             # pick from list

# Plan mode (explore without editing)
# Ctrl+R in interactive, or --permission-mode plan

# Clear context
/clear

# Compact with instructions
/compact Preserve: task objective, modified files, open questions

# Set a goal (loop until verified)
/goal all tests pass and build succeeds

# Run a skill
/fix-issue 1234
/deploy staging
```
