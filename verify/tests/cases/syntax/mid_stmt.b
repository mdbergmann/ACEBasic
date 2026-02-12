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

REM Replace at pos 1 (start of string)
f$ = "XXXXX"
MID$(f$, 1, 3) = "abc"
ASSERT f$ = "abcXX", "MID$ at pos 1"

REM RHS longer than remaining room - capped
g$ = "Hi!"
MID$(g$, 2) = "LONGSTRING"
ASSERT g$ = "HLO", "MID$ rhs capped at room"

REM Empty rhs - no change
h$ = "hello"
MID$(h$, 2, 3) = ""
ASSERT h$ = "hello", "MID$ empty rhs"

REM Pos beyond string - no change
i$ = "abc"
MID$(i$, 10, 1) = "X"
ASSERT i$ = "abc", "MID$ pos beyond end"
