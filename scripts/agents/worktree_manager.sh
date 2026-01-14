#!/bin/bash

# Git Worktree Manager
# v20 Autonomous Execution Mode
#
# Manages git worktrees for agent isolation.

set -e

FACTORY_ROOT="${FACTORY_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
FACTORY_DIR="$FACTORY_ROOT/.factory"
WORKTREES_DIR="${WORKTREES_DIR:-$FACTORY_ROOT/../worktrees}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[WORKTREE]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WORKTREE]${NC} $1"; }
log_error() { echo -e "${RED}[WORKTREE]${NC} $1"; }

usage() {
    cat << EOF
Usage: worktree_manager.sh COMMAND [OPTIONS]

Commands:
    create      Create a new worktree
    remove      Remove a worktree
    list        List all worktrees
    cleanup     Remove stale worktrees
    status      Show worktree status
    merge       Merge worktree branch to main

Options:
    --agent AGENT_ID    Agent ID
    --task TASK_ID      Task ID
    --path PATH         Worktree path
    --force             Force operation
    -h, --help          Show this help

Examples:
    worktree_manager.sh create --agent agent-123 --task TASK-001
    worktree_manager.sh remove --path ../worktrees/agent-123-TASK-001
    worktree_manager.sh cleanup --force
    worktree_manager.sh merge --agent agent-123 --task TASK-001
EOF
    exit 1
}

# Create worktree
cmd_create() {
    local agent_id=""
    local task_id=""
    local custom_path=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --agent) agent_id="$2"; shift 2 ;;
            --task) task_id="$2"; shift 2 ;;
            --path) custom_path="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [ -z "$agent_id" ] || [ -z "$task_id" ]; then
        log_error "Both --agent and --task are required"
        exit 1
    fi

    local worktree_path="${custom_path:-$WORKTREES_DIR/$agent_id-$task_id}"
    local branch_name="agent/$agent_id/$task_id"

    log_info "Creating worktree for $agent_id ($task_id)"

    # Create directory
    mkdir -p "$(dirname "$worktree_path")"

    # Determine base branch
    local base_branch="main"
    if ! git rev-parse --verify "$base_branch" &>/dev/null; then
        base_branch="master"
    fi

    # Create worktree with new branch
    if git worktree add "$worktree_path" -b "$branch_name" "$base_branch" 2>/dev/null; then
        log_info "Created worktree at $worktree_path"
        log_info "Branch: $branch_name"
    else
        # Try without creating branch (might exist)
        if git worktree add "$worktree_path" "$branch_name" 2>/dev/null; then
            log_info "Created worktree at $worktree_path (existing branch)"
        else
            log_error "Failed to create worktree"
            exit 1
        fi
    fi

    echo "$worktree_path"
}

# Remove worktree
cmd_remove() {
    local worktree_path=""
    local force=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --path) worktree_path="$2"; shift 2 ;;
            --force) force=true; shift ;;
            *) shift ;;
        esac
    done

    if [ -z "$worktree_path" ]; then
        log_error "--path is required"
        exit 1
    fi

    log_info "Removing worktree: $worktree_path"

    if [ "$force" = true ]; then
        git worktree remove --force "$worktree_path" 2>/dev/null || rm -rf "$worktree_path"
    else
        git worktree remove "$worktree_path" 2>/dev/null || {
            log_error "Failed to remove worktree. Use --force to force removal."
            exit 1
        }
    fi

    log_info "Worktree removed"
}

# List worktrees
cmd_list() {
    log_info "Listing worktrees:"
    echo ""

    git worktree list --porcelain | while read -r line; do
        if [[ $line == worktree* ]]; then
            path="${line#worktree }"
            echo "Path: $path"
        elif [[ $line == HEAD* ]]; then
            echo "HEAD: ${line#HEAD }"
        elif [[ $line == branch* ]]; then
            echo "Branch: ${line#branch refs/heads/}"
            echo "---"
        fi
    done

    echo ""
    log_info "Agent worktrees in $WORKTREES_DIR:"
    if [ -d "$WORKTREES_DIR" ]; then
        ls -la "$WORKTREES_DIR" 2>/dev/null || echo "  (empty)"
    else
        echo "  (directory not created yet)"
    fi
}

# Cleanup stale worktrees
cmd_cleanup() {
    local force=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --force) force=true; shift ;;
            *) shift ;;
        esac
    done

    log_info "Cleaning up stale worktrees..."

    # Prune worktrees with missing directories
    git worktree prune

    # Check for completed agents
    local registry_file="$FACTORY_DIR/execution/agent_registry.json"
    if [ -f "$registry_file" ]; then
        # Get completed/blocked agents
        local stale_agents=$(jq -r '.agents[] | select(.status == "completed" or .status == "blocked") | .worktree_path' "$registry_file" 2>/dev/null || echo "")

        for path in $stale_agents; do
            if [ -d "$path" ]; then
                log_info "Found stale worktree: $path"
                if [ "$force" = true ]; then
                    git worktree remove --force "$path" 2>/dev/null || rm -rf "$path"
                    log_info "  Removed"
                else
                    log_warn "  Use --force to remove"
                fi
            fi
        done
    fi

    # Check for orphaned worktrees in worktrees directory
    if [ -d "$WORKTREES_DIR" ]; then
        for dir in "$WORKTREES_DIR"/*; do
            if [ -d "$dir" ]; then
                # Check if it's a valid worktree
                if ! git worktree list --porcelain | grep -q "worktree $dir"; then
                    log_warn "Orphaned directory (not a git worktree): $dir"
                    if [ "$force" = true ]; then
                        rm -rf "$dir"
                        log_info "  Removed"
                    fi
                fi
            fi
        done
    fi

    log_info "Cleanup complete"
}

# Show worktree status
cmd_status() {
    log_info "Worktree Status"
    echo ""

    # Git worktree status
    echo "=== Git Worktrees ==="
    git worktree list
    echo ""

    # Agent registry status
    local registry_file="$FACTORY_DIR/execution/agent_registry.json"
    if [ -f "$registry_file" ]; then
        echo "=== Agent Worktrees ==="
        jq -r '.agents[] | "\(.agent_id) | \(.task_id) | \(.status) | \(.worktree_path)"' "$registry_file" 2>/dev/null | \
        while IFS='|' read -r agent task status path; do
            agent=$(echo "$agent" | xargs)
            task=$(echo "$task" | xargs)
            status=$(echo "$status" | xargs)
            path=$(echo "$path" | xargs)

            local exists="missing"
            if [ -d "$path" ]; then
                exists="exists"
            fi

            printf "%-15s %-12s %-12s %-8s %s\n" "$agent" "$task" "$status" "$exists" "$path"
        done
        echo ""
    fi

    # Disk usage
    if [ -d "$WORKTREES_DIR" ]; then
        echo "=== Disk Usage ==="
        du -sh "$WORKTREES_DIR" 2>/dev/null || echo "N/A"
    fi
}

# Merge worktree branch
cmd_merge() {
    local agent_id=""
    local task_id=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --agent) agent_id="$2"; shift 2 ;;
            --task) task_id="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [ -z "$agent_id" ] || [ -z "$task_id" ]; then
        log_error "Both --agent and --task are required"
        exit 1
    fi

    local branch_name="agent/$agent_id/$task_id"

    log_info "Preparing to merge branch: $branch_name"

    # Check branch exists
    if ! git rev-parse --verify "$branch_name" &>/dev/null; then
        log_error "Branch $branch_name does not exist"
        exit 1
    fi

    # Check for conflicts (dry-run merge)
    log_info "Checking for conflicts..."
    if ! git merge --no-commit --no-ff "$branch_name" &>/dev/null; then
        git merge --abort 2>/dev/null || true
        log_error "Merge would have conflicts. Manual resolution required."
        exit 1
    fi
    git merge --abort 2>/dev/null || true

    log_info "No conflicts detected. Ready to merge."
    log_info "To merge, run: git merge --no-ff $branch_name"
}

# Main
main() {
    if [ $# -eq 0 ]; then
        usage
    fi

    local command="$1"
    shift

    case "$command" in
        create)
            cmd_create "$@"
            ;;
        remove)
            cmd_remove "$@"
            ;;
        list)
            cmd_list "$@"
            ;;
        cleanup)
            cmd_cleanup "$@"
            ;;
        status)
            cmd_status "$@"
            ;;
        merge)
            cmd_merge "$@"
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown command: $command"
            usage
            ;;
    esac
}

main "$@"
