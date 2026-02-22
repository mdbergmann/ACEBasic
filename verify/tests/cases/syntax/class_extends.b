REM Test: CLASS EXTENDS - member inheritance, 3-level chain, descriptors

CLASS Shape
    LONGINT x
    LONGINT y
END CLASS

CLASS Rect EXTENDS Shape
    LONGINT w
    LONGINT h
END CLASS

CLASS ColorRect EXTENDS Rect
    LONGINT col
END CLASS

REM -- SIZEOF checks at each level
REM -- Shape: 4 (desc) + 4 (x) + 4 (y) = 12
REM -- Rect:  12 + 4 (w) + 4 (h) = 20
REM -- ColorRect: 20 + 4 (col) = 24
ASSERT SIZEOF(Shape) = 12, "Shape size should be 12"
ASSERT SIZEOF(Rect) = 20, "Rect size should be 20"
ASSERT SIZEOF(ColorRect) = 24, "ColorRect size should be 24"

REM -- 2-level inheritance: Rect inherits Shape members
DECLARE CLASS Rect r1
r1->x = 10
r1->y = 20
r1->w = 100
r1->h = 50
ASSERT r1->x = 10, "r1 inherited x should be 10"
ASSERT r1->y = 20, "r1 inherited y should be 20"
ASSERT r1->w = 100, "r1 own w should be 100"
ASSERT r1->h = 50, "r1 own h should be 50"

REM -- 3-level inheritance: ColorRect inherits Shape + Rect members
DECLARE CLASS ColorRect cr
cr->x = 1
cr->y = 2
cr->w = 30
cr->h = 40
cr->col = 255
ASSERT cr->x = 1, "cr inherited x should be 1"
ASSERT cr->y = 2, "cr inherited y should be 2"
ASSERT cr->w = 30, "cr inherited w should be 30"
ASSERT cr->h = 40, "cr inherited h should be 40"
ASSERT cr->col = 255, "cr own col should be 255"

REM -- Multiple instances of same CLASS type
DECLARE CLASS Rect r2
r2->x = 77
r2->y = 88
r2->w = 200
r2->h = 300
ASSERT r2->x = 77, "r2 x should be 77"
ASSERT r2->w = 200, "r2 w should be 200"
REM -- r1 must be unaffected
ASSERT r1->x = 10, "r1 x still 10 after r2 created"
ASSERT r1->w = 100, "r1 w still 100 after r2 created"

REM -- Descriptor parent chain: 3 deep
REM -- ColorRect desc -> Rect desc -> Shape desc -> 0
LONGINT crDesc, rectDesc, shapeDesc, rootParent
crDesc = PEEKL(cr)
rectDesc = PEEKL(crDesc + 4)
ASSERT rectDesc <> 0, "ColorRect parent desc should point to Rect"
shapeDesc = PEEKL(rectDesc + 4)
ASSERT shapeDesc <> 0, "Rect parent desc should point to Shape"
rootParent = PEEKL(shapeDesc + 4)
ASSERT rootParent = 0, "Shape parent desc should be 0 (root)"

PRINT "class_extends: ALL PASSED"
