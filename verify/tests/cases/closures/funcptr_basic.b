REM Test: Basic INVOKE with no parameters
REM Calls a SUB through a function pointer

DECLARE SUB Hello
funcPtr& = @Hello
INVOKE funcPtr&

SUB Hello
  PRINT "hello from invoke"
END SUB
