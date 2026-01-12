#!/usr/bin/env bash
set -euo pipefail

#############################################
# Figma Parser
# Converts Figma exports to factory format
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

parse_figma() {
    local file="$1"
    local output_file="$OUTPUT_DIR/figma_${BASENAME}.json"

    # For JSON, extract key info
    if [ "$EXTENSION" = "json" ]; then
        local component_count=$(grep -c '"type":' "$file" 2>/dev/null || echo "0")

        cat > "$output_file" << EOF
{
  "source": "figma",
  "source_file": "$FILENAME",
  "parsed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "format": "json",
  "component_count": $component_count,
  "content_type": "ui_specs",
  "raw_content_path": "$file"
}
EOF
    else
        # Markdown design spec
        local title=$(grep -m1 "^# " "$file" 2>/dev/null | sed 's/^# //' || echo "$BASENAME")
        title=$(escape_json "$title")

        # Count screens/components mentioned
        local screen_count=$(grep -c "^### " "$file" 2>/dev/null || echo "0")

        cat > "$output_file" << EOF
{
  "source": "figma",
  "source_file": "$FILENAME",
  "parsed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "format": "markdown",
  "title": "$title",
  "screen_count": $screen_count,
  "content_type": "design_documentation",
  "raw_content_path": "$file"
}
EOF
    fi

    echo "Parsed: $file -> $output_file"
}

parse_figma "$INPUT_FILE"
