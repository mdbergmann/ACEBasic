' bind_zero_args.b - BIND with zero bound arguments
' Callbacks must be INVOKABLE SUBs (return in d0)

DECLARE SUB LONGINT Double(LONGINT x) INVOKABLE
DECLARE SUB LONGINT ApplyFunc(ADDRESS func, LONGINT value) INVOKABLE

' Test 1: BIND with zero args, direct INVOKE
closure& = BIND(@Double)
result& = INVOKE closure&(21)
ASSERT result& = 42, "Direct INVOKE of zero-arg BIND should work"

' Test 2: Pass closure as parameter to another SUB
result2& = ApplyFunc(closure&, 10)
ASSERT result2& = 20, "INVOKE through parameter should work"

PRINT "bind_zero_args: PASSED"

SUB LONGINT Double(LONGINT x) INVOKABLE
  Double = x * 2
END SUB

SUB LONGINT ApplyFunc(ADDRESS func, LONGINT value) INVOKABLE
  LONGINT res
  res = INVOKE func(value)
  ApplyFunc = res
END SUB
