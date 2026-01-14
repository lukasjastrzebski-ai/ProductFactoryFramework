# Pause and Resume

**Version:** 20.0

This document describes the pause and resume system for execution control.

---

## Overview

The PO can pause execution (automatically or via DD command) and resume later. This enables handling critical escalations, DD unavailability, or emergency stops.

---

## Pause Triggers

### Automatic Pause

| Trigger | Priority |
|---------|----------|
| BLOCKING escalation created | Immediate |
| Critical error detected | Immediate |
| All agents blocked | Automatic |

### Manual Pause

| Trigger | Command |
|---------|---------|
| DD requests pause | PAUSE |
| Maintenance needed | PAUSE |
| Review required | PAUSE |

---

## Pause Process

```
pause_execution():
  1. Set orchestrator_state.paused = true
  2. Update ORCHESTRATOR_ACTIVE marker

  3. For each active agent:
     a. Allow current step to complete
     b. Block starting new steps
     c. Save progress

  4. Block:
     - New agent spawning
     - New GO gates
     - New batch starts

  5. Allow:
     - Progress reporting
     - Report submission
     - Status queries

  6. Save state snapshot
  7. Notify DD if not DD-initiated
```

---

## Paused State Behavior

### What Continues

- Active agents complete current step
- Progress updates still processed
- Completion reports still accepted
- NEXT gates still issued for complete work
- Status queries work

### What Stops

- No new GO gates issued
- No new agents spawned
- No new batches started
- No new tasks begin

---

## Resume Process

```
resume_execution():
  1. Verify pause state
  2. Set orchestrator_state.paused = false

  3. Check for changes during pause:
     a. Any escalations resolved?
     b. Any agents completed?
     c. Any new issues?

  4. Resume blocked operations:
     a. Issue pending GO gates
     b. Spawn queued agents
     c. Start pending batches

  5. Update state
  6. Confirm to DD
```

---

## State During Pause

### orchestrator_state.json

```json
{
  "paused": true,
  "paused_at": "ISO8601",
  "pause_reason": "BLOCKING_ESCALATION",
  "pause_trigger": {
    "type": "escalation",
    "id": "ESC-001"
  }
}
```

### Agent States

Agents in various states during pause:

| Agent State | During Pause |
|-------------|--------------|
| implementing | Completes current step, then waits |
| testing | Completes tests, submits report |
| awaiting_go | Waits (blocked) |
| awaiting_next | Receives NEXT if validated |

---

## Graceful Degradation

If critical escalation:

```
1. Pause new work
2. Let in-progress work complete
3. Save all state
4. Wait for DD resolution
5. Resume after resolution
```

---

## Emergency Stop vs Pause

| | PAUSE | ABORT |
|--|-------|-------|
| Agents | Complete current step | Terminate immediately |
| State | Preserved | Saved but phase marked aborted |
| Resume | Yes | New session required |
| Work | Preserved | Discarded |

---

## DD Commands

```
PAUSE
  - Pauses immediately
  - Agents finish current step
  - State preserved

RESUME
  - Resumes from pause
  - Continues where left off
  - Checks for updates

ABORT
  - Terminates everything
  - Cleans up
  - Phase marked aborted
```

---

## Related Documentation

- [DD Commands](dd_commands.md)
- [Orchestrator State](orchestrator_state.md)
- [Escalation Queue](escalation_queue.md)
