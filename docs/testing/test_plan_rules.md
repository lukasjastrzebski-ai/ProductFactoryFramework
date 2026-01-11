# Test Plan Rules

This document defines mandatory rules for Feature Test Plans and Task Test Delta.

---

## Feature Test Plans

Required for:
- All MVP features
- Any feature that impacts core user flows

Feature Test Plan must include:
- Feature overview
- Acceptance criteria mapping
- Test cases per acceptance criterion
- Edge cases
- Non-goals

Feature Test Plan file:
specs/tests/feature_<feature_slug>_test_plan.md

---

## Task Test Delta

Required for:
- Every task in plan/tasks/

Task Test Delta must specify:
- Tests to add
- Tests to update
- Regression suites to run

Task without Test Delta is BLOCKED.

---

## Mapping rules

- Acceptance criteria → Feature Test Plan → Tests
- Task Test Delta references Feature Test Plans

If mapping is unclear, STOP and clarify.