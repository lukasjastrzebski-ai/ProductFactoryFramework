# Factory Operating Contract

This file is automatically read by Claude Code at session start.
It summarizes the binding rules from docs/ai.md.

## Authority Order

When sources conflict, obey this order strictly:

1. docs/ai.md (binding contract)
2. specs/, architecture/, plan/
3. docs/execution/*
4. Memory (recall only, never authority)

Files always override chat and memory.

## Execution Rules

- Never code without GO authorization
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

- Task Runner: docs/execution/task_runner.md
- Execution State: docs/execution/state.md
- AI Contract: docs/ai.md
- Quality Gate: docs/quality/quality_gate.md
- Migration Guide: docs/migration/migration_guide.md (for existing projects)

## Quick Reference

| Gate | Purpose |
|------|---------|
| GO | Required before any implementation |
| NEXT | Required after task completion |
| Test Delta | Required for every task |
| Report | Required for completion |

## Planning Freeze

If `.factory/PLANNING_FROZEN` exists:
- specs/, architecture/, plan/ are frozen
- Only gated flows (CR/New Feature) may change them
- Violations invalidate execution

## Change Handling

If scope changes are required:
1. STOP execution
2. Route to appropriate flow:
   - docs/requests/change_request_flow.md
   - docs/requests/new_feature_flow.md
3. Wait for gate APPROVAL before continuing

## Session Start

1. Read this file and docs/ai.md
2. Check docs/execution/state.md for current state
3. Verify `.factory/PLANNING_FROZEN` status
4. Review docs/execution/task_status.md for pending work
5. Consider using /clear if resuming after a long break

## Context Hygiene

After NEXT gate approval:
- Use /clear if context exceeds 50% capacity
- Re-read this file after /clear

## Context Engineering

For detailed patterns, see:
- [Context Compaction Pattern](docs/patterns/context_compaction.md)
- [Trajectory Management Pattern](docs/patterns/trajectory_management.md)
- [Initializer Agent Pattern](docs/patterns/initializer_agent.md) (advanced)
- [Sandboxed Execution Pattern](docs/patterns/sandboxed_execution.md) (advanced)

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

Repeated corrections teach the model to fail. Fresh context beats poisoned context.

### Mid-Task Compaction
For long-running tasks:
1. Ask Claude to summarize current progress
2. Save summary to `.factory/session_context.md`
3. Use /clear
4. Re-read CLAUDE.md, state.md, and the summary
5. Continue from summary

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

### Gap Resolution Protocol

When resolving gaps:
1. Present gaps by severity (BLOCKING first)
2. Ask specific, answerable questions
3. Validate responses are actionable
4. Generate factory artifacts from responses
5. Track progress in resolution_progress.json

### PO Commands During Resolution

| Command | Action |
|---------|--------|
| `FILL: [id] [content]` | Provide gap content |
| `SKIP: [id] [reason]` | Skip with justification |
| `STATUS` | Show progress |
| `PROCEED` | Try to continue |

### Rules

- BLOCKING gaps must be resolved before execution
- All acceptance criteria must be testable
- Generate artifacts only after PO confirmation
- Update resolution_progress.json after each gap

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

Full documentation: `docs/skills/`

## If Unsure

- STOP
- Ask the Product Owner
- Do not guess
