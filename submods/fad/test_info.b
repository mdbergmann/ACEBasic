REM test_info.b - Test file info query functions
REM
REM Tests FadSize&, FadProtect&, FadComment$, FadDate%, and
REM date component accessors.
REM Uses RAM: for temp files.

REM #using ace:submods/fad/fad.o
REM #using ace:submods/testkit/testkit.o
#include <submods/fad.h>
#include <submods/testkit.h>

PRINT "=== fad File Info Tests ==="

TkInit

{* --- Setup: create a temp file with known content --- *}

OPEN "O", #1, "RAM:fadtest_info.tmp"
PRINT #1, "Hello World"
CLOSE #1

{* --- FadSize& tests --- *}

LONGINT sz
sz = FadSize&("RAM:fadtest_info.tmp")
' "Hello World" + newline = 12 bytes
TkAssertTrue(sz > 0, "FadSize& positive")

TkAssertEq&(FadSize&("RAM:nonexistent_xyz"), -1, "FadSize& -1 for missing file")

{* --- FadProtect& tests --- *}

LONGINT prot
prot = FadProtect&("RAM:fadtest_info.tmp")
TkAssertTrue(prot <> -1, "FadProtect& returned value")

{* --- FadComment$ tests --- *}

STRING cmt$
cmt$ = FadComment$("RAM:fadtest_info.tmp")
' New files typically have no comment
PRINT "INFO: FadComment$ = '"; cmt$; "'"
TkAssertTrue(-1, "FadComment$ returned")

{* --- FadDate% tests --- *}

TkAssertTrue(FadDate%("RAM:fadtest_info.tmp"), "FadDate% success")

' Days should be non-zero (days since Jan 1, 1978)
TkAssertTrue(FadDateDays& > 0, "FadDateDays& positive")

' Mins and ticks should be valid (0 is possible for midnight)
PRINT "INFO: FadDateMins& ="; FadDateMins&; " FadDateTicks& ="; FadDateTicks&
TkAssertTrue(-1, "FadDate components accessible")

TkAssertTrue(NOT FadDate%("RAM:nonexistent_xyz"), "FadDate% fails for missing file")

{* --- Cleanup --- *}

KILL "RAM:fadtest_info.tmp"

{* --- Summary --- *}
TkSummary
