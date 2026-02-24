REM Test: colon as statement separator

REM --- Basic colon separator ---
LONGINT x
x=1:x=x+1
ASSERT x = 2, "colon separator basic"

REM --- Multiple separators on one line ---
LONGINT a, b, c
a=10:b=20:c=a+b
ASSERT c = 30, "multiple colon separators"

REM --- Colon after variable with no spaces ---
LONGINT v
v=5:ASSERT v=5, "colon after assignment no spaces"

REM --- Colon separator with atom on same line ---
ATOM st
st=#:ready:ASSERT st=#:ready, "colon sep with atom literal"

REM --- Colon separator between atom assignments ---
ATOM p, q
p=#:ok:q=#:fail
ASSERT p=#:ok, "first atom after colon sep"
ASSERT q=#:fail, "second atom after colon sep"

REM --- Colon in IF..THEN single-line ---
LONGINT r
r=0
IF 1 THEN r=1:r=r+1
ASSERT r = 2, "colon in single-line IF"

PRINT "colon_sep: ALL PASSED"
