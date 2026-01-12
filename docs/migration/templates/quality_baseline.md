# Quality Baseline

**Established:** {{DATE}}
**Last Updated:** {{DATE}}
**Project:** {{PROJECT_NAME}}

---

## Current State Metrics

### Test Coverage

| Metric | Value | Tool | Measured On |
|--------|-------|------|-------------|
| Line coverage | % | | |
| Branch coverage | % | | |
| Function coverage | % | | |
| Statement coverage | % | | |

### Test Inventory

| Test Type | Count | Passing | Failing | Skipped |
|-----------|-------|---------|---------|---------|
| Unit | | | | |
| Integration | | | | |
| E2E | | | | |
| Manual/QA | | | | |
| **Total** | | | | |

### Build Metrics

| Metric | Value |
|--------|-------|
| Average test suite time | |
| Average full build time | |
| Flaky test count | |
| CI platform | |

---

## Known Technical Debt

Document technical debt that affects quality:

| ID | Description | Severity | Impact | Notes |
|----|-------------|----------|--------|-------|
| TD-001 | | High/Medium/Low | | |
| TD-002 | | High/Medium/Low | | |
| TD-003 | | High/Medium/Low | | |

---

## Accepted Limitations

The following are known gaps accepted as part of the baseline:

### Coverage Exceptions

| Component | Coverage | Reason | Expiration |
|-----------|----------|--------|------------|
| | | | |
| | | | |

### Test Gaps

| Area | Gap Description | Mitigation |
|------|-----------------|------------|
| | | |
| | | |

### Known Unfixed Issues

| Issue | Severity | Reason Not Fixed | Tracking |
|-------|----------|------------------|----------|
| | | | |
| | | | |

---

## Quality Targets

### Coverage Targets

| Metric | Current | Target | Timeline |
|--------|---------|--------|----------|
| Line coverage | % | % | |
| Branch coverage | % | % | |
| Test count | | | |

**Note:** Targets are aspirational. Failure to meet targets does not block execution.

### Quality Improvement Goals

| Goal | Current State | Target State | Priority |
|------|---------------|--------------|----------|
| | | | |
| | | | |

---

## Regression Policy

### Hard Requirements (Blocking)

These conditions MUST be met for CI to pass:

| Requirement | Threshold | Enforcement |
|-------------|-----------|-------------|
| Tests passing | 100% of enabled tests | CI check |
| Coverage floor | % (baseline - 2%) | CI check |
| No new flaky tests | 0 introduced | Manual review |
| Build success | Complete without errors | CI check |

### Soft Requirements (Warning Only)

These are monitored but do not block:

| Requirement | Threshold | Action if Violated |
|-------------|-----------|-------------------|
| Coverage trend | No decrease | Warning in PR |
| Build time | < X minutes | Warning in PR |
| New code coverage | > 70% | Review comment |

---

## New Code Requirements

All new code must meet these standards:

### Test Requirements

- [ ] Unit tests for new functions/methods
- [ ] Integration tests for new API endpoints
- [ ] Edge case coverage for user-facing features
- [ ] Minimum 70% line coverage for new files

### Quality Standards

- [ ] No new linting errors
- [ ] No new security warnings
- [ ] Code review approval
- [ ] Documentation for public APIs

### Exemptions

New code may be exempt from requirements if:

| Condition | Approval Required |
|-----------|-------------------|
| Generated code | Documented in PR |
| Third-party integration glue | Tech lead |
| Prototype/spike | Product Owner |
| Emergency hotfix | Post-hoc review |

---

## Exception Process

### Requesting an Exception

1. Document the exception request in task report
2. Provide justification:
   - Why coverage can't be achieved
   - What alternative quality measures exist
   - Expiration date for exception
3. Get required approval (see below)
4. Add to Accepted Limitations section

### Approval Requirements

| Exception Type | Approver |
|----------------|----------|
| Coverage < baseline | Product Owner |
| Skipping test type | Tech Lead + Product Owner |
| Emergency bypass | Post-hoc Product Owner |

### Exception Template

```markdown
## Exception Request

**Date:**
**Requester:**
**Task:**

### Scope
- Files affected:
- Coverage impact:

### Justification


### Alternative Quality Measures


### Expiration

```

---

## Flaky Test Policy

### Definition

A test is "flaky" if it:
- Passes and fails intermittently without code changes
- Depends on external state (time, network, random)
- Has race conditions

### Current Flaky Tests

| Test | Flakiness Rate | Reason | Status |
|------|----------------|--------|--------|
| | | | |

### Resolution Requirements

Flaky tests must be:

1. **Fixed** within 2 sprint cycles, OR
2. **Quarantined** to non-blocking suite, OR
3. **Deleted** if not providing value

### Quarantine Process

1. Move test to `tests/quarantine/` directory
2. Add to quarantine CI job (non-blocking)
3. Document in this baseline
4. Create ticket to fix or remove

---

## CI Integration

### Current CI Checks

| Check | Blocking | Threshold |
|-------|----------|-----------|
| Unit tests | Yes | 100% pass |
| Integration tests | Yes | 100% pass |
| Coverage | Yes | % |
| Linting | Yes | 0 errors |
| Build | Yes | Success |

### CI Configuration Files

| File | Purpose |
|------|---------|
| | |
| | |

### Adding New Checks

New CI checks require:
1. Documentation in this baseline
2. Initial threshold set appropriately
3. Product Owner approval if blocking

---

## Measurement Commands

### How to Measure Coverage

```bash
# JavaScript/TypeScript
npm test -- --coverage

# Python
pytest --cov=. --cov-report=term-missing

# Go
go test -cover ./...
```

### How to Run Full Quality Check

```bash
# Example comprehensive check
npm run lint && npm test -- --coverage && npm run build
```

---

## Review Schedule

| Review Type | Frequency | Reviewer |
|-------------|-----------|----------|
| Metrics update | Monthly | Tech Lead |
| Target adjustment | Quarterly | Team |
| Full baseline review | Annually | Product Owner |

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| | Baseline established | |
| | | |
