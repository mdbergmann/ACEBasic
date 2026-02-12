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
