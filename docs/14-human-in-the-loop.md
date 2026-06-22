# Human-in-the-Loop Escalation

Full autonomy is not always the goal. Build escalation points for situations the
loop cannot resolve:

```markdown
# In CLAUDE.md
If you encounter any of the following, stop and ask for human input:
- A destructive database operation (DROP, DELETE without WHERE)
- A push to main or production infrastructure
- A cost estimate exceeding $10
- Ambiguity about which of two approaches to take
- Three consecutive test failures with no clear fix
```

**Auto mode escalates automatically** when:
- The classifier blocks the same action 3 consecutive times
- Total denied actions reach 20 in a session
