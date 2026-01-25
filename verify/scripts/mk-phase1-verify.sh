#!/bin/bash
#
# phase1-verify.sh - Host-side Pre-flight Checks (macOS)
#
# Runs before launching fs-uae to verify basic setup is correct.
# Part of the Phase 6 full verification pipeline.
#
# Usage: ./phase1-verify.sh
#
# Exit codes:
#   0 - All checks passed
#   1 - One or more checks failed
#

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"
LOG_FILE="$RESULTS_DIR/phase1.log"
MARKER_FILE="$RESULTS_DIR/phase1-complete.marker"

# Ensure results directory exists
mkdir -p "$RESULTS_DIR"

# Remove previous results
rm -f "$LOG_FILE" "$MARKER_FILE"

# Logging function
log() {
    echo "$@" | tee -a "$LOG_FILE"
}

# Test result tracking
TESTS_PASSED=0
TESTS_FAILED=0

# Run a test and track result
run_test() {
    local test_name="$1"
    local test_desc="$2"
    shift 2

    log ""
    log "Test $test_name: $test_desc"
    log "-------------------------------------------"

    if "$@"; then
        log "Status: PASS"
        ((TESTS_PASSED++))
        return 0
    else
        log "Status: FAIL"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Start logging
log "================================================================================"
log " Phase 1: Pre-flight Checks (Host-Side)"
log "================================================================================"
log ""
log "Date: $(date)"
log "Project root: $PROJECT_ROOT"
log ""

# Change to project root for all tests
cd "$PROJECT_ROOT"

# Test 1.1: Makefile Syntax Check
test_1_1() {
    log "Command: cd src/make && make -f Makefile-ace -n all 2>&1 | head -20"
    log ""

    local output
    # Run make in dry-run mode - syntax errors will cause non-zero exit
    # We expect some command-not-found errors (AmigaDOS commands) but no Make syntax errors
    if output=$(cd src/make && make -f Makefile-ace -n all 2>&1); then
        log "Make parsed Makefile-ace successfully (dry-run mode)"
        log "First 10 lines of output:"
        echo "$output" | head -10 | tee -a "$LOG_FILE"
        return 0
    else
        log "ERROR: Make failed to parse Makefile-ace"
        log "Output:"
        echo "$output" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Test 1.2: Source File List Verification
test_1_2() {
    log "Command: ls -1 src/ace/c/*.c | wc -l"
    log "Expected: 31 files (29 compiled + 2 included: lexvar.c, symvar.c)"
    log ""

    local count
    count=$(ls -1 src/ace/c/*.c 2>/dev/null | wc -l | tr -d ' ')

    log "Found: $count .c files in src/ace/c/"

    if [[ "$count" -eq 31 ]]; then
        log "File count matches expected (31)"
        return 0
    else
        log "ERROR: Expected 31 files, found $count"
        log "Files found:"
        ls -1 src/ace/c/*.c 2>/dev/null | tee -a "$LOG_FILE"
        return 1
    fi
}

# Test 1.3: Object Directory Exists
test_1_3() {
    log "Command: ls -d src/ace/obj/"
    log "Expected: Directory exists"
    log ""

    if [[ -d "src/ace/obj" ]]; then
        log "Directory src/ace/obj/ exists"
        return 0
    else
        log "ERROR: Directory src/ace/obj/ does not exist"
        return 1
    fi
}

# Test 1.4: Bin Directory Exists
test_1_4() {
    log "Command: ls -d bin/"
    log "Expected: Directory exists"
    log ""

    if [[ -d "bin" ]]; then
        log "Directory bin/ exists"
        return 0
    else
        log "ERROR: Directory bin/ does not exist"
        return 1
    fi
}

# Run all tests
run_test "1.1" "Makefile Syntax Check" test_1_1 || true
run_test "1.2" "Source File List Verification" test_1_2 || true
run_test "1.3" "Object Directory Exists" test_1_3 || true
run_test "1.4" "Bin Directory Exists" test_1_4 || true

# Summary
log ""
log "================================================================================"
log " Phase 1 Summary"
log "================================================================================"
log ""
log "Tests Passed: $TESTS_PASSED"
log "Tests Failed: $TESTS_FAILED"
log ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    log "Phase 1: ALL CHECKS PASSED"
    log ""
    # Create completion marker
    echo "Phase 1 completed successfully at $(date)" > "$MARKER_FILE"
    log "Marker created: $MARKER_FILE"
    exit 0
else
    log "Phase 1: FAILED ($TESTS_FAILED check(s) failed)"
    log ""
    log "Fix the issues above before proceeding to Phase 2."
    exit 1
fi
