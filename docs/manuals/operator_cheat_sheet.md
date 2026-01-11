# Operator Cheat Sheet (Execution Mode)

Audience: Product Owner running day-to-day execution  
Purpose: One-page control surface. No explanations. Only actions and checks.

---

## Before every session

1) Open:
- docs/execution/state.md
- docs/execution/reports/ (last report)

2) Ask Claude (optional):
- “What did we do last session?”
Then VERIFY against files. Memory never overrides files.

3) Confirm:
- .factory/PLANNING_FROZEN exists
- You are in EXECUTION mode, not planning

If planning is not frozen, STOP.

---

## Running a task (canonical loop)

### Step 1 – Request task
You say:
> Run TASK-XXX via the task runner.

Claude must respond with:
- goal
- in-scope / out-of-scope
- dependencies
- expected files to touch
- commands to run
- acceptance criteria
- Test Delta

If Test Delta is missing → BLOCKED.

---

### Step 2 – Authorize
You say:
- GO

Nothing happens before GO.

---

### Step 3 – During execution (watch for red flags)

Immediate STOP if you see:
- scope creep
- edits outside declared files
- refactors not justified by task
- skipping tests
- claims of completion without disk files

---

### Step 4 – Verify completion (non-negotiable)

A) Report exists:
docs/execution/reports/TASK-XXX.md

B) Report includes:
- summary
- files changed
- tests added/updated/executed
- commands run
- AC verification

C) State updated:
docs/execution/state.md

Missing any → reject.

---

### Step 5 – Continue
You say:
- NEXT
- NEXT: TASK-YYY
- STOP
- BLOCKED. Reason: <text>

---

## Golden rules
- No GO → no code
- No report → no completion
- No tests → no acceptance
- Files > memory > chat
- When in doubt → STOP