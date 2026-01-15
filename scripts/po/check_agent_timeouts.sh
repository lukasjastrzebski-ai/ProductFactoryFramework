#!/bin/bash

# Agent Timeout Detection Script
# v20 Autonomous Execution Mode
#
# This script checks for timed-out agents and marks them as failed.
# Run periodically by the PO or as a cron job.

set -e

FACTORY_ROOT="${FACTORY_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
FACTORY_DIR="$FACTORY_ROOT/.factory"
EXECUTION_DIR="$FACTORY_DIR/execution"
REGISTRY_FILE="$EXECUTION_DIR/agent_registry.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[TIMEOUT]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[TIMEOUT]${NC} $1"; }
log_error() { echo -e "${RED}[TIMEOUT]${NC} $1"; }

usage() {
    cat << EOF
Usage: check_agent_timeouts.sh [OPTIONS]

Options:
    --dry-run           Show what would be done without executing
    --loop SECONDS      Run continuously with interval (default: one-shot)
    --notify            Create escalation for timed-out agents
    -h, --help          Show this help

Example:
    check_agent_timeouts.sh                    # One-shot check
    check_agent_timeouts.sh --loop 300         # Check every 5 minutes
    check_agent_timeouts.sh --notify           # Create escalations for timeouts
EOF
    exit 1
}

# Parse arguments
DRY_RUN=false
LOOP_INTERVAL=0
NOTIFY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --loop)
            LOOP_INTERVAL="$2"
            shift 2
            ;;
        --notify)
            NOTIFY=true
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

# Get current timestamp in seconds since epoch
get_current_epoch() {
    date +%s
}

# Convert ISO8601 to epoch seconds
iso_to_epoch() {
    local iso_date="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso_date" +%s 2>/dev/null || \
        date -j -f "%Y-%m-%dT%H:%M:%S" "${iso_date%Z}" +%s 2>/dev/null || echo "0"
    else
        # Linux
        date -d "$iso_date" +%s 2>/dev/null || echo "0"
    fi
}

# Check for timed out agents
check_timeouts() {
    if [ ! -f "$REGISTRY_FILE" ]; then
        log_warn "Agent registry not found: $REGISTRY_FILE"
        return 0
    fi

    local current_epoch=$(get_current_epoch)
    local timed_out_count=0
    local timed_out_agents=""

    log_info "Checking for timed-out agents at $(date -u +%Y-%m-%dT%H:%M:%SZ)..."

    # Get active agents with timeout_at
    local agents=$(jq -c '.agents[] | select(.status == "active" or .status == "implementing" or .status == "researching" or .status == "planning" or .status == "fixing")' "$REGISTRY_FILE" 2>/dev/null)

    if [ -z "$agents" ]; then
        log_info "No active agents found"
        return 0
    fi

    # Check each agent
    while IFS= read -r agent; do
        local agent_id=$(echo "$agent" | jq -r '.agent_id')
        local task_id=$(echo "$agent" | jq -r '.task_id')
        local timeout_at=$(echo "$agent" | jq -r '.timeout_at // empty')
        local status=$(echo "$agent" | jq -r '.status')

        if [ -z "$timeout_at" ]; then
            log_warn "Agent $agent_id has no timeout_at set"
            continue
        fi

        local timeout_epoch=$(iso_to_epoch "$timeout_at")

        if [ "$timeout_epoch" -gt 0 ] && [ "$current_epoch" -gt "$timeout_epoch" ]; then
            timed_out_count=$((timed_out_count + 1))
            local overtime=$((current_epoch - timeout_epoch))
            local overtime_min=$((overtime / 60))

            log_error "Agent $agent_id ($task_id) TIMED OUT - $overtime_min minutes overdue"
            timed_out_agents="$timed_out_agents $agent_id"

            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would mark agent $agent_id as timed_out"
            else
                # Mark agent as timed_out
                mark_agent_timeout "$agent_id" "$task_id" "$overtime_min"

                # Create escalation if requested
                if [ "$NOTIFY" = true ]; then
                    create_timeout_escalation "$agent_id" "$task_id" "$overtime_min"
                fi
            fi
        else
            local remaining=$((timeout_epoch - current_epoch))
            local remaining_min=$((remaining / 60))
            log_info "Agent $agent_id ($task_id) - $remaining_min minutes remaining"
        fi
    done <<< "$agents"

    if [ "$timed_out_count" -gt 0 ]; then
        log_error "Found $timed_out_count timed-out agent(s)"
        return 1
    else
        log_info "All agents within timeout limits"
        return 0
    fi
}

# Mark agent as timed out
mark_agent_timeout() {
    local agent_id="$1"
    local task_id="$2"
    local overtime_min="$3"

    log_info "Marking agent $agent_id as timed_out..."

    # Update registry
    jq --arg id "$agent_id" \
       --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '(.agents[] | select(.agent_id == $id)) |= . + {
          status: "timed_out",
          completed_at: $time,
          timeout_reason: "Exceeded maximum execution time"
        }' \
       "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp" && mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"

    # Update progress file if exists
    local progress_file="$FACTORY_DIR/agent_progress/${agent_id}.json"
    if [ -f "$progress_file" ]; then
        jq --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '. + {
             status: "timed_out",
             current_activity: "Agent timed out - execution exceeded limit",
             last_updated: $time
           }' \
           "$progress_file" > "$progress_file.tmp" && mv "$progress_file.tmp" "$progress_file"
    fi

    log_info "Agent $agent_id marked as timed_out"
}

# Create escalation for timed out agent
create_timeout_escalation() {
    local agent_id="$1"
    local task_id="$2"
    local overtime_min="$3"

    local escalation_file="$EXECUTION_DIR/escalations/ESC-TIMEOUT-$(date +%s).json"
    mkdir -p "$(dirname "$escalation_file")"

    cat > "$escalation_file" << EOF
{
  "escalation_id": "ESC-TIMEOUT-$(date +%s)",
  "type": "AGENT_TIMEOUT",
  "severity": "HIGH",
  "agent_id": "$agent_id",
  "task_id": "$task_id",
  "message": "Agent $agent_id executing $task_id has timed out ($overtime_min minutes over limit)",
  "recommended_action": "Review agent progress, consider manual intervention or task reassignment",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "pending"
}
EOF

    log_warn "Created timeout escalation: $escalation_file"
}

# Update orchestrator state with timeout info
update_orchestrator_state() {
    local state_file="$EXECUTION_DIR/orchestrator_state.json"

    if [ -f "$state_file" ]; then
        jq --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '.last_timeout_check = $time' \
           "$state_file" > "$state_file.tmp" && mv "$state_file.tmp" "$state_file"
    fi
}

# Main
main() {
    echo ""
    log_info "Agent Timeout Detection v20"
    echo ""

    if [ "$LOOP_INTERVAL" -gt 0 ]; then
        log_info "Running in loop mode (interval: ${LOOP_INTERVAL}s)"
        while true; do
            check_timeouts || true
            update_orchestrator_state
            echo ""
            log_info "Sleeping for ${LOOP_INTERVAL}s..."
            sleep "$LOOP_INTERVAL"
        done
    else
        check_timeouts
        update_orchestrator_state
    fi
}

main
