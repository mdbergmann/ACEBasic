REM Test: GENERIC dispatch with inheritance - override, inherit, 3-level chain

CLASS Shape
    LONGINT x
    LONGINT y
END CLASS

CLASS Rect EXTENDS Shape
    LONGINT w
    LONGINT h
END CLASS

CLASS ColorRect EXTENDS Rect
    LONGINT col
END CLASS

REM -- Override dispatch: both Shape and Rect have their own METHOD
REM -- Also tests inherited dispatch for ColorRect (walks up to Rect)
GENERIC LONGINT METHOD Info(CLASS)
    ON Shape
    ON Rect
END GENERIC

METHOD LONGINT Info(Shape s)
    Info = 1
END METHOD

METHOD LONGINT Info(Rect r)
    Info = 2
END METHOD

DECLARE CLASS Shape s1
DECLARE CLASS Rect r1
DECLARE CLASS ColorRect cr1

s1->x = 1 : s1->y = 2
r1->x = 3 : r1->y = 4 : r1->w = 10 : r1->h = 20
cr1->x = 5 : cr1->y = 6 : cr1->w = 30 : cr1->h = 40 : cr1->col = 255

REM -- Override: parent gets parent METHOD, child gets child METHOD
LONGINT rv
rv = Info(s1)
ASSERT rv = 1, "Shape Info should return 1"
rv = Info(r1)
ASSERT rv = 2, "Rect Info should return 2"

REM -- Inherited dispatch: ColorRect has no Info METHOD
REM -- Should walk parent chain: ColorRect -> Rect (match!)
rv = Info(cr1)
ASSERT rv = 2, "ColorRect Info should inherit Rect (return 2)"

REM -- Inherited dispatch: only Shape listed in ON clause
REM -- Child dispatches to parent METHOD via parent chain walk
GENERIC LONGINT METHOD Describe(CLASS)
    ON Shape
END GENERIC

METHOD LONGINT Describe(Shape s)
    Describe = s->x + s->y
END METHOD

rv = Describe(s1)
ASSERT rv = 3, "Shape Describe should return 3"

REM -- Rect inherits Shape's Describe (1 hop)
rv = Describe(r1)
ASSERT rv = 7, "Rect Describe should inherit Shape (return 7)"

REM -- ColorRect inherits Shape's Describe (2 hops: ColorRect->Rect->Shape)
rv = Describe(cr1)
ASSERT rv = 11, "ColorRect Describe should walk 2 hops (return 11)"

PRINT "generic_inherit: ALL PASSED"
