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
