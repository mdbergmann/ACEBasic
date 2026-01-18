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
basCmd = 'execute ' || aceDir || 'bin/bas'
aceCmd = aceDir || 'bin/ace'
casesDir = 'cases/'
expectedDir = 'expected/'
resultsDir = 'T:'

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
    ADDRESS COMMAND aceCmd testFile '>NIL:'
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
        /* bas.vb expects just the base name, run from source directory */
        lastSlash = LASTPOS('/', testFile)
        IF lastSlash > 0 THEN DO
            srcDir = LEFT(testFile, lastSlash)
        END
        ELSE DO
            srcDir = ''
        END

        /* Change to source directory and build */
        curDir = PRAGMA('D')
        CALL PRAGMA('D', srcDir)
        ADDRESS COMMAND basCmd testName '>NIL:'
        buildRC = RC

        IF buildRC ~= 0 THEN DO
            CALL PRAGMA('D', curDir)
            SAY '[FAIL]' category || '/' || testName '(build error:' buildRC || ')'
            RETURN 'FAIL'
        END

        /* Run and capture output */
        outputFile = resultsDir || testName || '.output'

        /* Check if executable was created in source directory */
        IF ~EXISTS(testName) THEN DO
            CALL PRAGMA('D', curDir)
            SAY '[FAIL]' category || '/' || testName '(no executable created)'
            RETURN 'FAIL'
        END

        /* Run the executable (we're already in its directory) */
        ADDRESS COMMAND testName '>' outputFile
        runRC = RC

        /* Return to original directory */
        CALL PRAGMA('D', curDir)

        /* Compare output using native ARexx */
        match = compareFiles(expectedFile, outputFile)

        IF match THEN DO
            SAY '[PASS]' category || '/' || testName '(output verified)'
            RETURN 'PASS'
        END
        ELSE DO
            SAY '[FAIL]' category || '/' || testName '(output mismatch)'
            SAY '  Expected (' || expectedFile || '):'
            CALL showFile(expectedFile)
            SAY '  Got (' || outputFile || '):'
            CALL showFile(outputFile)
            RETURN 'FAIL'
        END
    END
    ELSE DO
        /* Compile-only test */
        SAY '[PASS]' category || '/' || testName '(compiled)'
        RETURN 'PASS'
    END

    RETURN 'SKIP'

/*------------------------------------------------------------*/
/* Compare two files, return 1 if identical, 0 if different   */
/* Filters out ANSI control sequences and normalizes output   */
/*------------------------------------------------------------*/
compareFiles: PROCEDURE
    PARSE ARG file1, file2

    /* Try to open both files */
    IF ~OPEN('f1', file1, 'R') THEN RETURN 0
    IF ~OPEN('f2', file2, 'R') THEN DO
        CALL CLOSE('f1')
        RETURN 0
    END

    /* Read and normalize both files */
    content1 = ''
    DO WHILE ~EOF('f1')
        line = READLN('f1')
        line = normalizeLine(line)
        IF line ~= '' THEN content1 = content1 || line || '0a'x
    END

    content2 = ''
    DO WHILE ~EOF('f2')
        line = READLN('f2')
        line = normalizeLine(line)
        IF line ~= '' THEN content2 = content2 || line || '0a'x
    END

    CALL CLOSE('f1')
    CALL CLOSE('f2')

    RETURN (content1 = content2)

/*------------------------------------------------------------*/
/* Normalize a line: strip control chars and trailing spaces  */
/*------------------------------------------------------------*/
normalizeLine: PROCEDURE
    PARSE ARG line

    /* Remove ANSI escape sequences (ESC [ ... letter) */
    /* ESC is character 155 (0x9B) on Amiga or 27 (0x1B) */
    result = ''
    i = 1
    DO WHILE i <= LENGTH(line)
        ch = SUBSTR(line, i, 1)
        chNum = C2D(ch)

        /* Skip ESC sequences */
        IF chNum = 155 | chNum = 27 THEN DO
            /* Skip until we hit a letter (end of sequence) */
            i = i + 1
            DO WHILE i <= LENGTH(line)
                ch2 = SUBSTR(line, i, 1)
                IF (ch2 >= 'A' & ch2 <= 'Z') | (ch2 >= 'a' & ch2 <= 'z') THEN LEAVE
                i = i + 1
            END
        END
        /* Skip other control characters (< 32) except space */
        ELSE IF chNum >= 32 THEN DO
            result = result || ch
        END
        i = i + 1
    END

    /* Strip trailing whitespace */
    DO WHILE LENGTH(result) > 0 & RIGHT(result, 1) = ' '
        result = LEFT(result, LENGTH(result) - 1)
    END

    RETURN result

/*------------------------------------------------------------*/
/* Display contents of a file (for debugging)                 */
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
