# Escalation Queue

**Version:** 20.0

This document describes the escalation queue system for managing DD escalations.

---

## Overview

When the PO identifies an issue requiring DD involvement, it creates an escalation in the queue. The queue manages priority, aging, and resolution tracking.

---

## Queue Location

**File:** `.factory/execution/escalation_queue.json`

---

## Queue Schema

```json
{
  "version": "20.0",
  "escalations": [
    {
      "escalation_id": "ESC-001",
      "type": "EXTERNAL_DEPENDENCY",
      "priority": "BLOCKING",
      "status": "pending",
      "created_at": "ISO8601",
      "updated_at": "ISO8601",
      "affected_tasks": ["TASK-005", "TASK-006"],
      "description": "Stripe API key required for payment integration",
      "context": {
        "task_file": "plan/tasks/TASK-005.md",
        "spec_reference": "specs/features/payments.md",
        "what_is_needed": "Stripe publishable key and secret key"
      },
      "options": [
        {
          "id": "PROVIDE",
          "label": "Provide credentials",
          "implications": "Tasks can proceed"
        },
        {
          "id": "DEFER",
          "label": "Defer task",
          "implications": "Skip payment features for now"
        }
      ],
      "recommendation": "PROVIDE - needed for core functionality",
      "resolution": null
    }
  ],
  "last_updated": "ISO8601"
}
```

---

## Escalation Lifecycle

```
CREATE    → pending
NOTIFY    → pending (DD notified)
ACKNOWLEDGE → acknowledged
RESOLVE   → resolved

Timeout behavior:
  If pending > 24 hours and BLOCKING:
    Generate reminder
  If pending > 48 hours:
    Consider alternative paths
```

---

## Queue Operations

### Add Escalation

```
add_escalation(type, priority, affected_tasks, description):
  esc_id = generate_escalation_id()
  escalation = {
    escalation_id: esc_id,
    type: type,
    priority: priority,
    status: "pending",
    affected_tasks: affected_tasks,
    description: description,
    created_at: now()
  }
  queue.escalations.push(escalation)
  save_queue()

  IF priority == BLOCKING:
    pause_affected_tasks(affected_tasks)

  notify_dd(escalation)
  return esc_id
```

### Resolve Escalation

```
resolve_escalation(esc_id, resolution):
  escalation = find_escalation(esc_id)
  escalation.status = "resolved"
  escalation.resolution = resolution
  escalation.updated_at = now()
  save_queue()

  unblock_affected_tasks(escalation.affected_tasks)
  log_resolution(escalation)
```

### Get Pending Escalations

```
get_pending():
  RETURN queue.escalations
    .filter(e => e.status == "pending")
    .sort_by(e => e.priority, e.created_at)
```

---

## Priority Handling

### BLOCKING Escalations

- Pause affected tasks immediately
- Display prominently to DD
- Generate reminders if unresolved
- Block new dependent tasks

### HIGH Escalations

- Continue unrelated work
- Display in escalation list
- Reminder after 24 hours

### MEDIUM/LOW Escalations

- Continue all work
- List for DD review
- No automatic reminders

---

## Escalation Message Format

When displaying to DD:

```
[1] ESC-001 (BLOCKING)
    Type: External Dependency
    Affected: TASK-005, TASK-006
    Need: Stripe API key
    Age: 15 minutes

    What's needed:
    - Stripe publishable key
    - Stripe secret key

    Options:
    1. PROVIDE - Provide the credentials
    2. DEFER - Skip payment features for now

    Recommendation: PROVIDE (core functionality)

Use: RESPOND ESC-001 to respond
```

---

## Queue Monitoring

### Check for Blocking

```bash
jq '[.escalations[] | select(.priority == "BLOCKING" and .status == "pending")] | length' \
    .factory/execution/escalation_queue.json
```

### List All Pending

```bash
jq '.escalations[] | select(.status == "pending")' \
    .factory/execution/escalation_queue.json
```

### Calculate Age

```bash
jq '.escalations[] | select(.status == "pending") |
    {id: .escalation_id, age_hours: ((now - (.created_at | fromdate)) / 3600)}' \
    .factory/execution/escalation_queue.json
```

---

## Related Documentation

- [Escalation Classification](escalation_classification.md)
- [Escalation Responses](escalation_responses.md)
- [DD Commands](dd_commands.md)
