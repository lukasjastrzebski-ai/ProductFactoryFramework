# PO GO Gate

**Version:** 20.0

This document defines the GO gate protocol for the Product Owner in v20 autonomous mode.

---

## Overview

In v20 mode, the Product Owner (PO) issues GO gates internally, without requiring human (Delivery Director) approval. This enables autonomous task execution while maintaining quality through validation.

---

## GO Gate Definition

The GO gate authorizes a Task Agent to begin implementation of an assigned task.

**Issued By:** Product Owner (PO)
**Issued To:** Task Agent
**Authorization:** Begin implementation

---

## Pre-GO Requirements

Before issuing GO, the PO must verify:

### 1. Plan Submitted

- Task Agent has submitted implementation plan
- Plan document is complete and parseable

### 2. Plan Validated (Skill PO-01)

- All acceptance criteria addressed
- No file scope violations
- Test Delta covered
- No spec conflicts
- No scope expansion

### 3. Dependencies Satisfied

- All task dependencies completed
- Dependent tasks have NEXT gate issued
- No blocking escalations

### 4. Resources Available

- Agent slot available (< max concurrent agents)
- Git worktree can be created
- No file ownership conflicts

---

## GO Gate Process

```
┌──────────────────────────────────────────────────────────────┐
│                     GO GATE PROCESS                           │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  1. RECEIVE plan from Agent                                   │
│     └─ Parse PLAN_SUBMISSION message                         │
│                                                               │
│  2. VALIDATE plan (Skill PO-01)                              │
│     ├─ Check AC coverage                                     │
│     ├─ Check file scope                                      │
│     ├─ Check test delta                                      │
│     ├─ Check spec alignment                                  │
│     └─ Check scope bounds                                    │
│                                                               │
│  3. CHECK dependencies                                        │
│     ├─ Query execution state                                 │
│     └─ Verify all deps have NEXT                            │
│                                                               │
│  4. ISSUE GO or FEEDBACK                                      │
│     ├─ If valid: Issue GO directive                         │
│     └─ If invalid: Issue FIX directive with feedback        │
│                                                               │
│  5. RECORD gate                                               │
│     ├─ Save to .factory/execution/go_gates/                 │
│     └─ Update orchestrator state                            │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## GO Directive Format

```json
{
  "directive_type": "GO",
  "task_id": "TASK-XXX",
  "agent_id": "agent-{uuid}",
  "timestamp": "2026-01-14T10:00:00Z",
  "validation": {
    "plan_validated": true,
    "ac_coverage": "complete",
    "file_scope": "verified",
    "test_delta": "addressed",
    "spec_alignment": "verified"
  },
  "authorization": {
    "authorized_files": [
      "src/feature/component.ts",
      "src/feature/component.test.ts"
    ],
    "test_delta": {
      "add": ["src/feature/component.test.ts"],
      "update": [],
      "regression": ["npm test"]
    },
    "timeout_minutes": 30
  },
  "message": "GO. Plan validated. Begin implementation."
}
```

---

## Gate Record

Each GO gate is recorded for audit:

**File:** `.factory/execution/go_gates/TASK-XXX-go.json`

```json
{
  "task_id": "TASK-XXX",
  "agent_id": "agent-{uuid}",
  "gate_type": "GO",
  "issued_at": "2026-01-14T10:00:00Z",
  "issued_by": "PRODUCT_OWNER",
  "validation_result": {
    "ac_coverage": true,
    "file_scope": true,
    "test_delta": true,
    "spec_alignment": true,
    "scope_bounds": true
  },
  "plan_hash": "sha256:...",
  "session_id": "{uuid}"
}
```

---

## State Updates

When GO is issued:

1. **orchestrator_state.json:**
   ```json
   {
     "statistics": {
       "go_gates_issued": "+1"
     }
   }
   ```

2. **agent_registry.json:**
   ```json
   {
     "agents": [
       {
         "agent_id": "agent-{uuid}",
         "task_id": "TASK-XXX",
         "status": "implementing",
         "go_issued_at": "ISO8601"
       }
     ]
   }
   ```

---

## Rejection (No GO)

If validation fails, issue FIX directive instead:

```json
{
  "directive_type": "FIX",
  "task_id": "TASK-XXX",
  "agent_id": "agent-{uuid}",
  "timestamp": "2026-01-14T10:00:00Z",
  "validation": {
    "plan_validated": false,
    "issues": [
      {
        "type": "missing_coverage",
        "criterion": "AC-003",
        "message": "Error handling not addressed"
      }
    ]
  },
  "guidance": "Revise plan to address AC-003 error handling requirement.",
  "retry_allowed": true
}
```

---

## Error Handling

### Dependency Not Met

```
Cannot issue GO for TASK-003:
  Dependency TASK-001 status: IN_PROGRESS
  Action: Wait for TASK-001 completion
```

### Resource Conflict

```
Cannot issue GO for TASK-005:
  File conflict: src/auth.ts owned by agent-001
  Action: Wait for agent-001 completion or resequence
```

### Max Agents Reached

```
Cannot issue GO for TASK-006:
  Active agents: 5/5
  Action: Wait for agent slot availability
```

---

## Best Practices

### For PO

1. Always validate plan before GO
2. Record all gates for audit trail
3. Include clear authorization scope in GO
4. Provide specific feedback on rejection

### For Agents

1. Submit complete plans
2. Wait for explicit GO before implementing
3. Stay within authorized scope
4. Report blockers immediately

---

## Related Documentation

- [Plan Validator (Skill PO-01)](../skills/skill_po_plan_validator.md)
- [NEXT Gate](po_next_gate.md)
- [Task Assignment](task_assignment.md)
- [Agent Task Runner](agent_task_runner.md)
