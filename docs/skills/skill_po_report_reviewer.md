# Skill PO-02: Report Reviewer

**Version:** 20.0
**Role:** Product Owner
**Purpose:** Validate Task Agent completion reports before issuing NEXT

---

## Overview

When a Task Agent submits a completion report, the Product Owner must validate it against acceptance criteria before approving the task.

---

## Trigger

**When:** Agent submits completion report via COMPLETION_REPORT message

**Input:**
- Agent ID
- Task ID
- Completion report document
- Test results
- Files changed

---

## Validation Steps

### Step 1: Load Reference Documents

```
LOAD:
- Task specification from plan/tasks/TASK-XXX.md
- GO gate record from .factory/execution/go_gates/TASK-XXX-go.json
- Authorized file list from GO gate
- Test Delta from task assignment
```

### Step 2: Verify Acceptance Criteria

```
FOR each acceptance_criterion in task_spec:
  CHECK report claims criterion is met
  VERIFY evidence provided for criterion
  IF not met or no evidence:
    RECORD unmet_criterion: criterion
```

### Step 3: Verify Test Execution

```
FOR each test in test_delta.add:
  CHECK test was created
  CHECK test was executed
  CHECK test passed
  IF any check fails:
    RECORD test_failure: test

FOR each test in test_delta.update:
  CHECK test was updated
  CHECK test was executed
  CHECK test passed
  IF any check fails:
    RECORD test_failure: test

FOR each suite in test_delta.regression:
  CHECK suite was executed
  CHECK no regressions
  IF any check fails:
    RECORD regression: suite
```

### Step 4: Verify File Scope

```
FOR each file in report.files_changed:
  CHECK file in authorized_file_list
  IF not authorized:
    RECORD scope_violation: file

FOR each authorized_file in authorized_file_list:
  IF file not in report.files_changed AND expected_change:
    RECORD missing_change: file
```

### Step 5: Check Quality Baseline

```
CHECK no linting errors reported
CHECK no type errors reported
CHECK coverage not decreased
CHECK no security issues introduced
IF any check fails:
  RECORD quality_violation: check
```

### Step 6: Detect Scope Drift

```
FOR each change in report.changes:
  CHECK change relates to acceptance criteria
  IF unrelated change detected:
    RECORD scope_drift: change
```

---

## Decision Logic

```
IF unmet_criterion is not empty:
    RETURN FIX(
        reason: "Not all acceptance criteria verified",
        unmet: unmet_criterion,
        retry: true
    )

IF test_failure is not empty:
    RETURN FIX(
        reason: "Tests did not pass",
        failures: test_failure,
        retry: true
    )

IF regression is not empty:
    RETURN FIX(
        reason: "Regression detected",
        regressions: regression,
        retry: true
    )

IF scope_violation is not empty:
    RETURN BLOCKED(
        reason: "Unauthorized file modifications",
        violations: scope_violation,
        escalate: may_need_dd
    )

IF scope_drift is not empty:
    RETURN FIX(
        reason: "Scope drift detected",
        drift: scope_drift,
        retry: true,
        guidance: "Revert changes outside task scope"
    )

IF quality_violation is not empty:
    RETURN FIX(
        reason: "Quality baseline not met",
        violations: quality_violation,
        retry: true
    )

RETURN NEXT(
    status: APPROVED,
    task_complete: true
)
```

---

## Output Format

### Approval (NEXT)

```json
{
  "message_type": "next_directive",
  "task_id": "TASK-XXX",
  "agent_id": "agent-xxx",
  "status": "NEXT",
  "validation": {
    "ac_verified": true,
    "tests_passed": true,
    "scope_verified": true,
    "quality_verified": true
  },
  "summary": {
    "criteria_met": 5,
    "tests_passed": 12,
    "files_changed": 3,
    "coverage_delta": "+2%"
  },
  "message": "NEXT. Task completed successfully.",
  "timestamp": "ISO8601"
}
```

### FIX Required

```json
{
  "message_type": "fix_directive",
  "task_id": "TASK-XXX",
  "agent_id": "agent-xxx",
  "status": "FIX",
  "validation": {
    "issues": [
      {
        "type": "unmet_criterion",
        "criterion": "AC-003",
        "description": "No evidence that error message is displayed"
      },
      {
        "type": "test_failure",
        "test": "LoginPage.test.tsx",
        "error": "Expected error message not found"
      }
    ]
  },
  "retry_count": 1,
  "max_retries": 2,
  "guidance": "Fix the error display and update the test to verify it.",
  "timestamp": "ISO8601"
}
```

### BLOCKED

```json
{
  "message_type": "blocked_notification",
  "task_id": "TASK-XXX",
  "agent_id": "agent-xxx",
  "status": "BLOCKED",
  "reason": "Unauthorized file modifications detected",
  "violations": [
    {
      "file": "src/core/config.ts",
      "authorized": false,
      "change": "Modified authentication config"
    }
  ],
  "action": "Task blocked. Requires review.",
  "timestamp": "ISO8601"
}
```

---

## Validation Checklist

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| AC Verification | All criteria met | 100% with evidence |
| Test Execution | All tests run | All pass |
| Regression Suite | No regressions | Zero failures |
| File Scope | Within authorization | No violations |
| Quality Baseline | Standards met | No violations |
| Scope Bounds | No drift | No extra changes |

---

## FIX Retry Logic

```
IF retry_count < max_retries:
    Issue FIX with specific guidance
    Increment retry_count
    Allow agent to fix and resubmit
ELSE:
    Mark task BLOCKED
    Log failure pattern to anti_patterns/
    Consider escalation if pattern persists
```

---

## Examples

### Valid Report

```markdown
## Task Completion Report: TASK-001

### Acceptance Criteria Verification

- [x] AC-001: Login button added (LoginPage.tsx:50)
- [x] AC-002: Auth API called on click (authService.ts:75)
- [x] AC-003: Error displayed on failure (LoginPage.tsx:90)

### Test Results

- LoginPage.test.tsx: 8/8 passed
- auth.test.ts: 12/12 passed
- Regression suite: PASS

### Files Changed

- src/pages/LoginPage.tsx (authorized)
- src/services/authService.ts (authorized)
- tests/LoginPage.test.tsx (authorized)
```

**Result:** NEXT - All criteria verified, tests pass, files authorized.

### Invalid Report (Failing Tests)

```markdown
## Task Completion Report: TASK-001

### Test Results

- LoginPage.test.tsx: 6/8 passed
  - FAIL: should display error on auth failure
  - FAIL: should clear error on retry
```

**Result:** FIX - Tests failing, guidance to fix error handling tests.

### Invalid Report (Scope Drift)

```markdown
## Task Completion Report: TASK-001

### Files Changed

- src/pages/LoginPage.tsx (authorized)
- src/services/authService.ts (authorized)
- src/utils/logger.ts (NOT AUTHORIZED - "improved logging")
- src/core/config.ts (NOT AUTHORIZED - "updated timeout")
```

**Result:** FIX - Unauthorized files modified, revert changes outside scope.

---

## Related Documentation

- [NEXT Gate](../execution/po_next_gate.md)
- [Plan Validator (Skill PO-01)](skill_po_plan_validator.md)
- [Fix Coordination](../execution/fix_coordination.md)
