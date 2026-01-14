# Task Assignment Protocol

**Version:** 20.0

This document defines how tasks are assigned to Task Agents in v20 autonomous mode.

---

## Overview

The Product Owner creates task assignments that fully specify what an agent should implement. Assignments include scope boundaries, acceptance criteria, authorized files, and test requirements.

---

## Assignment Creation

### When PO Creates Assignment

1. Task selected for execution from dependency graph
2. Task dependencies satisfied
3. Agent slot available
4. No file conflicts with active agents

### Assignment Contents

The assignment must be complete and unambiguous:
- Agent should be able to work independently
- All necessary context included
- Boundaries clearly defined

---

## Assignment Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "task_id",
    "agent_id",
    "worktree_path",
    "task_file",
    "acceptance_criteria",
    "test_delta",
    "authorized_files",
    "timeout_minutes",
    "assigned_at"
  ],
  "properties": {
    "task_id": {
      "type": "string",
      "pattern": "^TASK-[A-Z0-9-]+$",
      "description": "Task identifier"
    },
    "agent_id": {
      "type": "string",
      "pattern": "^agent-[a-z0-9]+$",
      "description": "Assigned agent identifier"
    },
    "worktree_path": {
      "type": "string",
      "description": "Path to agent's git worktree"
    },
    "spec_reference": {
      "type": "string",
      "description": "Path to feature specification"
    },
    "task_file": {
      "type": "string",
      "description": "Path to task definition file"
    },
    "acceptance_criteria": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "description"],
        "properties": {
          "id": {"type": "string"},
          "description": {"type": "string"},
          "testable": {"type": "boolean", "default": true}
        }
      }
    },
    "test_delta": {
      "type": "object",
      "required": ["add", "update", "regression"],
      "properties": {
        "add": {
          "type": "array",
          "items": {"type": "string"},
          "description": "New test files to create"
        },
        "update": {
          "type": "array",
          "items": {"type": "string"},
          "description": "Existing test files to update"
        },
        "regression": {
          "type": "array",
          "items": {"type": "string"},
          "description": "Regression suites to run"
        }
      }
    },
    "authorized_files": {
      "type": "array",
      "items": {"type": "string"},
      "description": "Files agent is authorized to modify"
    },
    "dependencies": {
      "type": "array",
      "items": {"type": "string"},
      "description": "Completed dependency task IDs"
    },
    "timeout_minutes": {
      "type": "integer",
      "minimum": 5,
      "maximum": 120,
      "description": "Task timeout in minutes"
    },
    "max_retries": {
      "type": "integer",
      "minimum": 0,
      "maximum": 5,
      "default": 2
    },
    "assigned_at": {
      "type": "string",
      "format": "date-time"
    }
  }
}
```

---

## Complete Assignment Example

```json
{
  "task_id": "TASK-001",
  "agent_id": "agent-a1b2c3d4",
  "worktree_path": "../worktrees/agent-a1b2c3d4-TASK-001",
  "spec_reference": "specs/features/authentication.md",
  "task_file": "plan/tasks/TASK-001.md",
  "acceptance_criteria": [
    {
      "id": "AC-001",
      "description": "User can enter email and password in login form",
      "testable": true
    },
    {
      "id": "AC-002",
      "description": "Form validates email format before submission",
      "testable": true
    },
    {
      "id": "AC-003",
      "description": "Error message displayed for invalid credentials",
      "testable": true
    },
    {
      "id": "AC-004",
      "description": "Successful login redirects to dashboard",
      "testable": true
    }
  ],
  "test_delta": {
    "add": [
      "tests/pages/LoginPage.test.tsx",
      "tests/services/authService.test.ts"
    ],
    "update": [],
    "regression": [
      "npm run test:unit",
      "npm run test:e2e -- --grep login"
    ]
  },
  "authorized_files": [
    "src/pages/LoginPage.tsx",
    "src/pages/LoginPage.css",
    "src/services/authService.ts",
    "src/types/auth.ts",
    "tests/pages/LoginPage.test.tsx",
    "tests/services/authService.test.ts"
  ],
  "dependencies": [],
  "timeout_minutes": 30,
  "max_retries": 2,
  "assigned_at": "2026-01-14T10:00:00Z"
}
```

---

## File Authorization

### Authorized Files

Files the agent can modify:
- Listed explicitly in assignment
- Agent must stay within this scope
- Violations flagged by PO

### Determining Authorization

PO determines authorized files by:

1. **Task Definition** - Files mentioned in task spec
2. **Acceptance Criteria** - Files needed for each AC
3. **Test Delta** - Test files to create/update
4. **Existing Patterns** - Related files based on codebase

### Authorization Rules

```
AUTHORIZED:
- Files explicitly listed
- New files in authorized directories
- Test files for authorized source files

NOT AUTHORIZED:
- Files owned by other active agents
- Specification files (specs/)
- Architecture files (architecture/)
- Plan files (plan/)
- Factory state files (.factory/)
```

---

## Acceptance Criteria Format

### Good AC Examples

```json
{
  "id": "AC-001",
  "description": "Login form displays email and password input fields",
  "testable": true
}
```

```json
{
  "id": "AC-002",
  "description": "Clicking 'Submit' with invalid email shows 'Invalid email format' error",
  "testable": true
}
```

### Bad AC Examples

```json
{
  "description": "Login should work well",
  "testable": false  // Too vague
}
```

```json
{
  "description": "User experience should be good",
  "testable": false  // Subjective
}
```

---

## Test Delta Requirements

### Add

New test files to create:
```json
{
  "add": [
    "tests/pages/LoginPage.test.tsx"
  ]
}
```

Agent must:
- Create the file
- Write tests for all AC items
- Tests must pass

### Update

Existing test files to modify:
```json
{
  "update": [
    "tests/services/auth.test.ts"
  ]
}
```

Agent must:
- Modify specified file
- Add tests for new functionality
- Existing tests must still pass

### Regression

Test suites to run:
```json
{
  "regression": [
    "npm run test:unit",
    "npm run test:e2e -- --grep auth"
  ]
}
```

Agent must:
- Run all specified suites
- All tests must pass
- Report any failures

---

## Assignment Delivery

### File Location

```
.factory/agent_progress/{agent-id}_assignment.json
```

### Agent Reception

Agent receives assignment when spawned and must:

1. Parse assignment JSON
2. Validate completeness
3. Report readiness to PO
4. Begin research phase

---

## Assignment Validation

PO validates assignments before delivery:

```
CHECK assignment:
  - task_id matches plan/tasks/ file
  - All AC items are testable
  - Test delta covers all AC
  - Authorized files are specific
  - No conflicts with active agents
  - Dependencies all have NEXT gate
```

---

## Related Documentation

- [Agent Spawning](agent_spawning.md)
- [Agent Task Runner](agent_task_runner.md)
- [GO Gate](po_go_gate.md)
