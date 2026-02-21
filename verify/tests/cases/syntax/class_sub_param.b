REM Test: CLASS instance as SUB parameter (struct-typed param sugar)

CLASS Pos2D
    SINGLE x
    SINGLE y
END CLASS

SUB PrintPos(Pos2D p)
    ASSERT p->x = 3.0, "p->x should be 3.0"
    ASSERT p->y = 4.0, "p->y should be 4.0"
END SUB

DECLARE CLASS Pos2D pt
pt->x = 3.0
pt->y = 4.0
PrintPos(pt)

PRINT "class_sub_param: ALL PASSED"
