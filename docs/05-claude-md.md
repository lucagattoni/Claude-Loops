# CLAUDE.md — Your Persistent Context Layer

`CLAUDE.md` is loaded into context at the start of every session. It survives context compaction because Claude Code re-reads project-root `CLAUDE.md` and unscoped rules from disk and re-injects them specifically when `/compact` runs (or when automatic compaction triggers) — not on every request. Nested `CLAUDE.md` files load into context again the next time Claude reads a file in that subdirectory, and rules carrying `paths:` frontmatter reload the next time Claude reads a matching file.

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

## Rules Have a Half-Life

"Short and surgical" above is a snapshot discipline — apply it once and the file drifts
stale again as the model improves. A rule written to compensate for a model weakness has a
**half-life**: as models improve, more of `CLAUDE.md` stops being necessary guidance and
starts being unread dead weight (or worse, a rule the model now contradicts because the
underlying behavior changed). Treat a periodic audit — not just a one-time trim — as part
of maintaining the file, the same way [When to Remove Harness](24-harness-patterns.md#when-to-remove-harness)
treats harness components as a depreciating asset with every model release, not a
permanent fixture. ([Addy Osmani, "Audit your Agent files"](https://addyo.substack.com/p/audit-your-agent-files), Aug 2026.)

## What belongs where

| Content | Put it in |
|---|---|
| Rules that apply to every session | `CLAUDE.md` |
| Project overview and commands | `CLAUDE.md` (brief) or linked via `@README.md` |
| Domain-specific workflows | A Skill |
| Personal overrides | `CLAUDE.local.md` (gitignored) |
| Team-wide rules | `CLAUDE.md` (committed) |
| Rules for a subdirectory | `subdir/CLAUDE.md` (auto-loaded when Claude reads files there) |

## Load hierarchy

CLAUDE.md files and rules are loaded in this order (broadest → most specific, each can override):

1. Managed policy (`/Library/Application Support/ClaudeCode/CLAUDE.md` on macOS; `/etc/claude-code/CLAUDE.md` on Linux/WSL; `C:\Program Files\ClaudeCode\CLAUDE.md` on Windows)
2. User (`~/.claude/CLAUDE.md`), then user-level rules (`~/.claude/rules/*.md`)
3. Project root (`./CLAUDE.md` or `./.claude/CLAUDE.md`), plus project rules with no `paths:` frontmatter (`.claude/rules/*.md` — same priority as project CLAUDE.md)
4. Local override (`./CLAUDE.local.md`, gitignored — personal preferences)
5. Subdirectory files — loaded **lazily** when Claude reads files in that directory
6. Path-scoped rules — `.claude/rules/*.md` files that DO carry `paths:` frontmatter, loaded only when Claude reads a matching file

## AGENTS.md fallback (v2.1.277+)

In a project with no `CLAUDE.md`, Claude Code reads `AGENTS.md` instead — the same emerging
cross-tool convention other coding agents (Codex, others) already read. Configurable under
"Project instructions" in `/config`; not yet available on Bedrock, Vertex, or Foundry. This does
not change the load hierarchy above when a `CLAUDE.md` is present — `AGENTS.md` is a fallback, not
an additional layer. ([Claude Code
changelog](https://code.claude.com/docs/en/changelog), v2.1.277, Sep 2026.)

**Gated behind a remote flag, silently.** A 2026-09-23 measurement found the loader ships as a
built-in plugin whose availability asks a remote feature flag, `tengu_agents_md_mod` — both the
plugin's own default and the fallback used when the flag can't be fetched are `false`, read
directly from the Claude Code v2.1.280 bundle. With either `DISABLE_TELEMETRY=1` or
`CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` set, the flag is never fetched, so `AGENTS.md` is
skipped — and nothing warns that it happened. The workaround, since `@path` imports don't depend
on the flag:

```bash
echo '@AGENTS.md' > CLAUDE.md
```

A session-level override also works, but only from the second session in that configuration on
(the first session only fetches the flag): `claude --settings
'{"env":{"DISABLE_TELEMETRY":"","CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC":""}}'`. Tracked as
[issue #95690](https://github.com/anthropics/claude-code/issues/95690), labelled `enhancement` by
github-actions[bot] 72 seconds after filing (an automatic label, not a maintainer's triage), with
no fix version confirmed and the issue open as of 2026-09-28.
Przemysław Szypowicz measured this (blog.szypowi.cz; the same measurements are also posted as [a
comment on the GitHub
issue](https://github.com/anthropics/claude-code/issues/95690#issuecomment-5791716755) — one
author's measurement, not a second independent source). The issue thread does add one: another
user reported "Confirmed on 2.1.278 with fresh isolated homes"
([mmailhos](https://github.com/anthropics/claude-code/issues/95690#issuecomment-5795184619),
Sep 2026). Peter Steinberger flagged it on X
and later relayed secondhand: "Was a bug, they followed up. Dev mistake, not malice." — his
account of Anthropic's response, not an Anthropic statement, and not his own measurement.
([blog.szypowi.cz, "Claude Code reads AGENTS.md only when telemetry is on"](https://blog.szypowi.cz/p/claude-code-reads-agents.md-only-when-telemetry-is-on/), Sep 2026;
[anthropics/claude-code#95690](https://github.com/anthropics/claude-code/issues/95690), Sep 2026;
[@steipete](https://x.com/steipete/status/2102889319849713698), Sep 2026;
[@steipete follow-up](https://x.com/steipete/status/2102989175649956199), Sep 2026.)

## Path-scoped rules (`.claude/rules/`, v2.0.64+)

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

## Import syntax (available since v0.2.107)

Pull in other files without duplicating content:

```markdown
# CLAUDE.md
See @README.md for project overview.
Git workflow: @docs/git-instructions.md
Available scripts: @package.json
```

Maximum 4 import hops. Circular imports are ignored.

## HTML comment stripping (v2.1.72+)

Block-level HTML comments in CLAUDE.md are stripped before injection into Claude's
context — use them for maintainer notes that shouldn't consume context tokens.
Comments inside fenced code blocks are preserved (not stripped), and opening the file
directly with the Read tool still shows all comments:

```markdown
<!-- Last reviewed: 2026-06 — remove the pnpm rule when Node 24 ships -->
- Use pnpm (not npm)
```

## Project-wide exclusion (`claudeMdExcludes`)

In monorepos, exclude specific CLAUDE.md files from loading:

```json
// .claude/settings.local.json  (use settings.json instead only if the whole team should share this exclusion)
{
  "claudeMdExcludes": ["**/packages/legacy/**"]
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
