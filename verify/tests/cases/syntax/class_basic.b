REM Test: CLASS definition, instance creation, member access, type ID

CLASS Disc
    SINGLE radius
END CLASS

DECLARE CLASS Disc c
c->radius = 5.0

REM -- Test member access --
ASSERT c->radius = 5.0, "radius should be 5.0"

REM -- Test type ID at offset 0 (FNV-1a hash of "DISC") --
ASSERT PEEKL(c) = -376157364, "type ID should be FNV-1a hash of DISC"

PRINT "class_basic: ALL PASSED"
