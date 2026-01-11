# Multi-Agent Execution Protocol (Quality-First)

Default mode is single-agent execution. Parallelism is optional and risky.

Parallel work is allowed only if it reduces time without increasing rework risk.
If you cannot prove safety, do not parallelize.

## Preconditions for parallel execution
All must be true:
- Work can be split into independent slices with minimal shared files.
- Interfaces and acceptance criteria are defined before coding starts.
- One Integrator agent owns merges and correctness.
- One QA reviewer agent performs adversarial checks against specs and test plans.
- Each slice is small (target 0.5 to 2 days of work).
- A written parallel plan exists under docs/execution/parallel/.

If any condition fails, run single-agent.

## Required artifact: Parallel plan
Create:
- docs/execution/parallel/PRL-YYYYMMDD-<slug>.md

It must include:
- Goal
- Slice list and boundaries
- File ownership per slice
- Interfaces and contracts
- Acceptance criteria per slice
- Test requirements per slice
- Merge and integration checklist
- Rollback plan if integration fails

No parallel plan, no parallel execution.

## Roles

Integrator (single authority for merges):
- decomposes work into slices
- assigns slices to agents
- enforces file ownership boundaries
- resolves conflicts
- runs full test suites
- writes integration report

Contributor agents:
- implement only their assigned slice
- do not change specs or scope
- write slice report and list tests executed
- do not merge to main

QA reviewer:
- validates each slice against:
  - feature specs
  - acceptance criteria
  - Feature Test Plans
  - task Test Delta
- blocks merges if:
  - tests missing
  - acceptance criteria not verified
  - scope drift detected
  - regressions introduced

## Process

1) Integrator writes the parallel plan.
2) Contributors execute slices and produce slice reports:
   - docs/execution/reports/SLICE-<name>-YYYYMMDD.md (or a task report if slice maps to a task)
3) QA reviews slice outputs and approves or blocks.
4) Integrator merges slices in a controlled order.
5) Integrator runs full regression suites and updates execution state.
6) Integrator writes an integration report:
   - docs/execution/reports/PRL-YYYYMMDD-<slug>-integration.md

## Conflict and drift policy
- If two slices need to edit the same file, you do not parallelize unless file ownership can be partitioned cleanly.
- If interfaces are not stable, do not parallelize.
- If the work reveals a scope change, stop and route to CR/New Feature flows.

## Minimum quality bar
Parallel execution does not reduce quality requirements.
All standard rules still apply:
- GO gate per task or slice
- persisted reports
- tests executed and recorded
- state updated

## When to stop parallelism
Stop and return to single-agent if:
- repeated merge conflicts
- unclear ownership
- failing tests with unclear cause
- QA cannot verify acceptance criteria

Parallelism is a tool, not a goal.

## Git Worktrees for Parallel Execution

Git worktrees provide isolated working directories for each agent, eliminating merge conflicts during active development.

### When to use worktrees
- Multiple agents working on different slices simultaneously
- Long-running tasks that would block other work
- Testing changes in isolation before integration

### Creating worktrees

```bash
# From main repository, create a worktree for each agent
git worktree add ../worktrees/contributor-TASK-001 main
git worktree add ../worktrees/contributor-TASK-002 main
git worktree add ../worktrees/integrator main
```

### Naming convention
```
worktrees/<ROLE>-<TASK_ID>/
```

Examples:
- `worktrees/contributor-TASK-001/`
- `worktrees/integrator/`
- `worktrees/qa-review/`

### Integrator workflow with worktrees

1. Contributors work in their own worktrees, committing to feature branches
2. Integrator pulls feature branches into integrator worktree
3. Integrator runs full test suite in integrator worktree
4. Integrator merges to main only after all tests pass

```bash
# In integrator worktree
git fetch origin
git merge origin/feature/TASK-001
git merge origin/feature/TASK-002
pnpm test  # Run full suite
git push origin main  # Only after tests pass
```

### Cleanup

After parallel execution completes:
```bash
# Remove worktrees
git worktree remove ../worktrees/contributor-TASK-001
git worktree remove ../worktrees/contributor-TASK-002
git worktree remove ../worktrees/integrator

# Prune stale worktree references
git worktree prune
```

### Worktree rules
- Each worktree must be on a separate branch (cannot share branches)
- Do not delete the main repository while worktrees exist
- Worktrees share the same Git object database (space efficient)
- Always clean up worktrees after parallel execution ends
