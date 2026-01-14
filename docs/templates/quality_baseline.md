# Quality Baseline Template

**Version:** 20.0

Use this template to establish quality baselines for features and projects.

---

## Feature Information

**Feature:** [Name]
**Baseline Date:** [Date]
**Baseline Author:** [Name]

---

## Test Coverage Baseline

### Unit Tests

| Module | Tests | Passing | Coverage |
|--------|-------|---------|----------|
| [module] | [count] | [count] | [%] |
| **Total** | **[count]** | **[count]** | **[%]** |

### Integration Tests

| Flow | Tests | Passing | Coverage |
|------|-------|---------|----------|
| [flow] | [count] | [count] | [%] |
| **Total** | **[count]** | **[count]** | **[%]** |

### E2E Tests

| Scenario | Tests | Passing |
|----------|-------|---------|
| [scenario] | [count] | [count] |
| **Total** | **[count]** | **[count]** |

---

## Code Quality Baseline

### Static Analysis

| Tool | Issues | Severity |
|------|--------|----------|
| ESLint | [count] | [breakdown] |
| TypeScript | [count] | [breakdown] |
| [other] | [count] | [breakdown] |

### Complexity Metrics

| Metric | Value | Threshold |
|--------|-------|-----------|
| Cyclomatic Complexity (avg) | [value] | < 10 |
| Cognitive Complexity (avg) | [value] | < 15 |
| Lines per function (avg) | [value] | < 50 |

### Technical Debt

| Category | Count | Effort |
|----------|-------|--------|
| TODO comments | [count] | [hours] |
| Deprecated usage | [count] | [hours] |
| Missing types | [count] | [hours] |
| **Total** | **[count]** | **[hours]** |

---

## Performance Baseline

### Load Times

| Page/Action | P50 | P95 | P99 |
|-------------|-----|-----|-----|
| [page] | [ms] | [ms] | [ms] |

### Resource Usage

| Resource | Baseline | Threshold |
|----------|----------|-----------|
| Bundle size | [KB] | [KB] |
| Memory (idle) | [MB] | [MB] |
| Memory (active) | [MB] | [MB] |

---

## Security Baseline

### Vulnerability Scan

| Severity | Count | Status |
|----------|-------|--------|
| Critical | [count] | Fixed/Accepted |
| High | [count] | Fixed/Accepted |
| Medium | [count] | Fixed/Accepted |
| Low | [count] | Fixed/Accepted |

### Dependency Audit

| Package | Issue | Resolution |
|---------|-------|------------|
| [package] | [CVE] | [action] |

---

## Acceptance Criteria Coverage

### Feature AC Mapping

| AC ID | Description | Test Coverage |
|-------|-------------|---------------|
| AC-01 | [description] | Covered/Partial/None |
| AC-02 | [description] | Covered/Partial/None |

### Coverage Summary

- **Fully Covered:** [count] / [total]
- **Partially Covered:** [count] / [total]
- **Not Covered:** [count] / [total]

---

## Quality Gates

### Required for GO

| Gate | Current | Required | Pass |
|------|---------|----------|------|
| Unit test coverage | [%] | 80% | Yes/No |
| Integration tests pass | [%] | 100% | Yes/No |
| No critical vulnerabilities | [count] | 0 | Yes/No |
| TypeScript strict | Yes/No | Yes | Yes/No |

### Required for NEXT

| Gate | Current | Required | Pass |
|------|---------|----------|------|
| All AC tested | [%] | 100% | Yes/No |
| E2E tests pass | [%] | 100% | Yes/No |
| No regressions | [count] | 0 | Yes/No |
| Performance within threshold | Yes/No | Yes | Yes/No |

---

## Improvement Targets

| Metric | Current | Target | Priority |
|--------|---------|--------|----------|
| Unit coverage | [%] | [%] | High/Medium/Low |
| Tech debt hours | [hours] | [hours] | High/Medium/Low |
| Bundle size | [KB] | [KB] | High/Medium/Low |

---

## Related Documentation

- [Quality Gate](../quality/quality_gate.md)
- [Test Alignment Skill](../skills/skill_03_test_alignment.md)
