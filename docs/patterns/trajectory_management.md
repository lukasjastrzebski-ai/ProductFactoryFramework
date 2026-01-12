# Trajectory Management Pattern

## Purpose

Avoid context poisoning from repeated corrections.

Based on research by Dex Horthy (HumanLayer) - "No Vibes Allowed" presentation.

## The Problem

When you correct an AI repeatedly, a pattern emerges:

1. AI does X wrong
2. You correct it: "No, do Y instead"
3. AI does Y wrong
4. You correct it: "That's still wrong, try Z"
5. AI sees: "I fail → human corrects → I fail → human corrects"
6. **AI learns: next action should be a failure**

This is **trajectory poisoning**. The correction history becomes training data that teaches the model to fail.

## Detection

You need a fresh start if ANY of these are true:

| Signal | Indication |
|--------|------------|
| 3+ corrections in a row | Pattern established |
| Claude apologizes repeatedly | Model recognizes failure pattern |
| Same mistake appears twice | Not learning from corrections |
| You feel frustrated | Human signal of degraded interaction |
| Claude suggests increasingly unlikely solutions | Grasping at straws |

## Solution: Fresh Start Protocol

### Step 1: STOP

Do NOT correct again. Each additional correction makes it worse.

### Step 2: DOCUMENT

Write what went wrong to a file:

```markdown
# .factory/anti_patterns/TASK-XXX-failed-approach.md

## Context
Task: [task description]
Date: [date]

## What Failed
- Approach attempted: [description]
- Why it failed: [specific reason]
- Symptoms: [what went wrong]

## Avoid
- Do NOT: [specific thing to avoid]
- Do NOT: [another thing to avoid]

## Instead
- DO: [correct approach]
- Consider: [alternative]
```

### Step 3: CLEAR

Use `/clear` to reset context window.

### Step 4: RESTART

Begin with explicit anti-guidance:

```
Resume TASK-XXX.

IMPORTANT CONTEXT:
- Read .factory/anti_patterns/TASK-XXX-failed-approach.md first
- Do NOT [specific thing that failed]
- Instead, [correct approach]

Start by confirming you understand the constraints.
```

## Prevention

Better to prevent than recover:

| Strategy | How |
|----------|-----|
| Review plans before GO | Catch issues before implementation |
| Use Skill 14 research | Understand code before changing it |
| Break complex tasks | Smaller scope = fewer errors |
| Request "think hard" | Better reasoning for hard problems |
| Clear scope boundaries | Ambiguity causes mistakes |

## Integration with Factory

### Failed approaches become lessons

If a pattern repeats across tasks:
1. Create `docs/factory/lessons/LL-XXX.md`
2. Document the anti-pattern
3. Add to relevant skill guidance

### Route to CR if needed

If the failure reveals spec ambiguity:
1. STOP
2. Route to Change Request flow
3. Clarify spec before resuming

### Update task file

Add anti-pattern note to task file for future reference:

```markdown
## Known Pitfalls
- Do not attempt [approach] - see .factory/anti_patterns/TASK-XXX.md
```

## Example

### Bad Trajectory

```
Human: Implement user login
Claude: [implements with session tokens]
Human: No, use JWT
Claude: [implements JWT wrong]
Human: The expiry is wrong
Claude: [fixes expiry, breaks refresh]
Human: Now refresh is broken
Claude: [apologizes, tries another approach]
... context poisoned ...
```

### Good Recovery

```
Human: Implement user login
Claude: [implements with session tokens]
Human: No, use JWT
Claude: [implements JWT wrong]
Human: [STOPS - recognizes pattern forming]