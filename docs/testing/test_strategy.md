# Test Strategy

This document defines how testing is designed, executed, and enforced in the factory.

Testing is not optional. If tests are missing, execution is invalid.

---

## Testing layers

1) Unit tests
- Validate individual functions and components
- Fast, deterministic
- Required for all non-trivial logic

2) Integration tests
- Validate interactions between components
- Database, API, service boundaries

3) End-to-end (E2E) tests
- Validate user journeys
- Cover critical flows only

---

## Ownership

- Feature Test Plans define WHAT must be tested
- Task Test Delta defines WHAT changes per task
- Implementation executes tests
- Product Owner verifies test execution via reports

---

## Test design rules

- Every acceptance criterion must map to at least one test
- MVP features require Feature Test Plans
- Non-MVP features still require task-level tests

---

## Flakiness policy

- Flaky tests are treated as failures
- Fix flakiness immediately
- Do not disable tests to unblock execution

---

## Regression philosophy

- Regression tests protect shipped behavior
- Any change must declare regression scope
- Regression scope must be executed and reported

---

## Enforcement

- Tests must be executed before task completion
- Reports must list tests executed
- CI enforces minimum standards

If tests are missing, STOP execution.