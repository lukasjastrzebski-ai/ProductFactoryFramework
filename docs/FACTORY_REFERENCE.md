# Factory Reference

Deep reference documentation for the Product Factory.

## Authority Hierarchy

When sources conflict, apply this order (source: [docs/ai.md](ai.md)):

| Priority | Source | Type |
|----------|--------|------|
| 1 | docs/ai.md | Binding contract |
| 2 | specs/, architecture/, plan/ | Frozen specifications |
| 3 | docs/execution/* | Execution guidance |
| 4 | Memory and chat | Context only |

**Decision rule:** If sources conflict, the lower-numbered source always wins.

Files always override chat and memory.

## Marker Files

### Location: .factory/

| Marker | Created by | Meaning |
|--------|-----------|---------|
| `KICKOFF_COMPLETE` | Kickoff process | Factory initialized for product |
| `PLANNING_FROZEN` | Stage 7 completion | specs/, architecture/, plan/ are read-only |
| `STAGE_7_COMPLETE` | Stage 7 completion | AI contract finalized |
| `RUN_MODE` | Mode transition | Contains "PLANNING" or "EXECUTION" |
| `LAST_KNOWN_GOOD_SHA` | Various | Git SHA of last validated state |
| `factory_version.txt` | Kickoff | Copied from FACTORY_VERSION |

### CI enforcement

The `factory-guardrails.yml` workflow validates markers exist as appropriate (source: [.github/workflows/factory-guardrails.yml](../.github/workflows/factory-guardrails.yml)):
- `KICKOFF_COMPLETE` must always exist
- `STAGE_7_COMPLETE` and `PLANNING_FROZEN` must exist in execution mode

## Directory Responsibilities

| Directory | Purpose | Frozen after Stage 7? |
|-----------|---------|----------------------|
| `.factory/` | Marker files for factory state | No (markers may be added) |
| `.claude/` | Claude Code configuration | No |
| `.github/workflows/` | CI workflow definitions | No |
| `architecture/` | System design and ADRs | Yes |
| `architecture/decisions/` | Architecture Decision Records | Yes |
| `docs/` | All documentation | No (execution docs updated) |
| `docs/execution/` | Execution state, reports, playbooks | No |
| `docs/execution/reports/` | Task completion reports | No |
| `docs/migration/` | Migration guide for existing projects | No |
| `docs/migration/templates/` | Migration assessment and baseline templates | No |
| `docs/quality/` | Quality standards | No |
| `docs/requests/` | Change and feature request flows | No |
| `docs/signals/` | Signal definitions | No |
| `docs/skills/` | Claude Code skills | No |
| `plan/` | Implementation plan | Yes |
| `plan/phases/` | Phase definitions | Yes |
| `plan/tasks/` | Task definitions | Yes |
| `signals/` | Signal snapshot data | No |
| `specs/` | Feature specifications | Yes |
| `specs/_templates/` | Spec templates | Yes |
| `specs/features/` | Feature specs | Yes |
| `specs/tests/` | Feature test plans | Yes |
| `tools/` | Validation scripts | No |

## Skills Overview

Skills are structured operating procedures for Claude Code. They do not replace the task runner or execution rules (source: [docs/skills/README.md](skills/README.md)).

| Skill | Purpose | Source |
|-------|---------|--------|
| 01 - Context Loader | Load authoritative context before execution | [skill_01](skills/skill_01_context_loader.md) |
| 02 - Task Intake | Safely ingest a task before execution | [skill_02](skills/skill_02_task_intake.md) |
| 03 - Test Alignment | Ensure test discipline before coding | [skill_03](skills/skill_03_test_alignment.md) |
| 04 - Implementation | Execute scoped implementation after GO | [skill_04](skills/skill_04_implementation.md) |
| 05 - Run Checks | Execute commands and validate outcomes | [skill_05](skills/skill_05_run_checks.md) |
| 06 - Write Report | Persist execution outcome to disk | [skill_06](skills/skill_06_write_report.md) |
| 07 - Update State | Keep execution state accurate | [skill_07](skills/skill_07_update_state.md) |
| 08 - Next Task Recommendation | Suggest next action without authorizing | [skill_08](skills/skill_08_next_task_recommendation.md) |
| 09 - CR/NF Router | Route scope changes to correct flow | [skill_09](skills/skill_09_cr_new_feature_router.md) |
| 10 - Signal Snapshot and Decision | Generate decision inputs from signals | [skill_10](skills/skill_10_signal_snapshot_and_decision.md) |
| 11 - External Doc Import | Parse external tool exports | [skill_11](skills/skill_11_external_doc_import.md) |
| 12 - Gap Analysis | Validate completeness against factory requirements | [skill_12](skills/skill_12_gap_analysis.md) |
| 13 - Gap Resolution | Iterate with PO to fill planning gaps | [skill_13](skills/skill_13_gap_resolution.md) |

### Skill rules

- Skills never expand scope
- Skills never bypass GO/NEXT
- Skills never override files
- If a skill conflicts with docs/ai.md or task_runner.md, the skill is wrong

### Invocation model

Skills are invoked internally by Claude to maintain discipline. They are not commands the operator issues. The operator issues:
- Task requests (e.g., "Run TASK-XXX via the task runner")
- Gate responses (GO, NEXT, STOP, BLOCKED)

## CI Workflows

### factory-guardrails.yml (source: [.github/workflows/factory-guardrails.yml](../.github/workflows/factory-guardrails.yml))

**Trigger:** Pull requests and pushes to main

**Steps:**
1. Validate kickoff complete (`.factory/KICKOFF_COMPLETE`)
2. Validate planning freeze markers in execution mode
3. Validate COMPLETE tasks have reports
4. Validate Test Delta for in-progress tasks
5. Validate gate approvals for CR/NF execution
6. Validate MVP features have test plans
7. Validate report content (Summary, Tests, Acceptance criteria sections)
8. Verify report signatures (optional, non-blocking)

### quality-autopilot.yml (source: [.github/workflows/quality-autopilot.yml](../.github/workflows/quality-autopilot.yml))

**Trigger:** Pull requests and pushes to main

**Steps:**
1. Install dependencies (pnpm if pnpm-lock.yaml exists)
2. Run unit tests (`pnpm test` if package.json exists)

## Signals System

### Signal contract (source: [docs/signals/signal_contract.md](signals/signal_contract.md))

Required fields for every signal:
- name
- source
- timestamp
- value
- trend (up / down / flat)
- confidence (high / medium / low)

### Signal sources (source: [docs/signals/signal_sources.md](signals/signal_sources.md))

| Category | Examples |
|----------|----------|
| Analytics | activation rate, retention, conversion, funnel drop-offs |
| Errors | CI failure rate, production error rate, crash rate |
| Performance | p95/p99 latency, timeout rate, job failures |
| Revenue | MRR, churn, ARPU, failed payments |
| Manual PO | strategic pivots, customer feedback, compliance concerns |

### Signal snapshot (source: [docs/signals/signal_snapshot.md](signals/signal_snapshot.md))

Point-in-time summary used as input to decision engine. Includes:
- Metadata (date, product, generated_by, data sources)
- Signal entries with value, trend, confidence
- Interpretation summary

Snapshots do not mandate actions.

### PO Override (source: [docs/signals/po_override.md](signals/po_override.md))

Manual PO signals override automated recommendations. Used for:
- Strategic pivots
- Customer commitments
- Legal/compliance issues
- Existential business risks

## Decision Engine

### Gate (source: [docs/decision_engine/decision_gate.md](decision_engine/decision_gate.md))

Decision engine outputs do NOT trigger execution automatically. Execution requires explicit Product Owner approval.

### Inputs (source: [docs/decision_engine/decision_inputs.md](decision_engine/decision_inputs.md))

**Allowed inputs:**
- Signal snapshots
- Execution state
- Open tasks and phases
- Known regressions
- Manual PO overrides

**Forbidden inputs:**
- Chat-only context
- Unverified memory
- Speculation
- Partial or stale signals

### Rules (source: [docs/decision_engine/decision_rules.md](decision_engine/decision_rules.md))

Priority order:
1. Critical regressions
2. Blocked execution issues
3. Planned tasks in current phase
4. High-confidence signal-driven improvements
5. New features (after impact analysis)

## Quality Gates

### Pass criteria (source: [docs/quality/quality_gate.md](quality/quality_gate.md))

Execution may continue if:
- All required tests pass
- No known regressions exist
- Acceptance criteria met
- Quality baseline respected

### Fail criteria (source: [docs/quality/quality_gate.md](quality/quality_gate.md))

Execution must STOP if:
- Critical tests fail
- Regressions detected
- Reports incomplete
- Quality baseline violated

### Quality baseline (source: [docs/quality/quality_baseline.md](quality/quality_baseline.md))

Minimum standards:
- Code compiles and runs
- No unused variables or dead code
- Linting passes
- New logic has test coverage
- Critical paths have integration/E2E coverage
- Bug fixes include regression tests
- No known performance or security regressions

### Regression rules (source: [docs/quality/quality_regression_rules.md](quality/quality_regression_rules.md))

Response to regression:
1. STOP execution
2. Identify scope
3. Fix immediately, rollback, or open Change Request

Skipping regressions is forbidden.

## Templates

| Template | Purpose | Location |
|----------|---------|----------|
| Task | Task file structure | [specs/_templates/task.md](../specs/_templates/task.md) |
| Feature Spec | Feature specification structure | [specs/_templates/feature_spec.md](../specs/_templates/feature_spec.md) |
| Feature Test Plan | Test plan for features | [specs/_templates/feature_test_plan.md](../specs/_templates/feature_test_plan.md) |
| ADR | Architecture Decision Record | [architecture/decisions/ADR-TEMPLATE.md](../architecture/decisions/ADR-TEMPLATE.md) |
| Task Report | Completion report | [docs/execution/task_report_template.md](execution/task_report_template.md) |
| Execution Readiness | Stage 6 checklist | [plan/EXECUTION_READINESS_TEMPLATE.md](../plan/EXECUTION_READINESS_TEMPLATE.md) |
| Change Intake | CR intake form | [docs/requests/templates/change_intake.md](requests/templates/change_intake.md) |
| Feature Intake | NF intake form | [docs/requests/templates/feature_intake.md](requests/templates/feature_intake.md) |
| Impact Analysis | Change impact analysis | [docs/requests/templates/impact_analysis.md](requests/templates/impact_analysis.md) |
| Regression Plan | Regression test plan | [docs/requests/templates/regression_plan.md](requests/templates/regression_plan.md) |
| Execution Gate | Gate approval form | [docs/requests/templates/execution_gate.md](requests/templates/execution_gate.md) |
| Migration Assessment | Project evaluation for migration | [docs/migration/templates/migration_assessment.md](migration/templates/migration_assessment.md) |
| Existing Feature Spec | Retroactive feature documentation | [docs/migration/templates/existing_feature_spec.md](migration/templates/existing_feature_spec.md) |
| Retroactive ADR | Past decision documentation | [docs/migration/templates/retroactive_adr.md](migration/templates/retroactive_adr.md) |
| Quality Baseline | Quality metrics baseline | [docs/migration/templates/quality_baseline.md](migration/templates/quality_baseline.md) |
| Migration Readiness | Migration validation checklist | [docs/migration/templates/migration_readiness_checklist.md](migration/templates/migration_readiness_checklist.md) |

## Validation Tools

| Tool | Purpose | Location |
|------|---------|----------|
| validate_required_files.sh | Check for required factory files | [tools/validate_required_files.sh](../tools/validate_required_files.sh) |
| validate_planning_freeze.sh | Verify frozen files unchanged | [tools/validate_planning_freeze.sh](../tools/validate_planning_freeze.sh) |
| validate_factory_links.sh | Check markdown link validity | [tools/validate_factory_links.sh](../tools/validate_factory_links.sh) |
| sign_report.sh | Sign/verify execution reports | [tools/sign_report.sh](../tools/sign_report.sh) |
| generate_signal_snapshot.sh | Generate signal snapshots | [scripts/signals/generate_signal_snapshot.sh](../scripts/signals/generate_signal_snapshot.sh) |

## External Documentation Import

### Supported Tools

| Tool | Parser | Formats |
|------|--------|---------|
| Notion | scripts/import/parsers/notion_parser.sh | md, json |
| Figma | scripts/import/parsers/figma_parser.sh | json, md |
| Linear | scripts/import/parsers/linear_parser.sh | csv, json |

### Import Scripts

| Script | Purpose | Location |
|--------|---------|----------|
| parse_docs.sh | Main import orchestrator | [scripts/import/parse_docs.sh](../scripts/import/parse_docs.sh) |
| analyze_gaps.sh | Validate against factory requirements | [scripts/import/analyze_gaps.sh](../scripts/import/analyze_gaps.sh) |

### Gap Severities

| Severity | Icon | Meaning | Can Skip? |
|----------|------|---------|-----------|
| BLOCKING | 🔴 | Cannot proceed without | No (exceptional cases only) |
| HIGH | 🟠 | Should resolve | Yes, with justification |
| MEDIUM | 🟡 | Recommended | Yes |
| LOW | 🟢 | Optional | Yes |

### Generated Reports

| Report | Location |
|--------|----------|
| Import report | docs/import/validation/import_report.md |
| Gap analysis | docs/import/validation/gap_analysis.md |
| Resolution progress | docs/import/validation/resolution_progress.json |

### Import Directory Structure

```
docs/import/
├── README.md
├── config.json
├── sources/          # Place exported files here
│   ├── notion/
│   ├── figma/
│   ├── linear/
│   └── other/
├── parsed/           # Auto-generated parsed content
├── validation/       # Gap analysis reports
└── templates/        # Export guides per tool
```

### Related Documentation

- [Import System README](import/README.md)
- [Gap Analysis Guide](import/validation/gap_analysis_guide.md)
- [Notion Export Guide](import/templates/notion_export_guide.md)
- [Figma Export Guide](import/templates/figma_export_guide.md)
- [Linear Export Guide](import/templates/linear_export_guide.md)
