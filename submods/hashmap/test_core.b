REM #using ace:submods/hashmap/hashmap.o

{*
** Hashmap Phase 1: Core Tests
** Tests put/get/has/del, collisions, tombstones,
** multiple instances, load factor, clear.
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

PRINT "=== Hashmap Phase 1: Core Tests ==="
PRINT

_passed = 0
_failed = 0

SHORTINT rc%

{* --- Test 1: Make and Capacity --- *}
PRINT "--- Make / Capacity ---"
DECLARE CLASS Hashmap m
HmMake(m, HM_SMALL)
AssertEq&(HmCapacity(m), 32, "capacity should be 32")
AssertEq&(HmCount(m), 0, "initial count should be 0")

{* --- Test 2: Put and Get strings --- *}
PRINT "--- Put / Get ---"
rc% = HmPut$(m, "name", "Alice")
AssertEq%(rc%, 0, "put name should succeed")
AssertEqStr(HmGet$(m, "name"), "Alice", "get name")

rc% = HmPut$(m, "city", "Berlin")
AssertEq%(rc%, 0, "put city should succeed")
AssertEqStr(HmGet$(m, "city"), "Berlin", "get city")

AssertEq&(HmCount(m), 2, "count after 2 puts")

{* --- Test 3: Get nonexistent key --- *}
PRINT "--- Get missing ---"
AssertEqStr(HmGet$(m, "missing"), "", "get missing returns empty")

{* --- Test 4: Update existing key --- *}
PRINT "--- Update ---"
rc% = HmPut$(m, "name", "Bob")
AssertEq%(rc%, 0, "update name should succeed")
AssertEqStr(HmGet$(m, "name"), "Bob", "get updated name")
AssertEq&(HmCount(m), 2, "count unchanged after update")

{* --- Test 5: Has --- *}
PRINT "--- Has ---"
AssertTrue(HmHas(m, "name"), "has name")
AssertTrue(HmHas(m, "city"), "has city")
AssertTrue(NOT HmHas(m, "missing"), "not has missing")

{* --- Test 6: Delete --- *}
PRINT "--- Delete ---"
rc% = HmDel(m, "city")
AssertEq%(rc%, 0, "del city should succeed")
AssertTrue(NOT HmHas(m, "city"), "city gone after del")
AssertEqStr(HmGet$(m, "city"), "", "get deleted city returns empty")
AssertEq&(HmCount(m), 1, "count after delete")

rc% = HmDel(m, "nonexistent")
AssertEq%(rc%, -2, "del nonexistent returns NOT_FOUND")

{* --- Test 7: Reinsert after delete (tombstone reuse) --- *}
PRINT "--- Tombstone reuse ---"
rc% = HmPut$(m, "city", "Paris")
AssertEq%(rc%, 0, "reinsert city should succeed")
AssertEqStr(HmGet$(m, "city"), "Paris", "get reinserted city")
AssertEq&(HmCount(m), 2, "count after reinsert")

{* --- Test 8: Many keys (collision handling) --- *}
PRINT "--- Collisions ---"
HmClear(m)
SHORTINT i%, allOk%
STRING kk$

FOR i% = 0 TO 19
  kk$ = "key" + LTRIM$(STR$(i%))
  rc% = HmPut$(m, kk$, "val" + LTRIM$(STR$(i%)))
  IF rc% <> 0 THEN
    PRINT "FAIL: put "; kk$; " returned"; rc%
    _failed = _failed + 1
  END IF
NEXT
AssertEq&(HmCount(m), 20, "count after 20 inserts")

' Verify all 20 keys
allOk% = -1
FOR i% = 0 TO 19
  kk$ = "key" + LTRIM$(STR$(i%))
  IF HmGet$(m, kk$) <> "val" + LTRIM$(STR$(i%)) THEN
    PRINT "FAIL: get "; kk$; " wrong value"
    allOk% = 0
  END IF
NEXT
IF allOk% THEN
  _passed = _passed + 1
ELSE
  _failed = _failed + 1
END IF

{* --- Test 9: Delete then lookup across probe chain --- *}
PRINT "--- Delete in probe chain ---"
' Delete a middle key, verify others still found
rc% = HmDel(m, "key5")
AssertEq%(rc%, 0, "del key5 should succeed")
AssertTrue(NOT HmHas(m, "key5"), "key5 gone")
AssertTrue(HmHas(m, "key4"), "key4 still found")
AssertTrue(HmHas(m, "key6"), "key6 still found")
AssertTrue(HmHas(m, "key0"), "key0 still found")
AssertTrue(HmHas(m, "key19"), "key19 still found")

{* --- Test 10: Load factor limit --- *}
PRINT "--- Load factor ---"
HmFree(m)

DECLARE CLASS Hashmap sm
HmMake(sm, HM_SMALL)
FOR i% = 0 TO 21
  kk$ = "k" + LTRIM$(STR$(i%))
  rc% = HmPut$(sm, kk$, "v")
NEXT
AssertEq&(HmCount(sm), 22, "22 entries at max load")

rc% = HmPut$(sm, "overflow", "v")
AssertEq%(rc%, -1, "23rd insert should return ERR_FULL")
AssertEq&(HmCount(sm), 22, "count still 22 after failed insert")

' Update existing at full load should still work
rc% = HmPut$(sm, "k0", "updated")
AssertEq%(rc%, 0, "update at full load should succeed")
AssertEqStr(HmGet$(sm, "k0"), "updated", "updated value at full load")
HmFree(sm)

{* --- Test 11: Multiple independent instances --- *}
PRINT "--- Independent instances ---"
DECLARE CLASS Hashmap m1
DECLARE CLASS Hashmap m2
HmMake(m1, HM_SMALL)
HmMake(m2, HM_SMALL)

rc% = HmPut$(m1, "x", "one")
rc% = HmPut$(m2, "x", "two")

AssertEqStr(HmGet$(m1, "x"), "one", "m1 x is one")
AssertEqStr(HmGet$(m2, "x"), "two", "m2 x is two")

rc% = HmDel(m1, "x")
AssertTrue(NOT HmHas(m1, "x"), "m1 x deleted")
AssertTrue(HmHas(m2, "x"), "m2 x still exists")

HmFree(m1)
HmFree(m2)

{* --- Test 12: Clear --- *}
PRINT "--- Clear ---"
DECLARE CLASS Hashmap mc
HmMake(mc, HM_SMALL)
rc% = HmPut$(mc, "a", "1")
rc% = HmPut$(mc, "b", "2")
HmClear(mc)
AssertEq&(HmCount(mc), 0, "count 0 after clear")
AssertTrue(NOT HmHas(mc, "a"), "a gone after clear")
AssertTrue(NOT HmHas(mc, "b"), "b gone after clear")

' Can reuse after clear
rc% = HmPut$(mc, "c", "3")
AssertEqStr(HmGet$(mc, "c"), "3", "get c after clear+put")
HmFree(mc)

{* --- Test 13: Empty string key and value --- *}
PRINT "--- Edge cases ---"
DECLARE CLASS Hashmap me
HmMake(me, HM_SMALL)
rc% = HmPut$(me, "", "empty key")
AssertEq%(rc%, 0, "put empty key should succeed")
AssertEqStr(HmGet$(me, ""), "empty key", "get empty key")
AssertTrue(HmHas(me, ""), "has empty key")

rc% = HmPut$(me, "blank", "")
AssertEq%(rc%, 0, "put empty value should succeed")
AssertEqStr(HmGet$(me, "blank"), "", "get empty value")
AssertTrue(HmHas(me, "blank"), "has blank key with empty value")
HmFree(me)

{* ============== Summary ============== *}
PRINT
PRINT "Results:"; _passed; " passed,"; _failed; " failed"
IF _failed > 0 THEN
  PRINT "ASSERT FAILED: Some tests failed"
END IF
