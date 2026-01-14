# Skill PO-01: Plan Validator

**Version:** 20.0
**Role:** Product Owner
**Purpose:** Validate Task Agent implementation plans before issuing GO

---

## Overview

When a Task Agent submits an implementation plan, the Product Owner must validate it against specifications before authorizing implementation.

---

## Trigger

**When:** Agent submits implementation plan via PLAN_SUBMISSION message

**Input:**
- Agent ID
- Task ID
- Implementation plan document
- Proposed file changes
- AC mapping

---

## Validation Steps

### Step 1: Load Reference Documents

```
LOAD:
- Task specification from plan/tasks/TASK-XXX.md
- Feature specification from specs/features/
- Test Delta from task file
- Authorized file list from task assignment
```

### Step 2: Verify Scope Coverage

```
FOR each acceptance_criterion in task_spec:
  CHECK plan addresses this criterion
  IF not addressed:
    RECORD missing_coverage: criterion
  IF partially addressed:
    RECORD partial_coverage: criterion
```

### Step 3: Check File Scope

```
FOR each file in plan.proposed_files:
  CHECK file in authorized_file_list
  IF not authorized:
    RECORD scope_violation: file
```

### Step 4: Validate Test Delta

```
FOR each test in task.test_delta:
  CHECK plan includes test implementation/update
  IF missing:
    RECORD missing_test: test
```

### Step 5: Detect Scope Expansion

```
FOR each proposed_change in plan:
  CHECK change is necessary for AC items
  IF not necessary:
    RECORD scope_expansion: change
```

### Step 6: Check Spec Alignment

```
FOR each implementation_detail in plan:
  CHECK detail matches specification
  IF contradicts spec:
    RECORD spec_conflict: detail
```

---

## Decision Logic

```
IF missing_coverage is not empty:
    RETURN FEEDBACK(
        status: NEEDS_REVISION,
        reason: "Plan does not address all acceptance criteria",
        missing: missing_coverage
    )

IF scope_violation is not empty:
    RETURN FEEDBACK(
        status: REJECTED,
        reason: "Plan includes unauthorized files",
        violations: scope_violation
    )

IF scope_expansion is not empty:
    RETURN FEEDBACK(
        status: NEEDS_REVISION,
        reason: "Plan exceeds task scope",
        expansion: scope_expansion
    )

IF spec_conflict is not empty:
    RETURN FEEDBACK(
        status: REJECTED,
        reason: "Plan contradicts specification",
        conflicts: spec_conflict
    )

IF missing_test is not empty:
    RETURN FEEDBACK(
        status: NEEDS_REVISION,
        reason: "Plan does not address all Test Delta items",
        missing: missing_test
    )

RETURN APPROVED(
    status: GO,
    scope_confirmed: true,
    authorized_files: authorized_file_list
)
```

---

## Output Format

### Approval (GO)

```json
{
  "message_type": "go_directive",
  "task_id": "TASK-XXX",
  "agent_id": "agent-xxx",
  "status": "GO",
  "validation": {
    "scope_confirmed": true,
    "ac_coverage": "complete",
    "test_delta_addressed": true,
    "spec_alignment": "verified"
  },
  "authorized_files": ["file1.ts", "file2.ts"],
  "notes": "Plan validated. Proceed with implementation.",
  "timestamp": "ISO8601"
}
```

### Rejection

```json
{
  "message_type": "fix_directive",
  "task_id": "TASK-XXX",
  "agent_id": "agent-xxx",
  "status": "NEEDS_REVISION",
  "validation": {
    "issues": [
      {
        "type": "missing_coverage",
        "criterion": "AC-003",
        "description": "Plan does not address user notification requirement"
      },
      {
        "type": "scope_expansion",
        "detail": "Refactoring of auth module not in scope"
      }
    ]
  },
  "guidance": "Revise plan to address AC-003 and remove auth refactoring.",
  "timestamp": "ISO8601"
}
```

---

## Validation Checklist

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| AC Coverage | All criteria addressed | 100% coverage |
| File Scope | Files within authorization | No violations |
| Test Delta | All tests planned | All items covered |
| Spec Alignment | No contradictions | Zero conflicts |
| Scope Bounds | No expansion | No extra work |

---

## Examples

### Valid Plan

```markdown
## Implementation Plan for TASK-001

### Acceptance Criteria Mapping

- AC-001: Add login button → Line 50 of LoginPage.tsx
- AC-002: Call auth API → Line 75 of authService.ts
- AC-003: Show error on failure → Line 90 of LoginPage.tsx

### Files to Modify

- src/pages/LoginPage.tsx (authorized)
- src/services/authService.ts (authorized)

### Test Delta

- ADD: tests/LoginPage.test.tsx - Unit tests for login flow
- UPDATE: tests/auth.test.ts - Add failure case
```

**Result:** GO - All criteria addressed, files authorized, tests planned.

### Invalid Plan (Missing Coverage)

```markdown
## Implementation Plan for TASK-001

### Acceptance Criteria Mapping

- AC-001: Add login button → Line 50 of LoginPage.tsx
- AC-002: Call auth API → Line 75 of authService.ts
# AC-003 not addressed!

### Files to Modify

- src/pages/LoginPage.tsx
```

**Result:** NEEDS_REVISION - AC-003 (error handling) not addressed.

### Invalid Plan (Scope Expansion)

```markdown
## Implementation Plan for TASK-001

### Implementation

1. Add login button (AC-001)
2. Call auth API (AC-002)
3. Show error (AC-003)
4. Refactor auth module for better performance # NOT IN SCOPE
5. Add logging throughout auth flow # NOT IN SCOPE
```

**Result:** NEEDS_REVISION - Items 4 and 5 exceed scope.

---

## Related Documentation

- [GO Gate](../execution/po_go_gate.md)
- [Task Agent Contract](../roles/task_agent.md)
- [Task Assignment](../execution/task_assignment.md)
