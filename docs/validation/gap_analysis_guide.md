# Gap Analysis Guide

**Version:** 20.0

This guide explains how to perform gap analysis on imported documentation and planning artifacts.

---

## Overview

Gap analysis identifies missing, incomplete, or inconsistent information in project documentation before execution begins. This ensures planning is complete enough for autonomous execution.

---

## When to Perform Gap Analysis

1. **After importing external docs** - Validate imported content
2. **After completing planning stages** - Verify planning completeness
3. **Before freezing planning** - Final validation check
4. **When execution blocks** - Diagnose missing information

---

## Gap Categories

### BLOCKING Gaps

Must be resolved before execution can proceed.

| Type | Description | Example |
|------|-------------|---------|
| Missing AC | Acceptance criteria not defined | "Feature X has no testable criteria" |
| Undefined Scope | Feature boundaries unclear | "Does 'auth' include 2FA?" |
| Missing Dependencies | Required integrations unknown | "Which payment provider?" |
| Circular Dependencies | Tasks can't be ordered | "A needs B, B needs A" |

### WARNING Gaps

Should be resolved but don't block execution.

| Type | Description | Example |
|------|-------------|---------|
| Incomplete AC | Some criteria vague | "AC says 'fast' - how fast?" |
| Missing Tests | No test plan for feature | "No E2E tests defined" |
| Unclear Priority | Task priority not set | "Which feature first?" |
| Missing Estimates | No complexity estimate | "Task size unknown" |

### INFO Gaps

Informational - nice to have.

| Type | Description | Example |
|------|-------------|---------|
| Missing Context | Background info missing | "Why this approach?" |
| No ADR | Decision not documented | "Why React over Vue?" |
| Sparse Description | Could use more detail | "Task description brief" |

---

## Gap Analysis Process

### Step 1: Inventory Artifacts

List all planning artifacts:

```markdown
## Artifact Inventory

| Type | Count | Location |
|------|-------|----------|
| Feature Specs | [n] | specs/features/ |
| User Stories | [n] | specs/stories/ |
| Architecture Docs | [n] | architecture/ |
| Task Definitions | [n] | plan/tasks/ |
| Test Plans | [n] | docs/quality/ |
```

### Step 2: Check Completeness

For each artifact type, verify required fields:

**Feature Specs Must Have:**
- [ ] Clear description
- [ ] Acceptance criteria (testable)
- [ ] User stories mapped
- [ ] Dependencies listed
- [ ] Out of scope defined

**Tasks Must Have:**
- [ ] Clear objective
- [ ] Acceptance criteria
- [ ] Dependencies
- [ ] Estimated complexity
- [ ] Test requirements

### Step 3: Check Consistency

Cross-reference between artifacts:

- [ ] All user stories map to features
- [ ] All tasks map to stories or features
- [ ] All dependencies exist
- [ ] No circular dependencies
- [ ] Estimates are consistent

### Step 4: Document Gaps

Record all gaps found:

```markdown
## Gap Report

### BLOCKING

| ID | Type | Location | Description |
|----|------|----------|-------------|
| GAP-001 | Missing AC | specs/features/auth.md | No AC for password reset |

### WARNING

| ID | Type | Location | Description |
|----|------|----------|-------------|
| GAP-002 | Vague AC | specs/features/auth.md | "Should be secure" - not testable |

### INFO

| ID | Type | Location | Description |
|----|------|----------|-------------|
| GAP-003 | No ADR | architecture/ | Auth approach not documented |
```

---

## Resolution Process

### For BLOCKING Gaps

1. **Identify owner** - Who can provide the information?
2. **Ask specific questions** - Not "tell me more" but "what is X?"
3. **Validate response** - Is it actionable?
4. **Update artifact** - Add the information
5. **Mark resolved** - Update gap report

### For WARNING Gaps

1. **Assess impact** - Will this cause problems?
2. **Propose default** - Suggest reasonable default
3. **Get confirmation** - PO/DD approves default
4. **Update artifact** - Add with "[DEFAULT]" marker
5. **Mark resolved** - Update gap report

### For INFO Gaps

1. **Log for later** - Add to backlog
2. **Continue execution** - Don't block on these
3. **Resolve opportunistically** - Fix when convenient

---

## Gap Analysis Checklist

### Pre-Execution Checklist

- [ ] All features have testable AC
- [ ] All tasks have clear scope
- [ ] Dependencies are resolvable
- [ ] No circular dependencies
- [ ] External dependencies identified
- [ ] Test coverage planned

### Quality Checklist

- [ ] AC are measurable
- [ ] Estimates are reasonable
- [ ] Architecture supports features
- [ ] Security considered
- [ ] Performance requirements clear

---

## Tools

### Automated Gap Detection

```bash
# Run gap analysis script
./scripts/import/analyze_gaps.sh

# Output to file
./scripts/import/analyze_gaps.sh > docs/import/validation/gap_analysis.md
```

### Gap Resolution Tracking

```bash
# Check resolution progress
cat .factory/resolution_progress.json
```

---

## Related Documentation

- [Gap Analysis Skill](../skills/skill_12_gap_analysis.md)
- [Gap Resolution Skill](../skills/skill_13_gap_resolution.md)
- [External Doc Import](../skills/skill_11_external_doc_import.md)
