#!/usr/bin/env bash
set -euo pipefail

#############################################
# External Documentation Parser
# Orchestrates parsing of Notion, Figma, Linear exports
#############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
IMPORT_DIR="$REPO_ROOT/docs/import"
SOURCES_DIR="$IMPORT_DIR/sources"
PARSED_DIR="$IMPORT_DIR/parsed"
REPORT="$IMPORT_DIR/validation/import_report.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Initialize
mkdir -p "$PARSED_DIR"
mkdir -p "$(dirname "$REPORT")"

# Initialize report
cat > "$REPORT" << EOF
# Import Report

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Status:** Processing

---

## Sources Detected

EOF

TOTAL_FILES=0
PARSED_FILES=0
FAILED_FILES=0

#############################################
# Parse Notion exports
#############################################
parse_notion() {
    local notion_dir="$SOURCES_DIR/notion"
    [ -d "$notion_dir" ] || return 0

    local files_found=0

    echo "### Notion" >> "$REPORT"
    echo "" >> "$REPORT"

    # Process markdown files
    while IFS= read -r -d '' file; do
        files_found=$((files_found + 1))
        TOTAL_FILES=$((TOTAL_FILES + 1))

        local basename=$(basename "$file")
        log_info "Parsing Notion: $basename"

        if "$SCRIPT_DIR/parsers/notion_parser.sh" "$file" "$PARSED_DIR"; then
            echo "- ✅ $basename" >> "$REPORT"
            PARSED_FILES=$((PARSED_FILES + 1))
        else
            echo "- ❌ $basename (parse failed)" >> "$REPORT"
            FAILED_FILES=$((FAILED_FILES + 1))
        fi
    done < <(find "$notion_dir" -type f \( -name "*.md" -o -name "*.json" \) ! -name ".gitkeep" -print0 2>/dev/null)

    if [ $files_found -eq 0 ]; then
        echo "- No files found" >> "$REPORT"
    fi
    echo "" >> "$REPORT"
}

#############################################
# Parse Figma exports
#############################################
parse_figma() {
    local figma_dir="$SOURCES_DIR/figma"
    [ -d "$figma_dir" ] || return 0

    local files_found=0

    echo "### Figma" >> "$REPORT"
    echo "" >> "$REPORT"

    while IFS= read -r -d '' file; do
        files_found=$((files_found + 1))
        TOTAL_FILES=$((TOTAL_FILES + 1))

        local basename=$(basename "$file")
        log_info "Parsing Figma: $basename"

        if "$SCRIPT_DIR/parsers/figma_parser.sh" "$file" "$PARSED_DIR"; then
            echo "- ✅ $basename" >> "$REPORT"
            PARSED_FILES=$((PARSED_FILES + 1))
        else
            echo "- ❌ $basename (parse failed)" >> "$REPORT"
            FAILED_FILES=$((FAILED_FILES + 1))
        fi
    done < <(find "$figma_dir" -type f \( -name "*.json" -o -name "*.md" \) ! -name ".gitkeep" -print0 2>/dev/null)

    if [ $files_found -eq 0 ]; then
        echo "- No files found" >> "$REPORT"
    fi
    echo "" >> "$REPORT"
}

#############################################
# Parse Linear exports
#############################################
parse_linear() {
    local linear_dir="$SOURCES_DIR/linear"
    [ -d "$linear_dir" ] || return 0

    local files_found=0

    echo "### Linear" >> "$REPORT"
    echo "" >> "$REPORT"

    while IFS= read -r -d '' file; do
        files_found=$((files_found + 1))
        TOTAL_FILES=$((TOTAL_FILES + 1))

        local basename=$(basename "$file")
        log_info "Parsing Linear: $basename"

        if "$SCRIPT_DIR/parsers/linear_parser.sh" "$file" "$PARSED_DIR"; then
            echo "- ✅ $basename" >> "$REPORT"
            PARSED_FILES=$((PARSED_FILES + 1))
        else
            echo "- ❌ $basename (parse failed)" >> "$REPORT"
            FAILED_FILES=$((FAILED_FILES + 1))
        fi
    done < <(find "$linear_dir" -type f \( -name "*.csv" -o -name "*.json" \) ! -name ".gitkeep" -print0 2>/dev/null)

    if [ $files_found -eq 0 ]; then
        echo "- No files found" >> "$REPORT"
    fi
    echo "" >> "$REPORT"
}

#############################################
# Main execution
#############################################

log_info "Starting external documentation import..."
log_info "Sources directory: $SOURCES_DIR"
log_info "Output directory: $PARSED_DIR"

parse_notion
parse_figma
parse_linear

# Finalize report
cat >> "$REPORT" << EOF
---

## Summary

| Metric | Count |
|--------|-------|
| Total files detected | $TOTAL_FILES |
| Successfully parsed | $PARSED_FILES |
| Failed to parse | $FAILED_FILES |

**Status:** $([ $FAILED_FILES -eq 0 ] && echo "✅ Complete" || echo "⚠️ Completed with errors")

---

## Parsed Content

EOF

# List parsed files
if [ -d "$PARSED_DIR" ]; then
    echo "### Generated Files" >> "$REPORT"
    echo "" >> "$REPORT"
    for parsed in "$PARSED_DIR"/*.json; do
        [ -f "$parsed" ] || continue
        echo "- $(basename "$parsed")" >> "$REPORT"
    done
fi

cat >> "$REPORT" << EOF

---

## Next Steps

1. Review parsed content in \`docs/import/parsed/\`
2. Run gap analysis: \`./scripts/import/analyze_gaps.sh\`
3. Review gaps: \`docs/import/validation/gap_analysis.md\`
4. Iterate with Claude to resolve gaps

EOF

log_info "Import complete!"
log_info "Report: $REPORT"
log_info "Files: $PARSED_FILES/$TOTAL_FILES parsed successfully"

[ $FAILED_FILES -eq 0 ] || exit 1
