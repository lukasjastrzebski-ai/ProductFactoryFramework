# Implementation Control Manual

> **Authority Note:** This document derives from and elaborates on docs/ai.md, which remains the authoritative source for all AI agent rules.

Audience: Product Owner
Scope: Governing execution discipline after planning freeze

This manual defines what you MUST enforce while executing tasks.

---

## Preconditions for execution

Execution may start only if ALL are true:
- plan/EXECUTION_READINESS.md exists and is PASSED
- docs/ai.md finalized (no placeholders)
- .factory/PLANNING_FROZEN exists

If any condition is false, execution is forbidden.

---

## Execution authority model

You control:
- when execution starts (GO)
- what task runs next (NEXT)
- when execution stops (STOP)
- whether work is accepted or rejected

Claude has NO authority to violate docs/ai.md. Key constraints:
- No scope expansion
- No test skipping
- No planning artifact modification
- No completion without persisted files

---

## The GO / NEXT contract

GO:
- authorizes work on exactly one task
- authorizes only declared scope

NEXT:
- authorizes continuation to another task
- does NOT imply retroactive acceptance

STOP:
- halts execution immediately
- used when scope, quality, or discipline is violated

---

## Mandatory execution artifacts

For every completed task, ALL must exist:
- docs/execution/reports/TASK-XXX.md
- updated docs/execution/state.md
- tests written per Test Delta

If any artifact is missing, the task is NOT complete.

---

## Scope enforcement

See docs/ai.md for the authoritative list of forbidden actions.

Key constraints during execution:
- Frozen directories (specs/, architecture/, plan/) are read-only
- Changes must stay within declared task scope
- Refactoring outside scope is forbidden

If scope violation detected:
- STOP execution
- Route to Change Request or New Feature flow

---

## Handling failures

### Test failures
- One in-scope fix attempt allowed
- If still failing → BLOCKED

### Ambiguity
- STOP and clarify
- Do not guess

### CI failures
- Treat as execution blockers
- Open Change Request if needed

---

## Parallel execution policy

Default mode is single-agent.

Parallel execution requires:
- docs/multi_agent_execution_protocol.md
- a written parallel plan
- defined file ownership
- integration step

No plan → no parallelism.

---

## Anti-patterns (do not allow)

- “I fixed a few extra things”
- “Tests later”
- “This is small, I’ll just change it”
- “It works locally, trust me”

Each is grounds for rejection.

---

## Acceptance checklist

Before accepting a task:
- report exists
- tests listed and executed
- acceptance criteria verified
- state updated
- no scope drift

If all pass → NEXT
If not → STOP or BLOCKED

This manual overrides convenience.