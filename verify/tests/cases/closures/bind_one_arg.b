' bind_one_arg.b - BIND one argument, INVOKE with remaining
' Tests basic closure functionality

DECLARE SUB LONGINT AddN(LONGINT n, LONGINT x)

SUB LONGINT AddN(LONGINT n, LONGINT x)
  AddN = n + x
END SUB

adder& = BIND(@AddN, 5)
result& = INVOKE adder&(10)
PRINT result&
