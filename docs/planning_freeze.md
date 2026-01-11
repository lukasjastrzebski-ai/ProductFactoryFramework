# Planning Freeze Rules

Planning freeze protects execution discipline.

---

## What freeze means

When .factory/PLANNING_FROZEN exists:
- specs/ are frozen
- architecture/ is frozen
- plan/ is frozen

Execution may proceed.

---

## Allowed changes during freeze

Only allowed via APPROVED gates:
- Change Request
- New Feature

All other changes are forbidden.

---

## CI enforcement

CI must fail if:
- frozen files are modified without gate artifacts
- planning artifacts drift silently

---

## Lifting the freeze

Freeze is lifted only by:
- explicit Product Owner decision
- new planning cycle