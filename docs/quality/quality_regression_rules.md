# Quality Regression Rules

This document defines how quality regressions are detected and handled.

---

## What is a regression

A regression is any change that:
- breaks existing tests
- reduces coverage of critical paths
- degrades performance beyond acceptable thresholds
- introduces new errors or warnings
- breaks documented acceptance criteria

---

## Detection

Regressions may be detected via:
- automated tests
- CI failures
- production signals
- manual verification

---

## Response policy

When a regression is detected:
1) STOP execution
2) Identify scope of regression
3) Decide response:
   - fix immediately (preferred)
   - rollback to last known good state
   - open Change Request if fix is non-trivial

Skipping regressions to “move faster” is forbidden.

---

## Reporting

All regressions must be documented:
- what regressed
- how it was detected
- how it was fixed or mitigated