# Claude Skills

Claude Skills are structured operating procedures used during execution.
They do NOT replace the Task Runner or execution rules.
They are invoked internally by Claude to stay disciplined.

## Skill Index

| # | Skill | Purpose |
|---|-------|---------|
| 01 | [Context Loader](skill_01_context_loader.md) | Load factory context at session start |
| 02 | [Task Intake](skill_02_task_intake.md) | Extract and validate task requirements |
| 03 | [Test Alignment](skill_03_test_alignment.md) | Verify test coverage before implementation |
| 04 | [Implementation](skill_04_implementation.md) | Execute scoped code changes |
| 05 | [Run Checks](skill_05_run_checks.md) | Execute tests and quality checks |
| 06 | [Write Report](skill_06_write_report.md) | Generate completion report |
| 07 | [Update State](skill_07_update_state.md) | Update state.md and progress.json |
| 08 | [Next Task Recommendation](skill_08_next_task_recommendation.md) | Suggest next task after completion |
| 09 | [CR/NF Router](skill_09_cr_new_feature_router.md) | Route scope changes to proper flows |
| 10 | [Signal Snapshot](skill_10_signal_snapshot_and_decision.md) | Generate decision inputs from signals |
| 11 | [External Doc Import](skill_11_external_doc_import.md) | Parse Notion/Linear/Figma exports |
| 12 | [Gap Analysis](skill_12_gap_analysis.md) | Validate completeness against factory |
| 13 | [Gap Resolution](skill_13_gap_resolution.md) | Iterate with PO to fill planning gaps |
| 14 | [Codebase Research](skill_14_codebase_research.md) | On-demand research for complex tasks |

## Rules

- Skills never expand scope
- Skills never bypass GO/NEXT
- Skills never override files

If a skill conflicts with docs/ai.md or task_runner.md, the skill is wrong.