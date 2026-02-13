REM test_dp_math.b - Phase 2: trig, exp/log, sqrt, pow, single conv, ceil/floor
REM #using ace:submods/dp/dp.o

LIBRARY "mathffp"
LIBRARY "mathtrans"

#include <submods/dp.h>

LONGINT ok, rv
ADDRESS a, b, r, sc
LONGINT passed, failed
SINGLE sv

passed = 0
failed = 0

PRINT "=== DP Submodule Phase 2 Test ==="

ok = DpOpen
IF ok = 0 THEN
  PRINT "FAIL: DpOpen"
  STOP
END IF

a = DpNew : b = DpNew : r = DpNew : sc = DpNew

REM --- Test 1: DpFromSingle / DpToSingle roundtrip ---
REM 57 is exact in both FFP and IEEE DP
DpFromSingle(a, 57!)
rv = DpToLong(a)
IF rv = 57 THEN
  PRINT "PASS: DpFromSingle(57) -> DpToLong ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFromSingle(57) -> DpToLong expected 57, got"; rv
  failed = failed + 1
END IF

REM --- Test 2: DpToSingle roundtrip ---
DpFromLong(a, 42)
sv = DpToSingle(a)
IF sv = 42! THEN
  PRINT "PASS: DpToSingle(42) ="; sv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpToSingle(42) expected 42, got"; sv
  failed = failed + 1
END IF

REM --- Test 3: DpCeil of 3.5 (from 7/2) ---
DpFromLong(a, 7)
DpFromLong(b, 2)
DpDiv(r, a, b)
DpCeil(r, r)
rv = DpToLong(r)
IF rv = 4 THEN
  PRINT "PASS: DpCeil(3.5) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpCeil(3.5) expected 4, got"; rv
  failed = failed + 1
END IF

REM --- Test 4: DpFloor of 3.5 ---
DpFromLong(a, 7)
DpFromLong(b, 2)
DpDiv(r, a, b)
DpFloor(r, r)
rv = DpToLong(r)
IF rv = 3 THEN
  PRINT "PASS: DpFloor(3.5) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFloor(3.5) expected 3, got"; rv
  failed = failed + 1
END IF

REM --- Test 5: DpCeil of -3.5 ---
DpFromLong(a, -7)
DpFromLong(b, 2)
DpDiv(r, a, b)
DpCeil(r, r)
rv = DpToLong(r)
IF rv = -3 THEN
  PRINT "PASS: DpCeil(-3.5) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpCeil(-3.5) expected -3, got"; rv
  failed = failed + 1
END IF

REM --- Test 6: DpFloor of -3.5 ---
DpFromLong(a, -7)
DpFromLong(b, 2)
DpDiv(r, a, b)
DpFloor(r, r)
rv = DpToLong(r)
IF rv = -4 THEN
  PRINT "PASS: DpFloor(-3.5) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFloor(-3.5) expected -4, got"; rv
  failed = failed + 1
END IF

REM --- Test 7: DpSin(0) = 0 ---
DpFromLong(a, 0)
DpSin(r, a)
rv = DpToLong(r)
IF rv = 0 THEN
  PRINT "PASS: DpSin(0) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpSin(0) expected 0, got"; rv
  failed = failed + 1
END IF

REM --- Test 8: DpCos(0) = 1 ---
DpFromLong(a, 0)
DpCos(r, a)
rv = DpToLong(r)
IF rv = 1 THEN
  PRINT "PASS: DpCos(0) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpCos(0) expected 1, got"; rv
  failed = failed + 1
END IF

REM --- Test 9: DpSinCos(0) = sin=0, cos=1 ---
DpFromLong(a, 0)
DpSinCos(r, sc, a)
rv = DpToLong(r)
ok = DpToLong(sc)
IF rv = 0 AND ok = 1 THEN
  PRINT "PASS: DpSinCos(0) sin="; rv; " cos="; ok
  passed = passed + 1
ELSE
  PRINT "FAIL: DpSinCos(0) expected sin=0,cos=1, got sin="; rv; " cos="; ok
  failed = failed + 1
END IF

REM --- Test 10: DpSqrt(144) = 12 ---
DpFromLong(a, 144)
DpSqrt(r, a)
rv = DpToLong(r)
IF rv = 12 THEN
  PRINT "PASS: DpSqrt(144) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpSqrt(144) expected 12, got"; rv
  failed = failed + 1
END IF

REM --- Test 11: DpPow(2, 10) = 1024 ---
DpFromLong(a, 2)
DpFromLong(b, 10)
DpPow(r, a, b)
rv = DpToLong(r)
IF rv = 1024 THEN
  PRINT "PASS: DpPow(2,10) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpPow(2,10) expected 1024, got"; rv
  failed = failed + 1
END IF

REM --- Test 12: DpLog10(1000) = 3 ---
DpFromLong(a, 1000)
DpLog10(r, a)
rv = DpToLong(r)
IF rv = 3 THEN
  PRINT "PASS: DpLog10(1000) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpLog10(1000) expected 3, got"; rv
  failed = failed + 1
END IF

REM --- Test 13: DpExp/DpLog roundtrip: floor(exp(log(100))) = 100 ---
DpFromLong(a, 100)
DpLog(r, a)
DpExp(r, r)
DpFloor(r, r)
rv = DpToLong(r)
IF rv = 100 THEN
  PRINT "PASS: floor(exp(log(100))) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: floor(exp(log(100))) expected 100, got"; rv
  failed = failed + 1
END IF

REM --- Test 14: DpTan(0) = 0 ---
DpFromLong(a, 0)
DpTan(r, a)
rv = DpToLong(r)
IF rv = 0 THEN
  PRINT "PASS: DpTan(0) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpTan(0) expected 0, got"; rv
  failed = failed + 1
END IF

REM --- Test 15: DpAsin/DpAcos: asin(0)=0, acos(1)=0 ---
DpFromLong(a, 0)
DpAsin(r, a)
rv = DpToLong(r)
IF rv = 0 THEN
  PRINT "PASS: DpAsin(0) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpAsin(0) expected 0, got"; rv
  failed = failed + 1
END IF

REM --- Test 16: DpAcos(1) = 0 ---
DpFromLong(a, 1)
DpAcos(r, a)
rv = DpToLong(r)
IF rv = 0 THEN
  PRINT "PASS: DpAcos(1) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpAcos(1) expected 0, got"; rv
  failed = failed + 1
END IF

REM --- Test 17: DpAtan(0) = 0 ---
DpFromLong(a, 0)
DpAtan(r, a)
rv = DpToLong(r)
IF rv = 0 THEN
  PRINT "PASS: DpAtan(0) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpAtan(0) expected 0, got"; rv
  failed = failed + 1
END IF

REM --- Test 18: DpSinh(0) = 0 ---
DpFromLong(a, 0)
DpSinh(r, a)
rv = DpToLong(r)
IF rv = 0 THEN
  PRINT "PASS: DpSinh(0) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpSinh(0) expected 0, got"; rv
  failed = failed + 1
END IF

REM --- Test 19: DpCosh(0) = 1 ---
DpFromLong(a, 0)
DpCosh(r, a)
rv = DpToLong(r)
IF rv = 1 THEN
  PRINT "PASS: DpCosh(0) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpCosh(0) expected 1, got"; rv
  failed = failed + 1
END IF

REM --- Test 20: DpTanh(0) = 0 ---
DpFromLong(a, 0)
DpTanh(r, a)
rv = DpToLong(r)
IF rv = 0 THEN
  PRINT "PASS: DpTanh(0) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpTanh(0) expected 0, got"; rv
  failed = failed + 1
END IF

REM --- Summary ---
PRINT ""
PRINT "Results:"; passed; "passed,"; failed; "failed"
IF failed = 0 THEN
  PRINT "ALL TESTS PASSED"
ELSE
  PRINT "SOME TESTS FAILED"
END IF

DpClose
