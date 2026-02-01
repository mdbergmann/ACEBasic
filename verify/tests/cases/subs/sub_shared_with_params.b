REM Test: SUB with both parameters and SHARED variables
REM A SUB can use both passed parameters and shared variables

multiplier% = 10

SUB Compute(n%)
  SHARED multiplier%
  result% = n% * multiplier%
  PRINT result%
END SUB

CALL Compute(5)
CALL Compute(7)
