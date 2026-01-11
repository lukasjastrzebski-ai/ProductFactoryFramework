# New Feature Flow (Expansion Lane)

Use this flow when a new feature is discovered during execution that was not part of the original plan.

This flow allows controlled expansion without corrupting the execution discipline.

---

## When to use
- A critical feature was missed during planning
- Market, legal, or platform constraints require new functionality
- Signals or PO insight indicate high-impact opportunity

Do NOT use this flow for:
- fixing bugs
- changing existing behavior (use Change Request instead)

---

## Preconditions
- .factory/PLANNING_FROZEN exists
- Execution is currently blocked or paused for scope reasons

---

## Required artifacts (in order)

1) Feature Intake  
File: docs/requests/feature_<id>_intake.md

2) Impact Analysis  
File: docs/requests/feature_<id>_impact.md

3) Feature Specification  
File: specs/features/<feature_slug>.md

4) Feature Test Plan  
File: specs/tests/feature_<feature_slug>_test_plan.md

5) Architecture Updates (if required)  
Files under architecture/ and ADRs

6) Plan Updates  
- plan/roadmap.md (if sequencing changes)
- new or updated phase docs
- new task files with Test Delta

7) Regression Plan  
File: docs/requests/feature_<id>_regression.md

8) Execution Gate  
File: docs/requests/feature_<id>_gate.md (must be APPROVED)

---

## Execution gate rules

Execution on the new feature may begin ONLY if:
- all artifacts above exist
- gate decision is APPROVED
- test plans and Test Delta exist

Without an APPROVED gate, execution is forbidden.

---

## After execution
- Include feature in release notes
- Update signals if applicable
- Capture lessons learned if planning failed to anticipate this feature