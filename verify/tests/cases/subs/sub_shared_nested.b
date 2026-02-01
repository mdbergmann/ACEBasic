REM Test: Nested SUB calls with SHARED variable
REM Multiple SUBs can share the same variable

total& = 0

SUB AddTen
  SHARED total&
  total& = total& + 10
END SUB

SUB AddTwenty
  SHARED total&
  total& = total& + 20
END SUB

SUB PrintTotal
  SHARED total&
  PRINT total&
END SUB

CALL AddTen
CALL AddTwenty
CALL PrintTotal
