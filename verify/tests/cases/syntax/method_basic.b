REM Test: METHOD definitions called via GENERIC dispatch
REM Also tests: typed return, member modification, EXIT METHOD,
REM             CLASS instance as SUB parameter,
REM             mixed param types (CLASS+STRING, CLASS+SINGLE, CLASS+ATOM+LONGINT)

CLASS Vec2
    LONGINT x
    LONGINT y
END CLASS

CLASS Box
    LONGINT w
    LONGINT h
END CLASS

REM -- Void METHOD that modifies a member
METHOD SetXY(Vec2 v, LONGINT nx, LONGINT ny)
    v->x = nx
    v->y = ny
END METHOD

REM -- Typed return METHOD
METHOD LONGINT GetX(Vec2 v)
    GetX = v->x
END METHOD

REM -- Method for Box returning LONGINT
METHOD LONGINT GetArea(Box b)
    GetArea = b->w * b->h
END METHOD

REM -- EXIT METHOD (early return)
METHOD LONGINT CheckVal(Vec2 v)
    IF v->x > 100 THEN
        CheckVal = -1
        EXIT METHOD
    END IF
    CheckVal = v->x
END METHOD

REM -- METHOD with CLASS + STRING param
METHOD LONGINT Rename(Vec2 v, STRING label$)
    IF label$ = "origin" THEN
        v->x = 0
        v->y = 0
        Rename = 1
    ELSE
        Rename = 0
    END IF
END METHOD

REM -- METHOD with CLASS + SINGLE param
METHOD SINGLE Offset(Vec2 v, SINGLE delta)
    Offset = v->x + delta
END METHOD

REM -- METHOD with CLASS + ATOM + LONGINT params
METHOD LONGINT Apply(Vec2 v, :set cmd, LONGINT amount)
    v->x = amount
    Apply = amount
END METHOD

METHOD LONGINT Apply(Vec2 v, :add cmd, LONGINT amount)
    v->x = v->x + amount
    Apply = v->x
END METHOD

REM -- GENERIC declarations
GENERIC METHOD SetXY(CLASS, LONGINT, LONGINT)
    ON Vec2
END GENERIC

GENERIC LONGINT METHOD GetX(CLASS)
    ON Vec2
END GENERIC

GENERIC LONGINT METHOD GetArea(CLASS)
    ON Box
END GENERIC

GENERIC LONGINT METHOD CheckVal(CLASS)
    ON Vec2
END GENERIC

GENERIC LONGINT METHOD Rename(CLASS, STRING)
    ON Vec2
END GENERIC

GENERIC SINGLE METHOD Offset(CLASS, SINGLE)
    ON Vec2
END GENERIC

GENERIC LONGINT METHOD Apply(CLASS, ATOM, LONGINT)
    ON Vec2, :set
    ON Vec2, :add
END GENERIC

REM -- Test: call void method, verify member modification
DECLARE CLASS Vec2 v1
v1->x = 0
v1->y = 0
SetXY(v1, 42, 99)
ASSERT v1->x = 42, "SetXY should set x to 42"
ASSERT v1->y = 99, "SetXY should set y to 99"

REM -- Test: typed return value
LONGINT gx
gx = GetX(v1)
ASSERT gx = 42, "GetX should return 42"

REM -- Test: different CLASS method
DECLARE CLASS Box b1
b1->w = 5
b1->h = 3
LONGINT ar
ar = GetArea(b1)
ASSERT ar = 15, "GetArea should return 15"

REM -- Test: EXIT METHOD (early return)
LONGINT cv
v1->x = 50
cv = CheckVal(v1)
ASSERT cv = 50, "CheckVal should return 50 for x<=100"
v1->x = 200
cv = CheckVal(v1)
ASSERT cv = -1, "CheckVal should return -1 for x>100"

REM -- Test: CLASS instance as SUB parameter (struct-typed param sugar)
SUB PrintVec(Vec2 p)
    ASSERT p->x = 7, "SUB param x should be 7"
    ASSERT p->y = 8, "SUB param y should be 8"
END SUB

DECLARE CLASS Vec2 v2
v2->x = 7
v2->y = 8
PrintVec(v2)

REM -- Test: CLASS + STRING param
LONGINT rn
v1->x = 55
v1->y = 66
rn = Rename(v1, "origin")
ASSERT rn = 1, "Rename origin should return 1"
ASSERT v1->x = 0, "Rename origin should zero x"
ASSERT v1->y = 0, "Rename origin should zero y"
rn = Rename(v1, "other")
ASSERT rn = 0, "Rename other should return 0"

REM -- Test: CLASS + SINGLE param
v1->x = 10
SINGLE ofs
ofs = Offset(v1, 2.5)
ASSERT ofs = 12.5, "Offset(10, 2.5) should be 12.5"

REM -- Test: CLASS + ATOM + LONGINT params
v1->x = 100
LONGINT ap
ap = Apply(v1, :set, 50)
ASSERT ap = 50, "Apply :set 50 should return 50"
ASSERT v1->x = 50, "Apply :set should set x to 50"
ap = Apply(v1, :add, 25)
ASSERT ap = 75, "Apply :add 25 should return 75"
ASSERT v1->x = 75, "Apply :add should add to x"

PRINT "method_basic: ALL PASSED"
