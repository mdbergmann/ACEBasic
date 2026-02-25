REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/json/json.o
REM #using ace:submods/testkit/testkit.o

{*
** test_parse_arr.b - Phase 2: Parse JSON arrays, nesting, floats
** Tests: arrays, nested objects/arrays, float values, TYPECASE, depth limit
*}

#include <submods/json.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== Phase 2: Parse Arrays, Nesting, Floats ==="
PRINT

TkInit

STRING src$ SIZE 4096
STRING errMsg$ SIZE 128
STRING q$ SIZE 4
q$ = CHR$(34)

LONGINT root&, ref&
DECLARE CLASS Hashmap hm
DECLARE CLASS DynArray da
DECLARE CLASS DynArray innerDa
DECLARE CLASS Hashmap innerHm
SHORTINT matched%

{* ============== Test 1: Empty array ============== *}

PRINT "-- Test 1: Empty array"
src$ = "[]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse [] not null")
IF root& <> 0 THEN
  TkAssertEq%(JsRootType, JsArray, "root type = array")
  da = root&
  TkAssertEq&(DaCount(da), 0, "empty count = 0")
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 2: Array of strings ============== *}

PRINT "-- Test 2: Array of strings"
src$ = "[" + q$ + "aaa" + q$ + "," + q$ + "bbb" + q$ + "," + q$ + "ccc" + q$ + "]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse str array")
IF root& <> 0 THEN
  da = root&
  TkAssertEq&(DaCount(da), 3, "str arr count = 3")
  TkAssertEqStr(DaGet$(da, 0), "aaa", "elem 0 = aaa")
  TkAssertEqStr(DaGet$(da, 1), "bbb", "elem 1 = bbb")
  TkAssertEqStr(DaGet$(da, 2), "ccc", "elem 2 = ccc")
  TkAssertEq%(DaType(da, 0), DaTypeStr, "elem 0 type = str")
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 3: Array of integers ============== *}

PRINT "-- Test 3: Array of integers"
src$ = "[10, -20, 0, 999]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse int array")
IF root& <> 0 THEN
  da = root&
  TkAssertEq&(DaCount(da), 4, "int arr count = 4")
  TkAssertEq&(DaGet&(da, 0), 10, "elem 0 = 10")
  TkAssertEq&(DaGet&(da, 1), -20, "elem 1 = -20")
  TkAssertEq&(DaGet&(da, 2), 0, "elem 2 = 0")
  TkAssertEq&(DaGet&(da, 3), 999, "elem 3 = 999")
  TkAssertEq%(DaType(da, 0), DaTypeLng, "elem 0 type = lng")
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 4: Array of booleans ============== *}

PRINT "-- Test 4: Array of booleans"
src$ = "[true, false, true]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse bool array")
IF root& <> 0 THEN
  da = root&
  TkAssertEq&(DaCount(da), 3, "bool arr count = 3")
  TkAssertEq%(DaType(da, 0), DaTypeBool, "elem 0 type = bool")
  TkAssertEq%(DaType(da, 1), DaTypeBool, "elem 1 type = bool")
  TkAssertEq&(DaGet&(da, 0), 1, "elem 0 = 1 (true)")
  TkAssertEq&(DaGet&(da, 1), 0, "elem 1 = 0 (false)")
  TkAssertEq&(DaGet&(da, 2), 1, "elem 2 = 1 (true)")
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 5: Array with nulls ============== *}

PRINT "-- Test 5: Array with nulls"
src$ = "[null, null]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse null array")
IF root& <> 0 THEN
  da = root&
  TkAssertEq&(DaCount(da), 2, "null arr count = 2")
  TkAssertEq%(DaType(da, 0), DaTypeNull, "elem 0 type = null")
  TkAssertEq%(DaType(da, 1), DaTypeNull, "elem 1 type = null")
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 6: Mixed-type array ============== *}

PRINT "-- Test 6: Mixed-type array"
src$ = "[" + q$ + "hi" + q$ + ", 42, true, null]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse mixed array")
IF root& <> 0 THEN
  da = root&
  TkAssertEq&(DaCount(da), 4, "mixed arr count = 4")
  TkAssertEq%(DaType(da, 0), DaTypeStr, "elem 0 type = str")
  TkAssertEq%(DaType(da, 1), DaTypeLng, "elem 1 type = lng")
  TkAssertEq%(DaType(da, 2), DaTypeBool, "elem 2 type = bool")
  TkAssertEq%(DaType(da, 3), DaTypeNull, "elem 3 type = null")
  TkAssertEqStr(DaGet$(da, 0), "hi", "elem 0 = hi")
  TkAssertEq&(DaGet&(da, 1), 42, "elem 1 = 42")
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 7: Nested object inside array ============== *}

PRINT "-- Test 7: Nested object inside array"
src$ = "[{" + q$ + "nm" + q$ + ":" + q$ + "Bob" + q$ + "}]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse arr with obj")
IF root& <> 0 THEN
  da = root&
  TkAssertEq&(DaCount(da), 1, "arr count = 1")
  TkAssertEq%(DaType(da, 0), DaTypeRef, "elem 0 type = ref")
  ref& = DaGetRef(da, 0)
  TkAssertNeq&(ref&, 0, "ref not null")
  IF ref& <> 0 THEN
    innerHm = ref&
    TkAssertEqStr(HmGet$(innerHm, "nm"), "Bob", "nm = Bob")
    HmFree(innerHm)
    FREE ref&
  END IF
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 8: Nested array inside object ============== *}

PRINT "-- Test 8: Nested array inside object"
src$ = "{" + q$ + "tg" + q$ + ":[" + q$ + "dev" + q$ + ","
src$ = src$ + q$ + "amg" + q$ + "]}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse obj with arr")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq%(HmType(hm, "tg"), HmTypeRef, "tg type = ref")
  ref& = HmGetRef(hm, "tg")
  TkAssertNeq&(ref&, 0, "tg ref not null")
  IF ref& <> 0 THEN
    innerDa = ref&
    TkAssertEq&(DaCount(innerDa), 2, "inner count = 2")
    TkAssertEqStr(DaGet$(innerDa, 0), "dev", "tag 0 = dev")
    TkAssertEqStr(DaGet$(innerDa, 1), "amg", "tag 1 = amg")
    DaFree(innerDa)
    FREE ref&
  END IF
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 9: Nested array inside array ============== *}

PRINT "-- Test 9: Nested array inside array"
src$ = "[[1, 2], [3, 4]]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse nested arrays")
IF root& <> 0 THEN
  da = root&
  TkAssertEq&(DaCount(da), 2, "outer count = 2")
  TkAssertEq%(DaType(da, 0), DaTypeRef, "elem 0 type = ref")
  TkAssertEq%(DaType(da, 1), DaTypeRef, "elem 1 type = ref")

  ref& = DaGetRef(da, 0)
  IF ref& <> 0 THEN
    innerDa = ref&
    TkAssertEq&(DaCount(innerDa), 2, "inner0 count = 2")
    TkAssertEq&(DaGet&(innerDa, 0), 1, "inner0[0] = 1")
    TkAssertEq&(DaGet&(innerDa, 1), 2, "inner0[1] = 2")
    DaFree(innerDa)
    FREE ref&
  END IF

  ref& = DaGetRef(da, 1)
  IF ref& <> 0 THEN
    innerDa = ref&
    TkAssertEq&(DaCount(innerDa), 2, "inner1 count = 2")
    TkAssertEq&(DaGet&(innerDa, 0), 3, "inner1[0] = 3")
    TkAssertEq&(DaGet&(innerDa, 1), 4, "inner1[1] = 4")
    DaFree(innerDa)
    FREE ref&
  END IF

  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 10: Deeply nested structure ============== *}

PRINT "-- Test 10: Deeply nested structure"
' {"a":{"b":{"c":42}}}
src$ = "{" + q$ + "a" + q$ + ":{" + q$ + "b" + q$ + ":{" + q$ + "c" + q$ + ":42}}}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse deep nested")
IF root& <> 0 THEN
  hm = root&
  ref& = HmGetRef(hm, "a")
  TkAssertNeq&(ref&, 0, "a ref not null")
  IF ref& <> 0 THEN
    DECLARE CLASS Hashmap midHm
    midHm = ref&
    LONGINT ref2&
    ref2& = HmGetRef(midHm, "b")
    TkAssertNeq&(ref2&, 0, "b ref not null")
    IF ref2& <> 0 THEN
      DECLARE CLASS Hashmap deepHm
      deepHm = ref2&
      TkAssertEq&(HmGet&(deepHm, "c"), 42, "c = 42")
      HmFree(deepHm)
      FREE ref2&
    END IF
    HmFree(midHm)
    FREE ref&
  END IF
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 11: Float values ============== *}

PRINT "-- Test 11: Float values"
src$ = "{" + q$ + "pi" + q$ + ":3.14,"
src$ = src$ + q$ + "ng" + q$ + ":-0.5,"
src$ = src$ + q$ + "ex" + q$ + ":1.5e2}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse floats")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq%(HmType(hm, "pi"), HmTypeSng, "pi type = sng")
  TkAssertEq%(HmType(hm, "ng"), HmTypeSng, "ng type = sng")
  TkAssertEq%(HmType(hm, "ex"), HmTypeSng, "ex type = sng")

  ' FFP precision is ~7 digits, use approximate checks
  SINGLE piVal!, ngVal!, exVal!
  piVal! = HmGet!(hm, "pi")
  ngVal! = HmGet!(hm, "ng")
  exVal! = HmGet!(hm, "ex")

  ' Check pi is roughly 3.14
  TkAssertTrue(piVal! > 3.0 AND piVal! < 3.2, "pi ~ 3.14")
  ' Check ng is roughly -0.5
  TkAssertTrue(ngVal! < 0.0, "ng < 0")
  ' Check ex is roughly 150
  TkAssertTrue(exVal! > 140.0 AND exVal! < 160.0, "ex ~ 150")

  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 12: Float values in array ============== *}

PRINT "-- Test 12: Float values in array"
src$ = "[1.5, -2.7, 0.001]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse float array")
IF root& <> 0 THEN
  da = root&
  TkAssertEq&(DaCount(da), 3, "float arr count = 3")
  TkAssertEq%(DaType(da, 0), DaTypeSng, "elem 0 type = sng")
  TkAssertEq%(DaType(da, 1), DaTypeSng, "elem 1 type = sng")
  TkAssertEq%(DaType(da, 2), DaTypeSng, "elem 2 type = sng")

  SINGLE fv!
  fv! = DaGet!(da, 0)
  TkAssertTrue(fv! > 1.0 AND fv! < 2.0, "elem 0 ~ 1.5")
  fv! = DaGet!(da, 1)
  TkAssertTrue(fv! < -2.0 AND fv! > -3.0, "elem 1 ~ -2.7")

  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 13: TYPECASE on nested refs ============== *}

PRINT "-- Test 13: TYPECASE on nested refs"
' {"obj":{"x":1},"arr":[2]}
src$ = "{" + q$ + "obj" + q$ + ":{" + q$ + "x" + q$ + ":1},"
src$ = src$ + q$ + "arr" + q$ + ":[2]}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse for typecase")
IF root& <> 0 THEN
  hm = root&

  ' Check nested object via TYPECASE
  ref& = HmGetRef(hm, "obj")
  matched% = 0
  DECLARE CLASS Hashmap tcHm
  tcHm = ref&
  TYPECASE tcHm
    CASE Hashmap
      matched% = 1
    CASE DynArray
      matched% = 2
    CASE ELSE
      matched% = -1
  END TYPECASE
  TkAssertEq%(matched%, 1, "obj ref = Hashmap")

  ' Check nested array via TYPECASE
  ref& = HmGetRef(hm, "arr")
  matched% = 0
  DECLARE CLASS Hashmap tcProbe
  tcProbe = ref&
  TYPECASE tcProbe
    CASE Hashmap
      matched% = 1
    CASE DynArray
      matched% = 2
    CASE ELSE
      matched% = -1
  END TYPECASE
  TkAssertEq%(matched%, 2, "arr ref = DynArray")

  ' Clean up nested refs
  ref& = HmGetRef(hm, "obj")
  IF ref& <> 0 THEN
    innerHm = ref&
    HmFree(innerHm)
    FREE ref&
  END IF
  ref& = HmGetRef(hm, "arr")
  IF ref& <> 0 THEN
    innerDa = ref&
    DaFree(innerDa)
    FREE ref&
  END IF

  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 14: TYPECASE with narrowing ============== *}

PRINT "-- Test 14: TYPECASE with narrowing"
' [{"k":99}]
src$ = "[{" + q$ + "k" + q$ + ":99}]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse for narrowing")
IF root& <> 0 THEN
  da = root&
  ref& = DaGetRef(da, 0)
  DECLARE CLASS Hashmap nrProbe
  nrProbe = ref&
  LONGINT gotK&
  gotK& = 0

  TYPECASE nrProbe
    CASE Hashmap
      ' Narrowed: nrProbe is treated as Hashmap here
      gotK& = HmGet&(nrProbe, "k")
    CASE DynArray
      gotK& = -1
  END TYPECASE

  TkAssertEq&(gotK&, 99, "narrowed k = 99")

  ' Cleanup
  IF ref& <> 0 THEN
    innerHm = ref&
    HmFree(innerHm)
    FREE ref&
  END IF
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 15: Complex nested structure ============== *}

PRINT "-- Test 15: Complex nested structure"
' {"items":[{"id":1},{"id":2}],"total":2}
src$ = "{" + q$ + "items" + q$ + ":[{"
src$ = src$ + q$ + "id" + q$ + ":1},{"
src$ = src$ + q$ + "id" + q$ + ":2}],"
src$ = src$ + q$ + "total" + q$ + ":2}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse complex nested")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq&(HmGet&(hm, "total"), 2, "total = 2")
  ref& = HmGetRef(hm, "items")
  TkAssertNeq&(ref&, 0, "items ref not null")
  IF ref& <> 0 THEN
    innerDa = ref&
    TkAssertEq&(DaCount(innerDa), 2, "items count = 2")

    LONGINT itemRef&
    itemRef& = DaGetRef(innerDa, 0)
    IF itemRef& <> 0 THEN
      DECLARE CLASS Hashmap item0
      item0 = itemRef&
      TkAssertEq&(HmGet&(item0, "id"), 1, "item 0 id = 1")
      HmFree(item0)
      FREE itemRef&
    END IF

    itemRef& = DaGetRef(innerDa, 1)
    IF itemRef& <> 0 THEN
      DECLARE CLASS Hashmap item1
      item1 = itemRef&
      TkAssertEq&(HmGet&(item1, "id"), 2, "item 1 id = 2")
      HmFree(item1)
      FREE itemRef&
    END IF

    DaFree(innerDa)
    FREE ref&
  END IF
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 16: Depth limit error ============== *}

PRINT "-- Test 16: Depth limit error"
' Build 11 levels of nesting: [[[[[[[[[[[ ]]]]]]]]]]]
src$ = "[[[[[[[[[[["
src$ = src$ + q$ + "deep" + q$
src$ = src$ + "]]]]]]]]]]]"
root& = JsParse(src$)
TkAssertEq&(root&, 0, "depth limit -> null")
errMsg$ = JsError$
TkAssertTrue(LEN(errMsg$) > 0, "depth limit -> error msg")

{* ============== Test 17: Whitespace in arrays ============== *}

PRINT "-- Test 17: Whitespace in arrays"
src$ = " [ 1 , 2 , 3 ] "
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse ws array")
IF root& <> 0 THEN
  da = root&
  TkAssertEq&(DaCount(da), 3, "ws arr count = 3")
  TkAssertEq&(DaGet&(da, 0), 1, "ws elem 0 = 1")
  TkAssertEq&(DaGet&(da, 1), 2, "ws elem 1 = 2")
  TkAssertEq&(DaGet&(da, 2), 3, "ws elem 2 = 3")
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 18: Integer/float discrimination ============== *}

PRINT "-- Test 18: Integer/float discrimination"
src$ = "[42, 3.14]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse int/float mix")
IF root& <> 0 THEN
  da = root&
  TkAssertEq%(DaType(da, 0), DaTypeLng, "42 type = lng")
  TkAssertEq%(DaType(da, 1), DaTypeSng, "3.14 type = sng")
  TkAssertEq&(DaGet&(da, 0), 42, "42 val = 42")
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Summary ============== *}
TkSummary
