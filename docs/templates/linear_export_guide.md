# Linear Export Guide

**Version:** 20.0

Guide for exporting project documentation from Linear for factory import.

---

## Overview

This guide explains how to export Linear issues, projects, and roadmaps in a format compatible with the ProductFactoryFramework import system.

---

## Export Methods

### Method 1: CSV Export

1. **Navigate to Issues view**
2. **Filter to relevant issues**
3. **Click ••• menu → Export → CSV**
4. **Save to `docs/import/raw/linear/`**

### Method 2: API Export (Recommended)

```bash
# Using Linear CLI or API
linear export --project "Project Name" --format markdown
```

### Method 3: Manual Copy

1. Open issue
2. Copy description and comments
3. Paste into markdown template

---

## Export Structure

Place exports in:
```
docs/import/raw/
└── linear/
    ├── projects/
    │   └── project_name.md
    ├── issues/
    │   └── ISSUE-123.md
    ├── cycles/
    │   └── cycle_name.md
    └── roadmap.md
```

---

## Content to Export

### For Projects

- Project name and description
- Goals and success metrics
- Timeline/milestones
- Team assignments

### For Issues

- Title and description
- Acceptance criteria (from description)
- Labels and priority
- Related issues
- Comments (if relevant)

### For Cycles

- Cycle name and dates
- Issues in cycle
- Cycle goals

---

## Markdown Format

### Issue Template

```markdown
# ISSUE-123: [Title]

## Description
[Issue description]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Labels
- Priority: [High/Medium/Low]
- Type: [Feature/Bug/Task]
- Area: [Frontend/Backend/etc]

## Related Issues
- Blocks: ISSUE-XXX
- Blocked by: ISSUE-YYY

## Notes
[Relevant comments]
```

### Project Template

```markdown
# Project: [Name]

## Description
[Project description]

## Goals
1. [Goal 1]
2. [Goal 2]

## Success Metrics
| Metric | Target |
|--------|--------|
| [Metric] | [Value] |

## Issues
| ID | Title | Status |
|----|-------|--------|
| ISSUE-123 | [Title] | [Status] |
```

---

## Mapping to Factory Artifacts

| Linear | Factory |
|--------|---------|
| Project | Feature in specs/ |
| Epic | User Story Group |
| Issue | Task in plan/ |
| Label | Category/Tag |
| Cycle | Phase |

---

## Import Command

After export:
```bash
./scripts/import/parse_docs.sh --source linear
```

---

## Common Issues

### Missing Acceptance Criteria
- Check issue description for bullet points
- Flag as gap if not present

### Circular Dependencies
- Review "blocks/blocked by" relationships
- Report conflicts in gap analysis

---

## Related Documentation

- [External Doc Import](../skills/skill_11_external_doc_import.md)
- [Gap Analysis](../skills/skill_12_gap_analysis.md)
