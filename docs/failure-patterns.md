# Common Failure Patterns

| Pattern | Symptom | Fix |
|---|---|---|
| Kitchen-sink session | Unrelated tasks mixed, context polluted | `/clear` between tasks |
| Correction loop | Same mistake corrected 2+ times | `/clear` + rewrite the prompt with what you learned |
| Over-specified CLAUDE.md | Claude ignores some rules | Prune ruthlessly — if Claude does it right without the rule, delete it |
| Trust-then-verify gap | Plausible implementation with hidden edge cases | Always give Claude a runnable check |
| Infinite exploration | Claude reads hundreds of files, context full | Scope investigations narrowly or use subagents |
| No stopping condition | Loop runs forever or halts randomly | Define a verifiable success criterion before starting |
| Uncapped headless run | Expensive, hard to debug after the fact | Set `--max-turns` and `--max-budget-usd` |
| Reviewer bias | Claude reviews code it wrote, misses issues | Always use a subagent for final review |
| Polling loop | Cron fires every N minutes just to check if work exists, burning tokens on empty runs | Use event-driven triggers (webhook, file watcher, CI event) so the loop only fires when there is actually something to do |
