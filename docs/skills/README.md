# Claude Skills

Claude Skills are structured operating procedures used during execution.
They do NOT replace the Task Runner or execution rules.
They are invoked internally by Claude to stay disciplined.

Rules:
- Skills never expand scope
- Skills never bypass GO/NEXT
- Skills never override files

If a skill conflicts with docs/ai.md or task_runner.md, the skill is wrong.