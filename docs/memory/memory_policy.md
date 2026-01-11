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

Memory must not be used to justify violating docs/ai.md. Specifically:
- Memory cannot introduce new scope
- Memory cannot override planning artifacts
- Memory cannot justify skipping tests

See docs/ai.md for the authoritative list of forbidden actions.

---

## Review rule

Memory summaries should be verified against:
- execution reports
- execution state