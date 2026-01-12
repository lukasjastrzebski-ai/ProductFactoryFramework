# PR Documentation for AI-Assisted Development

## Purpose

When creating pull requests for AI-implemented tasks, proper documentation helps reviewers understand the work and maintains team alignment ("mental alignment" per Dex Horthy).

## Required Elements

Every PR for factory-managed tasks must include:

### 1. Task Reference
Link to the task file that authorized the work:
```
**Task:** [TASK-XXX](../../plan/tasks/TASK-XXX.md)
```

### 2. Report Reference
Link to the execution report:
```
**Report:** [TASK-XXX Report](../execution/reports/TASK-XXX.md)
```

### 3. Test Delta Summary
Brief summary of testing performed:
```
**Tests:**
- Added: 3 unit tests for auth flow
- Updated: login.test.ts assertions
- Regression: Full auth suite passed
```

## Recommended Elements

### Key Decisions
Document any decisions made during implementation:
```
**Decisions:**
- Used JWT instead of session tokens (per ADR-003)
- Added rate limiting to login endpoint
```

### Manual Testing
Describe manual verification performed:
```
**Manual Testing:**
- Verified login flow in browser
- Tested error states (invalid password, locked account)
- Confirmed logout clears session
```

### Deviations from Plan
If implementation differed from the plan, explain why:
```
**Deviations:**
- Added input sanitization (discovered XSS vector during implementation)
- See report for full justification
```

### Research Reference
If Skill 14 was used:
```
**Research:** [TASK-XXX Research](../execution/research/TASK-XXX-research.md)
```

## PR Description Template

```markdown
## Summary

[One sentence description of what this PR accomplishes]

## References

- **Task:** [TASK-XXX](../../plan/tasks/TASK-XXX.md)
- **Report:** [TASK-XXX Report](../execution/reports/TASK-XXX.md)
- **Research:** [If applicable](../execution/research/TASK-XXX-research.md)

## Changes

- [List key changes made]
- [Focus on "what" not "how"]

## Testing

- [x] Unit tests added/updated
- [x] Manual testing completed
- [x] Regression suite passed

### Test Summary
| Type | Added | Updated | Passed |
|------|-------|---------|--------|
| Unit | 3 | 1 | 15/15 |
| Integration | 0 | 0 | 8/8 |

## Decisions

- [Any implementation decisions worth noting]

## Notes for Reviewers

[Any additional context that helps review]

---
*Implemented via Product Factory Framework v10.2*
```

## Benefits

1. **Faster Reviews** - Reviewers have context immediately
2. **Audit Trail** - Links to task, report, and research documents
3. **Mental Alignment** - Team stays synchronized on changes
4. **Quality Signal** - Shows disciplined execution process

## Anti-patterns

- PRs without task references
- Missing test documentation
- Undocumented deviations from plan
- Walls of green without context

## Integration with Factory

This documentation pattern complements:
- Task Runner reports (detailed execution record)
- state.md updates (project-level tracking)
- progress.json (structured metrics)

The PR description is the "public face" of the work for team review.
