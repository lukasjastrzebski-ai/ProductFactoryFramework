# Migration Readiness Checklist

**Version:** 20.0

Complete this checklist before beginning migration to ProductFactoryFramework.

---

## Pre-Migration Requirements

### Documentation

- [ ] README exists and is current
- [ ] Architecture documentation available
- [ ] API documentation exists (if applicable)
- [ ] User stories or requirements documented
- [ ] Known issues/tech debt documented

### Codebase

- [ ] Repository is accessible
- [ ] Main branch is stable
- [ ] No blocking CI/CD failures
- [ ] Dependencies are documented
- [ ] Environment variables documented

### Testing

- [ ] Test suite exists
- [ ] Tests are passing
- [ ] Test coverage is known
- [ ] Critical paths have tests

### Team

- [ ] Migration lead assigned
- [ ] Team briefed on factory methodology
- [ ] Time allocated for migration
- [ ] Stakeholders informed

---

## Technical Readiness

### Source Control

| Item | Status | Notes |
|------|--------|-------|
| Git repository | Ready / Not Ready | |
| Branch protection | Configured / Not | |
| CI/CD pipeline | Working / Broken / None | |

### Environment

| Item | Status | Notes |
|------|--------|-------|
| Development env | Ready / Not Ready | |
| Staging env | Ready / Not Ready / N/A | |
| Production env | Documented / Not | |

### Dependencies

| Item | Status | Notes |
|------|--------|-------|
| Package manager | npm/yarn/pnpm/other | |
| Lock file | Present / Missing | |
| Outdated deps | None / Some / Many | |
| Security vulns | None / Some / Many | |

---

## Factory Preparation

### Required Files

- [ ] `.factory/` directory can be created
- [ ] `CLAUDE.md` location confirmed
- [ ] `docs/` directory structure planned

### Artifact Mapping

| Existing | Factory Equivalent | Ready |
|----------|-------------------|-------|
| Requirements doc | `specs/` | Yes/No |
| Architecture doc | `architecture/` | Yes/No |
| Task list | `plan/` | Yes/No |
| Test plan | `docs/quality/` | Yes/No |

---

## Risk Checklist

### Blockers

- [ ] No active production incidents
- [ ] No pending major releases
- [ ] No team members on leave
- [ ] No external audit in progress

### Concerns (document if present)

| Concern | Severity | Mitigation Plan |
|---------|----------|-----------------|
| [Concern] | High/Medium/Low | [Plan] |

---

## Sign-Off

### Checklist Completion

| Section | Complete | Reviewer |
|---------|----------|----------|
| Pre-Migration | Yes/No | [Name] |
| Technical | Yes/No | [Name] |
| Factory Prep | Yes/No | [Name] |
| Risk | Yes/No | [Name] |

### Approval

**Ready for Migration:** Yes / No

**Approved By:** [Name]
**Date:** [Date]

**Notes:**
[Any additional notes or conditions]

---

## Next Steps

After checklist is complete:

1. Run migration assessment
2. Create factory structure
3. Import existing documentation
4. Run gap analysis
5. Begin Stage 1 (Discovery)

---

## Related Documentation

- [Migration Assessment](migration_assessment.md)
- [Migration Guide](../migration/migration_guide.md)
