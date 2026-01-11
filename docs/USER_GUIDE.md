# User Guide

Audience: New operators using the Product Factory for the first time

## Prerequisites

Before using this factory:

- **Claude Code installed** - You need Claude Code CLI or VS Code extension
- **Git repository initialized** - The factory is file-driven and version-controlled
- **Basic Markdown literacy** - All artifacts are Markdown files
- **Time for planning** - Stages 0-7 require significant upfront investment

## Mental Model

Think of the factory as a **contract between you and an AI executor**.

**You (Product Owner):**
- Define what to build (planning stages)
- Authorize work (GO gate)
- Accept or reject outcomes (NEXT gate)
- Make all scope decisions

**Claude Code (AI Agent):**
- Implements scoped tasks (after GO)
- Writes and runs tests (per Test Delta)
- Persists reports (mandatory)
- Recommends next steps (without authority)

The AI has **no authority** to expand scope, skip tests, or modify plans. If it tries, STOP execution.

## Phase 1: Kickoff

### What happens

Kickoff initializes the factory for your product.

### What you do

1. Populate placeholders in [docs/ai.md](ai.md):
   - `{{PRODUCT_NAME}}`
   - `{{CORE_PROBLEM}}`
   - `{{TARGET_USER}}`

2. Verify `.factory/KICKOFF_COMPLETE` marker exists after initialization

### Reference files

- [docs/ai.md](ai.md) - Authority source
- [.factory/KICKOFF_COMPLETE](../.factory/KICKOFF_COMPLETE) - Marker file

## Phase 2: Planning (Stages 0-7)

### Stage progression

Each stage has mandatory outputs. You cannot skip stages.

| Stage | Goal | Key Outputs |
|-------|------|-------------|
| 0 | Idea Intake | docs/product/idea_intake.md |
| 1 | Vision & Strategy | docs/product/vision.md, strategy.md, metrics.md, risks.md |
| 2 | Product Definition | docs/product/definition.md, personas.md, journeys.md |
| 3 | Feature Discovery | specs/features/*.md, specs/tests/*_test_plan.md |
| 4 | Architecture | architecture/*.md, architecture/decisions/ADR-*.md |
| 5 | Implementation Planning | plan/roadmap.md, plan/phases/*.md, plan/tasks/*.md |
| 6 | Readiness Check | plan/EXECUTION_READINESS.md (PASSED or FAILED) |
| 7 | Contract Finalization | docs/ai.md finalized, planning frozen |

### Critical rules for planning

- **No placeholders** - Every field must be populated
- **Testable acceptance criteria** - If you cannot test it, it is not a criterion
- **MVP features need test plans** - Located in specs/tests/
- **Tasks need Test Delta** - Every task must specify tests to add/update/run
- **Tasks must be atomic** - Target 1-2 days of work per task

### Planning freeze

After Stage 7:
- `.factory/PLANNING_FROZEN` marker is created
- specs/, architecture/, plan/ become read-only
- Only gated flows (Change Request, New Feature) can modify frozen artifacts

### Reference files

- [docs/ideation_playbook.md](ideation_playbook.md) - Full stage definitions
- [docs/planning_freeze.md](planning_freeze.md) - Freeze rules
- [specs/_templates/](../specs/_templates/) - Templates for specs, tasks, test plans

## Phase 3: Execution

### How to start a task

1. **Choose a task** from plan/tasks/
2. **Request intake** - Tell Claude: "Run TASK-XXX via the task runner"
3. **Review intake summary** - Claude presents goal, scope, dependencies, Test Delta
4. **Say GO** - Authorizes exactly this task with exactly this scope
5. **Monitor execution** - Watch for scope creep, skipped tests, unauthorized changes
6. **Verify completion** - Report must exist, state must be updated
7. **Say NEXT** - Authorizes continuation

### GO/NEXT Protocol

The GO/NEXT protocol is defined in [docs/execution/task_runner.md](execution/task_runner.md).

| Gate | What it authorizes | What it does NOT authorize |
|------|-------------------|---------------------------|
| GO | One task, declared scope | Refactors, spec changes, test skipping |
| NEXT | Continuation to next task | Retroactive acceptance of undocumented changes |
| STOP | Immediate halt | Nothing - full stop |
| BLOCKED | Wait for resolution | Nothing - wait |

### Execution artifacts (mandatory)

For every completed task:
- `docs/execution/reports/TASK-XXX.md` must exist
- `docs/execution/state.md` must be updated
- `docs/execution/progress.json` must be updated
- Tests must be executed and results recorded

If any artifact is missing, the task is **not complete**.

### Reference files

- [docs/execution/task_runner.md](execution/task_runner.md) - Canonical execution loop
- [docs/execution/task_report_template.md](execution/task_report_template.md) - Report format
- [docs/execution/state.md](execution/state.md) - Current state
- [docs/manuals/operator_cheat_sheet.md](manuals/operator_cheat_sheet.md) - Quick reference

## How CI Enforces Rules

Two GitHub workflows enforce factory discipline:

### factory-guardrails.yml

Validates (defined in [.github/workflows/factory-guardrails.yml](../.github/workflows/factory-guardrails.yml)):
- `.factory/KICKOFF_COMPLETE` exists
- Planning freeze markers exist when in execution mode
- COMPLETE tasks have corresponding reports
- IN_PROGRESS tasks have Test Delta
- Change Requests and New Features have approved gates
- MVP features have test plans
- Reports contain required sections (Summary, Tests, Acceptance criteria)

### quality-autopilot.yml

Runs tests (defined in [.github/workflows/quality-autopilot.yml](../.github/workflows/quality-autopilot.yml)):
- Installs dependencies (pnpm)
- Executes test suite (`pnpm test`)

Both workflows run on pull requests and pushes to main.

## Common Operator Mistakes

### During Planning

| Mistake | Consequence | Prevention |
|---------|-------------|------------|
| Leaving placeholders | CI fails, execution blocked | Fill every field |
| Vague acceptance criteria | Cannot verify completion | Make criteria testable |
| Missing Test Delta in tasks | Tasks blocked | Always specify tests |
| Skipping stages | Incomplete planning | Follow sequence strictly |

### During Execution

| Mistake | Consequence | Prevention |
|---------|-------------|------------|
| Saying GO without reading intake | Scope not understood | Always review intake first |
| Not checking for reports | False completion | Verify file exists on disk |
| Allowing "quick fixes" outside scope | Scope creep | STOP immediately |
| Ignoring test failures | Quality degradation | Block until fixed |
| Accepting chat claims without files | No audit trail | Files are the only truth |

### Recovery

If discipline breaks:
1. **STOP** - Halt execution immediately
2. **Assess** - What was violated?
3. **Route** - Open Change Request if scope changed
4. **Restore** - Return to known good state if needed
5. **Resume** - Only after discipline restored

## Quick Start Checklist

Planning:
- [ ] CLAUDE.md and docs/ai.md read
- [ ] Product context populated in docs/ai.md
- [ ] Stages 0-7 completed in sequence
- [ ] plan/EXECUTION_READINESS.md is PASSED
- [ ] .factory/PLANNING_FROZEN exists

Execution:
- [ ] Task file exists in plan/tasks/
- [ ] Test Delta present in task
- [ ] GO explicitly given
- [ ] Report persisted to docs/execution/reports/
- [ ] State updated in docs/execution/state.md
- [ ] NEXT given after verification
