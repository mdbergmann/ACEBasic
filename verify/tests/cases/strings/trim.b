REM Test: TRIM$, LTRIM$, RTRIM$ functions

REM TRIM$ - remove leading and trailing whitespace
a$ = TRIM$("  hello  ")
ASSERT a$ = "hello", "TRIM$ should remove both sides"

REM LTRIM$ - remove leading whitespace only
b$ = LTRIM$("  hello  ")
ASSERT b$ = "hello  ", "LTRIM$ should remove leading only"

REM RTRIM$ - remove trailing whitespace only
c$ = RTRIM$("  hello  ")
ASSERT c$ = "  hello", "RTRIM$ should remove trailing only"

REM Empty string
d$ = TRIM$("")
ASSERT d$ = "", "TRIM$ should handle empty string"

REM No whitespace
e$ = TRIM$("nowhitespace")
ASSERT e$ = "nowhitespace", "TRIM$ no-op on clean string"

REM All whitespace
f$ = TRIM$("   ")
ASSERT f$ = "", "TRIM$ all whitespace becomes empty"

REM Tab characters
g$ = TRIM$(CHR$(9)+"tabbed"+CHR$(9))
ASSERT g$ = "tabbed", "TRIM$ should remove tabs too"

REM LTRIM$ - empty string
h$ = LTRIM$("")
ASSERT h$ = "", "LTRIM$ empty string"

REM LTRIM$ - all whitespace
i$ = LTRIM$("   ")
ASSERT i$ = "", "LTRIM$ all whitespace"

REM LTRIM$ - tab chars
j$ = LTRIM$(CHR$(9)+CHR$(9)+"hello")
ASSERT j$ = "hello", "LTRIM$ tabs"

REM RTRIM$ - empty string
k$ = RTRIM$("")
ASSERT k$ = "", "RTRIM$ empty string"

REM RTRIM$ - all whitespace
l$ = RTRIM$("   ")
ASSERT l$ = "", "RTRIM$ all whitespace"

REM RTRIM$ - tab chars
m$ = RTRIM$("hello"+CHR$(9)+CHR$(9))
ASSERT m$ = "hello", "RTRIM$ tabs"

REM Mixed spaces and tabs
n$ = TRIM$(CHR$(9)+" mixed "+CHR$(9))
ASSERT n$ = "mixed", "TRIM$ mixed spaces and tabs"
