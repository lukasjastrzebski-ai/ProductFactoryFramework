# Task Runner (GO-NEXT Protocol)

This is the canonical execution loop. If you execute without this, you are not using the factory.

Scope:
- Running one task from plan/tasks/
- Enforcing tests (Test Delta) and persisted reports
- Updating execution state
- Blocking scope drift

Authority order reminder:
1) docs/ai.md
2) specs/, architecture/, plan/
3) docs/execution/*
4) memory and chat

If any conflict exists, STOP.

## Inputs
- TASK identifier: TASK-XXX
- Task file: plan/tasks/TASK-XXX-*.md (or plan/tasks/TASK-XXX.md)

## Outputs (mandatory)
- docs/execution/reports/TASK-XXX.md
- docs/execution/state.md updated

## Step 0: Preflight (mandatory)
1) Read docs/ai.md.
2) Read docs/execution/state.md.
3) If available, query memory for the last session:
   - What was last completed?
   - What is currently blocked?
   - What commands failed?
4) Verify memory claims against files. If memory conflicts with files, ignore memory.

If planning is frozen (.factory/PLANNING_FROZEN exists):
- Do not edit specs/, architecture/, plan/ unless operating under an APPROVED gate in docs/requests/.

## Step 1: Task intake (mandatory)
Open the task file and extract the following into a short intake summary:
- Goal
- In scope
- Out of scope
- Dependencies (tasks and non-task dependencies)
- Expected files to touch
- Commands to run
- Acceptance criteria checklist
- Test Delta
  - tests to add
  - tests to update
  - regression suites to run

Hard block conditions:
- Task file does not exist
- Test Delta missing or empty
- Acceptance criteria not testable
- Dependencies not satisfied

If blocked, produce:
- Status: BLOCKED
- Reason: specific and actionable
- Suggested fix: clarify spec, add Test Delta, unblock dependency, or open CR/New Feature

If not blocked:
- Ask the Product Owner for GO.

## Step 2: GO gate (mandatory)
Do nothing until the Product Owner responds with GO.

GO authorizes:
- exactly one task
- exactly the declared scope

GO does not authorize:
- refactors outside scope
- spec changes
- plan changes without an approved gate
- skipping tests

## Step 3: Test alignment (mandatory)
Before writing implementation code:
1) Identify impacted feature specs in specs/features/.
2) Identify impacted Feature Test Plans in specs/tests/ for MVP features or behavior-changing work.
3) Confirm the task Test Delta covers required tests.
4) If an impacted MVP feature has no Feature Test Plan:
   - STOP
   - Open a Change Request or New Feature lane to add it

## Step 4: Implementation (scoped)
Rules:
- Implement only in-scope items.
- Touch only expected files unless a justified exception is required.
- No opportunistic improvements.
- No unrelated refactors.
- If you discover missing requirements or a necessary scope change:
  - STOP
  - Route to Change Request or New Feature flow

## Step 5: Tests (mandatory)
1) Implement tests listed in the Test Delta.
2) Update tests listed in the Test Delta.
3) Run all commands declared in the task file.
4) Run regression suites declared in the Test Delta.

Policy for failures:
- One in-scope fix attempt is allowed.
- If still failing, mark BLOCKED with evidence and stop.

## Step 6: Persist completion report (mandatory)
Create: docs/execution/reports/TASK-XXX.md

Use docs/execution/task_report_template.md.

The report must include:
- Summary and rationale
- Scope adherence (in and out of scope)
- Files changed
- Tests added, updated, executed
- Regression suites executed
- Commands run and results
- Acceptance criteria verification
- Status: COMPLETE or BLOCKED
- Suggested next tasks

Hard rule:
- If the report file is not written to disk, you cannot claim completion.

## Step 7: Update execution state (mandatory)
Update docs/execution/state.md with:
- updated_at
- last_completed_task
- last_report_path
- current_phase (if known)
- notes (optional, short)

Hard rule:
- Completion requires state update.

## Step 8: NEXT gate
After report and state are complete, ask the Product Owner:
- NEXT (continue with recommended task)
- NEXT: TASK-YYY (explicit next task)
- STOP
- BLOCKED. Reason: ...

## Minimal operator verification
Before accepting a task as complete, the Product Owner must confirm:
- report exists at docs/execution/reports/TASK-XXX.md
- state updated
- tests executed listed in report
