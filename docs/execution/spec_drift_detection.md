# Spec Drift Detection

**Version:** 20.0

This document describes how the PO detects when implementations drift from specifications.

---

## Overview

Spec drift occurs when the implementation doesn't match what was specified. The PO detects drift during plan validation and report review.

---

## Types of Drift

### 1. Missing Functionality

Implementation doesn't include something specified.

**Example:**
- Spec: "User can reset password via email"
- Implementation: No password reset feature

**Detection:** AC item not addressed in plan/report

### 2. Extra Functionality

Implementation includes something not specified.

**Example:**
- Spec: "User can log in"
- Implementation: Login + "remember me" + OAuth

**Detection:** Changes that don't map to AC items

### 3. Different Functionality

Implementation does something different than specified.

**Example:**
- Spec: "Show error message inline"
- Implementation: Error shown as toast notification

**Detection:** AC evidence doesn't match criterion

### 4. Partial Functionality

Implementation only partially meets specification.

**Example:**
- Spec: "Validate email format"
- Implementation: Only checks for @ symbol

**Detection:** Test doesn't fully verify AC

---

## Detection Points

### During Plan Validation

```
FOR each planned_change in plan:
  FIND matching AC item
  IF no match:
    FLAG as potential_drift: "Extra functionality"

FOR each AC_item in specification:
  FIND matching planned_change
  IF no match:
    FLAG as missing: "AC not addressed"
```

### During Report Review

```
FOR each AC_verification in report:
  CHECK evidence matches AC description
  IF evidence doesn't match:
    FLAG as drift: "Different implementation"

FOR each file_change in report:
  CHECK change relates to AC
  IF unrelated:
    FLAG as drift: "Scope expansion"
```

---

## Drift Categories

| Category | Severity | Action |
|----------|----------|--------|
| Missing AC | HIGH | FIX required |
| Extra functionality | MEDIUM | Revert or CR |
| Different approach | VARIES | Review needed |
| Partial coverage | HIGH | FIX required |

---

## Drift Response

### Minor Drift (MEDIUM)

1. Note in validation feedback
2. Request revision/revert
3. Allow continuation if addressed

### Major Drift (HIGH)

1. Block GO/NEXT
2. Require plan revision
3. May need CR flow

### Persistent Drift

1. Mark task BLOCKED
2. Document pattern
3. Escalate if needed

---

## Prevention

### Before GO

- Thorough plan review
- AC mapping verification
- Explicit scope confirmation

### During Implementation

- Agent stays within scope
- Regular progress checks
- Early drift detection

### After Implementation

- Report vs spec comparison
- Evidence verification
- Scope audit

---

## Related Documentation

- [Plan Validator (Skill PO-01)](../skills/skill_po_plan_validator.md)
- [Report Reviewer (Skill PO-02)](../skills/skill_po_report_reviewer.md)
- [Change Request Flow](../requests/change_request_flow.md)
