# Migration Readiness Checklist

**Project:** {{PROJECT_NAME}}
**Assessment Date:** {{DATE}}
**Assessor:** {{NAME}}

---

## Overview

This checklist validates that all migration phases are complete and the factory is ready for operation.

---

## Phase 0: Assessment

| Check | Status | Notes |
|-------|--------|-------|
| Documentation inventory completed | [ ] | |
| Feature catalog created | [ ] | |
| Architecture components mapped | [ ] | |
| Test coverage measured | [ ] | |
| Stakeholders identified | [ ] | |
| Migration scope decided | [ ] | |
| Assessment document saved | [ ] | |

**Phase 0 Status:** [ ] PASS / [ ] FAIL

---

## Phase 1: Structure

| Check | Status | Notes |
|-------|--------|-------|
| CLAUDE.md exists in project root | [ ] | |
| .claude/settings.json configured | [ ] | |
| docs/ai.md exists | [ ] | |
| docs/execution/ directory created | [ ] | |
| docs/execution/reports/ exists with .gitkeep | [ ] | |
| docs/execution/task_runner.md exists | [ ] | |
| docs/execution/state.md exists | [ ] | |
| docs/quality/ directory created | [ ] | |
| docs/quality/quality_gate.md exists | [ ] | |
| specs/features/ directory created | [ ] | |
| specs/_templates/ has templates | [ ] | |
| architecture/ directory created | [ ] | |
| plan/ directory created | [ ] | |
| .factory/ directory created | [ ] | |
| No unresolved file conflicts | [ ] | |

**Phase 1 Status:** [ ] PASS / [ ] FAIL

---

## Phase 2: Artifacts

### Minimal Adoption

| Check | Status | Notes |
|-------|--------|-------|
| docs/ai.md product context filled | [ ] | |
| specs/features/index.md created | [ ] | |
| MVP features listed | [ ] | |
| architecture/system.md created | [ ] | |

### Standard Adoption (includes Minimal)

| Check | Status | Notes |
|-------|--------|-------|
| All MVP feature specs created | [ ] | |
| Feature specs have acceptance criteria | [ ] | |
| At least 2 ADRs documented | [ ] | |
| ADRs in architecture/decisions/ | [ ] | |

### Full Adoption (includes Standard)

| Check | Status | Notes |
|-------|--------|-------|
| Secondary feature specs created | [ ] | |
| Comprehensive ADR coverage | [ ] | |
| Feature test plans documented | [ ] | |

**Migration Scope:** [ ] Minimal / [ ] Standard / [ ] Full

**Phase 2 Status:** [ ] PASS / [ ] FAIL

---

## Phase 3: Quality

| Check | Status | Notes |
|-------|--------|-------|
| Current test coverage measured | [ ] | Value: ___% |
| Test count documented | [ ] | Count: ___ |
| Flaky tests identified | [ ] | Count: ___ |
| docs/quality/quality_baseline.md created | [ ] | |
| Regression policy defined | [ ] | |
| Coverage threshold set | [ ] | Threshold: ___% |
| CI workflow configured | [ ] | |
| Exception process documented | [ ] | |

**Phase 3 Status:** [ ] PASS / [ ] FAIL

---

## Phase 4: Activation

| Check | Status | Notes |
|-------|--------|-------|
| docs/execution/state.md initialized | [ ] | |
| docs/execution/progress.json initialized | [ ] | |
| .factory/KICKOFF_COMPLETE exists | [ ] | |
| .factory/PLANNING_FROZEN exists | [ ] | |
| .factory/RUN_MODE exists | [ ] | |
| .factory/factory_version.txt exists | [ ] | |
| Validation script passes | [ ] | |
| First GO/NEXT cycle completed | [ ] | |
| First report persisted | [ ] | |
| All changes committed to git | [ ] | |

**Phase 4 Status:** [ ] PASS / [ ] FAIL

---

## First Task Validation

Verify the first GO/NEXT cycle worked correctly:

| Check | Status | Notes |
|-------|--------|-------|
| Task file created | [ ] | |
| GO gate worked | [ ] | |
| Task execution completed | [ ] | |
| Report generated | [ ] | |
| State file updated | [ ] | |
| Progress JSON updated | [ ] | |
| NEXT gate worked | [ ] | |

**First Task Status:** [ ] PASS / [ ] FAIL

---

## Team Readiness

| Check | Status | Notes |
|-------|--------|-------|
| Team briefed on GO/NEXT protocol | [ ] | |
| Documentation locations shared | [ ] | |
| Escalation path defined | [ ] | |
| First real task identified | [ ] | |
| Product Owner availability confirmed | [ ] | |

**Team Readiness Status:** [ ] PASS / [ ] FAIL

---

## Summary

### Checklist Results

| Phase | Status | Blocking Issues |
|-------|--------|-----------------|
| Phase 0: Assessment | | |
| Phase 1: Structure | | |
| Phase 2: Artifacts | | |
| Phase 3: Quality | | |
| Phase 4: Activation | | |
| First Task | | |
| Team Readiness | | |

### Counts

| Category | Pass | Fail | Total |
|----------|------|------|-------|
| Phase 0 | | | 7 |
| Phase 1 | | | 15 |
| Phase 2 (varies by scope) | | | |
| Phase 3 | | | 8 |
| Phase 4 | | | 10 |
| First Task | | | 7 |
| Team Readiness | | | 5 |
| **Total** | | | |

---

## Verdict

**[ ] PASSED** - All checks pass. Factory is ready for production use.

**[ ] PASSED WITH CONDITIONS** - Some non-critical checks failed. Factory may be used with documented limitations.

Conditions:
1.
2.
3.

**[ ] FAILED** - Critical checks failed. Do not proceed until resolved.

Blockers:
1.
2.
3.

---

## Blocker Documentation

If FAILED, document each blocker:

### Blocker 1: {{TITLE}}

**Phase:**
**Check:**
**Issue:**
**Resolution Required:**
**Owner:**
**Target Date:**

### Blocker 2: {{TITLE}}

**Phase:**
**Check:**
**Issue:**
**Resolution Required:**
**Owner:**
**Target Date:**

---

## Approval

### Migration Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Migration Lead | | | |
| Product Owner | | | |

### Conditional Approval (if applicable)

| Condition | Accepted By | Expiration |
|-----------|-------------|------------|
| | | |
| | | |

---

## Post-Migration Actions

After approval, complete these actions:

- [ ] Schedule first real task
- [ ] Set up regular progress reviews
- [ ] Plan quality baseline review (30 days)
- [ ] Document lessons learned
- [ ] Update README with factory references

---

## Notes

{{Additional notes about the migration}}
