#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
REPORT="$ROOT/factory_reorg_report.txt"
: > "$REPORT"

log() { echo "$1" | tee -a "$REPORT"; }

mkdirp() {
  mkdir -p "$1"
}

copy_if_exists() {
  local src="$1"
  local dst="$2"
  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dst")"
    cp -f "$src" "$dst"
    log "COPIED file: $src -> $dst"
  else
    log "SKIP missing file: $src"
  fi
}

copy_dir_if_exists() {
  local src="$1"
  local dst="$2"
  if [ -d "$src" ]; then
    mkdir -p "$dst"
    cp -R "$src"/. "$dst"/
    log "COPIED dir: $src -> $dst"
  else
    log "SKIP missing dir: $src"
  fi
}

unzip_if_exists() {
  local zip="$1"
  local dst="$2"
  if [ -f "$zip" ]; then
    mkdir -p "$dst"
    unzip -o "$zip" -d "$dst" >/dev/null
    log "UNZIPPED: $zip -> $dst"
  else
    log "SKIP missing zip: $zip"
  fi
}

log "Factory reorg started at $(date -u)"
log "ROOT: $ROOT"

# -----------------------------
# Create directory skeleton
# -----------------------------
mkdirp "$ROOT/.factory"
mkdirp "$ROOT/00_bootstrap/template_docs"
mkdirp "$ROOT/docs/manuals"
mkdirp "$ROOT/docs/factory/lessons"
mkdirp "$ROOT/docs/execution/parallel"
mkdirp "$ROOT/docs/execution/reports"
mkdirp "$ROOT/docs/requests/templates"
mkdirp "$ROOT/docs/testing"
mkdirp "$ROOT/docs/quality"
mkdirp "$ROOT/docs/signals"
mkdirp "$ROOT/docs/decision_engine"
mkdirp "$ROOT/docs/memory"
mkdirp "$ROOT/docs/skills"
mkdirp "$ROOT/specs/_templates"
mkdirp "$ROOT/specs/features"
mkdirp "$ROOT/specs/tests"
mkdirp "$ROOT/architecture/decisions"
mkdirp "$ROOT/plan/phases"
mkdirp "$ROOT/plan/tasks"
mkdirp "$ROOT/scripts/signals"
mkdirp "$ROOT/signals"
mkdirp "$ROOT/.github/workflows"
mkdirp "$ROOT/tools"

# -----------------------------
# Top-level files
# -----------------------------
copy_if_exists "$ROOT/FACTORY_VERSION" "$ROOT/FACTORY_VERSION"
copy_if_exists "$ROOT/README.md" "$ROOT/README.md"
copy_if_exists "$ROOT/CHANGELOG.md" "$ROOT/CHANGELOG.md"

# If you have Factory-README.md, keep it as docs-only reference
if [ -f "$ROOT/Factory-README.md" ]; then
  copy_if_exists "$ROOT/Factory-README.md" "$ROOT/docs/factory/Factory-README.md"
fi

# -----------------------------
# Bootstrap
# -----------------------------
copy_if_exists "$ROOT/KickoffPrompt.md" "$ROOT/00_bootstrap/KickoffPrompt.md"
copy_if_exists "$ROOT/ClaudeBootstrapPrompt.md" "$ROOT/00_bootstrap/ClaudeBootstrapPrompt.md"
copy_if_exists "$ROOT/template_init.md" "$ROOT/00_bootstrap/template_docs/template_init.md"
copy_if_exists "$ROOT/runbook.md" "$ROOT/00_bootstrap/template_docs/runbook.md"

# -----------------------------
# Core docs
# -----------------------------
copy_if_exists "$ROOT/ai.md" "$ROOT/docs/ai.md"
copy_if_exists "$ROOT/ideation_playbook.md" "$ROOT/docs/ideation_playbook.md"
copy_if_exists "$ROOT/multi_agent_execution_protocol.md" "$ROOT/docs/multi_agent_execution_protocol.md"

# -----------------------------
# Manuals
# -----------------------------
copy_if_exists "$ROOT/new_user_manual.md" "$ROOT/docs/manuals/new_user_manual.md"
copy_if_exists "$ROOT/implementation_control_manual.md" "$ROOT/docs/manuals/implementation_control_manual.md"
copy_if_exists "$ROOT/operator_cheat_sheet.md" "$ROOT/docs/manuals/operator_cheat_sheet.md"

# -----------------------------
# Factory docs
# -----------------------------
copy_if_exists "$ROOT/factory_versioning.md" "$ROOT/docs/factory/factory_versioning.md"
copy_if_exists "$ROOT/planning_freeze.md" "$ROOT/docs/factory/planning_freeze.md"
copy_if_exists "$ROOT/lessons_learned.md" "$ROOT/docs/factory/lessons_learned.md"
copy_if_exists "$ROOT/lessons_README.md" "$ROOT/docs/factory/lessons/README.md"
copy_if_exists "$ROOT/LL-TEMPLATE.md" "$ROOT/docs/factory/lessons/LL-TEMPLATE.md"

# -----------------------------
# Execution docs
# -----------------------------
copy_if_exists "$ROOT/execution_playbook.md" "$ROOT/docs/execution/execution_playbook.md"
copy_if_exists "$ROOT/task_runner.md" "$ROOT/docs/execution/task_runner.md"
copy_if_exists "$ROOT/task_report_template.md" "$ROOT/docs/execution/task_report_template.md"
copy_if_exists "$ROOT/task_status.md" "$ROOT/docs/execution/task_status.md"
copy_if_exists "$ROOT/state.md" "$ROOT/docs/execution/state.md"
copy_if_exists "$ROOT/PRL-TEMPLATE.md" "$ROOT/docs/execution/parallel/PRL-TEMPLATE.md"

# -----------------------------
# Requests
# -----------------------------
copy_if_exists "$ROOT/new_feature_flow.md" "$ROOT/docs/requests/new_feature_flow.md"
copy_if_exists "$ROOT/change_request_flow.md" "$ROOT/docs/requests/change_request_flow.md"
copy_if_exists "$ROOT/feature_intake.md" "$ROOT/docs/requests/templates/feature_intake.md"
copy_if_exists "$ROOT/change_intake.md" "$ROOT/docs/requests/templates/change_intake.md"
copy_if_exists "$ROOT/impact_analysis.md" "$ROOT/docs/requests/templates/impact_analysis.md"
copy_if_exists "$ROOT/regression_plan.md" "$ROOT/docs/requests/templates/regression_plan.md"
copy_if_exists "$ROOT/execution_gate.md" "$ROOT/docs/requests/templates/execution_gate.md"
copy_if_exists "$ROOT/release_notes.md" "$ROOT/docs/requests/templates/release_notes.md"

# -----------------------------
# Testing + Quality
# -----------------------------
copy_if_exists "$ROOT/test_strategy.md" "$ROOT/docs/testing/test_strategy.md"
copy_if_exists "$ROOT/test_plan_rules.md" "$ROOT/docs/testing/test_plan_rules.md"
copy_if_exists "$ROOT/test_case_template.md" "$ROOT/docs/testing/test_case_template.md"

copy_if_exists "$ROOT/quality_baseline.md" "$ROOT/docs/quality/quality_baseline.md"
copy_if_exists "$ROOT/quality_regression_rules.md" "$ROOT/docs/quality/quality_regression_rules.md"
copy_if_exists "$ROOT/quality_gate.md" "$ROOT/docs/quality/quality_gate.md"

# -----------------------------
# Signals + Decision engine + Memory
# -----------------------------
copy_if_exists "$ROOT/signal_sources.md" "$ROOT/docs/signals/signal_sources.md"
copy_if_exists "$ROOT/signal_contract.md" "$ROOT/docs/signals/signal_contract.md"
copy_if_exists "$ROOT/signal_normalization.md" "$ROOT/docs/signals/signal_normalization.md"
copy_if_exists "$ROOT/signal_snapshot.md" "$ROOT/docs/signals/signal_snapshot.md"
copy_if_exists "$ROOT/po_override.md" "$ROOT/docs/signals/po_override.md"

copy_if_exists "$ROOT/decision_inputs.md" "$ROOT/docs/decision_engine/decision_inputs.md"
copy_if_exists "$ROOT/decision_rules.md" "$ROOT/docs/decision_engine/decision_rules.md"
copy_if_exists "$ROOT/decision_output_template.md" "$ROOT/docs/decision_engine/decision_output_template.md"
copy_if_exists "$ROOT/decision_gate.md" "$ROOT/docs/decision_engine/decision_gate.md"

copy_if_exists "$ROOT/memory_setup.md" "$ROOT/docs/memory/memory_setup.md"
copy_if_exists "$ROOT/memory_policy.md" "$ROOT/docs/memory/memory_policy.md"
copy_if_exists "$ROOT/memory_queries.md" "$ROOT/docs/memory/memory_queries.md"
copy_if_exists "$ROOT/memory_review.md" "$ROOT/docs/memory/memory_review.md"

# -----------------------------
# Skills
# -----------------------------
copy_if_exists "$ROOT/Skill-README.md" "$ROOT/docs/skills/README.md"
for f in "$ROOT"/skill_*.md; do
  if [ -f "$f" ]; then
    copy_if_exists "$f" "$ROOT/docs/skills/$(basename "$f")"
  fi
done

# -----------------------------
# Factory markers and workflows
# -----------------------------
copy_dir_if_exists "$ROOT/factory_markers" "$ROOT/.factory"
copy_dir_if_exists "$ROOT/github_workflows" "$ROOT/.github/workflows"

# -----------------------------
# Unzip generated template bundles into correct places
# -----------------------------
unzip_if_exists "$ROOT/specs_templates.zip" "$ROOT/specs/_templates"
unzip_if_exists "$ROOT/architecture_decisions_templates.zip" "$ROOT/architecture/decisions"
unzip_if_exists "$ROOT/plan_readmes.zip" "$ROOT/plan"
unzip_if_exists "$ROOT/scripts_signals.zip" "$ROOT/scripts/signals"
unzip_if_exists "$ROOT/tools.zip" "$ROOT/tools"
unzip_if_exists "$ROOT/github_workflows.zip" "$ROOT/.github/workflows"

log "Factory reorg completed at $(date -u)"
log "Report written to: $REPORT"
echo "DONE. See $REPORT"