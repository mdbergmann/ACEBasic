REM Test: FMT$ function

REM Basic string interpolation
a$ = FMT$("hello %s", "world")
ASSERT a$ = "hello world", "FMT$ string"

REM Integer formatting
b$ = FMT$("%d items", 42)
ASSERT b$ = "42 items", "FMT$ integer"

REM Multiple args
c$ = FMT$("%s=%d", "x", 10)
ASSERT c$ = "x=10", "FMT$ multi args"

REM Hex formatting (platform _sprintf gives uppercase)
d$ = FMT$("hex: %x", 255)
ASSERT d$ = "hex: FF", "FMT$ hex"

REM Literal percent
e$ = FMT$("100%%")
ASSERT e$ = "100%", "FMT$ literal percent"

REM Character formatting
f$ = FMT$("char: %c", 65)
ASSERT f$ = "char: A", "FMT$ char"

REM No args - just format string
g$ = FMT$("plain text")
ASSERT g$ = "plain text", "FMT$ no args"

REM Zero-padded hex
h$ = FMT$("%08x", 255)
ASSERT h$ = "000000FF", "FMT$ zero-padded hex"
