# Factory Versioning

This document defines how the Product Factory itself is versioned and evolved.

The factory is a product. Changes must be deliberate and traceable.

---

## Version format

MAJOR.MINOR.PATCH

- MAJOR: breaking change to contracts, structure, or rules
- MINOR: additive capability or stricter enforcement
- PATCH: clarification or documentation fixes

---

## When to bump versions

MAJOR:
- execution protocol changes
- planning stage changes
- test or quality gate changes

MINOR:
- new skills
- new automation
- new optional flows

PATCH:
- documentation improvements
- typo fixes
- clarifications

---

## Version authority

- Version is recorded in FACTORY_VERSION
- Kickoff copies version into .factory/factory_version.txt
- CI may validate compatibility

---

## Release discipline

- Every version bump must be recorded in CHANGELOG.md
- No silent version changes