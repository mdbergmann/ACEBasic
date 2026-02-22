STRUCT Vec2D
  SINGLE x
  SINGLE y
END STRUCT

SUB PrintVec(Vec2D p)
  PRINT p->x; ","; p->y
END SUB

DECLARE STRUCT Vec2D pt
pt->x = 3.0
pt->y = 4.0
PrintVec(pt)
