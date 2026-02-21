REM Test: STRUCT instance as SUB parameter (struct-typed param sugar)

STRUCT Vec2D
  SINGLE x
  SINGLE y
END STRUCT

SUB PrintVec(Vec2D p)
  ASSERT p->x = 3.0, "p->x should be 3.0"
  ASSERT p->y = 4.0, "p->y should be 4.0"
END SUB

DECLARE STRUCT Vec2D pt
pt->x = 3.0
pt->y = 4.0
PrintVec(pt)

PRINT "struct_sub_param: ALL PASSED"
