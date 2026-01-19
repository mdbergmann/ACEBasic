#!/bin/bash
#
# run-auto-verify.sh - Automated Makefile Verification Launcher
#
# This script launches fs-uae with automatic verification enabled,
# monitors for completion, and displays results.
#
# Usage: ./run-auto-verify.sh [--wait]
#
# Options:
#   --wait    Wait for verification to complete and display results
#             (default: launch and exit)

set -e

# Cleanup function to kill fs-uae on exit
FSUAE_PID=""
cleanup_fsuae() {
    if [[ -n "$FSUAE_PID" ]] && ps -p "$FSUAE_PID" > /dev/null 2>&1; then
        echo ""
        echo "Shutting down FS-UAE (PID: $FSUAE_PID)..."

        # Try graceful shutdown first
        kill -TERM "$FSUAE_PID" 2>/dev/null || true

        # Wait up to 5 seconds for graceful shutdown
        for i in {1..10}; do
            if ! ps -p "$FSUAE_PID" > /dev/null 2>&1; then
                echo "FS-UAE terminated gracefully."
                return 0
            fi
            sleep 0.5
        done

        # Force kill if still running
        if ps -p "$FSUAE_PID" > /dev/null 2>&1; then
            echo "Force killing FS-UAE..."
            kill -KILL "$FSUAE_PID" 2>/dev/null || true
            sleep 1
        fi

        # Clean up any remaining fs-uae processes
        pkill -9 -f "fs-uae.*ace-verify" 2>/dev/null || true

        echo "FS-UAE cleanup complete."
    fi
}

# Register cleanup trap
trap cleanup_fsuae EXIT INT TERM

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FS_UAE_CONFIG="$SCRIPT_DIR/otherthenamiga/ace-verify.fs-uae"
FS_UAE_BIN="$HOME/Applications/Emu/Amiga/FS-UAE/FS-UAE.app/Contents/MacOS/fs-uae"
PHASE1_SCRIPT="$SCRIPT_DIR/phase1-verify.sh"
COMPLETION_MARKER="$PROJECT_ROOT/scripts/verify/results/phase5-complete.marker"
RESULTS_LOG="$PROJECT_ROOT/scripts/verify/results/phase5.log"
WAIT_MODE=false

# Parse arguments
if [[ "${1:-}" == "--wait" ]]; then
    WAIT_MODE=true
fi

echo "================================================================================"
echo " ACE Makefile - Phase 6: Full Automated Verification"
echo "================================================================================"
echo ""
echo "Project root: $PROJECT_ROOT"
echo "FS-UAE config: $FS_UAE_CONFIG"
echo ""

# ================================================================================
# PHASE 1: Host-side Pre-flight Checks
# ================================================================================
echo "--------------------------------------------------------------------------------"
echo " Phase 1: Running host-side pre-flight checks..."
echo "--------------------------------------------------------------------------------"
echo ""

if [[ ! -f "$PHASE1_SCRIPT" ]]; then
    echo "ERROR: Phase 1 script not found at: $PHASE1_SCRIPT"
    exit 1
fi

if ! "$PHASE1_SCRIPT"; then
    echo ""
    echo "ERROR: Phase 1 pre-flight checks failed!"
    echo "Fix the issues above before proceeding."
    exit 1
fi

echo ""
echo "Phase 1: PASSED - proceeding to Phases 2-5 (Amiga)"
echo ""

# Clean up previous results (phases 2-5)
echo "Cleaning previous phase 2-5 results..."
for phase in 2 3 4 5; do
    rm -f "$PROJECT_ROOT/scripts/verify/results/phase${phase}-complete.marker" 2>/dev/null || true
    rm -f "$PROJECT_ROOT/scripts/verify/results/phase${phase}.log" 2>/dev/null || true
done
echo ""

# Launch fs-uae
if [[ ! -f "$FS_UAE_BIN" ]]; then
    echo "ERROR: FS-UAE not found at: $FS_UAE_BIN"
    exit 1
fi

if [[ ! -f "$FS_UAE_CONFIG" ]]; then
    echo "ERROR: FS-UAE config not found at: $FS_UAE_CONFIG"
    exit 1
fi

echo "Launching FS-UAE..."
"$FS_UAE_BIN" "$FS_UAE_CONFIG" &
FSUAE_PID=$!

echo "FS-UAE launched (PID: $FSUAE_PID)"
echo "Will automatically shut down FS-UAE on script exit."
echo ""

if [[ "$WAIT_MODE" != "true" ]]; then
    echo "FS-UAE is running in background."
    echo ""
    echo "To monitor verification progress:"
    echo "  tail -f \"$RESULTS_LOG\""
    echo ""
    echo "To check if verification is complete:"
    echo "  test -f \"$COMPLETION_MARKER\" && echo 'Complete!'"
    echo ""
    echo "================================================================================"
    exit 0
fi

# Wait mode: monitor for completion
echo "Waiting for verification to complete..."
echo "(This may take 5-10 minutes)"
echo ""

MAX_WAIT=900  # 15 minutes max
ELAPSED=0
INTERVAL=5

while [[ $ELAPSED -lt $MAX_WAIT ]]; do
    if [[ -f "$COMPLETION_MARKER" ]]; then
        echo ""
        echo "================================================================================"
        echo " Verification Complete!"
        echo "================================================================================"
        echo ""

        if [[ -f "$RESULTS_LOG" ]]; then
            echo "Results:"
            echo "--------"
            cat "$RESULTS_LOG"
            echo ""
            echo "Full results saved to: $RESULTS_LOG"
        else
            echo "WARNING: Results log not found at: $RESULTS_LOG"
        fi

        echo ""
        echo "================================================================================"
        exit 0
    fi

    # Check if fs-uae is still running
    if ! ps -p $FSUAE_PID > /dev/null 2>&1; then
        echo ""
        echo "ERROR: FS-UAE process terminated unexpectedly"
        exit 1
    fi

    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
    echo -n "."
done

echo ""
echo ""
echo "WARNING: Verification did not complete within $MAX_WAIT seconds"
echo "FS-UAE is still running (PID: $FSUAE_PID)"
echo "Check manually or wait longer"
echo ""

exit 1
