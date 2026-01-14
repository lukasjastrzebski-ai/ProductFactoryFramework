# PO Startup Protocol

**Version:** 20.0

This document defines the startup protocol for the Product Owner in v20 autonomous mode.

---

## Overview

When the Product Owner (PO) starts a session in v20 mode, it must complete a structured initialization process before beginning execution.

---

## Startup Sequence

```
┌──────────────────────────────────────────────────────────────┐
│                    PO STARTUP SEQUENCE                        │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Step 1: VERIFY MODE                                          │
│  ├─ Check .factory/V20_MODE exists                           │
│  ├─ Verify factory version >= 20.0                           │
│  └─ Confirm planning frozen                                   │
│                                                               │
│  Step 2: CHECK EXISTING STATE                                 │
│  ├─ Check for ORCHESTRATOR_ACTIVE (stale session?)           │
│  ├─ Load docs/execution/state.md                             │
│  └─ Load .factory/execution/orchestrator_state.json          │
│                                                               │
│  Step 3: LOAD ARTIFACTS                                       │
│  ├─ Read docs/ai.md (binding contract)                       │
│  ├─ Read CLAUDE.md (operating contract)                      │
│  ├─ Load plan/phases/ (phase definitions)                    │
│  └─ Load plan/tasks/ (task definitions)                      │
│                                                               │
│  Step 4: INITIALIZE STATE                                     │
│  ├─ Create/update orchestrator_state.json                    │
│  ├─ Create ORCHESTRATOR_ACTIVE marker                        │
│  ├─ Initialize agent_registry.json                           │
│  └─ Initialize escalation_queue.json                         │
│                                                               │
│  Step 5: ANALYZE WORK                                         │
│  ├─ Identify current phase                                   │
│  ├─ Run dependency analysis                                  │
│  ├─ Build execution graph                                    │
│  └─ Identify first parallel group                            │
│                                                               │
│  Step 6: REPORT READY                                         │
│  ├─ Generate init report                                     │
│  └─ Report status to DD if present                           │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Step Details

### Step 1: Verify Mode

Before anything else, verify the factory is configured for v20 operation.

**Checks:**
1. `.factory/V20_MODE` file exists
2. `.factory/factory_version.txt` contains "20.0" or higher
3. `.factory/PLANNING_FROZEN` exists
4. `.factory/STAGE_7_COMPLETE` exists

**On Failure:**
- If v20 mode not enabled: Fall back to v10.x compatibility mode
- If planning not frozen: ERROR - cannot proceed

### Step 2: Check Existing State

Determine if this is a fresh start or continuation.

**Scenarios:**
1. **Fresh Start:** No orchestrator_state.json exists
2. **Resume:** State exists, check for incomplete work
3. **Stale Session:** ORCHESTRATOR_ACTIVE exists but session is old

**Stale Session Handling:**
- If ORCHESTRATOR_ACTIVE timestamp > 24 hours: Consider stale
- Clear stale markers before proceeding
- Log warning about potential orphaned agents

### Step 3: Load Artifacts

Load all planning artifacts into memory/context.

**Required Files:**
- `docs/ai.md` - Binding contract (role definitions, authorities)
- `CLAUDE.md` - Operating contract (procedures, quick reference)
- `docs/execution/state.md` - Current execution state

**Phase and Task Loading:**
- Enumerate all files in `plan/phases/`
- Enumerate all files in `plan/tasks/`
- Parse task metadata (dependencies, files, test delta)

### Step 4: Initialize State

Create or update runtime state files.

**orchestrator_state.json:**
```json
{
  "version": "20.0",
  "role": "PRODUCT_OWNER",
  "session_id": "{uuid}",
  "current_phase": "PHASE-XX",
  "execution_mode": "autonomous",
  "active_batch": null,
  "agents": {
    "active": 0,
    "completed": 0,
    "failed": 0
  },
  "escalations": {
    "pending": 0,
    "blocking": false
  },
  "statistics": {
    "tasks_completed": 0,
    "tasks_blocked": 0,
    "retries_issued": 0,
    "go_gates_issued": 0,
    "next_gates_issued": 0
  },
  "paused": false,
  "started_at": "ISO8601",
  "last_updated": "ISO8601"
}
```

**ORCHESTRATOR_ACTIVE marker:**
```json
{
  "started_at": "ISO8601",
  "session_id": "{uuid}",
  "phase": "PHASE-XX"
}
```

### Step 5: Analyze Work

Build the execution plan for the current phase.

**Actions:**
1. Determine current phase from state
2. Run `scripts/po/analyze_dependencies.py --phase PHASE-XX`
3. Load execution graph from `.factory/execution_graph.json`
4. Identify tasks ready for execution (no pending dependencies)

### Step 6: Report Ready

Confirm initialization and report status.

**Generate Report:**
- Create `docs/execution/reports/PO-INIT-{timestamp}.md`
- Include: mode, phase, pending tasks, any issues

**Report to DD:**
- If DD is present in session, provide summary
- Include any pending escalations from previous session

---

## Script Usage

Run the initialization script:

```bash
./scripts/po/init_po.sh
```

**Output:**
- Creates/updates state files
- Generates init report
- Prints status summary

---

## Error Handling

### Missing Prerequisites

```
ERROR: v20 mode not enabled
ACTION: Create .factory/V20_MODE or use v10.x mode
```

### Stale Session Detected

```
WARNING: Stale orchestrator session detected
ACTION: Clearing stale markers, checking for orphaned work
```

### Incomplete Previous Session

```
WARNING: Previous session incomplete
ACTION: Resuming from last known state
TASKS: [list of incomplete tasks]
```

---

## Post-Startup

After successful startup, the PO should:

1. **If DD present:** Report status and await instructions
2. **If autonomous:** Begin execution loop automatically
3. **If blocked:** Report blockers and pause

---

## Related Documentation

- [Product Owner Contract](../roles/product_owner.md)
- [Task Runner](task_runner.md)
- [GO Gate](po_go_gate.md)
- [Dependency Analysis](dependency_analysis.md)
