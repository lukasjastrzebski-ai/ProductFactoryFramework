# Decision Rules

This document defines conservative rules for ranking and recommending work.

---

## Guiding principles

- Quality over speed
- Fix regressions before adding scope
- Finish started work before starting new work
- Prefer small, reversible steps

---

## Priority order

1) Critical regressions
2) Blocked execution issues
3) Planned tasks in current phase
4) High-confidence signal-driven improvements
5) New features (after impact analysis)

---

## Risk handling

- High-risk changes require stronger evidence
- Low-confidence signals should not drive large scope changes
- Manual PO overrides supersede ranking

---

## Output discipline

- Recommendations must be explicit
- Rationale must be documented
- Alternatives should be listed when applicable