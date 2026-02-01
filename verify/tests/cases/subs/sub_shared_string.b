REM Test: SUB with SHARED string variable
REM A SUB can access a string variable via SHARED

msg$ = "Hello from SHARED"

SUB PrintMessage
  SHARED msg$
  PRINT msg$
END SUB

CALL PrintMessage
