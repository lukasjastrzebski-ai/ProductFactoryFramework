# Claude Code Setup Guide

This guide documents recommended settings and practices for using Claude Code with the Product Factory framework.

---

## Permission Configuration

Claude Code uses `.claude/settings.json` for permission control.

### Repository Template

The factory provides a safe-defaults template at `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Read(**)",
      "Glob(**)",
      "Grep(**)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(pnpm test:*)",
      "Bash(npm test:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)",
      "Bash(git reset --hard:*)",
      "Write(specs/**)",
      "Write(architecture/**)",
      "Write(plan/**)",
      "Edit(specs/**)",
      "Edit(architecture/**)",
      "Edit(plan/**)"
    ]
  }
}
```

### Safe Operations (Allowed)

- **All read operations:** Read, Glob, Grep
- **Standard git operations:** status, diff, log, add, commit
- **Test execution:** pnpm test, npm test
- **Build commands:** pnpm build, npm run build

### Blocked Operations

- **Frozen directories:** Write/Edit to specs/, architecture/, plan/
- **Destructive git:** push --force, reset --hard
- **File deletion:** rm -rf

### Local Overrides

Copy `.claude/settings.json` to `.claude/settings.local.json` for local customizations. The local file takes precedence.

---

## Context Hygiene

### Between Tasks

- Use `/clear` between unrelated tasks to reset context
- Verify context is clean before starting new work

### Session Start

1. Claude automatically reads CLAUDE.md
2. Review docs/execution/state.md for current state
3. Check docs/execution/task_status.md for pending work

### Context Verification

If unsure about context state:
- Review recent chat history
- Re-read key files (ai.md, state.md)
- Ask for clarification

---

## Memory Safety

### Authority Rule

Memory is for recall only. Files always override memory.

### Verification Practice

When using memory for context:
1. Recall the information
2. Verify against source files
3. If conflict, trust files

### Safe Memory Queries

- "What was the last task completed?"
- "What issues were discussed?"
- "What decisions were made?"

### Unsafe Memory Queries

- "What are the requirements?" (verify against specs/)
- "What's the architecture?" (verify against architecture/)
- "What's the implementation plan?" (verify against plan/)

---

## GO/NEXT Protocol

### Before Coding

Always wait for explicit GO authorization:
- DO NOT start implementation without GO
- GO authorizes exactly one task with declared scope
- If scope unclear, ask for clarification

### After Completion

Always request NEXT gate:
- Persist completion report first
- Update state.md
- Then request NEXT

### Gate Responses

| Response | Meaning |
|----------|---------|
| GO | Proceed with stated task |
| NEXT | Continue to next task |
| NEXT:TASK-XXX | Continue to specific task |
| STOP | Halt execution |
| BLOCKED | Wait for resolution |

---

## Quality Enforcement

### Test Delta

Every task must have a Test Delta:
- New tests for new functionality
- Updated tests for changed functionality
- Regression tests for bug fixes

### Before Completion

Verify:
- [ ] All tests pass
- [ ] Test Delta executed
- [ ] Report persisted
- [ ] State updated

---

## Troubleshooting

### Permission Denied

If you see permission denied errors:
1. Check `.claude/settings.json` for deny rules
2. Verify you're not trying to modify frozen artifacts
3. Request PO approval for exceptions

### Context Confusion

If Claude seems confused about context:
1. Use `/clear` to reset
2. Re-read CLAUDE.md and key files
3. Verify state.md is current

### Memory Conflicts

If memory conflicts with files:
1. Trust files (authority rule)
2. Update memory if needed
3. Document the discrepancy

---

## Best Practices

1. **Read before writing:** Always read relevant files before making changes
2. **Small commits:** Make focused, atomic changes
3. **Test immediately:** Run tests after each change
4. **Document decisions:** Note rationale in reports
5. **Ask when unsure:** STOP and ask rather than guess
