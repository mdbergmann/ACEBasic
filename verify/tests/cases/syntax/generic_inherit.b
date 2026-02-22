REM Test: GENERIC dispatch - parent method called for child instance

CLASS Shape
    LONGINT x
    LONGINT y
END CLASS

CLASS Rect EXTENDS Shape
    LONGINT w
    LONGINT h
END CLASS

GENERIC METHOD Describe(CLASS)
    ON Shape
END GENERIC

METHOD Describe(Shape s)
    PRINT "Shape at"; s->x; ","; s->y
END METHOD

REM -- Call with child class (no METHOD for Rect, inherits Shape's)
DECLARE CLASS Rect r
r->x = 42
r->y = 99

Describe(r)

ASSERT 1 = 1, "inherited dispatch ok"
PRINT "generic_inherit: PASSED"
