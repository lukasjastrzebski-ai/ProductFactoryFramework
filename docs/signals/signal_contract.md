# Signal Contract

This document defines what every signal must provide to be considered valid.

---

## Required fields

Every signal entry must include:
- name
- source
- timestamp
- value
- trend (up / down / flat)
- confidence (high / medium / low)

---

## Optional fields
- segment (user cohort, plan, region)
- notes
- links to dashboards or logs

---

## Validity rules
- Signals must be reproducible or traceable
- Stale signals should be marked as such
- Estimates must be labeled

Signals without context should not drive decisions.