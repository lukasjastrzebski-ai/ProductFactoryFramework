# Phase 1: Structure Setup

**Time: 30-60 minutes**

Phase 1 establishes the factory directory structure and configuration files in your existing project.

---

## Overview

This phase sets up the physical file structure required for factory operation. No content is created yet—that happens in Phase 2.

---

## Step 1: Copy Framework Files

Copy essential files from the Product Factory Framework to your project:

### Required Files

```bash
# From Product Factory Framework root, copy these to your project:

# Core contract and configuration
cp CLAUDE.md /path/to/your/project/
cp .claude/settings.json /path/to/your/project/.claude/

# Documentation templates
cp docs/ai.md /path/to/your/project/docs/
cp docs/execution/task_runner.md /path/to/your/project/docs/execution/
cp docs/execution/task_report_template.md /path/to/your/project/docs/execution/
cp docs/execution/state.md /path/to/your/project/docs/execution/
cp docs/execution/progress.json /path/to/your/project/docs/execution/
cp docs/quality/quality_gate.md /path/to/your/project/docs/quality/

# Feature and task templates
cp -r specs/_templates /path/to/your/project/specs/

# Request flows
cp -r docs/requests /path/to/your/project/docs/
```

### Optional Files (Standard/Full Adoption)

```bash
# Additional documentation
cp docs/ideation_playbook.md /path/to/your/project/docs/
cp docs/multi_agent_execution_protocol.md /path/to/your/project/docs/

# Manuals
cp -r docs/manuals /path/to/your/project/docs/

# CI workflows
cp -r .github/workflows /path/to/your/project/.github/
```

---

## Step 2: Create Directory Structure

Create all required directories:

```bash
# Navigate to your project root
cd /path/to/your/project

# Create factory directories
mkdir -p .claude
mkdir -p .factory
mkdir -p docs/execution/reports
mkdir -p docs/execution/signatures
mkdir -p docs/quality
mkdir -p docs/product
mkdir -p docs/requests
mkdir -p docs/manuals
mkdir -p docs/migration/templates
mkdir -p specs/features
mkdir -p specs/tests
mkdir -p specs/_templates
mkdir -p architecture/decisions
mkdir -p plan/phases
mkdir -p plan/tasks

# Create .gitkeep files for empty directories
touch docs/execution/reports/.gitkeep
touch docs/execution/signatures/.gitkeep
touch architecture/decisions/.gitkeep
touch plan/phases/.gitkeep
touch plan/tasks/.gitkeep
```

### Directory Structure Reference

After setup, your project should have:

```
your-project/
├── .claude/
│   └── settings.json          # Claude Code permissions
├── .factory/
│   └── (markers created in Phase 4)
├── CLAUDE.md                  # Session startup summary
├── docs/
│   ├── ai.md                  # AI binding contract
│   ├── execution/
│   │   ├── reports/           # Task completion reports
│   │   │   └── .gitkeep
│   │   ├── signatures/
│   │   │   └── .gitkeep
│   │   ├── state.md           # Current execution state
│   │   ├── progress.json      # Progress tracking
│   │   ├── task_runner.md     # GO/NEXT protocol
│   │   └── task_report_template.md
│   ├── quality/
│   │   ├── quality_gate.md    # Pass/fail criteria
│   │   └── quality_baseline.md # (created in Phase 3)
│   ├── requests/
│   │   ├── change_request_flow.md
│   │   └── new_feature_flow.md
│   └── migration/
│       └── templates/
├── specs/
│   ├── features/
│   │   └── index.md           # Feature index (created in Phase 2)
│   ├── tests/
│   └── _templates/
│       ├── feature_spec.md
│       ├── feature_test_plan.md
│       └── task.md
├── architecture/
│   ├── system.md              # (created in Phase 2)
│   └── decisions/
│       └── .gitkeep
└── plan/
    ├── roadmap.md             # (optional for migration)
    ├── phases/
    │   └── .gitkeep
    └── tasks/
        └── .gitkeep
```

---

## Step 3: Handle File Conflicts

If files already exist in your project, handle conflicts carefully:

### Conflict Resolution Strategies

| File | Strategy |
|------|----------|
| **README.md** | Merge - add factory references to existing |
| **CLAUDE.md** | Replace - factory version required |
| **.claude/settings.json** | Replace - factory version required |
| **docs/*** | Preserve - move existing to docs/legacy/ |
| **.github/workflows/*** | Merge - add factory workflows alongside existing |

### Handling Existing docs/ Directory

```bash
# If you have existing documentation
mkdir -p docs/legacy
mv docs/*.md docs/legacy/  # Preserve existing docs
# Then create factory structure
```

### Preserving Your README

Do NOT replace your existing README.md. Instead:

1. Keep your project's README as-is
2. Add a "Development Process" section referencing factory docs
3. Link to docs/migration/migration_guide.md

Example addition to your README:

```markdown
## Development Process

This project uses the Product Factory Framework for disciplined execution.

- [Migration Guide](docs/migration/migration_guide.md) - How we adopted the framework
- [Task Runner](docs/execution/task_runner.md) - GO/NEXT execution protocol
- [AI Contract](docs/ai.md) - Rules for AI-assisted development
```

---

## Step 4: Configure Permissions

Edit `.claude/settings.json` to allow factory operations:

### Minimal Configuration

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test:*)",
      "Bash(npm run:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Read",
      "Write",
      "Edit"
    ],
    "deny": []
  }
}
```

### Standard Configuration

Add your project's test commands:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test:*)",
      "Bash(npm run:*)",
      "Bash(pytest:*)",
      "Bash(go test:*)",
      "Bash(make:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Read",
      "Write",
      "Edit"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(sudo:*)"
    ]
  }
}
```

### Project-Specific Additions

Add commands specific to your project:

```json
{
  "permissions": {
    "allow": [
      // ... standard permissions ...

      // Example: Django project
      "Bash(python manage.py test:*)",
      "Bash(python manage.py migrate:*)",

      // Example: Docker project
      "Bash(docker-compose:*)",
      "Bash(docker build:*)",

      // Example: Rust project
      "Bash(cargo test:*)",
      "Bash(cargo build:*)"
    ]
  }
}
```

---

## Step 5: Customize CLAUDE.md

Edit CLAUDE.md to reference your project:

### Required Customizations

1. Update Key Files section with your project's important files
2. Verify Quick Commands paths are correct
3. Add any project-specific rules

### Example Customizations

```markdown
## Key Files

- Task Runner: docs/execution/task_runner.md
- Execution State: docs/execution/state.md
- AI Contract: docs/ai.md
- Quality Gate: docs/quality/quality_gate.md
- Migration Guide: docs/migration/migration_guide.md (for existing projects)

## Project-Specific Rules

- Always run `npm test` before requesting NEXT
- Database migrations require explicit approval
- API changes must update OpenAPI spec
```

---

## Verification Steps

Run these commands to verify structure is correct:

```bash
# Verify core files exist
ls -la CLAUDE.md .claude/settings.json docs/ai.md

# Verify directory structure
ls -la docs/execution/ docs/quality/ specs/features/ architecture/

# Verify templates
ls -la specs/_templates/

# Verify reports directory
ls -la docs/execution/reports/

# Check no conflicts remain
git status
```

### Expected Output

All files should exist without merge conflicts. Git status should show new files ready to commit (but don't commit yet—wait until Phase 4).

---

## Exit Criteria Checklist

Before proceeding to Phase 2, verify:

- [ ] **CLAUDE.md exists** in project root
- [ ] **.claude/settings.json configured** with appropriate permissions
- [ ] **docs/ai.md exists** (content filled in Phase 2)
- [ ] **docs/execution/ directory** has required files
- [ ] **docs/execution/reports/ exists** with .gitkeep
- [ ] **docs/quality/ directory** exists
- [ ] **specs/features/ directory** exists
- [ ] **specs/_templates/ directory** has templates
- [ ] **architecture/ directory** exists
- [ ] **plan/ directory** exists with subdirectories
- [ ] **.factory/ directory** exists (markers added in Phase 4)
- [ ] **No file conflicts** remain unresolved

---

## Common Issues

### "CLAUDE.md conflicts with existing file"

If you have an existing CLAUDE.md:
1. Review your existing content
2. Merge any project-specific rules into the factory CLAUDE.md
3. Replace with factory version

### "settings.json has different permissions"

Merge permissions:
1. Keep your existing allowed commands
2. Add factory-required permissions
3. Ensure deny rules don't block factory operations

### "Existing docs/ structure doesn't match"

Options:
1. Move existing docs to docs/legacy/
2. Create factory structure alongside existing
3. Gradually migrate docs to factory locations

### "Git shows too many new files"

This is expected. All factory structure files should be committed as part of migration. Consider a single migration commit after Phase 4.

---

## Next Step

Proceed to [Phase 2: Artifacts](phase_2_artifacts.md)
