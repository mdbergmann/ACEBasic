/* quick-test.rexx - Quick verification test for Makefile-ace */
/* Usage: rx quick-test.rexx */
/* Runs essential tests only (Tests 1-4) for fast iteration */

SAY ""
SAY "ACE Makefile Quick Test"
SAY "======================="
SAY ""

/* Change to make directory */
ADDRESS COMMAND "cd ACE:make"

passed = 0
failed = 0

/* Test 1: Clean Build */
SAY "Test 1: Clean Build..."
ADDRESS COMMAND "make -f Makefile-ace clean >NIL: 2>&1"
ADDRESS COMMAND "make -f Makefile-ace >T:quicktest.log 2>&1"

IF RC = 0 & EXISTS("ACE:bin/ace") THEN DO
    SAY "  PASS"
    passed = passed + 1
END
ELSE DO
    SAY "  FAIL - Check T:quicktest.log"
    failed = failed + 1
END

/* Test 2: No-Op Build */
SAY "Test 2: No-Op Build..."
ADDRESS COMMAND "wait 2"
ADDRESS COMMAND "make -f Makefile-ace >T:quicktest-noop.log 2>&1"

IF RC = 0 THEN DO
    SAY "  PASS"
    passed = passed + 1
END
ELSE DO
    SAY "  FAIL"
    failed = failed + 1
END

/* Test 3: Incremental Build */
SAY "Test 3: Incremental Build..."
ADDRESS COMMAND "copy ACE:src/ace/c/ver.c T:ver.c.bak CLONE QUIET"
ADDRESS COMMAND 'echo "/* test */" >>ACE:src/ace/c/ver.c'
ADDRESS COMMAND "wait 2"
ADDRESS COMMAND "make -f Makefile-ace >T:quicktest-inc.log 2>&1"
rc3 = RC
ADDRESS COMMAND "copy T:ver.c.bak ACE:src/ace/c/ver.c CLONE QUIET"
ADDRESS COMMAND "delete T:ver.c.bak QUIET"

IF rc3 = 0 THEN DO
    SAY "  PASS"
    passed = passed + 1
END
ELSE DO
    SAY "  FAIL"
    failed = failed + 1
END

/* Test 4: Clean Target */
SAY "Test 4: Clean..."
ADDRESS COMMAND "make -f Makefile-ace >NIL: 2>&1"
ADDRESS COMMAND "make -f Makefile-ace clean >NIL: 2>&1"

IF RC = 0 & ~EXISTS("ACE:src/ace/obj/alloc.o") & ~EXISTS("ACE:bin/ace") THEN DO
    SAY "  PASS"
    passed = passed + 1
END
ELSE DO
    SAY "  FAIL"
    failed = failed + 1
END

/* Rebuild for development */
SAY ""
SAY "Rebuilding for development..."
ADDRESS COMMAND "make -f Makefile-ace >NIL: 2>&1"

/* Summary */
SAY ""
SAY "======================="
SAY "Passed: " || passed || "/4"
SAY "Failed: " || failed
SAY "======================="
SAY ""

IF failed > 0 THEN DO
    SAY "QUICK TEST FAILED"
    EXIT 1
END
ELSE DO
    SAY "QUICK TEST PASSED"
    EXIT 0
END
