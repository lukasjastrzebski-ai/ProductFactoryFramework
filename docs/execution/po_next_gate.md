# PO NEXT Gate

**Version:** 20.0

This document defines the NEXT gate protocol for the Product Owner in v20 autonomous mode.

---

## Overview

In v20 mode, the Product Owner (PO) issues NEXT gates after validating task completion reports. This advances execution to the next task or marks tasks as blocked.

---

## NEXT Gate Definition

The NEXT gate signals that a task is complete and the agent can terminate.

**Issued By:** Product Owner (PO)
**Issued To:** Task Agent
**Signal:** Task complete, proceed

---

## Gate Outcomes

### NEXT (Success)

Task completed successfully. Agent should terminate.

### FIX (Retry)

Task has issues. Agent should fix and resubmit.

### BLOCKED

Task cannot proceed. Agent terminates, task marked blocked.

---

## Pre-NEXT Requirements

Before issuing NEXT, the PO must verify:

### 1. Report Submitted

- Task Agent has submitted completion report
- Report document is complete

### 2. Report Validated (Skill PO-02)

- All acceptance criteria verified with evidence
- All tests executed and passed
- No regressions detected
- File changes within authorized scope
- Quality baseline maintained
- No scope drift

---

## NEXT Gate Process

```
┌──────────────────────────────────────────────────────────────┐
│                    NEXT GATE PROCESS                          │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  1. RECEIVE report from Agent                                 │
│     └─ Parse COMPLETION_REPORT message                       │
│                                                               │
│  2. VALIDATE report (Skill PO-02)                            │
│     ├─ Verify AC items                                       │
│     ├─ Check test results                                    │
│     ├─ Verify file scope                                     │
│     ├─ Check quality baseline                                │
│     └─ Detect scope drift                                    │
│                                                               │
│  3. DETERMINE outcome                                         │
│     ├─ All checks pass → NEXT                               │
│     ├─ Fixable issues & retries left → FIX                  │
│     └─ Unfixable or max retries → BLOCKED                   │
│                                                               │
│  4. ISSUE directive                                           │
│     ├─ NEXT: Agent terminates, task complete                │
│     ├─ FIX: Agent retries with guidance                     │
│     └─ BLOCKED: Agent terminates, task blocked              │
│                                                               │
│  5. UPDATE state                                              │
│     ├─ Update orchestrator state                            │
│     ├─ Update agent registry                                │
│     └─ Trigger dependent tasks if NEXT                      │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## NEXT Directive Format

```json
{
  "directive_type": "NEXT",
  "task_id": "TASK-XXX",
  "agent_id": "agent-{uuid}",
  "timestamp": "2026-01-14T12:00:00Z",
  "validation": {
    "report_validated": true,
    "ac_verified": "complete",
    "tests_passed": true,
    "scope_verified": true,
    "quality_verified": true
  },
  "summary": {
    "criteria_met": 5,
    "tests_added": 3,
    "tests_updated": 1,
    "files_changed": 4,
    "lines_added": 150,
    "lines_removed": 20
  },
  "message": "NEXT. Task TASK-XXX completed successfully.",
  "cleanup": {
    "worktree": "remove",
    "branch": "ready_for_merge"
  }
}
```

---

## FIX Directive Format

```json
{
  "directive_type": "FIX",
  "task_id": "TASK-XXX",
  "agent_id": "agent-{uuid}",
  "timestamp": "2026-01-14T12:00:00Z",
  "validation": {
    "report_validated": false,
    "issues": [
      {
        "type": "unmet_criterion",
        "id": "AC-003",
        "message": "Error handling not implemented"
      },
      {
        "type": "test_failure",
        "test": "auth.test.ts",
        "message": "Test 'should handle timeout' failed"
      }
    ]
  },
  "retry": {
    "count": 1,
    "max": 2,
    "allowed": true
  },
  "guidance": "1. Implement error handling for auth timeout\n2. Fix the failing test",
  "message": "FIX required. See issues and guidance."
}
```

---

## BLOCKED Directive Format

```json
{
  "directive_type": "BLOCKED",
  "task_id": "TASK-XXX",
  "agent_id": "agent-{uuid}",
  "timestamp": "2026-01-14T12:00:00Z",
  "reason": "Max retries exceeded",
  "history": {
    "attempt_1": "Missing AC coverage",
    "attempt_2": "Test failures",
    "attempt_3": "Test failures (same)"
  },
  "next_steps": {
    "options": [
      "DD intervention required",
      "Task needs rescoping",
      "Different approach needed"
    ],
    "escalate": true
  },
  "message": "BLOCKED. Task cannot proceed without intervention."
}
```

---

## State Updates

### On NEXT

```json
// orchestrator_state.json
{
  "statistics": {
    "tasks_completed": "+1",
    "next_gates_issued": "+1"
  }
}

// agent_registry.json
{
  "agents": [
    {
      "agent_id": "agent-{uuid}",
      "status": "completed",
      "completed_at": "ISO8601"
    }
  ]
}

// docs/execution/state.md
Last Completed Task: TASK-XXX
```

### On FIX

```json
// orchestrator_state.json
{
  "statistics": {
    "retries_issued": "+1"
  }
}

// agent_registry.json
{
  "agents": [
    {
      "agent_id": "agent-{uuid}",
      "status": "fixing",
      "retry_count": 1
    }
  ]
}
```

### On BLOCKED

```json
// orchestrator_state.json
{
  "statistics": {
    "tasks_blocked": "+1"
  }
}

// agent_registry.json
{
  "agents": [
    {
      "agent_id": "agent-{uuid}",
      "status": "blocked",
      "blocked_at": "ISO8601",
      "reason": "max_retries"
    }
  ]
}
```

---

## Dependent Task Triggering

When NEXT is issued, check for tasks that can now proceed:

```
FOR each task in pending_tasks:
  IF task.dependencies all have NEXT:
    ADD task to ready_queue
    SPAWN agent if slots available
```

---

## Merge Process

After NEXT is issued:

1. Agent's worktree branch marked ready for merge
2. PO controls merge order (based on dependency graph)
3. Merge performed when safe (no conflicts with in-progress agents)
4. Worktree cleaned up after merge

---

## Error Handling

### Agent Not Responding

```
IF no report within timeout:
  CHECK agent progress
  IF agent stuck:
    ISSUE BLOCKED(reason: "agent_timeout")
    TERMINATE agent
```

### Conflicting Changes

```
IF merge conflict detected:
  HOLD merge
  NOTIFY about conflict
  MAY require FIX or manual resolution
```

---

## Related Documentation

- [Report Reviewer (Skill PO-02)](../skills/skill_po_report_reviewer.md)
- [GO Gate](po_go_gate.md)
- [Fix Coordination](fix_coordination.md)
- [Agent Task Runner](agent_task_runner.md)
