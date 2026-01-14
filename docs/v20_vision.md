# ProductFactoryFramework v20 Vision

## Autonomous Product Delivery with AI-Native Execution

**Version:** 20.0
**Status:** Vision Document
**Created:** 2026-01-14

---

## Executive Summary

ProductFactoryFramework v20 represents a paradigm shift from **human-directed AI execution** to **AI-orchestrated autonomous delivery**. In this model, Claude Code operates as the **Product Owner (PO)**, managing the entire execution phase while the human assumes the role of **Delivery Director (DD)** - providing strategic oversight, handling external escalations, and receiving status reports.

### The Core Transformation

| Aspect | v10.x (Current) | v20 (Vision) |
|--------|-----------------|--------------|
| Product Owner | Human | Claude Code |
| Execution Agent | Claude Code (single) | Claude Code Agents (parallel) |
| Human Role | Task-level control | Strategic oversight |
| GO/NEXT Gates | Human-controlled | AI-controlled |
| External Requests | Inline with execution | Escalated to Delivery Director |
| Parallelization | Optional, human-planned | Default, AI-orchestrated |

---

## Vision Statement

> **"From AI as Implementer to AI as Manager"**
>
> v20 transforms the ProductFactoryFramework into a fully autonomous delivery engine where Claude Code orchestrates multiple parallel agents, validates work against specifications, manages the GO/NEXT protocol internally, and only escalates to humans for external dependencies and strategic decisions.

---

## Role Definitions

### Delivery Director (Human)

The Delivery Director is the ultimate authority and external interface for the project.

**Responsibilities:**
- Approve project initiation and overall scope
- Handle external escalations (third-party accounts, payments, legal)
- Make strategic decisions when AI-detected blockers require human judgment
- Receive and review progress reports from Product Owner
- Provide final acceptance of completed phases/milestones
- Override AI decisions when necessary

**NOT Responsible For:**
- Task-level GO/NEXT approvals
- Code review at implementation level
- Individual test verification
- Internal task sequencing decisions

### Product Owner (Claude Code - Orchestrator)

The Product Owner is an autonomous Claude Code agent that manages the entire execution phase.

**Responsibilities:**
- Validate task implementation plans against specifications
- Issue GO gates for Task Agents
- Review task completion reports against acceptance criteria
- Issue NEXT gates or work with agents on fixes
- Manage parallel task execution strategy
- Detect scope drift and route to CR/NF flows
- Escalate external dependencies to Delivery Director
- Generate phase completion reports for Delivery Director
- Maintain execution state and progress tracking

**Authority:**
- Full authority over internal execution decisions
- Cannot approve scope changes (routes to DD via CR/NF)
- Cannot handle external account/payment setup
- Cannot make strategic pivots without DD approval

### Task Agents (Claude Code - Workers)

Task Agents are specialized Claude Code instances that execute individual tasks.

**Responsibilities:**
- Execute assigned tasks per specifications
- Write tests per Test Delta
- Generate task completion reports
- Report blockers to Product Owner
- Request clarification from Product Owner when needed

**Constraints:**
- Work only on assigned task
- Cannot expand scope
- Cannot modify specifications
- Cannot interact directly with Delivery Director
- Must complete reports before requesting NEXT

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DELIVERY DIRECTOR (Human)                        │
│                                                                         │
│  • Strategic Oversight    • External Escalations    • Final Acceptance  │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     │ Reports & Escalations
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       PRODUCT OWNER (Claude Code)                        │
│                                                                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐ │
│  │ Plan Validator  │  │ Execution       │  │ Escalation Manager      │ │
│  │ - Spec check    │  │ Orchestrator    │  │ - External requests     │ │
│  │ - Test coverage │  │ - Task dispatch │  │ - Blocker detection     │ │
│  │ - Dependency    │  │ - Parallelism   │  │ - DD communication      │ │
│  │   validation    │  │ - GO/NEXT gates │  │                         │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────────────┘ │
│                                                                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐ │
│  │ Report Reviewer │  │ Fix Coordinator │  │ State Manager           │ │
│  │ - AC validation │  │ - Failure triage│  │ - progress.json         │ │
│  │ - Quality check │  │ - Retry logic   │  │ - state.md              │ │
│  │ - Regression    │  │ - Agent collab  │  │ - Phase tracking        │ │
│  │   detection     │  │                 │  │                         │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────────────┘ │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                     ┌───────────────┼───────────────┐
                     │               │               │
                     ▼               ▼               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        TASK AGENTS (Parallel)                           │
│                                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │ Task Agent 1 │  │ Task Agent 2 │  │ Task Agent 3 │  │ Task Agent │  │
│  │ TASK-001     │  │ TASK-002     │  │ TASK-003     │  │    ...N    │  │
│  │              │  │              │  │              │  │            │  │
│  │ • Research   │  │ • Research   │  │ • Research   │  │            │  │
│  │ • Implement  │  │ • Implement  │  │ • Implement  │  │            │  │
│  │ • Test       │  │ • Test       │  │ • Test       │  │            │  │
│  │ • Report     │  │ • Report     │  │ • Report     │  │            │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  └────────────┘  │
│                                                                         │
│  [Git Worktrees for Isolation]                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Execution Model

### Phase 1: Delivery Director Kickoff

1. DD reviews project scope and planning artifacts
2. DD approves execution start for a phase
3. DD provides any required external credentials/access
4. DD sets escalation preferences (sync vs async)

### Phase 2: Product Owner Orchestration

```
PO Execution Loop:
┌─────────────────────────────────────────────────────────────────┐
│  1. Load Phase Tasks from plan/phases/                          │
│  2. Analyze Dependencies (build execution graph)                │
│  3. Identify Parallelizable Groups                              │
│  4. For each Group:                                             │
│     ├─ Validate task specs against acceptance criteria          │
│     ├─ Check test coverage requirements                         │
│     ├─ Spawn Task Agents (parallel where safe)                  │
│     ├─ Issue internal GO gates                                  │
│     ├─ Monitor execution                                        │
│     └─ Review reports, issue NEXT or coordinate fixes           │
│  5. Update execution state                                      │
│  6. Generate phase report for DD                                │
│  7. Request DD approval for next phase (or completion)          │
└─────────────────────────────────────────────────────────────────┘
```

### Phase 3: Task Agent Execution

Each Task Agent follows a modified task runner loop:

```
Task Agent Loop (per task):
┌─────────────────────────────────────────────────────────────────┐
│  0. Receive task assignment from PO                             │
│  1. Read task spec, dependencies, Test Delta                    │
│  2. Perform codebase research (Skill 14)                        │
│  3. Create implementation plan                                  │
│  4. Submit plan to PO for validation                           │
│  5. Await PO GO                                                 │
│  6. Implement (in isolated worktree)                           │
│  7. Run tests per Test Delta                                    │
│  8. Generate completion report                                  │
│  9. Submit report to PO                                         │
│  10. Await PO NEXT/FIX                                         │
│      ├─ NEXT: Task complete, agent terminates                   │
│      └─ FIX: Receive feedback, iterate (max 2 attempts)         │
└─────────────────────────────────────────────────────────────────┘
```

### Phase 4: Fix Coordination

When a task fails validation:

```
Fix Coordination Flow:
┌─────────────────────────────────────────────────────────────────┐
│  PO receives failed report                                      │
│  │                                                              │
│  ├─ Attempt 1: Provide specific feedback to same agent          │
│  │   └─ Agent retries with guidance                            │
│  │                                                              │
│  ├─ Attempt 2: Enhanced feedback with anti-patterns             │
│  │   └─ Agent retries with fresh context                       │
│  │                                                              │
│  └─ Attempt 3 (BLOCKED):                                        │
│      ├─ Mark task as BLOCKED                                    │
│      ├─ Document failure mode                                   │
│      └─ Escalate to DD with options:                           │
│          • Skip and proceed (technical debt)                    │
│          • Manual intervention required                         │
│          • Scope change needed (route to CR/NF)                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Escalation Protocol

### External Escalations (Mandatory DD Involvement)

| Escalation Type | Example | PO Action |
|-----------------|---------|-----------|
| Account Setup | Convex, Stripe, Vercel accounts | Pause dependent tasks, notify DD |
| Payment/Billing | API keys requiring payment | Pause, provide alternatives if any |
| Legal/Compliance | Terms acceptance, contracts | Full stop, await DD |
| Access Credentials | Third-party API keys | Pause, notify DD |
| Domain/Infrastructure | DNS, hosting setup | Document requirements, notify DD |

### Internal Escalations (PO Handles)

| Escalation Type | Example | PO Action |
|-----------------|---------|-----------|
| Test Failures | Tests fail after 2 attempts | Document, try fix coordination |
| Scope Ambiguity | Spec unclear | Reference specs, interpret reasonably |
| Dependency Conflict | Task A blocks Task B | Resequence execution |
| Quality Gate Fail | Below baseline | Coordinate fixes or flag for DD |

### Escalation Message Format

```markdown
## Escalation to Delivery Director

**Type:** [External Dependency / Blocker / Decision Required]
**Priority:** [BLOCKING / HIGH / MEDIUM]
**Affected Tasks:** [TASK-XXX, TASK-YYY]

### Context
[Brief description of what triggered this escalation]

### What's Needed
[Specific action required from DD]

### Options (if applicable)
1. [Option A] - [Implications]
2. [Option B] - [Implications]

### Recommended Action
[PO's recommendation if appropriate]

### Timeline Impact
[How this affects the schedule if not resolved]
```

---

## Parallelization Strategy

### Dependency Analysis

The Product Owner performs automatic dependency analysis:

```
Dependency Graph Construction:
1. Parse all tasks in current phase
2. Extract explicit dependencies from task files
3. Detect implicit dependencies:
   - Shared file modifications
   - API/interface dependencies
   - Test fixture dependencies
   - Build order requirements
4. Group independent tasks into parallel batches
5. Create execution schedule with barriers
```

### Parallelization Rules

| Rule | Description |
|------|-------------|
| File Ownership | Each file owned by max 1 agent at a time |
| Interface First | Shared interfaces defined before parallel work |
| Test Isolation | Each agent runs only their Test Delta |
| Merge Order | PO controls merge sequence to prevent conflicts |
| Rollback Ready | Each parallel batch can be rolled back independently |

### Parallel Execution Limits

- **Max concurrent agents:** 5 (configurable)
- **Max tasks per agent:** 1 (single task focus)
- **Agent timeout:** 30 minutes per task (configurable)
- **Retry limit:** 2 attempts before BLOCKED

---

## Quality Assurance

### PO Validation Checkpoints

1. **Pre-GO Validation**
   - Task spec completeness
   - Test Delta defined
   - Dependencies satisfied
   - No spec/plan conflicts

2. **Post-Implementation Validation**
   - All AC items addressed
   - Test Delta executed
   - No regressions detected
   - Report complete and accurate

3. **Phase Completion Validation**
   - All phase tasks complete
   - Integration tests pass
   - No blocked tasks unresolved
   - State files updated

### Automated Quality Checks

```yaml
pre_go_checks:
  - spec_exists: true
  - test_delta_defined: true
  - dependencies_met: true
  - no_conflicts: true

post_implementation_checks:
  - all_tests_pass: true
  - coverage_maintained: true
  - no_regressions: true
  - report_complete: true
  - files_match_scope: true
```

---

## State Management

### Execution State Hierarchy

```
.factory/
├── execution/
│   ├── orchestrator_state.json    # PO internal state
│   ├── agent_registry.json        # Active agents
│   ├── escalation_queue.json      # Pending DD items
│   └── parallel_batches/          # Batch execution logs
│       ├── BATCH-001.json
│       └── BATCH-002.json
│
docs/execution/
├── state.md                       # Human-readable state
├── progress.json                  # Progress metrics
├── dd_reports/                    # Reports for Delivery Director
│   ├── PHASE-01-report.md
│   └── daily_summary.md
└── agent_reports/                 # Individual agent reports
    ├── TASK-001.md
    └── TASK-002.md
```

### State Synchronization

- PO maintains authoritative state
- Agents report state changes to PO
- State persisted after each significant action
- DD can query state at any time

---

## Communication Patterns

### DD ↔ PO Communication

| Direction | Format | Frequency |
|-----------|--------|-----------|
| DD → PO | Chat commands | On-demand |
| PO → DD | Status reports | Per phase + on escalation |
| PO → DD | Escalation messages | As needed |
| DD → PO | Escalation responses | As needed |

### DD Commands to PO

```
STATUS              - Get current execution status
PAUSE               - Pause all execution
RESUME              - Resume execution
DETAIL [task-id]    - Get detailed task status
ESCALATIONS         - List pending escalations
RESPOND [esc-id]    - Respond to escalation
OVERRIDE [decision] - Override PO decision
SKIP [task-id]      - Skip a blocked task
ABORT               - Abort current phase
```

### PO ↔ Agent Communication

| Direction | Format | Frequency |
|-----------|--------|-----------|
| PO → Agent | Task assignment JSON | At spawn |
| Agent → PO | Progress updates | Every 5 minutes |
| Agent → PO | Completion report | At task end |
| PO → Agent | GO/FIX directive | At gates |

---

## Benefits of v20 Model

### For Delivery Directors

1. **Reduced Cognitive Load** - No task-level decisions required
2. **Strategic Focus** - Time spent on high-value decisions only
3. **Clear Escalation** - Know exactly when input is needed
4. **Progress Visibility** - Regular automated reports
5. **Override Capability** - Can intervene when necessary

### For Execution Speed

1. **Parallel by Default** - Multiple tasks execute simultaneously
2. **No Human Bottleneck** - GO/NEXT gates don't wait for humans
3. **Automated Fix Cycles** - PO handles first-line troubleshooting
4. **Continuous Progress** - Work continues while DD handles escalations

### For Quality

1. **Consistent Validation** - Same criteria applied every time
2. **Spec Fidelity** - PO validates against actual specifications
3. **Regression Prevention** - Automated checks at every step
4. **Audit Trail** - Complete execution history preserved

---

## Risk Mitigation

### Risk: AI Misinterprets Specifications

**Mitigation:**
- PO validates implementation plans against specs before GO
- Agents must cite specific spec sections in plans
- Automated spec-drift detection

### Risk: Parallel Conflicts

**Mitigation:**
- Strict file ownership during parallel execution
- Interface-first approach for shared components
- PO controls merge order

### Risk: Runaway Execution

**Mitigation:**
- Phase boundaries require DD approval
- Escalation thresholds trigger automatic pause
- DD can PAUSE/ABORT at any time

### Risk: External Dependency Blocking

**Mitigation:**
- Early detection of external dependencies
- Proactive escalation to DD
- Alternative path identification where possible

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| DD Time per Phase | < 30 min | Time spent on approvals/escalations |
| Parallel Efficiency | > 60% | Tasks executed in parallel vs sequential |
| First-Pass Success | > 80% | Tasks passing without fix cycles |
| Escalation Rate | < 10% | Tasks requiring DD intervention |
| Spec Compliance | 100% | Implementations matching specifications |

---

## Migration Path from v10.x

### Backward Compatibility

- v10.x projects can run under v20 with DD acting as active PO
- Gradual delegation: Start with PO handling specific phases
- Full autonomous mode opt-in per project

### Upgrade Steps

1. Upgrade factory artifacts to v20 format
2. Configure PO orchestrator settings
3. Set DD escalation preferences
4. Run pilot phase with DD oversight
5. Enable full autonomous mode

---

## Conclusion

ProductFactoryFramework v20 transforms AI from a tool that executes human commands into an autonomous manager that orchestrates delivery while humans focus on strategic decisions and external interfaces. This model maximizes parallel execution, maintains quality through consistent validation, and provides clear accountability through structured escalation.

The Delivery Director retains ultimate authority while being freed from operational details. The Product Owner (Claude Code) gains the autonomy to make routine execution decisions while recognizing the boundaries of its authority. Task Agents focus purely on implementation, protected from scope drift by the PO's oversight.

This is the natural evolution of AI-assisted development: from AI as implementer to AI as delivery manager.

---

## Appendix: Glossary

| Term | Definition |
|------|------------|
| Delivery Director (DD) | Human with strategic oversight and escalation handling |
| Product Owner (PO) | Claude Code orchestrator managing execution |
| Task Agent | Claude Code worker executing individual tasks |
| Escalation | Request for DD input on external/blocking issues |
| Parallel Batch | Group of independent tasks executed simultaneously |
| GO Gate | Authorization to begin implementation |
| NEXT Gate | Authorization to proceed to next task |
| Fix Coordination | PO-managed retry cycle for failed tasks |
