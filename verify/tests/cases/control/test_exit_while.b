REM test EXIT WHILE
x% = 0
WHILE -1
  x% = x% + 1
  IF x% = 5 THEN EXIT WHILE
WEND
ASSERT x% = 5, "EXIT WHILE should break out of loop at x%=5"
