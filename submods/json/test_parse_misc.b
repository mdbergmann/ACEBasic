REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/json/json.o
REM #using ace:submods/testkit/testkit.o

{*
** test_parse_misc.b - Phase 3: Escapes, file input, error edge cases
** Tests: string escapes, JsParseFile, error conditions
*}

#include <submods/json.h>
#include <submods/testkit.h>

{* ============== Test Suite ============== *}

PRINT "=== Phase 3: Escapes, File Input, Errors ==="
PRINT

TkInit

STRING src$ SIZE 4096
STRING errMsg$ SIZE 128
STRING q$ SIZE 4
q$ = CHR$(34)
STRING bsl$ SIZE 4
bsl$ = CHR$(92)

LONGINT root&
DECLARE CLASS Hashmap hm
DECLARE CLASS DynArray da
STRING got$ SIZE 256
STRING exp$ SIZE 256

{* ============== Test 1: Escaped quotes ============== *}

PRINT "-- Test 1: Escaped quotes in string"
' JSON: {"msg":"say \"hi\""}
src$ = "{" + q$ + "msg" + q$ + ":" + q$ + "say " + bsl$ + q$ + "hi" + bsl$ + q$ + q$ + "}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse esc quote")
IF root& <> 0 THEN
  hm = root&
  got$ = HmGet$(hm, "msg")
  exp$ = "say " + q$ + "hi" + q$
  TkAssertEqStr(got$, exp$, "msg = say qhiq")
  TkAssertEq&(LEN(got$), 8, "esc quote len = 8")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 2: Escaped backslash ============== *}

PRINT "-- Test 2: Escaped backslash"
' JSON: {"p":"c:\\dir"}
src$ = "{" + q$ + "p" + q$ + ":" + q$ + "c:" + bsl$ + bsl$ + "dir" + q$ + "}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse esc backslash")
IF root& <> 0 THEN
  hm = root&
  got$ = HmGet$(hm, "p")
  exp$ = "c:" + bsl$ + "dir"
  TkAssertEqStr(got$, exp$, "p = c bsl dir")
  TkAssertEq&(LEN(got$), 6, "esc bsl len = 6")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 3: Escaped newline and tab ============== *}

PRINT "-- Test 3: Escaped newline and tab"
' JSON: {"s":"a\nb\tc"}
src$ = "{" + q$ + "s" + q$ + ":" + q$ + "a" + bsl$ + "nb" + bsl$ + "tc" + q$ + "}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse esc nl/tab")
IF root& <> 0 THEN
  hm = root&
  got$ = HmGet$(hm, "s")
  exp$ = "a" + CHR$(10) + "b" + CHR$(9) + "c"
  TkAssertEqStr(got$, exp$, "s = a LF b TAB c")
  TkAssertEq&(LEN(got$), 5, "esc nl/tab len = 5")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 4: Escaped CR, BS, FF ============== *}

PRINT "-- Test 4: Escaped CR, BS, FF"
' JSON: {"s":"x\ry\bz\fw"}
src$ = "{" + q$ + "s" + q$ + ":" + q$ + "x" + bsl$ + "r"
src$ = src$ + "y" + bsl$ + "b" + "z" + bsl$ + "f" + "w" + q$ + "}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse esc cr/bs/ff")
IF root& <> 0 THEN
  hm = root&
  got$ = HmGet$(hm, "s")
  TkAssertEq&(LEN(got$), 7, "esc cr/bs/ff len = 7")
  ' Check specific bytes via PEEK
  LONGINT addr&
  addr& = SADD(got$)
  TkAssertEq%(PEEK(addr&), 120, "byte 0 = x (120)")
  TkAssertEq%(PEEK(addr& + 1), 13, "byte 1 = CR (13)")
  TkAssertEq%(PEEK(addr& + 2), 121, "byte 2 = y (121)")
  TkAssertEq%(PEEK(addr& + 3), 8, "byte 3 = BS (8)")
  TkAssertEq%(PEEK(addr& + 4), 122, "byte 4 = z (122)")
  TkAssertEq%(PEEK(addr& + 5), 12, "byte 5 = FF (12)")
  TkAssertEq%(PEEK(addr& + 6), 119, "byte 6 = w (119)")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 5: Escaped slash ============== *}

PRINT "-- Test 5: Escaped slash"
' JSON: {"u":"a\/b"}
src$ = "{" + q$ + "u" + q$ + ":" + q$ + "a" + bsl$ + "/b" + q$ + "}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse esc slash")
IF root& <> 0 THEN
  hm = root&
  TkAssertEqStr(HmGet$(hm, "u"), "a/b", "u = a/b")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 6: Multiple escapes in one string ============== *}

PRINT "-- Test 6: Multiple escapes"
' JSON: {"s":"a\"b\\c\/d"}
src$ = "{" + q$ + "s" + q$ + ":" + q$
src$ = src$ + "a" + bsl$ + q$ + "b" + bsl$ + bsl$ + "c" + bsl$ + "/d"
src$ = src$ + q$ + "}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse multi esc")
IF root& <> 0 THEN
  hm = root&
  got$ = HmGet$(hm, "s")
  exp$ = "a" + q$ + "b" + bsl$ + "c/d"
  TkAssertEqStr(got$, exp$, "multi esc val")
  TkAssertEq&(LEN(got$), 7, "multi esc len = 7")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 7: Empty string value ============== *}

PRINT "-- Test 7: Empty string value"
src$ = "{" + q$ + "e" + q$ + ":" + q$ + q$ + "}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse empty str")
IF root& <> 0 THEN
  hm = root&
  TkAssertEqStr(HmGet$(hm, "e"), "", "e = empty")
  TkAssertEq&(LEN(HmGet$(hm, "e")), 0, "empty len = 0")
  TkAssertEq%(HmType(hm, "e"), HmTypeStr, "e type = str")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 8: Escaped quotes in array ============== *}

PRINT "-- Test 8: Escaped quotes in array"
' JSON: ["say \"hi\"", "ok"]
src$ = "[" + q$ + "say " + bsl$ + q$ + "hi" + bsl$ + q$ + q$ + ","
src$ = src$ + q$ + "ok" + q$ + "]"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse arr esc quote")
IF root& <> 0 THEN
  da = root&
  TkAssertEq&(DaCount(da), 2, "arr esc count = 2")
  got$ = DaGet$(da, 0)
  exp$ = "say " + q$ + "hi" + q$
  TkAssertEqStr(got$, exp$, "arr[0] = say qhiq")
  TkAssertEqStr(DaGet$(da, 1), "ok", "arr[1] = ok")
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 9: JsParseFile - simple ============== *}

PRINT "-- Test 9: JsParseFile simple"
' Write JSON to temp file
OPEN "O", #1, "T:test_json.tmp"
src$ = "{" + q$ + "nm" + q$ + ":" + q$ + "Bob" + q$ + "}"
PRINT #1, src$
CLOSE #1

' Read back via JsParseFile
OPEN "I", #1, "T:test_json.tmp"
root& = JsParseFile(1)
CLOSE #1

TkAssertNeq&(root&, 0, "parsefile not null")
IF root& <> 0 THEN
  TkAssertEq%(JsRootType, JsObject, "pf root = object")
  hm = root&
  TkAssertEqStr(HmGet$(hm, "nm"), "Bob", "pf nm = Bob")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 10: JsParseFile - multi-line ============== *}

PRINT "-- Test 10: JsParseFile multi-line"
OPEN "O", #1, "T:test_json2.tmp"
PRINT #1, "{"
PRINT #1, "  "; q$; "x"; q$; ": 10,"
PRINT #1, "  "; q$; "y"; q$; ": 20"
PRINT #1, "}"
CLOSE #1

OPEN "I", #1, "T:test_json2.tmp"
root& = JsParseFile(1)
CLOSE #1

TkAssertNeq&(root&, 0, "pf multiline ok")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq&(HmGet&(hm, "x"), 10, "pf x = 10")
  TkAssertEq&(HmGet&(hm, "y"), 20, "pf y = 20")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 11: JsParseFile - array ============== *}

PRINT "-- Test 11: JsParseFile array"
OPEN "O", #1, "T:test_json3.tmp"
src$ = "[1, 2, 3]"
PRINT #1, src$
CLOSE #1

OPEN "I", #1, "T:test_json3.tmp"
root& = JsParseFile(1)
CLOSE #1

TkAssertNeq&(root&, 0, "pf array ok")
IF root& <> 0 THEN
  TkAssertEq%(JsRootType, JsArray, "pf root = array")
  da = root&
  TkAssertEq&(DaCount(da), 3, "pf arr count = 3")
  TkAssertEq&(DaGet&(da, 0), 1, "pf arr[0] = 1")
  TkAssertEq&(DaGet&(da, 1), 2, "pf arr[1] = 2")
  TkAssertEq&(DaGet&(da, 2), 3, "pf arr[2] = 3")
  DaFree(da)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 12: Error - unexpected EOF ============== *}

PRINT "-- Test 12: Error - unexpected EOF"
src$ = "{"
root& = JsParse(src$)
TkAssertEq&(root&, 0, "unexp EOF -> null")
errMsg$ = JsError$
TkAssertTrue(LEN(errMsg$) > 0, "unexp EOF -> error msg")

{* ============== Test 13: Error - invalid literal ============== *}

PRINT "-- Test 13: Error - invalid literal"
src$ = "{" + q$ + "x" + q$ + ":tru}"
root& = JsParse(src$)
TkAssertEq&(root&, 0, "bad literal -> null")
errMsg$ = JsError$
TkAssertTrue(LEN(errMsg$) > 0, "bad literal -> error msg")

{* ============== Test 14: Error - missing close bracket ============== *}

PRINT "-- Test 14: Error - missing close bracket"
src$ = "[1, 2, 3"
root& = JsParse(src$)
TkAssertEq&(root&, 0, "no close -> null")
errMsg$ = JsError$
TkAssertTrue(LEN(errMsg$) > 0, "no close -> error msg")

{* ============== Test 15: Error - empty input ============== *}

PRINT "-- Test 15: Error - empty input"
src$ = ""
root& = JsParse(src$)
TkAssertEq&(root&, 0, "empty -> null")
errMsg$ = JsError$
TkAssertTrue(LEN(errMsg$) > 0, "empty -> error msg")

{* ============== Test 16: Whitespace with newlines and tabs ============== *}

PRINT "-- Test 16: Whitespace with newlines and tabs"
src$ = "{" + CHR$(10) + CHR$(9) + q$ + "k" + q$ + " :" + CHR$(10) + " 42" + CHR$(10) + "}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse ws nl/tab")
IF root& <> 0 THEN
  hm = root&
  TkAssertEq&(HmGet&(hm, "k"), 42, "ws nl/tab k = 42")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Test 17: Escaped key name ============== *}

PRINT "-- Test 17: Escaped key name"
' JSON: {"a\"b":1}
src$ = "{" + q$ + "a" + bsl$ + q$ + "b" + q$ + ":1}"
root& = JsParse(src$)
TkAssertNeq&(root&, 0, "parse esc key")
IF root& <> 0 THEN
  hm = root&
  exp$ = "a" + q$ + "b"
  TkAssertEq&(HmGet&(hm, exp$), 1, "esc key val = 1")
  HmFree(hm)
  FREE root&
ELSE
  errMsg$ = JsError$
  PRINT "  Error: "; errMsg$
END IF

{* ============== Summary ============== *}
TkSummary
