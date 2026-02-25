REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/testkit/testkit.o

{*
** test_builder.b - Tests for Hashmap builder pattern
** Tests: HmNew, HmAdd$, HmAdd&, HmAdd!, HmAddRef, HmAddBool, HmAddNull, HmEnd
** Builder maps: use HmFree(m) then FREE map& to release both arrays and struct.
*}

#include <submods/hashmap.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== Hashmap Builder Tests ==="
PRINT

TkInit

LONGINT map&, inner&, ref&
SHORTINT rc%

DECLARE CLASS Hashmap m
DECLARE CLASS Hashmap mInner

{* ============== Test 1: Basic string builder ============== *}

PRINT "-- Test 1: Basic string builder"
HmNew(HM_SMALL)
  HmAdd$("name", "Alice")
  HmAdd$("city", "Berlin")
map& = HmEnd

m = map&
TkAssertEq&(HmCount(m), 2, "count = 2")
TkAssertEqStr(HmGet$(m, "name"), "Alice", "name = Alice")
TkAssertEqStr(HmGet$(m, "city"), "Berlin", "city = Berlin")
HmFree(m)
FREE map&

{* ============== Test 2: Mixed types ============== *}

PRINT "-- Test 2: Mixed types"
HmNew(HM_SMALL)
  HmAdd$("name", "Bob")
  HmAdd&("age", 42)
  HmAdd!("score", 3.14)
  HmAddBool("active", 1)
  HmAddNull("deleted")
map& = HmEnd

m = map&
TkAssertEq&(HmCount(m), 5, "count = 5")
TkAssertEqStr(HmGet$(m, "name"), "Bob", "name = Bob")
TkAssertEq&(HmGet&(m, "age"), 42, "age = 42")
TkAssertEq%(HmType(m, "name"), HmTypeStr, "name type = str")
TkAssertEq%(HmType(m, "age"), HmTypeLng, "age type = lng")
TkAssertEq%(HmType(m, "score"), HmTypeSng, "score type = sng")
TkAssertEq%(HmType(m, "active"), HmTypeBool, "active type = bool")
TkAssertEq&(HmGet&(m, "active"), 1, "active = 1")
TkAssertEq%(HmType(m, "deleted"), HmTypeNull, "deleted type = null")
HmFree(m)
FREE map&

{* ============== Test 3: Nested builder (inner first) ============== *}

PRINT "-- Test 3: Nested builder"
' Build inner map first
HmNew(HM_SMALL)
  HmAdd$("street", "123 Main St")
  HmAdd$("city", "Berlin")
inner& = HmEnd

' Build outer map, reference inner
HmNew(HM_SMALL)
  HmAdd$("name", "Alice")
  HmAddRef("address", inner&)
map& = HmEnd

m = map&
TkAssertEq&(HmCount(m), 2, "outer count = 2")
TkAssertEqStr(HmGet$(m, "name"), "Alice", "name = Alice")
TkAssertEq%(HmType(m, "address"), HmTypeRef, "address type = ref")

ref& = HmGetRef(m, "address")
TkAssertEq&(ref&, inner&, "ref = inner address")

mInner = ref&
TkAssertEqStr(HmGet$(mInner, "street"), "123 Main St", "inner street")
TkAssertEqStr(HmGet$(mInner, "city"), "Berlin", "inner city")

HmFree(mInner)
FREE inner&
HmFree(m)
FREE map&

{* ============== Test 4: Builder returns valid ADDRESS ============== *}

PRINT "-- Test 4: HmEnd returns nonzero ADDRESS"
HmNew(HM_SMALL)
  HmAdd$("x", "y")
map& = HmEnd
TkAssertTrue(map& <> 0, "HmEnd returns nonzero")

m = map&
TkAssertEq&(HmCapacity(m), HM_SMALL, "capacity = HM_SMALL")
HmFree(m)
FREE map&

{* ============== Test 5: Builder error propagation ============== *}

PRINT "-- Test 5: Error propagation"
HmNew(HM_SMALL)
  rc% = HmAdd$("k1", "v1")
  TkAssertEq%(rc%, HM_SUCCESS, "add returns SUCCESS")
map& = HmEnd

m = map&
HmFree(m)
FREE map&

{* ============== Test 6: Iteration order preserved ============== *}

PRINT "-- Test 6: Iteration order"
HmNew(HM_SMALL)
  HmAdd$("first", "1")
  HmAdd&("second", 2)
  HmAddBool("third", 0)
map& = HmEnd

m = map&
HmIterReset(m)

TkAssertTrue(HmIterNext(m), "iter 1")
TkAssertEqStr(HmIterKey$(m), "first", "key 1 = first")

TkAssertTrue(HmIterNext(m), "iter 2")
TkAssertEqStr(HmIterKey$(m), "second", "key 2 = second")

TkAssertTrue(HmIterNext(m), "iter 3")
TkAssertEqStr(HmIterKey$(m), "third", "key 3 = third")

TkAssertEq%(HmIterNext(m), 0, "iter done")
HmFree(m)
FREE map&

{* ============== Test 7: Empty builder ============== *}

PRINT "-- Test 7: Empty builder"
HmNew(HM_SMALL)
map& = HmEnd
TkAssertTrue(map& <> 0, "empty builder returns nonzero")

m = map&
TkAssertEq&(HmCount(m), 0, "empty count = 0")
HmFree(m)
FREE map&

{* ============== Summary ============== *}
TkSummary
