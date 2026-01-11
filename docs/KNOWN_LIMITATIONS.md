# Known Limitations

Radical honesty about what this factory does and does not do.

## What is Manual

The following activities require human effort and judgment:

### Planning stages (0-7)

- Populating idea intake, vision, strategy documents
- Making product decisions
- Writing feature specifications
- Defining acceptance criteria
- Designing architecture
- Creating implementation tasks
- Validating readiness

Claude may assist in these activities, but the Product Owner must validate all outputs. The factory does not auto-generate valid planning artifacts.

### Gate decisions

- GO/NEXT/STOP/BLOCKED responses are human decisions
- Change Request approvals are human decisions
- New Feature approvals are human decisions
- Quality gate pass/fail is ultimately a human judgment informed by evidence

### Signal interpretation

- Deciding what signals mean
- Prioritizing based on signals
- Overriding automated recommendations

## What is Not Automated

### Test generation

The factory requires tests but does not auto-generate them. Claude Code writes tests during task execution, but:
- Test quality depends on Task Test Delta clarity
- Test coverage is not automatically measured
- Flaky test detection is not automated

### Report verification

CI checks that reports exist and have required sections, but:
- Report accuracy is not automatically verified
- Acceptance criteria claims are not automatically validated
- Scope adherence is not automatically confirmed

### Planning artifact validation

CI checks that files exist, but:
- Spec quality is not automatically assessed
- Acceptance criteria testability is not automatically verified
- Architecture soundness is not automatically evaluated

### Memory accuracy

Memory is used for recall, but:
- Memory contents are not automatically validated against files
- Memory drift over sessions is not automatically detected
- Memory-file conflicts require manual resolution

## Where Human Judgment is Required

| Area | Why human judgment needed |
|------|--------------------------|
| Is this acceptance criterion testable? | Requires understanding of test feasibility |
| Is this task atomic enough? | Requires estimation experience |
| Is this scope change a CR or NF? | Requires product judgment |
| Is this regression critical? | Requires business context |
| Should this signal drive action? | Requires strategic context |
| Is this report complete? | Requires domain knowledge |
| Is this quality baseline appropriate? | Requires risk tolerance assessment |

## Known Structural Gaps

### Empty directories (template state)

The following directories exist but are empty in the template:

| Directory | Purpose | Status |
|-----------|---------|--------|
| `signals/` | Signal snapshot data | Empty - populated during operation |
| `specs/features/` | Feature specifications | Empty - populated during Stage 3 |
| `specs/tests/` | Feature test plans | Empty - populated during Stage 3 |
| `plan/tasks/` | Task files | README only - populated during Stage 5 |
| `plan/phases/` | Phase definitions | README only - populated during Stage 5 |
| `docs/execution/reports/` | Completion reports | Empty - populated during execution |
| `docs/requests/gates/` | Approval gates | .gitkeep only - populated during CR/NF flows |
| `00_bootstrap/template_docs/` | Bootstrap templates | Empty |

### Missing product artifacts

The ideation_playbook.md references outputs in `docs/product/` which does not exist in the template:
- idea_intake.md
- vision.md
- strategy.md
- metrics.md
- risks.md
- definition.md
- personas.md
- journeys.md
- non_goals.md

These must be created during Stages 0-2 of planning.

### No init_session.sh implemented

The initializer agent pattern ([docs/patterns/initializer_agent.md](patterns/initializer_agent.md)) describes `.factory/init_session.sh` but this script does not exist in the template. It must be created if using the initializer pattern.

## Assumptions Baked Into the Factory

### Claude Code as executor

The factory assumes Claude Code is the implementation agent. Other AI tools may work but are not explicitly supported.

### File-based discipline

The factory assumes all state is in files. External tools (Jira, Linear, etc.) are not integrated.

### Git-based version control

The factory assumes git is used. The CI workflows, freeze validation, and worktree patterns depend on git.

### Markdown as primary format

All factory documents are Markdown. JSON is used for progress.json and settings. No other formats are supported.

### Single Product Owner

The factory is designed for a single decision-maker. Multi-stakeholder governance is not built in.

### English language

All templates and documentation are in English. Localization is not supported.

### GitHub CI

The CI workflows are GitHub Actions. Adaptation to other CI systems requires manual effort.

## What the Factory Cannot Prevent

### Operator mistakes

The factory enforces discipline through CI and Claude constraints, but:
- Operators can merge broken PRs
- Operators can accept incomplete reports
- Operators can approve scope changes without proper analysis

### Claude hallucination

Despite constraints, Claude may:
- Make incorrect claims about test results
- Miss edge cases in implementation
- Misinterpret specifications

Human verification remains essential.

### External failures

The factory does not handle:
- Third-party service outages
- Hardware failures
- Network issues
- External dependency changes

### Planning errors

If planning is incomplete or incorrect, execution will be flawed. The factory enforces that planning exists, not that planning is correct.

## Risk Acknowledgments

| Risk | Mitigation in factory | Residual risk |
|------|----------------------|---------------|
| Scope creep | GO gate, frozen artifacts | Operator may accept unauthorized changes |
| Test gaps | Test Delta requirement, CI checks | Test quality not automatically assessed |
| Report fraud | Report existence checks, signature verification | Report accuracy not automatically verified |
| Memory conflicts | File authority rule | Requires operator vigilance |
| Planning gaps | Readiness checklist | Checklist items are checkbox, not validation |

## Improvement Areas

The factory tracks improvements via:
- [docs/lessons_learned.md](lessons_learned.md) - Process for capturing lessons
- [docs/factory/lessons/](factory/lessons/) - Individual lessons (template at LL-TEMPLATE.md)
- CHANGELOG.md - Version history

Factory evolution is evidence-driven, not impulsive.
