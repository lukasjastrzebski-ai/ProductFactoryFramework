#!/bin/bash

# v10 to v20 Migration Script
# ProductFactoryFramework
#
# Migrates a v10.x project to v20 autonomous mode.

set -e

FACTORY_ROOT="${FACTORY_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
FACTORY_DIR="$FACTORY_ROOT/.factory"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[MIGRATE]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[MIGRATE]${NC} $1"; }
log_error() { echo -e "${RED}[MIGRATE]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

usage() {
    cat << EOF
Usage: v10_to_v20.sh [OPTIONS]

Options:
    --check         Check migration readiness without migrating
    --backup        Create backup before migration
    --pilot         Enable pilot mode after migration
    --force         Force migration even with warnings
    --rollback      Rollback to v10.x
    -h, --help      Show this help

Examples:
    v10_to_v20.sh --check
    v10_to_v20.sh --backup
    v10_to_v20.sh --backup --pilot
    v10_to_v20.sh --rollback
EOF
    exit 1
}

# Parse arguments
CHECK_ONLY=false
CREATE_BACKUP=false
ENABLE_PILOT=false
FORCE=false
ROLLBACK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --check) CHECK_ONLY=true; shift ;;
        --backup) CREATE_BACKUP=true; shift ;;
        --pilot) ENABLE_PILOT=true; shift ;;
        --force) FORCE=true; shift ;;
        --rollback) ROLLBACK=true; shift ;;
        -h|--help) usage ;;
        *) log_error "Unknown option: $1"; usage ;;
    esac
done

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."

    local errors=0
    local warnings=0

    # Check factory exists
    if [ ! -d "$FACTORY_DIR" ]; then
        log_error "Factory directory not found"
        ((errors++))
    fi

    # Check planning complete
    if [ ! -f "$FACTORY_DIR/STAGE_7_COMPLETE" ]; then
        log_error "Planning not complete (STAGE_7_COMPLETE missing)"
        ((errors++))
    fi

    # Check planning frozen
    if [ ! -f "$FACTORY_DIR/PLANNING_FROZEN" ]; then
        log_error "Planning not frozen (PLANNING_FROZEN missing)"
        ((errors++))
    fi

    # Check current version
    local current_version="10.x"
    if [ -f "$FACTORY_DIR/factory_version.txt" ]; then
        current_version=$(cat "$FACTORY_DIR/factory_version.txt")
    fi

    if [[ "$current_version" == "20"* ]]; then
        log_warn "Already at v20 ($current_version)"
        ((warnings++))
    fi

    # Check for active execution
    if [ -f "$FACTORY_DIR/ORCHESTRATOR_ACTIVE" ]; then
        log_warn "Orchestrator appears to be active"
        ((warnings++))
    fi

    # Check required docs exist
    local required_docs=(
        "docs/ai.md"
        "CLAUDE.md"
        "docs/execution/state.md"
    )

    for doc in "${required_docs[@]}"; do
        if [ ! -f "$FACTORY_ROOT/$doc" ]; then
            log_warn "Required doc missing: $doc"
            ((warnings++))
        fi
    done

    echo ""
    log_info "Prerequisites check complete"
    log_info "  Errors: $errors"
    log_info "  Warnings: $warnings"

    if [ $errors -gt 0 ]; then
        log_error "Cannot proceed with $errors errors"
        return 1
    fi

    if [ $warnings -gt 0 ] && [ "$FORCE" != true ]; then
        log_warn "Has warnings. Use --force to proceed anyway"
        return 1
    fi

    return 0
}

# Create backup
create_backup() {
    log_step "Creating backup..."

    local backup_dir="$FACTORY_ROOT/.factory_backup_$(date +%Y%m%d_%H%M%S)"

    cp -r "$FACTORY_DIR" "$backup_dir"
    log_info "Backup created: $backup_dir"

    echo "$backup_dir" > "$FACTORY_DIR/.last_backup"
}

# Migrate to v20
migrate_to_v20() {
    log_step "Migrating to v20..."

    # Create v20 mode marker
    echo "20.0" > "$FACTORY_DIR/V20_MODE"
    log_info "Created V20_MODE marker"

    # Update factory version
    echo "20.0" > "$FACTORY_DIR/factory_version.txt"
    log_info "Updated factory version to 20.0"

    # Create v20 directory structure
    mkdir -p "$FACTORY_DIR/execution/parallel_batches"
    mkdir -p "$FACTORY_DIR/execution/history"
    mkdir -p "$FACTORY_DIR/execution/go_gates"
    mkdir -p "$FACTORY_DIR/agent_progress"
    mkdir -p "$FACTORY_DIR/schemas"
    mkdir -p "$FACTORY_DIR/validation/pre_go"
    mkdir -p "$FACTORY_DIR/validation/post_impl"
    log_info "Created v20 directory structure"

    # Initialize orchestrator state
    cat > "$FACTORY_DIR/execution/orchestrator_state.json" << EOF
{
  "version": "20.0",
  "role": "PRODUCT_OWNER",
  "session_id": null,
  "current_phase": "PHASE-01",
  "execution_mode": "autonomous",
  "active_batch": null,
  "agents": {
    "active": 0,
    "completed": 0,
    "failed": 0,
    "blocked": 0
  },
  "escalations": {
    "pending": 0,
    "blocking": false
  },
  "statistics": {
    "tasks_completed": 0,
    "tasks_blocked": 0,
    "tasks_skipped": 0,
    "retries_issued": 0,
    "go_gates_issued": 0,
    "next_gates_issued": 0
  },
  "paused": false,
  "started_at": null,
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    log_info "Initialized orchestrator state"

    # Initialize agent registry
    cat > "$FACTORY_DIR/execution/agent_registry.json" << EOF
{
  "version": "20.0",
  "agents": [],
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    log_info "Initialized agent registry"

    # Initialize escalation queue
    cat > "$FACTORY_DIR/execution/escalation_queue.json" << EOF
{
  "version": "20.0",
  "escalations": [],
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    log_info "Initialized escalation queue"

    # Create DD reports directory
    mkdir -p "$FACTORY_ROOT/docs/execution/dd_reports"
    log_info "Created DD reports directory"

    # Enable pilot mode if requested
    if [ "$ENABLE_PILOT" = true ]; then
        echo "pilot" > "$FACTORY_DIR/V20_PILOT"
        log_info "Enabled pilot mode"
    fi

    log_info "Migration to v20 complete!"
}

# Rollback to v10
rollback_to_v10() {
    log_step "Rolling back to v10.x..."

    # Remove v20 markers
    rm -f "$FACTORY_DIR/V20_MODE"
    rm -f "$FACTORY_DIR/V20_PILOT"
    rm -f "$FACTORY_DIR/ORCHESTRATOR_ACTIVE"
    rm -f "$FACTORY_DIR/DD_ESCALATION_PENDING"

    # Reset factory version
    echo "10.2" > "$FACTORY_DIR/factory_version.txt"

    # Remove v20 state (keep directories for reference)
    rm -f "$FACTORY_DIR/execution/orchestrator_state.json"
    rm -f "$FACTORY_DIR/execution/agent_registry.json"
    rm -f "$FACTORY_DIR/execution/escalation_queue.json"

    log_info "Rolled back to v10.x mode"
    log_info "v20 directories preserved for reference"
}

# Show migration summary
show_summary() {
    echo ""
    echo "========================================"
    echo "  Migration Summary"
    echo "========================================"
    echo ""
    echo "  Factory Version: $(cat "$FACTORY_DIR/factory_version.txt")"
    echo "  v20 Mode: $(test -f "$FACTORY_DIR/V20_MODE" && echo "Enabled" || echo "Disabled")"
    echo "  Pilot Mode: $(test -f "$FACTORY_DIR/V20_PILOT" && echo "Enabled" || echo "Disabled")"
    echo ""

    if [ -f "$FACTORY_DIR/V20_MODE" ]; then
        echo "  Next Steps:"
        echo "    1. Start a new Claude Code session"
        echo "    2. PO will initialize in v20 mode"
        echo "    3. Use STATUS to check progress"
        echo "    4. Respond to ESCALATIONS as needed"
        echo ""
    fi
}

# Main
main() {
    echo ""
    echo "========================================"
    echo "  ProductFactoryFramework Migration"
    echo "========================================"
    echo ""

    if [ "$ROLLBACK" = true ]; then
        rollback_to_v10
        show_summary
        exit 0
    fi

    if ! check_prerequisites; then
        exit 1
    fi

    if [ "$CHECK_ONLY" = true ]; then
        log_info "Check complete. Ready for migration."
        exit 0
    fi

    if [ "$CREATE_BACKUP" = true ]; then
        create_backup
    fi

    migrate_to_v20
    show_summary
}

main
