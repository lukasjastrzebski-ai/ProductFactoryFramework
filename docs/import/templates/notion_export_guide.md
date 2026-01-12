# Notion Export Guide

How to export Notion content for Product Factory import.

## Step 1: Identify Content to Export

Locate pages containing:
- Product vision and strategy
- Feature descriptions
- User stories and requirements
- Technical specifications
- Meeting notes with decisions

## Step 2: Export from Notion

### Option A: Page Export (Recommended)

1. Open the Notion page
2. Click `...` menu -> `Export`
3. Select format: **Markdown & CSV**
4. Include subpages: **Yes** (if applicable)
5. Download and extract

### Option B: Database Export

1. Open the Notion database
2. Click `...` menu -> `Export`
3. Select format: **CSV** or **Markdown**
4. Download

## Step 3: Organize Exports

Place exported files in `docs/import/sources/notion/`:

```
docs/import/sources/notion/
├── vision.md
├── features/
│   ├── feature_auth.md
│   ├── feature_dashboard.md
│   └── feature_reports.md
├── requirements.md
└── decisions.md
```

## Step 4: Add Metadata (Optional)

Create `docs/import/sources/notion/manifest.json`:

```json
{
  "exported_at": "2024-01-15",
  "source_workspace": "Acme Product",
  "files": [
    {"file": "vision.md", "type": "vision"},
    {"file": "features/", "type": "features"},
    {"file": "requirements.md", "type": "requirements"}
  ]
}
```

## Content Structure Tips

### For Best Import Results

Structure your Notion pages with clear headers:

```markdown
# Feature: User Authentication

## Problem
[Description of the problem]

## User Stories
- As a [user], I want [goal], so that [benefit]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Technical Notes
[Any technical considerations]
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Images not exported | Re-export with "Include files" option |
| Formatting lost | Use Markdown export, not PDF |
| Nested pages missing | Enable "Include subpages" |
| Database views lost | Export each view separately |
