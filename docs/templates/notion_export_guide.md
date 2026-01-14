# Notion Export Guide

**Version:** 20.0

Guide for exporting project documentation from Notion for factory import.

---

## Overview

This guide explains how to export Notion pages and databases in a format compatible with the ProductFactoryFramework import system.

---

## Export Methods

### Method 1: Page Export (Individual)

1. **Open Notion page**
2. **Click ••• menu (top right)**
3. **Export → Markdown & CSV**
4. **Select "Include subpages"**
5. **Download and extract**

### Method 2: Workspace Export (Bulk)

1. **Settings & Members**
2. **Settings → Export all workspace content**
3. **Select Markdown & CSV format**
4. **Download and extract**

### Method 3: API Export (Advanced)

```bash
# Using Notion API
notion-export --database "Database ID" --format markdown
```

---

## Export Structure

Place exports in:
```
docs/import/raw/
└── notion/
    ├── pages/
    │   └── page_name.md
    ├── databases/
    │   ├── database_name.csv
    │   └── database_name/
    │       └── row_name.md
    └── assets/
        └── images/
```

---

## Content to Export

### For Pages

- Page title and content
- Nested pages (subpages)
- Linked databases
- Embedded content

### For Databases

- Database schema (columns)
- All rows as individual pages
- Relations between databases
- Rollups and formulas (as values)

---

## Handling Notion Features

### Databases

| Notion Feature | Export Format |
|----------------|---------------|
| Table view | CSV + individual MD files |
| Relations | Links in markdown |
| Rollups | Computed values |
| Formulas | Computed values |
| Select/Multi-select | Plain text |

### Rich Content

| Notion Feature | Export Format |
|----------------|---------------|
| Toggle blocks | Collapsible markdown |
| Callouts | Blockquotes |
| Code blocks | Fenced code |
| Embeds | Links |
| Images | Separate files |

---

## Markdown Format

### Page Template

```markdown
# [Page Title]

## Overview
[Page content]

## Sections
[Organized content]

## Related
- [Links to related pages]

---
*Exported from Notion on [date]*
```

### Database Row Template

```markdown
# [Row Title]

| Property | Value |
|----------|-------|
| Status | [value] |
| Priority | [value] |
| [etc] | [value] |

## Description
[Content from page]

## Notes
[Additional content]
```

---

## Post-Export Processing

### Fix Common Issues

1. **Broken links:** Update to relative paths
2. **Missing images:** Check assets folder
3. **Duplicate IDs:** Rename files uniquely
4. **Empty pages:** Remove or flag

### Organize Structure

```bash
# Suggested organization script
./scripts/import/organize_notion.sh docs/import/raw/notion/
```

---

## Mapping to Factory Artifacts

| Notion | Factory |
|--------|---------|
| Product Spec page | specs/features/ |
| PRD database | specs/ |
| Architecture page | architecture/ |
| Sprint database | plan/phases/ |
| Task database | plan/tasks/ |
| Meeting notes | docs/decisions/ |

---

## Import Command

After export:
```bash
./scripts/import/parse_docs.sh --source notion
```

---

## Common Issues

### Sync Blocks
- Exported as regular content
- May have duplicates

### Linked Databases
- Export each source database
- Update links manually

### Permissions
- Ensure export access to all pages
- Check for private pages

---

## Related Documentation

- [External Doc Import](../skills/skill_11_external_doc_import.md)
- [Gap Analysis](../skills/skill_12_gap_analysis.md)
