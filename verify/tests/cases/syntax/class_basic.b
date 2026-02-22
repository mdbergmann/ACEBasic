REM Test: CLASS definition, instance creation, member access, type ID

CLASS Disc
    SINGLE radius
END CLASS

DECLARE CLASS Disc c
c->radius = 5.0

REM -- Test member access --
ASSERT c->radius = 5.0, "radius should be 5.0"

REM -- Test descriptor pointer at offset 0 (deref to get hash) --
ASSERT PEEKL(PEEKL(c)) = -376157364, "descriptor hash should be FNV-1a of DISC"

PRINT "class_basic: ALL PASSED"
