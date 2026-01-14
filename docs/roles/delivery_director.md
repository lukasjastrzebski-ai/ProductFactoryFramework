# Delivery Director Role Contract

**Version:** 20.0
**Role Type:** Human
**Authority Level:** Highest

---

## Definition

The Delivery Director (DD) is the human stakeholder with ultimate authority over the project. The DD provides strategic oversight, handles external escalations, and receives reports from the Product Owner (Claude Code).

---

## Responsibilities

### Strategic Oversight

- Approve project initiation and overall scope
- Make strategic decisions when AI-detected blockers require human judgment
- Provide final acceptance of completed phases/milestones
- Override AI decisions when necessary

### External Interface

- Handle external escalations (third-party accounts, payments, legal)
- Set up accounts requiring human identity (Stripe, Convex, Vercel, etc.)
- Accept terms of service and contracts
- Provide API keys and credentials

### Progress Monitoring

- Receive and review progress reports from Product Owner
- Monitor execution status via DD commands
- Intervene when quality standards are at risk

---

## NOT Responsible For

The Delivery Director should NOT be involved in:

- Task-level GO/NEXT approvals (delegated to PO)
- Code review at implementation level (handled by PO)
- Individual test verification (automated)
- Internal task sequencing decisions (managed by PO)
- Agent management (orchestrated by PO)

---

## Authorities

### Full Authority

| Authority | Description |
|-----------|-------------|
| PAUSE | Pause all execution immediately |
| RESUME | Resume paused execution |
| ABORT | Terminate all agents and execution |
| OVERRIDE | Override any PO decision |
| SKIP | Skip any blocked task |
| APPROVE | Approve phases, milestones, scope changes |

### Commands

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

---

## Constraints

### Must Do

- Respond to BLOCKING escalations in a timely manner
- Provide external credentials when requested
- Review phase completion reports before approval
- Make strategic decisions when requested

### Must NOT Do

- Micromanage task-level implementation
- Bypass the PO for agent communication
- Ignore escalations (causes execution stall)

---

## Escalation Triggers

The PO will escalate to DD when:

| Trigger | Priority | Example |
|---------|----------|---------|
| External account needed | BLOCKING | Stripe setup required |
| Payment required | BLOCKING | API key needs purchase |
| Legal/compliance | BLOCKING | ToS acceptance needed |
| Credentials needed | BLOCKING | Third-party API key |
| Strategic decision | HIGH | Architecture pivot needed |
| Repeated failures | HIGH | Task failed 3+ times |
| Quality concerns | MEDIUM | Below baseline quality |

---

## Response Format

When responding to escalations:

```markdown
## Escalation Response

**Escalation ID:** ESC-XXX
**Decision:** [APPROVE | REJECT | DEFER | PROVIDE]
**Details:** [Specific response or credentials]

### If Providing Credentials
```
CREDENTIAL_NAME=value
```

### If Deferring
**Defer Until:** [Date or condition]
**Reason:** [Why deferring]
```

---

## Session Behavior

### At Session Start

If operating as Delivery Director in v20 mode:
1. System announces DD role
2. PO provides status summary
3. Any pending escalations are presented

### During Session

- DD issues commands as needed
- PO executes autonomously between commands
- Escalations interrupt PO reports

### At Session End

- PO provides session summary
- Any unresolved escalations flagged
- State persisted for next session

---

## Relationship with Product Owner

```
DD Perspective:
┌─────────────────────────────────────────────────────────────┐
│                   DELIVERY DIRECTOR                          │
│                                                             │
│  I receive:              I provide:                         │
│  - Status reports        - Strategic direction              │
│  - Escalations          - External credentials              │
│  - Phase completions    - Escalation responses              │
│  - Quality alerts       - Override decisions                │
│                                                             │
│  I trust PO to:          I intervene when:                  │
│  - Manage execution     - External deps needed              │
│  - Validate quality     - Quality at risk                   │
│  - Coordinate fixes     - Strategic pivot needed            │
│  - Handle retries       - DD override necessary             │
└─────────────────────────────────────────────────────────────┘
```

---

## Related Documentation

- [Product Owner Contract](product_owner.md) - PO responsibilities
- [Task Agent Contract](task_agent.md) - Agent responsibilities
- [v20 Vision](../v20_vision.md) - Overall architecture
- [DD Commands](../execution/dd_commands.md) - Full command reference
