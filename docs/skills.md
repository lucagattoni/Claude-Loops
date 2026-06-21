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
