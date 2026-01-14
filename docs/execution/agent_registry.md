# Agent Registry

**Version:** 20.0

This document describes the Agent Registry system for tracking parallel Task Agents.

---

## Overview

The Agent Registry is a central record of all spawned Task Agents, their status, and their assignments. The PO uses this registry to manage parallel execution.

---

## Registry Location

```
.factory/execution/agent_registry.json
```

---

## Registry Schema

```json
{
  "version": "20.0",
  "agents": [
    {
      "agent_id": "agent-{uuid}",
      "task_id": "TASK-XXX",
      "worktree_path": "../worktrees/agent-xxx-TASK-XXX",
      "assignment_file": ".factory/agent_progress/agent-xxx_assignment.json",
      "status": "active",
      "spawned_at": "ISO8601",
      "timeout_at": "ISO8601",
      "retry_count": 0,
      "last_progress": "ISO8601",
      "go_issued_at": null,
      "completed_at": null,
      "blocked_at": null,
      "blocked_reason": null
    }
  ],
  "last_updated": "ISO8601"
}
```

---

## Agent Status Lifecycle

```
                    ┌─────────┐
                    │  spawn  │
                    └────┬────┘
                         │
                         ▼
                    ┌─────────┐
           ┌───────│  active │───────┐
           │       └────┬────┘       │
           │            │            │
           ▼            ▼            ▼
    ┌───────────┐ ┌───────────┐ ┌─────────┐
    │researching│ │ planning  │ │awaiting │
    └─────┬─────┘ └─────┬─────┘ │   go    │
          │             │       └────┬────┘
          └─────────────┼────────────┘
                        │
                        ▼ (GO received)
               ┌─────────────────┐
               │  implementing   │
               └────────┬────────┘
                        │
                        ▼
               ┌─────────────────┐
               │    testing      │
               └────────┬────────┘
                        │
                        ▼
               ┌─────────────────┐
               │   reporting     │
               └────────┬────────┘
                        │
                        ▼
               ┌─────────────────┐
               │ awaiting_next   │
               └────────┬────────┘
                        │
          ┌─────────────┼─────────────┐
          │             │             │
          ▼             ▼             ▼
    ┌──────────┐  ┌──────────┐  ┌──────────┐
    │ completed │  │  fixing  │  │ blocked  │
    └──────────┘  └────┬─────┘  └──────────┘
                       │
                       └───► (back to implementing or testing)
```

---

## Status Definitions

| Status | Description | Next States |
|--------|-------------|-------------|
| active | Just spawned | researching |
| researching | Reading specs and code | planning |
| planning | Creating implementation plan | awaiting_go |
| awaiting_go | Submitted plan, waiting for PO | implementing, planning |
| implementing | Writing code after GO | testing |
| testing | Running tests | reporting |
| reporting | Generating completion report | awaiting_next |
| awaiting_next | Submitted report, waiting for PO | completed, fixing, blocked |
| fixing | Addressing FIX feedback | implementing, testing |
| completed | Task finished successfully | (terminal) |
| blocked | Cannot proceed | (terminal) |
| failed | Error or timeout | (terminal) |

---

## Registry Operations

### Add Agent

```bash
# Via script
./scripts/agents/spawn_agent.sh --task TASK-001
```

Adds entry:
```json
{
  "agent_id": "agent-new",
  "task_id": "TASK-001",
  "status": "active",
  "spawned_at": "now"
}
```

### Update Status

```bash
# Via progress script
./scripts/agents/report_progress.sh \
    --agent agent-xxx \
    --status implementing
```

Updates:
```json
{
  "status": "implementing",
  "last_progress": "now"
}
```

### Complete Agent

When PO issues NEXT:
```json
{
  "status": "completed",
  "completed_at": "now"
}
```

### Block Agent

When PO issues BLOCKED:
```json
{
  "status": "blocked",
  "blocked_at": "now",
  "blocked_reason": "max_retries"
}
```

### Remove Agent

After cleanup:
```bash
# Remove from registry (agent entry deleted)
jq 'del(.agents[] | select(.agent_id == "agent-xxx"))' registry.json
```

---

## PO Queries

### Get Active Agents

```bash
jq '[.agents[] | select(.status == "active" or .status == "implementing")]' \
    .factory/execution/agent_registry.json
```

### Get Agent by Task

```bash
jq '.agents[] | select(.task_id == "TASK-001")' \
    .factory/execution/agent_registry.json
```

### Count by Status

```bash
jq '.agents | group_by(.status) | map({status: .[0].status, count: length})' \
    .factory/execution/agent_registry.json
```

### Check for Timeouts

```bash
# Find agents past timeout
jq --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   '[.agents[] | select(.timeout_at < $now and .status != "completed")]' \
    .factory/execution/agent_registry.json
```

### Check File Conflicts

```bash
# Get all files being modified by active agents
jq -r '.agents[] | select(.status | test("implementing|testing")) | .assignment_file' \
    .factory/execution/agent_registry.json | \
    xargs -I{} jq -r '.authorized_files[]' {}
```

---

## Concurrent Agent Limits

### Default Limits

| Metric | Limit |
|--------|-------|
| Max concurrent agents | 5 |
| Max agents per task | 1 |
| Max retry count | 2 |

### Checking Limits

```bash
# Active agent count
active=$(jq '[.agents[] | select(.status | test("active|implementing|testing"))] | length' \
    .factory/execution/agent_registry.json)

if [ "$active" -ge 5 ]; then
    echo "Max agents reached"
fi
```

---

## Timeout Handling

### Detection

PO periodically checks for timed-out agents:

```bash
# Every 5 minutes
for agent in $(jq -r '.agents[] | select(.timeout_at < "now" and .status != "completed") | .agent_id' registry.json); do
    # Handle timeout
    update_status "$agent" "failed" "timeout"
done
```

### Recovery

1. Mark agent as failed
2. Clean up worktree
3. Optionally retry with new agent

---

## Cleanup

### Remove Completed Agents

```bash
# Remove agents completed more than 1 hour ago
jq --arg cutoff "$(date -u -d '-1 hour' +%Y-%m-%dT%H:%M:%SZ)" \
   'del(.agents[] | select(.status == "completed" and .completed_at < $cutoff))' \
    .factory/execution/agent_registry.json
```

### Periodic Cleanup

Run during:
- PO startup
- After each phase
- Before spawning new agents

---

## Related Files

| File | Purpose |
|------|---------|
| agent_registry.json | Agent tracking |
| {agent-id}.json | Individual progress |
| {agent-id}_assignment.json | Task assignment |
| {agent-id}_spawn_result.json | Spawn metadata |

---

## Related Documentation

- [Agent Spawning](agent_spawning.md)
- [Agent Task Runner](agent_task_runner.md)
- [Worktree Isolation](worktree_isolation.md)
