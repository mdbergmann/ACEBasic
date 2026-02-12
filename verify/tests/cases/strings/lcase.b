REM Test: LCASE$ function - convert string to lowercase
REM Basic lowercase conversion
a$ = LCASE$("HELLO")
ASSERT a$ = "hello", "LCASE$ should convert HELLO to hello"

REM Mixed case input
b$ = LCASE$("Hello World")
ASSERT b$ = "hello world", "LCASE$ should convert mixed case"

REM Already lowercase - should remain unchanged
c$ = LCASE$("already lower")
ASSERT c$ = "already lower", "LCASE$ should preserve lowercase"

REM Numbers and symbols - should remain unchanged
d$ = LCASE$("ABC123!@#")
ASSERT d$ = "abc123!@#", "LCASE$ should only convert letters"

REM Empty string
e$ = LCASE$("")
ASSERT e$ = "", "LCASE$ should handle empty string"

REM Single character
f$ = LCASE$("X")
ASSERT f$ = "x", "LCASE$ should convert single char"
