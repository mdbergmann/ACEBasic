CLASS Shape
  SINGLE x
  SINGLE y
END CLASS

CLASS Box
  SINGLE w
  SINGLE h
END CLASS

GENERIC METHOD Draw(CLASS)
  ON Shape
  ON Box
END GENERIC

METHOD Draw(Shape s)
  PRINT "Shape at"; s->x; ","; s->y
END METHOD

METHOD Draw(Box b)
  PRINT "Box"; b->w; "x"; b->h
END METHOD

DECLARE CLASS Shape s1
DECLARE CLASS Box b1
s1->x = 10.0
s1->y = 20.0
b1->w = 5.0
b1->h = 3.0

Draw(s1)
Draw(b1)

ASSERT 1 = 1, "generic dispatch ok"
