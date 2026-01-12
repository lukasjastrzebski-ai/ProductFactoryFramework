# Gap Analysis Guide

This guide explains how the gap analysis system works and how to resolve identified gaps.

## Overview

The gap analysis system validates imported documentation against Product Factory stage requirements. It identifies missing content and categorizes gaps by severity.

## Gap Severities

| Severity | Icon | Meaning | Can Skip? |
|----------|------|---------|-----------|
| BLOCKING | 🔴 | Cannot proceed without this content | No (exceptional cases only) |
| HIGH | 🟠 | Should be resolved for quality | Yes, with justification |
| MEDIUM | 🟡 | Recommended for completeness | Yes |
| LOW | 🟢 | Optional enhancement | Yes |

## Stage Requirements

### Stage 0: Idea Intake
- **vision** (BLOCKING): Core product vision and problem statement

### Stage 1: Vision & Strategy
- **strategy** (HIGH): Go-to-market and success strategy
- **metrics** (HIGH): Success metrics and KPIs
- **risks** (MEDIUM): Risk assessment

### Stage 2: Product Definition
- **personas** (HIGH): Target user personas
- **journeys** (MEDIUM): User journey maps

### Stage 3: Features
- **features** (BLOCKING): Feature specifications
- **acceptance_criteria** (BLOCKING): Testable acceptance criteria

### Stage 4: Architecture
- **decisions** (MEDIUM): Architecture Decision Records
- **tech_stack** (HIGH): Technology stack definition

### Stage 5: Implementation Planning
- **tasks** (MEDIUM): Implementation task breakdown

### Additional Checks
- **mvp_scope** (HIGH): MVP feature identification
- **ui_specs** (LOW): UI/UX specifications

## Running Gap Analysis

```bash
# First, parse your imports
./scripts/import/parse_docs.sh

# Then run gap analysis
./scripts/import/analyze_gaps.sh

# Review the report
cat docs/import/validation/gap_analysis.md
```

## Resolving Gaps

### Interactive Resolution

Tell Claude:
```
Help me resolve the planning gaps
```

Claude will guide you through each gap, asking clarifying questions and generating factory artifacts.

### Manual Resolution

Use these commands in your conversation:

| Command | Example | Purpose |
|---------|---------|---------|
| FILL | `FILL: vision Our product helps...` | Provide content for a gap |
| SKIP | `SKIP: risks No significant risks identified` | Skip with justification |
| STATUS | `STATUS` | Check resolution progress |
| PROCEED | `PROCEED` | Attempt to continue |

### Resolution Examples

**Filling a vision gap:**
```
FILL: vision

Our product is a deployment dashboard for DevOps teams.

Problem: Teams lack visibility into deployment status across environments.
Target User: DevOps engineers managing multi-environment deployments.
Solution: Unified dashboard with real-time status, history, and rollback.
```

**Skipping a gap:**
```
SKIP: risks

This is an internal tool with no external users.
Security and compliance risks are managed by existing infrastructure.
```

## Gap Resolution Rules

1. **BLOCKING gaps cannot be skipped** without exceptional justification
2. **Acceptance criteria must be testable** - use checkbox format: `- [ ] User can...`
3. **Features must have at least 2 acceptance criteria**
4. **Tech stack must include version information** when possible
5. **Vision must include problem and target user**

## After Resolution

Once gaps are resolved:

1. Claude generates factory artifacts in appropriate locations:
   - Vision → `docs/product/vision.md`
   - Features → `specs/features/FEAT-XXX.md`
   - Decisions → `architecture/decisions/ADR-XXX.md`

2. Run validation again to confirm:
   ```bash
   ./scripts/import/analyze_gaps.sh
   ```

3. Proceed to execution readiness check

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "No parsed content found" | Run `./scripts/import/parse_docs.sh` first |
| Gap not resolving | Ensure your response is specific and complete |
| Wrong content type detected | Rename source file to include type keyword |
| Script errors | Check file permissions and bash version |

## See Also

- [Import README](../README.md)
- [Factory Stage Guide](../../FACTORY_REFERENCE.md)
- [Skill 13: Gap Resolution](../../skills/skill_13_gap_resolution.md)
