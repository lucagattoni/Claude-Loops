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
| Loop as wrong unit | Designing individual loops in isolation when the real system needs multiple loops coordinated at a higher level | Identify the system of loops first (what monitors what, who hands off to whom) before designing each loop's internals |
| Cost runaway | A loop without a hard spend cap runs for days and accumulates thousands of dollars in API costs before anyone notices ($47k in 11 days is a real example) | Always set `--max-budget-usd` before scheduling a headless loop; treat missing budget cap as a deployment blocker |
| Provider lock-in | Hard-coding a single model provider into the loop means one outage or policy change triggers both an emergency and a compliance review simultaneously | Design agent loops with model-agnostic interfaces from the start; use provider abstraction (OpenAI-compatible endpoints) so you can swap the model without rewriting the loop |
| Cognitive surrender | Accepting AI output without retaining your own judgment — delegating not just execution but evaluation | Treat every AI output as a first draft; apply engineering judgment before merging; distinguish offloading (delegate with retained oversight) from surrender (accept unchecked) |
| Orchestration tax | Human attention becomes the bottleneck in multi-agent loops — managing feedback from parallel agents consumes more cognitive load than the original task would have | Apply backpressure: limit parallel agents, batch their outputs, review asynchronously; the orchestration tax grows faster than the parallelism benefit |
| Intent debt | Undocumented design decisions become the most expensive technical debt in agentic workflows — agents cannot fabricate authentic rationale and silently fill gaps with plausible-sounding explanations | Document every design decision before launching the loop (use `CLAUDE.md` or a `DECISIONS.md`); treat undocumented intent as a defect, not a style choice |
