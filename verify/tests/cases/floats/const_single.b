REM Test: CONST SINGLE precision values
CONST pi! = 3.14159
CONST half! = 0.5
CONST ten! = 10.0
CONST neg! = -2.5

REM Test positive constants
ASSERT pi! > 3.14, "pi should be > 3.14"
ASSERT pi! < 3.15, "pi should be < 3.15"
ASSERT half! > 0.49, "half should be > 0.49"
ASSERT half! < 0.51, "half should be < 0.51"
ASSERT ten! > 9.99, "ten should be > 9.99"
ASSERT ten! < 10.01, "ten should be < 10.01"

REM Test negative constant
ASSERT neg! < -2.49, "neg should be < -2.49"
ASSERT neg! > -2.51, "neg should be > -2.51"

REM Test expressions with constants
result! = pi! * half!
ASSERT result! > 1.57, "pi*half should be > 1.57"
ASSERT result! < 1.58, "pi*half should be < 1.58"

result! = ten! + neg!
ASSERT result! > 7.49, "ten+neg should be > 7.49"
ASSERT result! < 7.51, "ten+neg should be < 7.51"

REM Test constants inside a SUB
SUB TestConsts
  r! = pi! * half!
  ASSERT r! > 1.57, "SUB: pi*half should be > 1.57"
  ASSERT r! < 1.58, "SUB: pi*half should be < 1.58"
  ASSERT neg! < -2.49, "SUB: neg should be < -2.49"
  ASSERT neg! > -2.51, "SUB: neg should be > -2.51"
END SUB

TestConsts
