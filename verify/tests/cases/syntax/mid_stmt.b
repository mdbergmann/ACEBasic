REM Test: MID$ statement form

REM Basic replacement
a$ = "Hello World"
MID$(a$, 7, 5) = "BASIC"
ASSERT a$ = "Hello BASIC", "MID$ basic replace"

REM Replace single char
b$ = "cat"
MID$(b$, 1, 1) = "b"
ASSERT b$ = "bat", "MID$ single char"

REM Replace at end
c$ = "Hello!"
MID$(c$, 6, 1) = "."
ASSERT c$ = "Hello.", "MID$ at end"

REM RHS shorter than len - only copies rhs length
d$ = "XXXXXXXX"
MID$(d$, 3, 5) = "ab"
ASSERT d$ = "XXabXXXX", "MID$ rhs shorter"

REM No length specified - uses rhs length
e$ = "Hello World"
MID$(e$, 7) = "BASIC"
ASSERT e$ = "Hello BASIC", "MID$ no len"
