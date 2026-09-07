# Skills — Reusable Workflows

Skills are on-demand procedures stored in `.claude/skills/<name>/SKILL.md`. Unlike
`CLAUDE.md`, they load only when invoked — keeping every-session context lean.

**When to create a skill:**
- Any multi-step process you invoke more than twice
- Processes involving external tools (`gh`, `aws`, `docker`)
- Workflows your whole team should share

**Commit skills to git.** Place team skills in `.claude/skills/`. Claude auto-discovers
them. Any developer gets the same capabilities.

```markdown
<!-- .claude/skills/deploy/SKILL.md -->
---
name: deploy
description: Deploy to production after running full checks
---
Deploy the current branch to production:

1. Run: pnpm test && pnpm build
2. If either fails, stop and report what failed
3. `gh pr view --json mergeable` — confirm PR is mergeable
4. `aws ecr get-login-password | docker login ...`
5. `docker build -t app:$(git rev-parse --short HEAD) .`
6. `docker push ...`
7. `kubectl rollout restart deployment/app`
8. `kubectl rollout status deployment/app`
9. Report deploy SHA and confirm pods are Running
```

## SKILL.md Frontmatter Reference

Beyond `name` and `description`, a `SKILL.md`'s YAML frontmatter controls when Claude invokes it, what it can touch, and where it runs:

| Field | Does |
|---|---|
| `description` | What Claude uses to decide when to invoke the skill. Combined with `when_to_use`, truncated at **1,536 characters** in the skill listing (raised from 250, v2.1.105) — put the key use case first. |
| `disable-model-invocation` | `true` restricts the skill to `/name` — Claude won't invoke it automatically, and it's excluded from subagent preloading. Since **v2.1.196**, it also stops the skill from running when a scheduled task names it as its prompt. Default `false`. |
| `user-invocable` | `false` hides the skill from the `/` menu — only Claude can invoke it. The mirror of `disable-model-invocation`. Default `true`. |
| `allowed-tools` | Tools Claude can use without a permission prompt for the turn that invokes the skill; the grant clears on your next message. Accepts a YAML list (v2.1.0) as well as a space/comma-separated string. |
| `disallowed-tools` | Removes tools from the pool while the skill is active (v2.1.152). |
| `context: fork` | Runs the skill in its own subagent context (v2.1.0) — a different knob from a Task-tool `subagent_type: fork` (see [Subagents → Cache-Safe Forking](07-subagents.md#cache-safe-forking-and-isolated-child-state)). Since **v2.1.218** this runs in the background by default; set `background: false` to wait for the result inline. |
| `agent` | Which subagent type a `context: fork` skill runs under (v2.1.0). |
| `model` / `effort` | Override the model/effort level for the skill's turn only. Skill *content* can also reference the live value directly with `${CLAUDE_EFFORT}` (v2.1.120) — distinct from the `$CLAUDE_EFFORT` environment variable hooks and Bash commands read (v2.1.133; see [Hooks → Environment variables](12-hooks.md#environment-variables-in-hooks)). |

**`allowed-tools` is not gated by workspace trust.** Claude Code applies a project skill's `allowed-tools` whenever it's invoked, including in an untrusted directory under `-p`. A skill checked into a repository can grant itself broad tool access — review it before running Claude Code against a repo whose skills you didn't write yourself.

Skill files also hot-reload: an edit under `.claude/skills/` takes effect immediately, no session restart needed (v2.1.0+; force a rescan with `/reload-skills`, v2.1.152). Full reference: [Skills → Frontmatter reference](https://code.claude.com/docs/en/skills#frontmatter-reference).

## Skills as SDLC Scaffolding

Skills can enforce engineering process, not just task steps. By baking spec writing,
testing, and review into the skill definition as **non-skippable phases**, you
prevent the agent from taking shortcuts inside a loop. (Pattern from Addy Osmani,
"Agent Skills", May 2026.)

```markdown
<!-- .claude/skills/implement-feature/SKILL.md -->
1. Write a spec in SPEC.md: requirements, acceptance criteria, edge cases
2. Only after spec is written: implement the feature
3. Write tests — unit and integration
4. Run tests; fix all failures before proceeding
5. Open a self-review subagent to audit the diff for correctness
6. Only after review passes: commit and open PR
```

The skill becomes a quality gate: each phase must complete before the next begins,
regardless of how the agent would otherwise sequence the work.

## Make Tools Agent-Legible (`--help` as embedded SKILL.md)

A skill teaches the agent a workflow; the *tools* the workflow calls should teach the
agent how to use them. Write a command's `--help` output detailed enough that an agent
can run the tool correctly from that alone — "it works kind of like bundling a
`SKILL.md` file directly inside the tool." The agent runs `mytool --help`, learns the
flags and expected inputs, and uses it with no external docs.

The payoff: capability travels *with the binary*. There's no separate doc to keep in
sync, and any loop that has the tool installed can self-onboard to it. Treat agents as
first-class users of your CLIs — design the `--help` for them, not just for humans.

(Simon Willison, ["shot-scraper video"](https://simonwillison.net/2026/Jun/30/shot-scraper-video/), Jun 2026.)

## Compiling Expert Knowledge into Skills

Skills don't have to be hand-authored procedures — they can be **compiled from a corpus**.
mimeo extracts expert knowledge from public corpora into agent-loadable skill files,
verifying each extracted claim against its source text before it becomes part of the skill.
Gains are clearest on obscure, quotation-heavy questions — exactly the material a general
model is weakest on and a hand-written skill would rarely think to cover. This is a
production pipeline for the skill-authoring step itself, complementary to (not a
replacement for) the manually-designed SDLC-scaffolding skills above.
([arXiv 2609.00453, "mimeo: Compiling Public Expert Corpora into Agent Skills"](https://arxiv.org/abs/2609.00453), Aug 2026.)

## Skill Compression for Progressive Loading

As a project accumulates skills, the token cost of the skill library itself becomes a
tax on every session. SkillZip Pro compresses progressively-loaded skill bundles by
removing cross-file redundancy while preserving routing (which skill gets invoked when),
reporting a **38% skill-bundle token reduction** and **10.4% per-run token reduction**
with no measured quality loss — a mechanical fix for skill-library bloat, distinct from
the discipline of writing lean skills in the first place.
([arXiv 2608.30785, "SkillZip Pro"](https://arxiv.org/abs/2608.30785), Aug 2026.)
