REM Test: UCASE$ and LCASE$ together - round trip conversions
REM Round trip: lowercase -> uppercase -> lowercase
a$ = "hello world"
b$ = UCASE$(a$)
c$ = LCASE$(b$)
ASSERT c$ = a$, "Round trip should preserve original"

REM Sequential calls (instead of nested)
d$ = UCASE$("MiXeD")
d$ = LCASE$(d$)
ASSERT d$ = "mixed", "Sequential UCASE then LCASE should work"

e$ = LCASE$("MiXeD")
e$ = UCASE$(e$)
ASSERT e$ = "MIXED", "Sequential LCASE then UCASE should work"

REM Variable conversion
text$ = "Test String"
lower$ = LCASE$(text$)
upper$ = UCASE$(text$)
ASSERT lower$ = "test string", "LCASE$ on variable should work"
ASSERT upper$ = "TEST STRING", "UCASE$ on variable should work"
