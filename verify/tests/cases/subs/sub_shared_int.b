REM Test: SUB with SHARED integer variable
REM A SUB can access a main program variable via SHARED

x% = 42
CALL PrintValue

SUB PrintValue
  SHARED x%
  PRINT x%
END SUB
