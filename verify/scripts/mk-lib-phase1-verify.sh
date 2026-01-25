#!/bin/bash
#
# lib-phase1-verify.sh - Host-side Pre-flight Checks for Library Build (macOS)
#
# Runs before launching fs-uae to verify basic setup is correct.
# Part of the Makefile-lib verification pipeline.
#
# Usage: ./lib-phase1-verify.sh
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
LOG_FILE="$RESULTS_DIR/lib-phase1.log"
MARKER_FILE="$RESULTS_DIR/lib-phase1-complete.marker"

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
log " Library Phase 1: Pre-flight Checks (Host-Side)"
log "================================================================================"
log ""
log "Date: $(date)"
log "Project root: $PROJECT_ROOT"
log ""

# Change to project root for all tests
cd "$PROJECT_ROOT"

# Test 1.1: Makefile Syntax Check
test_1_1() {
    log "Command: cd src/make && make -f Makefile-lib -n all 2>&1 | head -20"
    log ""

    local output
    # Run make in dry-run mode - syntax errors will cause non-zero exit
    if output=$(cd src/make && make -f Makefile-lib -n all 2>&1); then
        log "Make parsed Makefile-lib successfully (dry-run mode)"
        log "First 10 lines of output:"
        echo "$output" | head -10 | tee -a "$LOG_FILE"
        return 0
    else
        log "ERROR: Make failed to parse Makefile-lib"
        log "Output:"
        echo "$output" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Test 1.2: C Source Files Exist
test_1_2() {
    log "Command: ls -1 src/lib/c/*.c | wc -l"
    log "Expected: 30 files"
    log ""

    local count
    count=$(ls -1 src/lib/c/*.c 2>/dev/null | wc -l | tr -d ' ')

    log "Found: $count .c files in src/lib/c/"

    if [[ "$count" -eq 30 ]]; then
        log "File count matches expected (30)"
        return 0
    else
        log "ERROR: Expected 30 files, found $count"
        log "Files found:"
        ls -1 src/lib/c/*.c 2>/dev/null | tee -a "$LOG_FILE"
        return 1
    fi
}

# Test 1.3: Assembly Source Files Exist
test_1_3() {
    log "Command: ls -1 src/lib/asm/*.s | wc -l"
    log "Expected: 23 files"
    log ""

    local count
    count=$(ls -1 src/lib/asm/*.s 2>/dev/null | wc -l | tr -d ' ')

    log "Found: $count .s files in src/lib/asm/"

    if [[ "$count" -eq 23 ]]; then
        log "File count matches expected (23)"
        return 0
    else
        log "ERROR: Expected 23 files, found $count"
        log "Files found:"
        ls -1 src/lib/asm/*.s 2>/dev/null | tee -a "$LOG_FILE"
        return 1
    fi
}

# Test 1.4: Startup Source Exists
test_1_4() {
    log "Command: ls src/lib/startup/startup.s"
    log "Expected: File exists"
    log ""

    if [[ -f "src/lib/startup/startup.s" ]]; then
        log "File src/lib/startup/startup.s exists"
        return 0
    else
        log "ERROR: File src/lib/startup/startup.s does not exist"
        return 1
    fi
}

# Test 1.5: Object Directory Exists or Can Be Created
test_1_5() {
    log "Command: ls -d src/lib/obj/ or check it can be created"
    log "Expected: Directory exists or parent is writable"
    log ""

    if [[ -d "src/lib/obj" ]]; then
        log "Directory src/lib/obj/ exists"
        return 0
    elif [[ -d "src/lib" ]]; then
        log "Directory src/lib/obj/ does not exist but parent src/lib/ exists"
        log "Directory will be created during build"
        return 0
    else
        log "ERROR: Neither src/lib/obj/ nor src/lib/ exist"
        return 1
    fi
}

# Test 1.6: Output Library Directory Exists
test_1_6() {
    log "Command: ls -d lib/"
    log "Expected: Directory exists"
    log ""

    if [[ -d "lib" ]]; then
        log "Directory lib/ exists"
        return 0
    else
        log "ERROR: Directory lib/ does not exist"
        return 1
    fi
}

# Run all tests
run_test "1.1" "Makefile Syntax Check" test_1_1 || true
run_test "1.2" "C Source Files Exist (30)" test_1_2 || true
run_test "1.3" "Assembly Source Files Exist (23)" test_1_3 || true
run_test "1.4" "Startup Source Exists" test_1_4 || true
run_test "1.5" "Object Directory Exists" test_1_5 || true
run_test "1.6" "Output Library Directory Exists" test_1_6 || true

# Summary
log ""
log "================================================================================"
log " Library Phase 1 Summary"
log "================================================================================"
log ""
log "Tests Passed: $TESTS_PASSED"
log "Tests Failed: $TESTS_FAILED"
log ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    log "Library Phase 1: ALL CHECKS PASSED"
    log ""
    # Create completion marker
    echo "Library Phase 1 completed successfully at $(date)" > "$MARKER_FILE"
    log "Marker created: $MARKER_FILE"
    exit 0
else
    log "Library Phase 1: FAILED ($TESTS_FAILED check(s) failed)"
    log ""
    log "Fix the issues above before proceeding to Phase 2."
    exit 1
fi
