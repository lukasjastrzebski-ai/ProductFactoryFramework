# Audit Implementation Plan

**Created:** 2026-01-12
**Source:** E2E Audit Report + Video Analysis Addendum
**Status:** READY FOR REVIEW

---

## Overview

This plan addresses all findings from the 2026-01-12 audit against SDLC best practices and Dex Horthy's "No Vibes Allowed" recommendations.

**Total Tasks:** 18
**Estimated Effort:** 4-6 hours
**Priority Distribution:** 5 Critical, 6 High, 5 Medium, 2 Low

---

## Phase 1: Critical Fixes (Immediate)

### TASK-AUD-001: Fix Non-Executable Validation Scripts

**Priority:** CRITICAL
**Effort:** 5 minutes
**Source:** E2E Audit Report - Section 3.2

**Problem:**
Two validation scripts lack execute permissions, causing failures when run locally.

**Scope:**
- `tools/validate_planning_freeze.sh`
- `tools/validate_factory_links.sh`

**Implementation:**
```bash
chmod +x tools/validate_planning_freeze.sh
chmod +x tools/validate_factory_links.sh
```

**Acceptance Criteria:**
- [ ] Both scripts are executable
- [ ] `./tools/validate_planning_freeze.sh` runs without permission error
- [ ] `./tools/validate_factory_links.sh` runs without permission error

**Test Delta:**
- Run each script manually and verify execution

---

### TASK-AUD-002: Create Missing docs/product/ Directory

**Priority:** CRITICAL
**Effort:** 10 minutes
**Source:** E2E Audit Report - Section 3.3

**Problem:**
`ideation_playbook.md` references `docs/product/` for Stage 0-2 outputs, but directory doesn't exist.

**Scope:**
- Create `docs/product/` directory
- Add README explaining purpose
- Add .gitkeep for empty subdirectories

**Files to Create:**
```
docs/product/
├── README.md
└── .gitkeep
```

**Acceptance Criteria:**
- [ ] Directory exists at `docs/product/`
- [ ] README.md explains Stage 0-2 outputs go here
- [ ] Lists expected files: idea_intake.md, vision.md, strategy.md, etc.

**Test Delta:**
- Verify directory exists
- Verify README content matches ideation_playbook.md references

---

### TASK-AUD-003: Update Skill Count in Audit Report

**Priority:** CRITICAL
**Effort:** 5 minutes
**Source:** E2E Audit Report - Section 3.3

**Problem:**
`docs/audits/FACTORY_AUDIT_REPORT.md` says "Skills (10 total)" but there are 13 skills.

**Scope:**
- Line 57: Change "10 total" to "13 total"
- Line 302: Update skill range reference

**Acceptance Criteria:**
- [ ] Line 57 reads "Skills (13 total)"
- [ ] Line 302 references "skill_01 through skill_13"

**Test Delta:**
- Grep for "10 total" and "skill_10" - should not find outdated references

---

### TASK-AUD-004: Reset progress.json to Template State

**Priority:** CRITICAL
**Effort:** 5 minutes
**Source:** E2E Audit Report - Section 3.3

**Problem:**
`docs/execution/progress.json` contains sample data ("ExampleProduct", fake tasks) that may confuse users.

**Implementation:**
Reset to empty template structure:

```json
{
  "version": "1.0",
  "product": "{{PRODUCT_NAME}}",
  "updated_at": "",
  "current_phase": "",
  "features": [],
  "blockers": [],
  "metrics": {
    "tasks_completed": 0,
    "tasks_total": 0,
    "tasks_blocked": 0,
    "test_coverage": null
  }
}
```

**Acceptance Criteria:**
- [ ] No sample data in progress.json
- [ ] Contains placeholder for product name
- [ ] Empty features array
- [ ] Zero counters

**Test Delta:**
- Validate JSON syntax
- Verify no "ExampleProduct" or "TASK-001" references

---

### TASK-AUD-005: Fix RUN_MODE Placeholder

**Priority:** CRITICAL
**Effort:** 5 minutes
**Source:** E2E Audit Report - Section 3.3

**Problem:**
`.factory/RUN_MODE` contains literal "PLANNING | EXECUTION" instead of actual state.

**Implementation:**
Set to "PLANNING" (default for template):

```
PLANNING
```

**Acceptance Criteria:**
- [ ] RUN_MODE contains single value "PLANNING"
- [ ] No pipe character or multiple values

**Test Delta:**
- `cat .factory/RUN_MODE` outputs "PLANNING"

---

## Phase 2: Context Engineering Enhancements (High Priority)

### TASK-AUD-006: Add Context Engineering Section to CLAUDE.md

**Priority:** HIGH
**Effort:** 20 minutes
**Source:** Video Analysis Addendum - Priority 1

**Problem:**
CLAUDE.md lacks guidance on context window management, trajectory hygiene, and compaction.

**Scope:**
Add new section after "Context Hygiene":

```markdown
## Context Engineering

### The "Dumb Zone"
LLM performance degrades significantly around 40% context capacity. For complex tasks:
- Monitor context usage
- Use /clear proactively at ~40%, not reactively at 90%
- Complex tasks require more headroom than simple ones

### Trajectory Management
If Claude makes repeated mistakes:
1. STOP corrections immediately (they poison context)
2. Document what went wrong in a temp file
3. Use /clear to start fresh
4. Resume with explicit "avoid X" guidance

Repeated corrections teach the model to fail. Fresh context beats poisoned context.

### Mid-Task Compaction
For long-running tasks:
1. Ask Claude to summarize current progress
2. Save summary to `.factory/session_context.md`
3. Use /clear
4. Re-read CLAUDE.md, state.md, and the summary
5. Continue from summary

### Sub-agents for Context Control
When using Task tool or parallel agents:
- Research agents: Find files, return paths only
- Analysis agents: Understand flow, return summary
- Keep parent context clean for implementation
```

**Acceptance Criteria:**
- [ ] "Context Engineering" section exists in CLAUDE.md
- [ ] Covers Dumb Zone, Trajectory, Compaction, Sub-agents
- [ ] Actionable guidance with numbered steps

**Test Delta:**
- Review CLAUDE.md for new section
- Verify no placeholder text

---

### TASK-AUD-007: Create Skill 14 - Codebase Research

**Priority:** HIGH
**Effort:** 30 minutes
**Source:** Video Analysis Addendum - Priority 2

**Problem:**
Factory lacks on-demand research skill for existing code. Skills 11-13 handle external docs only.

**File:** `docs/skills/skill_14_codebase_research.md`

**Content:**
```markdown
# Skill 14: Codebase Research

## Purpose
Generate fresh, on-demand research for complex tasks before implementation.
Addresses spec-to-code drift in long-running products.

## When to Use
- Before complex tasks ([COMPLEX] marker)
- When task touches unfamiliar modules
- When specs may be outdated
- When PO requests "research first"

## Inputs
- Task file with scope
- Relevant module paths
- Specific questions to answer

## Process
1) Identify target modules from task scope
2) Run targeted searches:
   - Grep for key functions/classes
   - Read entry points
   - Trace data flow
3) Generate research document:
   - Current code structure
   - Key files and line numbers
   - Discovered patterns
   - Potential conflicts with spec
4) Compare with planning artifacts:
   - Does spec match implementation?
   - Are there undocumented behaviors?
5) Flag discrepancies to PO

## Output
- `docs/execution/research/TASK-XXX-research.md`

## Rules
- Research is READ-ONLY - no code changes
- Flag all spec drift to PO
- Keep research concise (aim for <500 lines)
- Research does not authorize implementation
```

**Acceptance Criteria:**
- [ ] File exists at `docs/skills/skill_14_codebase_research.md`
- [ ] Follows skill template format
- [ ] Includes research document template
- [ ] References spec drift detection

**Test Delta:**
- Validate markdown syntax
- Verify skill index updated

---

### TASK-AUD-008: Update Skills README with Skill 14

**Priority:** HIGH
**Effort:** 5 minutes
**Source:** Depends on TASK-AUD-007

**Scope:**
Update `docs/skills/README.md` to include Skill 14.

**Acceptance Criteria:**
- [ ] Skill 14 listed in README
- [ ] Link to skill_14_codebase_research.md works

**Test Delta:**
- Verify link resolves

---

### TASK-AUD-009: Create Context Compaction Pattern

**Priority:** HIGH
**Effort:** 20 minutes
**Source:** Video Analysis Addendum - Priority 3

**File:** `docs/patterns/context_compaction.md`

**Content:**
```markdown
# Context Compaction Pattern

## Purpose
Manage context window size during long sessions to maintain AI performance.

## The Problem
LLM performance degrades as context fills:
- ~40% capacity: Diminishing returns begin
- ~70% capacity: Significant degradation
- ~90% capacity: Severe issues, hallucinations increase

## Solution: Intentional Compaction

### When to Compact
1. Context reaches ~40% for complex tasks
2. After completing a logical unit of work
3. When Claude makes repeated mistakes
4. Before starting a new task type

### How to Compact

#### Option 1: Summary File
Ask Claude to summarize progress to .factory/session_context.md
Then: /clear and resume with the summary.

#### Option 2: Task Report Compaction
Create interim reports: docs/execution/reports/TASK-XXX-interim-1.md

#### Option 3: Research Compaction
Use Skill 14 for investigation work.

### Anti-Patterns
- Continuing in a full context window
- Repeated corrections without clearing
- Keeping failed attempts in context
- Not saving progress before /clear
```

**Acceptance Criteria:**
- [ ] File exists at `docs/patterns/context_compaction.md`
- [ ] Covers when, how, and anti-patterns
- [ ] Integrates with existing factory patterns

**Test Delta:**
- Validate markdown syntax

---

### TASK-AUD-010: Create Trajectory Management Pattern

**Priority:** HIGH
**Effort:** 15 minutes
**Source:** Video Analysis Addendum - Priority 3

**File:** `docs/patterns/trajectory_management.md`

**Content:**
```markdown
# Trajectory Management Pattern

## Purpose
Avoid context poisoning from repeated corrections.

## The Problem
When you correct an AI repeatedly:
1. AI does X wrong → You correct it
2. AI does Y wrong → You correct it
3. AI sees: "I fail → human corrects" pattern
4. AI learns: next action should be a failure

This is **trajectory poisoning**.

## Solution: Fresh Start Protocol

### Detection
You need a fresh start if:
- 3+ corrections in a row
- Claude apologizes repeatedly
- Same mistake appears twice
- You're frustrated

### Protocol
1. **STOP** - Do not correct again
2. **DOCUMENT** - Write what went wrong
3. **CLEAR** - Use /clear command
4. **RESTART** - Begin with explicit anti-guidance

### Prevention
- Review plans before GO (catch issues early)
- Use Skill 14 research for unfamiliar code
- Break complex tasks into smaller ones
- Request "think hard" for architectural decisions
```

**Acceptance Criteria:**
- [ ] File exists at `docs/patterns/trajectory_management.md`
- [ ] Includes detection criteria
- [ ] Provides step-by-step protocol

**Test Delta:**
- Validate markdown syntax

---

### TASK-AUD-011: Add Sub-agents Section to Multi-Agent Protocol

**Priority:** HIGH
**Effort:** 10 minutes
**Source:** Video Analysis Addendum - Section 4

**Scope:**
Add section to `docs/multi_agent_execution_protocol.md` about using sub-agents for context control.

**Content to Add:**
```markdown
## Sub-agents for Context Control

Beyond parallel execution, sub-agents serve a critical role in **context management**.

### Purpose
Keep parent context clean by delegating search/analysis to disposable sub-contexts.

### Use Cases

#### Research Sub-agent
Parent: "Find where user authentication is implemented"
Sub-agent: Searches codebase, reads files, traces flow
Returns: "Authentication in src/auth/: login.ts:45-120"
Parent: Reads only those specific lines

#### Analysis Sub-agent
Parent: "Understand how the payment flow works"
Sub-agent: Reads multiple files, builds mental model
Returns: "Payment flow: Cart→Checkout→Payment→Confirmation"
Parent: Has compressed understanding without context bloat

### Rules
- Sub-agents return **summaries**, not raw data
- Parent context stays clean for implementation
- Use for any investigation that would fill >20% context
```

**Acceptance Criteria:**
- [ ] Section added to multi_agent_execution_protocol.md
- [ ] Covers research and analysis use cases
- [ ] Includes rules

**Test Delta:**
- Review updated document

---

## Phase 3: Documentation Updates (Medium Priority)

### TASK-AUD-012: Document EXTENSION_ACTIVE Flag

**Priority:** MEDIUM
**Effort:** 15 minutes
**Source:** E2E Audit Report - Section 3.3

**Problem:**
`.factory/EXTENSION_ACTIVE` exists but is not documented.

**Scope:**
1. Determine purpose of flag
2. Document in .factory/README.md

**Acceptance Criteria:**
- [ ] EXTENSION_ACTIVE purpose documented
- [ ] Documentation explains when flag is set/cleared

**Test Delta:**
- Grep for EXTENSION_ACTIVE references

---

### TASK-AUD-013: Add Skill Reference Table to CLAUDE.md

**Priority:** MEDIUM
**Effort:** 10 minutes
**Source:** E2E Audit Report - Section 1.3

**Scope:**
Add quick reference table for all 14 skills.

**Content:**
```markdown
## Skill Reference

| # | Skill | Use When |
|---|-------|----------|
| 01 | Context Loader | Session start |
| 02 | Task Intake | Starting a task |
| 03 | Test Alignment | Before implementation |
| 04 | Implementation | During coding |
| 05 | Run Checks | After coding |
| 06 | Write Report | Task completion |
| 07 | Update State | After report |
| 08 | Next Task Recommendation | After NEXT gate |
| 09 | CR/NF Router | Scope change detected |
| 10 | Signal Snapshot | Decision needed |
| 11 | External Doc Import | Importing from tools |
| 12 | Gap Analysis | Validating completeness |
| 13 | Gap Resolution | Resolving planning gaps |
| 14 | Codebase Research | Before complex tasks |

Full documentation: `docs/skills/`
```

**Acceptance Criteria:**
- [ ] Skill table added to CLAUDE.md
- [ ] All 14 skills listed

**Test Delta:**
- Verify table renders correctly

---

### TASK-AUD-014: Add PR Documentation Guidance

**Priority:** MEDIUM
**Effort:** 10 minutes
**Source:** Video Analysis Addendum - Section 5

**File:** `docs/execution/pr_documentation.md`

**Content:**
PR documentation guidance for AI-assisted development including:
- Task reference links
- Report reference links
- Test Delta summary
- Template for PR descriptions

**Acceptance Criteria:**
- [ ] PR documentation guidance exists
- [ ] Includes template
- [ ] Referenced from execution docs

**Test Delta:**
- Validate markdown syntax

---

### TASK-AUD-015: Improve CI Report Parsing

**Priority:** MEDIUM
**Effort:** 30 minutes
**Source:** E2E Audit Report - Section 3.2

**Problem:**
`factory-guardrails.yml:131` uses `grep -v "^|"` which may exclude valid markdown table rows.

**Scope:**
Improve parsing logic to handle markdown tables correctly.

**Acceptance Criteria:**
- [ ] CI correctly parses task_status.md
- [ ] Markdown tables don't cause false negatives

**Test Delta:**
- Create test task_status.md with tables
- Run workflow validation locally

---

### TASK-AUD-016: Create .factory/README.md

**Priority:** MEDIUM
**Effort:** 15 minutes
**Source:** E2E Audit Report

**Problem:**
`.factory/` directory has multiple marker files without central documentation.

**Content:**
Document all marker files: KICKOFF_COMPLETE, STAGE_7_COMPLETE, PLANNING_FROZEN, RUN_MODE, LAST_KNOWN_GOOD_SHA, factory_version.txt, EXTENSION_ACTIVE

**Acceptance Criteria:**
- [ ] README.md exists in .factory/
- [ ] All current marker files documented

**Test Delta:**
- Verify all actual files are documented

---

## Phase 4: Low Priority Enhancements

### TASK-AUD-017: Consider Making Report Signing Mandatory

**Priority:** LOW
**Effort:** 10 minutes
**Source:** E2E Audit Report - Section 3.3

**Scope:**
Evaluate whether to make report signing mandatory in CI.

**Decision (2026-01-12):** KEEP OPTIONAL for v10.2

**Rationale:**
- Report signing adds friction for new users
- Not all teams require cryptographic audit trails
- Optional signing still provides capability for regulated environments
- Can be enabled per-project by removing `continue-on-error: true`

**Future Consideration:**
- Revisit for v11 based on user feedback
- Consider making mandatory only for EXECUTION mode

**Acceptance Criteria:**
- [x] Decision documented

---

### TASK-AUD-018: Create docs/execution/research/ Directory

**Priority:** LOW
**Effort:** 5 minutes
**Source:** TASK-AUD-007 dependency

**Implementation:**
```bash
mkdir -p docs/execution/research
touch docs/execution/research/.gitkeep
```

**Acceptance Criteria:**
- [ ] Directory exists
- [ ] .gitkeep present

---

## Implementation Order

### Wave 1: Critical Fixes (~30 min)
1. TASK-AUD-001 (script permissions)
2. TASK-AUD-002 (docs/product/)
3. TASK-AUD-003 (skill count)
4. TASK-AUD-004 (progress.json)
5. TASK-AUD-005 (RUN_MODE)

### Wave 2: Context Engineering (~2 hours)
6. TASK-AUD-006 (CLAUDE.md context section)
7. TASK-AUD-007 (Skill 14)
8. TASK-AUD-008 (Skills README)
9. TASK-AUD-009 (compaction pattern)
10. TASK-AUD-010 (trajectory pattern)
11. TASK-AUD-011 (sub-agents section)

### Wave 3: Documentation (~1.5 hours)
12. TASK-AUD-012 (EXTENSION_ACTIVE)
13. TASK-AUD-013 (skill table)
14. TASK-AUD-014 (PR docs)
15. TASK-AUD-015 (CI parsing)
16. TASK-AUD-016 (.factory README)

### Wave 4: Optional (Backlog)
17. TASK-AUD-017 (signing decision)
18. TASK-AUD-018 (research directory)

---

## Success Criteria

After implementation:
- [ ] All CRITICAL and HIGH tasks complete
- [ ] CLAUDE.md includes context engineering guidance
- [ ] Skill 14 documented and referenced
- [ ] No placeholder data in template files
- [ ] All scripts executable
- [ ] New patterns documented

## Version Target

These changes target **v10.2** release.

---

*Plan created 2026-01-12 based on E2E Audit findings*
