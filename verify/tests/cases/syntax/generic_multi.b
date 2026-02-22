REM Test: Multiple dispatch (two CLASS parameters) - all 2x2 combos

CLASS Disc
    SINGLE radius
END CLASS

CLASS Rect
    SINGLE w
    SINGLE h
END CLASS

GENERIC LONGINT METHOD Collide(CLASS, CLASS)
    ON Disc, Disc
    ON Disc, Rect
    ON Rect, Disc
    ON Rect, Rect
END GENERIC

METHOD LONGINT Collide(Disc a, Disc b)
    Collide = 11
END METHOD

METHOD LONGINT Collide(Disc a, Rect b)
    Collide = 12
END METHOD

METHOD LONGINT Collide(Rect a, Disc b)
    Collide = 21
END METHOD

METHOD LONGINT Collide(Rect a, Rect b)
    Collide = 22
END METHOD

DECLARE CLASS Disc c1, c2
DECLARE CLASS Rect r1, r2

LONGINT result

result = Collide(c1, c2)
ASSERT result = 11, "disc-disc should return 11"

result = Collide(c1, r1)
ASSERT result = 12, "disc-rect should return 12"

result = Collide(r1, c1)
ASSERT result = 21, "rect-disc should return 21"

result = Collide(r1, r2)
ASSERT result = 22, "rect-rect should return 22"

PRINT "generic_multi: ALL PASSED"
