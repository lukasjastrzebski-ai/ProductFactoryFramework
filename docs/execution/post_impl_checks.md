# Post-Implementation Validation Checks

**Version:** 20.0

This document defines the automated checks that run after task implementation.

---

## Overview

After an agent submits a completion report, the PO runs validation checks to ensure the task was completed correctly. These checks determine whether to issue NEXT, FIX, or BLOCKED.

---

## Check Categories

### 1. Acceptance Criteria Checks

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| ac_addressed | All AC items in report | 100% coverage |
| ac_verified | Each AC has evidence | Evidence provided |
| ac_passed | All AC marked pass | No failures |

### 2. Test Checks

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| tests_created | New tests created per delta | Files exist |
| tests_executed | All tests were run | Results reported |
| tests_passed | All tests pass | 0 failures |
| no_regressions | Regression suite passes | No new failures |

### 3. Scope Checks

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| files_authorized | Only authorized files changed | No violations |
| no_extra_files | No unexpected files | All changes scoped |
| no_scope_drift | Changes relate to AC | No extra work |

### 4. Quality Checks

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| no_lint_errors | Linting passes | 0 errors |
| no_type_errors | Type checking passes | 0 errors |
| coverage_maintained | Coverage not decreased | >= baseline |
| no_security_issues | No new vulnerabilities | Scan clean |

### 5. Report Checks

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| report_complete | All sections filled | No missing data |
| report_accurate | Data matches reality | Verified |
| evidence_valid | Evidence is verifiable | Can confirm |

---

## Check Execution

```
run_post_impl_checks(task_id, report):
  results = {}

  # AC checks
  results.ac_addressed = check_ac_addressed(task_id, report)
  results.ac_verified = check_ac_evidence(report)
  results.ac_passed = check_ac_status(report)

  # Test checks
  results.tests_created = check_tests_created(task_id, report)
  results.tests_executed = check_tests_executed(report)
  results.tests_passed = check_tests_passed(report)
  results.no_regressions = check_regressions(report)

  # Scope checks
  results.files_authorized = check_file_authorization(task_id, report)
  results.no_scope_drift = check_scope_drift(task_id, report)

  # Quality checks
  results.no_lint_errors = check_lint(report)
  results.coverage_maintained = check_coverage(report)

  # Report checks
  results.report_complete = check_report_completeness(report)
  results.report_accurate = check_report_accuracy(report)

  return results
```

---

## Check Results and Actions

### All Pass → NEXT

```json
{
  "task_id": "TASK-001",
  "overall": "PASS",
  "action": "NEXT",
  "checks": { /* all pass */ }
}
```

### Fixable Failures → FIX

```json
{
  "task_id": "TASK-001",
  "overall": "FAIL",
  "action": "FIX",
  "checks": {
    "tests_passed": {
      "status": "FAIL",
      "message": "2 tests failing",
      "fixable": true
    }
  },
  "retry": {
    "count": 1,
    "max": 2,
    "allowed": true
  },
  "feedback": ["Fix failing tests in LoginPage.test.tsx"]
}
```

### Unfixable Failures → BLOCKED

```json
{
  "task_id": "TASK-001",
  "overall": "FAIL",
  "action": "BLOCKED",
  "checks": {
    "files_authorized": {
      "status": "FAIL",
      "message": "Unauthorized file modifications",
      "fixable": false,
      "violations": ["src/core/config.ts"]
    }
  },
  "reason": "Scope violation requires review"
}
```

---

## Regression Detection

### What Counts as Regression

- Test that passed before now fails
- Coverage decreased significantly
- Build that worked now fails
- Performance degraded measurably

### Regression Response

1. Mark check as FAIL
2. Include in FIX feedback
3. If persistent: Escalate

---

## Check Storage

```
.factory/validation/post_impl/
├── TASK-001-post-impl.json
├── TASK-002-post-impl.json
└── ...
```

---

## Related Documentation

- [NEXT Gate](po_next_gate.md)
- [Report Reviewer (Skill PO-02)](../skills/skill_po_report_reviewer.md)
- [Fix Coordination](fix_coordination.md)
