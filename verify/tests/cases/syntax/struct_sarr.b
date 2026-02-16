REM Test: Struct arrays as struct members (Inner items SIZE n)

STRUCT Vec2
  LONGINT x
  LONGINT y
END STRUCT

STRUCT Holder
  Vec2 pts SIZE 5
  LONGINT cnt
END STRUCT

DECLARE STRUCT Holder c

REM -- Test 1: Write and read via constant index --
c->pts(0)->x = 10&
c->pts(0)->y = 20&
c->pts(1)->x = 30&
c->pts(1)->y = 40&
c->pts(4)->x = 90&
c->pts(4)->y = 100&
ASSERT c->pts(0)->x = 10, "pts(0)->x should be 10"
ASSERT c->pts(0)->y = 20, "pts(0)->y should be 20"
ASSERT c->pts(1)->x = 30, "pts(1)->x should be 30"
ASSERT c->pts(1)->y = 40, "pts(1)->y should be 40"
ASSERT c->pts(4)->x = 90, "pts(4)->x should be 90"
ASSERT c->pts(4)->y = 100, "pts(4)->y should be 100"

REM -- Test 2: Write via loop with variable index --
FOR i% = 0 TO 4
  c->pts(i%)->x = (i% + 1) * 100&
  c->pts(i%)->y = (i% + 1) * 200&
NEXT i%

REM -- Test 3: Read via variable index --
ASSERT c->pts(0)->x = 100, "loop pts(0)->x should be 100"
ASSERT c->pts(2)->x = 300, "loop pts(2)->x should be 300"
ASSERT c->pts(4)->y = 1000, "loop pts(4)->y should be 1000"

REM -- Test 4: Scalar member still works --
c->cnt = 5&
ASSERT c->cnt = 5, "scalar member cnt should be 5"

REM -- Test 5: Base address of struct array (no index) --
REM c->pts without index should push base address
LONGINT addr&
addr& = @c->pts
ASSERT addr& <> 0, "struct array base address should be nonzero"

REM -- Test 6: SIZEOF --
ASSERT SIZEOF(Vec2) = 8, "sizeof Vec2 should be 8"
ASSERT SIZEOF(Holder) = 44, "sizeof Holder should be 44"

PRINT "struct_sarr: ALL PASSED"
