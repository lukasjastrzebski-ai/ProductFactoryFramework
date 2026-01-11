#!/bin/bash
# Report Signing Script
# Signs execution reports using SHA256 checksums for integrity verification

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
REPORTS_DIR="$REPO_ROOT/docs/execution/reports"
SIGNATURES_DIR="$REPO_ROOT/docs/execution/signatures"

usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  sign <report.md>     Sign a single report file"
    echo "  sign-all             Sign all unsigned reports"
    echo "  verify <report.md>   Verify a single report signature"
    echo "  verify-all           Verify all report signatures"
    echo "  list                 List all reports and their signature status"
    echo ""
    echo "Examples:"
    echo "  $0 sign docs/execution/reports/TASK-001.md"
    echo "  $0 verify TASK-001.md"
    echo "  $0 sign-all"
    exit 1
}

# Ensure signatures directory exists
mkdir -p "$SIGNATURES_DIR"

sign_report() {
    local report="$1"

    # Handle relative or absolute paths
    if [[ ! "$report" = /* ]]; then
        if [[ -f "$REPORTS_DIR/$report" ]]; then
            report="$REPORTS_DIR/$report"
        elif [[ -f "$REPO_ROOT/$report" ]]; then
            report="$REPO_ROOT/$report"
        fi
    fi

    if [[ ! -f "$report" ]]; then
        echo "ERROR: Report file not found: $report"
        return 1
    fi

    local basename=$(basename "$report" .md)
    local sig_file="$SIGNATURES_DIR/${basename}.sha256"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Generate signature with metadata
    {
        echo "# Report Signature"
        echo "# Generated: $timestamp"
        echo "# File: $report"
        sha256sum "$report" | awk '{print $1 "  " FILENAME}' FILENAME="$(basename "$report")"
    } > "$sig_file"

    echo "Signed: $report -> $sig_file"
}

verify_report() {
    local report="$1"

    # Handle relative or absolute paths
    if [[ ! "$report" = /* ]]; then
        if [[ -f "$REPORTS_DIR/$report" ]]; then
            report="$REPORTS_DIR/$report"
        elif [[ -f "$REPO_ROOT/$report" ]]; then
            report="$REPO_ROOT/$report"
        fi
    fi

    if [[ ! -f "$report" ]]; then
        echo "ERROR: Report file not found: $report"
        return 1
    fi

    local basename=$(basename "$report" .md)
    local sig_file="$SIGNATURES_DIR/${basename}.sha256"

    if [[ ! -f "$sig_file" ]]; then
        echo "UNSIGNED: $report (no signature file)"
        return 1
    fi

    # Extract stored hash (skip comment lines)
    local stored_hash=$(grep -v "^#" "$sig_file" | awk '{print $1}')
    local current_hash=$(sha256sum "$report" | awk '{print $1}')

    if [[ "$stored_hash" == "$current_hash" ]]; then
        echo "VALID: $report"
        return 0
    else
        echo "INVALID: $report (hash mismatch)"
        echo "  Expected: $stored_hash"
        echo "  Got:      $current_hash"
        return 1
    fi
}

sign_all() {
    echo "Signing all unsigned reports..."
    local signed=0
    local skipped=0

    for report in "$REPORTS_DIR"/*.md; do
        [[ -f "$report" ]] || continue
        local basename=$(basename "$report" .md)
        local sig_file="$SIGNATURES_DIR/${basename}.sha256"

        if [[ -f "$sig_file" ]]; then
            # Check if report was modified after signing
            local stored_hash=$(grep -v "^#" "$sig_file" | awk '{print $1}')
            local current_hash=$(sha256sum "$report" | awk '{print $1}')

            if [[ "$stored_hash" == "$current_hash" ]]; then
                echo "Skipping (already signed): $report"
                ((skipped++))
                continue
            else
                echo "Re-signing (modified): $report"
            fi
        fi

        sign_report "$report"
        ((signed++))
    done

    echo ""
    echo "Done: $signed signed, $skipped skipped"
}

verify_all() {
    echo "Verifying all report signatures..."
    local valid=0
    local invalid=0
    local unsigned=0

    for report in "$REPORTS_DIR"/*.md; do
        [[ -f "$report" ]] || continue

        if verify_report "$report"; then
            ((valid++))
        else
            local basename=$(basename "$report" .md)
            local sig_file="$SIGNATURES_DIR/${basename}.sha256"
            if [[ -f "$sig_file" ]]; then
                ((invalid++))
            else
                ((unsigned++))
            fi
        fi
    done

    echo ""
    echo "Summary: $valid valid, $invalid invalid, $unsigned unsigned"

    if [[ $invalid -gt 0 ]]; then
        return 1
    fi
    return 0
}

list_reports() {
    echo "Report Signature Status"
    echo "========================"
    printf "%-40s %s\n" "Report" "Status"
    printf "%-40s %s\n" "------" "------"

    for report in "$REPORTS_DIR"/*.md; do
        [[ -f "$report" ]] || continue
        local basename=$(basename "$report")
        local sig_file="$SIGNATURES_DIR/${basename%.md}.sha256"

        if [[ ! -f "$sig_file" ]]; then
            printf "%-40s %s\n" "$basename" "UNSIGNED"
        else
            local stored_hash=$(grep -v "^#" "$sig_file" | awk '{print $1}')
            local current_hash=$(sha256sum "$report" | awk '{print $1}')

            if [[ "$stored_hash" == "$current_hash" ]]; then
                printf "%-40s %s\n" "$basename" "VALID"
            else
                printf "%-40s %s\n" "$basename" "MODIFIED"
            fi
        fi
    done
}

# Main command dispatch
case "${1:-}" in
    sign)
        [[ -n "${2:-}" ]] || usage
        sign_report "$2"
        ;;
    sign-all)
        sign_all
        ;;
    verify)
        [[ -n "${2:-}" ]] || usage
        verify_report "$2"
        ;;
    verify-all)
        verify_all
        ;;
    list)
        list_reports
        ;;
    *)
        usage
        ;;
esac
