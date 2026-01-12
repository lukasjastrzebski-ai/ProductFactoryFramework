# Factory Operating Contract

This file is automatically read by Claude Code at session start.
It summarizes the binding rules from docs/ai.md.

## Authority Order

When sources conflict, obey this order strictly:

1. docs/ai.md (binding contract)
2. specs/, architecture/, plan/
3. docs/execution/*
4. Memory (recall only, never authority)

Files always override chat and memory.

## Execution Rules

- Never code without GO authorization
- Always persist reports to docs/execution/reports/
- Always update docs/execution/state.md
- Stop on scope drift - route to CR/New Feature

## Forbidden Actions

AI agents MUST NOT:
- Invent requirements
- Expand scope
- Skip tests
- Modify frozen planning artifacts (specs/, architecture/, plan/)
- Declare completion without persisted reports
- Bypass GO/NEXT protocol
- Rely on memory without file verification

Any forbidden action requires STOP.

## Key Files

- Task Runner: docs/execution/task_runner.md
- Execution State: docs/execution/state.md
- AI Contract: docs/ai.md
- Quality Gate: docs/quality/quality_gate.md
- Migration Guide: docs/migration/migration_guide.md (for existing projects)

## Quick Reference

| Gate | Purpose |
|------|---------|
| GO | Required before any implementation |
| NEXT | Required after task completion |
| Test Delta | Required for every task |
| Report | Required for completion |

## Planning Freeze

If `.factory/PLANNING_FROZEN` exists:
- specs/, architecture/, plan/ are frozen
- Only gated flows (CR/New Feature) may change them
- Violations invalidate execution

## Change Handling

If scope changes are required:
1. STOP execution
2. Route to appropriate flow:
   - docs/requests/change_request_flow.md
   - docs/requests/new_feature_flow.md
3. Wait for gate APPROVAL before continuing

## Session Start

1. Read this file and docs/ai.md
2. Check docs/execution/state.md for current state
3. Verify `.factory/PLANNING_FROZEN` status
4. Review docs/execution/task_status.md for pending work
5. Consider using /clear if resuming after a long break

## Context Hygiene

After NEXT gate approval:
- Use /clear if context exceeds 50% capacity
- Re-read this file after /clear

## Complex Task Guidance

For tasks marked [COMPLEX] in task files:
- Use "think hard" before implementation planning
- Use "think harder" for architectural decisions
- Use "ultrathink" for security-critical code

## Quick Commands

| Action | Location |
|--------|----------|
| Check state | docs/execution/state.md |
| Verify freeze | .factory/PLANNING_FROZEN |
| View pending tasks | docs/execution/task_status.md |
| Report template | docs/execution/task_report_template.md |
| Quality gate | docs/quality/quality_gate.md |
| Route to CR | docs/requests/change_request_flow.md |
| Route to NF | docs/requests/new_feature_flow.md |
| Progress tracking | docs/execution/progress.json |

## If Unsure

- STOP
- Ask the Product Owner
- Do not guess
