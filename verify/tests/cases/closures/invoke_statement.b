' invoke_statement.b - Test INVOKE as statement with runtime CLSR detection
' Tests that INVOKE works as a statement (ignoring return value)
' when the closure type is not known at compile time (ADDRESS parameter)

LONGINT counter

DECLARE SUB LONGINT Increment(LONGINT n) INVOKABLE
DECLARE SUB CallIt(ADDRESS cb, LONGINT num)

counter = 0

' Create closure and pass as ADDRESS - requires runtime CLSR detection
cb& = BIND(@Increment)
CallIt(cb&, 5)
ASSERT counter = 5, "Counter should be 5 after first call"

CallIt(cb&, 3)
ASSERT counter = 8, "Counter should be 8 after second call"

PRINT "invoke_statement: PASSED"

SUB LONGINT Increment(LONGINT n) INVOKABLE
  SHARED counter
  counter = counter + n
  Increment = counter
END SUB

SUB CallIt(ADDRESS cb, LONGINT num)
  ' INVOKE as statement - return value ignored
  ' cb is ADDRESS so compiler doesn't know it's a CLSR at compile time
  INVOKE cb(num)
END SUB
