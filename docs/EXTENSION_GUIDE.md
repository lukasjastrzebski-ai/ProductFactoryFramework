# Extension Guide

How to extend the factory safely without breaking its discipline.

## Adding New Skills

### Where to add

Location: `docs/skills/skill_XX_<name>.md`

Naming convention: Two-digit number, underscore, descriptive name

### Skill structure

Follow existing skill format (source: existing skills in [docs/skills/](skills/)):

```markdown
# Skill XX - <Name>

Purpose:
<One sentence describing what this skill accomplishes>

Steps:
1) <First step>
2) <Second step>
...

Output:
- <What this skill produces>
```

### Rules for new skills

1. **Skills cannot expand scope** - A skill cannot introduce new work
2. **Skills cannot bypass GO/NEXT** - All authorization flows remain
3. **Skills cannot override files** - File authority hierarchy is preserved
4. **Skills must be documented** - Add to skills/README.md index

### Validation

After adding a skill:
- Reference it in relevant playbook sections if applicable
- Ensure it does not conflict with existing skills
- Test the skill in isolation

## Adding New CI Checks

### Where to add

Location: `.github/workflows/`

Options:
- Add step to existing workflow (`factory-guardrails.yml` or `quality-autopilot.yml`)
- Create new workflow file

### Guidelines

1. **Non-destructive** - Checks should validate, not modify
2. **Clear failure messages** - Echo specific error before `exit 1`
3. **Consistent with factory philosophy** - Enforce discipline, not convenience
4. **Document what the check enforces** - Comment in workflow file

### Example: Adding a check for task file structure

```yaml
- name: Validate task file structure
  run: |
    for task in plan/tasks/TASK-*.md; do
      [ -f "$task" ] || continue
      if ! grep -q "## Test Delta" "$task"; then
        echo "ERROR: Task $task missing Test Delta section"
        exit 1
      fi
      if ! grep -q "## Acceptance Criteria" "$task"; then
        echo "ERROR: Task $task missing Acceptance Criteria section"
        exit 1
      fi
    done
    echo "Task file structure validation passed"
```

### After adding

- Run workflow manually to test
- Update this guide if adding significant new enforcement
- Consider impact on existing workflows

## Modifying Quality Rules

### Source files

| Rule type | Location |
|-----------|----------|
| Pass/fail criteria | [docs/quality/quality_gate.md](quality/quality_gate.md) |
| Minimum standards | [docs/quality/quality_baseline.md](quality/quality_baseline.md) |
| Regression handling | [docs/quality/quality_regression_rules.md](quality/quality_regression_rules.md) |
| Test strategy | [docs/testing/test_strategy.md](testing/test_strategy.md) |
| Test plan rules | [docs/testing/test_plan_rules.md](testing/test_plan_rules.md) |

### Change process

1. **Document the reason** - Why is the change needed?
2. **Assess impact** - What existing processes are affected?
3. **Update source file** - Modify the relevant quality document
4. **Update enforcement** - Modify CI checks if automated enforcement needed
5. **Bump factory version** - Material changes require version bump

### What requires version bump

According to [docs/factory_versioning.md](factory_versioning.md):

- MAJOR: Quality gate changes
- MINOR: Stricter enforcement
- PATCH: Clarifications

## Introducing New Lifecycle Stages

### Current stages (source: [docs/ideation_playbook.md](ideation_playbook.md))

0. Idea Intake
1. Vision, Strategy, Metrics, Risks
2. Product Definition
3. Feature Discovery
4. Architecture
5. Implementation Planning
6. Execution Readiness Check
7. AI Contract Finalization

### Guidelines for new stages

**Do NOT add stages lightly.** The existing stages are designed to be complete.

If a new stage is truly needed:

1. **Identify the gap** - What cannot be accomplished within existing stages?
2. **Define outputs** - What files must be produced?
3. **Define exit criteria** - When is the stage complete?
4. **Position in sequence** - Where does it fit?
5. **Update ideation_playbook.md** - Add the stage definition
6. **Update EXECUTION_READINESS_TEMPLATE.md** - Add validation for stage outputs
7. **Update CI** - Add any necessary checks
8. **Bump MAJOR version** - Stage changes are breaking

### Recommendation

Before adding a stage, consider:
- Can this be a sub-activity within an existing stage?
- Can this be a skill rather than a stage?
- Can this be a quality check rather than a stage?

## What MUST NOT Be Changed Lightly

### Critical contracts

| File | Impact of change |
|------|-----------------|
| docs/ai.md | Changes what Claude may and may not do. MAJOR version bump required. |
| docs/execution/task_runner.md | Changes execution protocol. MAJOR version bump required. |
| docs/ideation_playbook.md | Changes planning process. MAJOR version bump required. |

### Frozen artifact rules

Changes to what gets frozen after Stage 7 require:
- Explicit justification
- Update to docs/planning_freeze.md
- Update to .claude/settings.json deny rules
- Update to CI validation
- MAJOR version bump

### Authority hierarchy

Changes to authority order (ai.md > specs > execution > memory) require:
- Comprehensive impact analysis
- Update across all referencing documents
- MAJOR version bump

### Claude Code permissions

Changes to .claude/settings.json affect:
- What Claude can read/write
- What operations are blocked
- Must be tested carefully

## Safe Extension Patterns

### Pattern: New request type

If you need a request flow other than Change Request or New Feature:

1. Create flow document: `docs/requests/<type>_flow.md`
2. Create templates: `docs/requests/templates/<type>_*.md`
3. Update CI to validate gates: `.github/workflows/factory-guardrails.yml`
4. Document in this guide

### Pattern: New validation tool

If you need a new validation script:

1. Create script: `tools/validate_<name>.sh`
2. Make executable: `chmod +x`
3. Add to CI if should be enforced
4. Document in FACTORY_REFERENCE.md

### Pattern: New signal source

If you need to add signal categories:

1. Add to docs/signals/signal_sources.md
2. Update generate_signal_snapshot.sh if automated
3. Document in FACTORY_REFERENCE.md

## Version Bump Checklist

When extending the factory:

- [ ] Changes documented in relevant source files
- [ ] CI updated if enforcement needed
- [ ] CHANGELOG.md updated
- [ ] FACTORY_VERSION updated
- [ ] factory_versioning.md rules followed (MAJOR/MINOR/PATCH)
