# Permissions Setup for v20 Execution

**Version:** 20.0

---

## Overview

To enable smooth autonomous execution, configure Claude Code permissions to auto-approve expected commands. This eliminates manual approval for routine operations while maintaining security for sensitive actions.

---

## Quick Setup

### Option 1: Use Generator Script (Recommended)

After Stage 7 completion, run:

```bash
./scripts/po/generate_permissions.sh
```

This analyzes your project and generates `.claude/settings.local.json` with appropriate permissions.

### Option 2: Manual Configuration

Create `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(mkdir:*)",
      "Bash(cat:*)",
      "Bash(cp:*)",
      "Bash(ls:*)",
      "Bash(echo:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(git status:*)"
    ]
  }
}
```

### Option 3: CLI Commands

```bash
# Add individual permissions
claude config add allowedTools "Bash(mkdir:*)" --scope project
claude config add allowedTools "Bash(cat:*)" --scope project
claude config add allowedTools "Bash(git add:*)" --scope project
```

---

## Permission Categories

### Planning Phase (Stages 0-7)

| Permission | Purpose |
|------------|---------|
| `Bash(mkdir:*)` | Create directories |
| `Bash(cat:*)` | Write files via heredoc |
| `Bash(cp:*)` | Copy files |
| `Bash(ls:*)` | List directories |
| `Bash(echo:*)` | Create marker files |

### Execution Phase (v20)

| Permission | Purpose |
|------------|---------|
| `Bash(git add:*)` | Stage changes |
| `Bash(git commit:*)` | Create commits |
| `Bash(git push:*)` | Push to remote |
| `Bash(git worktree:*)` | Agent isolation |
| `Bash(git branch:*)` | Branch management |

### Project-Specific

#### Swift/iOS
```json
"Bash(xcodebuild:*)",
"Bash(swift:*)",
"Bash(xcrun:*)"
```

#### Node.js
```json
"Bash(npm:*)",
"Bash(npx:*)",
"Bash(node:*)"
```

#### Python
```json
"Bash(python:*)",
"Bash(pip:*)",
"Bash(pytest:*)"
```

---

## Security Considerations

### Auto-Approved (Safe)
- File operations within project
- Git operations to configured remotes
- Build/test commands
- Read-only system queries

### Require Manual Approval
- `rm -rf` (destructive)
- Network commands to external hosts
- Credential/secret access
- System modification commands
- Package publishing

### Never Auto-Approve
- `sudo` commands
- System configuration changes
- Credential storage
- External API calls with secrets

---

## Per-Phase Permissions

The framework supports different permission sets per phase:

```json
{
  "permissions": {
    "allow": ["...base..."],
    "phases": {
      "planning": ["Bash(mkdir:*)", "Bash(cat:*)"],
      "execution": ["Bash(npm test:*)", "Bash(npm run build:*)"]
    }
  }
}
```

---

## Troubleshooting

### Permissions Not Working

1. Restart Claude Code session after changes
2. Verify JSON syntax is valid
3. Check file location: `.claude/settings.local.json`

### Too Many Prompts

1. Run `./scripts/po/generate_permissions.sh`
2. Add specific patterns that are being prompted
3. Use `--scope project` for project-specific settings

### Security Concerns

1. Review allowed commands periodically
2. Use specific patterns over wildcards where possible
3. Never add `rm -rf` to auto-approve list

---

## Integration with Stage 7

The permission generator should be run as part of Stage 7 completion:

```bash
# In Stage 7 checklist
- [ ] Run ./scripts/po/generate_permissions.sh
- [ ] Review generated permissions
- [ ] Commit .claude/settings.local.json
```

This ensures permissions are ready before execution begins.
