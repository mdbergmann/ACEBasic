REM test_tmpl.b - Template for submodule tests
REM
REM Copy this file into your submodule directory and rename it:
REM   cp test_tmpl.b mysubmod/test_something.b
REM
REM Then adapt the #using and #include lines, and add your test cases.

REM --- Module linkage (adjust path to your submodule) ---
REM #using ace:submods/mysubmod/mysubmod.o

REM --- Module header (adjust to your submodule) ---
REM #include <submods/mysubmod.h>

REM --- Skip directive (uncomment if test should be skipped) ---
REM $skip: reason why this test cannot run yet

REM --- Variables ---
LONGINT passed, failed

passed = 0
failed = 0

PRINT "=== My Submodule Test ==="

REM --- Test 1: Description ---
REM Replace with actual test logic
IF 1 = 1 THEN
  PRINT "PASS: basic sanity check"
  passed = passed + 1
ELSE
  PRINT "FAIL: basic sanity check"
  failed = failed + 1
END IF

REM --- Test 2: Using ASSERT directly ---
REM ASSERT is the simplest way to check a condition.
REM If it fails, the runner detects "ASSERT FAILED" in the output.
LONGINT result
result = 42
ASSERT result = 42, "expected 42"
passed = passed + 1

REM --- Add more tests here ---

REM --- Summary ---
PRINT ""
PRINT "Results:"; passed; "passed,"; failed; "failed"

ASSERT failed = 0, "Some tests failed"
