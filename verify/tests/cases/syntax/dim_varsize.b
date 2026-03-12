REM Test: DIM with variable-sized arrays

REM --- Test 1: Single variable dimension ---
SHORTINT n%
n% = 5
DIM SHORTINT arr(n%)
arr(0) = 10
arr(5) = 60
ASSERT arr(0) = 10, "arr(0) should be 10"
ASSERT arr(5) = 60, "arr(5) should be 60"

REM --- Test 2: Multi-dimensional variable ---
SHORTINT rows%
SHORTINT cols%
rows% = 2
cols% = 3
DIM SHORTINT grid(rows%, cols%)
grid(0, 0) = 1
PRINT "wrote grid(0,0) = 1"
SHORTINT v%
v% = grid(0, 0)
PRINT "read grid(0,0) ="; v%
grid(1, 2) = 42
v% = grid(1, 2)
PRINT "read grid(1,2) ="; v%
ASSERT grid(0, 0) = 1, "grid(0,0) should be 1"
ASSERT grid(1, 2) = 42, "grid(1,2) should be 42"

REM --- Test 3: String array with variable count ---
SHORTINT sc%
sc% = 3
DIM strs$(sc%) SIZE 20
strs$(0) = "hello"
strs$(3) = "done"
ASSERT strs$(0) = "hello", "strs$(0) should be hello"
ASSERT strs$(3) = "done", "strs$(3) should be done"

REM --- Test 4: LONGINT array with variable size ---
SHORTINT sz%
sz% = 4
DIM LONGINT big&(sz%)
big&(0) = 100000
big&(4) = 999999
ASSERT big&(0) = 100000, "big(0) should be 100000"
ASSERT big&(4) = 999999, "big(4) should be 999999"

REM --- Test 5: Variable-sized array inside SUB ---
SUB TestSub(SHORTINT cnt%)
  DIM SHORTINT nums(cnt%)
  SHORTINT j%
  FOR j% = 0 TO cnt%
    nums(j%) = j% * 10
  NEXT
  ASSERT nums(0) = 0, "nums(0) should be 0"
  ASSERT nums(cnt%) = cnt% * 10, "nums(cnt) should match"
END SUB
TestSub(5)

PRINT "All dim_varsize tests passed."
