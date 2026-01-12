# GitHub Wiki Structure Proposal

How to organize the factory documentation as a GitHub Wiki.

## Proposed Wiki Pages

### Home (Wiki landing page)

Content source: Main summary from README.md

Includes:
- What is the Product Factory
- Who is it for
- Core philosophy
- Quick navigation to other pages

### Getting Started

Content source: Extract from README.md and USER_GUIDE.md

Includes:
- Prerequisites
- Mental model
- Choosing your path (new vs existing project)
- Kickoff process (new projects)
- Link to Migration Guide (existing projects)
- Link to Planning Guide

### Migration Guide

Content source: docs/migration/migration_guide.md and docs/migration/README.md

For teams adopting the factory on existing codebases:
- Migration philosophy (document what exists, preserve working code)
- 5-phase migration process (Assessment, Structure, Artifacts, Quality, Activation)
- Time estimates (5-13 hours)
- Migration templates
- Troubleshooting

### Planning Guide

Content source: USER_GUIDE.md (Phase 2: Planning) and ideation_playbook.md

Includes:
- Stage-by-stage breakdown
- Mandatory outputs per stage
- Planning rules
- Planning freeze explanation

### Execution Guide

Content source: EXECUTION_GUIDE.md

Includes:
- Starting a task
- GO/NEXT protocol
- Claude Code behavior expectations
- Mandatory files per task
- Stop and escalate conditions

### Operator Cheat Sheet

Content source: docs/manuals/operator_cheat_sheet.md (can be embedded directly)

One-page quick reference for daily operation

### Factory Reference

Content source: FACTORY_REFERENCE.md

Includes:
- Authority hierarchy
- Directory responsibilities
- Marker files
- Skills overview
- CI workflows
- Signals system
- Decision engine
- Quality gates
- Templates
- Validation tools

### Change Management

Content source: docs/requests/change_request_flow.md and docs/requests/new_feature_flow.md

Includes:
- When to use Change Request
- When to use New Feature
- Required artifacts for each
- Gate approval process

### Extension Guide

Content source: EXTENSION_GUIDE.md

Includes:
- Adding skills
- Adding CI checks
- Modifying quality rules
- Adding lifecycle stages
- What not to change

### Known Limitations

Content source: KNOWN_LIMITATIONS.md

Includes:
- Manual activities
- Non-automated areas
- Structural gaps
- Assumptions
- Risk acknowledgments

### Claude Code Setup

Content source: docs/manuals/claude_code_setup.md

Includes:
- Permission configuration
- Context hygiene
- Memory safety
- GO/NEXT protocol usage

### Parallel Execution

Content source: docs/multi_agent_execution_protocol.md

For teams considering parallel agent execution

### Templates Index

Content source: Links to all templates

Quick navigation to:
- Task template
- Feature spec template
- Test plan template
- ADR template
- Report template
- All request templates

## Page Mapping

| Wiki Page | Source Documents |
|-----------|-----------------|
| Home | README.md (summary) |
| Getting Started | README.md, USER_GUIDE.md (excerpts) |
| Migration Guide | migration/migration_guide.md, migration/README.md |
| Planning Guide | USER_GUIDE.md, ideation_playbook.md |
| Execution Guide | EXECUTION_GUIDE.md |
| Operator Cheat Sheet | operator_cheat_sheet.md |
| Factory Reference | FACTORY_REFERENCE.md |
| Change Management | change_request_flow.md, new_feature_flow.md |
| Extension Guide | EXTENSION_GUIDE.md |
| Known Limitations | KNOWN_LIMITATIONS.md |
| Claude Code Setup | claude_code_setup.md |
| Parallel Execution | multi_agent_execution_protocol.md |
| Templates Index | Template file links |

## Wiki Sidebar Structure

```
Home
Getting Started
  Migration Guide (existing projects)
Planning
  Planning Guide
  Templates Index
Execution
  Execution Guide
  Operator Cheat Sheet
  Parallel Execution
Reference
  Factory Reference
  Claude Code Setup
  Change Management
Extending
  Extension Guide
  Known Limitations
```

## Maintenance Notes

- Wiki pages should link to source files in the repository for authoritative content
- When source files change, wiki pages should be updated
- Wiki is secondary to repository files (repository is authoritative)
- Consider using GitHub Wiki's built-in sync features if available
