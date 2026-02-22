REM Test: GENERIC dispatch - void, LONGINT return, SINGLE return, mixed params
REM Consolidates: generic_basic, generic_return, generic_single_return,
REM               generic_mixed_params

CLASS Disc
    LONGINT tag
    SINGLE radius
END CLASS

CLASS Rect
    LONGINT tag
    SINGLE w
    SINGLE h
END CLASS

REM -- Void dispatch: verify via member side-effect
METHOD Mark(Disc c)
    c->tag = 1
END METHOD

METHOD Mark(Rect r)
    r->tag = 2
END METHOD

GENERIC METHOD Mark(CLASS)
    ON Disc
    ON Rect
END GENERIC

REM -- LONGINT return dispatch
METHOD LONGINT GetCode(Disc c)
    GetCode = 42
END METHOD

METHOD LONGINT GetCode(Rect r)
    GetCode = 99
END METHOD

GENERIC LONGINT METHOD GetCode(CLASS)
    ON Disc
    ON Rect
END GENERIC

REM -- SINGLE return dispatch
METHOD SINGLE CalcArea(Disc c)
    CalcArea = c->radius * c->radius
END METHOD

METHOD SINGLE CalcArea(Rect r)
    CalcArea = r->w * r->h
END METHOD

GENERIC SINGLE METHOD CalcArea(CLASS)
    ON Disc
    ON Rect
END GENERIC

REM -- Mixed dispatched (CLASS) + non-dispatched (LONGINT) params
METHOD LONGINT Scale(Disc c, LONGINT factor)
    Scale = 100 + factor
END METHOD

METHOD LONGINT Scale(Rect r, LONGINT factor)
    Scale = 200 + factor
END METHOD

GENERIC LONGINT METHOD Scale(CLASS, LONGINT)
    ON Disc
    ON Rect
END GENERIC

REM ---- Tests ----

DECLARE CLASS Disc d
DECLARE CLASS Rect r
d->radius = 5.0
r->w = 10.0
r->h = 3.0

REM -- Void dispatch: verify member was set
d->tag = 0
r->tag = 0
Mark(d)
Mark(r)
ASSERT d->tag = 1, "Mark should set Disc tag to 1"
ASSERT r->tag = 2, "Mark should set Rect tag to 2"

REM -- LONGINT return dispatch
LONGINT v1, v2
v1 = GetCode(d)
v2 = GetCode(r)
ASSERT v1 = 42, "Disc GetCode should return 42"
ASSERT v2 = 99, "Rect GetCode should return 99"

REM -- SINGLE return dispatch
SINGLE area1, area2
area1 = CalcArea(d)
area2 = CalcArea(r)
ASSERT area1 = 25.0, "Disc area should be 25.0"
ASSERT area2 = 30.0, "Rect area should be 30.0"

REM -- Mixed params
LONGINT s1, s2
s1 = Scale(d, 5)
s2 = Scale(r, 5)
ASSERT s1 = 105, "Disc Scale(5) should return 105"
ASSERT s2 = 205, "Rect Scale(5) should return 205"

PRINT "generic_dispatch: ALL PASSED"
