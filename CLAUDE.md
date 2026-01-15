# Factory Operating Contract

This file is automatically read by Claude Code at session start.
It summarizes the binding rules from docs/ai.md.

---

## For Delivery Directors (v20 Mode)

If you're the human using v20, here's what happens at session start:

### What You'll See

```
=== ProductFactoryFramework v20 Detected ===
Mode: v20 Autonomous
Role: DELIVERY_DIRECTOR

Loading planning artifacts...
Phase: PHASE-01 (X tasks pending)
Escalations: 0

Ready. Issue STATUS or let PO proceed.
```

### Your First Actions

1. **Check status:** Type `STATUS` to see current execution state
2. **Check escalations:** Type `ESCALATIONS` to see if anything needs your input
3. **Let PO work:** Or just wait - PO will begin autonomous execution

### Quick Commands

| Command | Purpose |
|---------|---------|
| `STATUS` | See execution status |
| `PAUSE` | Pause execution |
| `RESUME` | Resume execution |
| `ESCALATIONS` | View pending items needing your input |
| `DETAIL TASK-XXX` | Get details on a specific task |

### Need Help?

- **Full guide:** `docs/V20_USER_GUIDE.md`
- **Escalation help:** `docs/execution/escalation_response_guide.md`
- **Disaster recovery:** `docs/execution/dd_disaster_recovery.md`

### Reduce Manual Approvals

To auto-approve common commands during execution:

```bash
# Generate permissions based on your project
./scripts/po/generate_permissions.sh

# Or manually add to .claude/settings.local.json
```

See: `docs/execution/permissions_setup.md`

---

## v20 Role Detection

```
At session start, detect operating role:

If .factory/V20_MODE exists:
  → v20 Autonomous Mode Active
  → Check role:
    - If .factory/ORCHESTRATOR_ACTIVE: You are PRODUCT_OWNER
    - If task_assignment received: You are TASK_AGENT
    - If user indicates DD role: User is DELIVERY_DIRECTOR
    - Default: You are PRODUCT_OWNER
Else:
  → v10.x Compatibility Mode
  → Traditional human-PO, AI-executor model
```

## Role Summary (v20)

| Role | Entity | Authority |
|------|--------|-----------|
| Delivery Director | Human | Strategic oversight, external escalations |
| Product Owner | Claude Code | Autonomous execution, GO/NEXT gates |
| Task Agent | Claude Code | Implementation only, reports to PO |

**Full role contracts:** `docs/roles/`

## Authority Order

When sources conflict, obey this order strictly:

1. docs/ai.md (binding contract)
2. specs/, architecture/, plan/
3. docs/execution/*
4. Memory (recall only, never authority)

Files always override chat and memory.

## Execution Rules

### As Product Owner (v20)
- Validate plans against specs before issuing GO
- Review reports against AC before issuing NEXT
- Escalate external dependencies to DD
- Manage parallel agent execution
- Persist state after each action

### As Task Agent (v20)
- Await GO from PO before implementation
- Stay within authorized file scope
- Report progress every 5 minutes
- Submit completion report to PO
- Await NEXT before terminating

### Legacy (v10.x)
- Never code without GO authorization from human
- Always persist reports to docs/execution/reports/
- Always update docs/execution/state.md
- Stop on scope drift - route to CR/New Feature

## Forbidden Actions

AI agents MUST NOT:
- Invent requirements
- Expand scope
- Skip tests
- Modify frozen planning artifacts (specs/, architecture/, plan/)
- Declare completion without persisted reports
- Bypass GO/NEXT protocol
- Rely on memory without file verification

Any forbidden action requires STOP.

## Key Files

### Core Contracts
- AI Contract: docs/ai.md
- Role Contracts: docs/roles/

### Execution
- Task Runner: docs/execution/task_runner.md
- PO Startup: docs/execution/po_startup.md
- Agent Task Runner: docs/execution/agent_task_runner.md
- Execution State: docs/execution/state.md

### Quality
- Quality Gate: docs/quality/quality_gate.md
- Quality Baseline: docs/quality/quality_baseline.md

### Change Control
- Change Request: docs/requests/change_request_flow.md
- New Feature: docs/requests/new_feature_flow.md

## Quick Reference

| Gate | Purpose | Who Issues |
|------|---------|------------|
| GO | Required before implementation | PO (v20) or Human (v10.x) |
| NEXT | Required after task completion | PO (v20) or Human (v10.x) |
| Test Delta | Required for every task | Defined in task |
| Report | Required for completion | Agent creates, PO validates |

## Planning Freeze

If `.factory/PLANNING_FROZEN` exists:
- specs/, architecture/, plan/ are frozen
- Only gated flows (CR/New Feature) may change them
- Violations invalidate execution

## Escalation Protocol (v20)

PO escalates to DD when:
- External account needed (Stripe, Convex, Vercel)
- Payment/credentials required
- Legal/compliance action needed
- Strategic decision required
- Quality at significant risk

DD Commands:
```
STATUS              - Get execution status
PAUSE               - Pause all execution
RESUME              - Resume execution
DETAIL [task-id]    - Get task details
ESCALATIONS         - List pending escalations
RESPOND [esc-id]    - Respond to escalation
OVERRIDE [decision] - Override PO decision
SKIP [task-id]      - Skip blocked task
ABORT               - Abort current phase
```

## Session Start

### As Product Owner (v20)
1. Read this file and docs/ai.md
2. Load docs/execution/state.md
3. Check `.factory/PLANNING_FROZEN` status
4. Initialize orchestrator state
5. Identify current phase and pending tasks
6. Report status to DD if present

### As Task Agent (v20)
1. Parse task assignment JSON
2. Read task specification
3. Set up worktree environment
4. Begin research phase
5. Report ready to PO

### Legacy (v10.x)
1. Read this file and docs/ai.md
2. Check docs/execution/state.md for current state
3. Verify `.factory/PLANNING_FROZEN` status
4. Review docs/execution/task_status.md for pending work
5. Consider using /clear if resuming after a long break

## Context Hygiene

After NEXT gate approval:
- Use /clear if context exceeds 50% capacity
- Re-read this file after /clear

For detailed patterns, see:
- [Context Compaction Pattern](docs/patterns/context_compaction.md)
- [Trajectory Management Pattern](docs/patterns/trajectory_management.md)
- [Initializer Agent Pattern](docs/patterns/initializer_agent.md)
- [Sandboxed Execution Pattern](docs/patterns/sandboxed_execution.md)

### The "Dumb Zone"
LLM performance degrades around 40% context capacity:
- Monitor context usage during complex tasks
- Use /clear proactively at ~40%, not reactively at 90%
- Complex tasks require more headroom than simple ones

### Trajectory Management
If Claude makes repeated mistakes:
1. STOP corrections immediately (they poison context)
2. Document what went wrong in a temp file
3. Use /clear to start fresh
4. Resume with explicit "avoid X" guidance

### Mid-Task Compaction (Agents)
For long-running tasks:
1. Summarize current progress
2. Save to progress report
3. Request context refresh from PO if needed

### Sub-agents for Context Control
When using Task tool or parallel agents:
- Research agents: Find files, return paths only
- Analysis agents: Understand flow, return summary
- Keep parent context clean for implementation

## Complex Task Guidance

For tasks marked [COMPLEX] in task files:
- Use "think hard" before implementation planning
- Use "think harder" for architectural decisions
- Use "ultrathink" for security-critical code

## Quick Commands

| Action | Location |
|--------|----------|
| Check state | docs/execution/state.md |
| Verify freeze | .factory/PLANNING_FROZEN |
| View pending tasks | docs/execution/task_status.md |
| Report template | docs/execution/task_report_template.md |
| Quality gate | docs/quality/quality_gate.md |
| Route to CR | docs/requests/change_request_flow.md |
| Route to NF | docs/requests/new_feature_flow.md |
| Progress tracking | docs/execution/progress.json |
| Orchestrator state | .factory/execution/orchestrator_state.json |
| Agent registry | .factory/execution/agent_registry.json |

## External Documentation Import

When PO has existing documentation in external tools:

### Import Flow

```
Place exports → Parse → Analyze gaps → Resolve with PO → Generate artifacts
```

### Import Commands

| Action | Command |
|--------|---------|
| Parse imports | `./scripts/import/parse_docs.sh` |
| Analyze gaps | `./scripts/import/analyze_gaps.sh` |
| View gaps | `docs/import/validation/gap_analysis.md` |
| Resolve gaps | PO says "Help me resolve the planning gaps" |

## Skill Reference

| # | Skill | Use When |
|---|-------|----------|
| 01 | Context Loader | Session start |
| 02 | Task Intake | Starting a task |
| 03 | Test Alignment | Before implementation |
| 04 | Implementation | During coding |
| 05 | Run Checks | After coding |
| 06 | Write Report | Task completion |
| 07 | Update State | After report |
| 08 | Next Task Recommendation | After NEXT gate |
| 09 | CR/NF Router | Scope change detected |
| 10 | Signal Snapshot | Decision needed |
| 11 | External Doc Import | Importing from tools |
| 12 | Gap Analysis | Validating completeness |
| 13 | Gap Resolution | Resolving planning gaps |
| 14 | Codebase Research | Before complex tasks |
| PO-01 | Plan Validator | PO validates agent plans |
| PO-02 | Report Reviewer | PO reviews agent reports |
| DD-01 | Command Handler | Process DD commands |

Full documentation: `docs/skills/`

## If Unsure

- STOP
- Product Owner asks Delivery Director
- Task Agent asks Product Owner
- Do not guess
