REM #using ace:submods/hashmap/hashmap.o

{*
** Hashmap Phase 2: Typed Value Tests
** Tests put/get for LONG, SINGLE, Bool, Null, Ref types.
** Tests HmType, type overwrite, mixed types, nested hashmap refs.
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

PRINT "=== Hashmap Phase 2: Typed Value Tests ==="
PRINT

_passed = 0
_failed = 0

SHORTINT rc%
DECLARE CLASS Hashmap m

{* --- Test 1: Put & Get LONGINT --- *}
PRINT "--- Put / Get LONGINT ---"
HmMake(m, HM_SMALL)

rc% = HmPut&(m, "age", 30)
AssertEq%(rc%, 0, "put& age should succeed")
AssertEq&(HmGet&(m, "age"), 30, "get& age")

rc% = HmPut&(m, "year", 2026)
AssertEq%(rc%, 0, "put& year should succeed")
AssertEq&(HmGet&(m, "year"), 2026, "get& year")

' Negative value
rc% = HmPut&(m, "neg", -42)
AssertEq%(rc%, 0, "put& negative should succeed")
AssertEq&(HmGet&(m, "neg"), -42, "get& negative")

' Zero
rc% = HmPut&(m, "zero", 0)
AssertEq%(rc%, 0, "put& zero should succeed")
AssertEq&(HmGet&(m, "zero"), 0, "get& zero")

' Get missing returns 0
AssertEq&(HmGet&(m, "missing"), 0, "get& missing returns 0")

HmFree(m)

{* --- Test 2: Put & Get SINGLE --- *}
PRINT "--- Put / Get SINGLE ---"
DECLARE CLASS Hashmap ms
HmMake(ms, HM_SMALL)

SINGLE testF!

rc% = HmPut!(ms, "pi", 3.14)
AssertEq%(rc%, 0, "put! pi should succeed")
testF! = HmGet!(ms, "pi")
AssertTrue(testF! > 3.13 AND testF! < 3.15, "get! pi approx 3.14")

rc% = HmPut!(ms, "half", 0.5)
AssertEq%(rc%, 0, "put! half should succeed")
testF! = HmGet!(ms, "half")
AssertTrue(testF! > 0.49 AND testF! < 0.51, "get! half approx 0.5")

' Negative float
rc% = HmPut!(ms, "negf", -1.5)
AssertEq%(rc%, 0, "put! negf should succeed")
testF! = HmGet!(ms, "negf")
AssertTrue(testF! < -1.4 AND testF! > -1.6, "get! negf approx -1.5")

HmFree(ms)

{* --- Test 3: Put Bool --- *}
PRINT "--- Put Bool ---"
DECLARE CLASS Hashmap mb
HmMake(mb, HM_SMALL)

rc% = HmPutBool(mb, "active", -1)
AssertEq%(rc%, 0, "putBool active should succeed")
AssertEq&(HmGet&(mb, "active"), 1, "getBool active is 1")

rc% = HmPutBool(mb, "deleted", 0)
AssertEq%(rc%, 0, "putBool deleted should succeed")
AssertEq&(HmGet&(mb, "deleted"), 0, "getBool deleted is 0")

HmFree(mb)

{* --- Test 4: Put Null --- *}
PRINT "--- Put Null ---"
DECLARE CLASS Hashmap mn
HmMake(mn, HM_SMALL)

rc% = HmPutNull(mn, "nothing")
AssertEq%(rc%, 0, "putNull should succeed")
AssertTrue(HmHas(mn, "nothing"), "has null key")
AssertEq%(HmType(mn, "nothing"), HmTypeNull, "type is null")

HmFree(mn)

{* --- Test 5: HmType for all types --- *}
PRINT "--- HmType ---"
DECLARE CLASS Hashmap mt
HmMake(mt, HM_SMALL)

rc% = HmPut$(mt, "s", "hello")
AssertEq%(HmType(mt, "s"), HmTypeStr, "type str")

rc% = HmPut&(mt, "l", 100)
AssertEq%(HmType(mt, "l"), HmTypeLng, "type lng")

rc% = HmPut!(mt, "f", 1.5)
AssertEq%(HmType(mt, "f"), HmTypeSng, "type sng")

rc% = HmPutBool(mt, "b", -1)
AssertEq%(HmType(mt, "b"), HmTypeBool, "type bool")

rc% = HmPutNull(mt, "n")
AssertEq%(HmType(mt, "n"), HmTypeNull, "type null")

' Missing key returns -1
AssertEq%(HmType(mt, "nope"), -1, "type missing returns -1")

HmFree(mt)

{* --- Test 6: Type overwrite --- *}
PRINT "--- Type overwrite ---"
DECLARE CLASS Hashmap mo
HmMake(mo, HM_SMALL)

' Start as string
rc% = HmPut$(mo, "x", "hello")
AssertEq%(HmType(mo, "x"), HmTypeStr, "x initially str")
AssertEqStr(HmGet$(mo, "x"), "hello", "x str value")

' Overwrite with LONGINT
rc% = HmPut&(mo, "x", 99)
AssertEq%(HmType(mo, "x"), HmTypeLng, "x now lng")
AssertEq&(HmGet&(mo, "x"), 99, "x lng value")

' Overwrite with null
rc% = HmPutNull(mo, "x")
AssertEq%(HmType(mo, "x"), HmTypeNull, "x now null")

' Count unchanged through overwrites
AssertEq&(HmCount(mo), 1, "count still 1 after overwrites")

HmFree(mo)

{* --- Test 7: Mixed types in same map --- *}
PRINT "--- Mixed types ---"
DECLARE CLASS Hashmap mx
HmMake(mx, HM_SMALL)

rc% = HmPut$(mx, "nm", "Alice")
rc% = HmPut&(mx, "ag", 30)
rc% = HmPut!(mx, "ht", 5.5)
rc% = HmPutBool(mx, "ok", -1)
rc% = HmPutNull(mx, "nn")

AssertEq&(HmCount(mx), 5, "5 mixed entries")

AssertEqStr(HmGet$(mx, "nm"), "Alice", "mixed get str")
AssertEq&(HmGet&(mx, "ag"), 30, "mixed get lng")
testF! = HmGet!(mx, "ht")
AssertTrue(testF! > 5.4 AND testF! < 5.6, "mixed get sng")
AssertEq&(HmGet&(mx, "ok"), 1, "mixed get bool")
AssertEq%(HmType(mx, "nn"), HmTypeNull, "mixed type null")

HmFree(mx)

{* --- Test 8: PutRef / GetRef with nested Hashmap --- *}
PRINT "--- Ref (nested hashmap) ---"
DECLARE CLASS Hashmap outer
DECLARE CLASS Hashmap inner
HmMake(outer, HM_SMALL)
HmMake(inner, HM_SMALL)

' Put data in inner map
rc% = HmPut$(inner, "street", "123 Main St")

' Store inner map as ref in outer map
rc% = HmPutRef(outer, "addr", inner)
AssertEq%(rc%, 0, "putRef should succeed")
AssertEq%(HmType(outer, "addr"), HmTypeRef, "type is ref")

' Retrieve the ref and verify it points to inner
LONGINT refAddr&
refAddr& = HmGetRef(outer, "addr")
AssertTrue(refAddr& <> 0, "ref is non-zero")
AssertEq&(refAddr&, inner, "ref equals inner address")

' Use the retrieved ref as a Hashmap
' (Verify inner map data is intact)
AssertEqStr(HmGet$(inner, "street"), "123 Main St", "inner data intact")

HmFree(inner)
HmFree(outer)

{* --- Test 9: Update LONGINT value --- *}
PRINT "--- Update typed value ---"
DECLARE CLASS Hashmap mu
HmMake(mu, HM_SMALL)

rc% = HmPut&(mu, "count", 10)
AssertEq&(HmGet&(mu, "count"), 10, "initial count")

rc% = HmPut&(mu, "count", 20)
AssertEq&(HmGet&(mu, "count"), 20, "updated count")
AssertEq&(HmCount(mu), 1, "count unchanged after update")

HmFree(mu)

{* --- Test 10: Delete typed entries --- *}
PRINT "--- Delete typed entries ---"
DECLARE CLASS Hashmap md
HmMake(md, HM_SMALL)

rc% = HmPut&(md, "a", 1)
rc% = HmPut!(md, "b", 2.5)
rc% = HmPutBool(md, "c", -1)
AssertEq&(HmCount(md), 3, "3 entries before delete")

rc% = HmDel(md, "b")
AssertEq%(rc%, 0, "del typed entry succeeds")
AssertTrue(NOT HmHas(md, "b"), "b gone after del")
AssertEq&(HmCount(md), 2, "count after del")

' Remaining entries still accessible
AssertEq&(HmGet&(md, "a"), 1, "a still accessible")
AssertEq&(HmGet&(md, "c"), 1, "c still accessible")

HmFree(md)

{* ============== Summary ============== *}
PRINT
PRINT "Results:"; _passed; " passed,"; _failed; " failed"
IF _failed > 0 THEN
  PRINT "ASSERT FAILED: Some tests failed"
END IF
