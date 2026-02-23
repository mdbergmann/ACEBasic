REM Test: Cross-module generic method dispatch
REM
REM Imports GENERIC Describe(CLASS) from shapes_mod.o
REM Verifies that dispatch works across module boundaries.

REM #using shapes_mod.o

CLASS Shape
  LONGINT x
  LONGINT y
END CLASS

CLASS Box
  LONGINT w
  LONGINT h
END CLASS

DECLARE GENERIC METHOD Describe(CLASS)

DECLARE CLASS Shape s1
DECLARE CLASS Box b1
s1->x = 10
s1->y = 20
b1->w = 5
b1->h = 3

Describe(s1)
Describe(b1)
