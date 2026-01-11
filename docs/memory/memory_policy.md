# Memory Policy

This document defines strict rules for memory usage.

---

## Authority rule

Files always override memory.

If memory conflicts with repository state:
- ignore memory
- trust files

---

## Safety rules

- Memory must not introduce new scope
- Memory must not modify plans
- Memory must not justify skipping tests

---

## Review rule

Memory summaries should be verified against:
- execution reports
- execution state