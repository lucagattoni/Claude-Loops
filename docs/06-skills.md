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
