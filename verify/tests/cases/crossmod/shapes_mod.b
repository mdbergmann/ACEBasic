REM Module: shapes_mod.b
REM Compile with: bas -m shapes_mod
REM
REM Defines CLASS types, GENERIC dispatch table, and METHOD implementations.
REM Cross-module test: main program imports via DECLARE GENERIC METHOD.

CLASS Shape
  LONGINT x
  LONGINT y
END CLASS

CLASS Box
  LONGINT w
  LONGINT h
END CLASS

GENERIC METHOD Describe(CLASS)
  ON Shape
  ON Box
END GENERIC

METHOD Describe(Shape s)
  PRINT "Shape at"; s->x; ","; s->y
END METHOD

METHOD Describe(Box b)
  PRINT "Box"; b->w; "x"; b->h
END METHOD
