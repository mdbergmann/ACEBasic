REM test_tmpl.b - Template for submodule tests
REM
REM Copy this file into your submodule directory and rename it:
REM   cp test_tmpl.b mysubmod/test_something.b
REM
REM Then adapt the #using and #include lines, and add your test cases.

REM --- Module linkage (adjust path to your submodule) ---
REM #using ace:submods/mysubmod/mysubmod.o
REM #using ace:submods/testkit/testkit.o

REM --- Module header (adjust to your submodule) ---
REM #include <submods/mysubmod.h>
#include <submods/testkit.h>

REM --- Skip directive (uncomment if test should be skipped) ---
REM $skip: reason why this test cannot run yet

REM --- Variables ---

PRINT "=== My Submodule Test ==="

TkInit

REM --- Test 1: Description ---
REM Replace with actual test logic
TkAssertTrue(1 = 1, "basic sanity check")

REM --- Test 2: Equality check ---
LONGINT result
result = 42
TkAssertEq&(result, 42, "expected 42")

REM --- Add more tests here ---

REM --- Summary ---
TkSummary
