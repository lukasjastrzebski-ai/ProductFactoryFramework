#!/usr/bin/env bash
set -euo pipefail

#############################################
# Import System Test Runner
# Runs all import-related tests
#############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "  Import System Test Suite"
echo "=========================================="
echo ""

TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

run_test_suite() {
    local name="$1"
    local script="$2"

    TOTAL_SUITES=$((TOTAL_SUITES + 1))

    echo -e "${YELLOW}Running: $name${NC}"
    echo "----------------------------------------"

    if "$script"; then
        PASSED_SUITES=$((PASSED_SUITES + 1))
        echo -e "${GREEN}Suite passed: $name${NC}"
    else
        FAILED_SUITES=$((FAILED_SUITES + 1))
        echo -e "${RED}Suite failed: $name${NC}"
    fi

    echo ""
}

# Run test suites
run_test_suite "Structure Tests" "$SCRIPT_DIR/test_structure.sh"
run_test_suite "Parser Tests" "$SCRIPT_DIR/test_parsers.sh"
run_test_suite "Gap Analysis Tests" "$SCRIPT_DIR/test_gap_analysis.sh"

# Summary
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo -e "Total suites: $TOTAL_SUITES"
echo -e "Passed: ${GREEN}$PASSED_SUITES${NC}"
echo -e "Failed: ${RED}$FAILED_SUITES${NC}"
echo ""

if [ $FAILED_SUITES -eq 0 ]; then
    echo -e "${GREEN}All test suites passed!${NC}"
    exit 0
else
    echo -e "${RED}Some test suites failed!${NC}"
    exit 1
fi
