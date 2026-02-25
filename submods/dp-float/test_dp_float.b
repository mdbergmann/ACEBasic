REM test_dp_float.b - Phase 1: core DP submodule test
REM #using ace:submods/dp-float/dp-float.o
REM #using ace:submods/testkit/testkit.o

#include <submods/dp-float.h>
#include <submods/testkit.h>

LONGINT ok, rv
ADDRESS a, b, r

PRINT "=== DP Submodule Phase 1 Test ==="

TkInit

REM --- Test 1: DpOpen ---
ok = DpOpen
TkAssertEq&(ok, -1, "DpOpen")
IF ok <> -1 THEN STOP

REM --- Test 2: DpNew ---
a = DpNew
b = DpNew
r = DpNew
TkAssertTrue(a <> 0 AND b <> 0 AND r <> 0, "DpNew")
IF a = 0 OR b = 0 OR r = 0 THEN STOP

REM --- Test 3: DpFromLong / DpToLong roundtrip ---
DpFromLong(a, 42)
rv = DpToLong(a)
TkAssertEq&(rv, 42, "DpFromLong/DpToLong 42")

REM --- Test 4: DpAdd 21+3=24 ---
DpFromLong(a, 21)
DpFromLong(b, 3)
DpAdd(r, a, b)
rv = DpToLong(r)
TkAssertEq&(rv, 24, "DpAdd 21+3")

REM --- Test 5: DpSub 21-3=18 ---
DpFromLong(a, 21)
DpFromLong(b, 3)
DpSub(r, a, b)
rv = DpToLong(r)
TkAssertEq&(rv, 18, "DpSub 21-3")

REM --- Test 6: DpMul 21*3=63 ---
DpFromLong(a, 21)
DpFromLong(b, 3)
DpMul(r, a, b)
rv = DpToLong(r)
TkAssertEq&(rv, 63, "DpMul 21*3")

REM --- Test 7: DpDiv 21/3=7 ---
DpFromLong(a, 21)
DpFromLong(b, 3)
DpDiv(r, a, b)
rv = DpToLong(r)
TkAssertEq&(rv, 7, "DpDiv 21/3")

REM --- Test 8: DpCmp greater ---
DpFromLong(a, 10)
DpFromLong(b, 5)
rv = DpCmp(a, b)
TkAssertEq&(rv, 1, "DpCmp 10>5")

REM --- Test 9: DpCmp less ---
DpFromLong(a, 5)
DpFromLong(b, 10)
rv = DpCmp(a, b)
TkAssertEq&(rv, -1, "DpCmp 5<10")

REM --- Test 10: DpCmp equal ---
DpFromLong(a, 7)
DpFromLong(b, 7)
rv = DpCmp(a, b)
TkAssertEq&(rv, 0, "DpCmp 7=7")

REM --- Test 11: DpAbs |-5| = 5 ---
DpFromLong(a, -5)
DpAbs(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, 5, "DpAbs |-5|")

REM --- Test 12: DpNeg -(7) = -7 ---
DpFromLong(a, 7)
DpNeg(r, a)
rv = DpToLong(r)
TkAssertEq&(rv, -7, "DpNeg -(7)")

REM --- Test 13: DpDiv non-integer result truncation (7/2=3 via DpToLong) ---
DpFromLong(a, 7)
DpFromLong(b, 2)
DpDiv(r, a, b)
rv = DpToLong(r)
TkAssertEq&(rv, 3, "DpDiv 7/2 truncated")

REM --- Summary ---
DpClose
TkSummary
