#!/bin/bash

# Agent Progress Reporter
# v20 Autonomous Execution Mode
#
# Updates agent progress file for PO monitoring.

set -e

FACTORY_ROOT="${FACTORY_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
FACTORY_DIR="$FACTORY_ROOT/.factory"
PROGRESS_DIR="$FACTORY_DIR/agent_progress"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[PROGRESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[PROGRESS]${NC} $1"; }
log_error() { echo -e "${RED}[PROGRESS]${NC} $1"; }

usage() {
    cat << EOF
Usage: report_progress.sh --agent AGENT_ID [OPTIONS]

Options:
    --agent AGENT_ID        Agent ID (required)
    --status STATUS         Status: initializing|researching|planning|
                                    awaiting_go|implementing|testing|
                                    reporting|awaiting_next|blocked
    --percent NUMBER        Progress percentage (0-100)
    --activity TEXT         Current activity description
    --file FILE             Add file to modified list
    --issue TEXT            Add issue/blocker
    --clear-issues          Clear all issues
    -h, --help              Show this help

Examples:
    report_progress.sh --agent agent-123 --status implementing --percent 50
    report_progress.sh --agent agent-123 --activity "Writing login component"
    report_progress.sh --agent agent-123 --file "src/login.ts" --file "src/login.test.ts"
    report_progress.sh --agent agent-123 --issue "Cannot find auth service"
EOF
    exit 1
}

# Parse arguments
AGENT_ID=""
STATUS=""
PERCENT=""
ACTIVITY=""
FILES=()
ISSUES=()
CLEAR_ISSUES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --agent)
            AGENT_ID="$2"
            shift 2
            ;;
        --status)
            STATUS="$2"
            shift 2
            ;;
        --percent)
            PERCENT="$2"
            shift 2
            ;;
        --activity)
            ACTIVITY="$2"
            shift 2
            ;;
        --file)
            FILES+=("$2")
            shift 2
            ;;
        --issue)
            ISSUES+=("$2")
            shift 2
            ;;
        --clear-issues)
            CLEAR_ISSUES=true
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

# Validate
if [ -z "$AGENT_ID" ]; then
    log_error "Agent ID is required"
    usage
fi

PROGRESS_FILE="$PROGRESS_DIR/${AGENT_ID}.json"

if [ ! -f "$PROGRESS_FILE" ]; then
    log_error "Progress file not found: $PROGRESS_FILE"
    exit 1
fi

# Update progress file
update_progress() {
    local temp_file="${PROGRESS_FILE}.tmp"

    # Read current content
    local current
    current=$(cat "$PROGRESS_FILE")

    # Update status if provided
    if [ -n "$STATUS" ]; then
        current=$(echo "$current" | jq --arg status "$STATUS" '.status = $status')
    fi

    # Update percent if provided
    if [ -n "$PERCENT" ]; then
        current=$(echo "$current" | jq --argjson percent "$PERCENT" '.progress_percent = $percent')
    fi

    # Update activity if provided
    if [ -n "$ACTIVITY" ]; then
        current=$(echo "$current" | jq --arg activity "$ACTIVITY" '.current_activity = $activity')
    fi

    # Add files if provided
    for file in "${FILES[@]}"; do
        current=$(echo "$current" | jq --arg file "$file" \
            'if (.files_modified | index($file)) then . else .files_modified += [$file] end')
    done

    # Clear or add issues
    if [ "$CLEAR_ISSUES" = true ]; then
        current=$(echo "$current" | jq '.issues = []')
    fi

    for issue in "${ISSUES[@]}"; do
        current=$(echo "$current" | jq --arg issue "$issue" '.issues += [$issue]')
    done

    # Update timestamp
    current=$(echo "$current" | jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.last_updated = $ts')

    # Write back
    echo "$current" > "$temp_file"
    mv "$temp_file" "$PROGRESS_FILE"

    log_info "Progress updated for $AGENT_ID"
}

# Also update agent registry status
update_registry() {
    local registry_file="$FACTORY_DIR/execution/agent_registry.json"

    if [ ! -f "$registry_file" ]; then
        return
    fi

    if [ -n "$STATUS" ]; then
        local temp_file="${registry_file}.tmp"

        jq --arg agent_id "$AGENT_ID" --arg status "$STATUS" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '(.agents[] | select(.agent_id == $agent_id)) |= (.status = $status | .last_progress = $ts) | .last_updated = $ts' \
           "$registry_file" > "$temp_file" && mv "$temp_file" "$registry_file"
    fi
}

# Show current progress
show_progress() {
    log_info "Current progress for $AGENT_ID:"
    jq '.' "$PROGRESS_FILE"
}

# Main
main() {
    update_progress
    update_registry
    show_progress
}

main
