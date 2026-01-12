#!/usr/bin/env bash
set -euo pipefail

#############################################
# Linear Parser
# Converts Linear CSV/JSON exports to factory format
#############################################

INPUT_FILE="$1"
OUTPUT_DIR="$2"

FILENAME=$(basename "$INPUT_FILE")
EXTENSION="${FILENAME##*.}"
BASENAME="${FILENAME%.*}"

# Escape JSON string
escape_json() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\r'/}"
    str="${str//$'\t'/\\t}"
    echo "$str"
}

# Parse CSV export
parse_csv() {
    local file="$1"
    local output_file="$OUTPUT_DIR/linear_${BASENAME}.json"

    # Count rows (excluding header)
    local row_count=$(tail -n +2 "$file" | wc -l | tr -d ' ')

    # Extract headers
    local headers=$(head -1 "$file")
    local headers_escaped=$(escape_json "$headers")

    # Try to detect if there's an acceptance criteria column
    local has_ac="false"
    if echo "$headers" | grep -qi "acceptance\|criteria\|ac"; then
        has_ac="true"
    fi

    # Check for MVP or priority labels
    local has_priority="false"
    if echo "$headers" | grep -qi "priority\|mvp\|label"; then
        has_priority="true"
    fi

    cat > "$output_file" << EOF
{
  "source": "linear",
  "source_file": "$FILENAME",
  "parsed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "format": "csv",
  "issue_count": $row_count,
  "headers": "$headers_escaped",
  "has_acceptance_criteria": $has_ac,
  "has_priority_info": $has_priority,
  "content_type": "tasks",
  "raw_content_path": "$file"
}
EOF

    echo "Parsed: $file -> $output_file"
}

# Parse JSON export
parse_json() {
    local file="$1"
    local output_file="$OUTPUT_DIR/linear_${BASENAME}_parsed.json"

    # Count issues if array
    local issue_count=$(grep -c '"id":' "$file" 2>/dev/null || echo "0")

    # Check for acceptance criteria in content
    local has_ac="false"
    if grep -qi "acceptance\|criteria\|\- \[ \]" "$file" 2>/dev/null; then
        has_ac="true"
    fi

    cat > "$output_file" << EOF
{
  "source": "linear",
  "source_file": "$FILENAME",
  "parsed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "format": "json",
  "issue_count": $issue_count,
  "has_acceptance_criteria": $has_ac,
  "content_type": "tasks",
  "data": $(cat "$file")
}
EOF

    echo "Parsed: $file -> $output_file"
}

# Main
case "$EXTENSION" in
    csv)
        parse_csv "$INPUT_FILE"
        ;;
    json)
        parse_json "$INPUT_FILE"
        ;;
    *)
        echo "Unsupported format: $EXTENSION"
        exit 1
        ;;
esac
