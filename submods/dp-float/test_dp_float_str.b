REM test_dp_float_str.b - Phase 3: string conversion tests
REM #using ace:submods/dp-float/dp-float.o

#include <submods/dp-float.h>

LONGINT ok, rv
ADDRESS a, b, r
STRING s$ SIZE 64
LONGINT passed, failed

passed = 0
failed = 0

PRINT "=== DP Submodule Phase 3 Test ==="

ok = DpOpen
IF ok = 0 THEN
  PRINT "FAIL: DpOpen"
  STOP
END IF

a = DpNew : b = DpNew : r = DpNew

REM --- Test 1: DpFromStr integer ---
DpFromStr(a, "42")
rv = DpToLong(a)
IF rv = 42 THEN
  PRINT "PASS: DpFromStr(42) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFromStr(42) expected 42, got"; rv
  failed = failed + 1
END IF

REM --- Test 2: DpFromStr negative ---
DpFromStr(a, "-17")
rv = DpToLong(a)
IF rv = -17 THEN
  PRINT "PASS: DpFromStr(-17) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFromStr(-17) expected -17, got"; rv
  failed = failed + 1
END IF

REM --- Test 3: DpFromStr with decimal (12.5 -> 12 via DpToLong, or check via mul) ---
DpFromStr(a, "12.5")
DpFromLong(b, 2)
DpMul(r, a, b)
rv = DpToLong(r)
IF rv = 25 THEN
  PRINT "PASS: DpFromStr(12.5)*2 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFromStr(12.5)*2 expected 25, got"; rv
  failed = failed + 1
END IF

REM --- Test 4: DpFromStr leading dot ---
DpFromStr(a, ".25")
DpFromLong(b, 4)
DpMul(r, a, b)
rv = DpToLong(r)
IF rv = 1 THEN
  PRINT "PASS: DpFromStr(.25)*4 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFromStr(.25)*4 expected 1, got"; rv
  failed = failed + 1
END IF

REM --- Test 5: DpFromStr with exponent ---
DpFromStr(a, "1.5e+2")
rv = DpToLong(a)
IF rv = 150 THEN
  PRINT "PASS: DpFromStr(1.5e+2) ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFromStr(1.5e+2) expected 150, got"; rv
  failed = failed + 1
END IF

REM --- Test 6: DpFromStr negative exponent ---
DpFromStr(a, "5e-1")
DpFromLong(b, 10)
DpMul(r, a, b)
rv = DpToLong(r)
IF rv = 5 THEN
  PRINT "PASS: DpFromStr(5e-1)*10 ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFromStr(5e-1)*10 expected 5, got"; rv
  failed = failed + 1
END IF

REM --- Test 7: DpFromStr with leading whitespace ---
DpFromStr(a, "  100")
rv = DpToLong(a)
IF rv = 100 THEN
  PRINT "PASS: DpFromStr('  100') ="; rv
  passed = passed + 1
ELSE
  PRINT "FAIL: DpFromStr('  100') expected 100, got"; rv
  failed = failed + 1
END IF

REM --- Test 8: DpToStr$ of 0 ---
DpFromLong(a, 0)
s$ = DpToStr$(a)
IF s$ = "0" THEN
  PRINT "PASS: DpToStr$(0) = "; s$
  passed = passed + 1
ELSE
  PRINT "FAIL: DpToStr$(0) expected '0', got '"; s$; "'"
  failed = failed + 1
END IF

REM --- Test 9: DpToStr$ of positive integer ---
DpFromLong(a, 42)
s$ = DpToStr$(a)
IF s$ = "42" THEN
  PRINT "PASS: DpToStr$(42) = "; s$
  passed = passed + 1
ELSE
  PRINT "FAIL: DpToStr$(42) expected '42', got '"; s$; "'"
  failed = failed + 1
END IF

REM --- Test 10: DpToStr$ of negative integer ---
DpFromLong(a, -7)
s$ = DpToStr$(a)
IF s$ = "-7" THEN
  PRINT "PASS: DpToStr$(-7) = "; s$
  passed = passed + 1
ELSE
  PRINT "FAIL: DpToStr$(-7) expected '-7', got '"; s$; "'"
  failed = failed + 1
END IF

REM --- Test 11: DpToStr$ of 12.5 ---
DpFromStr(a, "12.5")
s$ = DpToStr$(a)
IF s$ = "12.5" THEN
  PRINT "PASS: DpToStr$(12.5) = "; s$
  passed = passed + 1
ELSE
  PRINT "FAIL: DpToStr$(12.5) expected '12.5', got '"; s$; "'"
  failed = failed + 1
END IF

REM --- Test 12: DpToStr$ of 1000 ---
DpFromLong(a, 1000)
s$ = DpToStr$(a)
IF s$ = "1000" THEN
  PRINT "PASS: DpToStr$(1000) = "; s$
  passed = passed + 1
ELSE
  PRINT "FAIL: DpToStr$(1000) expected '1000', got '"; s$; "'"
  failed = failed + 1
END IF

REM --- Test 13: DpToStr$ of small decimal 0.25 ---
DpFromStr(a, "0.25")
s$ = DpToStr$(a)
IF s$ = "0.25" THEN
  PRINT "PASS: DpToStr$(0.25) = "; s$
  passed = passed + 1
ELSE
  PRINT "FAIL: DpToStr$(0.25) expected '0.25', got '"; s$; "'"
  failed = failed + 1
END IF

REM --- Test 14: DpFromStr/DpToStr$ roundtrip ---
DpFromStr(a, "123.456")
s$ = DpToStr$(a)
PRINT "INFO: DpToStr$(123.456) = "; s$
DpFromStr(b, s$)
rv = DpCmp(a, b)
IF rv = 0 THEN
  PRINT "PASS: roundtrip 123.456"
  passed = passed + 1
ELSE
  PRINT "FAIL: roundtrip 123.456, cmp="; rv
  failed = failed + 1
END IF

REM --- Test 15: Large number -> scientific notation ---
DpFromStr(a, "1.5e+20")
s$ = DpToStr$(a)
PRINT "INFO: DpToStr$(1.5e+20) = "; s$
' Roundtrip check
DpFromStr(b, s$)
DpFromStr(r, "1.5e+20")
rv = DpCmp(b, r)
IF rv = 0 THEN
  PRINT "PASS: roundtrip 1.5e+20"
  passed = passed + 1
ELSE
  PRINT "FAIL: roundtrip 1.5e+20, cmp="; rv
  failed = failed + 1
END IF

REM --- Summary ---
PRINT ""
PRINT "Results:"; passed; "passed,"; failed; "failed"

DpClose

ASSERT failed = 0, "Some DP string tests failed"
