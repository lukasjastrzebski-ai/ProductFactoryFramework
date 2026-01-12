# Skill 11 – External Documentation Import

Purpose:
Parse and import external documentation from tools like Notion, Figma, and Linear into factory-compatible format.

## Invocation

Triggered when:
- PO places files in `docs/import/sources/`
- PO says "Import my documentation"
- PO says "Parse my exports"
- PO says "I have documentation from [Notion/Figma/Linear]"

## Prerequisites

- External documentation exported from source tool
- Files placed in appropriate `docs/import/sources/` subdirectory

## Protocol

### Step 1: Check for Source Files

```
Check: docs/import/sources/notion/
Check: docs/import/sources/figma/
Check: docs/import/sources/linear/
Check: docs/import/sources/other/
```

### Step 2: Guide Export (if needed)

If no files found:

```markdown
## Import External Documentation

I don't see any files in the import sources directory yet.

**To import documentation:**

1. Export from your tool:
   - [Notion Export Guide](../import/templates/notion_export_guide.md)
   - [Figma Export Guide](../import/templates/figma_export_guide.md)
   - [Linear Export Guide](../import/templates/linear_export_guide.md)

2. Place exported files in:
   ```
   docs/import/sources/
   ├── notion/   # Notion .md or .json files
   ├── figma/    # Figma .json or .md files
   ├── linear/   # Linear .csv or .json files
   └── other/    # Other formats
   ```

3. Tell me when ready: "Parse my imports"

Which tool did you export from?
```

### Step 3: Run Parser

Execute: `./scripts/import/parse_docs.sh`

Report results:
```markdown
## Import Results

**Parsed:** X files
**Failed:** Y files

### Successfully Imported:
- notion_vision.json (vision)
- linear_issues.json (tasks)

### Next Steps:
1. Run gap analysis to identify missing content
2. Resolve any gaps with Claude's help

Shall I run the gap analysis now?
```

### Step 4: Trigger Gap Analysis

If PO confirms, invoke Skill 12 (Gap Analysis).

## Supported Formats

| Tool | Formats | Content Types |
|------|---------|---------------|
| Notion | .md, .json | vision, strategy, features, requirements |
| Figma | .json, .md | ui_specs, components, design_system |
| Linear | .csv, .json | issues, epics, tasks, milestones |

## Content Type Detection

Parsers detect content type from:
1. Filename keywords (vision, feature, task, etc.)
2. Content patterns (headers, checkboxes, etc.)

## Output

- Parsed JSON files in `docs/import/parsed/`
- Import report at `docs/import/validation/import_report.md`

## Rules

- Never modify source files
- Always generate import report
- Gracefully handle malformed files
- Detect content types automatically
