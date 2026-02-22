REM Test: CLASS EXTENDS - member inheritance

CLASS Shape
    LONGINT x
    LONGINT y
END CLASS

CLASS Rect EXTENDS Shape
    LONGINT w
    LONGINT h
END CLASS

REM -- Shape: size = 4 (desc) + 4 (x) + 4 (y) = 12
REM -- Rect:  size = 4 (desc) + 4 (x) + 4 (y) + 4 (w) + 4 (h) = 20
ASSERT SIZEOF(Shape) = 12, "Shape size should be 12"
ASSERT SIZEOF(Rect) = 20, "Rect size should be 20"

REM -- Instantiate subclass, access inherited + own members
DECLARE CLASS Rect r

r->x = 10
r->y = 20
r->w = 100
r->h = 50

ASSERT r->x = 10, "inherited x should be 10"
ASSERT r->y = 20, "inherited y should be 20"
ASSERT r->w = 100, "own w should be 100"
ASSERT r->h = 50, "own h should be 50"

REM -- Descriptor pointer at offset 0 points to a descriptor
REM -- whose first long is the FNV-1a hash
LONGINT descPtr, parentPtr
descPtr = PEEKL(r)
parentPtr = PEEKL(descPtr + 4)
ASSERT parentPtr <> 0, "Rect should have a parent descriptor"

PRINT "class_extends: ALL PASSED"
