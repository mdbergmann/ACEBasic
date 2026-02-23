REM test_exists.b - Test existence and type check functions
REM
REM Tests FadExists%, FadIsFile%, FadIsDir%, and FadError&.
REM Uses RAM: for temp files (fast, no disk I/O).

REM #using ace:submods/fad/fad.o
#include <submods/fad.h>
EXTERNAL fad

LONGINT passed, failed
passed = 0
failed = 0

PRINT "=== fad Existence & Type Check Tests ==="

{* --- Setup: create a temp file in RAM: --- *}

OPEN "O", #1, "RAM:fadtest_exists.tmp"
PRINT #1, "test data"
CLOSE #1

{* --- FadExists% tests --- *}

IF FadExists%("RAM:fadtest_exists.tmp") THEN
  PRINT "PASS: exists RAM:fadtest_exists.tmp"
  passed = passed + 1
ELSE
  PRINT "FAIL: exists RAM:fadtest_exists.tmp"
  failed = failed + 1
END IF

IF FadExists%("RAM:") THEN
  PRINT "PASS: exists RAM: (directory)"
  passed = passed + 1
ELSE
  PRINT "FAIL: exists RAM:"
  failed = failed + 1
END IF

IF NOT FadExists%("RAM:nonexistent_file_xyz") THEN
  PRINT "PASS: not exists nonexistent file"
  passed = passed + 1
ELSE
  PRINT "FAIL: nonexistent file reported as existing"
  failed = failed + 1
END IF

{* --- FadIsFile% tests --- *}

IF FadIsFile%("RAM:fadtest_exists.tmp") THEN
  PRINT "PASS: isfile RAM:fadtest_exists.tmp"
  passed = passed + 1
ELSE
  PRINT "FAIL: isfile RAM:fadtest_exists.tmp"
  failed = failed + 1
END IF

IF NOT FadIsFile%("RAM:") THEN
  PRINT "PASS: RAM: is not a file"
  passed = passed + 1
ELSE
  PRINT "FAIL: RAM: reported as file"
  failed = failed + 1
END IF

IF NOT FadIsFile%("RAM:nonexistent_file_xyz") THEN
  PRINT "PASS: nonexistent is not a file"
  passed = passed + 1
ELSE
  PRINT "FAIL: nonexistent reported as file"
  failed = failed + 1
END IF

{* --- FadIsDir% tests --- *}

IF FadIsDir%("RAM:") THEN
  PRINT "PASS: isdir RAM:"
  passed = passed + 1
ELSE
  PRINT "FAIL: isdir RAM:"
  failed = failed + 1
END IF

IF NOT FadIsDir%("RAM:fadtest_exists.tmp") THEN
  PRINT "PASS: file is not a dir"
  passed = passed + 1
ELSE
  PRINT "FAIL: file reported as dir"
  failed = failed + 1
END IF

IF NOT FadIsDir%("RAM:nonexistent_file_xyz") THEN
  PRINT "PASS: nonexistent is not a dir"
  passed = passed + 1
ELSE
  PRINT "FAIL: nonexistent reported as dir"
  failed = failed + 1
END IF

{* --- FadError& test --- *}

' After a failed operation, FadError should be non-zero
FadExists%("RAM:nonexistent_file_xyz")
IF FadError& <> 0 THEN
  PRINT "PASS: FadError& set after failure"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadError& not set after failure"
  failed = failed + 1
END IF

' After a successful operation, FadError should be 0
FadExists%("RAM:fadtest_exists.tmp")
IF FadError& = 0 THEN
  PRINT "PASS: FadError& cleared after success"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadError& not cleared after success"
  failed = failed + 1
END IF

{* --- Cleanup --- *}

KILL "RAM:fadtest_exists.tmp"

{* --- Summary --- *}
PRINT ""
PRINT "Results:"; passed; "passed,"; failed; "failed"

ASSERT failed = 0, "Some exists tests failed"
