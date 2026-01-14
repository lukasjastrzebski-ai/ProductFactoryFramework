# Retroactive ADR Template

**Version:** 20.0

Use this template to document architectural decisions that were made before formal ADR process was in place.

---

## ADR-[XXX]: [Decision Title]

**Status:** Accepted (Retroactive)
**Date Decided:** [Original date, approximate if unknown]
**Date Documented:** [Today's date]
**Deciders:** [Names if known, or "Unknown"]

---

## Context

### Historical Context

[Describe the situation at the time the decision was made]

- What was the team working on?
- What constraints existed?
- What was the technical landscape?

### Problem Statement

[What problem was being solved?]

### Constraints at the Time

- [Constraint 1]
- [Constraint 2]
- [Time pressure, team size, expertise, etc.]

---

## Decision

### What Was Decided

[Clear statement of the architectural decision]

### How It Was Implemented

[Description of the implementation]

### Files/Components Affected

| Component | Changes |
|-----------|---------|
| [component] | [what changed] |

---

## Alternatives Considered

*Note: This section may be incomplete if documentation wasn't kept at decision time.*

### Option 1: [Name]

- **Description:** [Brief description]
- **Pros:** [If known]
- **Cons:** [If known]
- **Why not chosen:** [If known]

### Option 2: [Name] (Chosen)

- **Description:** [Brief description]
- **Pros:** [If known]
- **Cons:** [If known]
- **Why chosen:** [If known]

---

## Consequences

### Positive

- [Positive outcome 1]
- [Positive outcome 2]

### Negative

- [Negative outcome 1]
- [Technical debt incurred]

### Neutral

- [Side effects]

---

## Current State

### Is This Decision Still Valid?

- [ ] Yes, still the right choice
- [ ] Partially - some aspects need revisiting
- [ ] No - should be changed (create new ADR)

### Technical Debt Incurred

| Item | Severity | Remediation |
|------|----------|-------------|
| [debt item] | High/Medium/Low | [planned action] |

### Lessons Learned

- [What we learned from this decision]
- [What we would do differently]

---

## Evidence

### Code References

```
path/to/relevant/code.ts:line
```

### Related PRs/Commits

- [PR #XXX](link) - [description]
- [Commit SHA](link) - [description]

### Related Documentation

- [Link to related docs]

---

## Reconstruction Notes

*This section documents how this ADR was reconstructed.*

### Sources Used

- [ ] Code archaeology (git blame, history)
- [ ] Team interviews
- [ ] Old documentation
- [ ] Commit messages
- [ ] PR descriptions
- [ ] Slack/email archives

### Confidence Level

**High / Medium / Low**

[Explain confidence in the accuracy of this reconstruction]

### Gaps in Knowledge

- [What we couldn't determine]
- [Assumptions made]

---

## Related ADRs

- [ADR-XXX](link) - [relationship]

---

## Review

**Reviewed By:** [Name]
**Review Date:** [Date]
**Review Notes:** [Any corrections or additions from review]
