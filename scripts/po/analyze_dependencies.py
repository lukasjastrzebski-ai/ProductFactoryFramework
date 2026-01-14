#!/usr/bin/env python3
"""
Dependency Analyzer for ProductFactoryFramework v20

This script analyzes task dependencies and generates an execution graph
for parallel task execution.

Usage:
    python analyze_dependencies.py [--phase PHASE] [--output OUTPUT]
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass, asdict
from datetime import datetime


@dataclass
class Task:
    """Represents a task with its metadata"""
    task_id: str
    title: str
    file_path: str
    phase: str
    dependencies: List[str]
    files_modified: List[str]
    test_delta: Dict[str, List[str]]
    priority: int
    complexity: str


@dataclass
class ParallelGroup:
    """A group of tasks that can be executed in parallel"""
    group_id: str
    tasks: List[str]
    barrier_after: bool
    estimated_agents: int


@dataclass
class ExecutionGraph:
    """The complete execution plan"""
    version: str
    phase: str
    generated_at: str
    tasks: Dict[str, Task]
    parallel_groups: List[ParallelGroup]
    execution_order: List[str]
    total_tasks: int
    parallelizable_tasks: int
    sequential_tasks: int


def find_factory_root() -> Path:
    """Find the factory root directory"""
    current = Path.cwd()
    while current != current.parent:
        if (current / ".factory").exists():
            return current
        current = current.parent
    return Path.cwd()


def parse_task_file(file_path: Path) -> Optional[Task]:
    """Parse a task markdown file and extract metadata"""
    try:
        content = file_path.read_text()

        # Extract task ID from filename
        task_id = file_path.stem.upper()

        # Extract title (first H1)
        title_match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
        title = title_match.group(1) if title_match else task_id

        # Extract phase
        phase_match = re.search(r'Phase:\s*(\S+)', content, re.IGNORECASE)
        phase = phase_match.group(1) if phase_match else "UNKNOWN"

        # Extract dependencies
        deps_match = re.search(r'Dependencies:\s*(.+?)(?:\n\n|\n#|$)', content, re.IGNORECASE | re.DOTALL)
        dependencies = []
        if deps_match:
            deps_text = deps_match.group(1)
            dependencies = re.findall(r'TASK-[A-Z0-9-]+', deps_text)

        # Extract files to be modified
        files_match = re.search(r'Files?(?:\s+to\s+(?:modify|change|update|create))?\s*:\s*(.+?)(?:\n\n|\n#|$)',
                               content, re.IGNORECASE | re.DOTALL)
        files_modified = []
        if files_match:
            files_text = files_match.group(1)
            files_modified = re.findall(r'[`"]?([a-zA-Z0-9_/.-]+\.[a-zA-Z]+)[`"]?', files_text)

        # Extract Test Delta
        test_delta = {"add": [], "update": [], "regression": []}
        test_match = re.search(r'Test\s*Delta\s*:\s*(.+?)(?:\n\n|\n#|$)', content, re.IGNORECASE | re.DOTALL)
        if test_match:
            test_text = test_match.group(1)
            add_tests = re.findall(r'[Aa]dd:\s*(.+?)(?:\n|$)', test_text)
            for t in add_tests:
                test_delta["add"].extend(re.findall(r'[`"]?([a-zA-Z0-9_/.-]+)[`"]?', t))

        # Extract priority (default 5)
        priority_match = re.search(r'Priority:\s*(\d+)', content, re.IGNORECASE)
        priority = int(priority_match.group(1)) if priority_match else 5

        # Extract complexity
        complexity_match = re.search(r'Complexity:\s*(\w+)', content, re.IGNORECASE)
        complexity = complexity_match.group(1) if complexity_match else "MEDIUM"

        return Task(
            task_id=task_id,
            title=title,
            file_path=str(file_path),
            phase=phase,
            dependencies=dependencies,
            files_modified=files_modified,
            test_delta=test_delta,
            priority=priority,
            complexity=complexity
        )
    except Exception as e:
        print(f"Warning: Failed to parse {file_path}: {e}", file=sys.stderr)
        return None


def detect_implicit_dependencies(tasks: Dict[str, Task]) -> Dict[str, Set[str]]:
    """Detect implicit dependencies based on shared file modifications"""
    implicit_deps: Dict[str, Set[str]] = {task_id: set() for task_id in tasks}

    # Build file-to-task mapping
    file_to_tasks: Dict[str, List[str]] = {}
    for task_id, task in tasks.items():
        for file in task.files_modified:
            if file not in file_to_tasks:
                file_to_tasks[file] = []
            file_to_tasks[file].append(task_id)

    # Find conflicts
    for file, task_list in file_to_tasks.items():
        if len(task_list) > 1:
            # Sort by priority (lower = higher priority)
            sorted_tasks = sorted(task_list, key=lambda t: tasks[t].priority)
            # Later tasks depend on earlier ones for this file
            for i, task_id in enumerate(sorted_tasks[1:], 1):
                for earlier_task in sorted_tasks[:i]:
                    implicit_deps[task_id].add(earlier_task)

    return implicit_deps


def build_dependency_graph(tasks: Dict[str, Task], phase_filter: Optional[str] = None) -> Dict[str, Set[str]]:
    """Build complete dependency graph including implicit dependencies"""
    # Filter by phase if specified
    if phase_filter:
        tasks = {k: v for k, v in tasks.items() if v.phase == phase_filter}

    # Start with explicit dependencies
    graph: Dict[str, Set[str]] = {}
    for task_id, task in tasks.items():
        graph[task_id] = set(d for d in task.dependencies if d in tasks)

    # Add implicit dependencies
    implicit = detect_implicit_dependencies(tasks)
    for task_id, deps in implicit.items():
        if task_id in graph:
            graph[task_id].update(deps)

    return graph


def topological_sort(graph: Dict[str, Set[str]]) -> List[str]:
    """Perform topological sort on dependency graph"""
    in_degree = {node: 0 for node in graph}
    for node in graph:
        for dep in graph[node]:
            if dep in in_degree:
                pass  # Dependencies point TO the dependent task

    for node in graph:
        for dep in graph[node]:
            if dep in in_degree:
                in_degree[node] += 1  # Increment for each dependency

    # Find nodes with no dependencies
    queue = [node for node, degree in in_degree.items() if degree == 0]
    result = []

    while queue:
        # Sort by some criteria for determinism
        queue.sort()
        node = queue.pop(0)
        result.append(node)

        # Reduce in-degree for dependent tasks
        for other_node, deps in graph.items():
            if node in deps:
                in_degree[other_node] -= 1
                if in_degree[other_node] == 0:
                    queue.append(other_node)

    if len(result) != len(graph):
        missing = set(graph.keys()) - set(result)
        print(f"Warning: Circular dependency detected involving: {missing}", file=sys.stderr)
        result.extend(sorted(missing))

    return result


def identify_parallel_groups(tasks: Dict[str, Task], graph: Dict[str, Set[str]],
                            execution_order: List[str]) -> List[ParallelGroup]:
    """Identify groups of tasks that can run in parallel"""
    groups: List[ParallelGroup] = []
    processed: Set[str] = set()
    group_counter = 1

    for task_id in execution_order:
        if task_id in processed:
            continue

        # Find all tasks that can run in parallel with this one
        parallel_tasks = [task_id]

        for other_id in execution_order:
            if other_id in processed or other_id == task_id:
                continue

            # Can run in parallel if:
            # 1. No dependency between them
            # 2. All their dependencies are already processed
            other_deps = graph.get(other_id, set())
            task_deps = graph.get(task_id, set())

            can_parallel = (
                task_id not in other_deps and
                other_id not in task_deps and
                other_deps.issubset(processed) and
                task_deps.issubset(processed)
            )

            if can_parallel:
                # Check for file conflicts
                task_files = set(tasks[task_id].files_modified)
                other_files = set(tasks[other_id].files_modified)
                if not task_files.intersection(other_files):
                    parallel_tasks.append(other_id)

        # Create group
        group = ParallelGroup(
            group_id=f"GROUP-{group_counter:03d}",
            tasks=parallel_tasks,
            barrier_after=True,  # Always wait for group to complete
            estimated_agents=min(len(parallel_tasks), 5)  # Max 5 agents
        )
        groups.append(group)

        for t in parallel_tasks:
            processed.add(t)

        group_counter += 1

    return groups


def analyze(phase: Optional[str] = None, output_file: Optional[str] = None) -> ExecutionGraph:
    """Main analysis function"""
    factory_root = find_factory_root()
    tasks_dir = factory_root / "plan" / "tasks"

    # Parse all task files
    tasks: Dict[str, Task] = {}
    if tasks_dir.exists():
        for task_file in tasks_dir.glob("*.md"):
            task = parse_task_file(task_file)
            if task:
                tasks[task.task_id] = task

    # Build dependency graph
    graph = build_dependency_graph(tasks, phase)

    # Get execution order
    execution_order = topological_sort(graph)

    # Identify parallel groups
    filtered_tasks = {k: v for k, v in tasks.items() if k in execution_order}
    parallel_groups = identify_parallel_groups(filtered_tasks, graph, execution_order)

    # Calculate statistics
    parallelizable = sum(1 for g in parallel_groups if len(g.tasks) > 1)
    sequential = len(parallel_groups) - parallelizable

    # Build result
    result = ExecutionGraph(
        version="20.0",
        phase=phase or "ALL",
        generated_at=datetime.utcnow().isoformat() + "Z",
        tasks={k: v for k, v in tasks.items() if k in execution_order},
        parallel_groups=parallel_groups,
        execution_order=execution_order,
        total_tasks=len(execution_order),
        parallelizable_tasks=sum(len(g.tasks) for g in parallel_groups if len(g.tasks) > 1),
        sequential_tasks=sum(1 for g in parallel_groups if len(g.tasks) == 1)
    )

    # Output
    output_path = Path(output_file) if output_file else factory_root / ".factory" / "execution_graph.json"

    # Convert to JSON-serializable format
    result_dict = {
        "version": result.version,
        "phase": result.phase,
        "generated_at": result.generated_at,
        "tasks": {k: asdict(v) for k, v in result.tasks.items()},
        "parallel_groups": [asdict(g) for g in result.parallel_groups],
        "execution_order": result.execution_order,
        "total_tasks": result.total_tasks,
        "parallelizable_tasks": result.parallelizable_tasks,
        "sequential_tasks": result.sequential_tasks
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(result_dict, indent=2))

    print(f"Dependency analysis complete:")
    print(f"  Total tasks: {result.total_tasks}")
    print(f"  Parallel groups: {len(result.parallel_groups)}")
    print(f"  Parallelizable tasks: {result.parallelizable_tasks}")
    print(f"  Sequential tasks: {result.sequential_tasks}")
    print(f"  Output: {output_path}")

    return result


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Analyze task dependencies")
    parser.add_argument("--phase", help="Filter by phase")
    parser.add_argument("--output", help="Output file path")
    args = parser.parse_args()

    analyze(args.phase, args.output)


if __name__ == "__main__":
    main()
