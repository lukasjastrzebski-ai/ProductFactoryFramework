# v20 Role Definitions

This directory contains the binding role contracts for ProductFactoryFramework v20.

## Role Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                 DELIVERY DIRECTOR (Human)                   │
│                    Ultimate Authority                        │
│         Strategic decisions, external escalations           │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              │ Reports & Escalations
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              PRODUCT OWNER (Claude Code)                    │
│                 Execution Authority                          │
│      GO/NEXT gates, validation, fix coordination            │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              │ Task Assignments
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              TASK AGENTS (Claude Code Workers)              │
│                  Implementation Only                         │
│        Execute assigned tasks, report to PO                 │
└─────────────────────────────────────────────────────────────┘
```

## Role Files

| Role | File | Authority Level |
|------|------|-----------------|
| Delivery Director | [delivery_director.md](delivery_director.md) | Highest |
| Product Owner | [product_owner.md](product_owner.md) | Execution |
| Task Agent | [task_agent.md](task_agent.md) | Implementation |

## Authority Rules

1. **DD decisions override PO decisions** - Always
2. **PO decisions override Agent decisions** - Always
3. **Agents cannot escalate directly to DD** - Must go through PO
4. **DD can override any decision** - At any time

## Role Detection

At session start, the system detects the operating role:

```
If .factory/V20_MODE exists:
  If user says "I am the Delivery Director" or context indicates DD:
    Role = DELIVERY_DIRECTOR
  Else if .factory/ORCHESTRATOR_ACTIVE exists:
    Role = PRODUCT_OWNER
  Else if task_assignment.json received:
    Role = TASK_AGENT
  Else:
    Role = PRODUCT_OWNER (default in v20)
Else:
  Role = LEGACY_PO (v10.x compatibility mode)
```

## Interaction Patterns

### DD ↔ PO

- **DD → PO:** Commands, escalation responses, overrides
- **PO → DD:** Status reports, escalations, phase completion

### PO ↔ Agent

- **PO → Agent:** Task assignments, GO gates, fix directives
- **Agent → PO:** Plans, progress updates, completion reports

### DD ↔ Agent

- **Direct interaction prohibited** - Always routed through PO
- Exception: DD ABORT command terminates all agents directly

## Related Documentation

- [v20 Vision](../v20_vision.md) - Overall v20 architecture
- [v20 Implementation Plan](../v20_implementation_plan.md) - Implementation details
- [AI Contract](../ai.md) - Binding authority rules
