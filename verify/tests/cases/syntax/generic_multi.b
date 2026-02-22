REM Test: Multiple dispatch (two CLASS parameters)

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
END GENERIC

METHOD LONGINT Collide(Disc a, Disc b)
  Collide = 11
END METHOD

METHOD LONGINT Collide(Disc a, Rect b)
  Collide = 12
END METHOD

DECLARE CLASS Disc c1, c2
DECLARE CLASS Rect r1

LONGINT result

result = Collide(c1, c2)
ASSERT result = 11, "disc-disc dispatch should return 11"

result = Collide(c1, r1)
ASSERT result = 12, "disc-rect dispatch should return 12"

PRINT "generic_multi: ALL PASSED"
