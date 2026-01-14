# State Files Guide for Delivery Directors

**Version:** 20.0

This guide explains the state files used in v20 and how to read them for debugging.

---

## Quick Reference

| File | Purpose | Safe to Read? | Safe to Edit? |
|------|---------|---------------|---------------|
| `.factory/execution/orchestrator_state.json` | PO runtime state | Yes | **No** |
| `.factory/execution/agent_registry.json` | Active agent tracking | Yes | **No** |
| `.factory/execution/escalation_queue.json` | Pending escalations | Yes | **No** |
| `docs/execution/state.md` | Human-readable status | Yes | Yes (notes only) |
| `docs/execution/progress.json` | Task progress tracking | Yes | **No** |

**Rule:** Never edit JSON files in `.factory/execution/`. PO manages these automatically.

---

## Orchestrator State

**Location:** `.factory/execution/orchestrator_state.json`

### What It Contains

```json
{
  "version": "20.0",
  "role": "PRODUCT_OWNER",
  "session_id": "sess_abc123",
  "current_phase": "PHASE-01",
  "execution_mode": "autonomous",
  "active_batch": "BATCH-003",
  "agents": {
    "active": 2,
    "completed": 5,
    "failed": 0,
    "blocked": 1
  },
  "escalations": {
    "pending": 1,
    "blocking": true
  },
  "statistics": {
    "tasks_completed": 5,
    "tasks_blocked": 1,
    "tasks_skipped": 0,
    "retries_issued": 2,
    "go_gates_issued": 6,
    "next_gates_issued": 5
  },
  "paused": false,
  "started_at": "2026-01-14T10:00:00Z",
  "last_updated": "2026-01-14T11:30:00Z"
}
```

### Key Fields Explained

| Field | What It Means |
|-------|---------------|
| `current_phase` | Which phase is executing |
| `agents.active` | How many tasks are running right now |
| `agents.blocked` | Tasks that failed and need attention |
| `escalations.blocking` | If `true`, execution is paused waiting for you |
| `paused` | If `true`, you issued PAUSE command |
| `last_updated` | When state was last modified |

### When to Check

- Execution seems stuck → Check `paused` and `escalations.blocking`
- Want to know progress → Check `statistics.tasks_completed`
- Suspect crash → Check `last_updated` timestamp

---

## Agent Registry

**Location:** `.factory/execution/agent_registry.json`

### What It Contains

```json
{
  "version": "20.0",
  "agents": [
    {
      "agent_id": "agent-001",
      "task_id": "TASK-003",
      "status": "implementing",
      "worktree": "../worktrees/agent-001",
      "started_at": "2026-01-14T11:00:00Z",
      "last_heartbeat": "2026-01-14T11:28:00Z"
    },
    {
      "agent_id": "agent-002",
      "task_id": "TASK-005",
      "status": "testing",
      "worktree": "../worktrees/agent-002",
      "started_at": "2026-01-14T11:15:00Z",
      "last_heartbeat": "2026-01-14T11:29:00Z"
    }
  ],
  "last_updated": "2026-01-14T11:30:00Z"
}
```

### Agent Statuses

| Status | Meaning |
|--------|---------|
| `initializing` | Agent starting up |
| `planning` | Agent creating implementation plan |
| `implementing` | Agent writing code |
| `testing` | Agent running tests |
| `reporting` | Agent writing completion report |
| `completed` | Agent finished successfully |
| `failed` | Agent failed after retries |
| `blocked` | Agent waiting on dependency |

### When to Check

- Want to know what's actually happening → Check agent statuses
- Agent seems stuck → Check `last_heartbeat` (stale = problem)
- Need to debug specific task → Find agent by `task_id`

---

## Escalation Queue

**Location:** `.factory/execution/escalation_queue.json`

### What It Contains

```json
{
  "version": "20.0",
  "escalations": [
    {
      "escalation_id": "ESC-001",
      "type": "external_dependency",
      "severity": "BLOCKING",
      "task_id": "TASK-003",
      "title": "Stripe API key needed",
      "description": "Payment integration requires Stripe secret key",
      "created_at": "2026-01-14T11:00:00Z",
      "status": "pending"
    }
  ],
  "last_updated": "2026-01-14T11:30:00Z"
}
```

### Escalation Fields

| Field | What It Means |
|-------|---------------|
| `severity` | BLOCKING, HIGH, MEDIUM, or INFO |
| `type` | external_dependency, strategic_decision, clarification, info |
| `status` | pending, responded, resolved, deferred |
| `task_id` | Which task is waiting on this |

### When to Check

- Execution paused → Look for `severity: BLOCKING` with `status: pending`
- Planning responses → See what's been resolved recently

---

## Human-Readable State

**Location:** `docs/execution/state.md`

### What It Contains

A markdown file with current execution status, updated by PO after significant events.

```markdown
# Execution State

**Last Updated:** 2026-01-14 11:30:00 UTC
**Phase:** PHASE-01
**Status:** RUNNING

## Progress

- Tasks Completed: 5/12
- Tasks In Progress: 2
- Tasks Blocked: 1

## Active Work

| Task | Agent | Status |
|------|-------|--------|
| TASK-003 | agent-001 | Implementing |
| TASK-005 | agent-002 | Testing |

## Pending Escalations

- ESC-001: Stripe API key needed (BLOCKING)

## Notes

[Your notes here - safe to edit this section]
```

### When to Use

- Quick status check without parsing JSON
- Adding your own notes about execution
- Sharing status with team members

---

## Progress Tracking

**Location:** `docs/execution/progress.json`

### What It Contains

```json
{
  "phase": "PHASE-01",
  "total_tasks": 12,
  "completed": 5,
  "in_progress": 2,
  "blocked": 1,
  "pending": 4,
  "skipped": 0,
  "percent_complete": 41.7,
  "last_updated": "2026-01-14T11:30:00Z"
}
```

### When to Check

- Progress reporting → Get percentage complete
- Estimating time remaining → Compare completed vs. total

---

## Debugging Common Issues

### "Execution is stuck"

1. Check orchestrator_state.json:
   ```bash
   cat .factory/execution/orchestrator_state.json | grep -E "paused|blocking"
   ```

2. If `paused: true` → Issue `RESUME`
3. If `blocking: true` → Check escalation_queue.json and respond

### "Agent not making progress"

1. Find the agent in agent_registry.json
2. Check `last_heartbeat` - if > 10 minutes old, agent may be stuck
3. Check `status` - if stuck in same status, consider SKIP

### "State seems wrong"

1. Check `last_updated` timestamps across all files
2. If timestamps are old, PO may have crashed
3. Start new session - PO will recover and update state

---

## File Locations Summary

```
.factory/
├── execution/
│   ├── orchestrator_state.json    ← Main PO state
│   ├── agent_registry.json        ← Active agents
│   ├── escalation_queue.json      ← Pending escalations
│   ├── parallel_batches/          ← Batch execution data
│   ├── history/                   ← State snapshots
│   └── go_gates/                  ← GO gate records
├── agent_progress/                ← Per-agent progress files
└── V20_MODE                       ← v20 activation marker

docs/execution/
├── state.md                       ← Human-readable state
├── progress.json                  ← Progress tracking
└── dd_reports/                    ← Phase completion reports
```

---

## Related Documentation

- [Orchestrator State Schema](orchestrator_state.md)
- [Disaster Recovery](dd_disaster_recovery.md)
- [V20 User Guide](../V20_USER_GUIDE.md)
