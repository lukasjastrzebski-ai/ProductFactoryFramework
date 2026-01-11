# Initializer Agent Pattern

Based on Anthropic's recommendations for long-running agent sessions.

---

## Purpose

An initializer agent runs at the start of each session to:
1. Verify environment state
2. Read progress files
3. Check for incomplete work
4. Set up context for the worker agent

This pattern improves session continuity and reduces context loss between sessions.

---

## Architecture

```
┌─────────────────────┐
│   Session Start     │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│ Initializer Agent   │
│ - Read state.md     │
│ - Run tests         │
│ - Check blockers    │
│ - Set up context    │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│   Worker Agent      │
│ - Execute tasks     │
│ - Follow GO/NEXT    │
│ - Persist reports   │
└─────────────────────┘
```

---

## Implementation

### Session Start Script

Create `.factory/init_session.sh`:

```bash
#!/bin/bash
# Factory Session Initialization Script

echo "=== Factory Session Initialization ==="
echo "Date: $(date)"
echo ""

# 1. Verify git state
echo "--- Git Status ---"
git status --short
echo ""

# 2. Read current execution state
echo "--- Execution State ---"
if [ -f docs/execution/state.md ]; then
    cat docs/execution/state.md
else
    echo "WARNING: state.md not found"
fi
echo ""

# 3. Check for blockers
echo "--- Blockers ---"
if [ -f docs/execution/task_status.md ]; then
    BLOCKED=$(grep "BLOCKED" docs/execution/task_status.md || true)
    if [ -n "$BLOCKED" ]; then
        echo "BLOCKED tasks found:"
        echo "$BLOCKED"
    else
        echo "No blocked tasks"
    fi
else
    echo "task_status.md not found"
fi
echo ""

# 4. Run tests to verify baseline
echo "--- Test Baseline ---"
if [ -f package.json ]; then
    pnpm test 2>/dev/null || npm test 2>/dev/null || echo "Tests failed or not configured"
else
    echo "No package.json found"
fi
echo ""

# 5. Check planning freeze status
echo "--- Planning Freeze ---"
if [ -f .factory/PLANNING_FROZEN ]; then
    echo "Planning is FROZEN"
    echo "Frozen directories: specs/, architecture/, plan/"
else
    echo "Planning is NOT frozen"
fi
echo ""

echo "=== Initialization Complete ==="
```

### Making the Script Executable

```bash
chmod +x .factory/init_session.sh
```

---

## Integration with Claude Code

### CLAUDE.md Addition

Add to CLAUDE.md:

```markdown
## Session Start

Run `.factory/init_session.sh` at the start of each session to:
- Verify git state
- Check execution state
- Identify blockers
- Validate test baseline
```

### Automatic Invocation

Consider adding to your shell profile or IDE startup:

```bash
# In .bashrc or .zshrc for project directory
cd /path/to/project && ./.factory/init_session.sh
```

---

## Two-Agent Pattern

For enhanced reliability, use separate Claude instances:

### Agent 1: Initializer

Responsibilities:
- Run initialization script
- Parse output for issues
- Create session context summary
- Hand off to worker

### Agent 2: Worker

Responsibilities:
- Receive context from initializer
- Execute tasks per GO/NEXT protocol
- Persist reports and state updates

### Communication

Agents communicate via files:
- `.factory/session_context.json` - Session state
- `docs/execution/state.md` - Persistent state
- `docs/execution/reports/` - Task completion

---

## Session Context File

Create `.factory/session_context.json`:

```json
{
  "session_id": "",
  "started_at": "",
  "git_branch": "",
  "git_status": "",
  "current_task": "",
  "blockers": [],
  "test_status": "",
  "notes": ""
}
```

The initializer agent populates this, and the worker agent reads it.

---

## Benefits

1. **Consistent startup:** Every session begins with verified state
2. **Early problem detection:** Blockers and test failures caught immediately
3. **Context preservation:** State survives session boundaries
4. **Audit trail:** Session starts are logged

---

## Best Practices

1. **Always run initialization:** Never skip the init script
2. **Fix issues before work:** Resolve blockers found during init
3. **Update state after work:** Ensure next session has accurate state
4. **Commit frequently:** Git history aids recovery

---

## Troubleshooting

### Init Script Fails

1. Check script permissions: `chmod +x .factory/init_session.sh`
2. Verify required files exist
3. Run individual commands to isolate failure

### State Desync

If state.md doesn't match reality:
1. Run `git log` to see recent changes
2. Check `docs/execution/reports/` for task history
3. Manually reconcile and update state.md

### Test Baseline Broken

If tests fail during init:
1. Do NOT proceed with new work
2. Investigate and fix test failures first
3. Re-run initialization after fix
