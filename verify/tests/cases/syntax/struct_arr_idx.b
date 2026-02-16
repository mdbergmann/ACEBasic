REM Test: Typed array indexed access in nested contexts
REM Tests indexed s->member(i) through embedded structs,
REM struct pointers, and struct arrays.

REM -- Struct with typed arrays --
STRUCT HasArrays
  LONGINT longs SIZE 4
  SHORTINT shorts SIZE 4
  BYTE bytes SIZE 8
  LONGINT cnt
END STRUCT

REM -- Embedded struct wrapping HasArrays --
STRUCT EmbedWrap
  HasArrays inner
  LONGINT extra
END STRUCT

REM -- Struct pointer wrapping HasArrays --
STRUCT PtrWrap
  HasArrays *ptr
  LONGINT extra
END STRUCT

REM -- For struct array + typed array combination --
STRUCT ArrElem
  LONGINT vals SIZE 3
  SHORTINT flags SIZE 2
  LONGINT id
END STRUCT

STRUCT ArrHolder
  ArrElem items SIZE 3
  LONGINT cnt
END STRUCT

REM -- Deep nesting: embedded containing embedded with array --
STRUCT DeepInner
  LONGINT arr SIZE 3
  LONGINT tag
END STRUCT

STRUCT DeepOuter
  DeepInner nested
  LONGINT extra
END STRUCT

STRUCT DeepWrap
  DeepOuter deep
  LONGINT top
END STRUCT

DECLARE STRUCT EmbedWrap ew
DECLARE STRUCT PtrWrap pw
DECLARE STRUCT ArrHolder ah
DECLARE STRUCT DeepWrap dw

REM ================================================================
REM  Test 1: Typed array via embedded struct (chained ->)
REM ================================================================
ew->inner->longs(0) = 100&
ew->inner->longs(1) = 200&
ew->inner->longs(3) = 400&
ASSERT ew->inner->longs(0) = 100, "embed LONG(0) should be 100"
ASSERT ew->inner->longs(1) = 200, "embed LONG(1) should be 200"
ASSERT ew->inner->longs(3) = 400, "embed LONG(3) should be 400"

ew->inner->shorts(0) = 10
ew->inner->shorts(3) = 40
ASSERT ew->inner->shorts(0) = 10, "embed SHORT(0) should be 10"
ASSERT ew->inner->shorts(3) = 40, "embed SHORT(3) should be 40"

ew->inner->bytes(0) = 65
ew->inner->bytes(7) = 72
ASSERT ew->inner->bytes(0) = 65, "embed BYTE(0) should be 65"
ASSERT ew->inner->bytes(7) = 72, "embed BYTE(7) should be 72"

REM -- Scalar member in embedded struct still works --
ew->inner->cnt = 99&
ASSERT ew->inner->cnt = 99, "embed scalar cnt should be 99"

REM -- Outer scalar member unaffected --
ew->extra = 77&
ASSERT ew->extra = 77, "embed outer extra should be 77"

REM -- Variable index through embedded struct --
FOR i% = 0 TO 3
  ew->inner->longs(i%) = (i% + 1) * 1000&
NEXT i%
ASSERT ew->inner->longs(0) = 1000, "embed loop LONG(0) = 1000"
ASSERT ew->inner->longs(2) = 3000, "embed loop LONG(2) = 3000"
ASSERT ew->inner->longs(3) = 4000, "embed loop LONG(3) = 4000"

REM ================================================================
REM  Test 2: Typed array via struct pointer (chained ->)
REM ================================================================
pw->ptr = ALLOC(SIZEOF(HasArrays))
ASSERT pw->ptr <> 0, "alloc HasArrays should succeed"

pw->ptr->longs(0) = 500&
pw->ptr->longs(1) = 600&
pw->ptr->longs(3) = 800&
ASSERT pw->ptr->longs(0) = 500, "ptr LONG(0) should be 500"
ASSERT pw->ptr->longs(1) = 600, "ptr LONG(1) should be 600"
ASSERT pw->ptr->longs(3) = 800, "ptr LONG(3) should be 800"

pw->ptr->shorts(0) = 11
pw->ptr->shorts(2) = 33
ASSERT pw->ptr->shorts(0) = 11, "ptr SHORT(0) should be 11"
ASSERT pw->ptr->shorts(2) = 33, "ptr SHORT(2) should be 33"

pw->ptr->bytes(0) = 70
pw->ptr->bytes(5) = 75
ASSERT pw->ptr->bytes(0) = 70, "ptr BYTE(0) should be 70"
ASSERT pw->ptr->bytes(5) = 75, "ptr BYTE(5) should be 75"

REM -- Variable index through struct pointer --
FOR i% = 0 TO 3
  pw->ptr->longs(i%) = (i% + 1) * 111&
NEXT i%
ASSERT pw->ptr->longs(0) = 111, "ptr loop LONG(0) = 111"
ASSERT pw->ptr->longs(1) = 222, "ptr loop LONG(1) = 222"
ASSERT pw->ptr->longs(3) = 444, "ptr loop LONG(3) = 444"

pw->extra = 88&
ASSERT pw->extra = 88, "ptr outer extra should be 88"

REM ================================================================
REM  Test 3: Typed array inside struct array element
REM ================================================================
ah->items(0)->vals(0) = 10&
ah->items(0)->vals(1) = 20&
ah->items(0)->vals(2) = 30&
ah->items(0)->id = 1&
ASSERT ah->items(0)->vals(0) = 10, "sarr(0) vals(0) = 10"
ASSERT ah->items(0)->vals(1) = 20, "sarr(0) vals(1) = 20"
ASSERT ah->items(0)->vals(2) = 30, "sarr(0) vals(2) = 30"
ASSERT ah->items(0)->id = 1, "sarr(0) id = 1"

ah->items(1)->vals(0) = 100&
ah->items(1)->vals(2) = 300&
ah->items(1)->id = 2&
ASSERT ah->items(1)->vals(0) = 100, "sarr(1) vals(0) = 100"
ASSERT ah->items(1)->vals(2) = 300, "sarr(1) vals(2) = 300"
ASSERT ah->items(1)->id = 2, "sarr(1) id = 2"

ah->items(2)->vals(1) = 999&
ASSERT ah->items(2)->vals(1) = 999, "sarr(2) vals(1) = 999"

REM -- SHORTINT array inside struct array element --
ah->items(0)->flags(0) = 1
ah->items(0)->flags(1) = 2
ah->items(1)->flags(0) = 3
ah->items(2)->flags(1) = 4
ASSERT ah->items(0)->flags(0) = 1, "sarr(0) flags(0) = 1"
ASSERT ah->items(0)->flags(1) = 2, "sarr(0) flags(1) = 2"
ASSERT ah->items(1)->flags(0) = 3, "sarr(1) flags(0) = 3"
ASSERT ah->items(2)->flags(1) = 4, "sarr(2) flags(1) = 4"

REM -- Variable indices for both struct array and typed array --
FOR i% = 0 TO 2
  FOR j% = 0 TO 2
    ah->items(i%)->vals(j%) = i% * 10 + j%
  NEXT j%
NEXT i%
ASSERT ah->items(0)->vals(0) = 0, "loop sarr(0) vals(0) = 0"
ASSERT ah->items(0)->vals(2) = 2, "loop sarr(0) vals(2) = 2"
ASSERT ah->items(1)->vals(0) = 10, "loop sarr(1) vals(0) = 10"
ASSERT ah->items(1)->vals(1) = 11, "loop sarr(1) vals(1) = 11"
ASSERT ah->items(2)->vals(2) = 22, "loop sarr(2) vals(2) = 22"

ah->cnt = 3&
ASSERT ah->cnt = 3, "arr holder cnt should be 3"

REM ================================================================
REM  Test 4: Deep nesting with typed array (3 levels of ->)
REM ================================================================
dw->deep->nested->arr(0) = 1111&
dw->deep->nested->arr(1) = 2222&
dw->deep->nested->arr(2) = 3333&
ASSERT dw->deep->nested->arr(0) = 1111, "deep arr(0) = 1111"
ASSERT dw->deep->nested->arr(1) = 2222, "deep arr(1) = 2222"
ASSERT dw->deep->nested->arr(2) = 3333, "deep arr(2) = 3333"

dw->deep->nested->tag = 42&
ASSERT dw->deep->nested->tag = 42, "deep nested tag = 42"

dw->deep->extra = 55&
ASSERT dw->deep->extra = 55, "deep extra = 55"

dw->top = 66&
ASSERT dw->top = 66, "deep top = 66"

REM -- Variable index at deep nesting --
FOR i% = 0 TO 2
  dw->deep->nested->arr(i%) = (i% + 1) * 5000&
NEXT i%
ASSERT dw->deep->nested->arr(0) = 5000, "deep loop arr(0) = 5000"
ASSERT dw->deep->nested->arr(1) = 10000, "deep loop arr(1) = 10000"
ASSERT dw->deep->nested->arr(2) = 15000, "deep loop arr(2) = 15000"

REM ================================================================
REM  Test 5: Non-indexed access still returns base address
REM ================================================================
LONGINT addr&
addr& = @ew->inner->longs
ASSERT addr& <> 0, "embed array base addr nonzero"
POKEL addr&, 7777&
ASSERT ew->inner->longs(0) = 7777, "POKE base visible via embed idx"

ew->inner->longs(0) = 8888&
ASSERT PEEKL(@ew->inner->longs) = 8888, "embed idx visible via PEEK"

PRINT "struct_arr_idx: ALL PASSED"
