{*
** Comprehensive Test Suite for the Lisp-style List Library
** Tests all type variants and all functions
*}

#include <submods/list.h>

SHORTINT _testsPassed, _testsFailed

{* ============== Assertion Helpers ============== *}

SUB AssertTrue(SHORTINT condition, msg$)
  SHARED _testsPassed, _testsFailed
  IF condition THEN
    _testsPassed = _testsPassed + 1
  ELSE
    PRINT "FAIL: "; msg$
    _testsFailed = _testsFailed + 1
  END IF
END SUB

SUB AssertEq%(SHORTINT actual, SHORTINT expected, msg$)
  SHARED _testsPassed, _testsFailed
  IF actual = expected THEN
    _testsPassed = _testsPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected"; expected; " got"; actual; ")"
    _testsFailed = _testsFailed + 1
  END IF
END SUB

SUB AssertEq&(LONGINT actual, LONGINT expected, msg$)
  SHARED _testsPassed, _testsFailed
  IF actual = expected THEN
    _testsPassed = _testsPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected"; expected; " got"; actual; ")"
    _testsFailed = _testsFailed + 1
  END IF
END SUB

SUB AssertEqAddr(ADDRESS actual, ADDRESS expected, msg$)
  SHARED _testsPassed, _testsFailed
  IF actual = expected THEN
    _testsPassed = _testsPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected"; expected; " got"; actual; ")"
    _testsFailed = _testsFailed + 1
  END IF
END SUB

SUB AssertNeqAddr(ADDRESS actual, ADDRESS notExpected, msg$)
  SHARED _testsPassed, _testsFailed
  IF actual <> notExpected THEN
    _testsPassed = _testsPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (should not be"; notExpected; ")"
    _testsFailed = _testsFailed + 1
  END IF
END SUB

SUB AssertEqStr(actual$, expected$, msg$)
  SHARED _testsPassed, _testsFailed
  IF actual$ = expected$ THEN
    _testsPassed = _testsPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected '"; expected$; "' got '"; actual$; "')"
    _testsFailed = _testsFailed + 1
  END IF
END SUB

{* Float comparison with tolerance *}
SUB AssertEqFloat(SINGLE actual, SINGLE expected, msg$)
  SHARED _testsPassed, _testsFailed
  SINGLE diff
  diff = actual - expected
  IF diff < 0 THEN diff = -diff
  IF diff < 0.001 THEN
    _testsPassed = _testsPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected"; expected; " got"; actual; ")"
    _testsFailed = _testsFailed + 1
  END IF
END SUB

{* ============== Main Test Program ============== *}

PRINT "=== List Library Comprehensive Test Suite ==="
PRINT

_testsPassed = 0
_testsFailed = 0

LInit

{* ============================================== *}
{* Test Group 1: LCons - All Type Variants       *}
{* ============================================== *}
PRINT "=== LCons Variants ==="

PRINT "Test: LCons% (SHORTINT)"
ADDRESS listInt
listInt = LCons%(3, LNil)
listInt = LCons%(2, listInt)
listInt = LCons%(1, listInt)
AssertEq&(LLen(listInt), 3, "LCons% length")
AssertEq%(LCar%(listInt), 1, "LCons% first value")
AssertEq%(LType(listInt), LTypeInt, "LCons% type")
LFree(listInt)

PRINT "Test: LCons& (LONGINT)"
ADDRESS listLng
listLng = LCons&(300000&, LNil)
listLng = LCons&(200000&, listLng)
listLng = LCons&(100000&, listLng)
AssertEq&(LLen(listLng), 3, "LCons& length")
AssertEq&(LCar&(listLng), 100000, "LCons& first value")
AssertEq%(LType(listLng), LTypeLng, "LCons& type")
LFree(listLng)

PRINT "Test: LCons! (SINGLE)"
ADDRESS listSng
listSng = LCons!(3.14!, LNil)
listSng = LCons!(2.71!, listSng)
listSng = LCons!(1.41!, listSng)
AssertEq&(LLen(listSng), 3, "LCons! length")
AssertEqFloat(LCar!(listSng), 1.41!, "LCons! first value")
AssertEq%(LType(listSng), LTypeSng, "LCons! type")
LFree(listSng)

PRINT "Test: LCons$ (STRING)"
ADDRESS listStr
listStr = LCons$("third", LNil)
listStr = LCons$("second", listStr)
listStr = LCons$("first", listStr)
AssertEq&(LLen(listStr), 3, "LCons$ length")
AssertEqStr(LCar$(listStr), "first", "LCons$ first value")
AssertEq%(LType(listStr), LTypeStr, "LCons$ type")
LFree(listStr)

PRINT "Test: LConsList (nested list)"
ADDRESS inner, outer
inner = LCons%(99, LNil)
outer = LConsList(inner, LNil)
AssertEq%(LType(outer), LTypeList, "LConsList type")
AssertEq%(LCar%(LCar(outer)), 99, "LConsList nested value")
' Only free outer - it will recursively free inner
LFree(outer)
PRINT

{* ============================================== *}
{* Test Group 2: LSnoc - All Type Variants       *}
{* ============================================== *}
PRINT "=== LSnoc Variants ==="

PRINT "Test: LSnoc% (SHORTINT)"
ADDRESS snocInt
snocInt = LNil
snocInt = LSnoc%(1, snocInt)
snocInt = LSnoc%(2, snocInt)
snocInt = LSnoc%(3, snocInt)
AssertEq&(LLen(snocInt), 3, "LSnoc% length")
AssertEq%(LCar%(snocInt), 1, "LSnoc% first value")
AssertEq%(LCar%(LCdr(LCdr(snocInt))), 3, "LSnoc% last value")
LFree(snocInt)

PRINT "Test: LSnoc& (LONGINT)"
ADDRESS snocLng
snocLng = LNil
snocLng = LSnoc&(100000&, snocLng)
snocLng = LSnoc&(200000&, snocLng)
AssertEq&(LLen(snocLng), 2, "LSnoc& length")
AssertEq&(LCar&(snocLng), 100000, "LSnoc& first value")
LFree(snocLng)

PRINT "Test: LSnoc! (SINGLE)"
ADDRESS snocSng
snocSng = LNil
snocSng = LSnoc!(1.1!, snocSng)
snocSng = LSnoc!(2.2!, snocSng)
AssertEq&(LLen(snocSng), 2, "LSnoc! length")
AssertEqFloat(LCar!(snocSng), 1.1!, "LSnoc! first value")
LFree(snocSng)

PRINT "Test: LSnoc$ (STRING)"
ADDRESS snocStr
snocStr = LNil
snocStr = LSnoc$("alpha", snocStr)
snocStr = LSnoc$("beta", snocStr)
AssertEq&(LLen(snocStr), 2, "LSnoc$ length")
AssertEqStr(LCar$(snocStr), "alpha", "LSnoc$ first value")
LFree(snocStr)

PRINT "Test: LSnocList (nested list)"
ADDRESS snocInner, snocOuter
snocInner = LCons%(42, LNil)
snocOuter = LNil
snocOuter = LSnocList(snocInner, snocOuter)
AssertEq%(LType(snocOuter), LTypeList, "LSnocList type")
' Only free snocOuter - it will recursively free snocInner
LFree(snocOuter)
PRINT

{* ============================================== *}
{* Test Group 3: LCar - All Type Variants        *}
{* ============================================== *}
PRINT "=== LCar Variants ==="

PRINT "Test: LCar%, LCar&, LCar!, LCar$, LCar"
ADDRESS mixedList
LNew
LAdd%(10)
LAdd&(20000&)
LAdd!(3.5!)
LAdd$("test")
mixedList = LEnd
AssertEq%(LCar%(mixedList), 10, "LCar% on INT cell")
AssertEq&(LCar&(LCdr(mixedList)), 20000, "LCar& on LNG cell")
AssertEqFloat(LCar!(LCdr(LCdr(mixedList))), 3.5!, "LCar! on SNG cell")
AssertEqStr(LCar$(LCdr(LCdr(LCdr(mixedList)))), "test", "LCar$ on STR cell")
LFree(mixedList)
PRINT

{* ============================================== *}
{* Test Group 4: LFirst - All Type Variants      *}
{* ============================================== *}
PRINT "=== LFirst Variants ==="

PRINT "Test: LFirst%, LFirst&, LFirst!, LFirst$"
ADDRESS lst
lst = LCons%(77, LNil)
AssertEq%(LFirst%(lst), 77, "LFirst% value")
LFree(lst)

lst = LCons&(77777&, LNil)
AssertEq&(LFirst&(lst), 77777, "LFirst& value")
LFree(lst)

lst = LCons!(7.77!, LNil)
AssertEqFloat(LFirst!(lst), 7.77!, "LFirst! value")
LFree(lst)

lst = LCons$("seven", LNil)
AssertEqStr(LFirst$(lst), "seven", "LFirst$ value")
LFree(lst)

inner = LCons%(7, LNil)
lst = LConsList(inner, LNil)
AssertEqAddr(LFirst(lst), inner, "LFirst (ADDRESS) value")
' Only free lst - it will recursively free inner
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 5: LSecond - All Type Variants     *}
{* ============================================== *}
PRINT "=== LSecond Variants ==="

PRINT "Test: LSecond%, LSecond&, LSecond!, LSecond$"
lst = LCons%(1, LCons%(2, LNil))
AssertEq%(LSecond%(lst), 2, "LSecond% value")
LFree(lst)

lst = LCons&(1&, LCons&(22222&, LNil))
AssertEq&(LSecond&(lst), 22222, "LSecond& value")
LFree(lst)

lst = LCons!(1.0!, LCons!(2.22!, LNil))
AssertEqFloat(LSecond!(lst), 2.22!, "LSecond! value")
LFree(lst)

lst = LCons$("a", LCons$("bee", LNil))
AssertEqStr(LSecond$(lst), "bee", "LSecond$ value")
LFree(lst)

inner = LCons%(99, LNil)
ADDRESS dummy
dummy = LCons%(0, LNil)
lst = LConsList(dummy, LConsList(inner, LNil))
AssertEqAddr(LSecond(lst), inner, "LSecond (ADDRESS) value")
' Only free lst - it will recursively free the nested lists (dummy, inner)
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 6: LCdr and LRest                  *}
{* ============================================== *}
PRINT "=== LCdr and LRest ==="

PRINT "Test: LCdr"
lst = LCons%(1, LCons%(2, LCons%(3, LNil)))
AssertEq%(LCar%(LCdr(lst)), 2, "LCdr returns second cell")
AssertEq%(LCar%(LCdr(LCdr(lst))), 3, "LCdr twice returns third cell")
AssertEqAddr(LCdr(LCdr(LCdr(lst))), LNil, "LCdr past end returns LNil")

PRINT "Test: LRest (alias for LCdr)"
AssertEq%(LCar%(LRest(lst)), 2, "LRest returns second cell")
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 7: Predicates and Info             *}
{* ============================================== *}
PRINT "=== Predicates and Info ==="

PRINT "Test: LNull"
AssertTrue(LNull(LNil), "LNull(LNil) is true")
lst = LCons%(1, LNil)
AssertTrue(NOT LNull(lst), "LNull(non-empty) is false")
LFree(lst)

PRINT "Test: LType"
lst = LCons%(1, LNil)
AssertEq%(LType(lst), LTypeInt, "LType INT")
LFree(lst)
lst = LCons&(1&, LNil)
AssertEq%(LType(lst), LTypeLng, "LType LNG")
LFree(lst)
lst = LCons!(1.0!, LNil)
AssertEq%(LType(lst), LTypeSng, "LType SNG")
LFree(lst)
lst = LCons$("x", LNil)
AssertEq%(LType(lst), LTypeStr, "LType STR")
LFree(lst)
inner = LCons%(1, LNil)
lst = LConsList(inner, LNil)
AssertEq%(LType(lst), LTypeList, "LType LIST")
' Only free lst - it will recursively free inner
LFree(lst)
AssertEq%(LType(LNil), LTypeNil, "LType LNil")

PRINT "Test: LLen"
AssertEq&(LLen(LNil), 0, "LLen of empty list")
lst = LCons%(1, LNil)
AssertEq&(LLen(lst), 1, "LLen of 1-element list")
LFree(lst)
lst = LCons%(1, LCons%(2, LCons%(3, LCons%(4, LCons%(5, LNil)))))
AssertEq&(LLen(lst), 5, "LLen of 5-element list")
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 8: Builder Pattern - All Variants  *}
{* ============================================== *}
PRINT "=== Builder Pattern ==="

PRINT "Test: LAdd% (SHORTINT)"
LNew
LAdd%(1)
LAdd%(2)
LAdd%(3)
lst = LEnd
AssertEq&(LLen(lst), 3, "LAdd% length")
AssertEq%(LCar%(lst), 1, "LAdd% preserves order")
LFree(lst)

PRINT "Test: LAdd& (LONGINT)"
LNew
LAdd&(100000&)
LAdd&(200000&)
lst = LEnd
AssertEq&(LCar&(lst), 100000, "LAdd& first value")
LFree(lst)

PRINT "Test: LAdd! (SINGLE)"
LNew
LAdd!(1.5!)
LAdd!(2.5!)
lst = LEnd
AssertEqFloat(LCar!(lst), 1.5!, "LAdd! first value")
LFree(lst)

PRINT "Test: LAdd$ (STRING)"
LNew
LAdd$("hello")
LAdd$("world")
lst = LEnd
AssertEqStr(LCar$(lst), "hello", "LAdd$ first value")
LFree(lst)

PRINT "Test: LAddList (nested)"
inner = LCons%(42, LNil)
LNew
LAddList(inner)
lst = LEnd
AssertEq%(LType(lst), LTypeList, "LAddList type")
' Only free lst - it will recursively free inner
LFree(lst)

PRINT "Test: String copy semantics in builder"
STRING s
s = "original"
LNew
LAdd$(s)
lst = LEnd
s = "changed"
AssertEqStr(LCar$(lst), "original", "string copied not referenced")
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 9: List Operations                 *}
{* ============================================== *}
PRINT "=== List Operations ==="

PRINT "Test: LAppend"
ADDRESS a, b, appended
a = LCons%(1, LCons%(2, LNil))
b = LCons%(3, LCons%(4, LNil))
appended = LAppend(a, b)
AssertEq&(LLen(appended), 4, "LAppend length")
AssertEq%(LCar%(appended), 1, "LAppend first")
AssertEq%(LCar%(LNth(appended, 2)), 3, "LAppend third (from b)")
AssertEq%(LCar%(LNth(appended, 3)), 4, "LAppend fourth")
' Note: appended shares tail with b, so only free appended's new cells
LFree(a)
' Don't free b - it's shared
' Don't free appended - cells from a are freed, b is shared

PRINT "Test: LRev (non-destructive)"
lst = LCons%(1, LCons%(2, LCons%(3, LNil)))
ADDRESS reversed
reversed = LRev(lst)
AssertEq%(LCar%(lst), 1, "original unchanged after LRev")
AssertEq%(LCar%(reversed), 3, "LRev first is original last")
AssertEq%(LCar%(LCdr(reversed)), 2, "LRev second")
AssertEq%(LCar%(LCdr(LCdr(reversed))), 1, "LRev third is original first")
LFree(lst)
LFree(reversed)

PRINT "Test: LCopy (deep copy)"
lst = LCons%(1, LCons%(2, LNil))
ADDRESS copied
copied = LCopy(lst)
AssertNeqAddr(copied, lst, "copy is different address")
AssertEq%(LCar%(copied), 1, "copy has same first value")
AssertEq%(LCar%(LCdr(copied)), 2, "copy has same second value")
LFree(lst)
LFree(copied)

PRINT "Test: LNth"
lst = LCons%(10, LCons%(20, LCons%(30, LCons%(40, LNil))))
AssertEq%(LCar%(LNth(lst, 0)), 10, "LNth(0)")
AssertEq%(LCar%(LNth(lst, 1)), 20, "LNth(1)")
AssertEq%(LCar%(LNth(lst, 2)), 30, "LNth(2)")
AssertEq%(LCar%(LNth(lst, 3)), 40, "LNth(3)")
AssertEqAddr(LNth(lst, 4), LNil, "LNth past end")
AssertEqAddr(LNth(lst, 100), LNil, "LNth way past end")
LFree(lst)

PRINT "Test: LNconc (destructive append)"
a = LCons%(1, LCons%(2, LNil))
b = LCons%(3, LCons%(4, LNil))
LNconc(a, b)
AssertEq&(LLen(a), 4, "LNconc length")
AssertEq%(LCar%(LNth(a, 2)), 3, "LNconc appended value")
LFree(a)
' b is now part of a, don't double-free

PRINT "Test: LNrev (destructive reverse)"
lst = LCons%(1, LCons%(2, LCons%(3, LNil)))
lst = LNrev(lst)
AssertEq%(LCar%(lst), 3, "LNrev first")
AssertEq%(LCar%(LCdr(lst)), 2, "LNrev second")
AssertEq%(LCar%(LCdr(LCdr(lst))), 1, "LNrev third")
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 10: Edge Cases                     *}
{* ============================================== *}
PRINT "=== Edge Cases ==="

PRINT "Test: Operations on empty list"
AssertEqAddr(LCdr(LNil), LNil, "LCdr of LNil")
AssertEqAddr(LRest(LNil), LNil, "LRest of LNil")
AssertEqAddr(LRev(LNil), LNil, "LRev of LNil")
AssertEqAddr(LCopy(LNil), LNil, "LCopy of LNil")
AssertEqAddr(LNth(LNil, 0), LNil, "LNth of LNil")
AssertEq&(LLen(LNil), 0, "LLen of LNil")

PRINT "Test: Single element list"
lst = LCons%(42, LNil)
AssertEq&(LLen(lst), 1, "single element length")
AssertEqAddr(LCdr(lst), LNil, "single element cdr is nil")
reversed = LRev(lst)
AssertEq%(LCar%(reversed), 42, "reverse single element")
LFree(lst)
LFree(reversed)

PRINT "Test: Empty builder"
LNew
lst = LEnd
AssertEqAddr(lst, LNil, "empty builder returns LNil")
PRINT

LCleanup

{* ============================================== *}
{* Results                                        *}
{* ============================================== *}
PRINT
PRINT "========================================"
PRINT "Test Results"
PRINT "========================================"
PRINT "Passed:"; _testsPassed
PRINT "Failed:"; _testsFailed
PRINT
IF _testsFailed = 0 THEN
  PRINT "All tests passed!"
ELSE
  PRINT "Some tests FAILED!"
END IF
