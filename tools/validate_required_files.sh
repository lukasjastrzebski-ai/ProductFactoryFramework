#!/usr/bin/env bash
set -euo pipefail

OUT="factory_missing_files_report.txt"
> "$OUT"

missing=0

log_missing() {
  echo "MISSING: $1" | tee -a "$OUT"
  missing=1
}

check_file() {
  [ -f "$1" ] || log_missing "$1"
}

check_dir() {
  [ -d "$1" ] || log_missing "$1/"
}

echo "Factory Missing Files Report" >> "$OUT"
echo "Generated at: $(date -u)" >> "$OUT"
echo "---------------------------------" >> "$OUT"

# ---------------------------
# Core required files
# ---------------------------
check_file "FACTORY_VERSION"
check_file "docs/ai.md"
check_file "docs/ideation_playbook.md"
check_file "docs/multi_agent_execution_protocol.md"

# ---------------------------
# Execution core
# ---------------------------
check_file "docs/execution/task_runner.md"
check_file "docs/execution/execution_playbook.md"
check_file "docs/execution/task_report_template.md"
check_file "docs/execution/state.md"
check_file "docs/execution/task_status.md"
check_dir  "docs/execution/reports"

# ---------------------------
# Quality & testing
# ---------------------------
check_file "docs/testing/test_strategy.md"
check_file "docs/testing/test_plan_rules.md"
check_file "docs/quality/quality_baseline.md"
check_file "docs/quality/quality_gate.md"

# ---------------------------
# Requests & change flows
# ---------------------------
check_file "docs/requests/new_feature_flow.md"
check_file "docs/requests/change_request_flow.md"
check_dir  "docs/requests/templates"

# ---------------------------
# Planning structure
# ---------------------------
check_dir "specs/_templates"
check_dir "architecture/decisions"
check_dir "plan/phases"
check_dir "plan/tasks"

# ---------------------------
# Factory markers
# ---------------------------
check_dir ".factory"
check_file ".factory/KICKOFF_COMPLETE"
check_file ".factory/factory_version.txt"

# ---------------------------
# Tooling
# ---------------------------
check_dir  "tools"
check_file "tools/validate_required_files.sh"
check_file "tools/validate_factory_links.sh"
check_file "tools/validate_planning_freeze.sh"

echo "---------------------------------" >> "$OUT"

if [ "$missing" -eq 1 ]; then
  echo "❌ Missing files detected. See $OUT"
  exit 1
else
  echo "✅ No missing files detected."
  exit 0
fi
