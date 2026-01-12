# Phase 4: Activation

**Time: 30-60 minutes**

Phase 4 enables factory execution mode and validates the complete migration setup.

---

## Overview

Activation is the final step before using the factory. You will:
1. Initialize execution state files
2. Create factory markers
3. Validate the setup
4. Run a test GO/NEXT cycle

After this phase, you can use the full GO/NEXT execution protocol.

---

## Step 1: Initialize Execution State

### Create docs/execution/state.md

If not already created, initialize the state file:

```markdown
# Execution State

## Metadata

| Field | Value |
|-------|-------|
| updated_at | YYYY-MM-DD |
| current_phase | migration_complete |

---

## Recent Tasks (Last 5)

| Task ID | Status | Report Path | Completed At |
|---------|--------|-------------|--------------|
|         |        |             |              |
|         |        |             |              |
|         |        |             |              |
|         |        |             |              |
|         |        |             |              |

---

## Current Blockers

| Blocker | Severity | Resolution Status | Owner |
|---------|----------|-------------------|-------|
|         |          |                   |       |

---

## Recent File Changes

| Session Date | Files Modified |
|--------------|----------------|
|              |                |

---

## Notes

Factory migration completed on YYYY-MM-DD.
Ready for GO/NEXT execution.
```

### Create docs/execution/progress.json

Initialize progress tracking:

```json
{
  "version": "1.0",
  "product": "YOUR_PRODUCT_NAME",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ",
  "current_phase": "implementation",
  "features": [
    {
      "id": "FEAT-001",
      "name": "Feature Name",
      "status": "complete",
      "tasks": []
    }
  ],
  "blockers": [],
  "metrics": {
    "tasks_completed": 0,
    "tasks_total": 0,
    "tasks_blocked": 0,
    "test_coverage": null
  }
}
```

Update with your actual features from specs/features/index.md.

### Ensure Reports Directory Exists

```bash
mkdir -p docs/execution/reports
touch docs/execution/reports/.gitkeep
```

---

## Step 2: Create Factory Markers

Factory markers are empty files that signal factory state:

```bash
# Navigate to project root
cd /path/to/your/project

# Create .factory directory if not exists
mkdir -p .factory

# Create markers
touch .factory/KICKOFF_COMPLETE
touch .factory/PLANNING_FROZEN
touch .factory/RUN_MODE

# Create version file
echo "v10.1" > .factory/factory_version.txt

# Record migration completion
echo "Migration completed: $(date -u +%Y-%m-%dT%H:%M:%SZ)" > .factory/MIGRATION_COMPLETE
```

### Marker Meanings

| Marker | Purpose |
|--------|---------|
| `KICKOFF_COMPLETE` | Signals kickoff/planning is done |
| `PLANNING_FROZEN` | Prevents changes to specs/architecture/plan |
| `RUN_MODE` | Indicates active execution mode |
| `factory_version.txt` | Records framework version |
| `MIGRATION_COMPLETE` | Records migration timestamp |

---

## Step 3: Run Validation

### Manual Validation Checklist

Run through this checklist to verify setup:

```bash
# 1. Verify core files
echo "=== Core Files ===" && \
ls -la CLAUDE.md docs/ai.md .claude/settings.json

# 2. Verify directory structure
echo "=== Directory Structure ===" && \
ls -la docs/execution/ && \
ls -la docs/quality/ && \
ls -la specs/features/ && \
ls -la architecture/

# 3. Verify factory markers
echo "=== Factory Markers ===" && \
ls -la .factory/

# 4. Verify state files
echo "=== State Files ===" && \
cat docs/execution/state.md | head -20 && \
cat docs/execution/progress.json | head -20

# 5. Verify quality baseline
echo "=== Quality Baseline ===" && \
ls -la docs/quality/quality_baseline.md

# 6. Run tests (verify CI works)
echo "=== Tests ===" && \
npm test  # or your test command
```

### Validation Script

Create and run a validation script:

```bash
#!/bin/bash
# validate_migration.sh

ERRORS=0

check_file() {
    if [ -f "$1" ]; then
        echo "✓ $1"
    else
        echo "✗ $1 MISSING"
        ERRORS=$((ERRORS + 1))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo "✓ $1/"
    else
        echo "✗ $1/ MISSING"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "=== Validating Factory Migration ==="
echo ""

echo "Core Files:"
check_file "CLAUDE.md"
check_file "docs/ai.md"
check_file ".claude/settings.json"
echo ""

echo "Execution Infrastructure:"
check_dir "docs/execution"
check_dir "docs/execution/reports"
check_file "docs/execution/state.md"
check_file "docs/execution/progress.json"
check_file "docs/execution/task_runner.md"
echo ""

echo "Quality Infrastructure:"
check_dir "docs/quality"
check_file "docs/quality/quality_gate.md"
check_file "docs/quality/quality_baseline.md"
echo ""

echo "Specifications:"
check_dir "specs/features"
check_file "specs/features/index.md"
check_dir "specs/_templates"
echo ""

echo "Architecture:"
check_dir "architecture"
check_file "architecture/system.md"
check_dir "architecture/decisions"
echo ""

echo "Factory Markers:"
check_file ".factory/KICKOFF_COMPLETE"
check_file ".factory/PLANNING_FROZEN"
check_file ".factory/RUN_MODE"
echo ""

echo "=== Validation Complete ==="
if [ $ERRORS -eq 0 ]; then
    echo "✓ All checks passed"
    exit 0
else
    echo "✗ $ERRORS check(s) failed"
    exit 1
fi
```

Run it:
```bash
chmod +x validate_migration.sh
./validate_migration.sh
```

---

## Step 4: Execute First GO/NEXT Cycle

The best way to validate migration is to run an actual task. Create a simple validation task:

### Create Validation Task

Create `plan/tasks/TASK-000-migration-validation.md`:

```markdown
# TASK-000: Migration Validation

## Goal
Validate that the factory migration is complete and functional.

## In Scope
- Verify all factory files exist
- Confirm state tracking works
- Test report generation

## Out of Scope
- Any code changes
- Test modifications

## Dependencies
- None

## Expected Files to Touch
- docs/execution/state.md (update)
- docs/execution/progress.json (update)
- docs/execution/reports/TASK-000.md (create)

## Commands to Run
- `./validate_migration.sh` (or manual validation)

## Acceptance Criteria
- [ ] All validation checks pass
- [ ] Report generated successfully
- [ ] State file updated
- [ ] Progress JSON updated

## Test Delta
- Tests to add: None (validation task)
- Tests to update: None
- Regression suites: None
```

### Run GO/NEXT Cycle

1. **Request GO:**
   - AI reads task and summarizes
   - AI requests GO from Product Owner

2. **Product Owner says GO**

3. **AI executes:**
   - Runs validation checks
   - Creates report

4. **AI creates report:**
   - Creates `docs/execution/reports/TASK-000.md`
   - Updates `docs/execution/state.md`
   - Updates `docs/execution/progress.json`

5. **AI requests NEXT:**
   - Presents completion summary
   - Requests NEXT from Product Owner

6. **Product Owner says NEXT or STOP**

### Expected Report

After the cycle, `docs/execution/reports/TASK-000.md` should exist:

```markdown
# Completion Report – TASK-000

Status: COMPLETE

---

## Summary
Migration validation task completed successfully. All factory infrastructure is in place and functional.

## Scope adherence
In scope:
- Factory file verification
- State tracking validation
- Report generation test

Out of scope:
- None attempted

## Files changed
- docs/execution/state.md (updated)
- docs/execution/progress.json (updated)
- docs/execution/reports/TASK-000.md (created)

## Tests
Added: None (validation task)
Updated: None
Executed: None required
Regression suites: N/A

## Commands run
- ./validate_migration.sh
  - Result: All checks passed

## Acceptance criteria verification
- [x] All validation checks pass
- [x] Report generated successfully
- [x] State file updated
- [x] Progress JSON updated

## Notes and risks
Migration complete. Factory is operational.

## Suggested next tasks
- First real implementation task
```

---

## Step 5: Post-Activation Checklist

Complete the [Migration Readiness Checklist](templates/migration_readiness_checklist.md):

### Quick Verification

| Check | Status |
|-------|--------|
| Core files present | |
| State files initialized | |
| Factory markers created | |
| Validation passed | |
| First GO/NEXT cycle completed | |
| Report persisted | |

---

## Step 6: Commit Migration

Now commit all migration changes:

```bash
# Stage all factory files
git add .

# Review what's staged
git status

# Commit
git commit -m "Complete Product Factory migration

- Add factory directory structure
- Create migration documentation
- Initialize execution state
- Establish quality baseline
- Create factory markers
- Complete validation task TASK-000

Migration scope: [Minimal/Standard/Full]
Migration guide: docs/migration/migration_guide.md"

# Push to remote
git push origin main  # or your branch
```

---

## Exit Criteria Checklist

Migration is complete when:

- [ ] **docs/execution/reports/ exists** with .gitkeep
- [ ] **docs/execution/state.md initialized** with current date
- [ ] **docs/execution/progress.json initialized** with features
- [ ] **.factory/KICKOFF_COMPLETE exists**
- [ ] **.factory/PLANNING_FROZEN exists**
- [ ] **.factory/RUN_MODE exists**
- [ ] **.factory/factory_version.txt** contains version
- [ ] **Validation script passes** all checks
- [ ] **First GO/NEXT cycle completed** successfully
- [ ] **First report persisted** to docs/execution/reports/
- [ ] **All changes committed** to git

---

## Post-Activation

### Immediate Next Steps

1. **Create first real task** - Use specs/_templates/task.md
2. **Brief the team** - Share migration guide location
3. **Update project README** - Link to factory docs

### Ongoing Operations

- Follow [Task Runner](../execution/task_runner.md) for all tasks
- Use [Change Request Flow](../requests/change_request_flow.md) for scope changes
- Maintain [Quality Baseline](../quality/quality_baseline.md) as coverage improves

### Periodic Review

- Monthly: Review quality metrics vs targets
- Quarterly: Update architecture documentation
- Annually: Consider framework version upgrade

---

## Common Issues

### "Validation task blocked by dependencies"

TASK-000 should have no dependencies. If blocked:
1. Check dependency field is empty
2. Verify no circular references
3. Create a simpler validation task

### "Report not saving"

1. Verify docs/execution/reports/ exists
2. Check file permissions
3. Ensure CLAUDE.md references correct paths

### "State not updating"

1. Check state.md format matches template
2. Verify AI has write permissions
3. Manually update to verify format works

### "AI doesn't follow GO/NEXT"

1. Restart Claude Code session
2. Verify CLAUDE.md is in project root
3. Check docs/ai.md is properly formatted
4. Ensure .factory/PLANNING_FROZEN exists

---

## Congratulations!

Your project is now running on the Product Factory Framework.

### Key Resources

- [Task Runner](../execution/task_runner.md) - Daily execution protocol
- [Quality Gate](../quality/quality_gate.md) - Quality enforcement
- [Change Request](../requests/change_request_flow.md) - Scope changes
- [New Feature](../requests/new_feature_flow.md) - Adding features

### Getting Help

- Review [Migration Guide](migration_guide.md) troubleshooting
- Check framework [README](../../README.md)
- Consult Product Owner for project-specific issues
