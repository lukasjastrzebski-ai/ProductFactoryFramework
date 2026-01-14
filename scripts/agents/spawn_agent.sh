#!/bin/bash

# Task Agent Spawning Script
# v20 Autonomous Execution Mode
#
# This script spawns a new Task Agent for parallel execution.

set -e

FACTORY_ROOT="${FACTORY_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
FACTORY_DIR="$FACTORY_ROOT/.factory"
EXECUTION_DIR="$FACTORY_DIR/execution"
WORKTREES_DIR="${WORKTREES_DIR:-$FACTORY_ROOT/../worktrees}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[SPAWN]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[SPAWN]${NC} $1"; }
log_error() { echo -e "${RED}[SPAWN]${NC} $1"; }
log_agent() { echo -e "${BLUE}[AGENT]${NC} $1"; }

usage() {
    cat << EOF
Usage: spawn_agent.sh --task TASK-ID [OPTIONS]

Options:
    --task TASK-ID       Task ID to assign (required)
    --assignment FILE    Path to task assignment JSON
    --timeout MINUTES    Agent timeout (default: 30)
    --worktree PATH      Custom worktree path
    --dry-run           Show what would be done without executing
    -h, --help          Show this help

Example:
    spawn_agent.sh --task TASK-001 --assignment /tmp/assignment.json
EOF
    exit 1
}

# Parse arguments
TASK_ID=""
ASSIGNMENT_FILE=""
TIMEOUT_MINUTES=30
CUSTOM_WORKTREE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --task)
            TASK_ID="$2"
            shift 2
            ;;
        --assignment)
            ASSIGNMENT_FILE="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT_MINUTES="$2"
            shift 2
            ;;
        --worktree)
            CUSTOM_WORKTREE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required args
if [ -z "$TASK_ID" ]; then
    log_error "Task ID is required"
    usage
fi

# Generate agent ID
generate_agent_id() {
    if command -v uuidgen &> /dev/null; then
        echo "agent-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -c1-8)"
    else
        echo "agent-$(date +%s%N | sha256sum | cut -c1-8)"
    fi
}

AGENT_ID=$(generate_agent_id)

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites for $TASK_ID..."

    # Check v20 mode
    if [ ! -f "$FACTORY_DIR/V20_MODE" ]; then
        log_error "v20 mode not enabled"
        exit 1
    fi

    # Check orchestrator is active
    if [ ! -f "$FACTORY_DIR/ORCHESTRATOR_ACTIVE" ]; then
        log_error "Orchestrator not active. Start PO first."
        exit 1
    fi

    # Check max agents
    local active_agents=0
    if [ -f "$EXECUTION_DIR/agent_registry.json" ]; then
        active_agents=$(jq '[.agents[] | select(.status == "active" or .status == "implementing" or .status == "fixing")] | length' "$EXECUTION_DIR/agent_registry.json" 2>/dev/null || echo "0")
    fi

    local max_agents=5
    if [ "$active_agents" -ge "$max_agents" ]; then
        log_error "Max agents ($max_agents) reached. Wait for completion."
        exit 1
    fi

    log_info "Prerequisites OK (active agents: $active_agents/$max_agents)"
}

# Create worktree
create_worktree() {
    local worktree_path="${CUSTOM_WORKTREE:-$WORKTREES_DIR/$AGENT_ID-$TASK_ID}"

    log_info "Creating worktree at $worktree_path..."

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would create worktree at $worktree_path"
        echo "$worktree_path"
        return
    fi

    # Create parent directory
    mkdir -p "$(dirname "$worktree_path")"

    # Create worktree from main branch
    local base_branch="main"
    if ! git rev-parse --verify "$base_branch" &>/dev/null; then
        base_branch="master"
    fi

    git worktree add "$worktree_path" -b "agent/$AGENT_ID/$TASK_ID" "$base_branch" 2>/dev/null || {
        # Branch might exist, try without creating
        git worktree add "$worktree_path" "$base_branch" 2>/dev/null || {
            log_error "Failed to create worktree"
            exit 1
        }
    }

    log_info "Worktree created: $worktree_path"
    echo "$worktree_path"
}

# Create task assignment if not provided
create_assignment() {
    local worktree_path="$1"

    if [ -n "$ASSIGNMENT_FILE" ] && [ -f "$ASSIGNMENT_FILE" ]; then
        log_info "Using provided assignment: $ASSIGNMENT_FILE"
        return
    fi

    log_info "Creating default task assignment..."

    # Read task file for metadata
    local task_file="$FACTORY_ROOT/plan/tasks/${TASK_ID}.md"
    local spec_ref=""
    local authorized_files="[]"

    if [ -f "$task_file" ]; then
        # Extract spec reference
        spec_ref=$(grep -oP 'Specification:\s*\K.+' "$task_file" 2>/dev/null || echo "")
    fi

    ASSIGNMENT_FILE="$FACTORY_DIR/agent_progress/${AGENT_ID}_assignment.json"

    cat > "$ASSIGNMENT_FILE" << EOF
{
  "task_id": "$TASK_ID",
  "agent_id": "$AGENT_ID",
  "worktree_path": "$worktree_path",
  "spec_reference": "$spec_ref",
  "task_file": "plan/tasks/${TASK_ID}.md",
  "acceptance_criteria": [],
  "test_delta": {
    "add": [],
    "update": [],
    "regression": []
  },
  "authorized_files": $authorized_files,
  "dependencies": [],
  "timeout_minutes": $TIMEOUT_MINUTES,
  "max_retries": 2,
  "assigned_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    log_info "Assignment created: $ASSIGNMENT_FILE"
}

# Register agent
register_agent() {
    local worktree_path="$1"

    log_info "Registering agent in registry..."

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would register agent $AGENT_ID"
        return
    fi

    local registry_file="$EXECUTION_DIR/agent_registry.json"

    # Create registry if doesn't exist
    if [ ! -f "$registry_file" ]; then
        echo '{"version": "20.0", "agents": [], "last_updated": ""}' > "$registry_file"
    fi

    # Add agent to registry
    local new_agent=$(cat << EOF
{
  "agent_id": "$AGENT_ID",
  "task_id": "$TASK_ID",
  "worktree_path": "$worktree_path",
  "assignment_file": "$ASSIGNMENT_FILE",
  "status": "active",
  "spawned_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "timeout_at": "$(date -u -d "+$TIMEOUT_MINUTES minutes" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+${TIMEOUT_MINUTES}M +%Y-%m-%dT%H:%M:%SZ)",
  "retry_count": 0,
  "last_progress": null
}
EOF
)

    # Update registry using jq
    jq --argjson agent "$new_agent" \
       '.agents += [$agent] | .last_updated = "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"' \
       "$registry_file" > "$registry_file.tmp" && mv "$registry_file.tmp" "$registry_file"

    log_info "Agent registered: $AGENT_ID"
}

# Create progress file
create_progress_file() {
    log_info "Creating progress file..."

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would create progress file"
        return
    fi

    local progress_file="$FACTORY_DIR/agent_progress/${AGENT_ID}.json"

    cat > "$progress_file" << EOF
{
  "agent_id": "$AGENT_ID",
  "task_id": "$TASK_ID",
  "status": "initializing",
  "progress_percent": 0,
  "current_activity": "Agent spawned, awaiting task intake",
  "files_modified": [],
  "issues": [],
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    log_info "Progress file created: $progress_file"
}

# Output spawn result
output_result() {
    local worktree_path="$1"

    cat << EOF

========================================
  Agent Spawned Successfully
========================================

Agent ID:     $AGENT_ID
Task ID:      $TASK_ID
Worktree:     $worktree_path
Assignment:   $ASSIGNMENT_FILE
Timeout:      $TIMEOUT_MINUTES minutes

To monitor progress:
  cat $FACTORY_DIR/agent_progress/${AGENT_ID}.json

To check status:
  jq '.agents[] | select(.agent_id == "$AGENT_ID")' $EXECUTION_DIR/agent_registry.json

EOF

    # Output JSON for programmatic use
    if [ "$DRY_RUN" != true ]; then
        cat > "$FACTORY_DIR/agent_progress/${AGENT_ID}_spawn_result.json" << EOF
{
  "success": true,
  "agent_id": "$AGENT_ID",
  "task_id": "$TASK_ID",
  "worktree_path": "$worktree_path",
  "assignment_file": "$ASSIGNMENT_FILE",
  "progress_file": "$FACTORY_DIR/agent_progress/${AGENT_ID}.json",
  "spawned_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    fi
}

# Main
main() {
    echo ""
    log_agent "Spawning Task Agent for $TASK_ID"
    echo ""

    check_prerequisites

    local worktree_path
    worktree_path=$(create_worktree)

    create_assignment "$worktree_path"
    register_agent "$worktree_path"
    create_progress_file
    output_result "$worktree_path"
}

main
