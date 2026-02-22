REM Test: Typed return values from generic methods

CLASS Disc
  SINGLE radius
END CLASS

CLASS Rect
  SINGLE w
  SINGLE h
END CLASS

GENERIC LONGINT METHOD GetCode(CLASS)
  ON Disc
  ON Rect
END GENERIC

METHOD LONGINT GetCode(Disc c)
  GetCode = 42
END METHOD

METHOD LONGINT GetCode(Rect r)
  GetCode = 99
END METHOD

DECLARE CLASS Disc d
DECLARE CLASS Rect r

d->radius = 5.0
r->w = 10.0
r->h = 3.0

LONGINT v1
LONGINT v2

v1 = GetCode(d)
v2 = GetCode(r)

ASSERT v1 = 42, "Disc GetCode should return 42"
ASSERT v2 = 99, "Rect GetCode should return 99"

PRINT "generic_return: ALL PASSED"
