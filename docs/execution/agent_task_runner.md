# Agent Task Runner

**Version:** 20.0

This document defines the execution loop for Task Agents in v20 autonomous mode.

---

## Overview

Task Agents follow a modified task runner loop optimized for parallel execution under PO orchestration. The loop emphasizes plan submission, GO gate waiting, and report generation.

---

## Execution Loop

```
┌──────────────────────────────────────────────────────────────┐
│                  TASK AGENT EXECUTION LOOP                    │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Step 0: RECEIVE ASSIGNMENT                                   │
│  ├─ Parse task assignment JSON                               │
│  ├─ Validate assignment completeness                         │
│  ├─ Initialize progress reporting                            │
│  └─ Report: status=initializing, percent=0                   │
│                                                               │
│  Step 1: RESEARCH                                             │
│  ├─ Read task specification                                  │
│  ├─ Read feature specification                               │
│  ├─ Study existing code patterns                             │
│  ├─ Identify implementation approach                         │
│  └─ Report: status=researching, percent=10                   │
│                                                               │
│  Step 2: PLAN                                                 │
│  ├─ Create implementation plan                               │
│  ├─ Map AC items to code changes                            │
│  ├─ Define test approach                                     │
│  ├─ List files to modify                                     │
│  └─ Report: status=planning, percent=20                      │
│                                                               │
│  Step 3: SUBMIT PLAN                                          │
│  ├─ Send PLAN_SUBMISSION to PO                              │
│  └─ Report: status=awaiting_go, percent=25                   │
│                                                               │
│  Step 4: AWAIT GO                                             │
│  ├─ Wait for PO response                                     │
│  ├─ If FEEDBACK: Revise plan, return to Step 2              │
│  └─ If GO: Proceed to Step 5                                │
│                                                               │
│  Step 5: IMPLEMENT                                            │
│  ├─ Execute plan within authorized scope                     │
│  ├─ Write code following existing patterns                   │
│  ├─ Report progress every 5 minutes                         │
│  └─ Report: status=implementing, percent=30-70               │
│                                                               │
│  Step 6: TEST                                                 │
│  ├─ Write tests per Test Delta                              │
│  ├─ Execute all required tests                               │
│  ├─ Fix in-scope failures                                    │
│  └─ Report: status=testing, percent=70-90                    │
│                                                               │
│  Step 7: REPORT                                               │
│  ├─ Generate completion report                               │
│  ├─ Document AC verification                                 │
│  ├─ Include test results                                     │
│  └─ Report: status=reporting, percent=95                     │
│                                                               │
│  Step 8: SUBMIT REPORT                                        │
│  ├─ Send COMPLETION_REPORT to PO                            │
│  └─ Report: status=awaiting_next, percent=100               │
│                                                               │
│  Step 9: AWAIT NEXT                                           │
│  ├─ Wait for PO response                                     │
│  ├─ If FIX: Note issues, return to Step 5 or 6              │
│  ├─ If BLOCKED: Log reason, terminate                       │
│  └─ If NEXT: Terminate successfully                         │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Step Details

### Step 0: Receive Assignment

**Input:** Task assignment JSON

**Actions:**
1. Parse JSON file
2. Verify all required fields present
3. Set up worktree environment
4. Initialize progress file

**Validation:**
```
REQUIRED:
- task_id present
- acceptance_criteria not empty
- test_delta defined
- authorized_files not empty
- timeout_minutes > 0
```

### Step 1: Research

**Goal:** Understand task and codebase context

**Actions:**
1. Read task definition file
2. Read referenced feature specification
3. Examine existing code in authorized files
4. Identify patterns to follow
5. Note potential issues

**Output:** Mental model of implementation approach

### Step 2: Plan

**Goal:** Create detailed implementation plan

**Plan Contents:**
```markdown
## Implementation Plan for TASK-XXX

### Approach
[High-level description]

### Acceptance Criteria Mapping

| AC | Implementation | File | Test |
|----|----------------|------|------|
| AC-001 | Add input field | LoginPage.tsx | LoginPage.test.tsx |
| AC-002 | Validate email | authService.ts | authService.test.ts |

### Files to Modify

- src/pages/LoginPage.tsx
  - Add email input (line ~50)
  - Add password input (line ~60)
  - Add error display (line ~80)

- src/services/authService.ts
  - Add validate() method

### Test Approach

- Unit tests for form validation
- Integration test for login flow
- E2E test for complete flow

### Potential Issues

- [Any concerns or questions]
```

### Step 3: Submit Plan

**Action:** Send plan to PO for validation

**Message Format:**
```json
{
  "message_type": "PLAN_SUBMISSION",
  "agent_id": "agent-xxx",
  "task_id": "TASK-XXX",
  "plan": {
    "approach": "...",
    "ac_mapping": [...],
    "files": [...],
    "tests": [...]
  },
  "questions": [],
  "submitted_at": "ISO8601"
}
```

### Step 4: Await GO

**Wait for PO response:**
- **GO:** Authorization to implement
- **FEEDBACK:** Revise plan with guidance

**On FEEDBACK:**
1. Read specific issues
2. Revise plan to address
3. Resubmit plan
4. Max 2 plan revisions before blocked

### Step 5: Implement

**Constraints:**
- Only modify authorized files
- Follow existing patterns
- Stay within AC scope
- Report progress every 5 minutes

**Progress Updates:**
```bash
./scripts/agents/report_progress.sh \
    --agent agent-xxx \
    --status implementing \
    --percent 50 \
    --activity "Writing login form component"
```

### Step 6: Test

**Required Actions:**
1. Write tests in Test Delta "add" files
2. Update tests in Test Delta "update" files
3. Run all Test Delta regression suites
4. All tests must pass

**On Failure:**
- If in-scope: Fix and retry
- If out-of-scope: Document and report to PO

### Step 7: Report

**Completion Report Structure:**
```markdown
## Task Completion Report: TASK-XXX

### Summary
- Task ID: TASK-XXX
- Agent ID: agent-xxx
- Started: [timestamp]
- Completed: [timestamp]
- Status: COMPLETE

### Acceptance Criteria Verification

| AC | Status | Evidence |
|----|--------|----------|
| AC-001 | PASS | LoginPage.tsx:50 - email input added |
| AC-002 | PASS | authService.ts:30 - validation added |
| AC-003 | PASS | LoginPage.tsx:80 - error display |

### Test Results

| Test | Result | Details |
|------|--------|---------|
| LoginPage.test.tsx | PASS | 8/8 tests |
| authService.test.ts | PASS | 5/5 tests |
| Regression suite | PASS | 45/45 tests |

### Files Changed

- src/pages/LoginPage.tsx (modified)
- src/services/authService.ts (modified)
- tests/pages/LoginPage.test.tsx (created)
- tests/services/authService.test.ts (created)

### Issues and Notes

[Any concerns or recommendations]
```

### Step 8: Submit Report

**Action:** Send report to PO

**Message Format:**
```json
{
  "message_type": "COMPLETION_REPORT",
  "agent_id": "agent-xxx",
  "task_id": "TASK-XXX",
  "report": {
    "ac_verification": [...],
    "test_results": [...],
    "files_changed": [...]
  },
  "submitted_at": "ISO8601"
}
```

### Step 9: Await NEXT

**Wait for PO response:**
- **NEXT:** Task complete, terminate
- **FIX:** Issues to address, retry
- **BLOCKED:** Cannot proceed, terminate

**On FIX:**
1. Read specific issues
2. Return to Step 5 or 6 based on issue
3. Address issues
4. Regenerate report
5. Max 2 fix attempts

---

## Progress Reporting

### Timing

Report progress:
- At each step transition
- Every 5 minutes during long steps
- On any significant event

### Progress Percentages

| Step | Percent Range |
|------|---------------|
| Initialize | 0-5% |
| Research | 5-15% |
| Plan | 15-25% |
| Await GO | 25% |
| Implement | 25-70% |
| Test | 70-90% |
| Report | 90-95% |
| Await NEXT | 95-100% |

---

## Error Handling

### Specification Conflict

```
STOP implementation
Document conflict in report
Report to PO as BLOCKED
```

### Test Failure (In Scope)

```
Analyze failure
Fix code or test
Re-run tests
Continue if pass
```

### Test Failure (Out of Scope)

```
Document failure
Note as out of scope
Include in report
PO determines resolution
```

### Timeout Approaching

```
Save current state
Report progress with warning
PO may extend or terminate
```

---

## Related Documentation

- [Task Assignment](task_assignment.md)
- [Agent Spawning](agent_spawning.md)
- [GO Gate](po_go_gate.md)
- [NEXT Gate](po_next_gate.md)
