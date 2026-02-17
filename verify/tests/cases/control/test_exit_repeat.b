REM test EXIT REPEAT
x% = 0
REPEAT
  x% = x% + 1
  IF x% = 3 THEN EXIT REPEAT
UNTIL x% = 100
ASSERT x% = 3, "EXIT REPEAT should break out of loop at x%=3"
