REM test_info.b - Test file info query functions
REM
REM Tests FadSize&, FadProtect&, FadComment$, FadDate%, and
REM date component accessors.
REM Uses RAM: for temp files.

REM #using ace:submods/fad/fad.o
#include <submods/fad.h>

LONGINT passed, failed
passed = 0
failed = 0

PRINT "=== fad File Info Tests ==="

{* --- Setup: create a temp file with known content --- *}

OPEN "O", #1, "RAM:fadtest_info.tmp"
PRINT #1, "Hello World"
CLOSE #1

{* --- FadSize& tests --- *}

LONGINT sz
sz = FadSize&("RAM:fadtest_info.tmp")
' "Hello World" + newline = 12 bytes
IF sz > 0 THEN
  PRINT "PASS: FadSize& returned"; sz; "(positive)"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadSize& returned"; sz
  failed = failed + 1
END IF

IF FadSize&("RAM:nonexistent_xyz") = -1 THEN
  PRINT "PASS: FadSize& returns -1 for missing file"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadSize& for missing file, got:"; FadSize&("RAM:nonexistent_xyz")
  failed = failed + 1
END IF

{* --- FadProtect& tests --- *}

LONGINT prot
prot = FadProtect&("RAM:fadtest_info.tmp")
IF prot <> -1 THEN
  PRINT "PASS: FadProtect& returned value"; prot
  passed = passed + 1
ELSE
  PRINT "FAIL: FadProtect& returned -1 (not found)"
  failed = failed + 1
END IF

{* --- FadComment$ tests --- *}

STRING cmt$
cmt$ = FadComment$("RAM:fadtest_info.tmp")
' New files typically have no comment
PRINT "INFO: FadComment$ = '"; cmt$; "'"
passed = passed + 1

{* --- FadDate% tests --- *}

IF FadDate%("RAM:fadtest_info.tmp") THEN
  PRINT "PASS: FadDate% returned success"
  passed = passed + 1

  ' Days should be non-zero (days since Jan 1, 1978)
  IF FadDateDays& > 0 THEN
    PRINT "PASS: FadDateDays& ="; FadDateDays&
    passed = passed + 1
  ELSE
    PRINT "FAIL: FadDateDays& ="; FadDateDays&
    failed = failed + 1
  END IF

  ' Mins and ticks should be valid (0 is possible for midnight)
  PRINT "INFO: FadDateMins& ="; FadDateMins&; " FadDateTicks& ="; FadDateTicks&
  passed = passed + 1
ELSE
  PRINT "FAIL: FadDate% returned failure"
  failed = failed + 1
END IF

IF NOT FadDate%("RAM:nonexistent_xyz") THEN
  PRINT "PASS: FadDate% fails for missing file"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadDate% succeeded for missing file"
  failed = failed + 1
END IF

{* --- Cleanup --- *}

KILL "RAM:fadtest_info.tmp"

{* --- Summary --- *}
PRINT ""
PRINT "Results:"; passed; "passed,"; failed; "failed"

ASSERT failed = 0, "Some info tests failed"
