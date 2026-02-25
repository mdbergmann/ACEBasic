REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/json/json.o
REM #using ace:submods/testkit/testkit.o

{*
** test_free.b - Phase 6: JsFree + JsMakeObj/JsMakeArr
** Tests: recursive free, convenience constructors, null safety
*}

#include <submods/json.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== Phase 6: JsFree + Convenience ==="
PRINT

TkInit

STRING src$ SIZE 4096
STRING q$ SIZE 4
q$ = CHR$(34)

LONGINT root&

{* ============== Test 1: JsFree null safety ============== *}

PRINT "-- Test 1: JsFree null safety"
JsFree(0)
TkAssertTrue(-1, "JsFree(0) no crash")

{* ============== Test 2: JsFree simple object ============== *}

PRINT "-- Test 2: JsFree simple object"
src$ = "{" + q$ + "a" + q$ + ":" + q$ + "b" + q$ + "}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "free obj parse")
JsFree(root&)
TkAssertTrue(-1, "free obj no crash")

{* ============== Test 3: JsFree simple array ============== *}

PRINT "-- Test 3: JsFree simple array"
src$ = "[1,2,3]"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "free arr parse")
JsFree(root&)
TkAssertTrue(-1, "free arr no crash")

{* ============== Test 4: JsFree empty object ============== *}

PRINT "-- Test 4: JsFree empty object"
src$ = "{}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "free {} parse")
JsFree(root&)
TkAssertTrue(-1, "free {} no crash")

{* ============== Test 5: JsFree empty array ============== *}

PRINT "-- Test 5: JsFree empty array"
src$ = "[]"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "free [] parse")
JsFree(root&)
TkAssertTrue(-1, "free [] no crash")

{* ============== Test 6: JsFree nested object ============== *}

PRINT "-- Test 6: JsFree nested object"
src$ = "{" + q$ + "inner" + q$ + ":{" + q$ + "x" + q$ + ":1}}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "free nested parse")
JsFree(root&)
TkAssertTrue(-1, "free nested no crash")

{* ============== Test 7: JsFree nested array in object ============== *}

PRINT "-- Test 7: JsFree nested array in object"
src$ = "{" + q$ + "arr" + q$ + ":[10,20,30]}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "free arr-in-obj parse")
JsFree(root&)
TkAssertTrue(-1, "free arr-in-obj no crash")

{* ============== Test 8: JsFree deeply nested ============== *}

PRINT "-- Test 8: JsFree deeply nested"
' {"d":[{"v":7,"sub":{"k":"val"}},true]}
src$ = "{" + q$ + "d" + q$ + ":[{" + q$ + "v" + q$ + ":7,"
src$ = src$ + q$ + "sub" + q$ + ":{" + q$ + "k" + q$ + ":"
src$ = src$ + q$ + "val" + q$ + "}},true]}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "free deep parse")
JsFree(root&)
TkAssertTrue(-1, "free deep no crash")

{* ============== Test 9: JsFree array of arrays ============== *}

PRINT "-- Test 9: JsFree array of arrays"
src$ = "[[1,2],[3,4]]"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "free arr-arr parse")
JsFree(root&)
TkAssertTrue(-1, "free arr-arr no crash")

{* ============== Test 10: JsFree mixed types ============== *}

PRINT "-- Test 10: JsFree mixed types"
src$ = "{" + q$ + "s" + q$ + ":" + q$ + "hi" + q$ + ","
src$ = src$ + q$ + "i" + q$ + ":42,"
src$ = src$ + q$ + "b" + q$ + ":true,"
src$ = src$ + q$ + "n" + q$ + ":null,"
src$ = src$ + q$ + "a" + q$ + ":[1]}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "free mixed parse")
JsFree(root&)
TkAssertTrue(-1, "free mixed no crash")

{* ============== Test 11: JsMakeObj produces TYPECASE-able instance ============== *}

PRINT "-- Test 11: JsMakeObj TYPECASE"
DECLARE CLASS Hashmap hm
JsMakeObj(hm, HM_SMALL)
HmPut$(hm, "test", "ok")
SHORTINT isObj%
isObj% = 0

DECLARE CLASS Hashmap tc
tc = hm
TYPECASE tc
  CASE Hashmap
    isObj% = -1
END TYPECASE

TkAssertTrue(isObj%, "JsMakeObj typecase")
TkAssertEqStr(HmGet$(hm, "test"), "ok", "JsMakeObj val")
HmFree(hm)

{* ============== Test 12: JsMakeArr produces TYPECASE-able instance ============== *}

PRINT "-- Test 12: JsMakeArr TYPECASE"
DECLARE CLASS DynArray da
JsMakeArr(da, DA_SMALL)
DaAppend&(da, 77)
SHORTINT isArr%
isArr% = 0

tc = da
TYPECASE tc
  CASE DynArray
    isArr% = -1
END TYPECASE

TkAssertTrue(isArr%, "JsMakeArr typecase")
TkAssertEq&(DaGet&(da, 0), 77, "JsMakeArr val")
DaFree(da)

{* ============== Test 13: Parse + use + JsFree full cycle ============== *}

PRINT "-- Test 13: Parse + use + JsFree full cycle"
src$ = "{" + q$ + "msg" + q$ + ":" + q$ + "hello" + q$ + ","
src$ = src$ + q$ + "nums" + q$ + ":[1,2,3]}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "cycle parse")

' Access values before freeing
DECLARE CLASS Hashmap doc
doc = root&
TkAssertEqStr(HmGet$(doc, "msg"), "hello", "cycle msg")

LONGINT ref&
ref& = HmGetRef(doc, "nums")
TkAssertTrue(ref& <> 0, "cycle nums ref")

DECLARE CLASS DynArray nums
nums = ref&
TkAssertEq&(DaCount(nums), 3, "cycle nums count")
TkAssertEq&(DaGet&(nums, 0), 1, "cycle nums[0]")
TkAssertEq&(DaGet&(nums, 2), 3, "cycle nums[2]")

' Now free the entire tree
JsFree(root&)
TkAssertTrue(-1, "cycle free no crash")

{* ============== Summary ============== *}
TkSummary
