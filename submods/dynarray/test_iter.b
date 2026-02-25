REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/testkit/testkit.o

{*
** DynArray Phase 2: Iteration Tests
** Tests IterReset/Next/Idx/Val*/Type, empty iteration,
** iteration after remove, mixed types iteration.
*}

#include <submods/dynarray.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== DynArray Phase 2: Iteration Tests ==="
PRINT

TkInit

SHORTINT rc%

{* --- Test 1: Iterate over strings --- *}
PRINT "--- Iterate strings ---"
DECLARE CLASS DynArray da
DaMake(da, DA_SMALL)

rc% = DaAppend$(da, "alpha")
rc% = DaAppend$(da, "beta")
rc% = DaAppend$(da, "gamma")

DaIterReset(da)
SHORTINT hasNext%

hasNext% = DaIterNext(da)
TkAssertTrue(hasNext%, "iter 1 has next")
TkAssertEq&(DaIterIdx(da), 0, "iter 1 idx = 0")
TkAssertEqStr(DaIterVal$(da), "alpha", "iter 1 val = alpha")

hasNext% = DaIterNext(da)
TkAssertTrue(hasNext%, "iter 2 has next")
TkAssertEq&(DaIterIdx(da), 1, "iter 2 idx = 1")
TkAssertEqStr(DaIterVal$(da), "beta", "iter 2 val = beta")

hasNext% = DaIterNext(da)
TkAssertTrue(hasNext%, "iter 3 has next")
TkAssertEq&(DaIterIdx(da), 2, "iter 3 idx = 2")
TkAssertEqStr(DaIterVal$(da), "gamma", "iter 3 val = gamma")

hasNext% = DaIterNext(da)
TkAssertFalse(hasNext%, "iter 4 no more")

DaFree(da)

{* --- Test 2: Empty iteration --- *}
PRINT "--- Empty iteration ---"
DECLARE CLASS DynArray de
DaMake(de, DA_SMALL)

DaIterReset(de)
hasNext% = DaIterNext(de)
TkAssertFalse(hasNext%, "empty iter returns false")

DaFree(de)

{* --- Test 3: Iterate mixed types --- *}
PRINT "--- Mixed types iteration ---"
DECLARE CLASS DynArray dm
DaMake(dm, DA_SMALL)

rc% = DaAppend$(dm, "text")
rc% = DaAppend&(dm, 42)
rc% = DaAppend!(dm, 3.14)
rc% = DaAppendRef(dm, 9999)
rc% = DaAppendBool(dm, -1)
rc% = DaAppendNull(dm)

DaIterReset(dm)

' Element 0: string
hasNext% = DaIterNext(dm)
TkAssertTrue(hasNext%, "mixed iter 0 has next")
TkAssertEq%(DaIterType(dm), DaTypeStr, "mixed iter 0 type = str")
TkAssertEqStr(DaIterVal$(dm), "text", "mixed iter 0 val = text")

' Element 1: longint
hasNext% = DaIterNext(dm)
TkAssertTrue(hasNext%, "mixed iter 1 has next")
TkAssertEq%(DaIterType(dm), DaTypeLng, "mixed iter 1 type = lng")
TkAssertEq&(DaIterVal&(dm), 42, "mixed iter 1 val = 42")

' Element 2: single
hasNext% = DaIterNext(dm)
TkAssertTrue(hasNext%, "mixed iter 2 has next")
TkAssertEq%(DaIterType(dm), DaTypeSng, "mixed iter 2 type = sng")
TkAssertEqFloat(DaIterVal!(dm), 3.14, "mixed iter 2 val = 3.14")

' Element 3: ref
hasNext% = DaIterNext(dm)
TkAssertTrue(hasNext%, "mixed iter 3 has next")
TkAssertEq%(DaIterType(dm), DaTypeRef, "mixed iter 3 type = ref")
TkAssertEq&(DaIterRef(dm), 9999, "mixed iter 3 val = 9999")

' Element 4: bool
hasNext% = DaIterNext(dm)
TkAssertTrue(hasNext%, "mixed iter 4 has next")
TkAssertEq%(DaIterType(dm), DaTypeBool, "mixed iter 4 type = bool")
TkAssertEq&(DaIterVal&(dm), 1, "mixed iter 4 val = 1")

' Element 5: null
hasNext% = DaIterNext(dm)
TkAssertTrue(hasNext%, "mixed iter 5 has next")
TkAssertEq%(DaIterType(dm), DaTypeNull, "mixed iter 5 type = null")

' End
hasNext% = DaIterNext(dm)
TkAssertFalse(hasNext%, "mixed iter end")

DaFree(dm)

{* --- Test 4: Iterator reset and re-iterate --- *}
PRINT "--- Reset and re-iterate ---"
DECLARE CLASS DynArray dr
DaMake(dr, DA_SMALL)

rc% = DaAppend$(dr, "one")
rc% = DaAppend$(dr, "two")

' First pass
DaIterReset(dr)
hasNext% = DaIterNext(dr)
TkAssertEqStr(DaIterVal$(dr), "one", "pass1: val = one")
hasNext% = DaIterNext(dr)
TkAssertEqStr(DaIterVal$(dr), "two", "pass1: val = two")
hasNext% = DaIterNext(dr)
TkAssertFalse(hasNext%, "pass1: end")

' Reset and second pass
DaIterReset(dr)
hasNext% = DaIterNext(dr)
TkAssertTrue(hasNext%, "pass2: has next after reset")
TkAssertEqStr(DaIterVal$(dr), "one", "pass2: val = one")
hasNext% = DaIterNext(dr)
TkAssertEqStr(DaIterVal$(dr), "two", "pass2: val = two")
hasNext% = DaIterNext(dr)
TkAssertFalse(hasNext%, "pass2: end")

DaFree(dr)

{* --- Test 5: Iterate after remove --- *}
PRINT "--- Iterate after remove ---"
DECLARE CLASS DynArray dx
DaMake(dx, DA_SMALL)

rc% = DaAppend$(dx, "a")
rc% = DaAppend$(dx, "b")
rc% = DaAppend$(dx, "c")

' Remove middle element
rc% = DaRemove(dx, 1)

' Iterate: should see "a", "c"
DaIterReset(dx)
hasNext% = DaIterNext(dx)
TkAssertTrue(hasNext%, "after remove: iter 0 has next")
TkAssertEqStr(DaIterVal$(dx), "a", "after remove: val = a")

hasNext% = DaIterNext(dx)
TkAssertTrue(hasNext%, "after remove: iter 1 has next")
TkAssertEqStr(DaIterVal$(dx), "c", "after remove: val = c")

hasNext% = DaIterNext(dx)
TkAssertFalse(hasNext%, "after remove: end")

DaFree(dx)

{* --- Test 6: Single element iteration --- *}
PRINT "--- Single element ---"
DECLARE CLASS DynArray ds
DaMake(ds, DA_SMALL)

rc% = DaAppend&(ds, 777)

DaIterReset(ds)
hasNext% = DaIterNext(ds)
TkAssertTrue(hasNext%, "single: has next")
TkAssertEq&(DaIterVal&(ds), 777, "single: val = 777")
TkAssertEq&(DaIterIdx(ds), 0, "single: idx = 0")

hasNext% = DaIterNext(ds)
TkAssertFalse(hasNext%, "single: end")

DaFree(ds)

{* --- Test 7: Iterator guard on invalid cursor --- *}
PRINT "--- Guard: no reset ---"
DECLARE CLASS DynArray dg
DaMake(dg, DA_SMALL)
rc% = DaAppend$(dg, "test")

' DaMake sets cursor = -1, so DaIterNext should work from initial state
hasNext% = DaIterNext(dg)
TkAssertTrue(hasNext%, "no explicit reset: has next")
TkAssertEqStr(DaIterVal$(dg), "test", "no explicit reset: val")

DaFree(dg)

{* ============== Summary ============== *}
TkSummary
