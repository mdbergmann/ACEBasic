REM test_exists.b - Test existence and type check functions
REM
REM Tests FadExists%, FadIsFile%, FadIsDir%, and FadError&.
REM Uses RAM: for temp files (fast, no disk I/O).

REM #using ace:submods/fad/fad.o
REM #using ace:submods/testkit/testkit.o
#include <submods/fad.h>
#include <submods/testkit.h>

PRINT "=== fad Existence & Type Check Tests ==="

TkInit

{* --- Setup: create a temp file in RAM: --- *}

OPEN "O", #1, "RAM:fadtest_exists.tmp"
PRINT #1, "test data"
CLOSE #1

{* --- FadExists% tests --- *}

TkAssertTrue(FadExists%("RAM:fadtest_exists.tmp"), "exists RAM:fadtest_exists.tmp")
TkAssertTrue(FadExists%("RAM:"), "exists RAM: (directory)")
TkAssertTrue(NOT FadExists%("RAM:nonexistent_file_xyz"), "not exists nonexistent file")

{* --- FadIsFile% tests --- *}

TkAssertTrue(FadIsFile%("RAM:fadtest_exists.tmp"), "isfile RAM:fadtest_exists.tmp")
TkAssertTrue(NOT FadIsFile%("RAM:"), "RAM: is not a file")
TkAssertTrue(NOT FadIsFile%("RAM:nonexistent_file_xyz"), "nonexistent is not a file")

{* --- FadIsDir% tests --- *}

TkAssertTrue(FadIsDir%("RAM:"), "isdir RAM:")
TkAssertTrue(NOT FadIsDir%("RAM:fadtest_exists.tmp"), "file is not a dir")
TkAssertTrue(NOT FadIsDir%("RAM:nonexistent_file_xyz"), "nonexistent is not a dir")

{* --- FadError& test --- *}

' After a failed operation, FadError should be non-zero
FadExists%("RAM:nonexistent_file_xyz")
TkAssertTrue(FadError& <> 0, "FadError& set after failure")

' After a successful operation, FadError should be 0
FadExists%("RAM:fadtest_exists.tmp")
TkAssertEq&(FadError&, 0, "FadError& cleared after success")

{* --- Cleanup --- *}

KILL "RAM:fadtest_exists.tmp"

{* --- Summary --- *}
TkSummary
