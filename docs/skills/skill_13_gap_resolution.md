# Skill 13 – Gap Resolution

Purpose:
Guide Product Owner through iterative resolution of documentation gaps identified by gap analysis.

## Invocation

Triggered when PO says:
- "Help me resolve the planning gaps"
- "Fill in the gaps"
- "Complete the planning"
- "Resolve gaps"

## Prerequisites

- Gap analysis has been run (`./scripts/import/analyze_gaps.sh`)
- Gap report exists at `docs/import/validation/gap_analysis.md`

## Protocol

### Step 1: Load Gap Report

```
Read: docs/import/validation/gap_analysis.md
Read: docs/import/validation/resolution_progress.json (if exists)
```

### Step 2: Present Gap Summary

Present gaps grouped by severity:

```markdown
## Gap Resolution Status

**Progress:** X of Y gaps resolved

### Remaining Gaps

🔴 BLOCKING (must resolve):
1. [gap-id]: [brief description]

🟠 HIGH (should resolve):
1. [gap-id]: [brief description]

🟡 MEDIUM (recommended):
1. [gap-id]: [brief description]

Shall I walk through each gap, starting with BLOCKING?
```

### Step 3: Iterate Through Gaps

For each gap (BLOCKING first, then HIGH, MEDIUM, LOW):

1. **Present the gap clearly:**
   ```markdown
   ### Gap: [gap-id]

   **What's missing:** [description]

   **Why it matters:** [factory requirement explanation]

   **Question:** [specific, answerable question]

   **Examples of good answers:**
   - [example 1]
   - [example 2]
   ```

2. **Wait for PO response**

3. **Validate response:**
   - Is it specific enough?
   - Does it answer the question?
   - Is it actionable for factory artifacts?

4. **If unclear, ask follow-up:**
   ```markdown
   Thanks! To make this actionable, I need a bit more detail:
   - [specific follow-up question]
   ```

5. **When clear, confirm and generate artifact:**
   ```markdown
   Got it! I'll create:
   - [artifact path] with [content summary]

   Proceeding to next gap...
   ```

### Step 4: Generate Artifacts

Map PO responses to factory artifacts:

| Gap Type | Generated Artifact |
|----------|-------------------|
| vision | docs/product/vision.md |
| strategy | docs/product/strategy.md |
| metrics | docs/product/metrics.md |
| risks | docs/product/risks.md |
| personas | docs/product/personas.md |
| journeys | docs/product/journeys.md |
| features | specs/features/FEAT-XXX.md |
| acceptance_criteria | Updated specs/features/*.md |
| tech_stack | architecture/system.md |
| decisions | architecture/decisions/ADR-XXX.md |
| tasks | plan/tasks/TASK-XXX.md |
| mvp_scope | docs/product/mvp.md |

### Step 5: Update Progress

After each resolution, update `docs/import/validation/resolution_progress.json`:

```json
{
  "total_gaps": 12,
  "resolved": 5,
  "skipped": 1,
  "remaining": 6,
  "last_updated": "2024-01-15T10:30:00Z",
  "resolutions": [
    {
      "gap_id": "vision",
      "status": "resolved",
      "artifact": "docs/product/vision.md",
      "resolved_at": "2024-01-15T10:15:00Z"
    },
    {
      "gap_id": "risks",
      "status": "skipped",
      "reason": "Internal tool, minimal risk",
      "skipped_at": "2024-01-15T10:20:00Z"
    }
  ]
}
```

### Step 6: Completion Check

When all BLOCKING gaps resolved:

```markdown
## All Blocking Gaps Resolved!

**Summary:**
- Resolved: X gaps
- Skipped: Y gaps (with justification)
- Remaining optional: Z gaps

**Artifacts Created:**
- docs/product/vision.md
- specs/features/FEAT-001.md
- [etc.]

**Next Steps:**
1. Review generated artifacts
2. Resolve remaining HIGH/MEDIUM gaps (recommended)
3. Run execution readiness check

Shall I:
A) Continue with HIGH priority gaps
B) Run execution readiness check
C) Show summary of all artifacts created
```

## PO Commands

| Command | Action |
|---------|--------|
| `FILL: [gap-id] [content]` | Provide content for gap |
| `SKIP: [gap-id] [reason]` | Skip gap (must justify) |
| `BACK` | Return to previous gap |
| `STATUS` | Show resolution progress |
| `SHOW: [gap-id]` | Show details of specific gap |
| `PROCEED` | Attempt to proceed |
| `ARTIFACTS` | List generated artifacts |
| `HELP` | Show available commands |

## Validation Rules

### Content Requirements

- **Vision**: Must include problem statement and target user
- **Features**: Must have name, description, and at least 2 acceptance criteria
- **Acceptance Criteria**: Must be testable (checkbox format: `- [ ] User can...`)
- **Tech Stack**: Should include version info when possible
- **Personas**: Must include name, context, needs, and goals

### Skip Rules

- BLOCKING gaps cannot be skipped without exceptional justification
- HIGH gaps can be skipped with documented reason
- MEDIUM/LOW gaps can be freely skipped
- All skips are recorded with justification

## Example Interaction

```
Claude: Let me check your gap analysis report...

## Gap Resolution Status

**Progress:** 0 of 8 gaps resolved

### Remaining Gaps

🔴 BLOCKING (must resolve):
1. features: No feature specifications found

🟠 HIGH (should resolve):
1. strategy: Product strategy not found
2. metrics: Success metrics not defined
3. personas: User personas not defined
4. mvp_scope: MVP scope not identified

🟡 MEDIUM (recommended):
1. risks: Risk assessment not found
2. journeys: User journeys not mapped
3. decisions: Architecture decisions not documented

Let's start with the BLOCKING gap.

---

### Gap: features

**What's missing:** No feature specifications found in imported documentation

**Why it matters:** Features are the core of your product specification. Without them, we cannot create implementation tasks or test plans.

**Question:** What features will this product include? Please list all features with descriptions.

**Example of a good answer:**
1. User Authentication - Allow users to sign up, log in, and manage their accounts
2. Dashboard - Display real-time deployment status across all environments
3. Rollback - Enable one-click rollback to previous deployments

PO: The product will have:
1. Real-time Dashboard - Shows deployment status for all environments
2. Deployment History - View past deployments with details
3. Rollback - One-click rollback with confirmation
4. Notifications - Alerts for deployment failures

Claude: Great! For each feature, I need acceptance criteria. Let's start with "Real-time Dashboard":

What are the testable acceptance criteria for the Dashboard feature?

**Example format:**
- [ ] Dashboard loads within 2 seconds
- [ ] Status updates appear within 5 seconds of change

PO:
- [ ] Dashboard shows all active deployments
- [ ] Each deployment shows: name, environment, status, timestamp
- [ ] Status updates in real-time (< 5 second delay)
- [ ] User can filter by environment

Claude: Got it! I'll create:
- specs/features/FEAT-001-dashboard.md

Moving to next feature: Deployment History...
```

## Output

- Factory artifacts in appropriate locations
- Updated resolution_progress.json
- Completion report when done

## Rules

- Never expand scope beyond identified gaps
- Never bypass GO/NEXT protocol
- Always validate PO responses before generating artifacts
- Always update progress tracking after each resolution
- Stop if PO requests to pause or has questions
