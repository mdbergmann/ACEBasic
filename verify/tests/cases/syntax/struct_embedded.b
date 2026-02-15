REM Test: Embedded struct member access via chained ->

REM -- Define inner struct --
STRUCT Inner
  LONGINT x
  LONGINT y
END STRUCT

REM -- Define outer struct with embedded Inner --
STRUCT Outer
  Inner pt
  LONGINT z
END STRUCT

REM -- Define 3-level nesting for deep test --
STRUCT Deep
  Outer inner
  LONGINT w
END STRUCT

DECLARE STRUCT Outer o
DECLARE STRUCT Deep d

REM -- Test 1: assign and read through chained -> --
o->pt->x = 10&
o->pt->y = 20&
o->z = 30&

ASSERT o->pt->x = 10, "outer->pt->x should be 10"
ASSERT o->pt->y = 20, "outer->pt->y should be 20"
ASSERT o->z = 30, "outer->z should be 30"

REM -- Test 2: address of embedded struct --
ADDRESS addr
addr = @o->pt
ASSERT addr <> 0, "address of embedded struct should be non-zero"

REM -- verify offset: pt is at offset 0 in Outer, z is at offset 8 --
POKEL addr, 100&
POKEL addr + 4, 200&
ASSERT o->pt->x = 100, "writing via address should update pt->x"
ASSERT o->pt->y = 200, "writing via address should update pt->y"

REM -- Test 3: deep nesting (3 levels) --
d->inner->pt->x = 1000&
d->inner->pt->y = 2000&
d->inner->z = 3000&
d->w = 4000&

ASSERT d->inner->pt->x = 1000, "deep->inner->pt->x should be 1000"
ASSERT d->inner->pt->y = 2000, "deep->inner->pt->y should be 2000"
ASSERT d->inner->z = 3000, "deep->inner->z should be 3000"
ASSERT d->w = 4000, "deep->w should be 4000"

PRINT "struct_embedded: ALL PASSED"
