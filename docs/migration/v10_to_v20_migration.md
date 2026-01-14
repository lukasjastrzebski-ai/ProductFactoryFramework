# v10.x to v20 Migration Guide

**Version:** 20.0

This guide explains how to upgrade a ProductFactoryFramework project from v10.x to v20.

---

## Overview

v20 introduces autonomous execution where Claude Code acts as Product Owner. This migration guide helps you transition from the human-PO model to the AI-PO model.

---

## Before You Begin

### Prerequisites

- [ ] Planning complete (Stage 7 done)
- [ ] Planning frozen (PLANNING_FROZEN exists)
- [ ] No active execution in progress
- [ ] Familiar with v20 concepts (read V20_USER_GUIDE.md)

### Compatibility

v20 is backward compatible. You can:
- Run v20 projects in v10.x mode
- Disable v20 at any time
- Return to human-PO control

---

## Migration Steps

### Step 1: Check Readiness

```bash
./scripts/migration/v10_to_v20.sh --check
```

This verifies:
- Planning is complete
- Required files exist
- No active execution

### Step 2: Create Backup

```bash
./scripts/migration/v10_to_v20.sh --backup
```

Creates backup of .factory/ directory.

### Step 3: Run Migration

```bash
# Standard migration
./scripts/migration/v10_to_v20.sh --backup

# With pilot mode (recommended for first time)
./scripts/migration/v10_to_v20.sh --backup --pilot
```

### Step 4: Verify Migration

```bash
# Check markers
cat .factory/V20_MODE           # Should show "20.0"
cat .factory/factory_version.txt # Should show "20.0"

# Check structure
ls -la .factory/execution/
ls -la .factory/agent_progress/
```

---

## What Changes

### Files Created

```
.factory/
├── V20_MODE                    # v20 activation marker
├── V20_PILOT                   # (if pilot mode)
├── execution/
│   ├── orchestrator_state.json # PO state
│   ├── agent_registry.json     # Agent tracking
│   ├── escalation_queue.json   # Escalations
│   ├── parallel_batches/       # Batch tracking
│   ├── history/                # Audit trail
│   └── go_gates/               # Gate records
├── agent_progress/             # Agent progress files
├── schemas/                    # JSON schemas
└── validation/                 # Validation results

docs/execution/
└── dd_reports/                 # DD reports
```

### Files Modified

- `.factory/factory_version.txt` - Updated to 20.0

### Files Preserved

- All planning artifacts (specs/, architecture/, plan/)
- Existing execution state (docs/execution/state.md)
- All documentation

---

## Behavior Changes

### GO/NEXT Gates

| v10.x | v20 |
|-------|-----|
| You issue GO | PO issues GO |
| You issue NEXT | PO issues NEXT |
| Manual approval | Automatic validation |

### Task Execution

| v10.x | v20 |
|-------|-----|
| Single agent | Parallel agents |
| Sequential by default | Parallel by default |
| Manual task selection | Automatic scheduling |

### Your Role

| v10.x | v20 |
|-------|-----|
| Product Owner | Delivery Director |
| Approve every task | Approve phases |
| Issue commands | Respond to escalations |

---

## Post-Migration

### First Session

1. Start Claude Code session
2. System detects v20 mode
3. PO initializes and reports status
4. Monitor via STATUS command

### Pilot Mode

If you enabled pilot mode:
- Enhanced visibility
- Optional checkpoints
- Verbose logging

Disable when comfortable:
```bash
rm .factory/V20_PILOT
```

---

## Rollback

If you need to return to v10.x:

```bash
./scripts/migration/v10_to_v20.sh --rollback
```

Or manually:
```bash
rm .factory/V20_MODE
echo "10.2" > .factory/factory_version.txt
```

---

## Troubleshooting

### Migration Fails

**Error:** "Planning not complete"
**Solution:** Complete Stage 7 before migrating

**Error:** "Planning not frozen"
**Solution:** Run Stage 7 to create PLANNING_FROZEN

**Error:** "Orchestrator active"
**Solution:** Clear ORCHESTRATOR_ACTIVE or wait for session to end

### Post-Migration Issues

**PO not starting in v20 mode:**
- Check V20_MODE marker exists
- Verify factory_version.txt is "20.0"
- Start fresh session

**Commands not recognized:**
- Use uppercase (STATUS not status)
- Check you're in execution mode

---

## Related Documentation

- [V20 User Guide](../V20_USER_GUIDE.md) - How to use v20
- [v20 Vision](../v20_vision.md) - Architecture overview
- [Delivery Director Contract](../roles/delivery_director.md) - Your new role
