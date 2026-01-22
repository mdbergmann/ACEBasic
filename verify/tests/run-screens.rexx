/* Run Screen Tests for Visual Verification
 *
 * Usage: rx run-screens.rexx
 *
 * Builds and runs each screen test so you can visually verify
 * that screens open correctly.
 */

basCmd = 'execute ACE:bin/bas'
casesDir = 'cases/screens/'

SAY ''
SAY '=== Screen Tests - Visual Verification ==='
SAY ''

/* Get list of .b files */
ADDRESS COMMAND 'list' casesDir 'PAT=#?.b LFORMAT=%s >T:screenfiles'

IF ~OPEN('filelist', 'T:screenfiles', 'R') THEN DO
    SAY 'No screen test files found'
    EXIT 5
END

DO WHILE ~EOF('filelist')
    line = READLN('filelist')
    IF line = '' THEN ITERATE

    testName = LEFT(line, LENGTH(line) - 2)

    SAY 'Building:' testName

    /* Build the test */
    curDir = PRAGMA('D')
    CALL PRAGMA('D', casesDir)
    ADDRESS COMMAND basCmd testName '>NIL:'
    buildRC = RC

    IF buildRC ~= 0 THEN DO
        SAY '  Build failed!'
        CALL PRAGMA('D', curDir)
        ITERATE
    END

    /* Run the test */
    SAY 'Running:' testName
    SAY ''
    ADDRESS COMMAND testName

    /* Cleanup */
    IF EXISTS(testName) THEN ADDRESS COMMAND 'delete >NIL:' testName
    IF EXISTS(testName || '.s') THEN ADDRESS COMMAND 'delete >NIL:' testName || '.s'
    IF EXISTS(testName || '.o') THEN ADDRESS COMMAND 'delete >NIL:' testName || '.o'

    CALL PRAGMA('D', curDir)
END

CALL CLOSE('filelist')
ADDRESS COMMAND 'delete >NIL: T:screenfiles'

SAY ''
SAY '=== Screen Tests Complete ==='
SAY ''

EXIT 0
