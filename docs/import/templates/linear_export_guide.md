# Linear Export Guide

How to export Linear issues for Product Factory import.

## Export Options

### Option 1: CSV Export

1. Go to Linear -> Issues view
2. Filter to relevant project/team
3. Click `...` -> `Export` -> `CSV`
4. Save to `docs/import/sources/linear/issues.csv`

### Option 2: API Export

```bash
# Using Linear CLI or API
linear export --project "Project Name" --format json \
  > docs/import/sources/linear/issues.json
```

### Option 3: Integration Sync

Configure webhook to sync issues automatically (advanced).

## CSV Column Mapping

| Linear Column | Factory Mapping |
|---------------|-----------------|
| Title | Task/Feature name |
| Description | Specification content |
| Labels | Feature category, MVP flag |
| Priority | Task priority |
| Estimate | Task complexity |
| Acceptance Criteria | AC in feature spec |
| Epic | Phase grouping |
| Milestone | Roadmap milestone |

## Organizing Exports

### By Epic/Feature

```
docs/import/sources/linear/
├── issues.csv           # All issues
├── epics/
│   ├── auth.csv         # Authentication epic
│   ├── dashboard.csv    # Dashboard epic
│   └── reporting.csv    # Reporting epic
└── milestones.json      # Milestone definitions
```

### Manifest File

Create `docs/import/sources/linear/manifest.json`:

```json
{
  "exported_at": "2024-01-15",
  "project": "Acme Product",
  "filters_applied": ["status:backlog,todo,in-progress"],
  "epic_mapping": {
    "AUTH": "FEAT-001",
    "DASH": "FEAT-002",
    "REPORT": "FEAT-003"
  }
}
```

## Best Practices

### Issue Structure for Import

Write Linear issues with clear structure:

```
Title: User can reset password via email

Description:
## User Story
As a user who forgot my password, I want to reset it via email link.

## Acceptance Criteria
- [ ] User can request password reset
- [ ] Email is sent within 30 seconds
- [ ] Reset link expires after 24 hours
- [ ] User can set new password meeting requirements

## Technical Notes
- Uses existing email service
- Tokens stored in Redis with TTL
```

### Labels for Categorization

| Label | Purpose |
|-------|---------|
| `mvp` | Identifies MVP features |
| `feature:auth` | Groups by feature |
| `type:bug` | Distinguishes bugs from features |
| `needs-spec` | Flags incomplete items |
