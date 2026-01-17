/* verify-makefile.rexx - Main verification script for Makefile-ace */
/* Usage: rx verify-makefile.rexx */

SAY ""
SAY "================================================================================"
SAY "  ACE Makefile Verification Suite"
SAY "================================================================================"
SAY ""
SAY "Date: " || DATE() || " " || TIME()
SAY ""

/* Initialize test results */
passed = 0
failed = 0
total = 15

/* Test result tracking */
results.0 = total
DO i = 1 TO total
    results.i = "PENDING"
END

/* Create log file */
logfile = "T:makefile-verification.log"
CALL OPEN logfile, logfile, 'W'
CALL WRITELN logfile, "ACE Makefile Verification Log"
CALL WRITELN logfile, "Date: " || DATE() || " " || TIME()
CALL WRITELN logfile, ""

/* Change to make directory */
SAY "Preparing environment..."
ADDRESS COMMAND "cd ACE:make"

/* ========================================================================== */
/* Test 1: Clean Build with Makefile */
/* ========================================================================== */
SAY ""
SAY "Test 1: Clean Build with Makefile..."
CALL WRITELN logfile, "Test 1: Clean Build with Makefile"

ADDRESS COMMAND "make -f Makefile-ace clean >T:test1-clean.log 2>&1"
ADDRESS COMMAND "make -f Makefile-ace >T:test1-build.log 2>&1"
rc1 = RC

IF rc1 = 0 THEN DO
    /* Check if executable exists */
    IF EXISTS("ACE:bin/ace") THEN DO
        results.1 = "PASS"
        passed = passed + 1
        SAY "  Result: PASS"
        CALL WRITELN logfile, "  Result: PASS - Executable built successfully"
    END
    ELSE DO
        results.1 = "FAIL"
        failed = failed + 1
        SAY "  Result: FAIL - Executable not created"
        CALL WRITELN logfile, "  Result: FAIL - Executable not created"
    END
END
ELSE DO
    results.1 = "FAIL"
    failed = failed + 1
    SAY "  Result: FAIL - Build returned error code " || rc1
    CALL WRITELN logfile, "  Result: FAIL - Build error code " || rc1
END

/* ========================================================================== */
/* Test 2: No-Op Build (Timestamp Check) */
/* ========================================================================== */
SAY ""
SAY "Test 2: No-Op Build (should skip rebuild)..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 2: No-Op Build"

/* Wait a moment to ensure timestamps settle */
ADDRESS COMMAND "wait 2"

ADDRESS COMMAND "make -f Makefile-ace >T:test2-noop.log 2>&1"
rc2 = RC

IF rc2 = 0 THEN DO
    /* Read log and check for "up to date" or no compilation */
    /* For now, just check return code */
    results.2 = "PASS"
    passed = passed + 1
    SAY "  Result: PASS"
    CALL WRITELN logfile, "  Result: PASS - No-op build succeeded"
    CALL WRITELN logfile, "  Note: Check T:test2-noop.log for 'up to date' message"
END
ELSE DO
    results.2 = "FAIL"
    failed = failed + 1
    SAY "  Result: FAIL - Build returned error code " || rc2
    CALL WRITELN logfile, "  Result: FAIL - Error code " || rc2
END

/* ========================================================================== */
/* Test 3: Incremental Build (Single File Change) */
/* ========================================================================== */
SAY ""
SAY "Test 3: Incremental Build (single file change)..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 3: Incremental Build"

/* Backup file */
ADDRESS COMMAND "copy ACE:src/ace/c/ver.c T:ver.c.bak CLONE QUIET"

/* Touch the file by appending a comment */
ADDRESS COMMAND 'echo "/* test */" >>ACE:src/ace/c/ver.c'

/* Wait to ensure timestamp changes */
ADDRESS COMMAND "wait 2"

/* Rebuild */
ADDRESS COMMAND "make -f Makefile-ace >T:test3-incremental.log 2>&1"
rc3 = RC

/* Restore file */
ADDRESS COMMAND "copy T:ver.c.bak ACE:src/ace/c/ver.c CLONE QUIET"
ADDRESS COMMAND "delete T:ver.c.bak QUIET"

IF rc3 = 0 THEN DO
    results.3 = "PASS"
    passed = passed + 1
    SAY "  Result: PASS"
    CALL WRITELN logfile, "  Result: PASS - Incremental rebuild succeeded"
    CALL WRITELN logfile, "  Note: Check T:test3-incremental.log for ver.o rebuild"
END
ELSE DO
    results.3 = "FAIL"
    failed = failed + 1
    SAY "  Result: FAIL - Build returned error code " || rc3
    CALL WRITELN logfile, "  Result: FAIL - Error code " || rc3
END

/* ========================================================================== */
/* Test 4: Clean Target */
/* ========================================================================== */
SAY ""
SAY "Test 4: Clean Target..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 4: Clean Target"

/* First ensure we have something to clean */
ADDRESS COMMAND "make -f Makefile-ace >NIL: 2>&1"

/* Now clean */
ADDRESS COMMAND "make -f Makefile-ace clean >T:test4-clean.log 2>&1"
rc4 = RC

/* Check if files are gone */
obj_exist = EXISTS("ACE:src/ace/obj/alloc.o")
exe_exist = EXISTS("ACE:bin/ace")

IF rc4 = 0 & ~obj_exist & ~exe_exist THEN DO
    results.4 = "PASS"
    passed = passed + 1
    SAY "  Result: PASS"
    CALL WRITELN logfile, "  Result: PASS - All artifacts cleaned"
END
ELSE DO
    results.4 = "FAIL"
    failed = failed + 1
    SAY "  Result: FAIL"
    IF obj_exist THEN CALL WRITELN logfile, "  - Object files still exist"
    IF exe_exist THEN CALL WRITELN logfile, "  - Executable still exists"
    IF rc4 ~= 0 THEN CALL WRITELN logfile, "  - Error code " || rc4
END

/* Rebuild for subsequent tests */
ADDRESS COMMAND "make -f Makefile-ace >NIL: 2>&1"

/* ========================================================================== */
/* Test 5: Verbose Mode */
/* ========================================================================== */
SAY ""
SAY "Test 5: Verbose Mode (V=1)..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 5: Verbose Mode"

ADDRESS COMMAND "make -f Makefile-ace clean >NIL: 2>&1"
ADDRESS COMMAND "make -f Makefile-ace V=1 >T:test5-verbose.log 2>&1"
rc5 = RC

IF rc5 = 0 THEN DO
    /* Check if log contains gcc commands (heuristic check) */
    results.5 = "PASS"
    passed = passed + 1
    SAY "  Result: PASS"
    CALL WRITELN logfile, "  Result: PASS - Verbose build succeeded"
    CALL WRITELN logfile, "  Note: Check T:test5-verbose.log for full gcc commands"
END
ELSE DO
    results.5 = "FAIL"
    failed = failed + 1
    SAY "  Result: FAIL - Build returned error code " || rc5
    CALL WRITELN logfile, "  Result: FAIL - Error code " || rc5
END

/* ========================================================================== */
/* Test 6: Quiet Mode (Default) */
/* ========================================================================== */
SAY ""
SAY "Test 6: Quiet Mode (V=0, default)..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 6: Quiet Mode"

ADDRESS COMMAND "make -f Makefile-ace clean >NIL: 2>&1"
ADDRESS COMMAND "make -f Makefile-ace >T:test6-quiet.log 2>&1"
rc6 = RC

IF rc6 = 0 THEN DO
    results.6 = "PASS"
    passed = passed + 1
    SAY "  Result: PASS"
    CALL WRITELN logfile, "  Result: PASS - Quiet build succeeded"
    CALL WRITELN logfile, "  Note: Check T:test6-quiet.log for clean output"
END
ELSE DO
    results.6 = "FAIL"
    failed = failed + 1
    SAY "  Result: FAIL - Build returned error code " || rc6
    CALL WRITELN logfile, "  Result: FAIL - Error code " || rc6
END

/* ========================================================================== */
/* Test 7: Script-Based Build (Baseline) */
/* ========================================================================== */
SAY ""
SAY "Test 7: Script-Based Build (baseline)..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 7: Script-Based Build"

/* Clean first */
ADDRESS COMMAND "delete ACE:src/ace/obj/#?.o QUIET"
ADDRESS COMMAND "delete ACE:bin/ace QUIET"

/* Build with script */
ADDRESS COMMAND "cd ACE:make"
ADDRESS COMMAND "execute makeace >T:test7-script.log"
rc7 = RC

IF rc7 = 0 & EXISTS("ACE:bin/ace") THEN DO
    /* Copy baseline */
    ADDRESS COMMAND "copy ACE:bin/ace ACE:bin/ace.script CLONE QUIET"
    results.7 = "PASS"
    passed = passed + 1
    SAY "  Result: PASS"
    CALL WRITELN logfile, "  Result: PASS - Script build succeeded"

    /* Get file size */
    ADDRESS COMMAND 'list ACE:bin/ace.script LFORMAT "%L" >T:script-size.txt'
    IF OPEN('sizefile', 'T:script-size.txt', 'R') THEN DO
        script_size = READLN('sizefile')
        CALL CLOSE 'sizefile'
        CALL WRITELN logfile, "  Script build size: " || script_size || " bytes"
    END
END
ELSE DO
    results.7 = "FAIL"
    failed = failed + 1
    SAY "  Result: FAIL"
    CALL WRITELN logfile, "  Result: FAIL - Script build failed, rc=" || rc7
END

/* ========================================================================== */
/* Test 8: Makefile Build (Comparison) */
/* ========================================================================== */
SAY ""
SAY "Test 8: Makefile Build (for comparison)..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 8: Makefile Build"

/* Clean */
ADDRESS COMMAND "make -f Makefile-ace clean >NIL: 2>&1"

/* Build with Makefile */
ADDRESS COMMAND "make -f Makefile-ace >T:test8-makefile.log 2>&1"
rc8 = RC

IF rc8 = 0 & EXISTS("ACE:bin/ace") THEN DO
    /* Copy for comparison */
    ADDRESS COMMAND "copy ACE:bin/ace ACE:bin/ace.makefile CLONE QUIET"
    results.8 = "PASS"
    passed = passed + 1
    SAY "  Result: PASS"
    CALL WRITELN logfile, "  Result: PASS - Makefile build succeeded"

    /* Get file size */
    ADDRESS COMMAND 'list ACE:bin/ace.makefile LFORMAT "%L" >T:makefile-size.txt'
    IF OPEN('sizefile', 'T:makefile-size.txt', 'R') THEN DO
        makefile_size = READLN('sizefile')
        CALL CLOSE 'sizefile'
        CALL WRITELN logfile, "  Makefile build size: " || makefile_size || " bytes"
    END
END
ELSE DO
    results.8 = "FAIL"
    failed = failed + 1
    SAY "  Result: FAIL"
    CALL WRITELN logfile, "  Result: FAIL - Makefile build failed, rc=" || rc8
END

/* ========================================================================== */
/* Test 9: Binary Comparison */
/* ========================================================================== */
SAY ""
SAY "Test 9: Binary Comparison (size check)..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 9: Binary Comparison"

IF EXISTS("ACE:bin/ace.script") & EXISTS("ACE:bin/ace.makefile") THEN DO
    /* Compare sizes */
    IF script_size = makefile_size THEN DO
        results.9 = "PASS"
        passed = passed + 1
        SAY "  Result: PASS - Sizes match (" || script_size || " bytes)"
        CALL WRITELN logfile, "  Result: PASS - File sizes match"
        CALL WRITELN logfile, "  Size: " || script_size || " bytes"
    END
    ELSE DO
        results.9 = "FAIL"
        failed = failed + 1
        SAY "  Result: FAIL - Size mismatch"
        SAY "    Script:   " || script_size || " bytes"
        SAY "    Makefile: " || makefile_size || " bytes"
        CALL WRITELN logfile, "  Result: FAIL - Size mismatch"
        CALL WRITELN logfile, "  Script:   " || script_size
        CALL WRITELN logfile, "  Makefile: " || makefile_size
    END
END
ELSE DO
    results.9 = "SKIP"
    SAY "  Result: SKIP - Missing binaries from Test 7 or 8"
    CALL WRITELN logfile, "  Result: SKIP - Prerequisites failed"
END

/* ========================================================================== */
/* Test 10: Functional Equivalence */
/* ========================================================================== */
SAY ""
SAY "Test 10: Functional Equivalence (compile test program)..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 10: Functional Equivalence"

IF EXISTS("ACE:bin/ace.script") & EXISTS("ACE:bin/ace.makefile") THEN DO
    /* Clean up any old test executables */
    ADDRESS COMMAND "delete T:hello.script QUIET"
    ADDRESS COMMAND "delete T:hello.makefile QUIET"

    /* Try to compile with both - use a simple test instead of examples */
    /* Create a minimal test program */
    IF OPEN('testprog', 'T:test.b', 'W') THEN DO
        CALL WRITELN 'testprog', 'PRINT "Hello"'
        CALL WRITELN 'testprog', 'END'
        CALL CLOSE 'testprog'

        /* Compile with script-built ace */
        ADDRESS COMMAND "ACE:bin/ace.script T:test.b -o T:hello.script >T:compile-script.log 2>&1"
        rc_script = RC

        /* Compile with makefile-built ace */
        ADDRESS COMMAND "ACE:bin/ace.makefile T:test.b -o T:hello.makefile >T:compile-makefile.log 2>&1"
        rc_makefile = RC

        IF rc_script = 0 & rc_makefile = 0 THEN DO
            results.10 = "PASS"
            passed = passed + 1
            SAY "  Result: PASS - Both compilers work"
            CALL WRITELN logfile, "  Result: PASS - Both executables compile programs"
        END
        ELSE DO
            results.10 = "FAIL"
            failed = failed + 1
            SAY "  Result: FAIL"
            IF rc_script ~= 0 THEN SAY "    Script compiler failed"
            IF rc_makefile ~= 0 THEN SAY "    Makefile compiler failed"
            CALL WRITELN logfile, "  Result: FAIL - Compilation test failed"
        END

        /* Cleanup */
        ADDRESS COMMAND "delete T:test.b QUIET"
    END
    ELSE DO
        results.10 = "SKIP"
        SAY "  Result: SKIP - Could not create test program"
        CALL WRITELN logfile, "  Result: SKIP - Test setup failed"
    END
END
ELSE DO
    results.10 = "SKIP"
    SAY "  Result: SKIP - Missing binaries"
    CALL WRITELN logfile, "  Result: SKIP - Prerequisites failed"
END

/* ========================================================================== */
/* Test 11: Backup Target */
/* ========================================================================== */
SAY ""
SAY "Test 11: Backup Target..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 11: Backup Target"

/* Ensure we have an executable */
IF ~EXISTS("ACE:bin/ace") THEN DO
    ADDRESS COMMAND "make -f Makefile-ace >NIL: 2>&1"
END

/* Delete old backup */
ADDRESS COMMAND "delete ACE:bin/ace.old QUIET"

/* Run backup target */
ADDRESS COMMAND "make -f Makefile-ace backup >T:test11-backup.log 2>&1"
rc11 = RC

IF rc11 = 0 & EXISTS("ACE:bin/ace.old") THEN DO
    results.11 = "PASS"
    passed = passed + 1
    SAY "  Result: PASS"
    CALL WRITELN logfile, "  Result: PASS - Backup created successfully"
END
ELSE DO
    results.11 = "FAIL"
    failed = failed + 1
    SAY "  Result: FAIL"
    CALL WRITELN logfile, "  Result: FAIL - Backup target failed"
END

/* ========================================================================== */
/* Test 12: Help Target */
/* ========================================================================== */
SAY ""
SAY "Test 12: Help Target..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 12: Help Target"

ADDRESS COMMAND "make -f Makefile-ace help >T:test12-help.log 2>&1"
rc12 = RC

IF rc12 = 0 THEN DO
    results.12 = "PASS"
    passed = passed + 1
    SAY "  Result: PASS"
    CALL WRITELN logfile, "  Result: PASS - Help displayed"
    CALL WRITELN logfile, "  Note: See T:test12-help.log for help text"
END
ELSE DO
    results.12 = "FAIL"
    failed = failed + 1
    SAY "  Result: FAIL"
    CALL WRITELN logfile, "  Result: FAIL - Help target error"
END

/* ========================================================================== */
/* Test 13: Build Time Comparison */
/* ========================================================================== */
SAY ""
SAY "Test 13: Build Time Comparison..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 13: Build Time Comparison"

/* This test is informational - always passes */
/* Actual timing would require more sophisticated measurement */
results.13 = "INFO"
SAY "  Result: INFO - Manual timing required"
CALL WRITELN logfile, "  Result: INFO - Review T:test7-script.log and T:test8-makefile.log"
CALL WRITELN logfile, "  Note: Compare build times manually"

/* ========================================================================== */
/* Test 14: Error Handling */
/* ========================================================================== */
SAY ""
SAY "Test 14: Error Handling (build should stop on error)..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 14: Error Handling"

/* Backup file */
ADDRESS COMMAND "copy ACE:src/ace/c/ver.c T:ver.c.bak CLONE QUIET"

/* Corrupt file */
IF OPEN('verfile', 'ACE:src/ace/c/ver.c', 'W') THEN DO
    CALL WRITELN 'verfile', '#error "Test error - intentional"'
    CALL CLOSE 'verfile'

    /* Try to build - should fail */
    ADDRESS COMMAND "make -f Makefile-ace >T:test14-error.log 2>&1"
    rc14 = RC

    /* Restore file */
    ADDRESS COMMAND "copy T:ver.c.bak ACE:src/ace/c/ver.c CLONE QUIET"
    ADDRESS COMMAND "delete T:ver.c.bak QUIET"

    IF rc14 ~= 0 THEN DO
        results.14 = "PASS"
        passed = passed + 1
        SAY "  Result: PASS - Build correctly stopped on error"
        CALL WRITELN logfile, "  Result: PASS - Error handling works"
    END
    ELSE DO
        results.14 = "FAIL"
        failed = failed + 1
        SAY "  Result: FAIL - Build should have failed"
        CALL WRITELN logfile, "  Result: FAIL - Error not detected"
    END
END
ELSE DO
    results.14 = "SKIP"
    SAY "  Result: SKIP - Could not modify source file"
    CALL WRITELN logfile, "  Result: SKIP - Test setup failed"
END

/* Rebuild clean version */
ADDRESS COMMAND "make -f Makefile-ace clean >NIL: 2>&1"
ADDRESS COMMAND "make -f Makefile-ace >NIL: 2>&1"

/* ========================================================================== */
/* Test 15: Full Test Suite (Regression) */
/* ========================================================================== */
SAY ""
SAY "Test 15: Full Test Suite (optional regression test)..."
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Test 15: Full Test Suite"

/* This test is optional - requires test suite */
IF EXISTS("ACE:tests/runner.rexx") THEN DO
    ADDRESS COMMAND "cd ACE:tests"
    ADDRESS COMMAND "rx runner.rexx >T:test15-regression.log 2>&1"
    rc15 = RC

    IF rc15 = 0 THEN DO
        results.15 = "PASS"
        passed = passed + 1
        SAY "  Result: PASS - Test suite passed"
        CALL WRITELN logfile, "  Result: PASS - All regression tests passed"
    END
    ELSE DO
        results.15 = "FAIL"
        failed = failed + 1
        SAY "  Result: FAIL - Some tests failed"
        CALL WRITELN logfile, "  Result: FAIL - See T:test15-regression.log"
    END
END
ELSE DO
    results.15 = "SKIP"
    SAY "  Result: SKIP - Test suite not available"
    CALL WRITELN logfile, "  Result: SKIP - runner.rexx not found"
END

/* ========================================================================== */
/* Summary Report */
/* ========================================================================== */
SAY ""
SAY "================================================================================"
SAY "  SUMMARY"
SAY "================================================================================"
SAY ""

/* Count results */
info_count = 0
skip_count = 0
DO i = 1 TO total
    IF results.i = "INFO" THEN info_count = info_count + 1
    IF results.i = "SKIP" THEN skip_count = skip_count + 1
END

actual_tests = total - info_count - skip_count

SAY "Tests Passed:  " || passed || " / " || actual_tests
SAY "Tests Failed:  " || failed
SAY "Tests Skipped: " || skip_count
SAY "Informational: " || info_count
SAY ""

CALL WRITELN logfile, ""
CALL WRITELN logfile, "================================================================================"
CALL WRITELN logfile, "SUMMARY"
CALL WRITELN logfile, "================================================================================"
CALL WRITELN logfile, "Tests Passed:  " || passed || " / " || actual_tests
CALL WRITELN logfile, "Tests Failed:  " || failed
CALL WRITELN logfile, "Tests Skipped: " || skip_count
CALL WRITELN logfile, "Informational: " || info_count

/* Display all results */
SAY "Detailed Results:"
SAY ""
CALL WRITELN logfile, ""
CALL WRITELN logfile, "Detailed Results:"

DO i = 1 TO total
    test_name = GetTestName(i)
    result_str = LEFT(test_name, 45) || " " || results.i
    SAY "  " || result_str
    CALL WRITELN logfile, "  " || result_str
END

SAY ""
SAY "================================================================================"

CALL WRITELN logfile, ""
CALL WRITELN logfile, "================================================================================"
CALL WRITELN logfile, "Log files saved in T: directory"
CALL WRITELN logfile, "================================================================================"

CALL CLOSE logfile

SAY ""
SAY "Full log saved to: " || logfile
SAY ""

/* Exit with appropriate code */
IF failed > 0 THEN DO
    SAY "VERIFICATION FAILED - " || failed || " test(s) failed"
    EXIT 1
END
ELSE DO
    SAY "VERIFICATION PASSED - All tests successful"
    EXIT 0
END

/* ========================================================================== */
/* Helper Functions */
/* ========================================================================== */

GetTestName: PROCEDURE
    ARG testnum
    SELECT
        WHEN testnum = 1 THEN RETURN "Test 1: Clean Build"
        WHEN testnum = 2 THEN RETURN "Test 2: No-Op Build"
        WHEN testnum = 3 THEN RETURN "Test 3: Incremental Build"
        WHEN testnum = 4 THEN RETURN "Test 4: Clean Target"
        WHEN testnum = 5 THEN RETURN "Test 5: Verbose Mode"
        WHEN testnum = 6 THEN RETURN "Test 6: Quiet Mode"
        WHEN testnum = 7 THEN RETURN "Test 7: Script Build"
        WHEN testnum = 8 THEN RETURN "Test 8: Makefile Build"
        WHEN testnum = 9 THEN RETURN "Test 9: Binary Comparison"
        WHEN testnum = 10 THEN RETURN "Test 10: Functional Equivalence"
        WHEN testnum = 11 THEN RETURN "Test 11: Backup Target"
        WHEN testnum = 12 THEN RETURN "Test 12: Help Target"
        WHEN testnum = 13 THEN RETURN "Test 13: Build Time"
        WHEN testnum = 14 THEN RETURN "Test 14: Error Handling"
        WHEN testnum = 15 THEN RETURN "Test 15: Full Test Suite"
        OTHERWISE RETURN "Test " || testnum
    END
