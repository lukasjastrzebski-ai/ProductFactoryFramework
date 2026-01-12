# Context Compaction Pattern

## Purpose

Manage context window size during long sessions to maintain AI performance.

Based on research by Dex Horthy (HumanLayer) - "No Vibes Allowed" presentation.

## The Problem

LLM performance degrades as context fills:
- ~40% capacity: Diminishing returns begin
- ~70% capacity: Significant degradation
- ~90% capacity: Severe issues, hallucinations increase

This is called working in the **"Dumb Zone"**.

## Solution: Intentional Compaction

### When to Compact

1. **Context reaches ~40%** for complex tasks
2. **After completing a logical unit** of work
3. **When Claude makes repeated mistakes** (trajectory poisoning)
4. **Before starting a new task type**

### How to Compact

#### Option 1: Summary File (Recommended)

Ask Claude to summarize progress:

```
Please summarize our current progress into a compact markdown file.
Include:
- What we've accomplished
- Current state of the work
- Next steps planned
- Any blockers or concerns
- Key decisions made

Save to .factory/session_context.md
```

Then:
1. Use `/clear`
2. Resume with: "Continue from .factory/session_context.md"

#### Option 2: Task Report Compaction

For multi-step tasks, create interim reports:
- `docs/execution/reports/TASK-XXX-interim-1.md`
- Contains progress, decisions, remaining work
- Allows clean context restart

#### Option 3: Research Compaction

For investigation work, use Skill 14:
- `docs/execution/research/TASK-XXX-research.md`
- Compressed findings, not raw search results
- Ready for implementation phase

### What to Compact

| Include | Exclude |
|---------|---------|
| Key findings | Raw file contents |
| File paths and line numbers | Full grep output |
| Decisions made | Failed approaches (unless lessons) |
| Next steps | Verbose explanations |
| Blockers | Repeated context |

### Anti-Patterns

- **Continuing in a full context window** - Performance degrades
- **Repeated corrections without clearing** - Trajectory poisoning
- **Keeping failed attempts in context** - Model learns failure
- **Not saving progress before /clear** - Work lost
- **Over-compacting** - Losing necessary context

## Integration with Factory

| Factory Mechanism | Compaction Role |
|-------------------|-----------------|
| Task Reports | Post-task compaction (already implemented) |
| state.md | Persistent session state |
| progress.json | Structured progress tracking |
| Session context file | Mid-task compaction |
| Skill 14 research | Research phase compaction |

## Example Workflow

```
Start Task
    ↓
[Work for a while]
    ↓
Context at 35%? → Continue working
    ↓
Context at 45%? → Compact now
    ↓
Save to .factory/session_context.md
    ↓
/clear
    ↓
Resume from summary
    ↓
Continue to completion
```

## Measuring Context Usage

Claude Code shows context usage. Watch for:
- Yellow indicator: Consider compacting soon
- Red indicator: Compact immediately

When in doubt, compact earlier rather than later.
