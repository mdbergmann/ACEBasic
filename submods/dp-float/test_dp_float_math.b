REM test_dp_float_math.b - Phase 2: trig, exp/log, sqrt, pow, single conv, ceil/floor
REM #using ace:submods/dp-float/dp-float.o
REM #using ace:submods/testkit/testkit.o

LIBRARY "mathffp"
LIBRARY "mathtrans"

#include <submods/dp-float.h>
#include <submods/testkit.h>

LONGINT ok, rv
ADDRESS a, b, r, sc
SINGLE sv

PRINT "=== DP Submodule Phase 2 Test ==="

TkInit

ok = DpOpen
TkAssertTrue(ok <> 0, "DpOpen")
IF ok = 0 THEN STOP

a = DpNew : b = DpNew : r = DpNew : sc = DpNew

REM --- Test 1: DpFromSingle / DpToSingle roundtrip ---
REM 57 is exact in both FFP and IEEE DP
DpFromSingle(a, 57!)
rv = DpToLong(a)
TkAssertEq&(rv, 57, "DpFromSingle(57) -> DpToLong")

REM --- Test 2: DpToSingle roundtrip ---
DpFromLong(a, 42)
sv = DpToSingle(a)
TkAssertTrue(sv = 42!, "DpToSingle(42)")

REM --- Test 3: DpCeil of 3.5 (from 7/2) ---
DpFromLong(a, 7)
DpFromLong(b, 2)
DpDiv(r, a, b)
DpCeil(r, r)
rv = DpToLong(r)
TkAssertEq&(rv, 4, "DpCeil(3.5)")

REM --- Test 4: DpFloor of 3.5 ---
DpFromLong(a, 7)
DpFromLong(b, 2)
DpDiv(r, a, b)
DpFloor(r, r)
rv = DpToLong(r)
TkAssertEq&(rv, 3, "DpFloor(3.5)")

REM --- Test 5: DpCeil of -3.5 ---
DpFromLong(a, -7)
DpFromLong(b, 2)
DpDiv(r, a, b)
DpCeil(r, r)
rv = DpToLong(r)
TkAssertEq&(rv, -3, "DpCeil(-3.5)")

REM --- Test 6: DpFloor of -3.5 ---
DpFromLong(a, -7)
DpFromLong(b, 2)
DpDiv(r, a, b)
DpFloor(r, r)
rv = DpToLong(r)
TkAssertEq&(rv, -4, "DpFloor(-3.5)")

REM --- Test 7: DpSin(0) = 0 ---
DpFromLong(a, 0)
DpSin(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 0, "DpSin(0)")

REM --- Test 8: DpCos(0) = 1 ---
DpFromLong(a, 0)
DpCos(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 1, "DpCos(0)")

REM --- Test 9: DpSinCos(0) = sin=0, cos=1 ---
DpFromLong(a, 0)
DpSinCos(r, sc, a)
rv = DpToLong(r)
ok = DpToLong(sc)
TkAssertTrue(rv = 0 AND ok = 1, "DpSinCos(0) sin=0 cos=1")

REM --- Test 10: DpSqrt(144) = 12 ---
DpFromLong(a, 144)
DpSqrt(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 12, "DpSqrt(144)")

REM --- Test 11: DpPow(2, 10) = 1024 ---
DpFromLong(a, 2)
DpFromLong(b, 10)
DpPow(r, a, b)
rv = DpToLong(r)
TkAssertEq&(rv, 1024, "DpPow(2,10)")

REM --- Test 12: DpLog10(1000) = 3 ---
DpFromLong(a, 1000)
DpLog10(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 3, "DpLog10(1000)")

REM --- Test 13: DpExp/DpLog roundtrip: floor(exp(log(100))) = 100 ---
DpFromLong(a, 100)
DpLog(r, a)
DpExp(r, r)
DpFloor(r, r)
rv = DpToLong(r)
TkAssertEq&(rv, 100, "floor(exp(log(100)))")

REM --- Test 14: DpTan(0) = 0 ---
DpFromLong(a, 0)
DpTan(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 0, "DpTan(0)")

REM --- Test 15: DpAsin(0) = 0 ---
DpFromLong(a, 0)
DpAsin(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 0, "DpAsin(0)")

REM --- Test 16: DpAcos(1) = 0 ---
DpFromLong(a, 1)
DpAcos(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 0, "DpAcos(1)")

REM --- Test 17: DpAtan(0) = 0 ---
DpFromLong(a, 0)
DpAtan(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 0, "DpAtan(0)")

REM --- Test 18: DpSinh(0) = 0 ---
DpFromLong(a, 0)
DpSinh(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 0, "DpSinh(0)")

REM --- Test 19: DpCosh(0) = 1 ---
DpFromLong(a, 0)
DpCosh(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 1, "DpCosh(0)")

REM --- Test 20: DpTanh(0) = 0 ---
DpFromLong(a, 0)
DpTanh(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 0, "DpTanh(0)")

REM --- Summary ---
DpClose
TkSummary
