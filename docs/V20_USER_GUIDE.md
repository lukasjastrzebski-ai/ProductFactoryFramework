# ProductFactoryFramework v20 User Guide

**Version:** 20.0

Welcome to v20 of the ProductFactoryFramework! This guide explains how to use the new autonomous execution system.

---

## What's New in v20

### Role Changes

| v10.x | v20 |
|-------|-----|
| Human is Product Owner | Human is Delivery Director |
| Human controls GO/NEXT | AI controls GO/NEXT |
| Single agent | Parallel agents |
| Manual task selection | Automatic parallelization |

### Your New Role: Delivery Director

As Delivery Director, you:
- Provide strategic oversight
- Handle external escalations (accounts, credentials)
- Approve phases
- Can override any decision

You no longer need to:
- Approve every task
- Review every implementation plan
- Issue GO/NEXT for each task

---

## Why Migrate to v20?

### The Problem with v10.x

In v10.x, you were the bottleneck:
- Every task waited for your GO approval
- Every completion waited for your NEXT approval
- Parallelization required manual coordination
- Your availability determined execution speed

### What v20 Solves

| Before (v10.x) | After (v20) |
|----------------|-------------|
| 2-3 hours/day approving tasks | 30 min/day reviewing phases |
| Sequential execution | Automatic parallelization |
| Inline credential handling | Structured escalation queue |
| Context switching per task | Strategic oversight only |

### Real Impact

**Time Savings:**
- Phase with 10 tasks: v10.x = ~5 hours your time → v20 = ~30 minutes
- External dependencies: handled asynchronously via escalation queue

**Quality Improvement:**
- Consistent validation (PO checks every plan)
- No rushed approvals (AI doesn't get tired)
- Complete audit trail

**Faster Delivery:**
- 30-40% speedup from automatic parallelization
- No waiting for human availability
- Continuous execution while you focus elsewhere

### You Still Have Full Control

- Override any PO decision with `OVERRIDE`
- Pause execution anytime with `PAUSE`
- Skip problematic tasks with `SKIP`
- Abort entire phase with `ABORT`
- Revert to v10.x mode instantly

---

## Getting Started

### 1. Activate v20 Mode

```bash
# Create v20 mode marker
echo "20.0" > .factory/V20_MODE

# Update factory version
echo "20.0" > .factory/factory_version.txt
```

### 2. Pre-Execution Checklist

Before starting your first v20 session, verify:

**Planning Complete:**
- [ ] `.factory/PLANNING_FROZEN` exists
- [ ] `plan/phases/PHASE-01.md` or similar exists
- [ ] `plan/tasks/` directory has task files

**Factory Configured:**
- [ ] `.factory/V20_MODE` contains "20.0"
- [ ] `.factory/factory_version.txt` contains "20.0"

**Optional but Recommended:**
- [ ] Enable pilot mode: `echo "pilot" > .factory/V20_PILOT`
- [ ] Review `docs/execution/state.md` for current state

**Verification Commands:**
```bash
# Check all prerequisites
cat .factory/PLANNING_FROZEN      # Should exist
cat .factory/V20_MODE             # Should show "20.0"
ls plan/tasks/                    # Should list TASK-*.md files
```

### 3. Start a Session

Start Claude Code as usual. The system will detect v20 mode and operate as Product Owner.

**What You'll See:**
```
=== ProductFactoryFramework v20 Detected ===
Mode: v20 Autonomous
Role: DELIVERY_DIRECTOR

Loading planning artifacts...
Phase: PHASE-01 (X tasks pending)
Escalations: 0

Ready. Issue STATUS or let PO proceed.
```

### 4. Monitor Execution

Use commands to monitor progress:

```
STATUS              - Current execution status
DETAIL TASK-XXX    - Specific task details
ESCALATIONS        - Pending escalations needing your input
```

---

## Common Workflows

### Starting a Phase

1. PO loads planning artifacts
2. PO builds dependency graph
3. PO starts parallel execution
4. You monitor via STATUS

### Handling Escalations

When you see an escalation:

```
[1] ESC-001 (BLOCKING)
    Type: External Dependency
    Need: Stripe API key
```

Respond with:
```
RESPOND ESC-001
```

Then follow the prompts to provide credentials.

### Pausing Execution

If you need to pause:
```
PAUSE
```

Resume later:
```
RESUME
```

### Skipping a Blocked Task

If a task can't proceed:
```
SKIP TASK-XXX
```

---

## Command Reference

| Command | Usage | Description |
|---------|-------|-------------|
| STATUS | `STATUS` | Current status |
| DETAIL | `DETAIL TASK-001` | Task details |
| ESCALATIONS | `ESCALATIONS` | List escalations |
| RESPOND | `RESPOND ESC-001` | Respond to escalation |
| PAUSE | `PAUSE` | Pause execution |
| RESUME | `RESUME` | Resume execution |
| SKIP | `SKIP TASK-001` | Skip blocked task |
| OVERRIDE | `OVERRIDE` | Override PO decision |
| ABORT | `ABORT` | Abort phase |

### Command Syntax Rules

**Case Sensitivity:**
- All commands must be UPPERCASE: `STATUS` works, `status` does not
- Task IDs use format `TASK-XXX`: `DETAIL TASK-001` not `DETAIL task-001`
- Escalation IDs use format `ESC-XXX`: `RESPOND ESC-001` not `RESPOND 1`

**Formatting:**
- No punctuation needed: `PAUSE` not `PAUSE.` or `PAUSE!`
- Whitespace is flexible: `STATUS`, ` STATUS `, `  STATUS  ` all work
- One command per message

**Common Errors:**
```
status          → ERROR: Command not recognized (use uppercase)
DETAIL 001      → ERROR: Invalid task format (use TASK-001)
RESPOND 1       → ERROR: Invalid escalation format (use ESC-001)
```

---

## Understanding Reports

### Status Report

```
=== Execution Status ===

Mode: v20 Autonomous
Phase: PHASE-01
State: RUNNING

Progress: 60% (9/15 tasks complete)

Agents:
  Active: 3 (implementing)
  Completed: 6
  Blocked: 1
```

### Phase Completion Report

Found in `docs/execution/dd_reports/PHASE-XX-report.md`

Contains:
- Tasks completed
- Issues encountered
- Metrics
- Recommendations

---

## Escalation Types

### External Dependencies

Things the PO can't handle:
- Third-party accounts (Stripe, Convex)
- API credentials
- Payment setup

**Your action:** Provide required credentials or access

### Strategic Decisions

Choices requiring business context:
- Architecture pivots
- Feature prioritization
- Scope changes

**Your action:** Make the decision and communicate it

---

## Pilot Mode

For first-time use, consider pilot mode:

```bash
echo "pilot" > .factory/V20_PILOT
```

This enables:
- Verbose logging
- Optional GO/NEXT confirmation
- Enhanced visibility

Disable when comfortable:
```bash
rm .factory/V20_PILOT
```

---

## Best Practices

### Do

- Check STATUS regularly
- Respond to escalations promptly
- Review phase completion reports
- Use PAUSE if you need to step away

### Don't

- Micromanage task-level decisions
- Ignore BLOCKING escalations
- Modify files directly during execution
- Run multiple PO sessions

---

## Troubleshooting

### Execution Seems Stuck

1. Check `STATUS` - is it paused?
2. Check `ESCALATIONS` - any blocking?
3. Check agent count - any at max?

### Agent Not Progressing

1. Use `DETAIL TASK-XXX` to check
2. May be stuck - PO will timeout
3. Use `SKIP` if truly blocked

### Wrong Decision Made

1. Use `OVERRIDE` to change
2. Can unblock, skip, or reassign

---

## File Locations

| What | Where |
|------|-------|
| Orchestrator state | `.factory/execution/orchestrator_state.json` |
| Agent registry | `.factory/execution/agent_registry.json` |
| Escalations | `.factory/execution/escalation_queue.json` |
| DD Reports | `docs/execution/dd_reports/` |
| Execution history | `.factory/execution/history/` |

---

## Getting Help

- **Documentation:** `docs/roles/delivery_director.md`
- **Vision:** `docs/v20_vision.md`
- **Implementation:** `docs/v20_implementation_plan.md`

If unsure, just ask the PO - it will guide you!

---

## Reverting to v10.x

If you need to revert:

```bash
rm .factory/V20_MODE
```

The system will operate in v10.x compatibility mode with human GO/NEXT approval.
