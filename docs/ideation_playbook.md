# Ideation Playbook (Stages 0–7)

This playbook defines the ONLY approved path from raw idea to authorized execution.

Execution is forbidden until:
- Stage 6 PASSED
- Stage 7 completed
- Planning frozen

All outputs of this playbook are FILES. Chat output is not an artifact.

---

## Global Rules

- Each stage has mandatory outputs
- No samples or partial generations where completeness is required
- All acceptance criteria must be testable
- Ambiguity must be resolved before advancing
- If estimated output count is N, generate N files

Failure to follow these rules invalidates planning.

---

## Stage 0 – Idea Intake

Goal:
Capture the raw idea without solution bias.

Output:
- docs/product/idea_intake.md

Content requirements:
- problem statement
- target user
- why now
- assumptions
- constraints
- open questions

Exit criteria:
- problem clearly stated
- no solution commitments

---

## Stage 1 – Vision, Strategy, Metrics, Risks

Goal:
Define why this product should exist and how success is measured.

Outputs:
- docs/product/vision.md
- docs/product/strategy.md
- docs/product/metrics.md
- docs/product/risks.md

Exit criteria:
- coherent vision
- explicit tradeoffs
- measurable success metrics
- documented risks

---

## Stage 2 – Product Definition

Goal:
Define what the product is and is not.

Outputs:
- docs/product/definition.md
- docs/product/personas.md
- docs/product/journeys.md
- docs/product/non_goals.md

Exit criteria:
- clear scope boundaries
- explicit non-goals
- primary user journeys defined

---

## Stage 3 – Feature Discovery

Goal:
Enumerate and specify all features.

Outputs:
- specs/features/index.md
- specs/features/<feature_slug>.md (one per feature)
- specs/tests/feature_<feature_slug>_test_plan.md (for each MVP feature)

Rules:
- Each feature must include acceptance criteria
- Acceptance criteria must be testable
- MVP features MUST have Feature Test Plans

Exit criteria:
- all features enumerated
- MVP clearly identified
- no feature without testable AC

---

## Stage 4 – Architecture

Goal:
Design a system capable of delivering the features.

Outputs:
- architecture/system.md
- architecture/data.md
- architecture/security.md
- architecture/integrations.md
- architecture/decisions/ADR-XXXX-*.md

Rules:
- major decisions require ADRs
- architecture must support non-functional requirements

Exit criteria:
- all components defined
- key decisions justified

---

## Stage 5 – Implementation Planning

Goal:
Create an exhaustive, executable plan.

Outputs:
- plan/roadmap.md
- plan/phases/*.md
- plan/tasks/TASK-XXX.md (exhaustive)

Task requirements:
- scope
- dependencies
- acceptance criteria
- Test Delta

Rules:
- tasks must be atomic (1–2 days)
- if plan estimates N tasks, generate N task files
- no TODOs or placeholders

Exit criteria:
- tasks cover all MVP features
- Test Delta present for all tasks

---

## Stage 6 – Execution Readiness Check

Goal:
Verify planning completeness.

Output:
- plan/EXECUTION_READINESS.md

Checklist:
- all prior artifacts exist
- acceptance criteria testable
- Feature Test Plans exist
- tasks exhaustive and atomic

Verdict:
- PASSED or FAILED

Execution forbidden if FAILED.

---

## Stage 7 – AI Contract Finalization

Goal:
Lock planning and authorize execution.

Actions:
- finalize docs/ai.md
- create .factory/STAGE_7_COMPLETE
- create .factory/PLANNING_FROZEN

Rules:
- no planning edits after freeze without gated flows

---

## Parallel Planning (Optional)

Parallel planning is allowed ONLY if:
- outputs are independent
- quality is not compromised
- a planning coordinator reconciles outputs

If unsure, plan sequentially.

---

## Completion

When Stage 7 is complete:
- planning artifacts are frozen
- execution may begin via task runner