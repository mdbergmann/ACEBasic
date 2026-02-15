REM Test: SUB/function call in single-line IF THEN
REM This tests that identifiers followed by '(' in THEN clauses
REM are correctly handled as function/sub calls, not array assignments.

DECLARE SUB SetResult(SHORTINT v)

result% = 0
extra% = 0

REM SUB call in THEN clause (was triggering error 71)
IF 1 = 1 THEN SetResult(42)
ASSERT result% = 42, "SUB call in IF THEN should work"

REM SUB call in THEN clause with false condition
IF 1 = 0 THEN SetResult(99)
ASSERT result% = 42, "False IF should not call SUB"

REM SUB call in THEN clause with ELSE
result% = 0
IF 1 = 1 THEN SetResult(10) ELSE SetResult(20)
ASSERT result% = 10, "True IF THEN ELSE should call THEN sub"

result% = 0
IF 1 = 0 THEN SetResult(10) ELSE SetResult(20)
ASSERT result% = 20, "False IF THEN ELSE should call ELSE sub"

REM Original patterns that must still work
result% = 0
IF 1 = 1 THEN result% = 77
ASSERT result% = 77, "IF THEN assignment should still work"

SUB SetResult(SHORTINT v)
  SHARED result%
  result% = v
END SUB
