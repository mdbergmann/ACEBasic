REM Test TYPECASE with ISA-like matching

CLASS Shape
    LONGINT x
END CLASS

CLASS Rect EXTENDS Shape
    LONGINT w
    LONGINT h
END CLASS

CLASS Oval EXTENDS Shape
    LONGINT rx
    LONGINT ry
END CLASS

SUB LONGINT Describe(Shape obj)
  LONGINT result
  result = 0
  TYPECASE obj
    CASE Rect
      result = 1
    CASE Oval
      result = 2
    CASE Shape
      result = 3
    CASE ELSE
      result = -1
  END TYPECASE
  Describe = result
END SUB

DECLARE CLASS Rect r
DECLARE CLASS Oval o
DECLARE CLASS Shape s

ASSERT Describe(r) = 1, "Rect should match CASE Rect"
ASSERT Describe(o) = 2, "Oval should match CASE Oval"
ASSERT Describe(s) = 3, "Shape should match CASE Shape"

PRINT "typecase: ALL PASSED"
