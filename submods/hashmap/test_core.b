REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/testkit/testkit.o

{*
** Hashmap Phase 1: Core Tests
** Tests put/get/has/del, collisions, tombstones,
** multiple instances, load factor, clear.
*}

#include <submods/hashmap.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== Hashmap Phase 1: Core Tests ==="
PRINT

TkInit

SHORTINT rc%

{* --- Test 1: Make and Capacity --- *}
PRINT "--- Make / Capacity ---"
DECLARE CLASS Hashmap m
HmMake(m, HM_SMALL)
TkAssertEq&(HmCapacity(m), 32, "capacity should be 32")
TkAssertEq&(HmCount(m), 0, "initial count should be 0")

{* --- Test 2: Put and Get strings --- *}
PRINT "--- Put / Get ---"
rc% = HmPut$(m, "name", "Alice")
TkAssertEq%(rc%, 0, "put name should succeed")
TkAssertEqStr(HmGet$(m, "name"), "Alice", "get name")

rc% = HmPut$(m, "city", "Berlin")
TkAssertEq%(rc%, 0, "put city should succeed")
TkAssertEqStr(HmGet$(m, "city"), "Berlin", "get city")

TkAssertEq&(HmCount(m), 2, "count after 2 puts")

{* --- Test 3: Get nonexistent key --- *}
PRINT "--- Get missing ---"
TkAssertEqStr(HmGet$(m, "missing"), "", "get missing returns empty")

{* --- Test 4: Update existing key --- *}
PRINT "--- Update ---"
rc% = HmPut$(m, "name", "Bob")
TkAssertEq%(rc%, 0, "update name should succeed")
TkAssertEqStr(HmGet$(m, "name"), "Bob", "get updated name")
TkAssertEq&(HmCount(m), 2, "count unchanged after update")

{* --- Test 5: Has --- *}
PRINT "--- Has ---"
TkAssertTrue(HmHas(m, "name"), "has name")
TkAssertTrue(HmHas(m, "city"), "has city")
TkAssertTrue(NOT HmHas(m, "missing"), "not has missing")

{* --- Test 6: Delete --- *}
PRINT "--- Delete ---"
rc% = HmDel(m, "city")
TkAssertEq%(rc%, 0, "del city should succeed")
TkAssertTrue(NOT HmHas(m, "city"), "city gone after del")
TkAssertEqStr(HmGet$(m, "city"), "", "get deleted city returns empty")
TkAssertEq&(HmCount(m), 1, "count after delete")

rc% = HmDel(m, "nonexistent")
TkAssertEq%(rc%, -2, "del nonexistent returns NOT_FOUND")

{* --- Test 7: Reinsert after delete (tombstone reuse) --- *}
PRINT "--- Tombstone reuse ---"
rc% = HmPut$(m, "city", "Paris")
TkAssertEq%(rc%, 0, "reinsert city should succeed")
TkAssertEqStr(HmGet$(m, "city"), "Paris", "get reinserted city")
TkAssertEq&(HmCount(m), 2, "count after reinsert")

{* --- Test 8: Many keys (collision handling) --- *}
PRINT "--- Collisions ---"
HmClear(m)
SHORTINT i%
STRING kk$

FOR i% = 0 TO 19
  kk$ = "key" + LTRIM$(STR$(i%))
  rc% = HmPut$(m, kk$, "val" + LTRIM$(STR$(i%)))
  TkAssertEq%(rc%, 0, "put " + kk$)
NEXT
TkAssertEq&(HmCount(m), 20, "count after 20 inserts")

' Verify all 20 keys
FOR i% = 0 TO 19
  kk$ = "key" + LTRIM$(STR$(i%))
  TkAssertEqStr(HmGet$(m, kk$), "val" + LTRIM$(STR$(i%)), "get " + kk$)
NEXT

{* --- Test 9: Delete then lookup across probe chain --- *}
PRINT "--- Delete in probe chain ---"
' Delete a middle key, verify others still found
rc% = HmDel(m, "key5")
TkAssertEq%(rc%, 0, "del key5 should succeed")
TkAssertTrue(NOT HmHas(m, "key5"), "key5 gone")
TkAssertTrue(HmHas(m, "key4"), "key4 still found")
TkAssertTrue(HmHas(m, "key6"), "key6 still found")
TkAssertTrue(HmHas(m, "key0"), "key0 still found")
TkAssertTrue(HmHas(m, "key19"), "key19 still found")

{* --- Test 10: Load factor limit --- *}
PRINT "--- Load factor ---"
HmFree(m)

DECLARE CLASS Hashmap sm
HmMake(sm, HM_SMALL)
FOR i% = 0 TO 21
  kk$ = "k" + LTRIM$(STR$(i%))
  rc% = HmPut$(sm, kk$, "v")
NEXT
TkAssertEq&(HmCount(sm), 22, "22 entries at max load")

rc% = HmPut$(sm, "overflow", "v")
TkAssertEq%(rc%, -1, "23rd insert should return ERR_FULL")
TkAssertEq&(HmCount(sm), 22, "count still 22 after failed insert")

' Update existing at full load should still work
rc% = HmPut$(sm, "k0", "updated")
TkAssertEq%(rc%, 0, "update at full load should succeed")
TkAssertEqStr(HmGet$(sm, "k0"), "updated", "updated value at full load")
HmFree(sm)

{* --- Test 11: Multiple independent instances --- *}
PRINT "--- Independent instances ---"
DECLARE CLASS Hashmap m1
DECLARE CLASS Hashmap m2
HmMake(m1, HM_SMALL)
HmMake(m2, HM_SMALL)

rc% = HmPut$(m1, "x", "one")
rc% = HmPut$(m2, "x", "two")

TkAssertEqStr(HmGet$(m1, "x"), "one", "m1 x is one")
TkAssertEqStr(HmGet$(m2, "x"), "two", "m2 x is two")

rc% = HmDel(m1, "x")
TkAssertTrue(NOT HmHas(m1, "x"), "m1 x deleted")
TkAssertTrue(HmHas(m2, "x"), "m2 x still exists")

HmFree(m1)
HmFree(m2)

{* --- Test 12: Clear --- *}
PRINT "--- Clear ---"
DECLARE CLASS Hashmap mc
HmMake(mc, HM_SMALL)
rc% = HmPut$(mc, "a", "1")
rc% = HmPut$(mc, "b", "2")
HmClear(mc)
TkAssertEq&(HmCount(mc), 0, "count 0 after clear")
TkAssertTrue(NOT HmHas(mc, "a"), "a gone after clear")
TkAssertTrue(NOT HmHas(mc, "b"), "b gone after clear")

' Can reuse after clear
rc% = HmPut$(mc, "c", "3")
TkAssertEqStr(HmGet$(mc, "c"), "3", "get c after clear+put")
HmFree(mc)

{* --- Test 13: Empty string key and value --- *}
PRINT "--- Edge cases ---"
DECLARE CLASS Hashmap me
HmMake(me, HM_SMALL)
rc% = HmPut$(me, "", "empty key")
TkAssertEq%(rc%, 0, "put empty key should succeed")
TkAssertEqStr(HmGet$(me, ""), "empty key", "get empty key")
TkAssertTrue(HmHas(me, ""), "has empty key")

rc% = HmPut$(me, "blank", "")
TkAssertEq%(rc%, 0, "put empty value should succeed")
TkAssertEqStr(HmGet$(me, "blank"), "", "get empty value")
TkAssertTrue(HmHas(me, "blank"), "has blank key with empty value")
HmFree(me)

{* ============== Summary ============== *}
TkSummary
