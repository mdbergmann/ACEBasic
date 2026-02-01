REM Test: SUB modifying a SHARED variable
REM A SUB can modify a shared variable and the main program sees the change

counter% = 5

SUB IncrementCounter
  SHARED counter%
  counter% = counter% + 1
END SUB

PRINT counter%
CALL IncrementCounter
PRINT counter%
CALL IncrementCounter
PRINT counter%
