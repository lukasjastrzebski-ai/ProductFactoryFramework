# Product Factory Framework

Version: v10.1

## What is the Product Factory?

The Product Factory is a strict, file-driven framework for building software products using Claude Code as an autonomous implementation agent. It provides a complete Software Development Lifecycle (SDLC) from idea intake through execution, with explicit quality gates and enforcement mechanisms.

The factory is designed for a single **Product Owner** (typically a technical founder or product manager) to reliably create and maintain software products with minimal manual engineering effort.

## Who is this for?

- Technical founders building products with AI assistance
- Product owners who want reproducible, disciplined execution
- Teams seeking to minimize rework through upfront planning
- Anyone who wants to use Claude Code as a constrained executor rather than an autonomous co-creator

## Core Philosophy

**Files over chat.** All decisions, plans, and outputs are persisted as Markdown files. Chat history is ephemeral; files are authoritative.

**Contracts over intent.** AI agents operate under explicit constraints defined in [docs/ai.md](docs/ai.md). Violations invalidate execution.

**Quality over speed.** Tests are mandatory. Reports must be persisted. Regressions block execution.

## What the Factory Provides

1. **Ideation to Execution Pipeline** - Seven planning stages from idea intake to execution authorization (defined in [docs/ideation_playbook.md](docs/ideation_playbook.md))

2. **Execution Protocol** - The GO/NEXT loop for controlled task execution (defined in [docs/execution/task_runner.md](docs/execution/task_runner.md))

3. **Change Control** - Gated flows for scope changes during execution (defined in [docs/requests/](docs/requests/))

4. **Quality Enforcement** - Test requirements, quality baselines, and regression rules (defined in [docs/quality/](docs/quality/) and [docs/testing/](docs/testing/))

5. **CI Guardrails** - Automated enforcement via GitHub Actions (defined in [.github/workflows/](.github/workflows/))

## What the Factory is NOT

- **Not a code generator** - It does not write code autonomously. Claude Code writes code under explicit authorization.
- **Not a project management tool** - It is a discipline framework, not a Jira replacement.
- **Not magic** - Planning requires human effort. Quality requires human verification.
- **Not flexible on quality** - Test skipping, scope creep, and undocumented changes are forbidden.

## What is Automated vs Human-Controlled

| Aspect | Automated | Human-Controlled |
|--------|-----------|------------------|
| Task execution | Claude Code implements scoped tasks | Product Owner authorizes with GO |
| Test execution | CI runs tests automatically | Product Owner verifies reports |
| State tracking | Reports and state files updated by Claude | Product Owner accepts or rejects |
| Scope changes | BLOCKED until routed | Product Owner approves gates |
| Planning | Claude may assist in planning stages | Product Owner validates all artifacts |

## High-Level Lifecycle

```
PLANNING (Stages 0-7)
  Stage 0: Idea Intake
  Stage 1: Vision, Strategy, Metrics, Risks
  Stage 2: Product Definition
  Stage 3: Feature Discovery
  Stage 4: Architecture
  Stage 5: Implementation Planning
  Stage 6: Execution Readiness Check
  Stage 7: AI Contract Finalization & Planning Freeze

EXECUTION (Task Runner Loop)
  1. Product Owner requests task
  2. Claude performs intake and requests GO
  3. Product Owner says GO
  4. Claude implements, tests, and reports
  5. Claude requests NEXT
  6. Product Owner says NEXT, STOP, or BLOCKED
  Repeat until all tasks complete

POST-EXECUTION
  Release, monitoring, and lessons learned
```

## Quick Start

Choose your path based on your project's current state:

### New Projects (Greenfield)

Use the **Ideation Playbook** to build from scratch:

1. Clone this repository as your project template
2. Read [docs/ideation_playbook.md](docs/ideation_playbook.md) for the planning process
3. Complete Stages 0-7 to prepare for execution
4. After Stage 7 completion, follow [docs/execution/task_runner.md](docs/execution/task_runner.md)
5. Use [docs/manuals/operator_cheat_sheet.md](docs/manuals/operator_cheat_sheet.md) for day-to-day reference

### Existing Projects (Migration)

Use the **Migration Guide** to adopt the factory on an existing codebase:

1. Read [docs/migration/migration_guide.md](docs/migration/migration_guide.md) for the full process
2. Complete the [Migration Assessment](docs/migration/templates/migration_assessment.md)
3. Follow Phases 0-4 to establish factory structure and baselines
4. Validate with the [Readiness Checklist](docs/migration/templates/migration_readiness_checklist.md)
5. Begin using the [Task Runner](docs/execution/task_runner.md)

**Migration time estimate:** 5-13 hours depending on project size and scope

### Starting with Existing Documentation

If you have documentation in Notion, Figma, Linear, or other tools:

1. Export and place in `docs/import/sources/`
2. Run `./scripts/import/parse_docs.sh`
3. Run `./scripts/import/analyze_gaps.sh`
4. Tell Claude: "Help me resolve the planning gaps"
5. Iterate until all blocking gaps are resolved
6. Proceed to execution readiness

See [External Documentation Import](docs/import/README.md) for details.

## Key Files

| File | Purpose |
|------|---------|
| [docs/ai.md](docs/ai.md) | Binding AI contract |
| [CLAUDE.md](CLAUDE.md) | Session startup summary |
| [docs/execution/task_runner.md](docs/execution/task_runner.md) | GO/NEXT execution protocol |
| [docs/ideation_playbook.md](docs/ideation_playbook.md) | Planning stages 0-7 (new projects) |
| [docs/migration/migration_guide.md](docs/migration/migration_guide.md) | Migration guide (existing projects) |
| [docs/quality/quality_gate.md](docs/quality/quality_gate.md) | Quality pass/fail criteria |

## Authority Hierarchy

When sources conflict, this order applies:

1. [docs/ai.md](docs/ai.md) (binding contract)
2. specs/, architecture/, plan/ (frozen specifications)
3. docs/execution/* (execution guidance)
4. Memory and chat (context only, never authority)

## Documentation

- [User Guide](docs/USER_GUIDE.md) - Step-by-step guide for new operators
- [Execution Guide](docs/EXECUTION_GUIDE.md) - Day-to-day operational manual
- [Factory Reference](docs/FACTORY_REFERENCE.md) - Deep reference documentation
- [Extension Guide](docs/EXTENSION_GUIDE.md) - How to extend the factory safely
- [Known Limitations](docs/KNOWN_LIMITATIONS.md) - What the factory does and does not do

## License and Support

See LICENSE file for licensing terms.

For issues, refer to the factory audit process in [docs/audits/](docs/audits/).
