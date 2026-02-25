REM #using ace:submods/testkit/testkit.o

{* TestKit smoke test - exercises every assert variant *}

#include <submods/testkit.h>

PRINT "=== TestKit Smoke Test ==="
PRINT

{* --- Verify FAIL output format --- *}
PRINT "--- Verify FAIL output (2 expected) ---"
TkInit
TkAssertTrue(0, "intentional fail for true")
TkAssertEqStr("a", "b", "intentional fail for eqstr")
PRINT "(above 2 FAILs are expected)"
PRINT

{* --- Reset and run all-pass tests --- *}
TkInit

PRINT "--- TkAssertTrue ---"
TkAssertTrue(-1, "true literal")
TkAssertTrue(1, "nonzero")

PRINT "--- TkAssertFalse ---"
TkAssertFalse(0, "zero is false")

PRINT "--- TkAssertEq% ---"
SHORTINT sv%
sv% = 42
TkAssertEq%(sv%, 42, "shortint 42 = 42")

PRINT "--- TkAssertEq& ---"
LONGINT lv&
lv& = 100000
TkAssertEq&(lv&, 100000, "longint 100000")

PRINT "--- TkAssertEqAddr ---"
ADDRESS av
av = 0
TkAssertEqAddr(av, 0, "null addr = null")

PRINT "--- TkAssertEqStr ---"
TkAssertEqStr("hello", "hello", "hello = hello")
TkAssertEqStr("", "", "empty = empty")

PRINT "--- TkAssertEqFloat ---"
SINGLE fv
fv = 3.14
TkAssertEqFloat(fv, 3.14, "3.14 = 3.14")
TkAssertEqFloat(1.0005, 1.0, "within tolerance")

PRINT "--- TkAssertNeq& ---"
TkAssertNeq&(10, 20, "10 <> 20")

PRINT "--- TkAssertNeqAddr ---"
TkAssertNeqAddr(100, 200, "100 <> 200")

PRINT
PRINT "Expected: 12 passed, 0 failed"
TkSummary
