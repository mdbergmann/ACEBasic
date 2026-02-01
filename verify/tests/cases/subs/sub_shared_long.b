REM Test: SUB with SHARED long integer variable
REM A SUB can access a long integer variable via SHARED

value& = 100000

SUB PrintLong
  SHARED value&
  PRINT value&
END SUB

CALL PrintLong
