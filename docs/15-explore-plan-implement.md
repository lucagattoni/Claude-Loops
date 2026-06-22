# The Explore → Plan → Implement → Commit Workflow

For complex, multi-file tasks, always separate phases:

```bash
# Phase 1: Explore (plan mode — no edits)
# Press Ctrl+R to enter plan mode, or:
claude --permission-mode plan
> "Read src/auth and understand how sessions work. 
   Also look at how we handle environment secrets."

# Phase 2: Plan
> "I want to add Google OAuth. What files change? 
   What's the session flow? Write a detailed plan."
# Press Ctrl+G to open plan in editor before Claude proceeds

# Phase 3: Implement (exit plan mode)
> "Implement the OAuth flow from the plan. Write tests 
   for the callback handler. Run tests and fix failures."

# Phase 4: Commit
> "Commit with a descriptive message and open a PR"
```

**Skip planning for small, clear tasks.** Planning adds overhead. If you can describe
the diff in one sentence, go directly to implementation.
