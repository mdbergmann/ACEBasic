REM Test: Generic with mixed dispatched and non-dispatched params

CLASS Disc
  SINGLE radius
END CLASS

CLASS Rect
  SINGLE w
  SINGLE h
END CLASS

GENERIC LONGINT METHOD Scale(CLASS, LONGINT)
  ON Disc
  ON Rect
END GENERIC

METHOD LONGINT Scale(Disc c, LONGINT factor)
  Scale = 100 + factor
END METHOD

METHOD LONGINT Scale(Rect r, LONGINT factor)
  Scale = 200 + factor
END METHOD

DECLARE CLASS Disc d
DECLARE CLASS Rect r

LONGINT v1
LONGINT v2

v1 = Scale(d, 5)
v2 = Scale(r, 5)

ASSERT v1 = 105, "Disc Scale(5) should return 105"
ASSERT v2 = 205, "Rect Scale(5) should return 205"

PRINT "generic_mixed_params: ALL PASSED"
