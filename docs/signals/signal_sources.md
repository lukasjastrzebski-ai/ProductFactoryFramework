# Signal Sources

Signals provide objective feedback about product health and execution quality.
They inform prioritization and decisions but do not auto-execute changes.

---

## Analytics signals
Source: analytics tools (e.g., PostHog)

Examples:
- activation rate
- retention (D1, D7, D30)
- conversion to paid
- funnel drop-offs

---

## Error signals
Source: CI, runtime monitoring, error tracking

Examples:
- CI failure rate
- production error rate
- top recurring errors
- crash rate

---

## Performance signals
Source: monitoring tools

Examples:
- p95 / p99 latency
- timeout rate
- background job failures

---

## Revenue signals
Source: billing and finance tools

Examples:
- MRR
- churn
- ARPU
- failed payments

---

## Manual PO signals
Source: Product Owner judgment

Examples:
- strategic priority shifts
- customer feedback
- legal or compliance concerns

Manual signals override automated recommendations.