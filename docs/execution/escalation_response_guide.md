# Escalation Response Guide for Delivery Directors

**Version:** 20.0

This guide explains how to handle escalations in v20 autonomous mode.

---

## Quick Facts

- Escalations are sent to you immediately when PO encounters something it cannot handle
- **BLOCKING** escalations automatically pause dependent tasks
- You must respond to BLOCKING escalations for execution to continue
- Non-blocking escalations can be deferred

---

## Escalation Severity Levels

| Level | Impact | Response Time | Auto-Pause? |
|-------|--------|---------------|-------------|
| **BLOCKING** | Execution halted | ASAP (< 4 hours) | Yes |
| **HIGH** | Progress slowed | Within 24 hours | No |
| **MEDIUM** | Minor delay | Within 48 hours | No |
| **INFO** | Awareness only | When convenient | No |

---

## Responding to Escalations

### Step 1: View Escalations

```
ESCALATIONS
```

Output:
```
=== Pending Escalations ===

[1] ESC-001 (BLOCKING)
    Type: External Dependency
    Task: TASK-003
    Need: Stripe API key for payment integration
    Created: 2026-01-14 10:30:00 UTC

[2] ESC-002 (HIGH)
    Type: Strategic Decision
    Task: TASK-007
    Need: Choose between OAuth and JWT for auth
    Created: 2026-01-14 11:15:00 UTC
```

### Step 2: Respond to an Escalation

```
RESPOND ESC-001
```

### Step 3: Follow the Interactive Prompts

**For External Dependencies:**
```
> RESPOND ESC-001

Escalation: Need Stripe API key for payment integration

Options:
  [1] PROVIDE - Supply the required credential
  [2] DEFER - Delay this task (provide reason)
  [3] SKIP - Skip this task entirely

Your choice: 1

Enter Stripe API key: sk_test_xxxxxxxxxxxx

Credential received. Resuming TASK-003.
```

**For Strategic Decisions:**
```
> RESPOND ESC-002

Escalation: Choose between OAuth and JWT for auth

Context:
- OAuth: Better for third-party integrations
- JWT: Simpler, faster to implement

Options:
  [1] DECIDE - Make the decision now
  [2] DEFER - Need more time
  [3] DELEGATE - Let PO decide based on criteria

Your choice: 1

Your decision: Use JWT for MVP, plan OAuth for v2

Decision recorded. Resuming dependent tasks.
```

---

## Response Options Explained

### PROVIDE (External Dependencies)

Use when you have the required credential or access.

```
RESPOND ESC-001
> PROVIDE
> [paste credential]
```

**Security Note:** Credentials appear in chat history. For sensitive keys:
1. Use environment variables when possible
2. Rotate keys after project completion
3. Never share production credentials in chat

### DEFER (Need More Time)

Use when you need to obtain something externally.

```
RESPOND ESC-001
> DEFER
> Reason: Waiting for client to provide Stripe account access
> Expected: 2026-01-15
```

**Effect:** Task remains blocked, other tasks continue.

### SKIP (Cannot Provide)

Use when the dependency cannot be satisfied.

```
RESPOND ESC-001
> SKIP
> Reason: Client decided to use different payment provider
```

**Effect:** Task marked as skipped, dependent tasks may also be skipped.

### DECIDE (Strategic Decisions)

Use when you can make the decision immediately.

```
RESPOND ESC-002
> DECIDE
> Decision: Use approach A because [reason]
```

### DELEGATE (Let PO Decide)

Use when you trust PO to make a technical decision.

```
RESPOND ESC-002
> DELEGATE
> Criteria: Prioritize faster implementation over flexibility
```

---

## Escalation Types

### External Dependencies (BLOCKING)

**What:** Third-party accounts, API keys, credentials, external access

**Examples:**
- Stripe/payment provider API keys
- Database connection strings
- Cloud service credentials (AWS, GCP, Convex)
- OAuth client IDs/secrets

**Your Action:** Provide the credential or explain why you can't

### Strategic Decisions (HIGH)

**What:** Choices requiring business context

**Examples:**
- Technology stack choices
- Feature prioritization
- Scope trade-offs
- Architecture pivots

**Your Action:** Make the decision or provide criteria for PO to decide

### Clarification Needed (MEDIUM)

**What:** Ambiguous requirements or specifications

**Examples:**
- Unclear acceptance criteria
- Missing edge case handling
- Conflicting requirements

**Your Action:** Clarify the requirement or approve PO's interpretation

### Information Only (INFO)

**What:** FYI items that don't require action

**Examples:**
- Task taking longer than expected
- Non-critical warning encountered
- Optimization opportunity identified

**Your Action:** Acknowledge or ignore

---

## What Happens If You Don't Respond

| Escalation Level | If No Response |
|------------------|----------------|
| BLOCKING | Execution stays paused indefinitely |
| HIGH | PO may proceed with default after 48h |
| MEDIUM | PO proceeds with documented assumption |
| INFO | Auto-dismissed after 7 days |

**Warning:** BLOCKING escalations will halt all dependent tasks. Respond promptly to avoid execution delays.

---

## Bulk Operations

### Respond to Multiple Escalations

If you have multiple similar escalations:

```
ESCALATIONS --type external
```

Shows only external dependency escalations.

### Defer All Non-Critical

```
DEFER ALL --level medium
> Reason: Focusing on blockers first
```

---

## Escalation Queue Management

### View Queue Statistics

```
ESCALATIONS --stats
```

Output:
```
Escalation Queue:
  BLOCKING: 1
  HIGH: 2
  MEDIUM: 3
  INFO: 5

Oldest: ESC-001 (4 hours ago)
```

### Clear Resolved Escalations

Escalations auto-clear when resolved. To manually clear:

```
CLEAR ESC-005
> Reason: No longer relevant after scope change
```

---

## Troubleshooting

### "Escalation Not Found"

- Check ID format: `ESC-001` not `001` or `esc-001`
- Escalation may have been auto-resolved
- Run `ESCALATIONS` to see current queue

### "Cannot DEFER BLOCKING Escalation"

BLOCKING escalations must be resolved (PROVIDE, DECIDE, or SKIP).
DEFER is only available for HIGH/MEDIUM/INFO levels.

### "Credential Invalid"

- Double-check the credential value
- Ensure no extra whitespace
- Verify the credential type matches what's needed

---

## Related Documentation

- [DD Commands](dd_commands.md)
- [Escalation Classification](escalation_classification.md)
- [Escalation Queue](escalation_queue.md)
