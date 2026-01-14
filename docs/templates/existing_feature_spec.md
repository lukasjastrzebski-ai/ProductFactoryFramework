# Existing Feature Specification Template

**Version:** 20.0

Use this template when documenting existing features for migration into the factory.

---

## Feature Overview

**Feature Name:** [Name]
**Current Location:** [File paths or module names]
**Status:** [Working / Partially Working / Broken]

---

## Current Behavior

### Description

[Describe what the feature currently does]

### Entry Points

- [List entry points: routes, commands, UI elements]

### Dependencies

- [List dependencies: other features, external services, libraries]

---

## User Stories

### As-Is Stories

| ID | Story | Status |
|----|-------|--------|
| US-01 | As a [user], I can [action] so that [benefit] | Working |

---

## Technical Details

### Files Involved

| File | Purpose |
|------|---------|
| `path/to/file.ts` | [Description] |

### Data Flow

```
[Input] → [Processing] → [Output]
```

### Configuration

| Setting | Value | Purpose |
|---------|-------|---------|
| [key] | [value] | [why] |

---

## Quality Baseline

### Existing Tests

| Test | Location | Status |
|------|----------|--------|
| [Test name] | `path/to/test` | Passing |

### Known Issues

| Issue | Severity | Notes |
|-------|----------|-------|
| [Description] | High/Medium/Low | [Context] |

---

## Migration Notes

### Preservation Requirements

- [ ] [What must be preserved during migration]

### Improvement Opportunities

- [ ] [What could be improved]

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk] | High/Medium/Low | High/Medium/Low | [Action] |

---

## Related Documentation

- [Link to related specs]
- [Link to architecture docs]
