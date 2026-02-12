REM Test: REPLACE$, REVERSE$, REPEAT$ functions

REM REVERSE$ - basic
a$ = REVERSE$("hello")
ASSERT a$ = "olleh", "REVERSE$ basic"

REM REVERSE$ - empty string
b$ = REVERSE$("")
ASSERT b$ = "", "REVERSE$ empty"

REM REVERSE$ - single char
c$ = REVERSE$("x")
ASSERT c$ = "x", "REVERSE$ single"

REM REVERSE$ - palindrome
d$ = REVERSE$("abcba")
ASSERT d$ = "abcba", "REVERSE$ palindrome"

REM REPEAT$ - basic
e$ = REPEAT$("ab", 3)
ASSERT e$ = "ababab", "REPEAT$ 3 times"

REM REPEAT$ - zero count
f$ = REPEAT$("hi", 0)
ASSERT f$ = "", "REPEAT$ zero"

REM REPEAT$ - one count
g$ = REPEAT$("hi", 1)
ASSERT g$ = "hi", "REPEAT$ once"

REM REPLACE$ - basic
h$ = REPLACE$("hello world", "world", "BASIC")
ASSERT h$ = "hello BASIC", "REPLACE$ basic"

REM REPLACE$ - multiple occurrences
i$ = REPLACE$("aXbXc", "X", "Y")
ASSERT i$ = "aYbYc", "REPLACE$ multiple"

REM REPLACE$ - not found
j$ = REPLACE$("hello", "xyz", "abc")
ASSERT j$ = "hello", "REPLACE$ not found"

REM REPLACE$ - empty replacement (delete)
k$ = REPLACE$("hello world", " world", "")
ASSERT k$ = "hello", "REPLACE$ delete"

REM REPLACE$ - longer replacement
l$ = REPLACE$("ab", "a", "XY")
ASSERT l$ = "XYb", "REPLACE$ longer repl"
