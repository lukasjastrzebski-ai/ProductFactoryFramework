# Change Request Flow (Change Lane)

Use this flow when changing or correcting existing planned behavior during execution.

This flow preserves discipline while allowing necessary corrections.

---

## When to use
- Fixing incorrect requirements
- Adjusting acceptance criteria
- Modifying existing feature behavior
- Responding to bugs with scope impact

Do NOT use this flow for:
- adding net-new features (use New Feature Flow)

---

## Preconditions
- .factory/PLANNING_FROZEN exists
- Execution is blocked or incorrect behavior detected

---

## Required artifacts (in order)

1) Change Intake  
File: docs/requests/change_<id>_intake.md

2) Impact Analysis  
File: docs/requests/change_<id>_impact.md

3) Specification Updates  
- update affected specs/features/*
- update affected acceptance criteria

4) Test Plan Updates  
- update impacted Feature Test Plans

5) Plan Updates  
- update tasks or add new tasks
- include Test Delta for all affected tasks

6) Regression Plan  
File: docs/requests/change_<id>_regression.md

7) Execution Gate  
File: docs/requests/change_<id>_gate.md (must be APPROVED)

---

## Execution gate rules

Execution on the change may begin ONLY if:
- all artifacts above exist
- gate decision is APPROVED
- test coverage is updated

---

## After execution
- Update release notes
- Monitor regressions
- Capture lessons learned if planning error occurred