# v20 Integration Tests

**Version:** 20.0

This directory contains integration tests for the v20 autonomous execution system.

---

## Test Categories

### 1. PO Initialization Tests

| Test | Description |
|------|-------------|
| test_po_init_fresh | PO initializes from scratch |
| test_po_init_resume | PO resumes from saved state |
| test_po_init_stale | PO handles stale session |

### 2. Agent Lifecycle Tests

| Test | Description |
|------|-------------|
| test_agent_spawn | Agent spawns correctly |
| test_agent_worktree | Worktree created and isolated |
| test_agent_progress | Progress reporting works |
| test_agent_complete | Agent completes and cleanup |

### 3. Gate Tests

| Test | Description |
|------|-------------|
| test_go_gate_valid | GO issued for valid plan |
| test_go_gate_invalid | GO rejected for invalid plan |
| test_next_gate_pass | NEXT issued for passing report |
| test_next_gate_fail | FIX issued for failing report |

### 4. Parallel Execution Tests

| Test | Description |
|------|-------------|
| test_parallel_spawn | Multiple agents spawn |
| test_parallel_isolation | No file conflicts |
| test_parallel_merge | Ordered merge works |
| test_batch_completion | Batch completes correctly |

### 5. Escalation Tests

| Test | Description |
|------|-------------|
| test_escalation_create | Escalation created |
| test_escalation_blocking | Blocking escalation pauses |
| test_escalation_resolve | Resolution unblocks |

### 6. DD Command Tests

| Test | Description |
|------|-------------|
| test_status_command | STATUS returns data |
| test_pause_command | PAUSE stops execution |
| test_resume_command | RESUME continues |
| test_abort_command | ABORT terminates |

### 7. Recovery Tests

| Test | Description |
|------|-------------|
| test_state_recovery | State recovers after crash |
| test_orphan_cleanup | Orphaned agents cleaned |
| test_worktree_cleanup | Stale worktrees removed |

---

## Running Tests

### All Tests

```bash
./tests/v20_integration/run_tests.sh
```

### Specific Category

```bash
./tests/v20_integration/run_tests.sh --category agent
```

### Single Test

```bash
./tests/v20_integration/run_tests.sh --test test_agent_spawn
```

---

## Test Environment

Tests run in isolated environment:
- Separate .factory/ directory
- Temporary worktrees
- Mock external services

### Setup

```bash
./tests/v20_integration/setup.sh
```

### Teardown

```bash
./tests/v20_integration/teardown.sh
```

---

## Test Fixtures

### Mock Task

```
tests/v20_integration/fixtures/
├── mock_task.md
├── mock_spec.md
├── mock_assignment.json
└── mock_report.json
```

### Mock State

```
tests/v20_integration/fixtures/state/
├── orchestrator_state.json
├── agent_registry.json
└── escalation_queue.json
```

---

## Test Results

Results stored in:

```
tests/v20_integration/results/
├── latest.json
├── 2026-01-14.json
└── ...
```

### Result Format

```json
{
  "timestamp": "ISO8601",
  "total": 30,
  "passed": 28,
  "failed": 2,
  "skipped": 0,
  "duration_seconds": 120,
  "failures": [
    {
      "test": "test_parallel_merge",
      "error": "Merge conflict detected",
      "details": "..."
    }
  ]
}
```

---

## Coverage

Target coverage:

| Component | Target |
|-----------|--------|
| PO Engine | 90% |
| Agent System | 90% |
| Communication | 85% |
| State Management | 90% |
| Escalation | 85% |

---

## Related Documentation

- [v20 Vision](../../docs/v20_vision.md)
- [v20 Implementation Plan](../../docs/v20_implementation_plan.md)
- [Pilot Mode](../../docs/execution/pilot_mode.md)
