# Pre-GO Validation Checks

**Version:** 20.0

This document defines the automated checks that run before the PO issues a GO gate.

---

## Overview

Before issuing GO, the PO runs a series of validation checks to ensure the task is ready for implementation. All checks must pass for GO to be issued.

---

## Check Categories

### 1. Specification Checks

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| spec_exists | Task spec file exists | File found |
| spec_complete | Spec has all required sections | No placeholders |
| ac_defined | Acceptance criteria present | AC list not empty |
| ac_testable | All AC are testable | No subjective criteria |

### 2. Test Delta Checks

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| test_delta_defined | Test Delta section exists | Section present |
| tests_mapped | Tests cover all AC | 100% coverage |
| regression_defined | Regression suite specified | Suite listed |

### 3. Dependency Checks

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| deps_satisfied | All dependencies completed | All have NEXT |
| deps_valid | Dependencies exist | All task IDs valid |
| no_circular | No circular dependencies | Graph acyclic |

### 4. Plan Checks

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| plan_submitted | Agent submitted plan | Plan received |
| plan_complete | Plan covers all AC | 100% coverage |
| plan_scoped | Plan within file scope | No violations |
| plan_aligned | Plan matches spec | No conflicts |

### 5. Resource Checks

| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| agent_available | Agent slot free | < max agents |
| files_available | No file conflicts | No active ownership |
| no_blockers | No blocking escalations | Queue clear |

---

## Check Execution

### Automatic Checks

Run automatically when agent submits plan:

```
run_pre_go_checks(task_id, plan):
  results = {}

  # Specification checks
  results.spec_exists = check_spec_exists(task_id)
  results.spec_complete = check_spec_complete(task_id)
  results.ac_defined = check_ac_defined(task_id)
  results.ac_testable = check_ac_testable(task_id)

  # Test Delta checks
  results.test_delta_defined = check_test_delta(task_id)
  results.tests_mapped = check_test_coverage(task_id, plan)
  results.regression_defined = check_regression(task_id)

  # Dependency checks
  results.deps_satisfied = check_deps_satisfied(task_id)
  results.deps_valid = check_deps_valid(task_id)
  results.no_circular = check_no_circular(task_id)

  # Plan checks
  results.plan_complete = check_plan_coverage(plan)
  results.plan_scoped = check_plan_scope(plan, task_id)
  results.plan_aligned = check_plan_alignment(plan, task_id)

  # Resource checks
  results.agent_available = check_agent_slots()
  results.files_available = check_file_availability(plan.files)

  return results
```

---

## Check Results

### All Pass

```json
{
  "task_id": "TASK-001",
  "timestamp": "ISO8601",
  "overall": "PASS",
  "checks": {
    "spec_exists": {"status": "PASS"},
    "spec_complete": {"status": "PASS"},
    "ac_defined": {"status": "PASS"},
    "ac_testable": {"status": "PASS"},
    "test_delta_defined": {"status": "PASS"},
    "tests_mapped": {"status": "PASS"},
    "regression_defined": {"status": "PASS"},
    "deps_satisfied": {"status": "PASS"},
    "deps_valid": {"status": "PASS"},
    "no_circular": {"status": "PASS"},
    "plan_complete": {"status": "PASS"},
    "plan_scoped": {"status": "PASS"},
    "plan_aligned": {"status": "PASS"},
    "agent_available": {"status": "PASS"},
    "files_available": {"status": "PASS"}
  },
  "action": "GO"
}
```

### Failure

```json
{
  "task_id": "TASK-001",
  "timestamp": "ISO8601",
  "overall": "FAIL",
  "checks": {
    "spec_exists": {"status": "PASS"},
    "plan_complete": {
      "status": "FAIL",
      "message": "AC-003 not addressed in plan",
      "details": {
        "missing": ["AC-003"]
      }
    },
    "files_available": {
      "status": "FAIL",
      "message": "File conflict with active agent",
      "details": {
        "file": "src/auth.ts",
        "owner": "agent-abc"
      }
    }
  },
  "action": "FEEDBACK",
  "feedback": [
    "Please address AC-003 in your plan",
    "Cannot proceed while src/auth.ts is being modified by another agent"
  ]
}
```

---

## Check Storage

Results stored for audit:

```
.factory/validation/pre_go/
├── TASK-001-pre-go.json
├── TASK-002-pre-go.json
└── ...
```

---

## Related Documentation

- [GO Gate](po_go_gate.md)
- [Plan Validator (Skill PO-01)](../skills/skill_po_plan_validator.md)
- [Post-Implementation Checks](post_impl_checks.md)
