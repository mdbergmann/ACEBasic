REM Test: Typed arrays in struct members (BYTE/SHORT/LONG/SINGLE SIZE n)

STRUCT ArrayStruct
  BYTE buf SIZE 16
  LONGINT vals SIZE 4
  SHORTINT flags SIZE 8
  SINGLE coords SIZE 3
  STRING tag SIZE 32
  LONGINT scalar
END STRUCT

DECLARE STRUCT ArrayStruct s

REM -- Test BYTE array: write and read via PEEK/POKE --
POKE @s->buf, 65
POKE @s->buf + 1, 66
POKE @s->buf + 2, 67
ASSERT PEEK(@s->buf) = 65, "BYTE array element 0 should be 65"
ASSERT PEEK(@s->buf + 1) = 66, "BYTE array element 1 should be 66"
ASSERT PEEK(@s->buf + 2) = 67, "BYTE array element 2 should be 67"

REM -- Test LONGINT array: write and read via PEEKL/POKEL --
POKEL @s->vals, 100&
POKEL @s->vals + 4, 200&
POKEL @s->vals + 8, 300&
POKEL @s->vals + 12, 400&
ASSERT PEEKL(@s->vals) = 100, "LONGINT array element 0 should be 100"
ASSERT PEEKL(@s->vals + 4) = 200, "LONGINT array element 1 should be 200"
ASSERT PEEKL(@s->vals + 8) = 300, "LONGINT array element 2 should be 300"
ASSERT PEEKL(@s->vals + 12) = 400, "LONGINT array element 3 should be 400"

REM -- Test SHORTINT array: write and read via PEEKW/POKEW --
POKEW @s->flags, 1
POKEW @s->flags + 2, 0
POKEW @s->flags + 4, 1
ASSERT PEEKW(@s->flags) = 1, "SHORTINT array element 0 should be 1"
ASSERT PEEKW(@s->flags + 2) = 0, "SHORTINT array element 1 should be 0"
ASSERT PEEKW(@s->flags + 4) = 1, "SHORTINT array element 2 should be 1"

REM -- Test scalar member still works alongside arrays --
s->scalar = 42&
ASSERT s->scalar = 42, "Scalar member should be 42"

REM -- Test STRING SIZE still works (backward compat) --
s->tag = "hello"
ASSERT s->tag = "hello", "STRING SIZE member should work"

REM ================================================================
REM  Indexed access tests: s->member(index)
REM ================================================================

REM -- LONGINT indexed access: write and read --
s->vals(0) = 1000&
s->vals(1) = 2000&
s->vals(2) = 3000&
s->vals(3) = 4000&
ASSERT s->vals(0) = 1000, "LONG idx(0) should be 1000"
ASSERT s->vals(1) = 2000, "LONG idx(1) should be 2000"
ASSERT s->vals(2) = 3000, "LONG idx(2) should be 3000"
ASSERT s->vals(3) = 4000, "LONG idx(3) should be 4000"

REM -- SHORTINT indexed access: write and read --
s->flags(0) = 10
s->flags(1) = 20
s->flags(2) = 30
s->flags(7) = 80
ASSERT s->flags(0) = 10, "SHORT idx(0) should be 10"
ASSERT s->flags(1) = 20, "SHORT idx(1) should be 20"
ASSERT s->flags(2) = 30, "SHORT idx(2) should be 30"
ASSERT s->flags(7) = 80, "SHORT idx(7) should be 80"

REM -- BYTE indexed access: write and read --
s->buf(0) = 65
s->buf(1) = 66
s->buf(15) = 90
ASSERT s->buf(0) = 65, "BYTE idx(0) should be 65"
ASSERT s->buf(1) = 66, "BYTE idx(1) should be 66"
ASSERT s->buf(15) = 90, "BYTE idx(15) should be 90"

REM -- SINGLE indexed access: write and read --
s->coords(0) = 1.5
s->coords(1) = 2.5
s->coords(2) = 3.5
ASSERT s->coords(0) = 1.5, "SINGLE idx(0) should be 1.5"
ASSERT s->coords(1) = 2.5, "SINGLE idx(1) should be 2.5"
ASSERT s->coords(2) = 3.5, "SINGLE idx(2) should be 3.5"

REM -- Variable index in FOR loop --
FOR i% = 0 TO 3
  s->vals(i%) = (i% + 1) * 10&
NEXT i%
ASSERT s->vals(0) = 10, "loop LONG idx(0) should be 10"
ASSERT s->vals(1) = 20, "loop LONG idx(1) should be 20"
ASSERT s->vals(2) = 30, "loop LONG idx(2) should be 30"
ASSERT s->vals(3) = 40, "loop LONG idx(3) should be 40"

REM -- Variable index for SHORTINT --
FOR i% = 0 TO 7
  s->flags(i%) = i% * 5
NEXT i%
ASSERT s->flags(0) = 0, "loop SHORT idx(0) should be 0"
ASSERT s->flags(3) = 15, "loop SHORT idx(3) should be 15"
ASSERT s->flags(7) = 35, "loop SHORT idx(7) should be 35"

REM -- Variable index for BYTE --
FOR i% = 0 TO 7
  s->buf(i%) = 65 + i%
NEXT i%
ASSERT s->buf(0) = 65, "loop BYTE idx(0) should be 65"
ASSERT s->buf(3) = 68, "loop BYTE idx(3) should be 68"
ASSERT s->buf(7) = 72, "loop BYTE idx(7) should be 72"

REM -- Expression as index --
s->vals(1 + 1) = 999&
ASSERT s->vals(2) = 999, "expr index write should work"
SHORTINT idx%
idx% = 2
ASSERT s->vals(idx%) = 999, "variable read after expr write"
s->vals(idx% + 1) = 888&
ASSERT s->vals(3) = 888, "expr with var index should work"

REM -- Cross-check: POKE via base address, read via index --
LONGINT addr&
addr& = @s->vals
POKEL addr&, 7777&
ASSERT s->vals(0) = 7777, "POKE at base visible via index"

REM -- Cross-check: index write, PEEK via base address --
s->vals(0) = 8888&
ASSERT PEEKL(@s->vals) = 8888, "index write visible via PEEK"

REM -- Scalar member unaffected by indexed operations --
s->scalar = 55&
ASSERT s->scalar = 55, "scalar unaffected after indexed ops"

PRINT "struct_array: ALL PASSED"
