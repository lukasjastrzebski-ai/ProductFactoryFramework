# Factory State Directory

This directory contains runtime state markers for the Product Factory Framework.

## Marker Files

### Core Markers (v10.x and v20)

| File | Purpose | Created At |
|------|---------|------------|
| `KICKOFF_COMPLETE` | Planning kickoff has finished | Stage 0 |
| `STAGE_7_COMPLETE` | AI contract finalized, planning done | Stage 7 |
| `PLANNING_FROZEN` | Planning artifacts locked for execution | Stage 7 |
| `RUN_MODE` | Current mode: PLANNING or EXECUTION | Kickoff |
| `LAST_KNOWN_GOOD_SHA` | Last verified git commit SHA | Execution |
| `factory_version.txt` | Framework version identifier | Installation |
| `EXTENSION_ACTIVE` | Extension/customization mode enabled | Extension flow |

### v20 Autonomous Mode Markers

| File | Purpose | Created At |
|------|---------|------------|
| `V20_MODE` | v20 autonomous execution enabled | v20 activation |
| `ORCHESTRATOR_ACTIVE` | PO orchestrator is running | PO startup |
| `DD_ESCALATION_PENDING` | Escalation awaiting DD response | On escalation |

## Marker Descriptions

### KICKOFF_COMPLETE
Created when Stage 0 (Idea Intake) is complete. Indicates the project has been initialized with basic product context.

### STAGE_7_COMPLETE
Created when all 7 planning stages are complete. The AI contract (docs/ai.md) is finalized and ready for execution.

### PLANNING_FROZEN
Created alongside STAGE_7_COMPLETE. Indicates that specs/, architecture/, and plan/ directories are locked. Changes require gated flows (CR/New Feature).

### RUN_MODE
Contains either "PLANNING" or "EXECUTION". Indicates current operational mode:
- PLANNING: Still in ideation stages 0-7
- EXECUTION: Active task implementation via task runner

### LAST_KNOWN_GOOD_SHA
Git commit SHA of the last verified good state. Used for recovery if needed.

### factory_version.txt
Contains the framework version (e.g., "20.0"). Used for compatibility checks.

### EXTENSION_ACTIVE
Present when the factory is being extended or customized. See docs/EXTENSION_GUIDE.md for details.

### V20_MODE (v20)
Present when v20 autonomous mode is enabled. Activates:
- AI Product Owner orchestration
- Parallel Task Agent execution
- DD escalation protocol
- Autonomous GO/NEXT gates

### ORCHESTRATOR_ACTIVE (v20)
Present when the PO orchestrator is actively running. Indicates:
- PO session is active
- Agents may be spawned
- State is being managed

### DD_ESCALATION_PENDING (v20)
Present when there are unresolved escalations awaiting DD response. Contains escalation IDs.

## v20 State Directories

| Directory | Purpose |
|-----------|---------|
| `execution/` | Orchestrator state and batch tracking |
| `execution/parallel_batches/` | Parallel batch execution logs |
| `execution/history/` | Execution audit trail |
| `execution/go_gates/` | GO gate records |
| `agent_progress/` | Individual agent progress files |
| `schemas/` | JSON schemas for v20 data structures |
| `validation/` | Validation check results |
| `anti_patterns/` | Documented failed approaches |

## Session Files (Optional)

| File | Purpose |
|------|---------|
| `session_context.md` | Mid-session compaction output for context management |
| `anti_patterns/` | Directory for documenting failed approaches |
| `init_session.sh` | Initializer agent script (if using that pattern) |

## v20 State Files

| File | Purpose |
|------|---------|
| `execution/orchestrator_state.json` | PO internal state |
| `execution/agent_registry.json` | Active agent tracking |
| `execution/escalation_queue.json` | Pending DD escalations |

## Rules

- **Do not manually edit marker files** - They are created by factory flows
- **CI validates marker presence** - Missing markers block execution
- **Markers are additive** - Once created, they persist until project reset
- **v20 markers require V20_MODE** - Other v20 markers invalid without it

## Checking State

Quick commands to check factory state:

```bash
# Check if planning is frozen
test -f .factory/PLANNING_FROZEN && echo "Frozen" || echo "Not frozen"

# Check current mode
cat .factory/RUN_MODE

# Check factory version
cat .factory/factory_version.txt

# Check if v20 mode is active
test -f .factory/V20_MODE && echo "v20 Active" || echo "v10.x Mode"

# Check if orchestrator is running
test -f .factory/ORCHESTRATOR_ACTIVE && echo "PO Running" || echo "PO Not Running"

# Check for pending escalations
test -f .factory/DD_ESCALATION_PENDING && echo "Escalations Pending" || echo "No Escalations"
```

## v20 Mode Activation

To activate v20 mode:

```bash
# Create v20 mode marker
echo "20.0" > .factory/V20_MODE

# Update factory version
echo "20.0" > .factory/factory_version.txt
```

## Resetting State

To reset factory state (use with caution):

```bash
# Remove execution markers (keeps planning complete)
rm -f .factory/LAST_KNOWN_GOOD_SHA

# Remove v20 runtime markers
rm -f .factory/ORCHESTRATOR_ACTIVE
rm -f .factory/DD_ESCALATION_PENDING

# Full reset (requires re-running planning stages)
rm -f .factory/STAGE_7_COMPLETE .factory/PLANNING_FROZEN

# Full v20 reset
rm -f .factory/V20_MODE
rm -rf .factory/execution/
rm -rf .factory/agent_progress/
```

## Related Documentation

- [CLAUDE.md](../CLAUDE.md) - Factory operating contract
- [docs/ai.md](../docs/ai.md) - Binding AI contract
- [docs/roles/](../docs/roles/) - v20 role contracts
- [docs/execution/state.md](../docs/execution/state.md) - Runtime execution state
- [docs/v20_vision.md](../docs/v20_vision.md) - v20 architecture vision
- [docs/v20_implementation_plan.md](../docs/v20_implementation_plan.md) - v20 implementation plan
