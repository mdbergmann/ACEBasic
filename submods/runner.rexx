/* ACE BASIC Submodule Test Runner
 *
 * Usage: rx runner.rexx [submod|all]
 *
 * Run from ACE:submods/ directory on emulator.
 *
 * Examples:
 *   rx runner.rexx all       - test all submodules
 *   rx runner.rexx           - same as 'all'
 *   rx runner.rexx list      - test only submods/list/
 *   rx runner.rexx dp-float  - test only submods/dp-float/
 *
 * Test outcome detection (three states):
 *   PASS - test ran to completion without assertion failures
 *   FAIL - testkit "Results:" shows failures, or "ASSERT FAILED", or build/link failed
 *   SKIP - output contains "SKIPPED:" (missing hardware/library)
 */

PARSE ARG submod

IF submod = '' THEN submod = 'all'

/* Configuration */
aceDir = 'ACE:'
basCmd = 'execute ' || aceDir || 'bin/bas'

/* Counters */
totalPass = 0
totalFail = 0
totalSkip = 0

/* Discover submodules to test */
IF submod = 'all' THEN DO
    /* List all subdirectories that contain test_*.b files */
    ADDRESS COMMAND 'list PAT=#? DIRS LFORMAT=%s >T:submoddirs'

    IF ~OPEN('dirlist', 'T:submoddirs', 'R') THEN DO
        SAY 'Cannot list subdirectories'
        EXIT 10
    END

    submods = ''
    DO WHILE ~EOF('dirlist')
        dirName = READLN('dirlist')
        IF dirName = '' THEN ITERATE
        /* Check if this directory has any test_*.b files */
        IF hasTestFiles(dirName) THEN
            submods = submods dirName
    END

    CALL CLOSE('dirlist')
    ADDRESS COMMAND 'delete >NIL: T:submoddirs'
END
ELSE DO
    submods = submod
END

/* Run tests for each submodule */
DO i = 1 TO WORDS(submods)
    sm = WORD(submods, i)
    SAY ''
    SAY '=== Testing:' sm '==='
    SAY ''
    CALL runSubmod(sm)
END

/* Summary */
SAY ''
SAY '=============================='
SAY 'TOTAL: Passed:' totalPass ', Failed:' totalFail ', Skipped:' totalSkip
SAY '=============================='

IF totalFail > 0 THEN EXIT 10
EXIT 0

/*------------------------------------------------------------*/
/* Check if a directory contains test_*.b files               */
/*------------------------------------------------------------*/
hasTestFiles: PROCEDURE
    PARSE ARG dirName

    ADDRESS COMMAND 'list' dirName 'PAT=test_#?.b LFORMAT=%s >T:probefiles'
    IF ~OPEN('probe', 'T:probefiles', 'R') THEN RETURN 0

    line = READLN('probe')
    CALL CLOSE('probe')
    ADDRESS COMMAND 'delete >NIL: T:probefiles'

    RETURN (line ~= '')

/*------------------------------------------------------------*/
/* Run all tests in a submodule directory                     */
/*------------------------------------------------------------*/
runSubmod: PROCEDURE EXPOSE totalPass totalFail totalSkip basCmd
    PARSE ARG sm

    /* Check if directory exists */
    IF ~EXISTS(sm) THEN DO
        SAY 'Submodule directory not found:' sm
        RETURN
    END

    /* Build submod if make file exists */
    makeFile = sm || '/make'
    IF EXISTS(makeFile) THEN DO
        curDir = PRAGMA('D')
        CALL PRAGMA('D', sm)
        ADDRESS COMMAND 'execute make >T:submod_build.log'
        makeRC = RC
        CALL PRAGMA('D', curDir)
        ADDRESS COMMAND 'delete >NIL: T:submod_build.log'
        IF makeRC ~= 0 THEN DO
            SAY '[FAIL]' sm '(module build error)'
            totalFail = totalFail + 1
            RETURN
        END
    END

    /* Get list of test_*.b files */
    ADDRESS COMMAND 'list' sm 'PAT=test_#?.b LFORMAT=%s >T:testfiles'

    IF ~OPEN('filelist', 'T:testfiles', 'R') THEN DO
        SAY 'No test files found in' sm
        RETURN
    END

    DO WHILE ~EOF('filelist')
        line = READLN('filelist')
        IF line = '' THEN ITERATE

        testName = LEFT(line, LENGTH(line) - 2)

        result = runTest(sm, testName)

        SELECT
            WHEN result = 'PASS' THEN totalPass = totalPass + 1
            WHEN result = 'FAIL' THEN totalFail = totalFail + 1
            OTHERWISE totalSkip = totalSkip + 1
        END
    END

    CALL CLOSE('filelist')
    ADDRESS COMMAND 'delete >NIL: T:testfiles'

    RETURN

/*------------------------------------------------------------*/
/* Run a single test                                          */
/*------------------------------------------------------------*/
runTest: PROCEDURE EXPOSE basCmd
    PARSE ARG sm, testName

    label = sm || '/' || testName

    /* Check source file for REM $skip: directive */
    srcSkip = checkSourceSkip(sm || '/' || testName || '.b')
    IF srcSkip ~= '' THEN DO
        SAY '[SKIP]' label '(' || srcSkip || ')'
        RETURN 'SKIP'
    END

    /* Save current directory and change to submod directory */
    curDir = PRAGMA('D')
    CALL PRAGMA('D', sm)

    /* Build: bas testname (suppress output via temp file) */
    ADDRESS COMMAND basCmd testName '>T:submod_build.log'
    buildRC = RC
    ADDRESS COMMAND 'delete >NIL: T:submod_build.log'

    IF buildRC ~= 0 THEN DO
        SAY '[FAIL]' label '(build error)'
        CALL cleanupFiles(testName)
        CALL PRAGMA('D', curDir)
        RETURN 'FAIL'
    END

    /* Check executable was created */
    IF ~EXISTS(testName) THEN DO
        SAY '[FAIL]' label '(no executable)'
        CALL cleanupFiles(testName)
        CALL PRAGMA('D', curDir)
        RETURN 'FAIL'
    END

    /* Run and capture output */
    outputFile = 'T:' || testName || '.output'
    ADDRESS COMMAND testName '>' outputFile
    runRC = RC

    /* Return to original directory */
    CALL PRAGMA('D', curDir)

    /* Check for SKIPPED: in output */
    skipped = checkSkipped(outputFile)
    IF skipped ~= '' THEN DO
        SAY '[SKIP]' label '(' || skipped || ')'
        CALL cleanupInDir(sm, testName, outputFile)
        RETURN 'SKIP'
    END

    /* Check for test failures in output */
    assertFailed = checkAssertFailed(outputFile)
    IF assertFailed THEN DO
        SAY '[FAIL]' label '(test failed)'
        SAY '  Output:'
        CALL showFile(outputFile)
        CALL cleanupInDir(sm, testName, outputFile)
        RETURN 'FAIL'
    END

    SAY '[PASS]' label
    CALL cleanupInDir(sm, testName, outputFile)
    RETURN 'PASS'

/*------------------------------------------------------------*/
/* Clean up generated files in submod directory                */
/*------------------------------------------------------------*/
cleanupInDir: PROCEDURE
    PARSE ARG sm, testName, outputFile

    asmFile = sm || '/' || testName || '.s'
    objFile = sm || '/' || testName || '.o'
    exeFile = sm || '/' || testName

    IF EXISTS(asmFile) THEN ADDRESS COMMAND 'delete >NIL:' asmFile
    IF EXISTS(objFile) THEN ADDRESS COMMAND 'delete >NIL:' objFile
    IF EXISTS(exeFile) THEN ADDRESS COMMAND 'delete >NIL:' exeFile
    IF EXISTS(outputFile) THEN ADDRESS COMMAND 'delete >NIL:' outputFile

    RETURN

/*------------------------------------------------------------*/
/* Clean up generated files (when still cd'd into submod dir) */
/*------------------------------------------------------------*/
cleanupFiles: PROCEDURE
    PARSE ARG testName

    asmFile = testName || '.s'
    objFile = testName || '.o'
    exeFile = testName

    IF EXISTS(asmFile) THEN ADDRESS COMMAND 'delete >NIL:' asmFile
    IF EXISTS(objFile) THEN ADDRESS COMMAND 'delete >NIL:' objFile
    IF EXISTS(exeFile) THEN ADDRESS COMMAND 'delete >NIL:' exeFile

    RETURN

/*------------------------------------------------------------*/
/* Check if output file contains test failures                */
/* 1. Testkit: parse "Results: N passed, M failed" line       */
/*    - If M > 0 => FAIL; if M = 0 => PASS                   */
/* 2. Legacy: detect "ASSERT FAILED" in output                */
/*------------------------------------------------------------*/
checkAssertFailed: PROCEDURE
    PARSE ARG filename

    IF ~OPEN('chkf', filename, 'R') THEN RETURN 0

    found = 0
    DO WHILE ~EOF('chkf')
        line = READLN('chkf')
        /* Testkit summary: "Results: N passed, M failed" */
        p = POS('failed', line)
        IF p > 0 & POS('Results:', line) > 0 THEN DO
            /* Extract the number before "failed" */
            chunk = STRIP(LEFT(line, p - 1))
            /* Last word before "failed" is the count */
            lastComma = LASTPOS(',', chunk)
            IF lastComma > 0 THEN DO
                failStr = STRIP(SUBSTR(chunk, lastComma + 1))
                IF DATATYPE(failStr, 'W') THEN DO
                    IF failStr > 0 THEN found = 1
                    LEAVE
                END
            END
        END
        /* Legacy: ASSERT FAILED */
        IF POS('ASSERT FAILED', line) > 0 THEN DO
            found = 1
            LEAVE
        END
    END

    CALL CLOSE('chkf')
    RETURN found

/*------------------------------------------------------------*/
/* Check if output contains SKIPPED: and return reason        */
/*------------------------------------------------------------*/
checkSkipped: PROCEDURE
    PARSE ARG filename

    IF ~OPEN('skpf', filename, 'R') THEN RETURN ''

    reason = ''
    DO WHILE ~EOF('skpf')
        line = READLN('skpf')
        p = POS('SKIPPED:', line)
        IF p > 0 THEN DO
            reason = STRIP(SUBSTR(line, p + 8))
            LEAVE
        END
    END

    CALL CLOSE('skpf')
    RETURN reason

/*------------------------------------------------------------*/
/* Display contents of a file (for debugging failures)        */
/*------------------------------------------------------------*/
showFile: PROCEDURE
    PARSE ARG filename

    IF ~OPEN('showf', filename, 'R') THEN DO
        SAY '    (cannot open file)'
        RETURN
    END

    lineNum = 1
    DO WHILE ~EOF('showf')
        line = READLN('showf')
        IF ~EOF('showf') | line ~= '' THEN
            SAY '    ' || lineNum || ': [' || line || ']'
        lineNum = lineNum + 1
    END

    CALL CLOSE('showf')
    RETURN

/*------------------------------------------------------------*/
/* Check source file for REM $skip: directive (first 10 lines)*/
/*------------------------------------------------------------*/
checkSourceSkip: PROCEDURE
    PARSE ARG filename

    IF ~OPEN('srcf', filename, 'R') THEN RETURN ''

    reason = ''
    DO i = 1 TO 10
        IF EOF('srcf') THEN LEAVE
        line = READLN('srcf')
        p = POS('$skip:', line)
        IF p > 0 THEN DO
            reason = STRIP(SUBSTR(line, p + 6))
            LEAVE
        END
    END

    CALL CLOSE('srcf')
    RETURN reason
