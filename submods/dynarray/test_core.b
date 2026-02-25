REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/testkit/testkit.o

{*
** DynArray Phase 1: Core Tests
** Tests Make/Free/Clear, all Append/Get/Set variants,
** Type, Remove, Count, Capacity, auto-grow.
*}

#include <submods/dynarray.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== DynArray Phase 1: Core Tests ==="
PRINT

TkInit

SHORTINT rc%

{* --- Test 1: Make and Capacity --- *}
PRINT "--- Make / Capacity ---"
DECLARE CLASS DynArray da
DaMake(da, DA_SMALL)
TkAssertEq&(DaCapacity(da), 16, "capacity should be 16")
TkAssertEq&(DaCount(da), 0, "initial count should be 0")

{* --- Test 2: Append and Get strings --- *}
PRINT "--- Append$ / Get$ ---"
rc% = DaAppend$(da, "hello")
TkAssertEq%(rc%, 0, "append hello should succeed")
TkAssertEqStr(DaGet$(da, 0), "hello", "get 0 = hello")

rc% = DaAppend$(da, "world")
TkAssertEq%(rc%, 0, "append world should succeed")
TkAssertEqStr(DaGet$(da, 1), "world", "get 1 = world")

TkAssertEq&(DaCount(da), 2, "count after 2 appends")

{* --- Test 3: Get out of bounds --- *}
PRINT "--- Get OOB ---"
TkAssertEqStr(DaGet$(da, -1), "", "get -1 returns empty")
TkAssertEqStr(DaGet$(da, 99), "", "get 99 returns empty")
TkAssertEq&(DaGet&(da, 99), 0, "get& OOB returns 0")

{* --- Test 4: Append and Get LONGINT --- *}
PRINT "--- Append& / Get& ---"
rc% = DaAppend&(da, 42)
TkAssertEq%(rc%, 0, "append& 42 should succeed")
TkAssertEq&(DaGet&(da, 2), 42, "get& 2 = 42")
TkAssertEq&(DaCount(da), 3, "count after 3 appends")

{* --- Test 5: Append and Get SINGLE --- *}
PRINT "--- Append! / Get! ---"
rc% = DaAppend!(da, 3.14)
TkAssertEq%(rc%, 0, "append! 3.14 should succeed")
TkAssertEqFloat(DaGet!(da, 3), 3.14, "get! 3 = 3.14")

{* --- Test 6: Append and Get Ref --- *}
PRINT "--- AppendRef / GetRef ---"
LONGINT someAddr&
someAddr& = 12345678
rc% = DaAppendRef(da, someAddr&)
TkAssertEq%(rc%, 0, "appendRef should succeed")
TkAssertEq&(DaGetRef(da, 4), 12345678, "getRef 4 = 12345678")

{* --- Test 7: Append Bool and Null --- *}
PRINT "--- AppendBool / AppendNull ---"
rc% = DaAppendBool(da, -1)
TkAssertEq%(rc%, 0, "appendBool should succeed")
TkAssertEq&(DaGet&(da, 5), 1, "get& bool slot = 1")

rc% = DaAppendNull(da)
TkAssertEq%(rc%, 0, "appendNull should succeed")
TkAssertEq&(DaCount(da), 7, "count after 7 appends")

{* --- Test 8: Type query --- *}
PRINT "--- Type ---"
TkAssertEq%(DaType(da, 0), DaTypeStr, "type 0 = str")
TkAssertEq%(DaType(da, 1), DaTypeStr, "type 1 = str")
TkAssertEq%(DaType(da, 2), DaTypeLng, "type 2 = lng")
TkAssertEq%(DaType(da, 3), DaTypeSng, "type 3 = sng")
TkAssertEq%(DaType(da, 4), DaTypeRef, "type 4 = ref")
TkAssertEq%(DaType(da, 5), DaTypeBool, "type 5 = bool")
TkAssertEq%(DaType(da, 6), DaTypeNull, "type 6 = null")
TkAssertEq%(DaType(da, 99), -1, "type OOB = -1")

{* --- Test 9: Set variants --- *}
PRINT "--- Set ---"
rc% = DaSet$(da, 0, "updated")
TkAssertEq%(rc%, 0, "set$ should succeed")
TkAssertEqStr(DaGet$(da, 0), "updated", "get after set$")

rc% = DaSet&(da, 2, 99)
TkAssertEq%(rc%, 0, "set& should succeed")
TkAssertEq&(DaGet&(da, 2), 99, "get& after set&")

rc% = DaSet!(da, 3, 2.718)
TkAssertEq%(rc%, 0, "set! should succeed")
TkAssertEqFloat(DaGet!(da, 3), 2.718, "get! after set!")

rc% = DaSetRef(da, 4, 87654321)
TkAssertEq%(rc%, 0, "setRef should succeed")
TkAssertEq&(DaGetRef(da, 4), 87654321, "getRef after setRef")

rc% = DaSetBool(da, 5, 0)
TkAssertEq%(rc%, 0, "setBool should succeed")
TkAssertEq&(DaGet&(da, 5), 0, "get& after setBool 0")

rc% = DaSetNull(da, 2)
TkAssertEq%(rc%, 0, "setNull should succeed")
TkAssertEq%(DaType(da, 2), DaTypeNull, "type after setNull")

' Set OOB should fail
rc% = DaSet$(da, 99, "oob")
TkAssertEq%(rc%, DA_ERR_BOUNDS, "set$ OOB returns ERR_BOUNDS")

{* --- Test 10: Remove --- *}
PRINT "--- Remove ---"
DaFree(da)
DECLARE CLASS DynArray dr
DaMake(dr, DA_SMALL)

rc% = DaAppend$(dr, "a")
rc% = DaAppend$(dr, "b")
rc% = DaAppend$(dr, "c")
rc% = DaAppend$(dr, "d")
TkAssertEq&(DaCount(dr), 4, "count before remove")

' Remove "b" at index 1
rc% = DaRemove(dr, 1)
TkAssertEq%(rc%, 0, "remove 1 should succeed")
TkAssertEq&(DaCount(dr), 3, "count after remove")
TkAssertEqStr(DaGet$(dr, 0), "a", "after remove: 0=a")
TkAssertEqStr(DaGet$(dr, 1), "c", "after remove: 1=c")
TkAssertEqStr(DaGet$(dr, 2), "d", "after remove: 2=d")

' Remove first element
rc% = DaRemove(dr, 0)
TkAssertEq%(rc%, 0, "remove 0 should succeed")
TkAssertEq&(DaCount(dr), 2, "count after remove first")
TkAssertEqStr(DaGet$(dr, 0), "c", "after remove first: 0=c")
TkAssertEqStr(DaGet$(dr, 1), "d", "after remove first: 1=d")

' Remove last element
rc% = DaRemove(dr, 1)
TkAssertEq%(rc%, 0, "remove last should succeed")
TkAssertEq&(DaCount(dr), 1, "count after remove last")
TkAssertEqStr(DaGet$(dr, 0), "c", "after remove last: 0=c")

' Remove OOB
rc% = DaRemove(dr, 5)
TkAssertEq%(rc%, DA_ERR_BOUNDS, "remove OOB returns ERR_BOUNDS")

DaFree(dr)

{* --- Test 11: Auto-grow --- *}
PRINT "--- Auto-grow ---"
DECLARE CLASS DynArray dg
DaMake(dg, 4)
TkAssertEq&(DaCapacity(dg), 4, "initial cap 4")

SHORTINT gi%
STRING gk$

FOR gi% = 0 TO 3
  gk$ = "item" + LTRIM$(STR$(gi%))
  rc% = DaAppend$(dg, gk$)
  TkAssertEq%(rc%, 0, "append " + gk$)
NEXT
TkAssertEq&(DaCount(dg), 4, "count at cap")
TkAssertEq&(DaCapacity(dg), 4, "cap still 4")

' This append should trigger auto-grow
rc% = DaAppend$(dg, "item4")
TkAssertEq%(rc%, 0, "append past cap should succeed")
TkAssertEq&(DaCount(dg), 5, "count after grow")
TkAssertEq&(DaCapacity(dg), 8, "cap doubled to 8")

' Verify old data survived grow
TkAssertEqStr(DaGet$(dg, 0), "item0", "after grow: 0=item0")
TkAssertEqStr(DaGet$(dg, 1), "item1", "after grow: 1=item1")
TkAssertEqStr(DaGet$(dg, 2), "item2", "after grow: 2=item2")
TkAssertEqStr(DaGet$(dg, 3), "item3", "after grow: 3=item3")
TkAssertEqStr(DaGet$(dg, 4), "item4", "after grow: 4=item4")

DaFree(dg)

{* --- Test 12: Clear --- *}
PRINT "--- Clear ---"
DECLARE CLASS DynArray dc
DaMake(dc, DA_SMALL)
rc% = DaAppend$(dc, "x")
rc% = DaAppend$(dc, "y")
DaClear(dc)
TkAssertEq&(DaCount(dc), 0, "count 0 after clear")
TkAssertEqStr(DaGet$(dc, 0), "", "get 0 OOB after clear")

' Can reuse after clear
rc% = DaAppend$(dc, "z")
TkAssertEqStr(DaGet$(dc, 0), "z", "get 0 after clear+append")
TkAssertEq&(DaCount(dc), 1, "count 1 after clear+append")
DaFree(dc)

{* --- Test 13: Multiple independent instances --- *}
PRINT "--- Independent instances ---"
DECLARE CLASS DynArray d1
DECLARE CLASS DynArray d2
DaMake(d1, DA_SMALL)
DaMake(d2, DA_SMALL)

rc% = DaAppend$(d1, "one")
rc% = DaAppend$(d2, "two")

TkAssertEqStr(DaGet$(d1, 0), "one", "d1 has one")
TkAssertEqStr(DaGet$(d2, 0), "two", "d2 has two")
TkAssertEq&(DaCount(d1), 1, "d1 count = 1")
TkAssertEq&(DaCount(d2), 1, "d2 count = 1")

rc% = DaRemove(d1, 0)
TkAssertEq&(DaCount(d1), 0, "d1 count 0 after remove")
TkAssertEq&(DaCount(d2), 1, "d2 count still 1")

DaFree(d1)
DaFree(d2)

{* --- Test 14: Mixed types in same array --- *}
PRINT "--- Mixed types ---"
DECLARE CLASS DynArray dm
DaMake(dm, DA_SMALL)

rc% = DaAppend$(dm, "text")
rc% = DaAppend&(dm, 100)
rc% = DaAppend!(dm, 1.5)
rc% = DaAppendRef(dm, 999)
rc% = DaAppendBool(dm, -1)
rc% = DaAppendNull(dm)

TkAssertEq&(DaCount(dm), 6, "mixed count = 6")
TkAssertEqStr(DaGet$(dm, 0), "text", "mixed: str")
TkAssertEq&(DaGet&(dm, 1), 100, "mixed: lng")
TkAssertEqFloat(DaGet!(dm, 2), 1.5, "mixed: sng")
TkAssertEq&(DaGetRef(dm, 3), 999, "mixed: ref")
TkAssertEq&(DaGet&(dm, 4), 1, "mixed: bool")
TkAssertEq%(DaType(dm, 5), DaTypeNull, "mixed: null type")

DaFree(dm)

{* --- Test 15: Empty string value --- *}
PRINT "--- Edge cases ---"
DECLARE CLASS DynArray de
DaMake(de, DA_SMALL)
rc% = DaAppend$(de, "")
TkAssertEq%(rc%, 0, "append empty string succeeds")
TkAssertEqStr(DaGet$(de, 0), "", "get empty string")
TkAssertEq%(DaType(de, 0), DaTypeStr, "type is str for empty")
TkAssertEq&(DaCount(de), 1, "count 1 after empty string")
DaFree(de)

{* ============== Summary ============== *}
TkSummary
