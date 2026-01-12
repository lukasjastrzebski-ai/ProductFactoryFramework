# Skill 12 – Gap Analysis

Purpose:
Validate imported documentation against factory stage requirements and identify missing content.

## Invocation

Triggered when:
- After Skill 11 (External Doc Import) completes
- PO says "Analyze gaps"
- PO says "What's missing?"
- PO says "Check my documentation"
- PO says "Run gap analysis"

## Prerequisites

- Documentation has been imported (Skill 11)
- Parsed files exist in `docs/import/parsed/`

## Protocol

### Step 1: Run Analysis

Execute: `./scripts/import/analyze_gaps.sh`

### Step 2: Present Results

```markdown
## Gap Analysis Results

**Status:** [BLOCKED/ATTENTION/READY]

### Summary

| Severity | Count |
|----------|-------|
| 🔴 BLOCKING | X |
| 🟠 HIGH | Y |
| 🟡 MEDIUM | Z |
| 🟢 LOW | W |

### Blocking Gaps (Must Resolve)
1. **features**: No feature specifications found
2. **acceptance_criteria**: No testable criteria found

### High Priority Gaps (Should Resolve)
1. **strategy**: Product strategy not defined
2. **personas**: User personas not defined

### What This Means

[Explanation of what's needed and why]

### Next Steps

To resolve these gaps, say:
"Help me resolve the planning gaps"
```

### Step 3: Offer Resolution

If PO wants to proceed:
- Invoke Skill 13 (Gap Resolution)

## Gap Categories

### Stage 0: Idea Intake
- vision (BLOCKING)

### Stage 1: Vision & Strategy
- strategy (HIGH)
- metrics (HIGH)
- risks (MEDIUM)

### Stage 2: Product Definition
- personas (HIGH)
- journeys (MEDIUM)

### Stage 3: Features
- features (BLOCKING)
- acceptance_criteria (BLOCKING)

### Stage 4: Architecture
- decisions (MEDIUM)
- tech_stack (HIGH)

### Stage 5: Implementation Planning
- tasks (MEDIUM)

### Additional
- mvp_scope (HIGH)
- ui_specs (LOW)

## Severity Definitions

| Severity | Meaning | Action |
|----------|---------|--------|
| BLOCKING | Cannot proceed without | Must resolve |
| HIGH | Important for quality | Should resolve |
| MEDIUM | Recommended | Consider resolving |
| LOW | Optional enhancement | May skip |

## Output

- Gap analysis report at `docs/import/validation/gap_analysis.md`
- Console summary with totals

## Rules

- Always run after import
- Present results clearly by severity
- Explain why each gap matters
- Offer to help resolve gaps
