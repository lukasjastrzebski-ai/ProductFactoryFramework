# Escalation Responses

**Version:** 20.0

This document describes how the PO processes DD responses to escalations.

---

## Overview

When the DD responds to an escalation, the PO processes the response, updates state, and unblocks affected work.

---

## Response Types

### PROVIDE

DD provides requested credentials or information.

```json
{
  "response_type": "PROVIDE",
  "escalation_id": "ESC-001",
  "data": {
    "STRIPE_PUBLISHABLE_KEY": "pk_test_xxx",
    "STRIPE_SECRET_KEY": "sk_test_xxx"
  },
  "timestamp": "ISO8601"
}
```

**Processing:**
1. Store credentials securely (not in git)
2. Update environment/config
3. Mark escalation resolved
4. Unblock affected tasks
5. Resume execution

### DEFER

DD defers the escalation to later.

```json
{
  "response_type": "DEFER",
  "escalation_id": "ESC-001",
  "defer_until": "2026-01-20",
  "reason": "Waiting for account approval",
  "timestamp": "ISO8601"
}
```

**Processing:**
1. Update escalation status to "deferred"
2. Mark affected tasks as deferred
3. Continue with unrelated work
4. Remind when defer_until reached

### SKIP

DD decides to skip the affected work.

```json
{
  "response_type": "SKIP",
  "escalation_id": "ESC-001",
  "reason": "Not needed for MVP",
  "create_tech_debt": true,
  "timestamp": "ISO8601"
}
```

**Processing:**
1. Mark affected tasks as SKIPPED
2. Create technical debt record
3. Unblock dependent tasks
4. Continue execution

### REJECT

DD rejects the escalation (not a valid need).

```json
{
  "response_type": "REJECT",
  "escalation_id": "ESC-001",
  "reason": "We already have Stripe credentials in vault",
  "instruction": "Use existing vault credentials",
  "timestamp": "ISO8601"
}
```

**Processing:**
1. Mark escalation as rejected
2. Update task with instruction
3. Resume task execution
4. No DD action needed

---

## Response Processing Flow

```
Receive DD Response
       │
       ▼
  ┌─────────────┐
  │   Parse     │
  │  Response   │
  └──────┬──────┘
         │
         ▼
  ┌─────────────┐
  │  Validate   │
  │   Input     │
  └──────┬──────┘
         │
         ├── PROVIDE ──► Store data, unblock
         │
         ├── DEFER ────► Update status, wait
         │
         ├── SKIP ─────► Skip tasks, record debt
         │
         └── REJECT ───► Update instruction, resume
```

---

## Credential Handling

### Secure Storage

Credentials provided by DD are stored securely:

```
# Never commit to git
.env.local          # Local only
.factory/secrets/   # Encrypted (gitignored)
```

### Environment Setup

```bash
# Set credentials for execution
export STRIPE_PUBLISHABLE_KEY="pk_test_xxx"
export STRIPE_SECRET_KEY="sk_test_xxx"
```

### Access Control

- Credentials available to agents via env vars
- Not written to code or config files
- Cleared at session end

---

## Unblocking Tasks

After resolution:

```
unblock_tasks(escalation):
  FOR task_id in escalation.affected_tasks:
    task = get_task(task_id)
    task.status = "pending"
    clear_blocker(task_id)

  # Check if tasks can now be spawned
  FOR task_id in escalation.affected_tasks:
    IF all_dependencies_met(task_id):
      add_to_spawn_queue(task_id)
```

---

## Technical Debt Records

When SKIP is chosen:

**File:** `docs/execution/technical_debt.md`

```markdown
## Technical Debt Record

### TD-001: Payment Integration Skipped

**Date:** 2026-01-14
**Tasks:** TASK-005, TASK-006
**Reason:** Account approval pending

**Impact:**
- Payment features not available
- Manual invoicing required as workaround

**Resolution Required:**
- [ ] Get Stripe account approved
- [ ] Implement TASK-005, TASK-006
- [ ] Test payment flow end-to-end

**Created By:** DD response to ESC-001
```

---

## Response Validation

```
validate_response(response):
  IF response.escalation_id NOT IN pending_escalations:
    ERROR "Escalation not found or already resolved"

  IF response.response_type == PROVIDE:
    CHECK all required data present
    CHECK data format valid

  IF response.response_type == DEFER:
    CHECK defer_until is future date
    CHECK reason provided

  IF response.response_type == SKIP:
    CHECK reason provided

  RETURN valid
```

---

## Related Documentation

- [Escalation Queue](escalation_queue.md)
- [Escalation Classification](escalation_classification.md)
- [DD Commands](dd_commands.md)
