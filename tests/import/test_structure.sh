#!/usr/bin/env bash
set -euo pipefail

#############################################
# Import Structure Tests
# Validates directory structure and required files
#############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
IMPORT_DIR="$REPO_ROOT/docs/import"

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

echo "=== Import Structure Tests ==="
echo ""

# Test 1: Import directory exists
if [ -d "$IMPORT_DIR" ]; then
    pass "docs/import/ directory exists"
else
    fail "docs/import/ directory does not exist"
fi

# Test 2: README exists
if [ -f "$IMPORT_DIR/README.md" ]; then
    pass "docs/import/README.md exists"
else
    fail "docs/import/README.md does not exist"
fi

# Test 3: Config exists and is valid JSON
if [ -f "$IMPORT_DIR/config.json" ]; then
    if python3 -c "import json; json.load(open('$IMPORT_DIR/config.json'))" 2>/dev/null; then
        pass "docs/import/config.json exists and is valid JSON"
    else
        fail "docs/import/config.json is not valid JSON"
    fi
else
    fail "docs/import/config.json does not exist"
fi

# Test 4: Sources directories exist
for dir in notion figma linear other; do
    if [ -d "$IMPORT_DIR/sources/$dir" ]; then
        pass "docs/import/sources/$dir/ exists"
    else
        fail "docs/import/sources/$dir/ does not exist"
    fi
done

# Test 5: Parsed directory exists
if [ -d "$IMPORT_DIR/parsed" ]; then
    pass "docs/import/parsed/ directory exists"
else
    fail "docs/import/parsed/ directory does not exist"
fi

# Test 6: Validation directory exists
if [ -d "$IMPORT_DIR/validation" ]; then
    pass "docs/import/validation/ directory exists"
else
    fail "docs/import/validation/ directory does not exist"
fi

# Test 7: Templates directory exists
if [ -d "$IMPORT_DIR/templates" ]; then
    pass "docs/import/templates/ directory exists"
else
    fail "docs/import/templates/ directory does not exist"
fi

# Test 8: Export guides exist
for guide in notion_export_guide.md figma_export_guide.md linear_export_guide.md; do
    if [ -f "$IMPORT_DIR/templates/$guide" ]; then
        pass "docs/import/templates/$guide exists"
    else
        fail "docs/import/templates/$guide does not exist"
    fi
done

# Test 9: Scripts exist and are executable
SCRIPTS_DIR="$REPO_ROOT/scripts/import"
if [ -x "$SCRIPTS_DIR/parse_docs.sh" ]; then
    pass "scripts/import/parse_docs.sh exists and is executable"
else
    fail "scripts/import/parse_docs.sh does not exist or is not executable"
fi

if [ -x "$SCRIPTS_DIR/analyze_gaps.sh" ]; then
    pass "scripts/import/analyze_gaps.sh exists and is executable"
else
    fail "scripts/import/analyze_gaps.sh does not exist or is not executable"
fi

# Test 10: Parsers exist and are executable
for parser in notion_parser.sh figma_parser.sh linear_parser.sh; do
    if [ -x "$SCRIPTS_DIR/parsers/$parser" ]; then
        pass "scripts/import/parsers/$parser exists and is executable"
    else
        fail "scripts/import/parsers/$parser does not exist or is not executable"
    fi
done

# Test 11: Skills exist
SKILLS_DIR="$REPO_ROOT/docs/skills"
for skill in skill_11_external_doc_import.md skill_12_gap_analysis.md skill_13_gap_resolution.md; do
    if [ -f "$SKILLS_DIR/$skill" ]; then
        pass "docs/skills/$skill exists"
    else
        fail "docs/skills/$skill does not exist"
    fi
done

# Test 12: Resolution progress template exists
if [ -f "$IMPORT_DIR/validation/resolution_progress.json" ]; then
    if python3 -c "import json; json.load(open('$IMPORT_DIR/validation/resolution_progress.json'))" 2>/dev/null; then
        pass "docs/import/validation/resolution_progress.json exists and is valid JSON"
    else
        fail "docs/import/validation/resolution_progress.json is not valid JSON"
    fi
else
    fail "docs/import/validation/resolution_progress.json does not exist"
fi

# Test 13: Gap analysis guide exists
if [ -f "$IMPORT_DIR/validation/gap_analysis_guide.md" ]; then
    pass "docs/import/validation/gap_analysis_guide.md exists"
else
    fail "docs/import/validation/gap_analysis_guide.md does not exist"
fi

echo ""
echo "=== Results ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All structure tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some structure tests failed!${NC}"
    exit 1
fi
