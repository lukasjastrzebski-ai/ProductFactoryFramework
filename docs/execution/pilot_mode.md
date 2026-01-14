# Pilot Mode

**Version:** 20.0

This document describes the supervised pilot mode for initial v20 testing.

---

## Overview

Pilot mode enables running v20 with enhanced DD oversight for testing and validation before full autonomous operation.

---

## Pilot Mode Features

### Enhanced Visibility

- All PO decisions shown to DD
- Verbose logging enabled
- Step-by-step confirmation available

### DD Checkpoints

- Optional confirmation before GO
- Optional confirmation before NEXT
- Batch completion review

### Easy Rollback

- Quick switch to v10.x mode
- State preservation
- No data loss

---

## Enabling Pilot Mode

### Activation

```bash
# Create pilot mode marker
echo "pilot" > .factory/V20_PILOT

# Or via config
{
  "execution_mode": "pilot",
  "require_go_confirmation": false,
  "require_next_confirmation": false,
  "verbose_logging": true
}
```

### Deactivation

```bash
# Switch to full autonomous
rm .factory/V20_PILOT

# Or update config
{
  "execution_mode": "autonomous"
}
```

---

## Pilot Mode Behavior

### Default Pilot Settings

| Setting | Default | Description |
|---------|---------|-------------|
| verbose_logging | true | Detailed logs |
| require_go_confirmation | false | DD confirms GO |
| require_next_confirmation | false | DD confirms NEXT |
| show_all_decisions | true | Display reasoning |
| batch_review | false | Review each batch |

### Checkpoint Options

**GO Checkpoint:**
```
[PILOT] About to issue GO for TASK-001

Plan validated:
  - AC coverage: complete
  - File scope: verified
  - Test delta: addressed

Proceed with GO? [Y/n/details]:
```

**NEXT Checkpoint:**
```
[PILOT] About to issue NEXT for TASK-001

Report validated:
  - AC verified: 5/5
  - Tests passed: 12/12
  - Files: 3 changed

Proceed with NEXT? [Y/n/details]:
```

---

## Verbose Logging

### Log Levels

| Level | Content |
|-------|---------|
| INFO | Major events |
| DEBUG | Decisions and reasoning |
| TRACE | All operations |

### Log Output

```
[2026-01-14 10:00:00] [INFO] PO starting in PILOT mode
[2026-01-14 10:00:01] [DEBUG] Loading orchestrator state...
[2026-01-14 10:00:02] [DEBUG] Found 5 pending tasks
[2026-01-14 10:00:03] [INFO] Analyzing dependencies...
[2026-01-14 10:00:04] [DEBUG] Dependency graph built: 2 parallel groups
[2026-01-14 10:00:05] [INFO] Starting BATCH-001 with 2 tasks
[2026-01-14 10:00:06] [DEBUG] Spawning agent for TASK-001
[2026-01-14 10:00:07] [TRACE] Worktree created: ../worktrees/agent-xxx
...
```

---

## Transitioning from Pilot

### Criteria for Full Autonomous

Before disabling pilot mode:

- [ ] 10+ tasks completed successfully
- [ ] Escalation flow tested
- [ ] Recovery tested
- [ ] No unexpected behaviors
- [ ] DD comfortable with system

### Transition Steps

1. Review pilot mode results
2. Address any issues found
3. Disable pilot markers
4. Enable full autonomous mode
5. Monitor first autonomous phase

---

## Fallback to v10.x

If issues during pilot:

```bash
# Quick fallback
rm .factory/V20_MODE
rm .factory/V20_PILOT

# PO will detect and switch to v10.x compatibility
```

---

## Pilot Mode Reports

### Daily Pilot Report

```markdown
# Pilot Mode Daily Report

**Date:** 2026-01-14
**Mode:** Pilot

## Session Summary

- Tasks attempted: 5
- Tasks completed: 4
- Tasks blocked: 1
- Interventions: 2

## DD Interventions

1. GO checkpoint for TASK-003
   - Reason: Wanted to review plan
   - Outcome: Approved

2. NEXT checkpoint for TASK-004
   - Reason: Verify test coverage
   - Outcome: Approved

## Issues Detected

- None critical

## Recommendations

- System behaving as expected
- Consider disabling GO checkpoints
```

---

## Related Documentation

- [v20 Vision](../v20_vision.md)
- [DD Commands](dd_commands.md)
- [Orchestrator State](orchestrator_state.md)
