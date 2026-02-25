REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/json/json.o
REM #using ace:submods/testkit/testkit.o

{*
** test_parse_obj.b - Phase 1: Parse JSON objects with scalar values
** Tests: JsParse, JsError$, JsRootType
** Value types: string, integer, boolean, null
*}

#include <submods/json.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== Phase 1: Parse JSON Objects ==="
PRINT

TkInit

STRING src$ SIZE 4096
STRING errMsg$ SIZE 128
STRING q$ SIZE 4
q$ = CHR$(34)

LONGINT root&
DECLARE CLASS Hashmap hm

{* ============== Test 1: Empty object ============== *}

PRINT "-- Test 1: Empty object"
src$ = "{}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse {} not null")
IF root& <> 0 THEN
  TkAssertEq%(JsRootType, JsObject, "root type = object")
  hm = root&
  TkAssertEq&(HmCount(hm), 0, "empty count = 0")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 2: Single string ============== *}

PRINT "-- Test 2: Single string"
src$ = "{" + q$ + "city" + q$ + ":" + q$ + "Berlin" + q$ + "}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse single str")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq&(HmCount(hm), 1, "count = 1")
  TkAssertEqStr(HmGet$(hm, "city"), "Berlin", "city = Berlin")
  TkAssertEq%(HmType(hm, "city"), HmTypeStr, "city type = str")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 3: Multiple strings ============== *}

PRINT "-- Test 3: Multiple strings"
src$ = "{" + q$ + "a" + q$ + ":" + q$ + "one" + q$ + ","
src$ = src$ + q$ + "b" + q$ + ":" + q$ + "two" + q$ + "}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse multi str")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq&(HmCount(hm), 2, "count = 2")
  TkAssertEqStr(HmGet$(hm, "a"), "one", "a = one")
  TkAssertEqStr(HmGet$(hm, "b"), "two", "b = two")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 4: Integer values ============== *}

PRINT "-- Test 4: Integer values"
src$ = "{" + q$ + "pos" + q$ + ":42,"
src$ = src$ + q$ + "neg" + q$ + ":-7,"
src$ = src$ + q$ + "zero" + q$ + ":0}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse integers")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq&(HmCount(hm), 3, "count = 3")
  TkAssertEq&(HmGet&(hm, "pos"), 42, "pos = 42")
  TkAssertEq&(HmGet&(hm, "neg"), -7, "neg = -7")
  TkAssertEq&(HmGet&(hm, "zero"), 0, "zero = 0")
  TkAssertEq%(HmType(hm, "pos"), HmTypeLng, "pos type = lng")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 5: Boolean values ============== *}

PRINT "-- Test 5: Boolean values"
src$ = "{" + q$ + "on" + q$ + ":true,"
src$ = src$ + q$ + "off" + q$ + ":false}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse booleans")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq&(HmCount(hm), 2, "count = 2")
  TkAssertEq%(HmType(hm, "on"), HmTypeBool, "on type = bool")
  TkAssertEq%(HmType(hm, "off"), HmTypeBool, "off type = bool")
  TkAssertEq&(HmGet&(hm, "on"), 1, "on = 1 (true)")
  TkAssertEq&(HmGet&(hm, "off"), 0, "off = 0 (false)")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 6: Null value ============== *}

PRINT "-- Test 6: Null value"
src$ = "{" + q$ + "gone" + q$ + ":null}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse null")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq&(HmCount(hm), 1, "count = 1")
  TkAssertEq%(HmType(hm, "gone"), HmTypeNull, "gone type = null")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 7: Mixed types ============== *}

PRINT "-- Test 7: Mixed types"
src$ = "{" + q$ + "nm" + q$ + ":" + q$ + "Alice" + q$ + ","
src$ = src$ + q$ + "ag" + q$ + ":30,"
src$ = src$ + q$ + "ok" + q$ + ":true,"
src$ = src$ + q$ + "rm" + q$ + ":null}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse mixed")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq&(HmCount(hm), 4, "count = 4")
  TkAssertEqStr(HmGet$(hm, "nm"), "Alice", "nm = Alice")
  TkAssertEq&(HmGet&(hm, "ag"), 30, "ag = 30")
  TkAssertEq%(HmType(hm, "ok"), HmTypeBool, "ok type = bool")
  TkAssertEq%(HmType(hm, "rm"), HmTypeNull, "rm type = null")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 8: Whitespace tolerance ============== *}

PRINT "-- Test 8: Whitespace tolerance"
src$ = "  { " + q$ + "x" + q$ + " : " + q$ + "y" + q$ + " } "
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse with whitespace")
IF root& <> 0 THEN
  hm = root&
  TkAssertEqStr(HmGet$(hm, "x"), "y", "x = y")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 9: Error - missing colon ============== *}

PRINT "-- Test 9: Error - missing colon"
src$ = "{" + q$ + "x" + q$ + " " + q$ + "y" + q$ + "}"
root& = JsParse(src$)
TkAssertEq&(root&, 0, "missing colon -> null")
errMsg$ = JsError$
TkAssertTrue(LEN(errMsg$) > 0, "missing colon -> error msg")

{* ============== Test 10: Error - unterminated string ============== *}

PRINT "-- Test 10: Error - unterminated string"
src$ = "{" + q$ + "x" + q$ + ":" + q$ + "hello}"
root& = JsParse(src$)
TkAssertEq&(root&, 0, "unterm string -> null")
errMsg$ = JsError$
TkAssertTrue(LEN(errMsg$) > 0, "unterm string -> error msg")

{* ============== Test 11: Error - trailing comma ============== *}

PRINT "-- Test 11: Error - trailing comma"
src$ = "{" + q$ + "x" + q$ + ":1,}"
root& = JsParse(src$)
TkAssertEq&(root&, 0, "trailing comma -> null")
errMsg$ = JsError$
TkAssertTrue(LEN(errMsg$) > 0, "trailing comma -> error msg")

{* ============== Test 12: Error - invalid input ============== *}

PRINT "-- Test 12: Error - invalid input"
src$ = "hello"
root& = JsParse(src$)
TkAssertEq&(root&, 0, "invalid input -> null")
errMsg$ = JsError$
TkAssertTrue(LEN(errMsg$) > 0, "invalid input -> error msg")

{* ============== Test 13: Large integer ============== *}

PRINT "-- Test 13: Large integer"
src$ = "{" + q$ + "big" + q$ + ":1000000}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse large int")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq&(HmGet&(hm, "big"), 1000000, "big = 1000000")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Summary ============== *}
TkSummary
