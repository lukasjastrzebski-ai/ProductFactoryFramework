# Disaster Recovery Guide for Delivery Directors

**Version:** 20.0

This guide explains how to recover from common failure scenarios in v20 autonomous mode.

---

## Quick Recovery Reference

| Scenario | Command | Risk Level |
|----------|---------|------------|
| Execution stuck | `PAUSE` then `RESUME` | Low |
| Task repeatedly failing | `SKIP TASK-XXX` | Low |
| Wrong decision made | `OVERRIDE` | Low |
| PO session crashed | Start new session | Low |
| State corrupted | Restore from backup | Medium |
| Need full reset | `ABORT` + manual cleanup | High |

---

## Scenario 1: Execution Seems Stuck

### Symptoms
- No progress for 30+ minutes
- `STATUS` shows same state repeatedly
- No new agent activity

### Diagnosis
```
STATUS
```

Check for:
- `State: PAUSED` - You paused and forgot
- `Agents: Active: 0, Blocked: X` - All tasks blocked
- `Escalations: X (BLOCKING)` - Waiting for your response

### Recovery

**If paused:**
```
RESUME
```

**If blocked on escalations:**
```
ESCALATIONS
RESPOND ESC-XXX
```

**If truly stuck (no obvious cause):**
```
PAUSE
# Wait 10 seconds
RESUME
```

This forces PO to re-evaluate the execution graph.

---

## Scenario 2: Task Keeps Failing

### Symptoms
- Same task appears in STATUS repeatedly
- Agent retries exhausted
- Task marked as BLOCKED

### Diagnosis
```
DETAIL TASK-XXX
```

Check for:
- Retry count (max is usually 3)
- Failure reason in log
- Dependencies that might be causing issues

### Recovery

**Option A: Skip the task**
```
SKIP TASK-XXX
```
Task is marked as skipped; dependent tasks may also be skipped.

**Option B: Override with guidance**
```
OVERRIDE
> Select: TASK-XXX
> Action: RETRY
> Guidance: Try alternative approach - use library X instead of Y
```

**Option C: Manual intervention**
```
PAUSE
# Fix the underlying issue manually in the codebase
RESUME
```

---

## Scenario 3: PO Session Crashed

### Symptoms
- Claude Code session ended unexpectedly
- No graceful shutdown message
- Partial work may be uncommitted

### Recovery

**Step 1: Start a new session**
```
# Just open Claude Code again
# v20 mode will auto-detect and resume
```

**Step 2: Check state**
```
STATUS
```

PO will report:
- Last known state
- Any interrupted tasks
- Recovery actions taken

**Step 3: Handle interrupted tasks**

Interrupted tasks are automatically:
- Rolled back to last checkpoint
- Re-queued for execution
- Marked with `INTERRUPTED` flag

No manual action needed unless you see errors.

---

## Scenario 4: State File Corrupted

### Symptoms
- Error on session start: "Invalid orchestrator state"
- JSON parse errors in logs
- Inconsistent status reports

### Diagnosis
```bash
# Check state file validity
cat .factory/execution/orchestrator_state.json | python -m json.tool
```

If this errors, state is corrupted.

### Recovery

**Option A: Use automatic backup**
```bash
# PO creates backups before each session
ls .factory/execution/history/
# Find most recent valid state
cp .factory/execution/history/orchestrator_state_YYYYMMDD.json \
   .factory/execution/orchestrator_state.json
```

**Option B: Reset state (loses progress)**
```bash
# Remove corrupted state
rm .factory/execution/orchestrator_state.json

# Start fresh session - PO will reinitialize
# Warning: Progress counters reset to 0
```

**Option C: Manual repair**

Only if you understand the schema:
```bash
# Edit the JSON to fix syntax errors
# See docs/execution/orchestrator_state.md for schema
```

---

## Scenario 5: Wrong Decision Made by PO

### Symptoms
- Task completed but implementation is wrong
- PO approved something you disagree with
- Need to undo a GO or NEXT decision

### Recovery

**Undo a task completion:**
```
OVERRIDE
> Select: TASK-XXX
> Action: REVERT
> Reason: Implementation doesn't match requirements
```

**Change a strategic decision:**
```
OVERRIDE
> Select: DECISION-XXX
> Action: CHANGE
> New decision: [your corrected decision]
```

**Note:** Reverting completed tasks may require re-executing dependent tasks.

---

## Scenario 6: Need to Abort Everything

### When to Use
- Fundamental planning error discovered
- Project requirements changed significantly
- Need to start over

### Recovery

**Step 1: Abort current phase**
```
ABORT
```

You'll be asked to confirm:
```
WARNING: This will:
- Stop all active agents
- Discard in-progress work
- Mark phase as ABORTED

Are you sure? (yes/no): yes
```

**Step 2: Clean up (optional)**
```bash
# Remove v20 execution state
rm -rf .factory/execution/
rm -rf .factory/agent_progress/

# Keep planning artifacts intact
```

**Step 3: Restart**
```bash
# Re-run migration to reinitialize
./scripts/migration/v10_to_v20.sh --backup
```

---

## Scenario 7: Rollback to v10.x

### When to Use
- v20 isn't working for your project
- Need manual control temporarily
- Debugging complex issues

### Recovery

**Quick rollback:**
```bash
rm .factory/V20_MODE
```

**Full rollback:**
```bash
./scripts/migration/v10_to_v20.sh --rollback
```

**What's preserved:**
- All planning artifacts
- Completed task reports
- Execution history

**What's removed:**
- v20 mode marker
- Orchestrator state (can be restored)
- Active agent registry

---

## Scenario 8: Multiple PO Sessions Running

### Symptoms
- Conflicting status reports
- Same task assigned twice
- Merge conflicts appearing

### Recovery

**Step 1: Identify sessions**
```bash
# Check for lock files
ls .factory/ORCHESTRATOR_ACTIVE
cat .factory/ORCHESTRATOR_ACTIVE
```

**Step 2: Kill extra sessions**

Close all Claude Code windows/terminals except one.

**Step 3: Clear lock**
```bash
rm .factory/ORCHESTRATOR_ACTIVE
```

**Step 4: Restart clean**
```
# In remaining session
PAUSE
RESUME
```

---

## Prevention Tips

### Regular Backups
```bash
# Before major phases
cp -r .factory/ .factory_backup_$(date +%Y%m%d)/
```

### Monitor Execution
- Check `STATUS` every 30 minutes
- Respond to escalations promptly
- Review phase reports before proceeding

### Use Pilot Mode First
```bash
echo "pilot" > .factory/V20_PILOT
```

This gives you more visibility and easier recovery.

---

## Getting Help

If recovery fails:

1. Check `docs/execution/dd_reports/` for logs
2. Review `.factory/execution/history/` for state history
3. Examine git history for recent changes
4. Consider rolling back to v10.x for manual recovery

---

## Related Documentation

- [Orchestrator State](orchestrator_state.md)
- [V20 User Guide](../V20_USER_GUIDE.md)
- [Compatibility Mode](compatibility_mode.md)
