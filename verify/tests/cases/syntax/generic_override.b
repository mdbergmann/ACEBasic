REM Test: GENERIC dispatch - child with own METHOD is called directly

CLASS Shape
    LONGINT x
    LONGINT y
END CLASS

CLASS Rect EXTENDS Shape
    LONGINT w
    LONGINT h
END CLASS

GENERIC METHOD Info(CLASS)
    ON Shape
    ON Rect
END GENERIC

METHOD Info(Shape s)
    PRINT "shape"
END METHOD

METHOD Info(Rect r)
    PRINT "rect"; r->w; "x"; r->h
END METHOD

DECLARE CLASS Shape s1
DECLARE CLASS Rect r1
s1->x = 1 : s1->y = 2
r1->x = 3 : r1->y = 4
r1->w = 10 : r1->h = 20

Info(s1)
Info(r1)

ASSERT 1 = 1, "override dispatch ok"
PRINT "generic_override: PASSED"
