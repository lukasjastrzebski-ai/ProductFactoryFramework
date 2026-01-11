# Decision Engine Inputs

This document defines what information may be used by the decision engine.

The decision engine recommends priorities. It never authorizes execution.

---

## Allowed inputs

- Signal snapshots (docs/signals/signal_snapshot.md)
- Execution state (docs/execution/state.md)
- Open tasks and phases (plan/tasks/, plan/phases/)
- Known regressions or quality issues
- Manual PO overrides

---

## Forbidden inputs

- Chat-only context
- Unverified memory
- Speculation without evidence
- Partial or stale signals

---

## Freshness rules

- Signal snapshots should be recent
- Execution state must reflect current reality
- Stale inputs must be flagged

Decisions based on stale data must be treated as low confidence.