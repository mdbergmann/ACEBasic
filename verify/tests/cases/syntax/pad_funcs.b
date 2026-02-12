REM Test: LPAD$, RPAD$ functions

REM LPAD$ - basic
a$ = LPAD$("hi", 5, " ")
ASSERT a$ = "   hi", "LPAD$ basic"

REM LPAD$ - already long enough
b$ = LPAD$("hello", 3, " ")
ASSERT b$ = "hello", "LPAD$ no-op when long enough"

REM LPAD$ - zero padding
c$ = LPAD$("42", 5, "0")
ASSERT c$ = "00042", "LPAD$ zero fill"

REM LPAD$ - exact width
d$ = LPAD$("abc", 3, "x")
ASSERT d$ = "abc", "LPAD$ exact width"

REM RPAD$ - basic
e$ = RPAD$("hi", 5, " ")
ASSERT e$ = "hi   ", "RPAD$ basic"

REM RPAD$ - already long enough
f$ = RPAD$("hello", 3, " ")
ASSERT f$ = "hello", "RPAD$ no-op when long enough"

REM RPAD$ - dot padding
g$ = RPAD$("test", 8, ".")
ASSERT g$ = "test....", "RPAD$ dot fill"

REM RPAD$ - exact width
h$ = RPAD$("abc", 3, "x")
ASSERT h$ = "abc", "RPAD$ exact width"
