# Execution Playbook

This document defines the boundaries, prerequisites, and operating rules for the execution phase.
It exists to prevent accidental drift back into planning or uncontrolled coding.

Execution mode begins only after planning is formally completed and frozen.

---

## Preconditions (hard gate)

Execution MAY begin only if ALL of the following are true:

- plan/EXECUTION_READINESS.md exists and verdict is PASSED
- docs/ai.md is finalized (no placeholders, no PRODUCT_OWNER_INPUT_REQUIRED markers)
- .factory/STAGE_7_COMPLETE exists
- .factory/PLANNING_FROZEN exists

If any condition is false:
- Execution is forbidden
- Do not run tasks
- Return to planning or fix the blocker

CI enforces these rules.

---

## What execution mode allows

In execution mode, Claude MAY:
- implement tasks defined in plan/tasks/
- write and update tests per Test Delta
- update application code strictly in scope
- write execution reports
- update execution state

---

## What execution mode forbids

See docs/ai.md for the authoritative list of forbidden actions.

Key constraints for execution mode:
- No edits to frozen directories (specs/, architecture/, plan/)
- No scope expansion or requirement changes
- No test skipping or deferral
- No refactoring outside task scope

Any forbidden action requires a gated flow:
- Change Request (docs/requests/change_request_flow.md)
- New Feature (docs/requests/new_feature_flow.md)

---

## The only valid execution mechanism

All work must go through:
- docs/execution/task_runner.md

There are no exceptions.
Running ad-hoc commands or partial changes outside the runner violates the factory contract.

---

## Operator responsibility

The Product Owner is responsible for:
- authorizing work (GO)
- verifying completion artifacts
- enforcing scope boundaries
- stopping execution when discipline breaks
- approving or rejecting Change Requests and New Features

Claude is not autonomous. It executes instructions within constraints.

---

## Handling uncertainty

If during execution any of the following occurs:
- ambiguity in requirements
- unclear acceptance criteria
- missing tests or test plans
- unexpected dependencies
- behavior that contradicts specs

Then:
- STOP execution
- Document the issue
- Decide whether to:
  - clarify within existing scope
  - open a Change Request
  - open a New Feature intake

Guessing is forbidden.

---

## Mid-execution scope change reminder

When planning is frozen:
- all scope changes must follow gated flows
- no silent edits to planning artifacts

Relevant documents:
- docs/requests/change_request_flow.md
- docs/requests/new_feature_flow.md

---

## Execution completion

Execution phase is considered complete when:
- all planned tasks are COMPLETE
- all completion reports exist on disk
- all tests pass
- quality gates pass
- release criteria defined in the roadmap are met

At this point, transition to release, monitoring, and lessons learned.

---

## Relationship to other documents

This document works together with:
- docs/execution/task_runner.md (how to run tasks)
- docs/execution/implementation_control_manual.md (operator discipline)
- docs/execution/operator_cheat_sheet.md (day-to-day reference)

If there is a conflict:
- task_runner.md overrides this document