REM #using ace:submods/hashmap/hashmap.o

{*
** test_builder.b - Tests for Hashmap builder pattern
** Tests: HmNew, HmAdd$, HmAdd&, HmAdd!, HmAddRef, HmAddBool, HmAddNull, HmEnd
** Builder maps: use HmFree(m) then FREE map& to release both arrays and struct.
*}

#include <submods/hashmap.h>

SHORTINT _passed, _failed

{* ============== Assertion Helpers ============== *}

SUB AssertTrue(SHORTINT condition, msg$)
  SHARED _passed, _failed
  IF condition THEN
    _passed = _passed + 1
  ELSE
    PRINT "FAIL: "; msg$
    _failed = _failed + 1
  END IF
END SUB

SUB AssertEqStr(actual$, expected$, msg$)
  SHARED _passed, _failed
  IF actual$ = expected$ THEN
    _passed = _passed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected '"; expected$; "' got '"; actual$; "')"
    _failed = _failed + 1
  END IF
END SUB

SUB AssertEq&(LONGINT actual, LONGINT expected, msg$)
  SHARED _passed, _failed
  IF actual = expected THEN
    _passed = _passed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected"; expected; " got"; actual; ")"
    _failed = _failed + 1
  END IF
END SUB

SUB AssertEq%(SHORTINT actual, SHORTINT expected, msg$)
  SHARED _passed, _failed
  IF actual = expected THEN
    _passed = _passed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected"; expected; " got"; actual; ")"
    _failed = _failed + 1
  END IF
END SUB

{* ============== Test Suite ============== *}

PRINT "=== Hashmap Builder Tests ==="
PRINT

_passed = 0
_failed = 0

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
AssertEq&(HmCount(m), 2, "count = 2")
AssertEqStr(HmGet$(m, "name"), "Alice", "name = Alice")
AssertEqStr(HmGet$(m, "city"), "Berlin", "city = Berlin")
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
AssertEq&(HmCount(m), 5, "count = 5")
AssertEqStr(HmGet$(m, "name"), "Bob", "name = Bob")
AssertEq&(HmGet&(m, "age"), 42, "age = 42")
AssertEq%(HmType(m, "name"), HmTypeStr, "name type = str")
AssertEq%(HmType(m, "age"), HmTypeLng, "age type = lng")
AssertEq%(HmType(m, "score"), HmTypeSng, "score type = sng")
AssertEq%(HmType(m, "active"), HmTypeBool, "active type = bool")
AssertEq&(HmGet&(m, "active"), 1, "active = 1")
AssertEq%(HmType(m, "deleted"), HmTypeNull, "deleted type = null")
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
AssertEq&(HmCount(m), 2, "outer count = 2")
AssertEqStr(HmGet$(m, "name"), "Alice", "name = Alice")
AssertEq%(HmType(m, "address"), HmTypeRef, "address type = ref")

ref& = HmGetRef(m, "address")
AssertEq&(ref&, inner&, "ref = inner address")

mInner = ref&
AssertEqStr(HmGet$(mInner, "street"), "123 Main St", "inner street")
AssertEqStr(HmGet$(mInner, "city"), "Berlin", "inner city")

HmFree(mInner)
FREE inner&
HmFree(m)
FREE map&

{* ============== Test 4: Builder returns valid ADDRESS ============== *}

PRINT "-- Test 4: HmEnd returns nonzero ADDRESS"
HmNew(HM_SMALL)
  HmAdd$("x", "y")
map& = HmEnd
AssertTrue(map& <> 0, "HmEnd returns nonzero")

m = map&
AssertEq&(HmCapacity(m), HM_SMALL, "capacity = HM_SMALL")
HmFree(m)
FREE map&

{* ============== Test 5: Builder error propagation ============== *}

PRINT "-- Test 5: Error propagation"
HmNew(HM_SMALL)
  rc% = HmAdd$("k1", "v1")
  AssertEq%(rc%, HM_SUCCESS, "add returns SUCCESS")
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

AssertTrue(HmIterNext(m), "iter 1")
AssertEqStr(HmIterKey$(m), "first", "key 1 = first")

AssertTrue(HmIterNext(m), "iter 2")
AssertEqStr(HmIterKey$(m), "second", "key 2 = second")

AssertTrue(HmIterNext(m), "iter 3")
AssertEqStr(HmIterKey$(m), "third", "key 3 = third")

AssertEq%(HmIterNext(m), 0, "iter done")
HmFree(m)
FREE map&

{* ============== Test 7: Empty builder ============== *}

PRINT "-- Test 7: Empty builder"
HmNew(HM_SMALL)
map& = HmEnd
AssertTrue(map& <> 0, "empty builder returns nonzero")

m = map&
AssertEq&(HmCount(m), 0, "empty count = 0")
HmFree(m)
FREE map&

{* ============== Summary ============== *}

PRINT
PRINT "Builder tests:"; _passed; " passed,"; _failed; " failed"
IF _failed = 0 THEN PRINT "ALL PASSED"
