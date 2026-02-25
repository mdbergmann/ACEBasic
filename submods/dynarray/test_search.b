REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/testkit/testkit.o

{*
** DynArray Phase 4: Search & Mutate Tests
** Tests IndexOf$/&, Contains$/&, Reverse.
*}

#include <submods/dynarray.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== DynArray Phase 4: Search & Mutate Tests ==="
PRINT

TkInit

SHORTINT rc%

{* --- Test 1: IndexOf$ --- *}
PRINT "--- IndexOf$ ---"
DECLARE CLASS DynArray da
DaMake(da, DA_SMALL)

rc% = DaAppend$(da, "apple")
rc% = DaAppend$(da, "banana")
rc% = DaAppend$(da, "cherry")

TkAssertEq&(DaIndexOf$(da, "apple"), 0, "indexOf apple = 0")
TkAssertEq&(DaIndexOf$(da, "banana"), 1, "indexOf banana = 1")
TkAssertEq&(DaIndexOf$(da, "cherry"), 2, "indexOf cherry = 2")
TkAssertEq&(DaIndexOf$(da, "missing"), -1, "indexOf missing = -1")
TkAssertEq&(DaIndexOf$(da, ""), -1, "indexOf empty = -1")

DaFree(da)

{* --- Test 2: IndexOf& --- *}
PRINT "--- IndexOf& ---"
DECLARE CLASS DynArray di
DaMake(di, DA_SMALL)

rc% = DaAppend&(di, 10)
rc% = DaAppend&(di, 20)
rc% = DaAppend&(di, 30)

TkAssertEq&(DaIndexOf&(di, 10), 0, "indexOf& 10 = 0")
TkAssertEq&(DaIndexOf&(di, 20), 1, "indexOf& 20 = 1")
TkAssertEq&(DaIndexOf&(di, 30), 2, "indexOf& 30 = 2")
TkAssertEq&(DaIndexOf&(di, 99), -1, "indexOf& 99 = -1")

DaFree(di)

{* --- Test 3: IndexOf& ignores non-LONGINT types --- *}
PRINT "--- IndexOf& type check ---"
DECLARE CLASS DynArray dt
DaMake(dt, DA_SMALL)

rc% = DaAppend$(dt, "42")
rc% = DaAppend&(dt, 42)

' The string "42" should not match IndexOf& 42
TkAssertEq&(DaIndexOf&(dt, 42), 1, "indexOf& skips str type")

DaFree(dt)

{* --- Test 4: Contains$ --- *}
PRINT "--- Contains$ ---"
DECLARE CLASS DynArray dc
DaMake(dc, DA_SMALL)

rc% = DaAppend$(dc, "red")
rc% = DaAppend$(dc, "green")
rc% = DaAppend$(dc, "blue")

TkAssertTrue(DaContains$(dc, "red"), "contains red")
TkAssertTrue(DaContains$(dc, "green"), "contains green")
TkAssertTrue(DaContains$(dc, "blue"), "contains blue")
TkAssertFalse(DaContains$(dc, "yellow"), "not contains yellow")

DaFree(dc)

{* --- Test 5: Contains& --- *}
PRINT "--- Contains& ---"
DECLARE CLASS DynArray cl
DaMake(cl, DA_SMALL)

rc% = DaAppend&(cl, 100)
rc% = DaAppend&(cl, 200)

TkAssertTrue(DaContains&(cl, 100), "contains& 100")
TkAssertTrue(DaContains&(cl, 200), "contains& 200")
TkAssertFalse(DaContains&(cl, 300), "not contains& 300")

DaFree(cl)

{* --- Test 6: Reverse strings --- *}
PRINT "--- Reverse strings ---"
DECLARE CLASS DynArray rv
DaMake(rv, DA_SMALL)

rc% = DaAppend$(rv, "a")
rc% = DaAppend$(rv, "b")
rc% = DaAppend$(rv, "c")
rc% = DaAppend$(rv, "d")

DaReverse(rv)

TkAssertEqStr(DaGet$(rv, 0), "d", "rev 0 = d")
TkAssertEqStr(DaGet$(rv, 1), "c", "rev 1 = c")
TkAssertEqStr(DaGet$(rv, 2), "b", "rev 2 = b")
TkAssertEqStr(DaGet$(rv, 3), "a", "rev 3 = a")

DaFree(rv)

{* --- Test 7: Reverse odd count --- *}
PRINT "--- Reverse odd count ---"
DECLARE CLASS DynArray ro
DaMake(ro, DA_SMALL)

rc% = DaAppend$(ro, "x")
rc% = DaAppend$(ro, "y")
rc% = DaAppend$(ro, "z")

DaReverse(ro)

TkAssertEqStr(DaGet$(ro, 0), "z", "rev odd 0 = z")
TkAssertEqStr(DaGet$(ro, 1), "y", "rev odd 1 = y")
TkAssertEqStr(DaGet$(ro, 2), "x", "rev odd 2 = x")

DaFree(ro)

{* --- Test 8: Reverse mixed types --- *}
PRINT "--- Reverse mixed ---"
DECLARE CLASS DynArray rm
DaMake(rm, DA_SMALL)

rc% = DaAppend$(rm, "first")
rc% = DaAppend&(rm, 42)
rc% = DaAppendNull(rm)

DaReverse(rm)

TkAssertEq%(DaType(rm, 0), DaTypeNull, "rev mixed 0 type = null")
TkAssertEq%(DaType(rm, 1), DaTypeLng, "rev mixed 1 type = lng")
TkAssertEq&(DaGet&(rm, 1), 42, "rev mixed 1 val = 42")
TkAssertEq%(DaType(rm, 2), DaTypeStr, "rev mixed 2 type = str")
TkAssertEqStr(DaGet$(rm, 2), "first", "rev mixed 2 val = first")

DaFree(rm)

{* --- Test 9: Reverse single and empty --- *}
PRINT "--- Reverse edge cases ---"
DECLARE CLASS DynArray r1
DaMake(r1, DA_SMALL)
rc% = DaAppend$(r1, "only")
DaReverse(r1)
TkAssertEqStr(DaGet$(r1, 0), "only", "rev single = only")
DaFree(r1)

DECLARE CLASS DynArray r0
DaMake(r0, DA_SMALL)
DaReverse(r0)
TkAssertEq&(DaCount(r0), 0, "rev empty count = 0")
DaFree(r0)

{* --- Test 10: IndexOf$ with duplicates --- *}
PRINT "--- IndexOf$ duplicates ---"
DECLARE CLASS DynArray dd
DaMake(dd, DA_SMALL)

rc% = DaAppend$(dd, "dup")
rc% = DaAppend$(dd, "other")
rc% = DaAppend$(dd, "dup")

TkAssertEq&(DaIndexOf$(dd, "dup"), 0, "indexOf first dup = 0")

DaFree(dd)

{* ============== Summary ============== *}
TkSummary
