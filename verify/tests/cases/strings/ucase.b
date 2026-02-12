REM Test: UCASE$ function - convert string to uppercase
REM Basic uppercase conversion
a$ = UCASE$("hello")
ASSERT a$ = "HELLO", "UCASE$ should convert hello to HELLO"

REM Mixed case input
b$ = UCASE$("Hello World")
ASSERT b$ = "HELLO WORLD", "UCASE$ should convert mixed case"

REM Already uppercase - should remain unchanged
c$ = UCASE$("ALREADY UPPER")
ASSERT c$ = "ALREADY UPPER", "UCASE$ should preserve uppercase"

REM Numbers and symbols - should remain unchanged
d$ = UCASE$("abc123!@#")
ASSERT d$ = "ABC123!@#", "UCASE$ should only convert letters"

REM Empty string
e$ = UCASE$("")
ASSERT e$ = "", "UCASE$ should handle empty string"

REM Single character
f$ = UCASE$("x")
ASSERT f$ = "X", "UCASE$ should convert single char"
