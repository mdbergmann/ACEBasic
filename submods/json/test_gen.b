REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/json/json.o
REM #using ace:submods/testkit/testkit.o

{*
** test_gen.b - Phase 4: Generate compact JSON output
** Tests: JsWrite, JsToStr$
** Builds data structures manually and verifies generated output.
*}

#include <submods/json.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== Phase 4: Generate Compact JSON ==="
PRINT

TkInit

STRING result$ SIZE 4096
STRING expected$ SIZE 4096
STRING q$ SIZE 4
q$ = CHR$(34)

DECLARE CLASS Hashmap hm
DECLARE CLASS DynArray da

{* ============== Test 1: Empty object ============== *}

PRINT "-- Test 1: Empty object"
HmMake(hm, HM_SMALL)
result$ = JsToStr$(hm)
TkAssertEqStr(result$, "{}", "empty obj = {}")
HmFree(hm)

{* ============== Test 2: Single string ============== *}

PRINT "-- Test 2: Single string"
HmMake(hm, HM_SMALL)
HmPut$(hm, "city", "Berlin")
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "city" + q$ + ":" + q$ + "Berlin" + q$ + "}"
TkAssertEqStr(result$, expected$, "single str obj")
HmFree(hm)

{* ============== Test 3: Integer value ============== *}

PRINT "-- Test 3: Integer value"
HmMake(hm, HM_SMALL)
HmPut&(hm, "age", 30)
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "age" + q$ + ":30}"
TkAssertEqStr(result$, expected$, "int val obj")
HmFree(hm)

{* ============== Test 4: Negative integer ============== *}

PRINT "-- Test 4: Negative integer"
HmMake(hm, HM_SMALL)
HmPut&(hm, "n", -5)
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "n" + q$ + ":-5}"
TkAssertEqStr(result$, expected$, "neg int obj")
HmFree(hm)

{* ============== Test 5: Boolean true ============== *}

PRINT "-- Test 5: Boolean true"
HmMake(hm, HM_SMALL)
HmPutBool(hm, "flag", -1)
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "flag" + q$ + ":true}"
TkAssertEqStr(result$, expected$, "bool true obj")
HmFree(hm)

{* ============== Test 6: Boolean false ============== *}

PRINT "-- Test 6: Boolean false"
HmMake(hm, HM_SMALL)
HmPutBool(hm, "flag", 0)
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "flag" + q$ + ":false}"
TkAssertEqStr(result$, expected$, "bool false obj")
HmFree(hm)

{* ============== Test 7: Null value ============== *}

PRINT "-- Test 7: Null value"
HmMake(hm, HM_SMALL)
HmPutNull(hm, "x")
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "x" + q$ + ":null}"
TkAssertEqStr(result$, expected$, "null val obj")
HmFree(hm)

{* ============== Test 8: Multiple values ============== *}

PRINT "-- Test 8: Multiple values"
HmMake(hm, HM_SMALL)
HmPut$(hm, "a", "x")
HmPut&(hm, "b", 1)
HmPutBool(hm, "c", -1)
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "a" + q$ + ":" + q$ + "x" + q$ + ","
expected$ = expected$ + q$ + "b" + q$ + ":1,"
expected$ = expected$ + q$ + "c" + q$ + ":true}"
TkAssertEqStr(result$, expected$, "multi val obj")
HmFree(hm)

{* ============== Test 9: Empty array ============== *}

PRINT "-- Test 9: Empty array"
DaMake(da, DA_SMALL)
result$ = JsToStr$(da)
TkAssertEqStr(result$, "[]", "empty arr = []")
DaFree(da)

{* ============== Test 10: String array ============== *}

PRINT "-- Test 10: String array"
DaMake(da, DA_SMALL)
DaAppend$(da, "aaa")
DaAppend$(da, "bbb")
result$ = JsToStr$(da)
expected$ = "[" + q$ + "aaa" + q$ + "," + q$ + "bbb" + q$ + "]"
TkAssertEqStr(result$, expected$, "str array")
DaFree(da)

{* ============== Test 11: Integer array ============== *}

PRINT "-- Test 11: Integer array"
DaMake(da, DA_SMALL)
DaAppend&(da, 1)
DaAppend&(da, -2)
DaAppend&(da, 0)
result$ = JsToStr$(da)
TkAssertEqStr(result$, "[1,-2,0]", "int array")
DaFree(da)

{* ============== Test 12: Mixed type array ============== *}

PRINT "-- Test 12: Mixed type array"
DaMake(da, DA_SMALL)
DaAppend$(da, "hi")
DaAppend&(da, 42)
DaAppendBool(da, -1)
DaAppendNull(da)
result$ = JsToStr$(da)
expected$ = "[" + q$ + "hi" + q$ + ",42,true,null]"
TkAssertEqStr(result$, expected$, "mixed array")
DaFree(da)

{* ============== Test 13: Nested object ============== *}

PRINT "-- Test 13: Nested object"
DECLARE CLASS Hashmap inner
HmMake(inner, HM_SMALL)
HmPut&(inner, "x", 1)
HmMake(hm, HM_SMALL)
HmPutRef(hm, "inner", inner)
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "inner" + q$ + ":{" + q$ + "x" + q$ + ":1}}"
TkAssertEqStr(result$, expected$, "nested obj")
HmFree(inner)
HmFree(hm)

{* ============== Test 14: Nested array in object ============== *}

PRINT "-- Test 14: Nested array in object"
DaMake(da, DA_SMALL)
DaAppend&(da, 10)
DaAppend&(da, 20)
HmMake(hm, HM_SMALL)
HmPutRef(hm, "nums", da)
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "nums" + q$ + ":[10,20]}"
TkAssertEqStr(result$, expected$, "arr in obj")
DaFree(da)
HmFree(hm)

{* ============== Test 15: Nested object in array ============== *}

PRINT "-- Test 15: Nested object in array"
HmMake(inner, HM_SMALL)
HmPut$(inner, "k", "v")
DaMake(da, DA_SMALL)
DaAppendRef(da, inner)
result$ = JsToStr$(da)
expected$ = "[{" + q$ + "k" + q$ + ":" + q$ + "v" + q$ + "}]"
TkAssertEqStr(result$, expected$, "obj in arr")
HmFree(inner)
DaFree(da)

{* ============== Test 16: String escaping - quote ============== *}

PRINT "-- Test 16: String escaping - quote"
HmMake(hm, HM_SMALL)
HmPut$(hm, "k", "a" + CHR$(34) + "b")
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "k" + q$ + ":" + q$ + "a\" + q$ + "b" + q$ + "}"
TkAssertEqStr(result$, expected$, "escape quote")
HmFree(hm)

{* ============== Test 17: String escaping - backslash ============== *}

PRINT "-- Test 17: String escaping - backslash"
HmMake(hm, HM_SMALL)
HmPut$(hm, "k", "a\b")
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "k" + q$ + ":" + q$ + "a\\b" + q$ + "}"
TkAssertEqStr(result$, expected$, "escape backslash")
HmFree(hm)

{* ============== Test 18: String escaping - newline ============== *}

PRINT "-- Test 18: String escaping - newline"
HmMake(hm, HM_SMALL)
HmPut$(hm, "k", "a" + CHR$(10) + "b")
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "k" + q$ + ":" + q$ + "a\nb" + q$ + "}"
TkAssertEqStr(result$, expected$, "escape newline")
HmFree(hm)

{* ============== Test 19: String escaping - tab ============== *}

PRINT "-- Test 19: String escaping - tab"
HmMake(hm, HM_SMALL)
HmPut$(hm, "k", "a" + CHR$(9) + "b")
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "k" + q$ + ":" + q$ + "a\tb" + q$ + "}"
TkAssertEqStr(result$, expected$, "escape tab")
HmFree(hm)

{* ============== Test 20: JsWrite to file ============== *}

PRINT "-- Test 20: JsWrite to file"
HmMake(hm, HM_SMALL)
HmPut$(hm, "msg", "ok")
OPEN "O", #1, "T:js_test.json"
JsWrite(hm, 1)
CLOSE #1
STRING fLine$ SIZE 1024
OPEN "I", #1, "T:js_test.json"
LINE INPUT #1, fLine$
CLOSE #1
expected$ = "{" + q$ + "msg" + q$ + ":" + q$ + "ok" + q$ + "}"
TkAssertEqStr(fLine$, expected$, "JsWrite to file")
HmFree(hm)

{* ============== Test 21: Deeply nested (obj > arr > obj) ============== *}

PRINT "-- Test 21: Deeply nested"
DECLARE CLASS Hashmap deep
HmMake(deep, HM_SMALL)
HmPut&(deep, "v", 7)
DaMake(da, DA_SMALL)
DaAppendRef(da, deep)
HmMake(hm, HM_SMALL)
HmPutRef(hm, "arr", da)
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "arr" + q$ + ":[{" + q$ + "v" + q$ + ":7}]}"
TkAssertEqStr(result$, expected$, "deep nested")
HmFree(deep)
DaFree(da)
HmFree(hm)

{* ============== Test 22: Key escaping ============== *}

PRINT "-- Test 22: Key escaping"
HmMake(hm, HM_SMALL)
HmPut&(hm, "a" + CHR$(34) + "b", 1)
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "a\" + q$ + "b" + q$ + ":1}"
TkAssertEqStr(result$, expected$, "key with quote")
HmFree(hm)

{* ============== Test 23: Empty string value ============== *}

PRINT "-- Test 23: Empty string value"
HmMake(hm, HM_SMALL)
HmPut$(hm, "e", "")
result$ = JsToStr$(hm)
expected$ = "{" + q$ + "e" + q$ + ":" + q$ + q$ + "}"
TkAssertEqStr(result$, expected$, "empty str val")
HmFree(hm)

{* ============== Summary ============== *}
TkSummary
