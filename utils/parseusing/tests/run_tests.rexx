/* parseusing Test Runner
 *
 * Usage: rx run_tests.rexx
 *
 * Can be run from any directory (uses absolute paths).
 * Requires parseusing binary at ace:bin/parseusing.
 */

parseusing = 'ace:bin/parseusing'

pass = 0
fail = 0

/* Check parseusing binary exists */
IF ~EXISTS(parseusing) THEN DO
    SAY '[FAIL] parseusing binary not found at' parseusing
    EXIT 10
END

/* --- Test 1: Single #using directive --- */
CALL writeFile('T:pu_input1.b', 'REM This is a test program' || '0a'x || 'REM #using ace:submods/list/list.o' || '0a'x || 'PRINT "hello"')
CALL runTest('single #using', 'T:pu_input1.b', 'ace:submods/list/list.o')

/* --- Test 2: Multiple #using directives --- */
CALL writeFile('T:pu_input2.b', 'REM #using ace:submods/list/list.o' || '0a'x || 'REM some comment' || '0a'x || 'REM #using ace:submods/testkit/testkit.o' || '0a'x || 'PRINT "test"')
CALL runTest('multiple #using', 'T:pu_input2.b', 'ace:submods/list/list.o ace:submods/testkit/testkit.o')

/* --- Test 3: No #using directives --- */
CALL writeFile('T:pu_input3.b', 'REM Just a regular program' || '0a'x || 'PRINT "hello"')
CALL runTest('no #using', 'T:pu_input3.b', '')

/* --- Test 4: Case-insensitive matching --- */
CALL writeFile('T:pu_input4.b', 'rem #USING ace:submods/foo/foo.o' || '0a'x || 'REM #Using ace:submods/bar/bar.o')
CALL runTest('case insensitive', 'T:pu_input4.b', 'ace:submods/foo/foo.o ace:submods/bar/bar.o')

/* --- Test 5: Non-existent input file --- */
CALL runTest('non-existent file', 'T:pu_nonexistent.b', '')

/* --- Test 6: #using beyond line 20 --- */
content = ''
DO i = 1 TO 21
    content = content || 'REM line' i || '0a'x
END
content = content || 'REM #using ace:submods/late/late.o'
CALL writeFile('T:pu_input6.b', content)
CALL runTest('beyond line 20', 'T:pu_input6.b', '')

/* Cleanup */
ADDRESS COMMAND 'delete >NIL: T:pu_input#?'
ADDRESS COMMAND 'delete >NIL: T:pu_out#?'

/* Summary */
SAY ''
SAY 'Results:' pass 'passed,' fail 'failed'
IF fail > 0 THEN EXIT 10
EXIT 0

/*------------------------------------------------------------*/
runTest: PROCEDURE EXPOSE parseusing pass fail
    PARSE ARG testName, inputFile, expected

    outputFile = 'T:pu_out.txt'

    /* Run parseusing with output file argument */
    ADDRESS COMMAND parseusing inputFile outputFile
    rc = RC

    /* Read output (first line only) */
    got = ''
    IF EXISTS(outputFile) THEN DO
        IF OPEN('outf', outputFile, 'R') THEN DO
            IF ~EOF('outf') THEN got = READLN('outf')
            CALL CLOSE('outf')
        END
        ADDRESS COMMAND 'delete >NIL:' outputFile
    END

    /* Compare */
    IF got = expected THEN DO
        SAY '[PASS]' testName
        pass = pass + 1
    END; ELSE DO
        SAY '[FAIL]' testName
        SAY "  expected: '" || expected || "'"
        SAY "  got:      '" || got || "'"
        fail = fail + 1
    END

    RETURN

/*------------------------------------------------------------*/
writeFile: PROCEDURE
    PARSE ARG filename, content

    IF OPEN('wf', filename, 'W') THEN DO
        CALL WRITECH('wf', content)
        CALL CLOSE('wf')
    END

    RETURN
