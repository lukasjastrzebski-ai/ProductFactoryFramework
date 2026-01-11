# Execution Guide

Audience: Operators during day-to-day implementation

## Starting a Task

### Step 1: Verify preconditions

Before any execution:

1. Check `.factory/PLANNING_FROZEN` exists (source: [docs/planning_freeze.md](planning_freeze.md))
2. Check `plan/EXECUTION_READINESS.md` shows PASSED (source: [plan/EXECUTION_READINESS_TEMPLATE.md](../plan/EXECUTION_READINESS_TEMPLATE.md))
3. Read `docs/execution/state.md` for current state (source: [docs/execution/state.md](execution/state.md))

If any check fails, execution is forbidden.

### Step 2: Request task intake

Tell Claude:
```
Run TASK-XXX via the task runner.
```

Claude must respond with (source: [docs/execution/task_runner.md](execution/task_runner.md) Step 1):
- Goal
- In-scope items
- Out-of-scope items
- Dependencies
- Expected files to touch
- Commands to run
- Acceptance criteria checklist
- Test Delta (tests to add, update, run)

### Step 3: Verify intake

Check the intake summary against the task file in `plan/tasks/TASK-XXX.md`.

Hard blockers (execution cannot proceed):
- Task file does not exist
- Test Delta missing or empty
- Acceptance criteria not testable
- Dependencies not satisfied

### Step 4: Authorize with GO

Say:
```
GO
```

GO authorizes (source: [docs/execution/task_runner.md](execution/task_runner.md) Step 2):
- Exactly one task
- Exactly the declared scope

GO does NOT authorize:
- Refactors outside scope
- Spec changes
- Plan changes
- Skipping tests

## Expected Claude Code Behavior

During execution, Claude must (source: [docs/ai.md](ai.md)):

**DO:**
- Implement only in-scope items
- Touch only expected files
- Write tests per Test Delta
- Run declared commands
- Execute regression suites
- Persist completion report
- Update execution state

**MUST NOT:**
- Invent requirements
- Expand scope
- Skip tests
- Modify frozen artifacts (specs/, architecture/, plan/)
- Declare completion without persisted files
- Bypass GO/NEXT protocol
- Rely on memory over files

If Claude exhibits forbidden behavior, say **STOP** immediately.

## Files to Update Per Task

### Mandatory outputs (source: [docs/execution/task_runner.md](execution/task_runner.md) Steps 6-7)

| File | Content |
|------|---------|
| `docs/execution/reports/TASK-XXX.md` | Completion report using [template](execution/task_report_template.md) |
| `docs/execution/state.md` | Updated metadata, recent tasks, blockers |
| `docs/execution/progress.json` | Incremented metrics, feature status |

### Report required sections (source: [docs/execution/task_report_template.md](execution/task_report_template.md))

- Summary
- Scope adherence (in/out of scope)
- Files changed
- Tests (added, updated, executed, regression suites)
- Commands run and results
- Acceptance criteria verification
- Status (COMPLETE or BLOCKED)
- Suggested next tasks

### Hard rule

If the report file is not written to disk, completion cannot be claimed.

## How Reports and State Work

### docs/execution/state.md

Tracks (source: [docs/execution/state.md](execution/state.md)):
- `updated_at` - Last update timestamp
- `current_phase` - Active implementation phase
- Recent tasks (last 5) with status and report path
- Current blockers
- Recent file changes
- Notes

Updated after every task completion.

### docs/execution/progress.json

Tracks (source: [docs/execution/progress.json](execution/progress.json)):
- Product name and version
- Current phase
- Features array with task breakdown
- Blockers array
- Metrics (tasks_completed, tasks_total, tasks_blocked, test_coverage)

### docs/execution/task_status.md

Lightweight tracker (source: [docs/execution/task_status.md](execution/task_status.md)):
- Format: `TASK-ID | STATUS | NOTES`
- Status values: NOT_STARTED, IN_PROGRESS, COMPLETE, BLOCKED
- CI validates that COMPLETE tasks have reports

## When to Stop and Escalate

### Immediate STOP conditions

Stop execution if any of the following occur (source: [docs/execution/execution_playbook.md](execution/execution_playbook.md)):

- Scope creep detected
- Edits to files outside declared scope
- Refactors not justified by task
- Test skipping attempted
- Claims of completion without disk files
- Ambiguity in requirements
- Behavior contradicts specs
- Unexpected dependencies
- Missing test plans

### Escalation paths (source: [docs/ai.md](ai.md))

| Situation | Route to |
|-----------|----------|
| Fixing incorrect requirements | [docs/requests/change_request_flow.md](requests/change_request_flow.md) |
| Adjusting acceptance criteria | [docs/requests/change_request_flow.md](requests/change_request_flow.md) |
| Adding net-new feature | [docs/requests/new_feature_flow.md](requests/new_feature_flow.md) |
| Bug with scope impact | [docs/requests/change_request_flow.md](requests/change_request_flow.md) |

### Escalation artifacts

Change Request requires (source: [docs/requests/change_request_flow.md](requests/change_request_flow.md)):
1. Change Intake document
2. Impact Analysis
3. Specification Updates
4. Test Plan Updates
5. Plan Updates
6. Regression Plan
7. Execution Gate (APPROVED)

New Feature requires (source: [docs/requests/new_feature_flow.md](requests/new_feature_flow.md)):
1. Feature Intake document
2. Impact Analysis
3. Feature Specification
4. Feature Test Plan
5. Architecture Updates (if needed)
6. Plan Updates
7. Regression Plan
8. Execution Gate (APPROVED)

Without an APPROVED gate, execution on changes is forbidden.

## Parallel Execution

### Default mode

Single-agent execution is the default. Parallelism is optional and requires additional setup.

### When parallel is allowed (source: [docs/multi_agent_execution_protocol.md](multi_agent_execution_protocol.md))

All conditions must be true:
- Work can be split into independent slices
- Interfaces and acceptance criteria defined before coding
- One Integrator agent owns merges
- One QA reviewer performs adversarial checks
- Each slice is small (0.5-2 days)
- Written parallel plan exists at `docs/execution/parallel/PRL-*.md`

### Parallel roles

| Role | Responsibility |
|------|----------------|
| Integrator | Decompose work, assign slices, resolve conflicts, run full tests, write integration report |
| Contributor | Implement assigned slice, write slice report, do not merge |
| QA Reviewer | Validate against specs, block merges if tests missing or scope drift |

### When to stop parallelism

Return to single-agent if:
- Repeated merge conflicts
- Unclear ownership
- Failing tests with unclear cause
- QA cannot verify acceptance criteria

## Verification Checklist

Before accepting a task as complete (source: [docs/manuals/implementation_control_manual.md](manuals/implementation_control_manual.md)):

- [ ] Report exists at `docs/execution/reports/TASK-XXX.md`
- [ ] Report contains Summary section
- [ ] Report contains Tests section
- [ ] Report contains Acceptance criteria section
- [ ] Tests listed and execution results recorded
- [ ] Acceptance criteria verified against evidence
- [ ] `docs/execution/state.md` updated
- [ ] `docs/execution/progress.json` updated
- [ ] No scope drift occurred

If all pass: **NEXT**
If any fail: **STOP** or **BLOCKED**
