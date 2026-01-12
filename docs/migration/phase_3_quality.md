# Phase 3: Quality Baseline

**Time: 1-2 hours**

Phase 3 establishes a quality baseline that prevents regression without requiring immediate improvements.

---

## Overview

The quality baseline defines:
- Current state (the floor, not the ceiling)
- Regression policy (what must not get worse)
- New code requirements (standards for additions)
- Exception process (how to handle edge cases)

**Key principle:** The baseline documents reality, not aspirations.

---

## Step 1: Measure Current Test Coverage

### Run Coverage Tools

Execute your project's coverage command:

```bash
# JavaScript/TypeScript (Jest)
npm test -- --coverage --coverageReporters=json-summary

# JavaScript/TypeScript (Vitest)
npx vitest run --coverage

# Python (pytest)
pytest --cov=. --cov-report=json

# Go
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out

# Ruby
COVERAGE=true bundle exec rspec

# Java (Maven with JaCoCo)
mvn test jacoco:report
```

### Record Coverage Metrics

| Metric | Value | Tool |
|--------|-------|------|
| Line coverage | X% | |
| Branch coverage | X% | |
| Function coverage | X% | |
| Statement coverage | X% | |

### Count Tests

```bash
# JavaScript (Jest)
npm test -- --listTests | wc -l

# Python (pytest)
pytest --collect-only | grep "test session starts" -A 1

# Go
go test -v ./... 2>&1 | grep -c "=== RUN"

# Ruby
bundle exec rspec --dry-run
```

| Test Type | Count |
|-----------|-------|
| Unit tests | |
| Integration tests | |
| E2E tests | |
| **Total** | |

---

## Step 2: Identify Test Quality Issues

### Find Flaky Tests

Tests that intermittently fail are "flaky" and should be documented:

```bash
# Run tests multiple times to identify flaky tests
for i in {1..5}; do npm test 2>&1 | tee -a test_runs.log; done

# Analyze for inconsistent results
grep -E "FAIL|PASS" test_runs.log | sort | uniq -c
```

### Measure Build Time

```bash
# Time your test suite
time npm test

# For CI, check historical build times in your CI dashboard
```

### Document Known Issues

| Issue Type | Count | Examples |
|------------|-------|----------|
| Flaky tests | | test_user_session, test_async_update |
| Slow tests (>30s) | | integration_full_workflow |
| Skipped tests | | |
| Disabled tests | | |

---

## Step 3: Create Quality Baseline Document

Create `docs/quality/quality_baseline.md` using the [template](templates/quality_baseline.md):

```markdown
# Quality Baseline

Established: YYYY-MM-DD
Last updated: YYYY-MM-DD

## Current State Metrics

| Metric | Value | Measured On |
|--------|-------|-------------|
| Line coverage | 45% | 2024-01-15 |
| Branch coverage | 32% | 2024-01-15 |
| Total tests | 127 | 2024-01-15 |
| Passing tests | 125 | 2024-01-15 |
| Flaky tests | 2 | 2024-01-15 |
| Average build time | 3m 42s | 2024-01-15 |

## Known Technical Debt

| Item | Severity | Notes |
|------|----------|-------|
| No E2E tests | Medium | Manual QA covers critical paths |
| Auth tests incomplete | Medium | Only happy path covered |
| Legacy module untested | Low | Scheduled for deprecation |

## Accepted Limitations

The following are known gaps accepted at baseline:

1. **Legacy reporting module** - 0% coverage, scheduled for replacement
2. **Admin panel** - 15% coverage, low usage feature
3. **PDF export** - Manual testing only, third-party library

## Quality Targets

| Metric | Current | Target | Timeline |
|--------|---------|--------|----------|
| Line coverage | 45% | 60% | 6 months |
| Branch coverage | 32% | 45% | 6 months |
| Flaky tests | 2 | 0 | 3 months |

Targets are aspirational. Failure to meet targets does not block execution.

## Regression Policy

### Hard Requirements (Blocking)

- Total test count must not decrease without approved exception
- Passing test count must not decrease
- Coverage must not drop more than 2% from baseline
- No new flaky tests introduced

### Soft Requirements (Warning Only)

- Coverage should increase with new features
- Build time should not increase more than 20%
- New code should have >70% coverage

## New Code Requirements

All new code must:

1. Include tests for new functionality
2. Achieve minimum 70% line coverage for new files
3. Not break existing tests
4. Pass all CI checks

## Exception Process

To request a coverage exception:

1. Document the exception in the task report
2. Provide justification (e.g., third-party integration, generated code)
3. Get Product Owner approval
4. Add to Accepted Limitations list

## Flaky Test Policy

Flaky tests must be:

1. Documented in Known Issues
2. Either fixed within 2 sprints OR
3. Quarantined (moved to separate non-blocking suite)

## CI Integration

Coverage is enforced via:

- [ ] Pre-commit hooks
- [ ] GitHub Actions / CI pipeline
- [ ] Pull request checks

Blocking checks:
- `npm test` must pass
- Coverage check must pass (threshold: 43% - 2% below baseline)
```

---

## Step 4: Configure CI Workflow

### GitHub Actions Example

Create or update `.github/workflows/quality.yml`:

```yaml
name: Quality Gate

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests with coverage
        run: npm test -- --coverage --coverageReporters=json-summary

      - name: Check coverage threshold
        run: |
          COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
          THRESHOLD=43  # 2% below baseline of 45%
          if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
            echo "Coverage $COVERAGE% is below threshold $THRESHOLD%"
            exit 1
          fi
          echo "Coverage $COVERAGE% meets threshold $THRESHOLD%"

      - name: Upload coverage report
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
```

### GitLab CI Example

```yaml
# .gitlab-ci.yml
test:
  stage: test
  script:
    - npm ci
    - npm test -- --coverage
  coverage: '/Lines\s*:\s*(\d+\.?\d*)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

### Pre-commit Hook (Optional)

Add to `package.json`:

```json
{
  "husky": {
    "hooks": {
      "pre-commit": "npm test -- --coverage --coverageThreshold='{\"global\":{\"lines\":43}}'"
    }
  }
}
```

---

## Step 5: Verify Quality Gate Integration

### Test the Quality Gate

```bash
# Run tests and verify coverage is captured
npm test -- --coverage

# Verify CI configuration
# Push a test branch and check CI logs

# Verify threshold enforcement
# Temporarily lower coverage and confirm CI fails
```

### Expected Behavior

| Action | Expected Result |
|--------|-----------------|
| Tests pass, coverage meets threshold | CI passes |
| Tests pass, coverage below threshold | CI fails |
| Tests fail | CI fails |
| Flaky test detected | Warning logged |

---

## Exception Documentation

When you need exceptions, document them:

### Template for Exception

```markdown
## Coverage Exception: [Component Name]

**Date:** YYYY-MM-DD
**Requested by:** [Name]
**Approved by:** [Product Owner]

### Reason
[Why coverage is exempted]

### Scope
- Files affected: [list]
- Coverage impact: [X% reduction]

### Mitigation
[What alternative quality measures exist]

### Expiration
[When this exception should be revisited]
```

---

## Exit Criteria Checklist

Before proceeding to Phase 4, verify:

- [ ] **Current coverage measured** - Exact percentage known
- [ ] **Test count documented** - Total and by type
- [ ] **Flaky tests identified** - Listed with names
- [ ] **quality_baseline.md created** - Complete with all sections
- [ ] **Regression policy defined** - Hard and soft requirements clear
- [ ] **CI workflow configured** - Tests run on push/PR
- [ ] **Coverage threshold set** - 2% below baseline
- [ ] **Exception process documented** - Clear steps

---

## Common Issues

### "No tests exist at all"

If coverage is 0%:
1. Set baseline at 0%
2. Define "new code requires tests" policy
3. Skip coverage threshold enforcement initially
4. Require tests for all new code going forward

### "Coverage tool doesn't work"

1. Check tool is installed (`npm install --save-dev jest` etc.)
2. Verify configuration file exists (jest.config.js, pytest.ini)
3. Check test files match expected pattern (*test*, *spec*)
4. Consult tool documentation for setup

### "CI already exists with different rules"

Options:
1. Merge factory quality checks into existing CI
2. Add factory workflow alongside existing
3. Gradually migrate to factory patterns

### "Team objects to hard coverage requirements"

Adjust threshold:
1. Set initial threshold lower (5-10% below current)
2. Document as accepted limitation
3. Plan gradual increase over time
4. Use soft requirements initially

### "Flaky tests are too numerous"

If >10% of tests are flaky:
1. Quarantine all flaky tests to separate suite
2. Run quarantined suite separately (non-blocking)
3. Create task to fix flaky tests
4. Set baseline from stable tests only

---

## Next Step

Proceed to [Phase 4: Activation](phase_4_activation.md)
