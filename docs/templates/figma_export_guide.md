# Figma Export Guide

**Version:** 20.0

Guide for exporting design documentation from Figma for factory import.

---

## Overview

This guide explains how to export Figma designs in a format compatible with the ProductFactoryFramework import system.

---

## Export Methods

### Method 1: Manual Export (Recommended)

1. **Open Figma file**
2. **Select frames to export**
3. **Right-click → Copy as → Copy as text**
4. **Paste into markdown file**

### Method 2: Plugin Export

Use the "Design Docs" Figma plugin:
1. Install plugin from Figma Community
2. Select frames
3. Run plugin → Export to Markdown
4. Save output to `docs/import/raw/figma/`

---

## Export Structure

Place exports in:
```
docs/import/raw/
└── figma/
    ├── screens/
    │   ├── screen_name.md
    │   └── screen_name.png
    ├── components/
    │   └── component_name.md
    └── flows/
        └── flow_name.md
```

---

## Content to Export

### For Each Screen

- Screen name and purpose
- Component breakdown
- Interaction states
- Responsive variations
- Annotations/notes

### For Each Component

- Component name
- Variants
- Properties
- Usage guidelines

### For Flows

- Flow name
- Step sequence
- Decision points
- Error states

---

## Markdown Format

```markdown
# Screen: [Name]

## Purpose
[Description]

## Components
- [Component 1]
- [Component 2]

## States
| State | Description |
|-------|-------------|
| Default | [desc] |
| Hover | [desc] |
| Active | [desc] |

## Responsive
- Desktop: [behavior]
- Tablet: [behavior]
- Mobile: [behavior]

## Notes
[Designer annotations]
```

---

## Image Export

For visual reference:
1. Select frame
2. Export as PNG (2x)
3. Name: `screen_name.png`
4. Place alongside markdown file

---

## Import Command

After export:
```bash
./scripts/import/parse_docs.sh --source figma
```

---

## Troubleshooting

### Missing Components
- Ensure all nested components are included
- Check for external library dependencies

### Broken Links
- Update links to use relative paths
- Replace Figma URLs with local references

---

## Related Documentation

- [External Doc Import](../skills/skill_11_external_doc_import.md)
- [Gap Analysis](../skills/skill_12_gap_analysis.md)
