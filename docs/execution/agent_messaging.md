# Agent-PO Message Protocol

**Version:** 20.0

This document defines the messaging protocol between Task Agents and the Product Owner.

---

## Overview

Task Agents communicate with the Product Owner through structured messages. Messages are used for plan submission, progress updates, completion reports, and receiving directives.

---

## Message Flow

```
Agent → PO                         PO → Agent
──────────────                     ──────────────
PLAN_SUBMISSION    ────────►
                   ◄────────       GO_DIRECTIVE
                                   or FEEDBACK

PROGRESS_UPDATE    ────────►
                   ◄────────       (acknowledgment)

COMPLETION_REPORT  ────────►
                   ◄────────       NEXT_DIRECTIVE
                                   or FIX_DIRECTIVE
                                   or BLOCKED_NOTIFICATION

BLOCKED_NOTIFICATION ──────►
                   ◄────────       (acknowledgment)
```

---

## Message Types

### Agent to PO

| Type | Purpose | When Sent |
|------|---------|-----------|
| PLAN_SUBMISSION | Submit implementation plan | Before GO |
| PROGRESS_UPDATE | Report current status | Every 5 min |
| COMPLETION_REPORT | Report task completion | After implementation |
| BLOCKED_NOTIFICATION | Report blocker | When stuck |

### PO to Agent

| Type | Purpose | When Sent |
|------|---------|-----------|
| GO_DIRECTIVE | Authorize implementation | After plan validated |
| FEEDBACK | Request plan revision | If plan has issues |
| NEXT_DIRECTIVE | Approve completion | After report validated |
| FIX_DIRECTIVE | Request fixes | If report has issues |
| BLOCKED_NOTIFICATION | Mark task blocked | After max retries |
| TERMINATE_DIRECTIVE | End agent | Abort/cleanup |

---

## Message Schemas

### PLAN_SUBMISSION

```json
{
  "message_type": "PLAN_SUBMISSION",
  "agent_id": "agent-xxx",
  "task_id": "TASK-XXX",
  "timestamp": "ISO8601",
  "plan": {
    "approach": "Description of implementation approach",
    "ac_mapping": [
      {
        "ac_id": "AC-001",
        "implementation": "Add login form component",
        "file": "src/pages/LoginPage.tsx",
        "line_estimate": "~50"
      }
    ],
    "files_to_modify": [
      {
        "path": "src/pages/LoginPage.tsx",
        "changes": "Add form, validation, submit handler"
      }
    ],
    "test_approach": {
      "unit_tests": ["Test form validation", "Test submit"],
      "integration_tests": ["Test login flow"]
    }
  },
  "questions": [],
  "revision": 1
}
```

### PROGRESS_UPDATE

```json
{
  "message_type": "PROGRESS_UPDATE",
  "agent_id": "agent-xxx",
  "task_id": "TASK-XXX",
  "timestamp": "ISO8601",
  "status": "implementing",
  "progress_percent": 50,
  "current_activity": "Writing login form component",
  "files_modified": [
    "src/pages/LoginPage.tsx"
  ],
  "issues": [],
  "eta_minutes": 15
}
```

### COMPLETION_REPORT

```json
{
  "message_type": "COMPLETION_REPORT",
  "agent_id": "agent-xxx",
  "task_id": "TASK-XXX",
  "timestamp": "ISO8601",
  "summary": {
    "started_at": "ISO8601",
    "completed_at": "ISO8601",
    "duration_minutes": 25
  },
  "ac_verification": [
    {
      "ac_id": "AC-001",
      "status": "PASS",
      "evidence": "LoginPage.tsx:50 - form component added",
      "tested": true
    }
  ],
  "test_results": {
    "passed": 12,
    "failed": 0,
    "skipped": 0,
    "details": [
      {
        "file": "LoginPage.test.tsx",
        "passed": 8,
        "failed": 0
      }
    ]
  },
  "files_changed": [
    {
      "path": "src/pages/LoginPage.tsx",
      "action": "modified",
      "lines_added": 50,
      "lines_removed": 5
    }
  ],
  "issues": [],
  "recommendations": []
}
```

### BLOCKED_NOTIFICATION (Agent)

```json
{
  "message_type": "BLOCKED_NOTIFICATION",
  "agent_id": "agent-xxx",
  "task_id": "TASK-XXX",
  "timestamp": "ISO8601",
  "reason": "Cannot resolve test failure",
  "details": {
    "issue": "Auth service mock not working",
    "attempts": [
      "Tried updating mock",
      "Tried different mock library"
    ],
    "blocking_since": "ISO8601"
  },
  "suggested_action": "May need different mocking approach"
}
```

### GO_DIRECTIVE

```json
{
  "message_type": "GO_DIRECTIVE",
  "task_id": "TASK-XXX",
  "agent_id": "agent-xxx",
  "timestamp": "ISO8601",
  "status": "GO",
  "validation": {
    "plan_validated": true,
    "ac_coverage": "complete",
    "file_scope": "verified",
    "test_delta": "addressed"
  },
  "authorization": {
    "authorized_files": [
      "src/pages/LoginPage.tsx",
      "src/services/authService.ts",
      "tests/LoginPage.test.tsx"
    ],
    "timeout_minutes": 30
  },
  "message": "GO. Plan validated. Begin implementation."
}
```

### FEEDBACK

```json
{
  "message_type": "FEEDBACK",
  "task_id": "TASK-XXX",
  "agent_id": "agent-xxx",
  "timestamp": "ISO8601",
  "status": "NEEDS_REVISION",
  "validation": {
    "issues": [
      {
        "type": "missing_coverage",
        "ac_id": "AC-003",
        "message": "Plan does not address error handling"
      }
    ]
  },
  "guidance": "Please add error handling for auth failures to your plan",
  "revision_required": true,
  "max_revisions": 2,
  "current_revision": 1
}
```

### NEXT_DIRECTIVE

```json
{
  "message_type": "NEXT_DIRECTIVE",
  "task_id": "TASK-XXX",
  "agent_id": "agent-xxx",
  "timestamp": "ISO8601",
  "status": "NEXT",
  "validation": {
    "report_validated": true,
    "ac_verified": "complete",
    "tests_passed": true,
    "scope_verified": true
  },
  "summary": {
    "criteria_met": 4,
    "tests_passed": 12,
    "files_changed": 3
  },
  "message": "NEXT. Task completed successfully.",
  "cleanup": {
    "worktree": "ready_for_merge",
    "branch": "agent/agent-xxx/TASK-XXX"
  }
}
```

### FIX_DIRECTIVE

```json
{
  "message_type": "FIX_DIRECTIVE",
  "task_id": "TASK-XXX",
  "agent_id": "agent-xxx",
  "timestamp": "ISO8601",
  "status": "FIX",
  "validation": {
    "issues": [
      {
        "type": "test_failure",
        "test": "LoginPage.test.tsx",
        "message": "Test 'should show error on failure' failed"
      }
    ]
  },
  "retry": {
    "count": 1,
    "max": 2,
    "allowed": true
  },
  "guidance": "Fix the error display test - ensure error message element exists",
  "message": "FIX required. Address issues and resubmit."
}
```

### TERMINATE_DIRECTIVE

```json
{
  "message_type": "TERMINATE_DIRECTIVE",
  "task_id": "TASK-XXX",
  "agent_id": "agent-xxx",
  "timestamp": "ISO8601",
  "reason": "abort",
  "cleanup": {
    "worktree": "remove",
    "branch": "delete"
  },
  "message": "Terminate. Phase aborted by DD."
}
```

---

## Message Persistence

### Storage Location

Messages are persisted for audit:

```
.factory/execution/messages/
├── agent-xxx/
│   ├── PLAN_SUBMISSION_001.json
│   ├── PROGRESS_UPDATE_001.json
│   ├── COMPLETION_REPORT_001.json
│   └── received/
│       ├── GO_DIRECTIVE_001.json
│       └── NEXT_DIRECTIVE_001.json
```

### Retention

- Active task messages: Keep until task complete
- Completed task messages: Keep for 7 days
- Archive important messages to execution history

---

## Error Handling

### Message Validation

All messages validated before processing:

```
VALIDATE message:
  - Required fields present
  - Valid message_type
  - Matching agent_id and task_id
  - Valid timestamp format
```

### Invalid Message Response

```json
{
  "message_type": "ERROR",
  "error": {
    "code": "INVALID_MESSAGE",
    "message": "Missing required field: ac_verification",
    "original_message_type": "COMPLETION_REPORT"
  },
  "action": "Please resubmit with all required fields"
}
```

---

## Related Documentation

- [Agent Task Runner](agent_task_runner.md)
- [GO Gate](po_go_gate.md)
- [NEXT Gate](po_next_gate.md)
- [Fix Coordination](fix_coordination.md)
