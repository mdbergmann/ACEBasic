REM Diagnostic: FIX, CINT, INT, MOD, PRINT float

REM FIX - truncate toward zero
PRINT "FIX(3.7) ="; FIX(3.7)
PRINT "FIX(3.2) ="; FIX(3.2)
PRINT "FIX(-3.7) ="; FIX(-3.7)
PRINT "FIX(-3.2) ="; FIX(-3.2)

REM CINT - round to nearest
PRINT "CINT(3.7) ="; CINT(3.7)
PRINT "CINT(3.2) ="; CINT(3.2)
PRINT "CINT(3.5) ="; CINT(3.5)
PRINT "CINT(-2.3) ="; CINT(-2.3)
PRINT "CINT(-2.7) ="; CINT(-2.7)

REM INT - floor
PRINT "INT(3.7) ="; INT(3.7)
PRINT "INT(-3.7) ="; INT(-3.7)

REM CLNG
PRINT "CLNG(100.7) ="; CLNG(100.7)

REM MOD
x! = 7.5
y! = 2.5
PRINT "FIX(7.5 MOD 2.5) ="; FIX(x! MOD y!)
x! = 10.0
y! = 3.0
PRINT "FIX(10.0 MOD 3.0) ="; FIX(x! MOD y!)

REM PRINT of floats (was crashing)
x! = 3.7
PRINT "x! = 3.7:"; x!
x! = -0.001234
PRINT "x! = -0.001234:"; x!
x! = 123456.7
PRINT "x! = 123456.7:"; x!
x! = 1.5e+10
PRINT "x! = 1.5e+10:"; x!

REM STR$ round-trip
PRINT "STR$(3.14) ="; STR$(3.14)
PRINT "VAL(STR$(3.14)) ="; VAL(STR$(3.14))

PRINT "DONE"
