REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/testkit/testkit.o

{*
** DynArray Phase 6: Sort Tests
** Tests DaSort with custom comparator, DaSortStr, DaSortLng,
** empty/single-element, reverse-sorted input, already sorted.
*}

#include <submods/dynarray.h>
#include <submods/testkit.h>

{* ============== Custom comparators for tests ============== *}

' Descending LONGINT comparator
SUB ADDRESS _CmpLngDesc(LONGINT rawA&, LONGINT rawB&, ~
    ADDRESS strPtrA, ADDRESS strPtrB, ~
    SHORTINT typA%, SHORTINT typB%) INVOKABLE
  IF rawA& > rawB& THEN
    _CmpLngDesc = -1
  ELSEIF rawA& < rawB& THEN
    _CmpLngDesc = 1
  ELSE
    _CmpLngDesc = 0
  END IF
END SUB

' Descending string comparator
SUB ADDRESS _CmpStrDesc(LONGINT rawA&, LONGINT rawB&, ~
    ADDRESS strPtrA, ADDRESS strPtrB, ~
    SHORTINT typA%, SHORTINT typB%) INVOKABLE
  STRING sa$, sb$
  sa$ = CSTR(strPtrA)
  sb$ = CSTR(strPtrB)
  IF sa$ > sb$ THEN
    _CmpStrDesc = -1
  ELSEIF sa$ < sb$ THEN
    _CmpStrDesc = 1
  ELSE
    _CmpStrDesc = 0
  END IF
END SUB

{* ============== Test Suite ============== *}

PRINT "=== DynArray Phase 6: Sort Tests ==="
PRINT

TkInit

SHORTINT rc%

{* --- Test 1: SortLng ascending --- *}
PRINT "--- SortLng ascending ---"
DECLARE CLASS DynArray da
DaMake(da, DA_SMALL)

rc% = DaAppend&(da, 50)
rc% = DaAppend&(da, 10)
rc% = DaAppend&(da, 40)
rc% = DaAppend&(da, 20)
rc% = DaAppend&(da, 30)

DaSortLng(da)

TkAssertEq&(DaGet&(da, 0), 10, "sortLng 0 = 10")
TkAssertEq&(DaGet&(da, 1), 20, "sortLng 1 = 20")
TkAssertEq&(DaGet&(da, 2), 30, "sortLng 2 = 30")
TkAssertEq&(DaGet&(da, 3), 40, "sortLng 3 = 40")
TkAssertEq&(DaGet&(da, 4), 50, "sortLng 4 = 50")

DaFree(da)

{* --- Test 2: SortStr ascending --- *}
PRINT "--- SortStr ascending ---"
DECLARE CLASS DynArray ds
DaMake(ds, DA_SMALL)

rc% = DaAppend$(ds, "cherry")
rc% = DaAppend$(ds, "apple")
rc% = DaAppend$(ds, "banana")
rc% = DaAppend$(ds, "date")

DaSortStr(ds)

TkAssertEqStr(DaGet$(ds, 0), "apple", "sortStr 0 = apple")
TkAssertEqStr(DaGet$(ds, 1), "banana", "sortStr 1 = banana")
TkAssertEqStr(DaGet$(ds, 2), "cherry", "sortStr 2 = cherry")
TkAssertEqStr(DaGet$(ds, 3), "date", "sortStr 3 = date")

DaFree(ds)

{* --- Test 3: Custom comparator descending LONGINT --- *}
PRINT "--- Sort descending LONGINT ---"
DECLARE CLASS DynArray dd
DaMake(dd, DA_SMALL)

rc% = DaAppend&(dd, 1)
rc% = DaAppend&(dd, 5)
rc% = DaAppend&(dd, 3)
rc% = DaAppend&(dd, 2)
rc% = DaAppend&(dd, 4)

DaSort(dd, BIND(@_CmpLngDesc))

TkAssertEq&(DaGet&(dd, 0), 5, "desc 0 = 5")
TkAssertEq&(DaGet&(dd, 1), 4, "desc 1 = 4")
TkAssertEq&(DaGet&(dd, 2), 3, "desc 2 = 3")
TkAssertEq&(DaGet&(dd, 3), 2, "desc 3 = 2")
TkAssertEq&(DaGet&(dd, 4), 1, "desc 4 = 1")

DaFree(dd)

{* --- Test 4: Custom comparator descending string --- *}
PRINT "--- Sort descending string ---"
DECLARE CLASS DynArray sd
DaMake(sd, DA_SMALL)

rc% = DaAppend$(sd, "alpha")
rc% = DaAppend$(sd, "gamma")
rc% = DaAppend$(sd, "beta")

DaSort(sd, BIND(@_CmpStrDesc))

TkAssertEqStr(DaGet$(sd, 0), "gamma", "strDesc 0 = gamma")
TkAssertEqStr(DaGet$(sd, 1), "beta", "strDesc 1 = beta")
TkAssertEqStr(DaGet$(sd, 2), "alpha", "strDesc 2 = alpha")

DaFree(sd)

{* --- Test 5: Already sorted input --- *}
PRINT "--- Already sorted ---"
DECLARE CLASS DynArray sa
DaMake(sa, DA_SMALL)

rc% = DaAppend&(sa, 1)
rc% = DaAppend&(sa, 2)
rc% = DaAppend&(sa, 3)

DaSortLng(sa)

TkAssertEq&(DaGet&(sa, 0), 1, "already 0 = 1")
TkAssertEq&(DaGet&(sa, 1), 2, "already 1 = 2")
TkAssertEq&(DaGet&(sa, 2), 3, "already 2 = 3")

DaFree(sa)

{* --- Test 6: Reverse-sorted input --- *}
PRINT "--- Reverse sorted input ---"
DECLARE CLASS DynArray sr
DaMake(sr, DA_SMALL)

rc% = DaAppend&(sr, 5)
rc% = DaAppend&(sr, 4)
rc% = DaAppend&(sr, 3)
rc% = DaAppend&(sr, 2)
rc% = DaAppend&(sr, 1)

DaSortLng(sr)

TkAssertEq&(DaGet&(sr, 0), 1, "rev 0 = 1")
TkAssertEq&(DaGet&(sr, 1), 2, "rev 1 = 2")
TkAssertEq&(DaGet&(sr, 2), 3, "rev 2 = 3")
TkAssertEq&(DaGet&(sr, 3), 4, "rev 3 = 4")
TkAssertEq&(DaGet&(sr, 4), 5, "rev 4 = 5")

DaFree(sr)

{* --- Test 7: Single element and empty --- *}
PRINT "--- Edge cases ---"
DECLARE CLASS DynArray s1
DaMake(s1, DA_SMALL)
rc% = DaAppend&(s1, 42)
DaSortLng(s1)
TkAssertEq&(DaGet&(s1, 0), 42, "single sort = 42")
DaFree(s1)

DECLARE CLASS DynArray s0
DaMake(s0, DA_SMALL)
DaSortLng(s0)
TkAssertEq&(DaCount(s0), 0, "empty sort count = 0")
DaFree(s0)

{* --- Test 8: Duplicates --- *}
PRINT "--- Duplicates ---"
DECLARE CLASS DynArray dp
DaMake(dp, DA_SMALL)

rc% = DaAppend&(dp, 3)
rc% = DaAppend&(dp, 1)
rc% = DaAppend&(dp, 3)
rc% = DaAppend&(dp, 2)
rc% = DaAppend&(dp, 1)

DaSortLng(dp)

TkAssertEq&(DaGet&(dp, 0), 1, "dup 0 = 1")
TkAssertEq&(DaGet&(dp, 1), 1, "dup 1 = 1")
TkAssertEq&(DaGet&(dp, 2), 2, "dup 2 = 2")
TkAssertEq&(DaGet&(dp, 3), 3, "dup 3 = 3")
TkAssertEq&(DaGet&(dp, 4), 3, "dup 4 = 3")

DaFree(dp)

{* --- Test 9: Larger dataset (16 elements) --- *}
PRINT "--- Larger dataset ---"
DECLARE CLASS DynArray dl
DaMake(dl, DA_SMALL)

rc% = DaAppend&(dl, 88)
rc% = DaAppend&(dl, 12)
rc% = DaAppend&(dl, 55)
rc% = DaAppend&(dl, 3)
rc% = DaAppend&(dl, 77)
rc% = DaAppend&(dl, 44)
rc% = DaAppend&(dl, 99)
rc% = DaAppend&(dl, 21)
rc% = DaAppend&(dl, 66)
rc% = DaAppend&(dl, 8)
rc% = DaAppend&(dl, 33)
rc% = DaAppend&(dl, 71)
rc% = DaAppend&(dl, 15)
rc% = DaAppend&(dl, 42)
rc% = DaAppend&(dl, 1)
rc% = DaAppend&(dl, 50)

DaSortLng(dl)

TkAssertEq&(DaGet&(dl, 0), 1, "large 0 = 1")
TkAssertEq&(DaGet&(dl, 1), 3, "large 1 = 3")
TkAssertEq&(DaGet&(dl, 2), 8, "large 2 = 8")
TkAssertEq&(DaGet&(dl, 7), 42, "large 7 = 42")
TkAssertEq&(DaGet&(dl, 15), 99, "large 15 = 99")

DaFree(dl)

{* --- Test 10: Sort preserves type tags --- *}
PRINT "--- Type tag preservation ---"
DECLARE CLASS DynArray dt
DaMake(dt, DA_SMALL)

rc% = DaAppend&(dt, 30)
rc% = DaAppend&(dt, 10)
rc% = DaAppend&(dt, 20)

DaSortLng(dt)

TkAssertEq%(DaType(dt, 0), DaTypeLng, "sorted type 0 = lng")
TkAssertEq%(DaType(dt, 1), DaTypeLng, "sorted type 1 = lng")
TkAssertEq%(DaType(dt, 2), DaTypeLng, "sorted type 2 = lng")

DaFree(dt)

{* ============== Summary ============== *}
TkSummary
