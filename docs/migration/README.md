# Migration Guide Index

This directory contains comprehensive documentation for adopting the Product Factory Framework on existing projects.

---

## Migration vs Ideation Playbook

| Approach | Use Case | Starting Point |
|----------|----------|----------------|
| **Ideation Playbook** | New projects, greenfield development | Start from Stage 0 with a raw idea |
| **Migration Guide** | Existing projects with code and features | Document what exists, establish baseline |

### When to Use Migration

Use this migration guide when:
- You have an existing codebase with working features
- You want to adopt factory discipline without rewriting code
- You need to establish quality baselines for existing code
- You want to bring structure to an ad-hoc development process

### When to Use Ideation Playbook

Use the [Ideation Playbook](../ideation_playbook.md) when:
- Starting a brand new project from scratch
- You have only an idea, no existing code
- You want the full planning-first approach
- You're building a greenfield product

---

## Migration Phases

| Phase | Name | Purpose | Time Estimate |
|-------|------|---------|---------------|
| 0 | [Assessment](phase_0_assessment.md) | Evaluate existing project state | 1-2 hours |
| 1 | [Structure](phase_1_structure.md) | Set up factory file structure | 30-60 minutes |
| 2 | [Artifacts](phase_2_artifacts.md) | Create retroactive specifications | 2-4 hours |
| 3 | [Quality](phase_3_quality.md) | Establish quality baseline | 1-2 hours |
| 4 | [Activation](phase_4_activation.md) | Enable factory execution | 30-60 minutes |

**Total estimated time: 5-13 hours** (varies by project size and complexity)

---

## Documentation

| Document | Purpose |
|----------|---------|
| [Migration Guide](migration_guide.md) | Complete migration walkthrough |
| [Phase 0: Assessment](phase_0_assessment.md) | Inventory and scope evaluation |
| [Phase 1: Structure](phase_1_structure.md) | File and directory setup |
| [Phase 2: Artifacts](phase_2_artifacts.md) | Specification creation |
| [Phase 3: Quality](phase_3_quality.md) | Quality baseline establishment |
| [Phase 4: Activation](phase_4_activation.md) | Factory enablement |

---

## Templates

| Template | Purpose |
|----------|---------|
| [Migration Assessment](templates/migration_assessment.md) | Project evaluation worksheet |
| [Existing Feature Spec](templates/existing_feature_spec.md) | Document existing features |
| [Retroactive ADR](templates/retroactive_adr.md) | Document past architecture decisions |
| [Quality Baseline](templates/quality_baseline.md) | Establish quality metrics |
| [Migration Readiness Checklist](templates/migration_readiness_checklist.md) | Final validation |

---

## Quick Start

1. Read the [Migration Guide](migration_guide.md) for the full process
2. Complete [Phase 0: Assessment](phase_0_assessment.md) using the [Assessment Template](templates/migration_assessment.md)
3. Decide on your migration scope (Minimal, Standard, or Full)
4. Follow Phases 1-4 sequentially
5. Validate with the [Readiness Checklist](templates/migration_readiness_checklist.md)
6. Begin using the [Task Runner](../execution/task_runner.md)

---

## Related Framework Documentation

- [AI Contract](../ai.md) - Binding rules for AI agents
- [Ideation Playbook](../ideation_playbook.md) - For new projects
- [Task Runner](../execution/task_runner.md) - GO/NEXT execution protocol
- [Quality Gate](../quality/quality_gate.md) - Pass/fail criteria
- [Change Request Flow](../requests/change_request_flow.md) - For scope changes
