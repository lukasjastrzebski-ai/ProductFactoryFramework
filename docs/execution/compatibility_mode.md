# Compatibility Mode

**Version:** 20.0

This document describes v10.x compatibility mode for v20 projects.

---

## Overview

v20 includes a compatibility mode that allows projects to operate like v10.x with human-controlled GO/NEXT gates. This enables gradual adoption of v20 features.

---

## Enabling Compatibility Mode

### Full Compatibility (v10.x behavior)

Remove v20 marker:
```bash
rm .factory/V20_MODE
```

Or set in config:
```json
{
  "execution_mode": "compatibility"
}
```

### Partial Compatibility

Enable specific v10.x behaviors:

```json
{
  "execution_mode": "autonomous",
  "require_human_go": true,
  "require_human_next": true,
  "disable_parallel": true
}
```

---

## Behavior Comparison

| Feature | v10.x / Compat | v20 Autonomous |
|---------|----------------|----------------|
| GO gates | Human approves | PO approves |
| NEXT gates | Human approves | PO approves |
| Parallel execution | Disabled | Enabled |
| Agent spawning | Single | Multiple |
| Escalations | Direct to human | Via queue |

---

## Use Cases

### Gradual Adoption

1. Start in compatibility mode
2. Enable autonomous GO (keep human NEXT)
3. Enable parallel execution
4. Full autonomous mode

### Sensitive Phases

For phases requiring extra oversight:
```json
{
  "phase_overrides": {
    "PHASE-03": {
      "require_human_go": true,
      "require_human_next": true
    }
  }
}
```

### Debugging

When troubleshooting v20 issues:
```bash
# Temporarily disable v20
rm .factory/V20_MODE

# Debug in v10.x mode
# Then re-enable
echo "20.0" > .factory/V20_MODE
```

---

## Configuration Options

### Global Settings

```json
// .factory/v20_config.json
{
  "execution_mode": "autonomous",
  "require_human_go": false,
  "require_human_next": false,
  "enable_parallel": true,
  "max_parallel_agents": 5,
  "verbose_logging": false
}
```

### Per-Phase Overrides

```json
{
  "phase_overrides": {
    "PHASE-01": {
      "require_human_go": true
    },
    "PHASE-05": {
      "max_parallel_agents": 2
    }
  }
}
```

---

## Switching Modes

### To Compatibility Mode

```bash
rm .factory/V20_MODE
```

Or:
```bash
./scripts/migration/v10_to_v20.sh --rollback
```

### To Autonomous Mode

```bash
echo "20.0" > .factory/V20_MODE
```

Or:
```bash
./scripts/migration/v10_to_v20.sh
```

---

## State Preservation

When switching modes:
- Execution state preserved
- Task progress preserved
- Reports preserved
- Only behavior changes

---

## Related Documentation

- [v10 to v20 Migration](../migration/v10_to_v20_migration.md)
- [V20 User Guide](../V20_USER_GUIDE.md)
- [Pilot Mode](pilot_mode.md)
