# Migration Guide

This guide provides a complete walkthrough for adopting the Product Factory Framework on existing projects.

**Total estimated time: 5-13 hours** (varies by project size and complexity)

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Migration Philosophy](#migration-philosophy)
3. [Phase Overview](#phase-overview)
4. [Phase 0: Assessment](#phase-0-assessment)
5. [Phase 1: Structure](#phase-1-structure)
6. [Phase 2: Artifacts](#phase-2-artifacts)
7. [Phase 3: Quality](#phase-3-quality)
8. [Phase 4: Activation](#phase-4-activation)
9. [Minimal vs Full Adoption](#minimal-vs-full-adoption)
10. [Common Challenges](#common-challenges)
11. [Troubleshooting](#troubleshooting)
12. [Post-Migration Checklist](#post-migration-checklist)

---

## Prerequisites

Before beginning migration, ensure you have:

### Required

- [ ] Git repository with commit history
- [ ] Working codebase (builds and runs)
- [ ] Access to project documentation (if any exists)
- [ ] Basic understanding of the factory framework (read [README](../../README.md))
- [ ] 5-13 hours of dedicated time

### Recommended

- [ ] Existing test suite (any coverage level)
- [ ] CI/CD pipeline configured
- [ ] Knowledge of project architecture
- [ ] Access to original stakeholders or decision-makers

### Not Required

- Complete test coverage (you'll establish a baseline)
- Perfect documentation (you'll create what's needed)
- Clean architecture (you'll document what exists)

---

## Migration Philosophy

The factory migration follows three core principles:

### 1. Document What Exists

Do not invent requirements or idealize the system. Document the actual current state:
- What features are actually implemented?
- What architecture decisions were actually made?
- What tests actually exist?

### 2. Preserve Working Code

Migration should NOT require code changes. The goal is to wrap factory discipline around existing code:
- No refactoring required
- No test rewrites required
- No architecture changes required

### 3. Establish Baseline

Create a defensible starting point for future development:
- Current test coverage becomes the floor, not the ceiling
- Existing decisions become documented ADRs
- Current features become specifications

**Migration is documentation, not transformation.**

---

## Phase Overview

| Phase | Name | Purpose | Outputs |
|-------|------|---------|---------|
| 0 | Assessment | Understand current state | Assessment document |
| 1 | Structure | Set up factory files | Directory structure, config |
| 2 | Artifacts | Create specifications | Feature specs, ADRs, ai.md |
| 3 | Quality | Establish baseline | Quality baseline, CI config |
| 4 | Activation | Enable factory mode | Markers, state files, validation |

Each phase has explicit exit criteria. Do not proceed until exit criteria are met.

---

## Phase 0: Assessment

**Time: 1-2 hours**

See [Phase 0: Assessment](phase_0_assessment.md) for complete details.

### Purpose
Evaluate your project to determine migration scope and identify what documentation is needed.

### Key Activities
1. Inventory existing documentation
2. Catalog features (MVP vs secondary)
3. Map architecture components
4. Assess test coverage
5. Identify stakeholders
6. Decide migration scope

### Outputs
- Completed [Migration Assessment](templates/migration_assessment.md)
- Migration scope decision (Minimal/Standard/Full)

### Exit Criteria
- [ ] Assessment document completed
- [ ] Feature count known
- [ ] Architecture complexity understood
- [ ] Test coverage measured
- [ ] Migration scope decided

---

## Phase 1: Structure

**Time: 30-60 minutes**

See [Phase 1: Structure](phase_1_structure.md) for complete details.

### Purpose
Set up the factory directory structure and configuration files.

### Key Activities
1. Copy framework files to project
2. Create required directories
3. Configure permissions (.claude/settings.json)
4. Handle conflicts with existing files

### Outputs
- Factory directory structure
- CLAUDE.md configured
- .claude/settings.json configured

### Exit Criteria
- [ ] All required directories exist
- [ ] CLAUDE.md present and customized
- [ ] .claude/settings.json configured
- [ ] No file conflicts remaining

---

## Phase 2: Artifacts

**Time: 2-4 hours** (scales with project size)

See [Phase 2: Artifacts](phase_2_artifacts.md) for complete details.

### Purpose
Create retroactive specifications for existing features and architecture.

### Key Activities
1. Fill docs/ai.md product context
2. Create specs/features/index.md
3. Document MVP features with acceptance criteria
4. Create architecture/system.md
5. Write retroactive ADRs for past decisions

### Outputs
- Populated docs/ai.md
- Feature specifications for MVP features
- Architecture documentation
- Retroactive ADRs

### Priority Order
1. docs/ai.md (required for factory operation)
2. specs/features/index.md (feature overview)
3. MVP feature specs (most critical features)
4. architecture/system.md (system overview)
5. ADRs for major decisions
6. Secondary feature specs (if Full adoption)

### Exit Criteria
- [ ] docs/ai.md populated
- [ ] Feature index created
- [ ] MVP features documented
- [ ] System architecture documented
- [ ] Major ADRs written

---

## Phase 3: Quality

**Time: 1-2 hours**

See [Phase 3: Quality](phase_3_quality.md) for complete details.

### Purpose
Establish a quality baseline that prevents regression without requiring immediate improvements.

### Key Activities
1. Measure current test coverage
2. Create quality_baseline.md
3. Define quality targets
4. Configure CI workflows

### Outputs
- docs/quality/quality_baseline.md
- CI workflow configuration
- Documented exceptions

### Exit Criteria
- [ ] Current coverage measured
- [ ] Baseline documented
- [ ] CI configured
- [ ] Regression policy defined

---

## Phase 4: Activation

**Time: 30-60 minutes**

See [Phase 4: Activation](phase_4_activation.md) for complete details.

### Purpose
Enable factory execution mode and validate the setup.

### Key Activities
1. Create docs/execution/reports/ directory
2. Initialize state.md and progress.json
3. Create factory markers
4. Run validation
5. Execute first GO/NEXT cycle

### Outputs
- Execution state files
- Factory markers (.factory/*)
- Validation results
- First task report

### Exit Criteria
- [ ] Reports directory exists
- [ ] State files initialized
- [ ] Factory markers created
- [ ] Validation passed
- [ ] First GO/NEXT cycle completed

---

## Minimal vs Full Adoption

Choose your adoption level based on project needs and available time:

| Aspect | Minimal | Standard | Full |
|--------|---------|----------|------|
| **Time required** | 3-5 hours | 5-8 hours | 8-13 hours |
| **Feature specs** | MVP only | MVP + critical | All features |
| **ADRs** | None | Major decisions | All decisions |
| **Test baseline** | Current state | Current + gaps | Comprehensive |
| **Best for** | Quick adoption | Most projects | Regulated/complex |

### Minimal Adoption

Best for:
- Small projects with few features
- Projects needing quick factory adoption
- Proof-of-concept migrations

Includes:
- Basic directory structure
- docs/ai.md with product context
- Feature index with MVP features only
- Basic system.md
- Current test coverage as baseline

### Standard Adoption

Best for:
- Most production projects
- Teams wanting disciplined execution
- Projects with moderate complexity

Includes everything in Minimal, plus:
- Full MVP feature specifications
- Major architecture decisions documented as ADRs
- Quality targets defined
- CI workflow configured

### Full Adoption

Best for:
- Regulated industries
- Complex multi-team projects
- Projects requiring audit trails

Includes everything in Standard, plus:
- All feature specifications (including secondary)
- Comprehensive ADR coverage
- Detailed quality baseline with exception documentation
- Team training and onboarding materials

---

## Common Challenges

### "We don't have any documentation"

**Solution:** This is exactly what migration addresses. Use Phase 0 to discover what exists by examining code, and Phase 2 to create the minimum required documentation.

### "Our tests are incomplete"

**Solution:** Phase 3 establishes your current coverage as the baseline floor. You don't need complete coverage to migrate—you need to document what exists and prevent regression.

### "We don't know all the architectural decisions"

**Solution:** Document what you can observe. Create retroactive ADRs for decisions visible in the code (e.g., "We use PostgreSQL" is a documented decision even if the original rationale is unknown).

### "Multiple people built this, nobody knows everything"

**Solution:** Phase 0 includes stakeholder identification. Interview key people during assessment. Gaps in knowledge become "Open Questions" in documentation.

### "We're actively developing, can't pause for migration"

**Solution:** Migration does not require stopping development. Consider:
1. Migrate during a low-activity period
2. Assign one person to migration while others continue
3. Use Minimal adoption and expand later

### "Our architecture is messy"

**Solution:** Document the mess. The factory doesn't require clean architecture—it requires documented architecture. You can address technical debt later through proper change requests.

---

## Troubleshooting

### Problem: Claude Code doesn't recognize factory structure

**Symptoms:**
- AI doesn't follow GO/NEXT protocol
- AI ignores docs/ai.md
- AI modifies frozen files

**Solutions:**
1. Verify CLAUDE.md exists in project root
2. Check that docs/ai.md is properly formatted
3. Ensure .factory/PLANNING_FROZEN exists
4. Restart Claude Code session

### Problem: Test baseline keeps failing CI

**Symptoms:**
- CI fails on existing tests
- Coverage check fails

**Solutions:**
1. Verify baseline reflects actual current state
2. Check for flaky tests (document in exceptions)
3. Adjust threshold to match reality, not aspirations
4. Document known failures as accepted limitations

### Problem: Feature specifications don't match code

**Symptoms:**
- Acceptance criteria don't reflect actual behavior
- Specifications describe desired, not actual behavior

**Solutions:**
1. Reread migration philosophy: document what EXISTS
2. Update specs to match actual code behavior
3. Create change requests for desired improvements

### Problem: State files get out of sync

**Symptoms:**
- progress.json doesn't match reality
- state.md has stale data

**Solutions:**
1. Manual reconciliation during activation
2. Use factory validation tools
3. Reset state to current reality

### Problem: Unclear what's MVP vs secondary

**Symptoms:**
- Can't prioritize feature documentation
- Everything seems critical

**Solutions:**
1. Ask: "If this feature broke, would we stop shipping?"
2. Review actual usage metrics if available
3. Consult original stakeholders
4. When in doubt, mark as MVP (safer)

---

## Post-Migration Checklist

After completing all phases, verify:

### Structure Verification
- [ ] docs/migration/ contains all files
- [ ] docs/execution/reports/ exists with .gitkeep
- [ ] .factory/ contains required markers
- [ ] CLAUDE.md references migration guide

### Artifact Verification
- [ ] docs/ai.md populated with product context
- [ ] specs/features/index.md lists all features
- [ ] MVP features have specifications
- [ ] architecture/system.md describes current architecture
- [ ] At least one ADR exists (for Standard/Full adoption)

### Quality Verification
- [ ] docs/quality/quality_baseline.md exists
- [ ] Current test coverage documented
- [ ] CI workflow configured (if applicable)
- [ ] Regression policy defined

### Activation Verification
- [ ] docs/execution/state.md initialized
- [ ] docs/execution/progress.json initialized
- [ ] .factory/PLANNING_FROZEN exists
- [ ] .factory/RUN_MODE exists
- [ ] First GO/NEXT cycle completed successfully

### Team Readiness
- [ ] Team understands GO/NEXT protocol
- [ ] Team knows where to find documentation
- [ ] Escalation path for blockers defined
- [ ] First real task identified

---

## Next Steps

After migration is complete:

1. **Start using the Task Runner** - Follow [docs/execution/task_runner.md](../execution/task_runner.md)
2. **Create your first task** - Use [specs/_templates/task.md](../../specs/_templates/task.md)
3. **Review quality gates** - Understand [docs/quality/quality_gate.md](../quality/quality_gate.md)
4. **Know your escape hatches** - Review [docs/requests/change_request_flow.md](../requests/change_request_flow.md)

---

## Getting Help

If you encounter issues during migration:

1. Check this troubleshooting section
2. Review the specific phase documentation
3. Examine example migrations (if available)
4. Ask the Product Owner for clarification
5. Document gaps and continue—perfection is not required for activation
