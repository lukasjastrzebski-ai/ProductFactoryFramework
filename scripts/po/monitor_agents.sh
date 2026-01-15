#!/bin/bash

# PO Agent Monitor
# v20 Autonomous Execution Mode
#
# Comprehensive monitoring script for parallel agent execution.
# Monitors timeouts, progress, and agent health.

set -e

FACTORY_ROOT="${FACTORY_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
FACTORY_DIR="$FACTORY_ROOT/.factory"
EXECUTION_DIR="$FACTORY_DIR/execution"
REGISTRY_FILE="$EXECUTION_DIR/agent_registry.json"
STATE_FILE="$EXECUTION_DIR/orchestrator_state.json"
PROGRESS_DIR="$FACTORY_DIR/agent_progress"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[MONITOR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[MONITOR]${NC} $1"; }
log_error() { echo -e "${RED}[MONITOR]${NC} $1"; }
log_header() { echo -e "${CYAN}$1${NC}"; }

usage() {
    cat << EOF
Usage: monitor_agents.sh [COMMAND] [OPTIONS]

Commands:
    status          Show current agent status (default)
    dashboard       Show real-time dashboard
    check           Run all health checks
    stale           Find stale agents (no progress update)
    timeouts        Check for timed-out agents
    cleanup         Clean up completed/failed agents

Options:
    --loop SECONDS  Run continuously with interval
    --json          Output in JSON format
    -h, --help      Show this help

Examples:
    monitor_agents.sh status
    monitor_agents.sh dashboard --loop 30
    monitor_agents.sh cleanup
EOF
    exit 1
}

# Get current timestamp
get_current_epoch() {
    date +%s
}

# Convert ISO8601 to epoch
iso_to_epoch() {
    local iso_date="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso_date" +%s 2>/dev/null || \
        date -j -f "%Y-%m-%dT%H:%M:%S" "${iso_date%Z}" +%s 2>/dev/null || echo "0"
    else
        date -d "$iso_date" +%s 2>/dev/null || echo "0"
    fi
}

# Show agent status
show_status() {
    if [ ! -f "$REGISTRY_FILE" ]; then
        log_warn "No agent registry found"
        return 0
    fi

    echo ""
    log_header "═══════════════════════════════════════════════════════════"
    log_header "                    AGENT STATUS"
    log_header "═══════════════════════════════════════════════════════════"
    echo ""

    # Count by status
    local total=$(jq '.agents | length' "$REGISTRY_FILE")
    local active=$(jq '[.agents[] | select(.status == "active" or .status == "implementing" or .status == "researching" or .status == "planning" or .status == "fixing")] | length' "$REGISTRY_FILE")
    local completed=$(jq '[.agents[] | select(.status == "completed")] | length' "$REGISTRY_FILE")
    local failed=$(jq '[.agents[] | select(.status == "failed" or .status == "timed_out" or .status == "blocked")] | length' "$REGISTRY_FILE")

    echo "  Total Agents:     $total"
    echo "  Active:           $active"
    echo "  Completed:        $completed"
    echo "  Failed/Blocked:   $failed"
    echo ""

    if [ "$active" -gt 0 ]; then
        log_header "Active Agents:"
        echo ""
        jq -r '.agents[] | select(.status == "active" or .status == "implementing" or .status == "researching" or .status == "planning" or .status == "fixing") | "  \(.agent_id) | \(.task_id) | \(.status)"' "$REGISTRY_FILE"
        echo ""
    fi

    if [ "$JSON_OUTPUT" = true ]; then
        jq '{
          total: (.agents | length),
          active: [.agents[] | select(.status == "active" or .status == "implementing")] | length,
          completed: [.agents[] | select(.status == "completed")] | length,
          failed: [.agents[] | select(.status == "failed" or .status == "timed_out")] | length,
          agents: .agents
        }' "$REGISTRY_FILE"
    fi
}

# Show dashboard
show_dashboard() {
    clear
    echo ""
    log_header "═══════════════════════════════════════════════════════════"
    log_header "               PO AGENT DASHBOARD"
    log_header "           $(date '+%Y-%m-%d %H:%M:%S')"
    log_header "═══════════════════════════════════════════════════════════"
    echo ""

    # Orchestrator state
    if [ -f "$STATE_FILE" ]; then
        local phase=$(jq -r '.current_phase // "UNKNOWN"' "$STATE_FILE")
        local mode=$(jq -r '.execution_mode // "unknown"' "$STATE_FILE")
        local paused=$(jq -r '.paused // false' "$STATE_FILE")

        echo "  Phase:       $phase"
        echo "  Mode:        $mode"
        echo "  Paused:      $paused"
        echo ""
    fi

    # Agent summary
    if [ -f "$REGISTRY_FILE" ]; then
        local current_epoch=$(get_current_epoch)

        log_header "┌─────────────┬─────────────┬──────────────┬────────────┐"
        log_header "│  Agent ID   │   Task ID   │    Status    │  Time Left │"
        log_header "├─────────────┼─────────────┼──────────────┼────────────┤"

        jq -r '.agents[] | "\(.agent_id)|\(.task_id)|\(.status)|\(.timeout_at // "")"' "$REGISTRY_FILE" | while IFS='|' read -r agent_id task_id status timeout_at; do
            local time_left="-"
            if [ -n "$timeout_at" ] && [ "$timeout_at" != "null" ]; then
                local timeout_epoch=$(iso_to_epoch "$timeout_at")
                if [ "$timeout_epoch" -gt 0 ]; then
                    local remaining=$((timeout_epoch - current_epoch))
                    if [ "$remaining" -gt 0 ]; then
                        time_left="${remaining}s"
                    else
                        time_left="TIMEOUT"
                    fi
                fi
            fi

            # Truncate for display
            agent_id="${agent_id:0:11}"
            task_id="${task_id:0:11}"
            status="${status:0:12}"

            printf "│ %-11s │ %-11s │ %-12s │ %10s │\n" "$agent_id" "$task_id" "$status" "$time_left"
        done

        log_header "└─────────────┴─────────────┴──────────────┴────────────┘"
    fi

    echo ""

    # Recent progress
    if [ -d "$PROGRESS_DIR" ]; then
        log_header "Recent Progress Updates:"
        echo ""
        for progress_file in "$PROGRESS_DIR"/*.json; do
            if [ -f "$progress_file" ] && [[ ! "$progress_file" =~ _assignment\.json$ ]] && [[ ! "$progress_file" =~ _spawn_result\.json$ ]]; then
                local agent=$(jq -r '.agent_id // "unknown"' "$progress_file" 2>/dev/null)
                local activity=$(jq -r '.current_activity // "unknown"' "$progress_file" 2>/dev/null)
                local percent=$(jq -r '.progress_percent // 0' "$progress_file" 2>/dev/null)

                echo "  $agent: ${percent}% - ${activity:0:50}"
            fi
        done 2>/dev/null || echo "  No progress files found"
    fi

    echo ""
    echo "  Press Ctrl+C to exit"
}

# Find stale agents (no progress in 10 minutes)
find_stale_agents() {
    local stale_threshold=600  # 10 minutes in seconds
    local current_epoch=$(get_current_epoch)

    echo ""
    log_header "Checking for stale agents (no update in 10 minutes)..."
    echo ""

    if [ ! -f "$REGISTRY_FILE" ]; then
        log_warn "No agent registry found"
        return 0
    fi

    local stale_count=0

    jq -c '.agents[] | select(.status == "active" or .status == "implementing")' "$REGISTRY_FILE" | while IFS= read -r agent; do
        local agent_id=$(echo "$agent" | jq -r '.agent_id')
        local last_progress=$(echo "$agent" | jq -r '.last_progress // empty')

        if [ -n "$last_progress" ]; then
            local progress_epoch=$(iso_to_epoch "$last_progress")
            local since=$((current_epoch - progress_epoch))

            if [ "$since" -gt "$stale_threshold" ]; then
                local since_min=$((since / 60))
                log_warn "Agent $agent_id is STALE - no update for $since_min minutes"
                stale_count=$((stale_count + 1))
            fi
        fi
    done

    if [ "$stale_count" -eq 0 ]; then
        log_info "No stale agents found"
    fi
}

# Run all health checks
run_health_checks() {
    echo ""
    log_header "═══════════════════════════════════════════════════════════"
    log_header "                 AGENT HEALTH CHECK"
    log_header "═══════════════════════════════════════════════════════════"
    echo ""

    # 1. Check timeouts
    log_info "Checking timeouts..."
    "$FACTORY_ROOT/scripts/po/check_agent_timeouts.sh" --dry-run 2>/dev/null || log_warn "Timeout check failed"
    echo ""

    # 2. Check for stale agents
    log_info "Checking for stale agents..."
    find_stale_agents
    echo ""

    # 3. Check worktree health
    log_info "Checking worktrees..."
    if [ -f "$FACTORY_ROOT/scripts/agents/worktree_manager.sh" ]; then
        "$FACTORY_ROOT/scripts/agents/worktree_manager.sh" status 2>/dev/null || log_warn "Worktree check failed"
    fi
    echo ""

    # 4. Check for orphaned progress files
    log_info "Checking for orphaned files..."
    if [ -d "$PROGRESS_DIR" ]; then
        local orphan_count=0
        for progress_file in "$PROGRESS_DIR"/*.json; do
            if [ -f "$progress_file" ] && [[ ! "$progress_file" =~ _assignment\.json$ ]] && [[ ! "$progress_file" =~ _spawn_result\.json$ ]]; then
                local agent_id=$(basename "$progress_file" .json)
                local in_registry=$(jq --arg id "$agent_id" '[.agents[] | select(.agent_id == $id)] | length' "$REGISTRY_FILE" 2>/dev/null || echo "0")
                if [ "$in_registry" -eq 0 ]; then
                    log_warn "Orphaned progress file: $progress_file"
                    orphan_count=$((orphan_count + 1))
                fi
            fi
        done 2>/dev/null
        if [ "$orphan_count" -eq 0 ]; then
            log_info "No orphaned files found"
        fi
    fi

    echo ""
    log_info "Health check complete"
}

# Cleanup completed/failed agents
cleanup_agents() {
    echo ""
    log_header "Cleaning up completed/failed agents..."
    echo ""

    if [ ! -f "$REGISTRY_FILE" ]; then
        log_warn "No agent registry found"
        return 0
    fi

    local cleaned=0

    # Get agents to clean
    jq -c '.agents[] | select(.status == "completed" or .status == "failed" or .status == "timed_out")' "$REGISTRY_FILE" | while IFS= read -r agent; do
        local agent_id=$(echo "$agent" | jq -r '.agent_id')
        local task_id=$(echo "$agent" | jq -r '.task_id')
        local worktree=$(echo "$agent" | jq -r '.worktree_path // empty')

        log_info "Cleaning up agent $agent_id ($task_id)..."

        # Remove worktree if exists
        if [ -n "$worktree" ] && [ -d "$worktree" ]; then
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would remove worktree: $worktree"
            else
                git worktree remove "$worktree" --force 2>/dev/null || log_warn "Could not remove worktree: $worktree"
            fi
        fi

        # Archive progress files
        local progress_file="$PROGRESS_DIR/${agent_id}.json"
        if [ -f "$progress_file" ]; then
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would archive: $progress_file"
            else
                mkdir -p "$PROGRESS_DIR/archive"
                mv "$progress_file" "$PROGRESS_DIR/archive/" 2>/dev/null || true
            fi
        fi

        cleaned=$((cleaned + 1))
    done

    # Remove cleaned agents from registry
    if [ "$DRY_RUN" != true ]; then
        jq '.agents = [.agents[] | select(.status != "completed" and .status != "failed" and .status != "timed_out")]' \
           "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp" && mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"
    fi

    log_info "Cleanup complete"
}

# Parse arguments
COMMAND="status"
LOOP_INTERVAL=0
JSON_OUTPUT=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        status|dashboard|check|stale|timeouts|cleanup)
            COMMAND="$1"
            shift
            ;;
        --loop)
            LOOP_INTERVAL="$2"
            shift 2
            ;;
        --json)
            JSON_OUTPUT=true
            shift
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

# Main
main() {
    case $COMMAND in
        status)
            if [ "$LOOP_INTERVAL" -gt 0 ]; then
                while true; do
                    show_status
                    sleep "$LOOP_INTERVAL"
                done
            else
                show_status
            fi
            ;;
        dashboard)
            if [ "$LOOP_INTERVAL" -gt 0 ]; then
                while true; do
                    show_dashboard
                    sleep "$LOOP_INTERVAL"
                done
            else
                show_dashboard
            fi
            ;;
        check)
            run_health_checks
            ;;
        stale)
            find_stale_agents
            ;;
        timeouts)
            "$FACTORY_ROOT/scripts/po/check_agent_timeouts.sh" "$@"
            ;;
        cleanup)
            cleanup_agents
            ;;
    esac
}

main
