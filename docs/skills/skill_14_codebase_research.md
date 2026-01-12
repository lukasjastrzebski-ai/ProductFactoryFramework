# Skill 14: Codebase Research

## Purpose

Generate fresh, on-demand research for complex tasks before implementation.
Addresses spec-to-code drift in long-running products.

## When to Use

- Before complex tasks ([COMPLEX] marker)
- When task touches unfamiliar modules
- When specs may be outdated
- When PO requests "research first"

## Inputs

- Task file with scope
- Relevant module paths
- Specific questions to answer

## Process

1) Identify target modules from task scope
2) Run targeted searches:
   - Grep for key functions/classes
   - Read entry points
   - Trace data flow
3) Generate research document:
   - Current code structure
   - Key files and line numbers
   - Discovered patterns
   - Potential conflicts with spec
4) Compare with planning artifacts:
   - Does spec match implementation?
   - Are there undocumented behaviors?
5) Flag discrepancies to PO

## Output

- `docs/execution/research/TASK-XXX-research.md`

## Research Document Template

```markdown
# Research: TASK-XXX

**Generated:** {{DATE}}
**Task:** {{TASK_TITLE}}

## Summary

[One paragraph overview of findings]

## Key Files

| File | Purpose | Relevant Lines |
|------|---------|----------------|
| path/to/file.ts | Description | 100-150 |
| path/to/other.ts | Description | 20-80 |

## Code Flow

[Mermaid diagram or text description of how components interact]

## Spec Alignment

| Spec Reference | Code Reality | Status |
|----------------|--------------|--------|
| specs/features/X.md | Actual implementation | ALIGNED / DRIFT |

## Findings

- Finding 1: [description]
- Finding 2: [description]

## Potential Issues

- Issue 1: [description and risk]

## Recommendations

- Recommendation 1: [actionable guidance]
```

## Rules

- Research is READ-ONLY - no code changes
- Flag all spec drift to PO before proceeding
- Keep research concise (aim for <500 lines)
- Research does NOT authorize implementation
- Still requires GO gate after research

## Integration with Task Runner

Research phase occurs between Task Intake (Step 1) and GO Gate (Step 2):

```
Step 1: Task Intake
    ↓
[Skill 14: Research] ← Optional, for complex tasks
    ↓
Step 2: GO Gate
```

If research reveals spec drift or missing information:
- STOP
- Flag to PO
- Route to CR if spec needs updating
