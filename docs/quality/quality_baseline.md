# Quality Baseline

This document defines the minimum acceptable quality standards for any product built with this factory.

Quality standards are conservative by default. Relaxing them requires an explicit decision.

---

## Code quality

- Code must compile and run without errors
- No unused variables or dead code
- Linting must pass

---

## Test coverage

Minimum expectations:
- All new logic must be covered by tests
- Critical paths must have integration or E2E coverage
- Bug fixes must include regression tests

Coverage numbers are guidance, not a substitute for meaningful tests.

---

## Documentation quality

- Specs must be up to date
- Acceptance criteria must be testable
- Execution reports must be complete

---

## Performance

- No known performance regressions allowed
- Performance-sensitive changes must include benchmarks or measurements

---

## Security

- No known security regressions allowed
- Auth and authorization must be respected
- Sensitive data must not be logged

---

## Enforcement

If the baseline is violated:
- STOP execution
- Open a Change Request to restore quality