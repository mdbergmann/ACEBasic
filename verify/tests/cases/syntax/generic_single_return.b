REM Test: SINGLE return type from generic method

CLASS Disc
  SINGLE radius
END CLASS

GENERIC SINGLE METHOD CalcArea(CLASS)
  ON Disc
END GENERIC

METHOD SINGLE CalcArea(Disc c)
  CalcArea = c->radius * c->radius
END METHOD

DECLARE CLASS Disc d
d->radius = 5.0

SINGLE result
result = CalcArea(d)

ASSERT result = 25.0, "CalcArea of disc with r=5 should be 25"

PRINT "generic_single_return: ALL PASSED"
