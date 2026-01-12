#!/usr/bin/env bash
set -euo pipefail

#############################################
# Parser Tests
# Tests for Notion, Figma, and Linear parsers
#############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
PARSERS_DIR="$REPO_ROOT/scripts/import/parsers"
OUTPUT_DIR=$(mktemp -d)

# Cleanup on exit
trap "rm -rf $OUTPUT_DIR" EXIT

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

PASSED=0
FAILED=0

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED=$((FAILED + 1))
}

echo "=== Parser Tests ==="
echo ""

#############################################
# Notion Parser Tests
#############################################
echo "--- Notion Parser ---"

# Test 1: Parse markdown file
if [ -f "$FIXTURES_DIR/notion/sample_vision.md" ]; then
    if "$PARSERS_DIR/notion_parser.sh" "$FIXTURES_DIR/notion/sample_vision.md" "$OUTPUT_DIR" > /dev/null 2>&1; then
        if [ -f "$OUTPUT_DIR/notion_sample_vision.json" ]; then
            pass "Notion parser creates JSON output for markdown"
        else
            fail "Notion parser did not create expected output file"
        fi
    else
        fail "Notion parser failed to run"
    fi
else
    fail "Test fixture notion/sample_vision.md not found"
fi

# Test 2: Verify content type detection
if [ -f "$OUTPUT_DIR/notion_sample_vision.json" ]; then
    if grep -q '"content_type": "vision"' "$OUTPUT_DIR/notion_sample_vision.json"; then
        pass "Notion parser correctly detects 'vision' content type"
    else
        fail "Notion parser did not detect 'vision' content type"
    fi
fi

# Test 3: Verify acceptance criteria detection
if [ -f "$OUTPUT_DIR/notion_sample_vision.json" ]; then
    if grep -q '"has_acceptance_criteria": true' "$OUTPUT_DIR/notion_sample_vision.json"; then
        pass "Notion parser detects acceptance criteria"
    else
        fail "Notion parser did not detect acceptance criteria"
    fi
fi

# Test 4: Verify title extraction
if [ -f "$OUTPUT_DIR/notion_sample_vision.json" ]; then
    if grep -q '"title":' "$OUTPUT_DIR/notion_sample_vision.json"; then
        pass "Notion parser extracts title"
    else
        fail "Notion parser did not extract title"
    fi
fi

# Test 5: Verify sections extraction
if [ -f "$OUTPUT_DIR/notion_sample_vision.json" ]; then
    if grep -q '"sections":' "$OUTPUT_DIR/notion_sample_vision.json"; then
        pass "Notion parser extracts sections"
    else
        fail "Notion parser did not extract sections"
    fi
fi

#############################################
# Linear Parser Tests
#############################################
echo ""
echo "--- Linear Parser ---"

# Test 6: Parse CSV file
if [ -f "$FIXTURES_DIR/linear/sample_issues.csv" ]; then
    if "$PARSERS_DIR/linear_parser.sh" "$FIXTURES_DIR/linear/sample_issues.csv" "$OUTPUT_DIR" > /dev/null 2>&1; then
        if [ -f "$OUTPUT_DIR/linear_sample_issues.json" ]; then
            pass "Linear parser creates JSON output for CSV"
        else
            fail "Linear parser did not create expected output file"
        fi
    else
        fail "Linear parser failed to run"
    fi
else
    fail "Test fixture linear/sample_issues.csv not found"
fi

# Test 7: Verify issue count
if [ -f "$OUTPUT_DIR/linear_sample_issues.json" ]; then
    if grep -q '"issue_count": 3' "$OUTPUT_DIR/linear_sample_issues.json"; then
        pass "Linear parser correctly counts issues"
    else
        fail "Linear parser did not count issues correctly"
    fi
fi

# Test 8: Verify content type
if [ -f "$OUTPUT_DIR/linear_sample_issues.json" ]; then
    if grep -q '"content_type": "tasks"' "$OUTPUT_DIR/linear_sample_issues.json"; then
        pass "Linear parser sets content type to 'tasks'"
    else
        fail "Linear parser did not set content type to 'tasks'"
    fi
fi

# Test 9: Verify AC detection
if [ -f "$OUTPUT_DIR/linear_sample_issues.json" ]; then
    if grep -q '"has_acceptance_criteria": true' "$OUTPUT_DIR/linear_sample_issues.json"; then
        pass "Linear parser detects acceptance criteria column"
    else
        fail "Linear parser did not detect acceptance criteria column"
    fi
fi

#############################################
# Figma Parser Tests
#############################################
echo ""
echo "--- Figma Parser ---"

# Create a test Figma fixture
FIGMA_FIXTURE="$OUTPUT_DIR/figma_test.md"
cat > "$FIGMA_FIXTURE" << 'EOF'
# Design Specification

## Screens

### Login Screen
- Components: Email, Password, Submit

### Dashboard
- Components: Header, Sidebar, Cards
EOF

# Test 10: Parse markdown design spec
if "$PARSERS_DIR/figma_parser.sh" "$FIGMA_FIXTURE" "$OUTPUT_DIR" > /dev/null 2>&1; then
    if [ -f "$OUTPUT_DIR/figma_figma_test.json" ]; then
        pass "Figma parser creates JSON output for markdown"
    else
        fail "Figma parser did not create expected output file"
    fi
else
    fail "Figma parser failed to run"
fi

# Test 11: Verify content type
if [ -f "$OUTPUT_DIR/figma_figma_test.json" ]; then
    if grep -q '"content_type": "design_documentation"' "$OUTPUT_DIR/figma_figma_test.json"; then
        pass "Figma parser sets correct content type"
    else
        fail "Figma parser did not set correct content type"
    fi
fi

#############################################
# Edge Cases
#############################################
echo ""
echo "--- Edge Cases ---"

# Test 12: Handle empty file gracefully
EMPTY_FILE="$OUTPUT_DIR/empty.md"
touch "$EMPTY_FILE"
if "$PARSERS_DIR/notion_parser.sh" "$EMPTY_FILE" "$OUTPUT_DIR" > /dev/null 2>&1; then
    pass "Parser handles empty file without crashing"
else
    fail "Parser crashed on empty file"
fi

# Test 13: Unsupported format returns error
UNSUPPORTED="$OUTPUT_DIR/test.xyz"
touch "$UNSUPPORTED"
if ! "$PARSERS_DIR/notion_parser.sh" "$UNSUPPORTED" "$OUTPUT_DIR" > /dev/null 2>&1; then
    pass "Parser rejects unsupported format"
else
    fail "Parser should reject unsupported format"
fi

echo ""
echo "=== Results ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All parser tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some parser tests failed!${NC}"
    exit 1
fi
