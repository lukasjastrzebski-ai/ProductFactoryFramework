#!/usr/bin/env bash
set -euo pipefail

#############################################
# Notion Parser
# Converts Notion markdown/JSON to factory format
#############################################

INPUT_FILE="$1"
OUTPUT_DIR="$2"

FILENAME=$(basename "$INPUT_FILE")
EXTENSION="${FILENAME##*.}"
BASENAME="${FILENAME%.*}"

# Detect content type from filename or content
detect_content_type() {
    local file="$1"
    local filename=$(basename "$file" | tr '[:upper:]' '[:lower:]')

    case "$filename" in
        *vision*) echo "vision" ;;
        *strategy*) echo "strategy" ;;
        *metric*) echo "metrics" ;;
        *risk*) echo "risks" ;;
        *persona*) echo "personas" ;;
        *journey*) echo "journeys" ;;
        *feature*) echo "features" ;;
        *requirement*) echo "requirements" ;;
        *decision*|*adr*) echo "decisions" ;;
        *task*|*issue*) echo "tasks" ;;
        *) echo "unknown" ;;
    esac
}

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

# Parse markdown file
parse_markdown() {
    local file="$1"
    local content_type=$(detect_content_type "$file")
    local output_file="$OUTPUT_DIR/notion_${BASENAME}.json"

    # Extract title (first H1)
    local title=$(grep -m1 "^# " "$file" 2>/dev/null | sed 's/^# //' || echo "$BASENAME")
    title=$(escape_json "$title")

    # Extract sections (H2 headers)
    local sections_json="[]"
    if grep -q "^## " "$file" 2>/dev/null; then
        sections_json=$(grep "^## " "$file" | sed 's/^## //' | while read -r s; do
            echo "\"$(escape_json "$s")\""
        done | paste -sd "," - | sed 's/^/[/' | sed 's/$/]/')
    fi

    # Extract acceptance criteria if present
    local has_ac="false"
    local ac_count=0
    if grep -q "^\- \[ \]" "$file" 2>/dev/null; then
        has_ac="true"
        ac_count=$(grep -c "^\- \[ \]" "$file" 2>/dev/null || echo "0")
    fi

    # Generate JSON output
    cat > "$output_file" << EOF
{
  "source": "notion",
  "source_file": "$FILENAME",
  "parsed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "content_type": "$content_type",
  "title": "$title",
  "sections": $sections_json,
  "has_acceptance_criteria": $has_ac,
  "acceptance_criteria_count": $ac_count,
  "raw_content_path": "$file"
}
EOF

    echo "Parsed: $file -> $output_file"
}

# Parse JSON export
parse_json() {
    local file="$1"
    local content_type=$(detect_content_type "$file")
    local output_file="$OUTPUT_DIR/notion_${BASENAME}_parsed.json"

    # Wrap with metadata
    cat > "$output_file" << EOF
{
  "source": "notion",
  "source_file": "$FILENAME",
  "parsed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "content_type": "$content_type",
  "data": $(cat "$file")
}
EOF

    echo "Parsed: $file -> $output_file"
}

# Main
case "$EXTENSION" in
    md|markdown)
        parse_markdown "$INPUT_FILE"
        ;;
    json)
        parse_json "$INPUT_FILE"
        ;;
    *)
        echo "Unsupported format: $EXTENSION"
        exit 1
        ;;
esac
