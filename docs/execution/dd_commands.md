# Delivery Director Commands

**Version:** 20.0

This document defines the command interface for the Delivery Director to interact with the Product Owner.

---

## Overview

The Delivery Director (DD) issues commands to the Product Owner (PO) for status, control, and escalation handling. Commands are processed immediately by the PO.

---

## Command Summary

| Command | Description | Scope |
|---------|-------------|-------|
| STATUS | Get current execution status | Read |
| PAUSE | Pause all execution | Control |
| RESUME | Resume paused execution | Control |
| DETAIL | Get detailed task status | Read |
| ESCALATIONS | List pending escalations | Read |
| RESPOND | Respond to escalation | Action |
| OVERRIDE | Override PO decision | Control |
| SKIP | Skip a blocked task | Control |
| ABORT | Abort current phase | Control |

---

## Command Details

### STATUS

Get current execution status overview.

**Usage:**
```
STATUS
```

**Response:**
```
=== Execution Status ===

Mode: v20 Autonomous
Phase: PHASE-01
State: RUNNING

Agents:
  Active: 3
  Completed: 5
  Blocked: 1

Tasks:
  Completed: 8/15
  In Progress: 3
  Pending: 4

Escalations:
  Pending: 1 (BLOCKING)

Last Activity: 2 minutes ago
```

---

### PAUSE

Pause all execution immediately.

**Usage:**
```
PAUSE
```

**Effect:**
- Running agents complete current step
- No new agents spawned
- No new GO gates issued
- State preserved for resume

**Response:**
```
Execution PAUSED

Active agents: 3
  - agent-a1b2c3d4 (TASK-001): completing current step
  - agent-e5f6g7h8 (TASK-002): completing current step
  - agent-i9j0k1l2 (TASK-003): completing current step

State saved. Use RESUME to continue.
```

---

### RESUME

Resume paused execution.

**Usage:**
```
RESUME
```

**Effect:**
- Execution continues from saved state
- Pending agents may be spawned
- GO/NEXT gates resume

**Response:**
```
Execution RESUMED

Continuing from: PHASE-01
Active agents: 3
Next in queue: TASK-004, TASK-005

Monitoring resumed.
```

---

### DETAIL

Get detailed status of a specific task.

**Usage:**
```
DETAIL TASK-001
```

**Response:**
```
=== Task Detail: TASK-001 ===

Status: implementing
Agent: agent-a1b2c3d4
Progress: 65%

Acceptance Criteria:
  [✓] AC-001: Login form created
  [✓] AC-002: Validation added
  [ ] AC-003: Error handling (in progress)
  [ ] AC-004: Redirect logic

Files Modified:
  - src/pages/LoginPage.tsx
  - src/services/authService.ts

Test Status:
  - Unit tests: pending
  - Regression: pending

Timeline:
  - Started: 10:00:00
  - GO issued: 10:05:00
  - Timeout: 10:35:00

Last Activity: "Writing error handling component"
```

---

### ESCALATIONS

List all pending escalations.

**Usage:**
```
ESCALATIONS
```

**Response:**
```
=== Pending Escalations ===

[1] ESC-001 (BLOCKING)
    Type: External Dependency
    Task: TASK-005
    Need: Stripe API key
    Created: 15 minutes ago

[2] ESC-002 (HIGH)
    Type: Strategic Decision
    Task: TASK-008
    Need: Auth provider choice (OAuth vs JWT)
    Created: 5 minutes ago

Use: RESPOND ESC-001 to respond
```

---

### RESPOND

Respond to a specific escalation.

**Usage:**
```
RESPOND ESC-001
```

This initiates interactive response flow:

```
=== Responding to ESC-001 ===

Type: External Dependency
Task: TASK-005
Description: Stripe API key required for payment integration

What the task needs:
- Stripe publishable key
- Stripe secret key

Options:
1. PROVIDE - Provide the required credentials
2. DEFER - Defer this task for later
3. SKIP - Skip this task entirely

Enter choice (or type response):
> PROVIDE

Enter STRIPE_PUBLISHABLE_KEY:
> pk_test_xxx

Enter STRIPE_SECRET_KEY:
> sk_test_xxx

Escalation resolved. Task TASK-005 unblocked.
```

---

### OVERRIDE

Override a PO decision.

**Usage:**
```
OVERRIDE
```

Interactive override:

```
=== Override PO Decision ===

Recent decisions:
1. GO issued for TASK-006 (5 min ago)
2. FIX issued for TASK-003 (10 min ago)
3. BLOCKED issued for TASK-002 (15 min ago)

Which decision to override? [1/2/3]:
> 3

Decision: BLOCKED for TASK-002
Reason: Max retries exceeded

Override options:
1. UNBLOCK - Allow another retry
2. SKIP - Skip task and continue
3. REASSIGN - Assign to different approach
4. CANCEL - Cancel override

Enter choice:
> 1

TASK-002 unblocked. Retry count reset.
Agent will be spawned with fresh context.
```

---

### SKIP

Skip a blocked or problematic task.

**Usage:**
```
SKIP TASK-002
```

**Response:**
```
=== Skip Task: TASK-002 ===

Current Status: blocked
Blocked Reason: Max retries exceeded

Skipping will:
- Mark task as SKIPPED (not completed)
- Allow dependent tasks to proceed
- Create technical debt record

Confirm skip? [y/n]:
> y

TASK-002 skipped.
Technical debt recorded in docs/execution/technical_debt.md
Dependent tasks unblocked: TASK-007, TASK-008
```

---

### ABORT

Abort current phase execution.

**Usage:**
```
ABORT
```

**Response:**
```
=== Abort Phase Execution ===

⚠️  WARNING: This will:
- Terminate all active agents
- Discard incomplete work
- Mark phase as ABORTED

Current status:
- Active agents: 3
- Completed tasks: 8
- In-progress tasks: 3

Type 'CONFIRM ABORT' to proceed:
> CONFIRM ABORT

Phase ABORTED

Cleanup:
- 3 agents terminated
- 3 worktrees cleaned up
- State saved for potential resume

To restart phase: Start new session and specify phase
```

---

## Command Skill

The PO processes commands via Skill DD-01:

**File:** `docs/skills/skill_dd_command_handler.md`

---

## Response Formats

### Success Response

```json
{
  "command": "STATUS",
  "status": "success",
  "timestamp": "ISO8601",
  "data": { ... }
}
```

### Error Response

```json
{
  "command": "SKIP",
  "status": "error",
  "timestamp": "ISO8601",
  "error": {
    "code": "TASK_NOT_FOUND",
    "message": "Task TASK-999 does not exist"
  }
}
```

---

## Command Permissions

| Command | Requires | Effect |
|---------|----------|--------|
| STATUS | None | Read-only |
| PAUSE | None | Stops new work |
| RESUME | Paused state | Continues work |
| DETAIL | None | Read-only |
| ESCALATIONS | None | Read-only |
| RESPOND | Pending escalation | Resolves escalation |
| OVERRIDE | None | Changes PO decision |
| SKIP | Blocked task | Creates tech debt |
| ABORT | None | Terminates phase |

---

## Related Documentation

- [Delivery Director Contract](../roles/delivery_director.md)
- [Product Owner Contract](../roles/product_owner.md)
- [Escalation System](escalation_classification.md)
