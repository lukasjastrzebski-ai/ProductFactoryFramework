# Execution History

**Version:** 20.0

This document describes the execution history and audit trail system.

---

## Overview

The PO maintains a complete audit trail of all execution decisions and events. This enables debugging, recovery, and compliance.

---

## History Storage

### Location

```
.factory/execution/history/
├── 2026-01-14.json
├── 2026-01-15.json
└── ...
```

### Daily Log Format

```json
{
  "date": "2026-01-14",
  "session_id": "uuid",
  "events": [
    {
      "timestamp": "ISO8601",
      "type": "GO_GATE",
      "task_id": "TASK-001",
      "agent_id": "agent-xxx",
      "details": { ... }
    },
    {
      "timestamp": "ISO8601",
      "type": "NEXT_GATE",
      "task_id": "TASK-001",
      "agent_id": "agent-xxx",
      "details": { ... }
    }
  ],
  "summary": {
    "go_gates": 5,
    "next_gates": 4,
    "fix_directives": 1,
    "blocked": 0,
    "escalations": 1
  }
}
```

---

## Event Types

| Type | Description |
|------|-------------|
| PO_START | PO session started |
| PO_END | PO session ended |
| GO_GATE | GO issued to agent |
| NEXT_GATE | NEXT issued, task complete |
| FIX_DIRECTIVE | FIX issued, retry needed |
| BLOCKED | Task blocked |
| AGENT_SPAWN | Agent spawned |
| AGENT_TERMINATE | Agent terminated |
| ESCALATION_CREATE | Escalation created |
| ESCALATION_RESOLVE | Escalation resolved |
| DD_COMMAND | DD issued command |
| BATCH_START | Batch execution started |
| BATCH_COMPLETE | Batch execution complete |
| PHASE_COMPLETE | Phase completed |

---

## Event Details

### GO_GATE Event

```json
{
  "timestamp": "ISO8601",
  "type": "GO_GATE",
  "task_id": "TASK-001",
  "agent_id": "agent-xxx",
  "details": {
    "validation_result": "PASS",
    "authorized_files": ["src/auth.ts"],
    "timeout_minutes": 30
  }
}
```

### ESCALATION_CREATE Event

```json
{
  "timestamp": "ISO8601",
  "type": "ESCALATION_CREATE",
  "escalation_id": "ESC-001",
  "details": {
    "type": "EXTERNAL_DEPENDENCY",
    "priority": "BLOCKING",
    "affected_tasks": ["TASK-005"],
    "description": "Stripe API key needed"
  }
}
```

### DD_COMMAND Event

```json
{
  "timestamp": "ISO8601",
  "type": "DD_COMMAND",
  "command": "PAUSE",
  "details": {
    "previous_state": "RUNNING",
    "new_state": "PAUSED",
    "active_agents": 3
  }
}
```

---

## History Queries

### Get Today's Events

```bash
jq '.events' .factory/execution/history/$(date +%Y-%m-%d).json
```

### Get Events by Type

```bash
jq '[.events[] | select(.type == "GO_GATE")]' .factory/execution/history/2026-01-14.json
```

### Get Events for Task

```bash
jq '[.events[] | select(.task_id == "TASK-001")]' .factory/execution/history/2026-01-14.json
```

### Get Daily Summary

```bash
jq '.summary' .factory/execution/history/2026-01-14.json
```

---

## History Retention

| Type | Retention |
|------|-----------|
| Daily logs | 30 days |
| Summary data | 1 year |
| Critical events | Permanent |

---

## Recovery Use

### Find Last Good State

```bash
# Find last successful batch
jq '[.events[] | select(.type == "BATCH_COMPLETE" and .details.status == "completed")] | last' \
    .factory/execution/history/2026-01-14.json
```

### Replay Decisions

History enables understanding why decisions were made and what state led to issues.

---

## Related Documentation

- [Orchestrator State](orchestrator_state.md)
- [Batch Tracking](batch_tracking.md)
- [PO Reporting](po_reporting.md)
