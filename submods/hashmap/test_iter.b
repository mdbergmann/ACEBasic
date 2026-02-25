REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/testkit/testkit.o

{*
** Hashmap Phase 3: Iteration Tests
** Tests insertion-order iteration, mixed types, iteration after
** deletes, tombstone reuse ordering, reset, independent instances.
*}

#include <submods/hashmap.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== Hashmap Phase 3: Iteration Tests ==="
PRINT

TkInit

SHORTINT rc%, ok%

{* --- Test 1: Basic insertion order --- *}
PRINT "--- Basic insertion order ---"
DECLARE CLASS Hashmap m1
HmMake(m1, HM_SMALL)

rc% = HmPut$(m1, "alpha", "A")
rc% = HmPut$(m1, "beta", "B")
rc% = HmPut$(m1, "gamma", "C")

HmIterReset(m1)

ok% = HmIterNext(m1)
TkAssertTrue(ok%, "iter1 has 1st")
TkAssertEqStr(HmIterKey$(m1), "alpha", "iter1 1st key")
TkAssertEqStr(HmIterVal$(m1), "A", "iter1 1st val")

ok% = HmIterNext(m1)
TkAssertTrue(ok%, "iter1 has 2nd")
TkAssertEqStr(HmIterKey$(m1), "beta", "iter1 2nd key")
TkAssertEqStr(HmIterVal$(m1), "B", "iter1 2nd val")

ok% = HmIterNext(m1)
TkAssertTrue(ok%, "iter1 has 3rd")
TkAssertEqStr(HmIterKey$(m1), "gamma", "iter1 3rd key")
TkAssertEqStr(HmIterVal$(m1), "C", "iter1 3rd val")

ok% = HmIterNext(m1)
TkAssertTrue(NOT ok%, "iter1 ends after 3")

HmFree(m1)

{* --- Test 2: Empty map iteration --- *}
PRINT "--- Empty map ---"
DECLARE CLASS Hashmap m2
HmMake(m2, HM_SMALL)

HmIterReset(m2)
ok% = HmIterNext(m2)
TkAssertTrue(NOT ok%, "empty map iter returns 0")

HmFree(m2)

{* --- Test 3: Iteration count matches HmCount --- *}
PRINT "--- Count match ---"
DECLARE CLASS Hashmap m3
HmMake(m3, HM_SMALL)

rc% = HmPut$(m3, "a", "1")
rc% = HmPut$(m3, "b", "2")
rc% = HmPut$(m3, "c", "3")
rc% = HmPut$(m3, "d", "4")
rc% = HmPut$(m3, "e", "5")

SHORTINT iterCnt%
iterCnt% = 0
HmIterReset(m3)
WHILE HmIterNext(m3)
  iterCnt% = iterCnt% + 1
WEND
TkAssertEq%(iterCnt%, 5, "iter count matches HmCount")

HmFree(m3)

{* --- Test 4: Iteration after delete --- *}
PRINT "--- After delete ---"
DECLARE CLASS Hashmap m4
HmMake(m4, HM_SMALL)

rc% = HmPut$(m4, "x", "1")
rc% = HmPut$(m4, "y", "2")
rc% = HmPut$(m4, "z", "3")

' Delete middle entry
rc% = HmDel(m4, "y")

HmIterReset(m4)

ok% = HmIterNext(m4)
TkAssertTrue(ok%, "del iter has 1st")
TkAssertEqStr(HmIterKey$(m4), "x", "del iter 1st key")

ok% = HmIterNext(m4)
TkAssertTrue(ok%, "del iter has 2nd")
TkAssertEqStr(HmIterKey$(m4), "z", "del iter 2nd key (y skipped)")

ok% = HmIterNext(m4)
TkAssertTrue(NOT ok%, "del iter ends after 2")

HmFree(m4)

{* --- Test 5: Delete first and last --- *}
PRINT "--- Delete first and last ---"
DECLARE CLASS Hashmap m5
HmMake(m5, HM_SMALL)

rc% = HmPut$(m5, "first", "1")
rc% = HmPut$(m5, "mid", "2")
rc% = HmPut$(m5, "last", "3")

rc% = HmDel(m5, "first")
rc% = HmDel(m5, "last")

HmIterReset(m5)
ok% = HmIterNext(m5)
TkAssertTrue(ok%, "del-fl has 1 entry")
TkAssertEqStr(HmIterKey$(m5), "mid", "del-fl only mid remains")
ok% = HmIterNext(m5)
TkAssertTrue(NOT ok%, "del-fl ends after 1")

HmFree(m5)

{* --- Test 6: Tombstone reuse preserves order --- *}
PRINT "--- Tombstone reuse order ---"
DECLARE CLASS Hashmap m6
HmMake(m6, HM_SMALL)

rc% = HmPut$(m6, "aa", "1")
rc% = HmPut$(m6, "bb", "2")
rc% = HmPut$(m6, "cc", "3")

' Delete bb, then insert dd (may reuse bb's slot)
rc% = HmDel(m6, "bb")
rc% = HmPut$(m6, "dd", "4")

' Expected order: aa, cc, dd (bb deleted, dd appended)
HmIterReset(m6)

ok% = HmIterNext(m6)
TkAssertEqStr(HmIterKey$(m6), "aa", "tomb order 1st = aa")
ok% = HmIterNext(m6)
TkAssertEqStr(HmIterKey$(m6), "cc", "tomb order 2nd = cc")
ok% = HmIterNext(m6)
TkAssertEqStr(HmIterKey$(m6), "dd", "tomb order 3rd = dd")
ok% = HmIterNext(m6)
TkAssertTrue(NOT ok%, "tomb order ends after 3")

HmFree(m6)

{* --- Test 7: Mixed types iteration --- *}
PRINT "--- Mixed types ---"
DECLARE CLASS Hashmap m7
HmMake(m7, HM_SMALL)

rc% = HmPut$(m7, "nm", "Alice")
rc% = HmPut&(m7, "ag", 30)
rc% = HmPut!(m7, "ht", 5.5)
rc% = HmPutBool(m7, "ok", -1)
rc% = HmPutNull(m7, "nn")

SINGLE testF!

HmIterReset(m7)

ok% = HmIterNext(m7)
TkAssertEqStr(HmIterKey$(m7), "nm", "mix iter 1st key")
TkAssertEq%(HmIterType(m7), HmTypeStr, "mix iter 1st type")
TkAssertEqStr(HmIterVal$(m7), "Alice", "mix iter 1st val")

ok% = HmIterNext(m7)
TkAssertEqStr(HmIterKey$(m7), "ag", "mix iter 2nd key")
TkAssertEq%(HmIterType(m7), HmTypeLng, "mix iter 2nd type")
TkAssertEq&(HmIterVal&(m7), 30, "mix iter 2nd val")

ok% = HmIterNext(m7)
TkAssertEqStr(HmIterKey$(m7), "ht", "mix iter 3rd key")
TkAssertEq%(HmIterType(m7), HmTypeSng, "mix iter 3rd type")
testF! = HmIterVal!(m7)
TkAssertTrue(testF! > 5.4 AND testF! < 5.6, "mix iter 3rd val ~5.5")

ok% = HmIterNext(m7)
TkAssertEqStr(HmIterKey$(m7), "ok", "mix iter 4th key")
TkAssertEq%(HmIterType(m7), HmTypeBool, "mix iter 4th type")
TkAssertEq&(HmIterVal&(m7), 1, "mix iter 4th val")

ok% = HmIterNext(m7)
TkAssertEqStr(HmIterKey$(m7), "nn", "mix iter 5th key")
TkAssertEq%(HmIterType(m7), HmTypeNull, "mix iter 5th type")

ok% = HmIterNext(m7)
TkAssertTrue(NOT ok%, "mix iter ends after 5")

HmFree(m7)

{* --- Test 8: Re-iteration (reset and iterate again) --- *}
PRINT "--- Re-iteration ---"
DECLARE CLASS Hashmap m8
HmMake(m8, HM_SMALL)

rc% = HmPut$(m8, "p", "1")
rc% = HmPut$(m8, "q", "2")

' First pass
HmIterReset(m8)
ok% = HmIterNext(m8)
TkAssertEqStr(HmIterKey$(m8), "p", "pass1 1st")
ok% = HmIterNext(m8)
TkAssertEqStr(HmIterKey$(m8), "q", "pass1 2nd")

' Second pass - same results
HmIterReset(m8)
ok% = HmIterNext(m8)
TkAssertEqStr(HmIterKey$(m8), "p", "pass2 1st")
ok% = HmIterNext(m8)
TkAssertEqStr(HmIterKey$(m8), "q", "pass2 2nd")
ok% = HmIterNext(m8)
TkAssertTrue(NOT ok%, "pass2 ends")

HmFree(m8)

{* --- Test 9: Independent instance iteration --- *}
PRINT "--- Independent instances ---"
DECLARE CLASS Hashmap ia
DECLARE CLASS Hashmap ib
HmMake(ia, HM_SMALL)
HmMake(ib, HM_SMALL)

rc% = HmPut$(ia, "a1", "v1")
rc% = HmPut$(ia, "a2", "v2")

rc% = HmPut$(ib, "b1", "w1")
rc% = HmPut$(ib, "b2", "w2")
rc% = HmPut$(ib, "b3", "w3")

' Iterate ia
SHORTINT cntA%
cntA% = 0
HmIterReset(ia)
WHILE HmIterNext(ia)
  cntA% = cntA% + 1
WEND
TkAssertEq%(cntA%, 2, "ia has 2 entries")

' Iterate ib
SHORTINT cntB%
cntB% = 0
HmIterReset(ib)
WHILE HmIterNext(ib)
  cntB% = cntB% + 1
WEND
TkAssertEq%(cntB%, 3, "ib has 3 entries")

' Verify ia order
HmIterReset(ia)
ok% = HmIterNext(ia)
TkAssertEqStr(HmIterKey$(ia), "a1", "ia 1st key")
ok% = HmIterNext(ia)
TkAssertEqStr(HmIterKey$(ia), "a2", "ia 2nd key")

' Verify ib order
HmIterReset(ib)
ok% = HmIterNext(ib)
TkAssertEqStr(HmIterKey$(ib), "b1", "ib 1st key")
ok% = HmIterNext(ib)
TkAssertEqStr(HmIterKey$(ib), "b2", "ib 2nd key")
ok% = HmIterNext(ib)
TkAssertEqStr(HmIterKey$(ib), "b3", "ib 3rd key")

HmFree(ia)
HmFree(ib)

{* --- Test 10: HmClear resets iteration order --- *}
PRINT "--- Clear resets order ---"
DECLARE CLASS Hashmap mc
HmMake(mc, HM_SMALL)

rc% = HmPut$(mc, "old1", "v1")
rc% = HmPut$(mc, "old2", "v2")

HmClear(mc)

rc% = HmPut$(mc, "new1", "w1")
rc% = HmPut$(mc, "new2", "w2")

HmIterReset(mc)
ok% = HmIterNext(mc)
TkAssertEqStr(HmIterKey$(mc), "new1", "clear: 1st is new1")
ok% = HmIterNext(mc)
TkAssertEqStr(HmIterKey$(mc), "new2", "clear: 2nd is new2")
ok% = HmIterNext(mc)
TkAssertTrue(NOT ok%, "clear: ends after 2")

HmFree(mc)

{* --- Test 11: Update does not change order --- *}
PRINT "--- Update keeps order ---"
DECLARE CLASS Hashmap mu
HmMake(mu, HM_SMALL)

rc% = HmPut$(mu, "k1", "v1")
rc% = HmPut$(mu, "k2", "v2")
rc% = HmPut$(mu, "k3", "v3")

' Update k2 - should NOT change its position
rc% = HmPut$(mu, "k2", "updated")

HmIterReset(mu)
ok% = HmIterNext(mu)
TkAssertEqStr(HmIterKey$(mu), "k1", "upd order 1st = k1")
ok% = HmIterNext(mu)
TkAssertEqStr(HmIterKey$(mu), "k2", "upd order 2nd = k2")
TkAssertEqStr(HmIterVal$(mu), "updated", "upd k2 has new value")
ok% = HmIterNext(mu)
TkAssertEqStr(HmIterKey$(mu), "k3", "upd order 3rd = k3")
ok% = HmIterNext(mu)
TkAssertTrue(NOT ok%, "upd order ends")

HmFree(mu)

{* --- Test 12: Many inserts iteration --- *}
PRINT "--- Many inserts ---"
DECLARE CLASS Hashmap mm
HmMake(mm, HM_SMALL)

SHORTINT j%
STRING kk$
FOR j% = 0 TO 19
  kk$ = "item" + LTRIM$(STR$(j%))
  rc% = HmPut&(mm, kk$, j%)
NEXT

' Verify iteration count
SHORTINT mCnt%
mCnt% = 0
HmIterReset(mm)
WHILE HmIterNext(mm)
  mCnt% = mCnt% + 1
WEND
TkAssertEq%(mCnt%, 20, "many: 20 entries iterated")

' Verify first and last
HmIterReset(mm)
ok% = HmIterNext(mm)
TkAssertEqStr(HmIterKey$(mm), "item0", "many: 1st is item0")
TkAssertEq&(HmIterVal&(mm), 0, "many: 1st val is 0")

' Walk to last
FOR j% = 1 TO 19
  ok% = HmIterNext(mm)
NEXT
TkAssertEqStr(HmIterKey$(mm), "item19", "many: last is item19")
TkAssertEq&(HmIterVal&(mm), 19, "many: last val is 19")

HmFree(mm)

{* --- Test 13: Ref iteration --- *}
PRINT "--- Ref iteration ---"
DECLARE CLASS Hashmap mr
DECLARE CLASS Hashmap inner
HmMake(mr, HM_SMALL)
HmMake(inner, HM_SMALL)

rc% = HmPut$(inner, "foo", "bar")
rc% = HmPut$(mr, "label", "test")
rc% = HmPutRef(mr, "child", inner)

HmIterReset(mr)
ok% = HmIterNext(mr)
TkAssertEqStr(HmIterKey$(mr), "label", "ref iter 1st key")
TkAssertEq%(HmIterType(mr), HmTypeStr, "ref iter 1st type")

ok% = HmIterNext(mr)
TkAssertEqStr(HmIterKey$(mr), "child", "ref iter 2nd key")
TkAssertEq%(HmIterType(mr), HmTypeRef, "ref iter 2nd type")
TkAssertTrue(HmIterVal&(mr) <> 0, "ref iter 2nd val non-zero")
TkAssertEq&(HmIterVal&(mr), inner, "ref iter 2nd val = inner addr")

HmFree(inner)
HmFree(mr)

{* ============== Summary ============== *}
TkSummary
