# Parallel Batch Tracking

**Version:** 20.0

This document describes tracking of parallel execution batches.

---

## Overview

The PO groups independent tasks into batches for parallel execution. Each batch is tracked separately with its own state and metrics.

---

## Batch Structure

### Batch File

**Location:** `.factory/execution/parallel_batches/BATCH-XXX.json`

```json
{
  "batch_id": "BATCH-001",
  "phase": "PHASE-01",
  "created_at": "ISO8601",
  "started_at": "ISO8601",
  "completed_at": null,
  "status": "running",
  "tasks": [
    {
      "task_id": "TASK-001",
      "agent_id": "agent-xxx",
      "status": "completed",
      "started_at": "ISO8601",
      "completed_at": "ISO8601"
    },
    {
      "task_id": "TASK-002",
      "agent_id": "agent-yyy",
      "status": "implementing",
      "started_at": "ISO8601",
      "completed_at": null
    }
  ],
  "barrier_after": true,
  "max_agents": 5,
  "metrics": {
    "planned_tasks": 3,
    "completed_tasks": 1,
    "failed_tasks": 0,
    "total_duration": null
  }
}
```

---

## Batch Lifecycle

```
CREATE    → PENDING
START     → RUNNING
COMPLETE  → COMPLETED | PARTIAL | FAILED

States:
  PENDING   - Batch created, not started
  RUNNING   - Tasks being executed
  COMPLETED - All tasks finished successfully
  PARTIAL   - Some tasks blocked/failed
  FAILED    - Critical failure, batch aborted
```

---

## Batch Operations

### Create Batch

```
create_batch(tasks):
  batch_id = generate_batch_id()
  batch = {
    batch_id: batch_id,
    tasks: tasks,
    status: "pending",
    created_at: now()
  }
  save_batch(batch)
  return batch_id
```

### Start Batch

```
start_batch(batch_id):
  batch = load_batch(batch_id)
  batch.status = "running"
  batch.started_at = now()

  FOR each task in batch.tasks:
    spawn_agent(task)
    task.status = "active"

  save_batch(batch)
```

### Complete Batch

```
complete_batch(batch_id):
  batch = load_batch(batch_id)

  IF all tasks completed:
    batch.status = "completed"
  ELSE IF any tasks blocked:
    batch.status = "partial"
  ELSE IF critical failure:
    batch.status = "failed"

  batch.completed_at = now()
  calculate_metrics(batch)
  save_batch(batch)
```

---

## Barrier Behavior

### With Barrier (default)

```
barrier_after: true

Execution:
  [BATCH-001] → WAIT → [BATCH-002] → WAIT → [BATCH-003]

All tasks in batch must complete before next batch starts.
```

### Without Barrier

```
barrier_after: false

Execution:
  [BATCH-001 tasks...] → [start BATCH-002 as agents free]

Tasks from next batch can start as agents become available.
```

---

## Batch Metrics

| Metric | Description |
|--------|-------------|
| planned_tasks | Tasks in batch |
| completed_tasks | Successfully completed |
| failed_tasks | Blocked or failed |
| total_duration | Time from start to complete |
| agent_hours | Sum of agent execution times |
| parallel_efficiency | completed / (duration * agents) |

---

## Batch Directory

```
.factory/execution/parallel_batches/
├── BATCH-001.json
├── BATCH-002.json
├── BATCH-003.json
└── ...
```

---

## Batch Queries

### Get Current Batch

```bash
jq '.active_batch' .factory/execution/orchestrator_state.json
```

### List All Batches

```bash
ls -la .factory/execution/parallel_batches/
```

### Get Batch Status

```bash
jq '.status' .factory/execution/parallel_batches/BATCH-001.json
```

---

## Related Documentation

- [Dependency Analysis](dependency_analysis.md)
- [Orchestrator State](orchestrator_state.md)
- [Agent Spawning](agent_spawning.md)
