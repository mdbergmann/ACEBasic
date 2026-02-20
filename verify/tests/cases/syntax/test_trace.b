REM -- test_trace.b: SUB tracing test --
REM Compile with: bas -t test_trace
REM Trace output goes to T:ace_trace.log

OPTION t+

DECLARE SUB LONGINT Add(LONGINT a, LONGINT b)
DECLARE SUB Greet(STRING who$)
DECLARE SUB LONGINT Factorial(LONGINT n)
DECLARE SUB NoParams

LONGINT result

result = Add(3, 5)
PRINT "Add ="; result

Greet("World")

result = Factorial(4)
PRINT "Fact ="; result

NoParams

PRINT "Done."

END

SUB LONGINT Add(LONGINT a, LONGINT b)
  Add = a + b
END SUB

SUB Greet(STRING who$)
  PRINT "Hello, "; who$; "!"
END SUB

SUB LONGINT Factorial(LONGINT n)
  IF n <= 1 THEN
    Factorial = 1
  ELSE
    Factorial = n * Factorial(n - 1)
  END IF
END SUB

SUB NoParams
  PRINT "No params"
END SUB
