# Dependency Analysis

**Version:** 20.0

This document describes how the Product Owner analyzes task dependencies for parallel execution.

---

## Overview

Before executing tasks, the PO must analyze dependencies to:
1. Determine execution order
2. Identify parallelizable tasks
3. Detect potential conflicts
4. Build the execution graph

---

## Dependency Types

### Explicit Dependencies

Defined directly in task files:

```markdown
## Dependencies

- TASK-001 (Must complete first)
- TASK-002 (Provides required interface)
```

**Detection:** Parse task files for `Dependencies:` section

### Implicit Dependencies

Inferred from task properties:

1. **Shared File Modifications**
   - If TASK-A and TASK-B both modify `src/auth.ts`
   - They cannot run in parallel
   - Lower priority task depends on higher priority

2. **Interface Dependencies**
   - If TASK-A creates an interface TASK-B uses
   - TASK-B implicitly depends on TASK-A

3. **Test Dependencies**
   - If TASK-B's tests depend on TASK-A's code
   - TASK-B depends on TASK-A

**Detection:** Analyze file modification lists, test imports

---

## Dependency Graph

### Structure

```json
{
  "TASK-001": [],
  "TASK-002": ["TASK-001"],
  "TASK-003": ["TASK-001"],
  "TASK-004": ["TASK-002", "TASK-003"],
  "TASK-005": []
}
```

Each key is a task ID, value is list of dependencies.

### Visualization

```
TASK-001 ──┬──► TASK-002 ──┬──► TASK-004
           │               │
           └──► TASK-003 ──┘

TASK-005 (independent)
```

---

## Parallelization Rules

### Can Run in Parallel

Tasks can run in parallel if ALL conditions are met:

1. **No direct dependency** - Neither depends on the other
2. **No shared files** - Disjoint file modification sets
3. **Dependencies satisfied** - All dependencies complete
4. **No resource conflicts** - No shared external resources

### Cannot Run in Parallel

Tasks must run sequentially if ANY condition is true:

1. **Direct dependency** - One depends on the other
2. **File conflict** - Both modify the same file
3. **Interface conflict** - One creates what other uses
4. **Resource conflict** - Both use limited resource

---

## Algorithm

### Input

- List of tasks in current phase
- Task metadata (dependencies, files, tests)

### Process

```python
def analyze_dependencies(tasks):
    # 1. Build explicit dependency graph
    graph = {}
    for task in tasks:
        graph[task.id] = task.explicit_dependencies

    # 2. Detect implicit dependencies
    file_owners = {}
    for task in tasks:
        for file in task.files_modified:
            if file in file_owners:
                # File conflict - add implicit dependency
                graph[task.id].add(file_owners[file])
            file_owners[file] = task.id

    # 3. Topological sort for execution order
    order = topological_sort(graph)

    # 4. Group into parallel batches
    batches = []
    processed = set()

    for task_id in order:
        if task_id in processed:
            continue

        batch = [task_id]
        for other_id in order:
            if can_parallelize(task_id, other_id, graph, tasks):
                batch.append(other_id)

        batches.append(batch)
        processed.update(batch)

    return batches
```

### Output

Execution graph JSON:

```json
{
  "version": "20.0",
  "phase": "PHASE-01",
  "generated_at": "2026-01-14T10:00:00Z",
  "tasks": { ... },
  "parallel_groups": [
    {
      "group_id": "GROUP-001",
      "tasks": ["TASK-001", "TASK-005"],
      "barrier_after": true,
      "estimated_agents": 2
    },
    {
      "group_id": "GROUP-002",
      "tasks": ["TASK-002", "TASK-003"],
      "barrier_after": true,
      "estimated_agents": 2
    },
    {
      "group_id": "GROUP-003",
      "tasks": ["TASK-004"],
      "barrier_after": true,
      "estimated_agents": 1
    }
  ],
  "execution_order": ["TASK-001", "TASK-005", "TASK-002", "TASK-003", "TASK-004"],
  "total_tasks": 5,
  "parallelizable_tasks": 4,
  "sequential_tasks": 1
}
```

---

## Conflict Resolution

### File Conflicts

When multiple tasks modify the same file:

1. **Check priority** - Higher priority task goes first
2. **Check dependencies** - If one depends on other, that determines order
3. **Default** - Alphabetical task ID order

### Circular Dependencies

When detected:

1. **Log warning** - Document the cycle
2. **Break arbitrarily** - Choose one edge to remove
3. **Flag for review** - DD may need to resolve

---

## Usage

### Command Line

```bash
# Analyze all tasks
python scripts/po/analyze_dependencies.py

# Analyze specific phase
python scripts/po/analyze_dependencies.py --phase PHASE-01

# Custom output
python scripts/po/analyze_dependencies.py --output custom_graph.json
```

### Programmatic

```python
from scripts.po.analyze_dependencies import analyze

# Run analysis
result = analyze(phase="PHASE-01")

# Access results
print(f"Total tasks: {result.total_tasks}")
print(f"Parallel groups: {len(result.parallel_groups)}")
```

---

## Integration with PO

The PO uses dependency analysis at:

1. **Startup** - Analyze current phase
2. **Phase transition** - Analyze new phase
3. **Resequencing** - After task completion changes graph

---

## Metrics

Track parallelization efficiency:

| Metric | Formula |
|--------|---------|
| Parallelization Ratio | parallelizable_tasks / total_tasks |
| Group Efficiency | avg(tasks_per_group) |
| Critical Path Length | len(sequential_groups) |

Target: >60% parallelization ratio

---

## Related Documentation

- [PO Startup](po_startup.md)
- [Task Assignment](task_assignment.md)
- [Multi-Agent Execution Protocol](../multi_agent_execution_protocol.md)
