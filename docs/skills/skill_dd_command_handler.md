# Skill DD-01: Command Handler

**Version:** 20.0
**Role:** Product Owner
**Purpose:** Process Delivery Director commands

---

## Overview

When the Delivery Director issues a command, the Product Owner processes it immediately using this skill. Commands take priority over ongoing orchestration work.

---

## Trigger

**When:** DD issues a recognized command

**Commands:**
- STATUS
- PAUSE
- RESUME
- DETAIL [task-id]
- ESCALATIONS
- RESPOND [esc-id]
- OVERRIDE
- SKIP [task-id]
- ABORT

---

## Processing Flow

```
Command Received
       │
       ▼
  ┌─────────────┐
  │   Parse     │
  │  Command    │
  └──────┬──────┘
         │
         ▼
  ┌─────────────┐
  │  Validate   │
  │   Input     │
  └──────┬──────┘
         │
         ▼
  ┌─────────────┐
  │   Execute   │
  │   Handler   │
  └──────┬──────┘
         │
         ▼
  ┌─────────────┐
  │  Generate   │
  │  Response   │
  └──────┬──────┘
         │
         ▼
  ┌─────────────┐
  │   Update    │
  │   State     │
  └─────────────┘
```

---

## Command Handlers

### STATUS Handler

```
1. Load orchestrator_state.json
2. Load agent_registry.json
3. Load escalation_queue.json
4. Calculate metrics:
   - Active agent count
   - Completed task count
   - Pending escalation count
5. Format response
6. Return to DD
```

### PAUSE Handler

```
1. Set orchestrator_state.paused = true
2. Update ORCHESTRATOR_ACTIVE marker
3. For each active agent:
   - Allow current step to complete
   - Block new steps
4. Block new agent spawning
5. Block new GO gates
6. Save state snapshot
7. Confirm to DD
```

### RESUME Handler

```
1. Verify paused state
2. Set orchestrator_state.paused = false
3. Load state snapshot
4. Resume agent monitoring
5. Resume GO/NEXT processing
6. Check for pending spawns
7. Confirm to DD
```

### DETAIL Handler

```
1. Parse task_id from command
2. Verify task exists
3. Load task from registry
4. If active agent:
   - Load progress file
   - Get current activity
5. Load AC verification status
6. Format detailed response
7. Return to DD
```

### ESCALATIONS Handler

```
1. Load escalation_queue.json
2. Filter to pending escalations
3. Sort by priority (BLOCKING first)
4. Format each escalation:
   - ID
   - Type
   - Affected task
   - Description
   - Age
5. Return list to DD
```

### RESPOND Handler

```
1. Parse escalation_id from command
2. Load escalation from queue
3. Present escalation details
4. Collect DD response:
   - PROVIDE: Get required data
   - DEFER: Set defer until
   - SKIP: Mark task skipped
5. Update escalation status
6. If PROVIDE:
   - Store credentials safely
   - Unblock affected task
7. If DEFER:
   - Update defer timestamp
   - Mark escalation deferred
8. If SKIP:
   - Mark task skipped
   - Record technical debt
9. Confirm resolution
```

### OVERRIDE Handler

```
1. Load recent PO decisions
2. Present to DD
3. Get decision to override
4. Present override options
5. Get DD choice
6. Execute override:
   - UNBLOCK: Reset retry count
   - SKIP: Skip task
   - REASSIGN: Change approach
7. Update state
8. Confirm override
```

### SKIP Handler

```
1. Parse task_id from command
2. Verify task exists
3. Verify task is blocked/problematic
4. Present skip impact:
   - Dependent tasks
   - Technical debt
5. Get DD confirmation
6. If confirmed:
   - Mark task SKIPPED
   - Record technical debt
   - Unblock dependents
7. Confirm skip
```

### ABORT Handler

```
1. Present warning
2. Show current status:
   - Active agents
   - Completed tasks
   - In-progress work
3. Require explicit confirmation
4. If confirmed:
   - Terminate all agents
   - Clean up worktrees
   - Mark phase ABORTED
   - Save state for recovery
5. Confirm abort
```

---

## Error Handling

### Unknown Command

```
ERROR: Unknown command 'FOOBAR'

Available commands:
  STATUS, PAUSE, RESUME, DETAIL, ESCALATIONS,
  RESPOND, OVERRIDE, SKIP, ABORT

Type a command or 'HELP' for details.
```

### Invalid Task ID

```
ERROR: Task 'TASK-999' not found

Active tasks:
  TASK-001, TASK-002, TASK-003

Use 'STATUS' to see all tasks.
```

### Invalid Escalation ID

```
ERROR: Escalation 'ESC-999' not found

Pending escalations:
  ESC-001, ESC-002

Use 'ESCALATIONS' to see all.
```

### State Conflict

```
ERROR: Cannot RESUME - execution not paused

Current state: RUNNING
Active agents: 3

No action needed.
```

---

## State Updates

After command processing:

```json
// orchestrator_state.json updates

// PAUSE
{ "paused": true }

// RESUME
{ "paused": false }

// OVERRIDE (unblock)
{
  "statistics": {
    "overrides_issued": "+1"
  }
}

// SKIP
{
  "statistics": {
    "tasks_skipped": "+1"
  }
}

// ABORT
{
  "current_phase": "ABORTED",
  "statistics": {
    "phases_aborted": "+1"
  }
}
```

---

## Response Templates

### Status Response

```
=== Execution Status ===

Mode: v20 Autonomous
Phase: {phase}
State: {state}

Agents:
  Active: {active}
  Completed: {completed}
  Blocked: {blocked}

Tasks:
  Completed: {done}/{total}
  In Progress: {progress}
  Pending: {pending}

Escalations:
  Pending: {esc_count} ({esc_severity})

Last Activity: {time_ago}
```

### Error Response

```
ERROR: {error_message}

{helpful_context}

{suggestion}
```

---

## Related Documentation

- [DD Commands Reference](../execution/dd_commands.md)
- [Delivery Director Contract](../roles/delivery_director.md)
- [Escalation System](../execution/escalation_classification.md)
