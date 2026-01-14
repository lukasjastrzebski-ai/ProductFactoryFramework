# Factory Markers Reference

**Version:** 20.0

This document provides a complete reference for all factory state markers.

---

## Marker Categories

### Core Markers (All Versions)

These markers exist in both v10.x and v20 modes.

| Marker | File | Purpose |
|--------|------|---------|
| Kickoff Complete | `.factory/KICKOFF_COMPLETE` | Planning initialized |
| Stage 7 Complete | `.factory/STAGE_7_COMPLETE` | Planning finished |
| Planning Frozen | `.factory/PLANNING_FROZEN` | Specs locked |
| Run Mode | `.factory/RUN_MODE` | PLANNING or EXECUTION |
| Last Good SHA | `.factory/LAST_KNOWN_GOOD_SHA` | Recovery point |
| Factory Version | `.factory/factory_version.txt` | Version identifier |
| Extension Active | `.factory/EXTENSION_ACTIVE` | Customization mode |

### v20 Mode Markers

These markers are specific to v20 autonomous mode.

| Marker | File | Purpose |
|--------|------|---------|
| v20 Mode | `.factory/V20_MODE` | Autonomous mode enabled |
| Orchestrator Active | `.factory/ORCHESTRATOR_ACTIVE` | PO is running |
| DD Escalation Pending | `.factory/DD_ESCALATION_PENDING` | Awaiting DD |

---

## Marker Details

### KICKOFF_COMPLETE

**Created:** Stage 0 completion
**Content:** Timestamp

```
KICKOFF_COMPLETE
Created: 2026-01-14T10:00:00Z
Product: Example Product
```

**Significance:**
- Project has been initialized
- Product context exists
- Ready for planning stages

---

### STAGE_7_COMPLETE

**Created:** Stage 7 completion
**Content:** Timestamp and summary

```
STAGE_7_COMPLETE
Created: 2026-01-14T12:00:00Z
AI Contract: Finalized
Planning Stages: 7/7 Complete
```

**Significance:**
- All planning stages complete
- AI contract (docs/ai.md) finalized
- Ready for execution phase

---

### PLANNING_FROZEN

**Created:** With STAGE_7_COMPLETE
**Content:** Timestamp

```
PLANNING_FROZEN
Created: 2026-01-14T12:00:00Z
Frozen Directories:
- specs/
- architecture/
- plan/
```

**Significance:**
- specs/, architecture/, plan/ are read-only
- Changes require CR/NF gates
- Violations invalidate execution

---

### RUN_MODE

**Created:** Kickoff
**Content:** Mode string

```
PLANNING
```
or
```
EXECUTION
```

**Significance:**
- PLANNING: Stages 0-7 in progress
- EXECUTION: Task runner active

---

### V20_MODE

**Created:** v20 activation
**Content:** Version string

```
20.0
```

**Significance:**
- Autonomous execution enabled
- PO manages GO/NEXT gates
- Parallel agents allowed
- DD escalation protocol active

---

### ORCHESTRATOR_ACTIVE

**Created:** PO startup
**Content:** Session info

```json
{
  "started_at": "2026-01-14T10:00:00Z",
  "session_id": "uuid",
  "phase": "PHASE-01"
}
```

**Significance:**
- PO session is active
- Agents may be spawned
- State is being managed
- Should not run multiple orchestrators

---

### DD_ESCALATION_PENDING

**Created:** On escalation
**Content:** Escalation IDs

```json
{
  "escalations": ["ESC-001", "ESC-002"],
  "blocking": true,
  "created_at": "2026-01-14T10:00:00Z"
}
```

**Significance:**
- Unresolved escalations exist
- If blocking: execution paused
- DD response required

---

## Marker Lifecycle

```
Project Start
     │
     ▼
KICKOFF_COMPLETE ────────────────────────┐
     │                                    │
     ▼ Planning Stages 1-7                │
     │                                    │
     ▼                                    │
STAGE_7_COMPLETE + PLANNING_FROZEN ──────┤
     │                                    │
     ▼ Execution Phase                    │
     │                                    │
     ├─► RUN_MODE = EXECUTION             │
     │                                    │
     ├─► V20_MODE (if v20)                │
     │     │                              │
     │     ├─► ORCHESTRATOR_ACTIVE        │
     │     │                              │
     │     └─► DD_ESCALATION_PENDING      │
     │           (temporary)              │
     │                                    │
     ▼                                    │
LAST_KNOWN_GOOD_SHA ─────────────────────┘
     │
     ▼
Project Complete
```

---

## Validation Rules

### CI/CD Checks

```yaml
# .github/workflows/factory-guardrails.yml

validate_markers:
  # Core markers always required after kickoff
  - KICKOFF_COMPLETE must exist after Stage 0

  # Execution requires planning complete
  - If RUN_MODE == EXECUTION:
    - STAGE_7_COMPLETE must exist
    - PLANNING_FROZEN must exist

  # v20 mode requirements
  - If V20_MODE exists:
    - Factory version >= 20.0
    - PLANNING_FROZEN must exist

  # Orchestrator constraints
  - If ORCHESTRATOR_ACTIVE exists:
    - V20_MODE must exist
    - Only one orchestrator at a time
```

---

## Creating Markers

### Programmatic Creation

```bash
# Create v20 mode marker
create_v20_mode() {
  echo "20.0" > .factory/V20_MODE
  echo "20.0" > .factory/factory_version.txt
}

# Create orchestrator marker
create_orchestrator_active() {
  cat > .factory/ORCHESTRATOR_ACTIVE << EOF
{
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "session_id": "$(uuidgen)",
  "phase": "$1"
}
EOF
}

# Create escalation marker
create_escalation_pending() {
  cat > .factory/DD_ESCALATION_PENDING << EOF
{
  "escalations": $1,
  "blocking": $2,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}
```

---

## Checking Markers

### Quick Checks

```bash
# Is planning frozen?
is_frozen() {
  test -f .factory/PLANNING_FROZEN
}

# Is v20 mode active?
is_v20() {
  test -f .factory/V20_MODE
}

# Is orchestrator running?
is_orchestrator_active() {
  test -f .factory/ORCHESTRATOR_ACTIVE
}

# Are there pending escalations?
has_escalations() {
  test -f .factory/DD_ESCALATION_PENDING
}

# Is execution blocked?
is_blocked() {
  if [ -f .factory/DD_ESCALATION_PENDING ]; then
    grep -q '"blocking": true' .factory/DD_ESCALATION_PENDING
  else
    return 1
  fi
}
```

---

## Removing Markers

### Safe Removal

```bash
# Clear orchestrator session
clear_orchestrator() {
  rm -f .factory/ORCHESTRATOR_ACTIVE
}

# Clear escalations (after DD responds)
clear_escalations() {
  rm -f .factory/DD_ESCALATION_PENDING
}

# Full v20 reset (caution!)
reset_v20() {
  rm -f .factory/V20_MODE
  rm -f .factory/ORCHESTRATOR_ACTIVE
  rm -f .factory/DD_ESCALATION_PENDING
  rm -rf .factory/execution/
  rm -rf .factory/agent_progress/
}
```

---

## Related Documentation

- [.factory/README.md](../.factory/README.md) - State directory reference
- [docs/ai.md](ai.md) - AI contract
- [CLAUDE.md](../CLAUDE.md) - Operating contract
