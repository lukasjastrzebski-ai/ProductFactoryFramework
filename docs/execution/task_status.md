# Task Status Tracker

This file provides a lightweight execution overview and supports CI enforcement.

Format:
TASK-ID | STATUS | NOTES

Where:
- STATUS is one of: NOT_STARTED, IN_PROGRESS, COMPLETE, BLOCKED

Rules:
- A task marked COMPLETE MUST have a corresponding report in:
  docs/execution/reports/TASK-ID.md
- CI will fail if a COMPLETE task has no persisted report.