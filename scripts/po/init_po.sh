#!/bin/bash

# Product Owner Initialization Script
# v20 Autonomous Execution Mode
#
# This script initializes the PO orchestrator at session start.
# It validates the factory state and prepares for execution.

set -e

FACTORY_ROOT="${FACTORY_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
FACTORY_DIR="$FACTORY_ROOT/.factory"
EXECUTION_DIR="$FACTORY_DIR/execution"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[PO-INIT]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[PO-INIT]${NC} $1"
}

log_error() {
    echo -e "${RED}[PO-INIT]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check v20 mode
    if [ ! -f "$FACTORY_DIR/V20_MODE" ]; then
        log_error "v20 mode not enabled. Create .factory/V20_MODE first."
        exit 1
    fi

    # Check planning freeze
    if [ ! -f "$FACTORY_DIR/PLANNING_FROZEN" ]; then
        log_error "Planning not frozen. Complete planning stages first."
        exit 1
    fi

    # Check for existing orchestrator
    if [ -f "$FACTORY_DIR/ORCHESTRATOR_ACTIVE" ]; then
        log_warn "Orchestrator already active. Checking if stale..."
        # Could add staleness check here based on timestamp
    fi

    log_info "Prerequisites OK"
}

# Load planning artifacts
load_planning_artifacts() {
    log_info "Loading planning artifacts..."

    # Verify required files exist
    local required_files=(
        "docs/ai.md"
        "CLAUDE.md"
        "docs/execution/state.md"
    )

    for file in "${required_files[@]}"; do
        if [ ! -f "$FACTORY_ROOT/$file" ]; then
            log_error "Required file missing: $file"
            exit 1
        fi
    done

    # Count tasks in plan
    local task_count=0
    if [ -d "$FACTORY_ROOT/plan/tasks" ]; then
        task_count=$(find "$FACTORY_ROOT/plan/tasks" -name "*.md" | wc -l | tr -d ' ')
    fi

    # Count phases
    local phase_count=0
    if [ -d "$FACTORY_ROOT/plan/phases" ]; then
        phase_count=$(find "$FACTORY_ROOT/plan/phases" -name "*.md" | wc -l | tr -d ' ')
    fi

    log_info "Found $task_count tasks in $phase_count phases"
}

# Initialize execution state
initialize_state() {
    log_info "Initializing execution state..."

    # Create execution directories if needed
    mkdir -p "$EXECUTION_DIR/parallel_batches"
    mkdir -p "$EXECUTION_DIR/history"
    mkdir -p "$EXECUTION_DIR/go_gates"
    mkdir -p "$FACTORY_DIR/agent_progress"

    # Generate session ID
    local session_id
    if command -v uuidgen &> /dev/null; then
        session_id=$(uuidgen)
    else
        session_id=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "session-$(date +%s)")
    fi

    # Determine current phase
    local current_phase="PHASE-01"
    if [ -f "$FACTORY_ROOT/docs/execution/state.md" ]; then
        # Try to extract current phase from state file
        local phase_from_state=$(grep -oP 'Current Phase: \K[A-Z]+-[0-9]+' "$FACTORY_ROOT/docs/execution/state.md" 2>/dev/null || echo "")
        if [ -n "$phase_from_state" ]; then
            current_phase="$phase_from_state"
        fi
    fi

    # Create orchestrator state
    cat > "$EXECUTION_DIR/orchestrator_state.json" << EOF
{
  "version": "20.0",
  "role": "PRODUCT_OWNER",
  "session_id": "$session_id",
  "current_phase": "$current_phase",
  "execution_mode": "autonomous",
  "active_batch": null,
  "agents": {
    "active": 0,
    "completed": 0,
    "failed": 0
  },
  "escalations": {
    "pending": 0,
    "blocking": false
  },
  "statistics": {
    "tasks_completed": 0,
    "tasks_blocked": 0,
    "retries_issued": 0,
    "go_gates_issued": 0,
    "next_gates_issued": 0
  },
  "paused": false,
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    # Create orchestrator active marker
    cat > "$FACTORY_DIR/ORCHESTRATOR_ACTIVE" << EOF
{
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "session_id": "$session_id",
  "phase": "$current_phase"
}
EOF

    # Initialize agent registry
    cat > "$EXECUTION_DIR/agent_registry.json" << EOF
{
  "version": "20.0",
  "agents": [],
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    # Initialize escalation queue
    cat > "$EXECUTION_DIR/escalation_queue.json" << EOF
{
  "version": "20.0",
  "escalations": [],
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    log_info "Execution state initialized"
    log_info "Session ID: $session_id"
    log_info "Current Phase: $current_phase"
}

# Generate initialization report
generate_report() {
    log_info "Generating initialization report..."

    local report_file="$EXECUTION_DIR/init_report.md"

    cat > "$report_file" << EOF
# PO Initialization Report

**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Factory Version:** $(cat "$FACTORY_DIR/factory_version.txt" 2>/dev/null || echo "unknown")
**Mode:** v20 Autonomous

## Status

- Prerequisites: PASS
- Planning Artifacts: LOADED
- Execution State: INITIALIZED
- Orchestrator: ACTIVE

## Session Info

- Session ID: $(jq -r '.session_id' "$EXECUTION_DIR/orchestrator_state.json")
- Current Phase: $(jq -r '.current_phase' "$EXECUTION_DIR/orchestrator_state.json")

## Ready for Execution

The Product Owner is ready to begin autonomous execution.

### Next Steps

1. Review current phase tasks
2. Build dependency graph
3. Identify parallelizable groups
4. Begin task execution

EOF

    log_info "Report saved to: $report_file"
}

# Main
main() {
    echo ""
    echo "========================================"
    echo "  Product Owner Initialization (v20)"
    echo "========================================"
    echo ""

    check_prerequisites
    load_planning_artifacts
    initialize_state
    generate_report

    echo ""
    log_info "PO initialization complete!"
    echo ""
}

main "$@"
