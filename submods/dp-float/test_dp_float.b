REM test_dp_float.b - Phase 1: core DP submodule test
REM #using ace:submods/dp-float/dp-float.o

#include <submods/dp-float.h>

LONGINT ok, rv
ADDRESS a, b, r
LONGINT passed, failed

passed = 0
failed = 0

PRINT "=== DP Submodule Phase 1 Test ==="

REM --- Test 1: DpOpen ---
ok = DpOpen
IF ok = -1 THEN
  PRINT "PASS: DpOpen"
  passed = passed + 1
ELSE
  PRINT "FAIL: DpOpen returned"; ok
  failed = failed + 1
  STOP
END IF

REM --- Test 2: DpNew ---
a = DpNew
b = DpNew
r = DpNew
IF a <> 0 AND b <> 0 AND r <> 0 THEN
  PRINT "PASS: DpNew"
  passed = passed + 1
ELSE
  PRINT "FAIL: DpNew returned 0"
  failed = failed + 1
  STOP
END IF

REM --- Test 3: DpFromLong / DpToLong roundtrip ---
DpFromLong(a, 42)
rv = DpToLong(a)
IF rv = 42 THEN
  PRINT "PASS: DpFromLong/DpToLong 42 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFromLong/DpToLong expected 42, got"; rv
  failed = failed + 1
END IF

REM --- Test 4: DpAdd 21+3=24 ---
DpFromLong(a, 21)
DpFromLong(b, 3)
DpAdd(r, a, b)
rv = DpToLong(r)
IF rv = 24 THEN
  PRINT "PASS: DpAdd 21+3 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpAdd expected 24, got"; rv
  failed = failed + 1
END IF

REM --- Test 5: DpSub 21-3=18 ---
DpFromLong(a, 21)
DpFromLong(b, 3)
DpSub(r, a, b)
rv = DpToLong(r)
IF rv = 18 THEN
  PRINT "PASS: DpSub 21-3 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpSub expected 18, got"; rv
  failed = failed + 1
END IF

REM --- Test 6: DpMul 21*3=63 ---
DpFromLong(a, 21)
DpFromLong(b, 3)
DpMul(r, a, b)
rv = DpToLong(r)
IF rv = 63 THEN
  PRINT "PASS: DpMul 21*3 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpMul expected 63, got"; rv
  failed = failed + 1
END IF

REM --- Test 7: DpDiv 21/3=7 ---
DpFromLong(a, 21)
DpFromLong(b, 3)
DpDiv(r, a, b)
rv = DpToLong(r)
IF rv = 7 THEN
  PRINT "PASS: DpDiv 21/3 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpDiv expected 7, got"; rv
  failed = failed + 1
END IF

REM --- Test 8: DpCmp greater ---
DpFromLong(a, 10)
DpFromLong(b, 5)
rv = DpCmp(a, b)
IF rv = 1 THEN
  PRINT "PASS: DpCmp 10>5 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpCmp 10>5 expected 1, got"; rv
  failed = failed + 1
END IF

REM --- Test 9: DpCmp less ---
DpFromLong(a, 5)
DpFromLong(b, 10)
rv = DpCmp(a, b)
IF rv = -1 THEN
  PRINT "PASS: DpCmp 5<10 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpCmp 5<10 expected -1, got"; rv
  failed = failed + 1
END IF

REM --- Test 10: DpCmp equal ---
DpFromLong(a, 7)
DpFromLong(b, 7)
rv = DpCmp(a, b)
IF rv = 0 THEN
  PRINT "PASS: DpCmp 7=7 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpCmp 7=7 expected 0, got"; rv
  failed = failed + 1
END IF

REM --- Test 11: DpAbs |-5| = 5 ---
DpFromLong(a, -5)
DpAbs(r, a)
rv = DpToLong(r)
IF rv = 5 THEN
  PRINT "PASS: DpAbs |-5| ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpAbs expected 5, got"; rv
  failed = failed + 1
END IF

REM --- Test 12: DpNeg -(7) = -7 ---
DpFromLong(a, 7)
DpNeg(r, a)
rv = DpToLong(r)
IF rv = -7 THEN
  PRINT "PASS: DpNeg -(7) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpNeg expected -7, got"; rv
  failed = failed + 1
END IF

REM --- Test 13: DpDiv non-integer result truncation (7/2=3 via DpToLong) ---
DpFromLong(a, 7)
DpFromLong(b, 2)
DpDiv(r, a, b)
rv = DpToLong(r)
IF rv = 3 THEN
  PRINT "PASS: DpDiv 7/2 truncated ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpDiv 7/2 truncated expected 3, got"; rv
  failed = failed + 1
END IF

REM --- Summary ---
PRINT ""
PRINT "Results:"; passed; "passed,"; failed; "failed"

DpClose

ASSERT failed = 0, "Some DP core tests failed"
