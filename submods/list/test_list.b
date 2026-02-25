REM #using ace:submods/list/list.o
REM #using ace:submods/testkit/testkit.o

{*
** Comprehensive Test Suite for the Lisp-style List Library
** Tests all type variants and all functions
*}

#include <submods/list.h>
#include <submods/testkit.h>

STRING _upperResult$

{* ============== Main Test Program ============== *}

PRINT "=== List Library Comprehensive Test Suite ==="
PRINT

TkInit

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
TkAssertEq&(LLen(listInt), 3, "LCons% length")
TkAssertEq%(LCar%(listInt), 1, "LCons% first value")
TkAssertEq%(LType(listInt), LTypeInt, "LCons% type")
LFree(listInt)

PRINT "Test: LCons& (LONGINT)"
ADDRESS listLng
listLng = LCons&(300000&, LNil)
listLng = LCons&(200000&, listLng)
listLng = LCons&(100000&, listLng)
TkAssertEq&(LLen(listLng), 3, "LCons& length")
TkAssertEq&(LCar&(listLng), 100000, "LCons& first value")
TkAssertEq%(LType(listLng), LTypeLng, "LCons& type")
LFree(listLng)

PRINT "Test: LCons! (SINGLE)"
ADDRESS listSng
listSng = LCons!(3.14!, LNil)
listSng = LCons!(2.71!, listSng)
listSng = LCons!(1.41!, listSng)
TkAssertEq&(LLen(listSng), 3, "LCons! length")
TkAssertEqFloat(LCar!(listSng), 1.41!, "LCons! first value")
TkAssertEq%(LType(listSng), LTypeSng, "LCons! type")
LFree(listSng)

PRINT "Test: LCons$ (STRING)"
ADDRESS listStr
listStr = LCons$("third", LNil)
listStr = LCons$("second", listStr)
listStr = LCons$("first", listStr)
TkAssertEq&(LLen(listStr), 3, "LCons$ length")
TkAssertEqStr(LCar$(listStr), "first", "LCons$ first value")
TkAssertEq%(LType(listStr), LTypeStr, "LCons$ type")
LFree(listStr)

PRINT "Test: LConsList (nested list)"
ADDRESS inner, outer
inner = LCons%(99, LNil)
outer = LConsList(inner, LNil)
TkAssertEq%(LType(outer), LTypeList, "LConsList type")
TkAssertEq%(LCar%(LCar(outer)), 99, "LConsList nested value")
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
TkAssertEq&(LLen(snocInt), 3, "LSnoc% length")
TkAssertEq%(LCar%(snocInt), 1, "LSnoc% first value")
TkAssertEq%(LCar%(LCdr(LCdr(snocInt))), 3, "LSnoc% last value")
LFree(snocInt)

PRINT "Test: LSnoc& (LONGINT)"
ADDRESS snocLng
snocLng = LNil
snocLng = LSnoc&(100000&, snocLng)
snocLng = LSnoc&(200000&, snocLng)
TkAssertEq&(LLen(snocLng), 2, "LSnoc& length")
TkAssertEq&(LCar&(snocLng), 100000, "LSnoc& first value")
LFree(snocLng)

PRINT "Test: LSnoc! (SINGLE)"
ADDRESS snocSng
snocSng = LNil
snocSng = LSnoc!(1.1!, snocSng)
snocSng = LSnoc!(2.2!, snocSng)
TkAssertEq&(LLen(snocSng), 2, "LSnoc! length")
TkAssertEqFloat(LCar!(snocSng), 1.1!, "LSnoc! first value")
LFree(snocSng)

PRINT "Test: LSnoc$ (STRING)"
ADDRESS snocStr
snocStr = LNil
snocStr = LSnoc$("alpha", snocStr)
snocStr = LSnoc$("beta", snocStr)
TkAssertEq&(LLen(snocStr), 2, "LSnoc$ length")
TkAssertEqStr(LCar$(snocStr), "alpha", "LSnoc$ first value")
LFree(snocStr)

PRINT "Test: LSnocList (nested list)"
ADDRESS snocInner, snocOuter
snocInner = LCons%(42, LNil)
snocOuter = LNil
snocOuter = LSnocList(snocInner, snocOuter)
TkAssertEq%(LType(snocOuter), LTypeList, "LSnocList type")
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
TkAssertEq%(LCar%(mixedList), 10, "LCar% on INT cell")
TkAssertEq&(LCar&(LCdr(mixedList)), 20000, "LCar& on LNG cell")
TkAssertEqFloat(LCar!(LCdr(LCdr(mixedList))), 3.5!, "LCar! on SNG cell")
TkAssertEqStr(LCar$(LCdr(LCdr(LCdr(mixedList)))), "test", "LCar$ on STR cell")
LFree(mixedList)
PRINT

{* ============================================== *}
{* Test Group 4: LFirst - All Type Variants      *}
{* ============================================== *}
PRINT "=== LFirst Variants ==="

PRINT "Test: LFirst%, LFirst&, LFirst!, LFirst$"
ADDRESS lst
lst = LCons%(77, LNil)
TkAssertEq%(LFirst%(lst), 77, "LFirst% value")
LFree(lst)

lst = LCons&(77777&, LNil)
TkAssertEq&(LFirst&(lst), 77777, "LFirst& value")
LFree(lst)

lst = LCons!(7.77!, LNil)
TkAssertEqFloat(LFirst!(lst), 7.77!, "LFirst! value")
LFree(lst)

lst = LCons$("seven", LNil)
TkAssertEqStr(LFirst$(lst), "seven", "LFirst$ value")
LFree(lst)

inner = LCons%(7, LNil)
lst = LConsList(inner, LNil)
TkAssertEqAddr(LFirst(lst), inner, "LFirst (ADDRESS) value")
' Only free lst - it will recursively free inner
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 5: LSecond - All Type Variants     *}
{* ============================================== *}
PRINT "=== LSecond Variants ==="

PRINT "Test: LSecond%, LSecond&, LSecond!, LSecond$"
lst = LCons%(1, LCons%(2, LNil))
TkAssertEq%(LSecond%(lst), 2, "LSecond% value")
LFree(lst)

lst = LCons&(1&, LCons&(22222&, LNil))
TkAssertEq&(LSecond&(lst), 22222, "LSecond& value")
LFree(lst)

lst = LCons!(1.0!, LCons!(2.22!, LNil))
TkAssertEqFloat(LSecond!(lst), 2.22!, "LSecond! value")
LFree(lst)

lst = LCons$("a", LCons$("bee", LNil))
TkAssertEqStr(LSecond$(lst), "bee", "LSecond$ value")
LFree(lst)

inner = LCons%(99, LNil)
ADDRESS dummy
dummy = LCons%(0, LNil)
lst = LConsList(dummy, LConsList(inner, LNil))
TkAssertEqAddr(LSecond(lst), inner, "LSecond (ADDRESS) value")
' Only free lst - it will recursively free the nested lists (dummy, inner)
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 6: LCdr and LRest                  *}
{* ============================================== *}
PRINT "=== LCdr and LRest ==="

PRINT "Test: LCdr"
lst = LCons%(1, LCons%(2, LCons%(3, LNil)))
TkAssertEq%(LCar%(LCdr(lst)), 2, "LCdr returns second cell")
TkAssertEq%(LCar%(LCdr(LCdr(lst))), 3, "LCdr twice returns third cell")
TkAssertEqAddr(LCdr(LCdr(LCdr(lst))), LNil, "LCdr past end returns LNil")

PRINT "Test: LRest (alias for LCdr)"
TkAssertEq%(LCar%(LRest(lst)), 2, "LRest returns second cell")
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 7: Predicates and Info             *}
{* ============================================== *}
PRINT "=== Predicates and Info ==="

PRINT "Test: LNull"
TkAssertTrue(LNull(LNil), "LNull(LNil) is true")
lst = LCons%(1, LNil)
TkAssertTrue(NOT LNull(lst), "LNull(non-empty) is false")
LFree(lst)

PRINT "Test: LType"
lst = LCons%(1, LNil)
TkAssertEq%(LType(lst), LTypeInt, "LType INT")
LFree(lst)
lst = LCons&(1&, LNil)
TkAssertEq%(LType(lst), LTypeLng, "LType LNG")
LFree(lst)
lst = LCons!(1.0!, LNil)
TkAssertEq%(LType(lst), LTypeSng, "LType SNG")
LFree(lst)
lst = LCons$("x", LNil)
TkAssertEq%(LType(lst), LTypeStr, "LType STR")
LFree(lst)
inner = LCons%(1, LNil)
lst = LConsList(inner, LNil)
TkAssertEq%(LType(lst), LTypeList, "LType LIST")
' Only free lst - it will recursively free inner
LFree(lst)
TkAssertEq%(LType(LNil), LTypeNil, "LType LNil")

PRINT "Test: LLen"
TkAssertEq&(LLen(LNil), 0, "LLen of empty list")
lst = LCons%(1, LNil)
TkAssertEq&(LLen(lst), 1, "LLen of 1-element list")
LFree(lst)
lst = LCons%(1, LCons%(2, LCons%(3, LCons%(4, LCons%(5, LNil)))))
TkAssertEq&(LLen(lst), 5, "LLen of 5-element list")
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
TkAssertEq&(LLen(lst), 3, "LAdd% length")
TkAssertEq%(LCar%(lst), 1, "LAdd% preserves order")
LFree(lst)

PRINT "Test: LAdd& (LONGINT)"
LNew
LAdd&(100000&)
LAdd&(200000&)
lst = LEnd
TkAssertEq&(LCar&(lst), 100000, "LAdd& first value")
LFree(lst)

PRINT "Test: LAdd! (SINGLE)"
LNew
LAdd!(1.5!)
LAdd!(2.5!)
lst = LEnd
TkAssertEqFloat(LCar!(lst), 1.5!, "LAdd! first value")
LFree(lst)

PRINT "Test: LAdd$ (STRING)"
LNew
LAdd$("hello")
LAdd$("world")
lst = LEnd
TkAssertEqStr(LCar$(lst), "hello", "LAdd$ first value")
LFree(lst)

PRINT "Test: LAddList (nested)"
inner = LCons%(42, LNil)
LNew
LAddList(inner)
lst = LEnd
TkAssertEq%(LType(lst), LTypeList, "LAddList type")
' Only free lst - it will recursively free inner
LFree(lst)

PRINT "Test: String copy semantics in builder"
STRING s
s = "original"
LNew
LAdd$(s)
lst = LEnd
s = "changed"
TkAssertEqStr(LCar$(lst), "original", "string copied not referenced")
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
TkAssertEq&(LLen(appended), 4, "LAppend length")
TkAssertEq%(LCar%(appended), 1, "LAppend first")
TkAssertEq%(LCar%(LNth(appended, 2)), 3, "LAppend third (from b)")
TkAssertEq%(LCar%(LNth(appended, 3)), 4, "LAppend fourth")
' Note: appended shares tail with b, so only free appended's new cells
LFree(a)
' Don't free b - it's shared
' Don't free appended - cells from a are freed, b is shared

PRINT "Test: LRev (non-destructive)"
lst = LCons%(1, LCons%(2, LCons%(3, LNil)))
ADDRESS reversed
reversed = LRev(lst)
TkAssertEq%(LCar%(lst), 1, "original unchanged after LRev")
TkAssertEq%(LCar%(reversed), 3, "LRev first is original last")
TkAssertEq%(LCar%(LCdr(reversed)), 2, "LRev second")
TkAssertEq%(LCar%(LCdr(LCdr(reversed))), 1, "LRev third is original first")
LFree(lst)
LFree(reversed)

PRINT "Test: LCopy (deep copy)"
lst = LCons%(1, LCons%(2, LNil))
ADDRESS copied
copied = LCopy(lst)
TkAssertNeqAddr(copied, lst, "copy is different address")
TkAssertEq%(LCar%(copied), 1, "copy has same first value")
TkAssertEq%(LCar%(LCdr(copied)), 2, "copy has same second value")
LFree(lst)
LFree(copied)

PRINT "Test: LNth"
lst = LCons%(10, LCons%(20, LCons%(30, LCons%(40, LNil))))
TkAssertEq%(LCar%(LNth(lst, 0)), 10, "LNth(0)")
TkAssertEq%(LCar%(LNth(lst, 1)), 20, "LNth(1)")
TkAssertEq%(LCar%(LNth(lst, 2)), 30, "LNth(2)")
TkAssertEq%(LCar%(LNth(lst, 3)), 40, "LNth(3)")
TkAssertEqAddr(LNth(lst, 4), LNil, "LNth past end")
TkAssertEqAddr(LNth(lst, 100), LNil, "LNth way past end")
LFree(lst)

PRINT "Test: LNconc (destructive append)"
a = LCons%(1, LCons%(2, LNil))
b = LCons%(3, LCons%(4, LNil))
LNconc(a, b)
TkAssertEq&(LLen(a), 4, "LNconc length")
TkAssertEq%(LCar%(LNth(a, 2)), 3, "LNconc appended value")
LFree(a)
' b is now part of a, don't double-free

PRINT "Test: LNrev (destructive reverse)"
lst = LCons%(1, LCons%(2, LCons%(3, LNil)))
lst = LNrev(lst)
TkAssertEq%(LCar%(lst), 3, "LNrev first")
TkAssertEq%(LCar%(LCdr(lst)), 2, "LNrev second")
TkAssertEq%(LCar%(LCdr(LCdr(lst))), 1, "LNrev third")
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 10: Edge Cases                     *}
{* ============================================== *}
PRINT "=== Edge Cases ==="

PRINT "Test: Operations on empty list"
TkAssertEqAddr(LCdr(LNil), LNil, "LCdr of LNil")
TkAssertEqAddr(LRest(LNil), LNil, "LRest of LNil")
TkAssertEqAddr(LRev(LNil), LNil, "LRev of LNil")
TkAssertEqAddr(LCopy(LNil), LNil, "LCopy of LNil")
TkAssertEqAddr(LNth(LNil, 0), LNil, "LNth of LNil")
TkAssertEq&(LLen(LNil), 0, "LLen of LNil")

PRINT "Test: Single element list"
lst = LCons%(42, LNil)
TkAssertEq&(LLen(lst), 1, "single element length")
TkAssertEqAddr(LCdr(lst), LNil, "single element cdr is nil")
reversed = LRev(lst)
TkAssertEq%(LCar%(reversed), 42, "reverse single element")
LFree(lst)
LFree(reversed)

PRINT "Test: Empty builder"
LNew
lst = LEnd
TkAssertEqAddr(lst, LNil, "empty builder returns LNil")
PRINT

{* ============================================== *}
{* Test Group 11: Higher-Order Functions - LMap   *}
{* ============================================== *}
PRINT "=== LMap (Higher-Order) ==="

{* Callback functions for testing - declared before use *}
DECLARE SUB ADDRESS DoubleValue(ADDRESS carVal, SHORTINT typeTag) INVOKABLE
DECLARE SUB ADDRESS ToUpperStr(ADDRESS carVal, SHORTINT typeTag) INVOKABLE

PRINT "Test: LMap with SHORTINT list"
LNew
LAdd%(1)
LAdd%(2)
LAdd%(3)
lst = LEnd
ADDRESS mapped
mapped = LMap(lst, BIND(@DoubleValue))
TkAssertEq&(LLen(mapped), 3, "LMap length preserved")
TkAssertEq%(LCar%(mapped), 2, "LMap first doubled")
TkAssertEq%(LCar%(LCdr(mapped)), 4, "LMap second doubled")
TkAssertEq%(LCar%(LCdr(LCdr(mapped))), 6, "LMap third doubled")
' Original should be unchanged
TkAssertEq%(LCar%(lst), 1, "LMap original unchanged")
LFree(lst)
LFree(mapped)

PRINT "Test: LMap with LONGINT list"
LNew
LAdd&(100000&)
LAdd&(200000&)
lst = LEnd
mapped = LMap(lst, BIND(@DoubleValue))
TkAssertEq&(LCar&(mapped), 200000, "LMap LONG first doubled")
TkAssertEq&(LCar&(LCdr(mapped)), 400000, "LMap LONG second doubled")
LFree(lst)
LFree(mapped)

PRINT "Test: LMap with SINGLE (FFP) list"
LNew
LAdd!(1.5)
LAdd!(2.25)
LAdd!(3.0)
lst = LEnd
mapped = LMap(lst, BIND(@DoubleValue))
TkAssertEq&(LLen(mapped), 3, "LMap SINGLE length preserved")
TkAssertEqFloat(LCar!(mapped), 3.0, "LMap SINGLE first doubled (1.5 -> 3.0)")
TkAssertEqFloat(LCar!(LCdr(mapped)), 4.5, "LMap SINGLE second doubled (2.25 -> 4.5)")
TkAssertEqFloat(LCar!(LCdr(LCdr(mapped))), 6.0, "LMap SINGLE third doubled (3.0 -> 6.0)")
' Original should be unchanged
TkAssertEqFloat(LCar!(lst), 1.5, "LMap SINGLE original unchanged")
LFree(lst)
LFree(mapped)

PRINT "Test: LMap with STRING list"
LNew
LAdd$("abc")
LAdd$("def")
lst = LEnd
mapped = LMap(lst, BIND(@ToUpperStr))
TkAssertEqStr(LCar$(mapped), "ABC", "LMap STR first uppercased")
TkAssertEqStr(LCar$(LCdr(mapped)), "DEF", "LMap STR second uppercased")
LFree(lst)
LFree(mapped)

PRINT "Test: LMap on empty list"
TkAssertEqAddr(LMap(LNil, BIND(@DoubleValue)), LNil, "LMap of empty returns LNil")
PRINT

{* ============================================== *}
{* Test Group 12: Higher-Order Functions - LFilter *}
{* ============================================== *}
PRINT "=== LFilter (Higher-Order) ==="

DECLARE SUB SHORTINT IsEvenValue(ADDRESS carVal, SHORTINT typeTag) INVOKABLE
DECLARE SUB SHORTINT IsPositiveValue(ADDRESS carVal, SHORTINT typeTag) INVOKABLE
DECLARE SUB SHORTINT StartsWithA(ADDRESS carVal, SHORTINT typeTag) INVOKABLE

PRINT "Test: LFilter with SHORTINT list"
LNew
LAdd%(1)
LAdd%(2)
LAdd%(3)
LAdd%(4)
LAdd%(5)
LAdd%(6)
lst = LEnd
ADDRESS filtered
filtered = LFilter(lst, BIND(@IsEvenValue))
TkAssertEq&(LLen(filtered), 3, "LFilter keeps only evens")
TkAssertEq%(LCar%(filtered), 2, "LFilter first even")
TkAssertEq%(LCar%(LCdr(filtered)), 4, "LFilter second even")
TkAssertEq%(LCar%(LCdr(LCdr(filtered))), 6, "LFilter third even")
' Original unchanged
TkAssertEq&(LLen(lst), 6, "LFilter original unchanged")
LFree(lst)
LFree(filtered)

PRINT "Test: LFilter with LONGINT list"
LNew
LAdd&(-100&)
LAdd&(200&)
LAdd&(-300&)
LAdd&(400&)
lst = LEnd
filtered = LFilter(lst, BIND(@IsPositiveValue))
TkAssertEq&(LLen(filtered), 2, "LFilter keeps positives")
TkAssertEq&(LCar&(filtered), 200, "LFilter first positive")
LFree(lst)
LFree(filtered)

PRINT "Test: LFilter with STRING list"
LNew
LAdd$("apple")
LAdd$("banana")
LAdd$("apricot")
LAdd$("cherry")
lst = LEnd
filtered = LFilter(lst, BIND(@StartsWithA))
TkAssertEq&(LLen(filtered), 2, "LFilter keeps A-words")
TkAssertEqStr(LCar$(filtered), "apple", "LFilter first A-word")
TkAssertEqStr(LCar$(LCdr(filtered)), "apricot", "LFilter second A-word")
LFree(lst)
LFree(filtered)

PRINT "Test: LFilter all removed"
LNew
LAdd%(1)
LAdd%(3)
LAdd%(5)
lst = LEnd
filtered = LFilter(lst, BIND(@IsEvenValue))
TkAssertEqAddr(filtered, LNil, "LFilter all odds removed")
LFree(lst)

PRINT "Test: LFilter on empty list"
TkAssertEqAddr(LFilter(LNil, BIND(@IsEvenValue)), LNil, "LFilter of empty")
PRINT

{* ============================================== *}
{* Test Group 13: Higher-Order Functions - LReduce *}
{* ============================================== *}
PRINT "=== LReduce (Higher-Order) ==="

DECLARE SUB ADDRESS SumValues(ADDRESS acc, ADDRESS carVal, SHORTINT typeTag) INVOKABLE
DECLARE SUB ADDRESS ConcatStrings(ADDRESS acc, ADDRESS carVal, SHORTINT typeTag) INVOKABLE

PRINT "Test: LReduce with SHORTINT list"
LNew
LAdd%(1)
LAdd%(2)
LAdd%(3)
LAdd%(4)
LAdd%(5)
lst = LEnd
ADDRESS sumResult
sumResult = LReduce(lst, BIND(@SumValues), 0&)
TkAssertEq&(sumResult, 15, "LReduce sum 1+2+3+4+5=15")
LFree(lst)

PRINT "Test: LReduce with LONGINT list"
LNew
LAdd&(100000&)
LAdd&(200000&)
LAdd&(300000&)
lst = LEnd
sumResult = LReduce(lst, BIND(@SumValues), 0&)
TkAssertEq&(sumResult, 600000, "LReduce LONG sum")
LFree(lst)

PRINT "Test: LReduce on empty list"
sumResult = LReduce(LNil, BIND(@SumValues), 42&)
TkAssertEq&(sumResult, 42, "LReduce of empty returns initial")
PRINT

{* ============================================== *}
{* Test Group 14: Higher-Order Functions - LForEach *}
{* ============================================== *}
PRINT "=== LForEach (Higher-Order) ==="

' We'll use a shared variable to track calls
SHORTINT _forEachCount
_forEachCount = 0

DECLARE SUB ADDRESS CountCallback(ADDRESS carVal, SHORTINT typeTag) INVOKABLE

PRINT "Test: LForEach"
LNew
LAdd%(10)
LAdd%(20)
LAdd%(30)
lst = LEnd
_forEachCount = 0
LForEach(lst, BIND(@CountCallback))
TkAssertEq%(_forEachCount, 3, "LForEach called 3 times")
LFree(lst)

PRINT "Test: LForEach on empty list"
_forEachCount = 0
LForEach(LNil, BIND(@CountCallback))
TkAssertEq%(_forEachCount, 0, "LForEach on empty calls nothing")
PRINT

{* ============================================== *}
{* Test Group 15: Destructive Higher-Order - LNmap *}
{* ============================================== *}
PRINT "=== LNmap (Destructive Map) ==="

PRINT "Test: LNmap with SHORTINT list"
LNew
LAdd%(1)
LAdd%(2)
LAdd%(3)
lst = LEnd
LNmap(lst, BIND(@DoubleValue))
TkAssertEq%(LCar%(lst), 2, "LNmap first doubled in place")
TkAssertEq%(LCar%(LCdr(lst)), 4, "LNmap second doubled in place")
TkAssertEq%(LCar%(LCdr(LCdr(lst))), 6, "LNmap third doubled in place")
LFree(lst)

PRINT "Test: LNmap with LONGINT list"
LNew
LAdd&(100000&)
LAdd&(200000&)
lst = LEnd
LNmap(lst, BIND(@DoubleValue))
TkAssertEq&(LCar&(lst), 200000, "LNmap LONG first doubled in place")
LFree(lst)

PRINT "Test: LNmap with STRING list"
LNew
LAdd$("abc")
LAdd$("xyz")
lst = LEnd
LNmap(lst, BIND(@ToUpperStr))
TkAssertEqStr(LCar$(lst), "ABC", "LNmap STR first uppercased in place")
TkAssertEqStr(LCar$(LCdr(lst)), "XYZ", "LNmap STR second uppercased in place")
LFree(lst)
PRINT

{* ============================================== *}
{* Test Group 16: Destructive Higher-Order - LNfilter *}
{* ============================================== *}
PRINT "=== LNfilter (Destructive Filter) ==="

PRINT "Test: LNfilter with SHORTINT list"
LNew
LAdd%(1)
LAdd%(2)
LAdd%(3)
LAdd%(4)
LAdd%(5)
LAdd%(6)
lst = LEnd
lst = LNfilter(lst, BIND(@IsEvenValue))
TkAssertEq&(LLen(lst), 3, "LNfilter keeps only evens")
TkAssertEq%(LCar%(lst), 2, "LNfilter first even")
TkAssertEq%(LCar%(LCdr(lst)), 4, "LNfilter second even")
LFree(lst)

PRINT "Test: LNfilter removes first elements"
LNew
LAdd%(1)
LAdd%(3)
LAdd%(4)
LAdd%(5)
LAdd%(6)
lst = LEnd
lst = LNfilter(lst, BIND(@IsEvenValue))
TkAssertEq&(LLen(lst), 2, "LNfilter new head after removal")
TkAssertEq%(LCar%(lst), 4, "LNfilter new first is 4")
LFree(lst)

PRINT "Test: LNfilter all removed"
LNew
LAdd%(1)
LAdd%(3)
LAdd%(5)
lst = LEnd
lst = LNfilter(lst, BIND(@IsEvenValue))
TkAssertEqAddr(lst, LNil, "LNfilter all removed returns LNil")

PRINT "Test: LNfilter with LONGINT list"
LNew
LAdd&(-100&)
LAdd&(200&)
LAdd&(-300&)
LAdd&(400&)
lst = LEnd
lst = LNfilter(lst, BIND(@IsPositiveValue))
TkAssertEq&(LLen(lst), 2, "LNfilter keeps positives")
LFree(lst)

PRINT "Test: LNfilter with STRING list"
LNew
LAdd$("apple")
LAdd$("banana")
LAdd$("apricot")
lst = LEnd
lst = LNfilter(lst, BIND(@StartsWithA))
TkAssertEq&(LLen(lst), 2, "LNfilter keeps A-words")
TkAssertEqStr(LCar$(lst), "apple", "LNfilter first A-word")
LFree(lst)
PRINT

LCleanup

{* ============================================== *}
{* Results                                        *}
{* ============================================== *}
TkSummary

STOP

{* ============================================== *}
{* Callback Functions for Higher-Order Tests      *}
{* Generic callbacks receive (carValue, typeTag)  *}
{* ============================================== *}

{* Double any numeric value *}
SUB ADDRESS DoubleValue(ADDRESS carVal, SHORTINT typeTag) INVOKABLE
  SHORTINT intVal
  LONGINT lngVal
  SINGLE sngVal
  ADDRESS floatAddr

  IF typeTag = LTypeInt THEN
    intVal = carVal
    DoubleValue = intVal * 2
  ELSEIF typeTag = LTypeLng THEN
    lngVal = carVal
    DoubleValue = lngVal * 2
  ELSEIF typeTag = LTypeSng THEN
    floatAddr = VARPTR(sngVal)
    POKEL floatAddr, carVal
    sngVal = sngVal * 2.0!
    DoubleValue = PEEKL(floatAddr)
  ELSE
    DoubleValue = carVal
  END IF
END SUB

{* Convert string to uppercase *}
SUB ADDRESS ToUpperStr(ADDRESS carVal, SHORTINT typeTag) INVOKABLE
  SHARED _upperResult$
  STRING s
  SHORTINT i, c

  IF typeTag <> LTypeStr THEN
    ToUpperStr = carVal
    EXIT SUB
  END IF

  s = CSTR(carVal)
  _upperResult$ = ""
  FOR i = 1 TO LEN(s)
    c = ASC(MID$(s, i, 1))
    IF c >= 97 AND c <= 122 THEN
      c = c - 32
    END IF
    _upperResult$ = _upperResult$ + CHR$(c)
  NEXT
  ToUpperStr = SADD(_upperResult$)
END SUB

{* Check if numeric value is even *}
SUB SHORTINT IsEvenValue(ADDRESS carVal, SHORTINT typeTag) INVOKABLE
  SHORTINT intVal
  LONGINT lngVal

  IF typeTag = LTypeInt THEN
    intVal = carVal
    IF (intVal MOD 2) = 0 THEN
      IsEvenValue = -1
    ELSE
      IsEvenValue = 0
    END IF
  ELSEIF typeTag = LTypeLng THEN
    lngVal = carVal
    IF (lngVal MOD 2) = 0 THEN
      IsEvenValue = -1
    ELSE
      IsEvenValue = 0
    END IF
  ELSE
    IsEvenValue = 0
  END IF
END SUB

{* Check if numeric value is positive *}
SUB SHORTINT IsPositiveValue(ADDRESS carVal, SHORTINT typeTag) INVOKABLE
  SHORTINT intVal
  LONGINT lngVal

  IF typeTag = LTypeInt THEN
    intVal = carVal
    IF intVal > 0 THEN
      IsPositiveValue = -1
    ELSE
      IsPositiveValue = 0
    END IF
  ELSEIF typeTag = LTypeLng THEN
    lngVal = carVal
    IF lngVal > 0 THEN
      IsPositiveValue = -1
    ELSE
      IsPositiveValue = 0
    END IF
  ELSE
    IsPositiveValue = 0
  END IF
END SUB

{* Check if string starts with 'a' or 'A' *}
SUB SHORTINT StartsWithA(ADDRESS carVal, SHORTINT typeTag) INVOKABLE
  STRING s

  IF typeTag <> LTypeStr THEN
    StartsWithA = 0
    EXIT SUB
  END IF

  s = CSTR(carVal)
  IF LEFT$(s, 1) = "a" OR LEFT$(s, 1) = "A" THEN
    StartsWithA = -1
  ELSE
    StartsWithA = 0
  END IF
END SUB

{* Sum accumulator for reduce *}
SUB ADDRESS SumValues(ADDRESS acc, ADDRESS carVal, SHORTINT typeTag) INVOKABLE
  LONGINT accLng, valLng
  SHORTINT valInt

  accLng = acc
  IF typeTag = LTypeInt THEN
    valInt = carVal
    SumValues = accLng + valInt
  ELSEIF typeTag = LTypeLng THEN
    valLng = carVal
    SumValues = accLng + valLng
  ELSE
    SumValues = acc
  END IF
END SUB

{* Concat accumulator for reduce (not used in current tests) *}
SUB ADDRESS ConcatStrings(ADDRESS acc, ADDRESS carVal, SHORTINT typeTag) INVOKABLE
  ' String concat would need shared variable for result
  ConcatStrings = acc
END SUB

{* Count callback for ForEach *}
SUB ADDRESS CountCallback(ADDRESS carVal, SHORTINT typeTag) INVOKABLE
  SHARED _forEachCount
  _forEachCount = _forEachCount + 1
  CountCallback = 0
END SUB
