# CLAUDE.md — Your Persistent Context Layer

`CLAUDE.md` is loaded at the start of every session. It is **re-injected on every
request**, so rules survive context compaction.

## The rule: short and surgical

Keep it ruthlessly concise. If Claude already does something correctly without the
rule, delete the rule. Bloated `CLAUDE.md` files cause Claude to ignore instructions.

```markdown
# Code style
- ES modules (import/export), not CommonJS
- Destructure imports when possible

# Workflow
- Typecheck after every series of edits: npx tsc --noEmit
- Run single tests, not the full suite: npx jest <file>

# Commit conventions
- Conventional commits: feat:, fix:, chore:, docs:
- Never commit directly to main

# Environment
- Node 22+, pnpm (not npm)
- .env.local for secrets (never commit)
```

## What belongs where

| Content | Put it in |
|---|---|
| Rules that apply to every session | `CLAUDE.md` |
| Project overview and commands | `CLAUDE.md` (brief) or linked via `@README.md` |
| Domain-specific workflows | A Skill |
| Personal overrides | `CLAUDE.local.md` (gitignored) |
| Team-wide rules | `CLAUDE.md` (committed) |
| Rules for a subdirectory | `subdir/CLAUDE.md` (auto-loaded when Claude reads files there) |

## Import syntax

```markdown
# CLAUDE.md
See @README.md for project overview and @package.json for available scripts.

- Git workflow: @docs/git-instructions.md
```

## Customizing compaction

Tell the compactor what to preserve when context is summarized:

```markdown
# Summary instructions
When compacting this conversation, always preserve:
- The current task objective and acceptance criteria
- File paths modified during this session
- Test results and error messages
- Decisions made and their reasoning
```
