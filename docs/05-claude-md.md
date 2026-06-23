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

## Load hierarchy

CLAUDE.md files are loaded in this order (broadest → most specific, each can override):

1. Managed policy (`/Library/Application Support/ClaudeCode/CLAUDE.md`)
2. User (`~/.claude/CLAUDE.md`)
3. Project root (`./CLAUDE.md` or `./.claude/CLAUDE.md`)
4. Local override (`./CLAUDE.local.md`, gitignored — personal preferences)
5. Subdirectory files — loaded **lazily** when Claude reads files in that directory
6. Path-scoped rules (`.claude/rules/*.md`) — loaded when matching files are touched

## Path-scoped rules (`.claude/rules/`)

Rules that only apply to specific file patterns — reduce context noise for
large projects where different subsystems have different conventions:

```markdown
<!-- .claude/rules/api-rules.md -->
---
paths:
  - "src/api/**/*.ts"
  - "src/routes/**/*.ts"
---
# API Development Rules
- All endpoints must validate input with zod
- Return 400 with structured error body on validation failure
- Never expose stack traces in API responses
```

These rules are only injected into context when Claude is working with files
matching the `paths` patterns — they don't consume context tokens on unrelated tasks.

## Import syntax

Pull in other files without duplicating content:

```markdown
# CLAUDE.md
See @README.md for project overview.
Git workflow: @docs/git-instructions.md
Available scripts: @package.json
```

Maximum 4 import hops. Circular imports are ignored.

## HTML comment stripping

HTML comments in CLAUDE.md are stripped before injection — use them for
maintainer notes that should not consume context tokens:

```markdown
<!-- Last reviewed: 2026-06 — remove the pnpm rule when Node 24 ships -->
- Use pnpm (not npm)
```

## Project-wide exclusion (`claudeMdExcludes`)

In monorepos, exclude specific CLAUDE.md files from loading:

```json
// .claude/settings.json
{
  "claudeMdExcludes": ["packages/legacy/**"]
}
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
