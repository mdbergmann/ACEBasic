REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/json/json.o
REM #using ace:submods/testkit/testkit.o

{*
** test_roundtrip.b - Phase 5: Pretty printer + round-trip
** Tests: JsWriteFmt, parse->generate->compare
** Note: JsFree not yet implemented (Phase 6), parsed trees are leaked.
*}

#include <submods/json.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== Phase 5: Pretty Printer + Round-Trip ==="
PRINT

TkInit

STRING result$ SIZE 4096
STRING expected$ SIZE 4096
STRING src$ SIZE 4096
STRING ln$ SIZE 512
STRING q$ SIZE 4
q$ = CHR$(34)

LONGINT root&, root2&
DECLARE CLASS Hashmap hm
DECLARE CLASS DynArray da

{* ============== Test 1: Fmt empty object ============== *}

PRINT "-- Test 1: Fmt empty object"
HmMake(hm, HM_SMALL)
OPEN "O", #1, "T:jsfmt.txt"
JsWriteFmt(hm, 1)
CLOSE #1
OPEN "I", #1, "T:jsfmt.txt"
LINE INPUT #1, ln$
CLOSE #1
TkAssertEqStr(ln$, "{}", "fmt empty obj")
HmFree(hm)

{* ============== Test 2: Fmt empty array ============== *}

PRINT "-- Test 2: Fmt empty array"
DaMake(da, DA_SMALL)
OPEN "O", #1, "T:jsfmt.txt"
JsWriteFmt(da, 1)
CLOSE #1
OPEN "I", #1, "T:jsfmt.txt"
LINE INPUT #1, ln$
CLOSE #1
TkAssertEqStr(ln$, "[]", "fmt empty arr")
DaFree(da)

{* ============== Test 3: Fmt single-key object ============== *}

PRINT "-- Test 3: Fmt single-key object"
HmMake(hm, HM_SMALL)
HmPut$(hm, "city", "Berlin")
OPEN "O", #1, "T:jsfmt.txt"
JsWriteFmt(hm, 1)
CLOSE #1
OPEN "I", #1, "T:jsfmt.txt"
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "{", "fmt obj L1 {")
LINE INPUT #1, ln$
expected$ = "  " + q$ + "city" + q$ + ": " + q$ + "Berlin" + q$
TkAssertEqStr(ln$, expected$, "fmt obj L2 kv")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "}", "fmt obj L3 }")
CLOSE #1
HmFree(hm)

{* ============== Test 4: Fmt integer array ============== *}

PRINT "-- Test 4: Fmt integer array"
DaMake(da, DA_SMALL)
DaAppend&(da, 10)
DaAppend&(da, 20)
DaAppend&(da, 30)
OPEN "O", #1, "T:jsfmt.txt"
JsWriteFmt(da, 1)
CLOSE #1
OPEN "I", #1, "T:jsfmt.txt"
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "[", "fmt arr L1 [")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "  10,", "fmt arr L2 10,")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "  20,", "fmt arr L3 20,")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "  30", "fmt arr L4 30")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "]", "fmt arr L5 ]")
CLOSE #1
DaFree(da)

{* ============== Test 5: Fmt nested array in object ============== *}

PRINT "-- Test 5: Fmt nested array in object"
DaMake(da, DA_SMALL)
DaAppend&(da, 1)
DaAppend&(da, 2)
HmMake(hm, HM_SMALL)
HmPutRef(hm, "arr", da)
OPEN "O", #1, "T:jsfmt.txt"
JsWriteFmt(hm, 1)
CLOSE #1
OPEN "I", #1, "T:jsfmt.txt"
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "{", "fmt nest L1 {")
LINE INPUT #1, ln$
expected$ = "  " + q$ + "arr" + q$ + ": ["
TkAssertEqStr(ln$, expected$, "fmt nest L2 arr:[")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "    1,", "fmt nest L3 1,")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "    2", "fmt nest L4 2")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "  ]", "fmt nest L5 ]")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "}", "fmt nest L6 }")
CLOSE #1
DaFree(da)
HmFree(hm)

{* ============== Test 6: Fmt nested object in object ============== *}

PRINT "-- Test 6: Fmt nested object in object"
DECLARE CLASS Hashmap inner
HmMake(inner, HM_SMALL)
HmPut&(inner, "x", 99)
HmMake(hm, HM_SMALL)
HmPutRef(hm, "obj", inner)
OPEN "O", #1, "T:jsfmt.txt"
JsWriteFmt(hm, 1)
CLOSE #1
OPEN "I", #1, "T:jsfmt.txt"
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "{", "fmt nobj L1 {")
LINE INPUT #1, ln$
expected$ = "  " + q$ + "obj" + q$ + ": {"
TkAssertEqStr(ln$, expected$, "fmt nobj L2 obj:{")
LINE INPUT #1, ln$
expected$ = "    " + q$ + "x" + q$ + ": 99"
TkAssertEqStr(ln$, expected$, "fmt nobj L3 x:99")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "  }", "fmt nobj L4 }")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "}", "fmt nobj L5 }")
CLOSE #1
HmFree(inner)
HmFree(hm)

{* ============== Test 7: Fmt bool/null array ============== *}

PRINT "-- Test 7: Fmt bool/null array"
DaMake(da, DA_SMALL)
DaAppendBool(da, -1)
DaAppendNull(da)
DaAppendBool(da, 0)
OPEN "O", #1, "T:jsfmt.txt"
JsWriteFmt(da, 1)
CLOSE #1
OPEN "I", #1, "T:jsfmt.txt"
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "[", "fmt bnl L1")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "  true,", "fmt bnl L2")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "  null,", "fmt bnl L3")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "  false", "fmt bnl L4")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "]", "fmt bnl L5")
CLOSE #1
DaFree(da)

{* ============== Test 8: Compact round-trip int array ============== *}

PRINT "-- Test 8: Compact round-trip int array"
src$ = "[1,-2,0,999]"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "rt intarr parse")
result$ = JsToStr$(root&)
TkAssertEqStr(result$, src$, "rt intarr match")

{* ============== Test 9: Compact round-trip string array ============== *}

PRINT "-- Test 9: Compact round-trip string array"
src$ = "[" + q$ + "aaa" + q$ + "," + q$ + "bbb" + q$ + "]"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "rt strarr parse")
result$ = JsToStr$(root&)
TkAssertEqStr(result$, src$, "rt strarr match")

{* ============== Test 10: Compact round-trip mixed array ============== *}

PRINT "-- Test 10: Compact round-trip mixed array"
src$ = "[42," + q$ + "hi" + q$ + ",true,false,null]"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "rt mixarr parse")
result$ = JsToStr$(root&)
TkAssertEqStr(result$, src$, "rt mixarr match")

{* ============== Test 11: Compact round-trip single-key obj ============== *}

PRINT "-- Test 11: Compact round-trip single-key object"
src$ = "{" + q$ + "n" + q$ + ":42}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "rt 1key parse")
result$ = JsToStr$(root&)
TkAssertEqStr(result$, src$, "rt 1key match")

{* ============== Test 12: Compact round-trip string escapes ============== *}

PRINT "-- Test 12: Compact round-trip string escapes"
' Input: {"k":"a\"b\\c"}
src$ = "{" + q$ + "k" + q$ + ":" + q$ + "a\" + q$ + "b\\c" + q$ + "}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "rt esc parse")
result$ = JsToStr$(root&)
TkAssertEqStr(result$, src$, "rt esc match")

{* ============== Test 13: Compact round-trip nested ============== *}

PRINT "-- Test 13: Compact round-trip nested"
' Single-key objects preserve order -> string comparison works
src$ = "{" + q$ + "a" + q$ + ":[1,2]}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "rt nest parse")
result$ = JsToStr$(root&)
TkAssertEqStr(result$, src$, "rt nest match")

{* ============== Test 14: Fmt round-trip (format then parse back) ============== *}

PRINT "-- Test 14: Fmt round-trip array"
DaMake(da, DA_SMALL)
DaAppend$(da, "hello")
DaAppend&(da, 42)
DaAppendBool(da, -1)
OPEN "O", #1, "T:jsfmt_rt.json"
JsWriteFmt(da, 1)
CLOSE #1
DaFree(da)

' Parse the formatted output back
OPEN "I", #1, "T:jsfmt_rt.json"
root& = JsParseFile(1)
CLOSE #1
TkAssertTrue(root& <> 0, "fmt rt parse ok")

DECLARE CLASS DynArray da2
da2 = root&
TkAssertEq&(DaCount(da2), 3, "fmt rt count")
TkAssertEqStr(DaGet$(da2, 0), "hello", "fmt rt str")
TkAssertEq&(DaGet&(da2, 1), 42, "fmt rt int")
TkAssertEq&(DaGet&(da2, 2), 1, "fmt rt bool")

{* ============== Test 15: Fmt round-trip object ============== *}

PRINT "-- Test 15: Fmt round-trip object"
HmMake(hm, HM_SMALL)
HmPut$(hm, "msg", "ok")
HmPut&(hm, "code", 200)
HmPutBool(hm, "flag", 0)
HmPutNull(hm, "nil")
OPEN "O", #1, "T:jsfmt_rt.json"
JsWriteFmt(hm, 1)
CLOSE #1
HmFree(hm)

' Parse back
OPEN "I", #1, "T:jsfmt_rt.json"
root& = JsParseFile(1)
CLOSE #1
TkAssertTrue(root& <> 0, "fmt rt obj parse")

DECLARE CLASS Hashmap doc
doc = root&
TkAssertEqStr(HmGet$(doc, "msg"), "ok", "fmt rt obj str")
TkAssertEq&(HmGet&(doc, "code"), 200, "fmt rt obj int")
TkAssertTrue(HmHas(doc, "flag"), "fmt rt obj has flag")
TkAssertEq%(HmType(doc, "nil"), HmTypeNull, "fmt rt obj null")

{* ============== Test 16: Type preservation after round-trip ============== *}

PRINT "-- Test 16: Type preservation"
src$ = "{" + q$ + "i" + q$ + ":7," + q$ + "b" + q$ + ":true,"
src$ = src$ + q$ + "n" + q$ + ":null}"
root& = JsParse(src$)
TkAssertTrue(root& <> 0, "tp parse ok")

doc = root&
TkAssertEq%(HmType(doc, "i"), HmTypeLng, "tp int type")
TkAssertEq%(HmType(doc, "b"), HmTypeBool, "tp bool type")
TkAssertEq%(HmType(doc, "n"), HmTypeNull, "tp null type")

' Generate and parse again
result$ = JsToStr$(root&)
root2& = JsParse(result$)
TkAssertTrue(root2& <> 0, "tp reparse ok")
doc = root2&
TkAssertEq%(HmType(doc, "i"), HmTypeLng, "tp2 int type")
TkAssertEq&(HmGet&(doc, "i"), 7, "tp2 int val")
TkAssertEq%(HmType(doc, "b"), HmTypeBool, "tp2 bool type")
TkAssertEq%(HmType(doc, "n"), HmTypeNull, "tp2 null type")

{* ============== Test 17: Deep nesting pretty-print ============== *}

PRINT "-- Test 17: Deep nesting pretty-print"
' Build: {"d":[{"v":7}]}
DECLARE CLASS Hashmap deep
HmMake(deep, HM_SMALL)
HmPut&(deep, "v", 7)
DaMake(da, DA_SMALL)
DaAppendRef(da, deep)
HmMake(hm, HM_SMALL)
HmPutRef(hm, "d", da)
OPEN "O", #1, "T:jsfmt.txt"
JsWriteFmt(hm, 1)
CLOSE #1
OPEN "I", #1, "T:jsfmt.txt"
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "{", "fmt deep L1")
LINE INPUT #1, ln$
expected$ = "  " + q$ + "d" + q$ + ": ["
TkAssertEqStr(ln$, expected$, "fmt deep L2")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "    {", "fmt deep L3")
LINE INPUT #1, ln$
expected$ = "      " + q$ + "v" + q$ + ": 7"
TkAssertEqStr(ln$, expected$, "fmt deep L4")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "    }", "fmt deep L5")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "  ]", "fmt deep L6")
LINE INPUT #1, ln$
TkAssertEqStr(ln$, "}", "fmt deep L7")
CLOSE #1
HmFree(deep)
DaFree(da)
HmFree(hm)

{* ============== Summary ============== *}
TkSummary
