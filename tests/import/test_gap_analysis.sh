#!/usr/bin/env bash
set -euo pipefail

#############################################
# Gap Analysis Tests
# Tests for the gap analysis system
#############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
IMPORT_DIR="$REPO_ROOT/docs/import"
ANALYZE_SCRIPT="$REPO_ROOT/scripts/import/analyze_gaps.sh"
PARSE_SCRIPT="$REPO_ROOT/scripts/import/parse_docs.sh"

# Create temp directories for testing
TEMP_PARSED=$(mktemp -d)
TEMP_VALIDATION=$(mktemp -d)

# Backup and restore functions
backup_dirs() {
    if [ -d "$IMPORT_DIR/parsed" ] && [ "$(ls -A $IMPORT_DIR/parsed 2>/dev/null)" ]; then
        cp -r "$IMPORT_DIR/parsed" "$TEMP_PARSED/backup"
    fi
    if [ -f "$IMPORT_DIR/validation/gap_analysis.md" ]; then
        cp "$IMPORT_DIR/validation/gap_analysis.md" "$TEMP_VALIDATION/gap_analysis.md.backup"
    fi
}

restore_dirs() {
    rm -f "$IMPORT_DIR/parsed"/*.json 2>/dev/null || true
    if [ -d "$TEMP_PARSED/backup" ]; then
        cp -r "$TEMP_PARSED/backup"/* "$IMPORT_DIR/parsed/" 2>/dev/null || true
    fi
    if [ -f "$TEMP_VALIDATION/gap_analysis.md.backup" ]; then
        cp "$TEMP_VALIDATION/gap_analysis.md.backup" "$IMPORT_DIR/validation/gap_analysis.md"
    fi
}

# Cleanup on exit
trap "restore_dirs; rm -rf $TEMP_PARSED $TEMP_VALIDATION" EXIT

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

echo "=== Gap Analysis Tests ==="
echo ""

# Backup existing state
backup_dirs

#############################################
# Test 1: Empty parsed directory
#############################################
echo "--- Test: Empty Parsed Directory ---"

rm -f "$IMPORT_DIR/parsed"/*.json 2>/dev/null || true

if "$ANALYZE_SCRIPT" > /dev/null 2>&1; then
    # Should have blocking gap for no content
    if [ -f "$IMPORT_DIR/validation/gap_analysis.md" ]; then
        if grep -q "BLOCKING" "$IMPORT_DIR/validation/gap_analysis.md"; then
            pass "Gap analysis detects missing content as BLOCKING"
        else
            fail "Gap analysis should report BLOCKING for empty parsed"
        fi
    else
        fail "Gap analysis did not create report"
    fi
else
    # Exit code 1 is expected for blocking gaps
    if [ -f "$IMPORT_DIR/validation/gap_analysis.md" ]; then
        pass "Gap analysis correctly exits with error for blocking gaps"
    else
        fail "Gap analysis should create report even with blocking gaps"
    fi
fi

#############################################
# Test 2: With vision content
#############################################
echo ""
echo "--- Test: With Vision Content ---"

# Copy fixture and parse
cp "$FIXTURES_DIR/notion/sample_vision.md" "$IMPORT_DIR/sources/notion/"
"$PARSE_SCRIPT" > /dev/null 2>&1

if "$ANALYZE_SCRIPT" > /dev/null 2>&1; then
    pass "Gap analysis runs with vision content"
else
    # Check if vision gap is NOT present
    if [ -f "$IMPORT_DIR/validation/gap_analysis.md" ]; then
        if ! grep -q "BLOCKING: vision" "$IMPORT_DIR/validation/gap_analysis.md"; then
            pass "Vision content removes vision gap"
        else
            fail "Vision gap should not be present with vision content"
        fi
    fi
fi

# Cleanup
rm -f "$IMPORT_DIR/sources/notion/sample_vision.md"
rm -f "$IMPORT_DIR/parsed"/*.json

#############################################
# Test 3: Gap severity ordering
#############################################
echo ""
echo "--- Test: Gap Severity Categories ---"

# Parse with fixture
cp "$FIXTURES_DIR/notion/sample_vision.md" "$IMPORT_DIR/sources/notion/"
"$PARSE_SCRIPT" > /dev/null 2>&1
"$ANALYZE_SCRIPT" > /dev/null 2>&1 || true

if [ -f "$IMPORT_DIR/validation/gap_analysis.md" ]; then
    # Check for different severity levels
    has_blocking=false
    has_high=false
    has_medium=false

    grep -q "BLOCKING" "$IMPORT_DIR/validation/gap_analysis.md" && has_blocking=true
    grep -q "HIGH" "$IMPORT_DIR/validation/gap_analysis.md" && has_high=true
    grep -q "MEDIUM" "$IMPORT_DIR/validation/gap_analysis.md" && has_medium=true

    if [ "$has_blocking" = true ] || [ "$has_high" = true ] || [ "$has_medium" = true ]; then
        pass "Gap analysis categorizes gaps by severity"
    else
        fail "Gap analysis should categorize gaps by severity"
    fi
else
    fail "Gap analysis report not created"
fi

# Cleanup
rm -f "$IMPORT_DIR/sources/notion/sample_vision.md"
rm -f "$IMPORT_DIR/parsed"/*.json

#############################################
# Test 4: Report structure
#############################################
echo ""
echo "--- Test: Report Structure ---"

# Parse minimal content
cp "$FIXTURES_DIR/notion/sample_vision.md" "$IMPORT_DIR/sources/notion/"
"$PARSE_SCRIPT" > /dev/null 2>&1
"$ANALYZE_SCRIPT" > /dev/null 2>&1 || true

if [ -f "$IMPORT_DIR/validation/gap_analysis.md" ]; then
    # Check for required sections
    sections_ok=true

    grep -q "Executive Summary" "$IMPORT_DIR/validation/gap_analysis.md" || sections_ok=false
    grep -q "Gap Details" "$IMPORT_DIR/validation/gap_analysis.md" || sections_ok=false
    grep -q "Next Steps" "$IMPORT_DIR/validation/gap_analysis.md" || sections_ok=false
    grep -q "Resolution Commands" "$IMPORT_DIR/validation/gap_analysis.md" || sections_ok=false

    if [ "$sections_ok" = true ]; then
        pass "Gap report contains all required sections"
    else
        fail "Gap report missing required sections"
    fi
else
    fail "Gap analysis report not created"
fi

# Cleanup
rm -f "$IMPORT_DIR/sources/notion/sample_vision.md"
rm -f "$IMPORT_DIR/parsed"/*.json

#############################################
# Test 5: Gap questions present
#############################################
echo ""
echo "--- Test: Gap Questions ---"

cp "$FIXTURES_DIR/notion/sample_vision.md" "$IMPORT_DIR/sources/notion/"
"$PARSE_SCRIPT" > /dev/null 2>&1
"$ANALYZE_SCRIPT" > /dev/null 2>&1 || true

if [ -f "$IMPORT_DIR/validation/gap_analysis.md" ]; then
    if grep -q "Question for PO:" "$IMPORT_DIR/validation/gap_analysis.md"; then
        pass "Gap report includes questions for PO"
    else
        fail "Gap report should include questions for PO"
    fi
else
    fail "Gap analysis report not created"
fi

# Cleanup
rm -f "$IMPORT_DIR/sources/notion/sample_vision.md"
rm -f "$IMPORT_DIR/parsed"/*.json

#############################################
# Test 6: Resolution instructions
#############################################
echo ""
echo "--- Test: Resolution Instructions ---"

cp "$FIXTURES_DIR/notion/sample_vision.md" "$IMPORT_DIR/sources/notion/"
"$PARSE_SCRIPT" > /dev/null 2>&1
"$ANALYZE_SCRIPT" > /dev/null 2>&1 || true

if [ -f "$IMPORT_DIR/validation/gap_analysis.md" ]; then
    if grep -q "FILL:" "$IMPORT_DIR/validation/gap_analysis.md"; then
        pass "Gap report includes FILL command template"
    else
        fail "Gap report should include FILL command template"
    fi
else
    fail "Gap analysis report not created"
fi

# Final cleanup
rm -f "$IMPORT_DIR/sources/notion/sample_vision.md"
rm -f "$IMPORT_DIR/parsed"/*.json

echo ""
echo "=== Results ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All gap analysis tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some gap analysis tests failed!${NC}"
    exit 1
fi
