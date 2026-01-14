# Fix Coordination

**Version:** 20.0

This document defines how the Product Owner coordinates fix cycles for failed tasks.

---

## Overview

When a Task Agent's work doesn't pass validation, the PO must coordinate fixes. This involves providing feedback, managing retries, and escalating persistent failures.

---

## Fix Cycle Flow

```
┌──────────────────────────────────────────────────────────────┐
│                     FIX CYCLE FLOW                            │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Report Received                                              │
│       │                                                       │
│       ▼                                                       │
│  ┌─────────────┐                                             │
│  │  Validate   │───── PASS ─────► NEXT (complete)            │
│  │   Report    │                                             │
│  └─────────────┘                                             │
│       │                                                       │
│       │ FAIL                                                  │
│       ▼                                                       │
│  ┌─────────────┐                                             │
│  │  Retries    │───── NO ──────► BLOCKED (escalate)          │
│  │  Available? │                                             │
│  └─────────────┘                                             │
│       │                                                       │
│       │ YES                                                   │
│       ▼                                                       │
│  ┌─────────────┐                                             │
│  │  Issue FIX  │                                             │
│  │  Directive  │                                             │
│  └─────────────┘                                             │
│       │                                                       │
│       ▼                                                       │
│  ┌─────────────┐                                             │
│  │   Agent     │                                             │
│  │   Fixes     │                                             │
│  └─────────────┘                                             │
│       │                                                       │
│       ▼                                                       │
│  Report Received (loop back to validate)                     │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Retry Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| max_retries | 2 | Maximum fix attempts |
| retry_timeout | 15 min | Time limit per retry |
| fresh_context | true | Clear agent context on retry 2+ |

---

## FIX Directive Components

### Issue Identification

Clearly identify what failed:

```json
{
  "issues": [
    {
      "type": "unmet_criterion",
      "id": "AC-003",
      "severity": "blocking",
      "evidence_missing": true
    },
    {
      "type": "test_failure",
      "test": "auth.test.ts:45",
      "error": "Expected 'Login failed' but got undefined",
      "severity": "blocking"
    }
  ]
}
```

### Specific Guidance

Provide actionable guidance:

```json
{
  "guidance": {
    "steps": [
      "Add error state to LoginPage component",
      "Display error message when auth fails",
      "Update test to check for error message element"
    ],
    "references": [
      "See AC-003 in specs/features/auth.md",
      "Error component pattern in src/components/Error.tsx"
    ],
    "avoid": [
      "Do not modify the auth service error format",
      "Do not add logging outside the LoginPage"
    ]
  }
}
```

### Anti-Patterns (Retry 2+)

For persistent failures, include anti-patterns:

```json
{
  "anti_patterns": {
    "documented_in": ".factory/anti_patterns/TASK-XXX-attempt-1.md",
    "avoid": [
      "Previous attempt used wrong error property name",
      "Do not use 'error.message', use 'error.displayText'"
    ]
  }
}
```

---

## Retry Strategy

### Retry 1: Same Context

- Provide specific feedback
- Keep agent context
- Expect quick fix

```json
{
  "retry": {
    "count": 1,
    "strategy": "same_context",
    "guidance_level": "specific",
    "timeout_minutes": 15
  }
}
```

### Retry 2: Fresh Context

- Document failure pattern
- Clear agent context
- Provide anti-patterns
- More comprehensive guidance

```json
{
  "retry": {
    "count": 2,
    "strategy": "fresh_context",
    "guidance_level": "comprehensive",
    "anti_patterns_provided": true,
    "timeout_minutes": 20
  }
}
```

### Beyond Max Retries: BLOCKED

- Document all attempts
- Create anti-pattern file
- Mark task BLOCKED
- Consider escalation

---

## Anti-Pattern Documentation

When fixes fail repeatedly, document the pattern:

**File:** `.factory/anti_patterns/TASK-XXX-failed-approach.md`

```markdown
# Failed Approach: TASK-XXX

## Task
Implement login error handling

## Attempts

### Attempt 1
- Approach: Used error.message property
- Result: Property doesn't exist on AuthError type
- Lesson: AuthError uses displayText, not message

### Attempt 2
- Approach: Added displayText but didn't render
- Result: Component didn't re-render on error
- Lesson: Need to trigger state update

## Root Cause
Agent didn't understand the AuthError type structure

## Recommendations
- Provide type definition in task assignment
- Include example error handling pattern
```

---

## Escalation Triggers

### Automatic Escalation

- Same error on all retries
- Test suite regression
- Security issue detected
- File conflict with another agent

### Optional Escalation

- Quality below threshold
- Unusual amount of changes
- Agent stuck/unresponsive

---

## Monitoring Fix Cycles

Track fix cycle metrics:

```json
{
  "task_id": "TASK-XXX",
  "fix_cycles": {
    "total_attempts": 3,
    "issues_by_type": {
      "unmet_criterion": 2,
      "test_failure": 1
    },
    "time_in_fix": "45 minutes",
    "outcome": "completed" | "blocked"
  }
}
```

---

## PO Actions During Fix

### While Agent is Fixing

1. Monitor progress updates
2. Check for stuck state
3. Prepare additional guidance if needed

### When Report Resubmitted

1. Re-run validation
2. Compare to previous issues
3. Check if same issues persist

### If Blocked

1. Log complete failure history
2. Create anti-pattern documentation
3. Update task status
4. Determine next steps (DD escalation, rescope, etc.)

---

## Examples

### Successful Fix Cycle

```
Report 1: AC-003 not met (no error display)
FIX 1: "Add error state and display component"
Report 2: All criteria met, tests pass
NEXT: Task complete
```

### Failed Fix Cycle

```
Report 1: Test failures (3 tests)
FIX 1: "Fix assertions in auth tests"
Report 2: Same test failures
FIX 2 (fresh context): "Use ErrorBoundary pattern, see anti_patterns/"
Report 3: Same test failures
BLOCKED: "Max retries exceeded, same failure pattern"
```

---

## Best Practices

### For PO

1. **Be Specific** - Generic feedback leads to generic fixes
2. **Provide Context** - Reference specs, examples, patterns
3. **Document Patterns** - Anti-patterns help future attempts
4. **Know When to Stop** - Don't waste retries on unfixable issues

### For Agents

1. **Read Feedback Carefully** - Address each issue specifically
2. **Ask If Unclear** - Better to clarify than guess
3. **Don't Repeat Approaches** - If it didn't work, try different
4. **Report Blockers** - If stuck, say so

---

## Related Documentation

- [Report Reviewer (Skill PO-02)](../skills/skill_po_report_reviewer.md)
- [NEXT Gate](po_next_gate.md)
- [Trajectory Management](../patterns/trajectory_management.md)
