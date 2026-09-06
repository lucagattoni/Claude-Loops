# The Explore → Plan → Implement → Commit Workflow

For complex, multi-file tasks, always separate phases:

```bash
# Phase 1: Explore (plan mode — no edits)
# Press Shift+Tab to cycle permission modes into plan mode, or:
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

---

## What plan mode actually does

Plan mode is not just "ask before every edit" — it changes what runs at all. Reads and codebase
exploration proceed; edits stay blocked until you approve a plan:

> "Plan mode tells Claude to research and propose changes without making them. Claude reads files,
> runs shell commands to explore, and writes a plan, but does not edit your source. Except in
> sessions with bypass permissions available, edits stay blocked until you approve the plan."
>
> — Anthropic, [Choose a permission mode](https://code.claude.com/docs/en/permission-modes#analyze-before-you-edit-with-plan-mode)

What runs without asking in this mode: *"Reads, plus classifier-approved commands when auto mode
is available"* — same source. Everything else prompts.

## Entering and leaving

Per Anthropic's [permission-modes reference](https://code.claude.com/docs/en/permission-modes#switch-permission-modes):

| Action | How |
|---|---|
| Enter from a running session | `Shift+Tab` to cycle (`default → acceptEdits → plan → default`), or prefix one prompt with `/plan` |
| Start a session already in plan mode | `claude --permission-mode plan` |
| Edit the proposed plan before Claude proceeds | `Ctrl+G` opens it in your default text editor |
| Leave without approving | `Shift+Tab` again |
| Approve | Exits plan mode and switches to the mode the approve option names, so Claude starts editing |

## Who does the exploring

Two built-in subagent types exist specifically for this phase, both read-only:

| Type | Use when |
|---|---|
| `Explore` | Fast codebase search; skips CLAUDE.md and git status for speed |
| `Plan` | Architecture planning in plan mode |

See [Subagents](07-subagents.md#built-in-subagent-types) for the full table and its footnote on
why "Explore is cheap because it's Haiku" stopped being true by default in v2.1.198.

## When planning is waste

The short version is above: skip planning for small, clear tasks.
[The Development Workflow](36-development-workflow.md#the-spec-scales-with-the-risk-not-with-the-task)
has the fuller argument — match the ceremony to the blast radius, not to the task.

## Related

- [Permissions & Auto Mode](08-permissions.md) — the full permission-mode reference
- [Subagents](07-subagents.md) — `Explore` and `Plan`, and every other built-in type
- [The Development Workflow](36-development-workflow.md) — where this phase sits in the wider cycle
- [Choosing Your Mode](35-choosing-your-mode.md) — plan mode among the other supervised-autonomy primitives
