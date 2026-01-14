# Orchestrator State Management

**Version:** 20.0

This document describes the PO's internal state management system.

---

## Overview

The Product Owner maintains state in JSON files to track execution progress, manage agents, and enable recovery from interruptions.

---

## State Files

### Primary State

**File:** `.factory/execution/orchestrator_state.json`

```json
{
  "version": "20.0",
  "role": "PRODUCT_OWNER",
  "session_id": "uuid",
  "current_phase": "PHASE-01",
  "execution_mode": "autonomous",
  "active_batch": "BATCH-001",
  "agents": {
    "active": 3,
    "completed": 5,
    "failed": 0,
    "blocked": 1
  },
  "escalations": {
    "pending": 1,
    "blocking": true
  },
  "statistics": {
    "tasks_completed": 8,
    "tasks_blocked": 1,
    "tasks_skipped": 0,
    "retries_issued": 3,
    "go_gates_issued": 12,
    "next_gates_issued": 8
  },
  "paused": false,
  "started_at": "ISO8601",
  "last_updated": "ISO8601"
}
```

### Agent Registry

**File:** `.factory/execution/agent_registry.json`

See [Agent Registry](agent_registry.md) for schema.

### Escalation Queue

**File:** `.factory/execution/escalation_queue.json`

See [Escalation Queue](escalation_queue.md) for schema.

---

## State Updates

### Update Triggers

State is updated after:
- PO startup
- Agent spawn
- GO gate issued
- NEXT gate issued
- FIX issued
- Task blocked
- Escalation created
- Escalation resolved
- Phase complete
- DD command processed

### Atomic Updates

```
update_state(changes):
  1. Read current state
  2. Apply changes
  3. Update timestamp
  4. Write to temp file
  5. Rename temp to state file
  6. Confirm write
```

---

## State Recovery

### On PO Restart

```
recover_state():
  1. Check ORCHESTRATOR_ACTIVE marker
  2. Load orchestrator_state.json
  3. Load agent_registry.json
  4. Check for stale agents
  5. Resume from last known state
```

### Stale Session Detection

```
IF ORCHESTRATOR_ACTIVE exists:
  IF timestamp > 24 hours:
    MARK as stale
    CLEAR marker
    CHECK for orphaned agents
```

### Orphaned Agent Cleanup

```
FOR each agent in registry:
  IF status == active AND no recent progress:
    MARK as orphaned
    CLEAN worktree
    UPDATE status to failed
```

---

## State Consistency

### Invariants

1. `tasks_completed + tasks_blocked + tasks_in_progress = tasks_started`
2. `go_gates_issued >= next_gates_issued`
3. `agents.active <= max_agents`
4. If `paused == true`, no new GO gates issued

### Validation

```
validate_state():
  CHECK invariants
  CHECK timestamps are valid
  CHECK IDs are consistent
  RETURN valid | invalid
```

---

## State Persistence

### Write Schedule

- **Synchronous:** After every significant action
- **Periodic:** Every 5 minutes during execution
- **On exit:** Before PO terminates

### Backup

```
.factory/execution/
├── orchestrator_state.json          # Current
├── orchestrator_state.json.backup   # Previous
└── orchestrator_state.json.bak2     # Older
```

---

## Metrics Tracking

### Execution Metrics

| Metric | Tracked In | Updated When |
|--------|------------|--------------|
| Tasks completed | statistics | NEXT issued |
| Tasks blocked | statistics | BLOCKED issued |
| Retry rate | statistics | FIX issued |
| Agent hours | derived | Agent complete |

### Performance Metrics

| Metric | Formula |
|--------|---------|
| First-pass rate | (completed - retried) / completed |
| Parallel efficiency | parallel_tasks / total_tasks |
| Agent utilization | agent_hours / total_hours |

---

## Related Documentation

- [PO Startup](po_startup.md)
- [Agent Registry](agent_registry.md)
- [Batch Tracking](batch_tracking.md)
