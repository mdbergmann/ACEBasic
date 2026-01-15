/* ACE BASIC Compiler Test Runner
 *
 * Usage: rx runner.rexx [category]
 *
 * Categories: syntax, arithmetic, floats, control, errors, all
 * Default: all
 *
 * Test levels:
 *   1 - Compile only (produces .s file)
 *   2 - Assemble (produces .o file)
 *   3 - Link (produces executable)
 *   4 - Execute and verify output
 */

PARSE ARG category

IF category = '' THEN category = 'all'

/* Configuration */
aceDir = 'ACE:'
basCmd = aceDir || 'bin/bas'
aceCmd = aceDir || 'bin/ace'
casesDir = 'tests/cases/'
expectedDir = 'tests/expected/'
resultsDir = 'tests/results/'

/* Counters */
totalPass = 0
totalFail = 0
totalSkip = 0

/* Categories to test */
IF category = 'all' THEN
    categories = 'syntax arithmetic floats control errors'
ELSE
    categories = category

/* Run tests for each category */
DO i = 1 TO WORDS(categories)
    cat = WORD(categories, i)
    SAY ''
    SAY '=== Testing:' cat '==='
    SAY ''
    CALL runCategory(cat)
END

/* Summary */
SAY ''
SAY '=============================='
SAY 'TOTAL: Passed:' totalPass ', Failed:' totalFail ', Skipped:' totalSkip
SAY '=============================='

IF totalFail > 0 THEN EXIT 10
EXIT 0

/*------------------------------------------------------------*/
/* Run all tests in a category                                */
/*------------------------------------------------------------*/
runCategory: PROCEDURE EXPOSE totalPass totalFail totalSkip basCmd aceCmd casesDir expectedDir resultsDir
    PARSE ARG cat

    catDir = casesDir || cat

    /* Check if directory exists */
    IF ~EXISTS(catDir) THEN DO
        SAY 'Category directory not found:' catDir
        RETURN
    END

    /* Get list of .b files */
    ADDRESS COMMAND 'list' catDir 'PAT=#?.b LFORMAT=%s >T:testfiles'

    IF ~OPEN('filelist', 'T:testfiles', 'R') THEN DO
        SAY 'No test files found in' catDir
        RETURN
    END

    DO WHILE ~EOF('filelist')
        line = READLN('filelist')
        IF line = '' THEN ITERATE

        testFile = catDir || '/' || line
        testName = LEFT(line, LENGTH(line) - 2)

        /* Error tests should fail compilation */
        expectFail = (cat = 'errors')

        /* Run test */
        result = runTest(testFile, testName, cat, expectFail)

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
runTest: PROCEDURE EXPOSE basCmd aceCmd expectedDir resultsDir
    PARSE ARG testFile, testName, category, expectFail

    /* Clean up any previous output */
    baseName = testFile
    IF RIGHT(baseName, 2) = '.b' THEN
        baseName = LEFT(baseName, LENGTH(baseName) - 2)

    asmFile = baseName || '.s'
    objFile = baseName || '.o'
    exeFile = baseName

    /* Level 1: Compile */
    ADDRESS COMMAND aceCmd testFile '>>' resultsDir || testName || '.log' '2>&1'
    compileRC = RC

    IF expectFail THEN DO
        /* Error tests: compilation should fail */
        IF compileRC ~= 0 THEN DO
            SAY '[PASS]' category || '/' || testName '(expected failure)'
            RETURN 'PASS'
        END
        ELSE DO
            SAY '[FAIL]' category || '/' || testName '(should have failed)'
            RETURN 'FAIL'
        END
    END

    /* Normal tests: compilation should succeed */
    IF compileRC ~= 0 THEN DO
        SAY '[FAIL]' category || '/' || testName '(compile error:' compileRC || ')'
        RETURN 'FAIL'
    END

    /* Check .s file was created */
    IF ~EXISTS(asmFile) THEN DO
        SAY '[FAIL]' category || '/' || testName '(no .s file)'
        RETURN 'FAIL'
    END

    /* Level 2-4: Full build and execute (optional) */
    expectedFile = expectedDir || testName || '.expected'

    IF EXISTS(expectedFile) THEN DO
        /* Full pipeline: compile, assemble, link, run */
        ADDRESS COMMAND basCmd testFile '>>' resultsDir || testName || '.log' '2>&1'
        buildRC = RC

        IF buildRC ~= 0 THEN DO
            SAY '[FAIL]' category || '/' || testName '(build error:' buildRC || ')'
            RETURN 'FAIL'
        END

        /* Run and capture output */
        outputFile = resultsDir || testName || '.output'
        ADDRESS COMMAND exeFile '>' outputFile
        runRC = RC

        /* Compare output */
        ADDRESS COMMAND 'diff' expectedFile outputFile '>NIL:'
        diffRC = RC

        IF diffRC = 0 THEN DO
            SAY '[PASS]' category || '/' || testName '(output verified)'
            RETURN 'PASS'
        END
        ELSE DO
            SAY '[FAIL]' category || '/' || testName '(output mismatch)'
            RETURN 'FAIL'
        END
    END
    ELSE DO
        /* Compile-only test */
        SAY '[PASS]' category || '/' || testName '(compiled)'
        RETURN 'PASS'
    END

    RETURN 'SKIP'
