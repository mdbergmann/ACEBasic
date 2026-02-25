REM test_dp_float_str.b - Phase 3: string conversion tests
REM #using ace:submods/dp-float/dp-float.o
REM #using ace:submods/testkit/testkit.o

#include <submods/dp-float.h>
#include <submods/testkit.h>

LONGINT ok, rv
ADDRESS a, b, r
STRING s$ SIZE 64

PRINT "=== DP Submodule Phase 3 Test ==="

TkInit

ok = DpOpen
TkAssertTrue(ok <> 0, "DpOpen")
IF ok = 0 THEN STOP

a = DpNew : b = DpNew : r = DpNew

REM --- Test 1: DpFromStr integer ---
DpFromStr(a, "42")
rv = DpToLong(a)
TkAssertEq&(rv, 42, "DpFromStr(42)")

REM --- Test 2: DpFromStr negative ---
DpFromStr(a, "-17")
rv = DpToLong(a)
TkAssertEq&(rv, -17, "DpFromStr(-17)")

REM --- Test 3: DpFromStr with decimal (12.5 -> verify via mul) ---
DpFromStr(a, "12.5")
DpFromLong(b, 2)
DpMul(r, a, b)
rv = DpToLong(r)
TkAssertEq&(rv, 25, "DpFromStr(12.5)*2")

REM --- Test 4: DpFromStr leading dot ---
DpFromStr(a, ".25")
DpFromLong(b, 4)
DpMul(r, a, b)
rv = DpToLong(r)
TkAssertEq&(rv, 1, "DpFromStr(.25)*4")

REM --- Test 5: DpFromStr with exponent ---
DpFromStr(a, "1.5e+2")
rv = DpToLong(a)
TkAssertEq&(rv, 150, "DpFromStr(1.5e+2)")

REM --- Test 6: DpFromStr negative exponent ---
DpFromStr(a, "5e-1")
DpFromLong(b, 10)
DpMul(r, a, b)
rv = DpToLong(r)
TkAssertEq&(rv, 5, "DpFromStr(5e-1)*10")

REM --- Test 7: DpFromStr with leading whitespace ---
DpFromStr(a, "  100")
rv = DpToLong(a)
TkAssertEq&(rv, 100, "DpFromStr('  100')")

REM --- Test 8: DpToStr$ of 0 ---
DpFromLong(a, 0)
s$ = DpToStr$(a)
TkAssertEqStr(s$, "0", "DpToStr$(0)")

REM --- Test 9: DpToStr$ of positive integer ---
DpFromLong(a, 42)
s$ = DpToStr$(a)
TkAssertEqStr(s$, "42", "DpToStr$(42)")

REM --- Test 10: DpToStr$ of negative integer ---
DpFromLong(a, -7)
s$ = DpToStr$(a)
TkAssertEqStr(s$, "-7", "DpToStr$(-7)")

REM --- Test 11: DpToStr$ of 12.5 ---
DpFromStr(a, "12.5")
s$ = DpToStr$(a)
TkAssertEqStr(s$, "12.5", "DpToStr$(12.5)")

REM --- Test 12: DpToStr$ of 1000 ---
DpFromLong(a, 1000)
s$ = DpToStr$(a)
TkAssertEqStr(s$, "1000", "DpToStr$(1000)")

REM --- Test 13: DpToStr$ of small decimal 0.25 ---
DpFromStr(a, "0.25")
s$ = DpToStr$(a)
TkAssertEqStr(s$, "0.25", "DpToStr$(0.25)")

REM --- Test 14: DpFromStr/DpToStr$ roundtrip ---
DpFromStr(a, "123.456")
s$ = DpToStr$(a)
PRINT "INFO: DpToStr$(123.456) = "; s$
DpFromStr(b, s$)
rv = DpCmp(a, b)
TkAssertEq&(rv, 0, "roundtrip 123.456")

REM --- Test 15: Large number -> scientific notation ---
DpFromStr(a, "1.5e+20")
s$ = DpToStr$(a)
PRINT "INFO: DpToStr$(1.5e+20) = "; s$
' Roundtrip check
DpFromStr(b, s$)
DpFromStr(r, "1.5e+20")
rv = DpCmp(b, r)
TkAssertEq&(rv, 0, "roundtrip 1.5e+20")

REM --- Summary ---
DpClose
TkSummary
