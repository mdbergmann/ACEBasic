REM Test: SUB with multiple SHARED variables
REM A SUB can share multiple variables at once

a% = 10
b% = 20
c& = 30
CALL PrintAll

SUB PrintAll
  SHARED a%, b%, c&
  PRINT a%
  PRINT b%
  PRINT c&
END SUB
