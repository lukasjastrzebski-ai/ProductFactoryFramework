# Factory State Directory

This directory contains runtime state markers for the Product Factory Framework.

## Marker Files

| File | Purpose | Created At |
|------|---------|------------|
| `KICKOFF_COMPLETE` | Planning kickoff has finished | Stage 0 |
| `STAGE_7_COMPLETE` | AI contract finalized, planning done | Stage 7 |
| `PLANNING_FROZEN` | Planning artifacts locked for execution | Stage 7 |
| `RUN_MODE` | Current mode: PLANNING or EXECUTION | Kickoff |
| `LAST_KNOWN_GOOD_SHA` | Last verified git commit SHA | Execution |
| `factory_version.txt` | Framework version identifier | Installation |
| `EXTENSION_ACTIVE` | Extension/customization mode enabled | Extension flow |

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
Contains the framework version (e.g., "10.1"). Used for compatibility checks.

### EXTENSION_ACTIVE
Present when the factory is being extended or customized. See docs/EXTENSION_GUIDE.md for details.

## Session Files (Optional)

| File | Purpose |
|------|---------|
| `session_context.md` | Mid-session compaction output for context management |
| `anti_patterns/` | Directory for documenting failed approaches |
| `init_session.sh` | Initializer agent script (if using that pattern) |

## Rules

- **Do not manually edit marker files** - They are created by factory flows
- **CI validates marker presence** - Missing markers block execution
- **Markers are additive** - Once created, they persist until project reset

## Checking State

Quick commands to check factory state:

```bash
# Check if planning is frozen
test -f .factory/PLANNING_FROZEN && echo "Frozen" || echo "Not frozen"

# Check current mode
cat .factory/RUN_MODE

# Check factory version
cat .factory/factory_version.txt
```

## Resetting State

To reset factory state (use with caution):

```bash
# Remove execution markers (keeps planning complete)
rm -f .factory/LAST_KNOWN_GOOD_SHA

# Full reset (requires re-running planning stages)
rm -f .factory/STAGE_7_COMPLETE .factory/PLANNING_FROZEN
```

## Related Documentation

- [CLAUDE.md](../CLAUDE.md) - Factory operating contract
- [docs/ai.md](../docs/ai.md) - Binding AI contract
- [docs/execution/state.md](../docs/execution/state.md) - Runtime execution state
