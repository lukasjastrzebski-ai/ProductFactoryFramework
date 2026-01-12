#!/usr/bin/env bash
set -euo pipefail

# Enable nullglob to handle empty glob patterns gracefully
shopt -s nullglob

#############################################
# Gap Analysis Engine
# Validates imported content against factory requirements
#############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
IMPORT_DIR="$REPO_ROOT/docs/import"
PARSED_DIR="$IMPORT_DIR/parsed"
CONFIG_FILE="$IMPORT_DIR/config.json"
GAP_REPORT="$IMPORT_DIR/validation/gap_analysis.md"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Initialize counters
BLOCKING_GAPS=0
HIGH_GAPS=0
MEDIUM_GAPS=0
LOW_GAPS=0

# Initialize report
mkdir -p "$(dirname "$GAP_REPORT")"

REPORT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$GAP_REPORT" << 'EOF'
# Gap Analysis Report

**Generated:** DATE_PLACEHOLDER
**Status:** Analyzing...

---

## Executive Summary

| Severity | Count | Action Required |
|----------|-------|-----------------|
| BLOCKING | BLOCKING_COUNT | Must resolve before execution |
| HIGH | HIGH_COUNT | Should resolve |
| MEDIUM | MEDIUM_COUNT | Recommended |
| LOW | LOW_COUNT | Optional |

---

## Gap Details

EOF

# Replace date placeholder
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/DATE_PLACEHOLDER/$REPORT_DATE/" "$GAP_REPORT"
else
    sed -i "s/DATE_PLACEHOLDER/$REPORT_DATE/" "$GAP_REPORT"
fi

#############################################
# Helper: Add gap to report
#############################################
add_gap() {
    local severity="$1"
    local id="$2"
    local description="$3"
    local question="$4"

    local icon=""
    case "$severity" in
        BLOCKING)
            icon="🔴"
            BLOCKING_GAPS=$((BLOCKING_GAPS + 1))
            ;;
        HIGH)
            icon="🟠"
            HIGH_GAPS=$((HIGH_GAPS + 1))
            ;;
        MEDIUM)
            icon="🟡"
            MEDIUM_GAPS=$((MEDIUM_GAPS + 1))
            ;;
        LOW)
            icon="🟢"
            LOW_GAPS=$((LOW_GAPS + 1))
            ;;
    esac

    cat >> "$GAP_REPORT" << EOF

### $icon $severity: $id

**Description:** $description

**Question for PO:**
> $question

**Resolution:**
\`\`\`
FILL: $id [your response here]
\`\`\`

---
EOF
}

#############################################
# Check if content type exists in parsed files
#############################################
check_content_exists() {
    local content_type="$1"
    local severity="$2"
    local description="$3"
    local question="$4"

    local found=false

    for parsed in "$PARSED_DIR"/*.json; do
        [ -f "$parsed" ] || continue
        if grep -q "\"content_type\": \"$content_type\"" "$parsed" 2>/dev/null; then
            found=true
            break
        fi
    done

    if [ "$found" = false ]; then
        add_gap "$severity" "$content_type" "$description" "$question"
        return 1
    fi
    return 0
}

#############################################
# Check for any parsed content
#############################################
check_any_content() {
    local count=0
    for parsed in "$PARSED_DIR"/*.json; do
        [ -f "$parsed" ] || continue
        count=$((count + 1))
    done
    echo $count
}

#############################################
# Stage 0: Idea Intake
#############################################
validate_stage_0() {
    log_info "Checking Stage 0: Idea Intake..."

    check_content_exists "vision" "BLOCKING" \
        "Product vision not found in imported documentation" \
        "What is the core product vision? What problem are you solving and for whom?" || true
}

#############################################
# Stage 1: Vision, Strategy, Metrics, Risks
#############################################
validate_stage_1() {
    log_info "Checking Stage 1: Vision & Strategy..."

    check_content_exists "strategy" "HIGH" \
        "Product strategy not found" \
        "What is your go-to-market strategy? How will this product succeed?" || true

    check_content_exists "metrics" "HIGH" \
        "Success metrics not defined" \
        "What metrics will indicate product success? (e.g., DAU, retention, conversion)" || true

    check_content_exists "risks" "MEDIUM" \
        "Risk assessment not found" \
        "What are the key risks to this product's success? Technical, market, or operational?" || true
}

#############################################
# Stage 2: Product Definition
#############################################
validate_stage_2() {
    log_info "Checking Stage 2: Product Definition..."

    check_content_exists "personas" "HIGH" \
        "User personas not defined" \
        "Who are your target users? Please describe 2-3 primary personas with their needs and contexts." || true

    check_content_exists "journeys" "MEDIUM" \
        "User journeys not mapped" \
        "What are the primary user journeys? Describe the key workflows users will perform." || true
}

#############################################
# Stage 3: Features
#############################################
validate_stage_3() {
    log_info "Checking Stage 3: Features..."

    # Check for features
    local feature_count=0
    for parsed in "$PARSED_DIR"/*.json; do
        [ -f "$parsed" ] || continue
        if grep -q "\"content_type\": \"features\"" "$parsed" 2>/dev/null; then
            feature_count=$((feature_count + 1))
        fi
    done

    if [ $feature_count -eq 0 ]; then
        add_gap "BLOCKING" "features" \
            "No feature specifications found in imported documentation" \
            "What features will this product include? Please list all features with descriptions."
    fi

    # Check for acceptance criteria
    local ac_found=false
    for parsed in "$PARSED_DIR"/*.json; do
        [ -f "$parsed" ] || continue
        if grep -q "\"has_acceptance_criteria\": true" "$parsed" 2>/dev/null; then
            ac_found=true
            break
        fi
    done

    if [ "$ac_found" = false ]; then
        add_gap "BLOCKING" "acceptance_criteria" \
            "No acceptance criteria found in any imported features" \
            "For each feature, what are the testable acceptance criteria? Format: '- [ ] User can...'"
    fi
}

#############################################
# Stage 4: Architecture
#############################################
validate_stage_4() {
    log_info "Checking Stage 4: Architecture..."

    check_content_exists "decisions" "MEDIUM" \
        "Architecture decisions not documented" \
        "What major technical decisions have been made? (e.g., tech stack, database, frameworks)" || true

    # Check for tech stack in any parsed content
    local tech_found=false
    for parsed in "$PARSED_DIR"/*.json; do
        [ -f "$parsed" ] || continue
        if grep -qi "stack\|framework\|database\|language\|react\|node\|python\|postgres\|mongodb" "$parsed" 2>/dev/null; then
            tech_found=true
            break
        fi
    done

    if [ "$tech_found" = false ]; then
        add_gap "HIGH" "tech_stack" \
            "Technology stack not defined" \
            "What is your technology stack? Please specify: frontend, backend, database, infrastructure."
    fi
}

#############################################
# Stage 5: Implementation Planning
#############################################
validate_stage_5() {
    log_info "Checking Stage 5: Implementation Planning..."

    check_content_exists "tasks" "MEDIUM" \
        "Implementation tasks not defined" \
        "Have you broken down features into implementable tasks? If not, we will do this together." || true
}

#############################################
# Additional Validation
#############################################
validate_additional() {
    log_info "Running additional validation..."

    # Check MVP identification
    local mvp_found=false
    for parsed in "$PARSED_DIR"/*.json; do
        [ -f "$parsed" ] || continue
        if grep -qi "mvp\|minimum viable\|phase 1\|priority.*high\|must.have" "$parsed" 2>/dev/null; then
            mvp_found=true
            break
        fi
    done

    if [ "$mvp_found" = false ]; then
        add_gap "HIGH" "mvp_scope" \
            "MVP scope not clearly identified" \
            "Which features are MVP (must-have for launch) vs. secondary (nice-to-have)?"
    fi

    # Check for UI specs if features exist
    local has_features=false
    local has_ui=false
    for parsed in "$PARSED_DIR"/*.json; do
        [ -f "$parsed" ] || continue
        if grep -q "\"content_type\": \"features\"" "$parsed" 2>/dev/null; then
            has_features=true
        fi
        if grep -q "\"content_type\": \"ui_specs\"\|\"content_type\": \"design_documentation\"" "$parsed" 2>/dev/null; then
            has_ui=true
        fi
    done

    if [ "$has_features" = true ] && [ "$has_ui" = false ]; then
        add_gap "LOW" "ui_specs" \
            "No UI specifications found for features" \
            "Do you have design mockups or wireframes? If so, please export from Figma or describe key screens."
    fi
}

#############################################
# Main execution
#############################################

log_info "Starting gap analysis..."
log_info "Parsed content directory: $PARSED_DIR"

# Check if any content exists
CONTENT_COUNT=$(check_any_content)
if [ "$CONTENT_COUNT" -eq 0 ]; then
    log_warn "No parsed content found. Run ./scripts/import/parse_docs.sh first."
    add_gap "BLOCKING" "no_content" \
        "No documentation has been imported yet" \
        "Please import your existing documentation first. Place exports in docs/import/sources/ and run ./scripts/import/parse_docs.sh"
else
    log_info "Found $CONTENT_COUNT parsed files"

    validate_stage_0
    validate_stage_1
    validate_stage_2
    validate_stage_3
    validate_stage_4
    validate_stage_5
    validate_additional
fi

#############################################
# Finalize report
#############################################

# Update summary counts using sed
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/| BLOCKING | BLOCKING_COUNT/| 🔴 BLOCKING | $BLOCKING_GAPS/" "$GAP_REPORT"
    sed -i '' "s/| HIGH | HIGH_COUNT/| 🟠 HIGH | $HIGH_GAPS/" "$GAP_REPORT"
    sed -i '' "s/| MEDIUM | MEDIUM_COUNT/| 🟡 MEDIUM | $MEDIUM_GAPS/" "$GAP_REPORT"
    sed -i '' "s/| LOW | LOW_COUNT/| 🟢 LOW | $LOW_GAPS/" "$GAP_REPORT"
else
    sed -i "s/| BLOCKING | BLOCKING_COUNT/| 🔴 BLOCKING | $BLOCKING_GAPS/" "$GAP_REPORT"
    sed -i "s/| HIGH | HIGH_COUNT/| 🟠 HIGH | $HIGH_GAPS/" "$GAP_REPORT"
    sed -i "s/| MEDIUM | MEDIUM_COUNT/| 🟡 MEDIUM | $MEDIUM_GAPS/" "$GAP_REPORT"
    sed -i "s/| LOW | LOW_COUNT/| 🟢 LOW | $LOW_GAPS/" "$GAP_REPORT"
fi

TOTAL_GAPS=$((BLOCKING_GAPS + HIGH_GAPS + MEDIUM_GAPS + LOW_GAPS))

# Update status
if [ $BLOCKING_GAPS -gt 0 ]; then
    STATUS_MSG="⛔ BLOCKED - $BLOCKING_GAPS blocking gaps must be resolved"
elif [ $HIGH_GAPS -gt 0 ]; then
    STATUS_MSG="⚠️ ATTENTION - $HIGH_GAPS high-priority gaps should be resolved"
else
    STATUS_MSG="✅ READY - No blocking gaps ($TOTAL_GAPS optional improvements)"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/Analyzing.../$STATUS_MSG/" "$GAP_REPORT"
else
    sed -i "s/Analyzing.../$STATUS_MSG/" "$GAP_REPORT"
fi

# Add next steps
cat >> "$GAP_REPORT" << EOF

## Next Steps

EOF

if [ $BLOCKING_GAPS -gt 0 ]; then
    cat >> "$GAP_REPORT" << EOF
### ⛔ Blocking Gaps Require Resolution

You have **$BLOCKING_GAPS blocking gaps** that must be resolved before proceeding.

**To resolve gaps, tell Claude:**
\`\`\`
Help me resolve the planning gaps
\`\`\`

Claude will guide you through each gap interactively.

EOF
else
    cat >> "$GAP_REPORT" << EOF
### ✅ Ready to Proceed

No blocking gaps found. You may:
1. Resolve remaining gaps for higher quality (recommended)
2. Proceed to execution readiness check

**To resolve remaining gaps:**
\`\`\`
Help me resolve the planning gaps
\`\`\`

**To proceed:**
\`\`\`
Run execution readiness check
\`\`\`

EOF
fi

cat >> "$GAP_REPORT" << EOF
---

## Resolution Commands

| Command | Purpose |
|---------|---------|
| \`FILL: [gap-id] [content]\` | Provide content for specific gap |
| \`SKIP: [gap-id] [reason]\` | Skip gap with justification |
| \`STATUS\` | Show current resolution status |
| \`PROCEED\` | Attempt to proceed (blocked if BLOCKING gaps remain) |

EOF

log_info "Gap analysis complete!"
log_info "Report: $GAP_REPORT"
log_info "Total gaps: $TOTAL_GAPS (BLOCKING: $BLOCKING_GAPS, HIGH: $HIGH_GAPS, MEDIUM: $MEDIUM_GAPS, LOW: $LOW_GAPS)"

if [ $BLOCKING_GAPS -gt 0 ]; then
    log_error "Cannot proceed: $BLOCKING_GAPS blocking gaps found"
    exit 1
fi

exit 0
