# Escalation Classification

**Version:** 20.0

This document describes how the PO classifies issues as internal or external escalations.

---

## Overview

The PO must determine when to handle issues internally vs escalate to the Delivery Director. Classification is based on the nature of the issue.

---

## Classification Rules

### External Escalations (Require DD)

| Type | Examples | Action |
|------|----------|--------|
| Account Setup | Stripe, Convex, Vercel, AWS | Pause, notify DD |
| Payment Required | Paid APIs, licenses | Pause, notify DD |
| Credentials | API keys, secrets, tokens | Pause, notify DD |
| Legal/Compliance | ToS, contracts, privacy | STOP, notify DD |
| Strategic Decision | Architecture pivot, scope change | Pause, notify DD |

### Internal Handling (PO Manages)

| Type | Examples | Action |
|------|----------|--------|
| Test Failures | Unit test fails | FIX directive |
| Code Issues | Bug, type error | FIX directive |
| Dependency Wait | Task A waits for B | Resequence |
| File Conflict | Two agents same file | Reorder |
| Agent Timeout | Agent stuck | Terminate, retry |

---

## Classification Logic

```
classify_issue(issue):
  # Check for external indicators
  IF contains_keywords(issue, ["api key", "stripe", "convex", "account"]):
    RETURN EXTERNAL_DEPENDENCY

  IF contains_keywords(issue, ["payment", "license", "subscription"]):
    RETURN PAYMENT_REQUIRED

  IF contains_keywords(issue, ["credentials", "secret", "token"]):
    RETURN CREDENTIALS_NEEDED

  IF contains_keywords(issue, ["legal", "compliance", "terms", "privacy"]):
    RETURN LEGAL_COMPLIANCE

  IF requires_business_decision(issue):
    RETURN STRATEGIC_DECISION

  # Otherwise internal
  IF is_test_failure(issue):
    RETURN INTERNAL_TEST

  IF is_code_issue(issue):
    RETURN INTERNAL_CODE

  IF is_dependency_issue(issue):
    RETURN INTERNAL_DEPENDENCY

  RETURN INTERNAL_OTHER
```

---

## Priority Levels

| Priority | Description | Response Time |
|----------|-------------|---------------|
| BLOCKING | Stops all execution | Immediate |
| HIGH | Affects multiple tasks | Same day |
| MEDIUM | Affects single task | Can wait |
| LOW | Minor concern | Optional |

### Priority Assignment

```
assign_priority(type, impact):
  IF type in [LEGAL_COMPLIANCE]:
    RETURN BLOCKING

  IF type in [EXTERNAL_DEPENDENCY, CREDENTIALS_NEEDED]:
    IF blocks_multiple_tasks(impact):
      RETURN BLOCKING
    ELSE:
      RETURN HIGH

  IF type in [PAYMENT_REQUIRED, STRATEGIC_DECISION]:
    RETURN HIGH

  RETURN MEDIUM
```

---

## Escalation Decision Matrix

| Issue Type | # Tasks Affected | Priority | Action |
|------------|------------------|----------|--------|
| External Dep | 1 | HIGH | Escalate, continue others |
| External Dep | >1 | BLOCKING | Escalate, pause affected |
| Legal | Any | BLOCKING | STOP, escalate |
| Test Failure | 1 | LOW | FIX internally |
| Test Failure | >1 | MEDIUM | FIX, monitor pattern |

---

## Examples

### External Escalation

```
Issue: "Cannot connect to Stripe API"
Analysis:
  - Contains "Stripe API" → external service
  - Requires credentials → DD must provide
  - Classification: EXTERNAL_DEPENDENCY
  - Priority: HIGH (blocks payment feature)
Action: Create escalation, notify DD
```

### Internal Handling

```
Issue: "Login test failing"
Analysis:
  - Test failure → internal code issue
  - No external dependency
  - Classification: INTERNAL_TEST
  - Priority: LOW (single task)
Action: Issue FIX directive with guidance
```

---

## Related Documentation

- [Escalation Queue](escalation_queue.md)
- [Escalation Responses](escalation_responses.md)
- [DD Commands](dd_commands.md)
