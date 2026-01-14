# Agent Spawning

**Version:** 20.0

This document describes how the Product Owner spawns Task Agents for parallel execution.

---

## Overview

In v20 mode, the PO spawns multiple Task Agents to execute tasks in parallel. Each agent operates in an isolated git worktree with a dedicated assignment.

---

## Spawning Process

```
┌──────────────────────────────────────────────────────────────┐
│                    AGENT SPAWNING PROCESS                     │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  1. CHECK PREREQUISITES                                       │
│     ├─ v20 mode enabled?                                     │
│     ├─ Orchestrator active?                                  │
│     ├─ Agent slots available?                                │
│     └─ Task ready for execution?                             │
│                                                               │
│  2. CREATE WORKTREE                                           │
│     ├─ Generate agent ID                                     │
│     ├─ Create worktree from main                            │
│     └─ Create agent branch                                  │
│                                                               │
│  3. CREATE ASSIGNMENT                                         │
│     ├─ Task specification                                    │
│     ├─ Authorized files                                      │
│     ├─ Test delta                                            │
│     └─ Timeout settings                                      │
│                                                               │
│  4. REGISTER AGENT                                            │
│     ├─ Add to agent registry                                │
│     ├─ Create progress file                                  │
│     └─ Record spawn event                                    │
│                                                               │
│  5. START AGENT                                               │
│     └─ Agent begins task intake                             │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### v20 Mode

```bash
test -f .factory/V20_MODE
```

### Orchestrator Active

```bash
test -f .factory/ORCHESTRATOR_ACTIVE
```

### Agent Slots

```bash
# Max 5 concurrent agents (configurable)
active_agents=$(jq '[.agents[] | select(.status == "active")] | length' \
    .factory/execution/agent_registry.json)
[ "$active_agents" -lt 5 ]
```

### Task Ready

- All dependencies completed (have NEXT gate)
- No file conflicts with active agents
- Task not already assigned

---

## Agent ID Generation

Format: `agent-{uuid-prefix}`

```bash
# Example IDs
agent-a1b2c3d4
agent-e5f6g7h8
```

---

## Worktree Creation

Each agent gets an isolated git worktree:

```bash
# Directory structure
../worktrees/
├── agent-a1b2c3d4-TASK-001/
│   └── (full repository copy)
├── agent-e5f6g7h8-TASK-002/
│   └── (full repository copy)
└── ...
```

### Branch Naming

```
agent/{agent-id}/{task-id}
```

Example: `agent/agent-a1b2c3d4/TASK-001`

---

## Task Assignment

### Assignment JSON Schema

```json
{
  "task_id": "TASK-XXX",
  "agent_id": "agent-{uuid}",
  "worktree_path": "../worktrees/agent-xxx-TASK-XXX",
  "spec_reference": "specs/features/feature.md",
  "task_file": "plan/tasks/TASK-XXX.md",
  "acceptance_criteria": [
    {
      "id": "AC-001",
      "description": "User can log in with valid credentials",
      "testable": true
    }
  ],
  "test_delta": {
    "add": ["tests/login.test.ts"],
    "update": [],
    "regression": ["npm test"]
  },
  "authorized_files": [
    "src/pages/LoginPage.tsx",
    "src/services/authService.ts",
    "tests/login.test.ts"
  ],
  "dependencies": ["TASK-001"],
  "timeout_minutes": 30,
  "max_retries": 2,
  "assigned_at": "2026-01-14T10:00:00Z"
}
```

### File Location

```
.factory/agent_progress/{agent-id}_assignment.json
```

---

## Agent Registry

### Registry Schema

```json
{
  "version": "20.0",
  "agents": [
    {
      "agent_id": "agent-a1b2c3d4",
      "task_id": "TASK-001",
      "worktree_path": "../worktrees/agent-a1b2c3d4-TASK-001",
      "assignment_file": ".factory/agent_progress/agent-a1b2c3d4_assignment.json",
      "status": "active",
      "spawned_at": "2026-01-14T10:00:00Z",
      "timeout_at": "2026-01-14T10:30:00Z",
      "retry_count": 0,
      "last_progress": "2026-01-14T10:05:00Z"
    }
  ],
  "last_updated": "2026-01-14T10:00:00Z"
}
```

### Agent Statuses

| Status | Description |
|--------|-------------|
| active | Agent spawned and running |
| researching | Agent researching codebase |
| planning | Agent creating implementation plan |
| awaiting_go | Agent waiting for GO gate |
| implementing | Agent implementing after GO |
| testing | Agent running tests |
| reporting | Agent generating report |
| awaiting_next | Agent waiting for NEXT gate |
| fixing | Agent fixing issues after FIX |
| completed | Agent finished successfully |
| blocked | Agent blocked, cannot proceed |
| failed | Agent failed (error/timeout) |

---

## Progress Tracking

### Progress File Schema

```json
{
  "agent_id": "agent-a1b2c3d4",
  "task_id": "TASK-001",
  "status": "implementing",
  "progress_percent": 50,
  "current_activity": "Writing login form component",
  "files_modified": [
    "src/pages/LoginPage.tsx"
  ],
  "issues": [],
  "created_at": "2026-01-14T10:00:00Z",
  "last_updated": "2026-01-14T10:15:00Z"
}
```

### Progress Updates

Agents report progress every 5 minutes via:

```bash
./scripts/agents/report_progress.sh \
    --agent agent-a1b2c3d4 \
    --status implementing \
    --percent 50 \
    --activity "Writing login form component"
```

---

## Script Usage

### Spawn Agent

```bash
./scripts/agents/spawn_agent.sh \
    --task TASK-001 \
    --timeout 30
```

### With Custom Assignment

```bash
./scripts/agents/spawn_agent.sh \
    --task TASK-001 \
    --assignment /path/to/assignment.json
```

### Dry Run

```bash
./scripts/agents/spawn_agent.sh \
    --task TASK-001 \
    --dry-run
```

---

## Resource Management

### Max Concurrent Agents

Default: 5 agents

Configure via orchestrator state:
```json
{
  "config": {
    "max_concurrent_agents": 5
  }
}
```

### Timeout Handling

- Default: 30 minutes per task
- Configurable per task in assignment
- On timeout: Agent marked as failed

### Memory/Context

- Each agent has independent context
- Fresh context on retry (after first attempt)
- No context sharing between agents

---

## Error Handling

### Spawn Failures

| Error | Cause | Resolution |
|-------|-------|------------|
| Max agents reached | 5 agents active | Wait for completion |
| Worktree exists | Previous spawn incomplete | Clean up and retry |
| Branch conflict | Branch name in use | Use unique agent ID |
| Git error | Repository issues | Check git status |

### Agent Failures

| Error | Cause | Resolution |
|-------|-------|------------|
| Timeout | Task took too long | Mark blocked, notify PO |
| Crash | Unexpected error | Log error, notify PO |
| Stuck | No progress update | Force terminate, retry |

---

## Related Documentation

- [Worktree Manager](worktree_isolation.md)
- [Task Assignment Protocol](task_assignment.md)
- [Agent Task Runner](agent_task_runner.md)
- [Agent Registry](agent_registry.md)
