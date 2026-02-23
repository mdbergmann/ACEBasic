REM Test: STRUCT embedded in CLASS and STRUCT pointer in CLASS

STRUCT Vec2
  LONGINT x
  LONGINT y
END STRUCT

REM -- CLASS with embedded struct member --
CLASS Marker
  Vec2 pt
  LONGINT col
END CLASS

REM -- CLASS with struct pointer member --
CLASS Cursor
  Vec2 *target
  LONGINT mode
END CLASS

REM -- Test 1: embedded struct in class --
DECLARE CLASS Marker m
m->pt->x = 10
m->pt->y = 20
m->col = 255

ASSERT m->pt->x = 10, "marker pt->x should be 10"
ASSERT m->pt->y = 20, "marker pt->y should be 20"
ASSERT m->col = 255, "marker col should be 255"

REM -- Test 2: type ID still at offset 0 of class --
ASSERT PEEKL(m) <> 0, "marker type ID should be non-zero"

REM -- Test 3: struct pointer in class --
DECLARE CLASS Cursor cur
DECLARE STRUCT Vec2 v1
v1->x = 42
v1->y = 99
cur->target = v1
cur->mode = 3

ASSERT cur->target->x = 42, "cursor target->x should be 42"
ASSERT cur->target->y = 99, "cursor target->y should be 99"
ASSERT cur->mode = 3, "cursor mode should be 3"

REM -- Test 4: struct pointer via ALLOC --
cur->target = ALLOC(SIZEOF(Vec2))
ASSERT cur->target <> 0, "alloc should succeed"
cur->target->x = 77
cur->target->y = 88
ASSERT cur->target->x = 77, "alloc target->x should be 77"
ASSERT cur->target->y = 88, "alloc target->y should be 88"

PRINT "class_struct_member: ALL PASSED"
