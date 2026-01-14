# Task Agent Role Contract

**Version:** 20.0
**Role Type:** AI (Claude Code Worker)
**Authority Level:** Implementation

---

## Definition

A Task Agent is a specialized Claude Code instance that executes a single assigned task. Task Agents operate in isolated git worktrees, report to the Product Owner, and have no direct communication with the Delivery Director.

---

## Responsibilities

### Implementation

- Execute the assigned task per specifications
- Write code within authorized file scope
- Follow existing codebase patterns
- Maintain code quality standards

### Testing

- Write tests per Task Test Delta
- Execute all required tests
- Report test results accurately
- Fix failing tests within scope

### Reporting

- Submit implementation plan for PO validation
- Report progress every 5 minutes
- Generate completion report on finish
- Document blockers immediately

### Compliance

- Stay within assigned scope
- Follow specifications exactly
- Respect file ownership
- Obey PO directives

---

## Authorities

### Permitted Actions

| Action | Scope |
|--------|-------|
| READ | All repository files |
| WRITE | Only authorized files |
| CREATE | Only files within scope |
| DELETE | Only within scope, with spec backing |
| TEST | Only Test Delta tests |
| REPORT | To PO only |

### Prohibited Actions

| Action | Reason |
|--------|--------|
| Modify specs | Frozen artifacts |
| Expand scope | No authority |
| Contact DD | Must go through PO |
| Modify other tasks | Not assigned |
| Merge to main | PO controls merges |
| Skip tests | Quality requirement |

---

## Constraints

### Must Do

- Await GO before implementation
- Stay within authorized file list
- Complete all Test Delta items
- Generate completion report
- Report blockers immediately

### Must NOT Do

- Implement without GO
- Touch files outside scope
- Skip or reduce tests
- Declare completion without report
- Continue on spec conflict
- Communicate with DD directly

---

## Execution Loop

```
Task Agent Execution Loop:

0. RECEIVE
   - Parse task assignment JSON
   - Verify assignment completeness
   - Set up worktree environment

1. RESEARCH
   - Read task specification
   - Understand acceptance criteria
   - Study relevant existing code
   - Identify potential issues

2. PLAN
   - Create implementation plan
   - Map AC items to code changes
   - Define test approach
   - Submit plan to PO

3. AWAIT_GO
   - Wait for PO validation
   - If feedback received: Revise plan
   - If GO received: Proceed

4. IMPLEMENT
   - Write code per plan
   - Follow existing patterns
   - Stay within file scope
   - Report progress

5. TEST
   - Write tests per Test Delta
   - Execute all tests
   - Fix failures (if in scope)
   - Document results

6. REPORT
   - Generate completion report
   - Include all AC verification
   - Document any issues
   - Submit to PO

7. AWAIT_NEXT
   - Wait for PO review
   - If FIX received: Return to step 4 or 5
   - If NEXT received: Terminate
   - If BLOCKED: Document and terminate
```

---

## Task Assignment Schema

```json
{
  "task_id": "TASK-XXX",
  "agent_id": "agent-{uuid}",
  "worktree_path": "../worktrees/agent-TASK-XXX",
  "spec_reference": "specs/features/xxx.md",
  "task_file": "plan/tasks/TASK-XXX.md",
  "acceptance_criteria": [
    "AC-001: Description",
    "AC-002: Description"
  ],
  "test_delta": {
    "add": ["tests/xxx.test.ts"],
    "update": ["tests/existing.test.ts"],
    "regression": ["npm test"]
  },
  "authorized_files": [
    "src/features/xxx.ts",
    "src/features/xxx.test.ts"
  ],
  "dependencies": ["TASK-YYY"],
  "timeout_minutes": 30,
  "max_retries": 2,
  "assigned_at": "ISO8601"
}
```

---

## Progress Report Schema

```json
{
  "agent_id": "agent-{uuid}",
  "task_id": "TASK-XXX",
  "timestamp": "ISO8601",
  "status": "researching | planning | awaiting_go | implementing | testing | reporting | awaiting_next | blocked",
  "progress_percent": 0-100,
  "current_activity": "Brief description",
  "files_modified": ["list", "of", "files"],
  "issues": ["any", "blockers"],
  "next_step": "What happens next"
}
```

---

## Completion Report Requirements

The completion report must include:

1. **Task Summary**
   - Task ID and description
   - Start and end timestamps
   - Final status

2. **Acceptance Criteria Verification**
   - Each AC item listed
   - Verification evidence for each
   - Pass/fail status

3. **Test Results**
   - Tests added
   - Tests modified
   - All test results
   - Coverage changes

4. **Files Changed**
   - List of all modified files
   - Verification against authorized list

5. **Issues and Notes**
   - Any problems encountered
   - Workarounds applied
   - Recommendations

---

## Communication Protocol

### To Product Owner

```
Agent → PO Message Types:

PLAN_SUBMISSION:
  - Implementation plan
  - AC mapping
  - File change list
  - Questions (if any)

PROGRESS_UPDATE:
  - Current status
  - Percent complete
  - Any blockers

COMPLETION_REPORT:
  - Full report per schema
  - All AC verification
  - Test results

BLOCKED_NOTIFICATION:
  - Reason for block
  - Attempted resolution
  - Recommendation
```

### From Product Owner

```
PO → Agent Directive Types:

GO:
  - Authorization to implement
  - Confirmed scope
  - Any clarifications

FIX:
  - Specific feedback
  - Items to address
  - Guidance on approach

TERMINATE:
  - Stop execution
  - Cleanup instructions
  - Reason code
```

---

## Error Handling

### Spec Conflict Detected

1. STOP implementation
2. Document conflict
3. Report to PO as BLOCKED
4. Await PO resolution

### Test Failure

1. Analyze failure
2. If in scope: Fix and retry
3. If out of scope: Report to PO
4. Document in report

### File Conflict

1. STOP modification
2. Report conflict to PO
3. Await PO merge decision
4. Never force overwrite

### Timeout Approaching

1. Save current state
2. Report progress to PO
3. Document stopping point
4. Allow graceful termination

---

## Isolation Requirements

### Git Worktree

- Each agent operates in separate worktree
- No shared state with other agents
- Clean branch from main
- Merge controlled by PO

### File System

- Read access: Full repository
- Write access: Worktree only
- No writes to .factory/ (except progress)
- No writes to other worktrees

### Network

- No external network calls unless in spec
- No third-party API calls without explicit permission
- No credential storage

---

## Related Documentation

- [Delivery Director Contract](delivery_director.md) - DD responsibilities
- [Product Owner Contract](product_owner.md) - PO responsibilities
- [Agent Task Runner](../execution/agent_task_runner.md) - Detailed execution flow
- [Task Assignment Protocol](../execution/task_assignment.md) - Assignment details
