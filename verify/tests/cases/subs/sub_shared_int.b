REM Test: SUB with SHARED integer variable
REM A SUB can access a main program variable via SHARED

x% = 42

SUB PrintValue
  SHARED x%
  PRINT x%
END SUB

CALL PrintValue
