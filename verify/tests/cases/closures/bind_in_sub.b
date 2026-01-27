' bind_in_sub.b - Create closure inside a SUB, return it, invoke from main
' Tests value capture from SUB scope

DECLARE SUB LONGINT AddN(LONGINT n, LONGINT x)
DECLARE SUB LONGINT MakeAdder(LONGINT n)

SUB LONGINT AddN(LONGINT n, LONGINT x)
  AddN = n + x
END SUB

SUB LONGINT MakeAdder(LONGINT n)
  MakeAdder = BIND(@AddN, n)
END SUB

add5& = MakeAdder(5)
result& = INVOKE add5&(10)
PRINT result&
