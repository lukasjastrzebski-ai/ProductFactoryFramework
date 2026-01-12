# External Documentation Import System

This system enables importing partial documentation from external tools into the Product Factory framework.

## Supported Tools

| Tool | Export Formats | Content Types |
|------|----------------|---------------|
| Notion | Markdown, JSON | Vision, features, requirements, user stories |
| Figma | JSON, Links | UI specs, component specs, design system |
| Linear | CSV, JSON | Issues, epics, milestones, acceptance criteria |
| Other | Markdown, YAML | Any structured content |

## Directory Structure

```
docs/import/
├── sources/          # Place exported files here
│   ├── notion/       # Notion markdown/JSON exports
│   ├── figma/        # Figma JSON exports or link files
│   ├── linear/       # Linear CSV/JSON exports
│   └── other/        # Other tool exports
├── parsed/           # Auto-generated parsed content
├── validation/       # Gap analysis reports
└── templates/        # Export guides per tool
```

## Quick Start

1. Export documentation from your external tool
2. Place exports in appropriate `sources/` subdirectory
3. Run: `./scripts/import/parse_docs.sh`
4. Run: `./scripts/import/analyze_gaps.sh`
5. Review: `docs/import/validation/gap_analysis.md`
6. Iterate with Claude to resolve gaps

## Content Mapping

| External Content | Factory Artifact |
|------------------|------------------|
| Product vision | docs/product/vision.md |
| Strategy | docs/product/strategy.md |
| User personas | docs/product/personas.md |
| Feature descriptions | specs/features/*.md |
| Acceptance criteria | specs/features/*.md (AC section) |
| UI specifications | specs/features/*.md + architecture/ |
| Technical decisions | architecture/decisions/ADR-*.md |
| Issues/Tasks | plan/tasks/TASK-*.md |
| Milestones | plan/phases/*.md |

## Validation

After import, the gap analysis identifies:
- **BLOCKING** - Missing content required for factory operation
- **HIGH** - Important content that should be provided
- **MEDIUM** - Recommended content for completeness
- **LOW** - Optional enhancements

## See Also

- [Gap Analysis Guide](validation/gap_analysis_guide.md)
- [Notion Export Guide](templates/notion_export_guide.md)
- [Figma Export Guide](templates/figma_export_guide.md)
- [Linear Export Guide](templates/linear_export_guide.md)
