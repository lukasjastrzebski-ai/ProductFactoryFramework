# AI Agent Contract (docs/ai.md)

This document is the binding contract between the Product Owner and AI agents (Claude Code).
If an AI action violates this document, it is invalid.

This file is finalized at Stage 7 and frozen for execution.

---

## Product Context

Product: {{PRODUCT_NAME}}
Core Problem: {{CORE_PROBLEM}}
Target User: {{TARGET_USER}}

These placeholders are populated during Kickoff and must not be changed afterward.

---

## Authority Order

When sources conflict, obey this order strictly:

1) docs/ai.md (this file)
2) specs/, architecture/, plan/
3) docs/execution/*
4) memory and chat context

Files always override chat and memory.

---

## Allowed AI actions

AI agents MAY:
- read all repository files
- implement tasks defined in plan/tasks/
- write tests defined by Feature Test Plans and Task Test Delta
- write execution reports and update execution state
- recommend next tasks (without authorizing them)

---

## Forbidden AI actions

AI agents MUST NOT:
- invent requirements
- expand scope
- skip tests
- modify planning artifacts during execution
- declare completion without persisted reports
- bypass GO / NEXT protocol
- rely on memory without file verification

Any forbidden action requires STOP.

---

## Execution discipline

AI agents must follow:
- docs/execution/task_runner.md
- docs/execution/implementation_control_manual.md
- docs/execution/operator_cheat_sheet.md

There are no shortcuts.

---

## Planning freeze

If .factory/PLANNING_FROZEN exists:
- specs/, architecture/, plan/ are frozen
- only gated flows may change them

Violations invalidate execution.

---

## Change handling

If scope changes are required:
- STOP execution
- route to:
  - docs/requests/change_request_flow.md
  - docs/requests/new_feature_flow.md

AI agents must not continue until a gate is APPROVED.

---

## Parallel execution

Parallel execution is allowed only if:
- docs/multi_agent_execution_protocol.md conditions are met
- a parallel plan exists

Otherwise, default to single-agent execution.

---

## Quality and tests

AI agents must:
- enforce Feature Test Plans
- enforce Task Test Delta
- run and report tests

Quality violations require STOP.

---

## Memory usage

Memory may be used only for recall.
Memory never overrides files.

If memory conflicts with files, ignore memory.

---

## Completion rules

A task is COMPLETE only if:
- report exists on disk
- execution state updated
- tests executed and reported

If any condition fails, task is not complete.

---

## Final note

If you are unsure:
- STOP
- ask the Product Owner
- do not guess