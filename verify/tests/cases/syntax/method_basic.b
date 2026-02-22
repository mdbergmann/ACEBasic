REM Test: METHOD definition with CLASS-typed parameters

CLASS Shape
    SINGLE x
    SINGLE y
END CLASS

CLASS Box
    SINGLE w
    SINGLE h
END CLASS

METHOD Draw(Shape s)
  PRINT "Shape at "; s->x; ","; s->y
END METHOD

METHOD Draw(Box b)
  PRINT "Box "; b->w; "x"; b->h
END METHOD

METHOD SINGLE GetX(Shape s)
  GetX = s->x
END METHOD

METHOD SetXY(Shape s, SINGLE nx, SINGLE ny)
  s->x = nx
  s->y = ny
END METHOD

DECLARE CLASS Shape s1
DECLARE CLASS Box b1
s1->x = 10.0
s1->y = 20.0
b1->w = 5.0
b1->h = 3.0

PRINT "method_basic: ALL PASSED"
