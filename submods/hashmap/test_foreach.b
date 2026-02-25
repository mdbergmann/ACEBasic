REM #using ace:submods/hashmap/hashmap.o
REM #using ace:submods/testkit/testkit.o

{*
** Hashmap: HmForEach Tests
** Tests higher-order iteration with callback using BIND/INVOKE.
** Callback signature: (ADDRESS keyPtr, LONGINT rawVal&,
**                      ADDRESS strPtr, SHORTINT typ%)
*}

#include <submods/hashmap.h>
#include <submods/testkit.h>

{* ============== Shared State for Callbacks ============== *}

SHORTINT _feCount
STRING _feKeys$ SIZE 512
LONGINT _feSum
SHORTINT _feStrCnt, _feLngCnt, _feSngCnt, _feBoolCnt, _feNullCnt
STRING _feLastKey$ SIZE 64
STRING _feLastStr$ SIZE 256

{* ============== Callback Forward Declares ============== *}

DECLARE SUB ADDRESS CountEntry(ADDRESS keyPtr, LONGINT rawVal&, ~
                               ADDRESS strPtr, SHORTINT typ%) INVOKABLE

DECLARE SUB ADDRESS CollectKeys(ADDRESS keyPtr, LONGINT rawVal&, ~
                                ADDRESS strPtr, SHORTINT typ%) INVOKABLE

DECLARE SUB ADDRESS SumLongs(ADDRESS keyPtr, LONGINT rawVal&, ~
                             ADDRESS strPtr, SHORTINT typ%) INVOKABLE

DECLARE SUB ADDRESS CountTypes(ADDRESS keyPtr, LONGINT rawVal&, ~
                               ADDRESS strPtr, SHORTINT typ%) INVOKABLE

DECLARE SUB ADDRESS CaptureStr(ADDRESS keyPtr, LONGINT rawVal&, ~
                               ADDRESS strPtr, SHORTINT typ%) INVOKABLE

{* ============== Test Suite ============== *}

PRINT "=== Hashmap: HmForEach Tests ==="
PRINT

TkInit

SHORTINT rc%

{* --- Test 1: Empty map --- *}
PRINT "--- Empty map ---"
DECLARE CLASS Hashmap m1
HmMake(m1, HM_SMALL)

_feCount = 0
HmForEach(m1, BIND(@CountEntry))
TkAssertEq%(_feCount, 0, "count 0 on empty")

HmFree(m1)

{* --- Test 2: Count 3 entries --- *}
PRINT "--- Count 3 entries ---"
DECLARE CLASS Hashmap m2
HmMake(m2, HM_SMALL)

rc% = HmPut$(m2, "a", "A")
rc% = HmPut$(m2, "b", "B")
rc% = HmPut$(m2, "c", "C")

_feCount = 0
HmForEach(m2, BIND(@CountEntry))
TkAssertEq%(_feCount, 3, "count 3 entries")

HmFree(m2)

{* --- Test 3: Keys in insertion order --- *}
PRINT "--- Key order ---"
DECLARE CLASS Hashmap m3
HmMake(m3, HM_SMALL)

rc% = HmPut$(m3, "alpha", "1")
rc% = HmPut$(m3, "beta", "2")
rc% = HmPut$(m3, "gamma", "3")

_feKeys$ = ""
HmForEach(m3, BIND(@CollectKeys))
TkAssertEqStr(_feKeys$, "alpha,beta,gamma", "keys in order")

HmFree(m3)

{* --- Test 4: Skips deleted entries --- *}
PRINT "--- After delete ---"
DECLARE CLASS Hashmap m4
HmMake(m4, HM_SMALL)

rc% = HmPut$(m4, "x", "1")
rc% = HmPut$(m4, "y", "2")
rc% = HmPut$(m4, "z", "3")
rc% = HmDel(m4, "y")

_feCount = 0
HmForEach(m4, BIND(@CountEntry))
TkAssertEq%(_feCount, 2, "count 2 after del")

_feKeys$ = ""
HmForEach(m4, BIND(@CollectKeys))
TkAssertEqStr(_feKeys$, "x,z", "del: keys x,z (y skipped)")

HmFree(m4)

{* --- Test 5: Sum LONG values --- *}
PRINT "--- Sum LONGs ---"
DECLARE CLASS Hashmap m5
HmMake(m5, HM_SMALL)

rc% = HmPut&(m5, "a", 10)
rc% = HmPut&(m5, "b", 20)
rc% = HmPut&(m5, "c", 30)

_feSum = 0
HmForEach(m5, BIND(@SumLongs))
TkAssertEq&(_feSum, 60, "sum is 60")

HmFree(m5)

{* --- Test 6: Mixed types counting --- *}
PRINT "--- Mixed type counting ---"
DECLARE CLASS Hashmap m6
HmMake(m6, HM_SMALL)

rc% = HmPut$(m6, "s1", "hello")
rc% = HmPut$(m6, "s2", "world")
rc% = HmPut&(m6, "n1", 42)
rc% = HmPut!(m6, "f1", 3.14)
rc% = HmPutBool(m6, "b1", -1)
rc% = HmPutNull(m6, "z1")

_feStrCnt = 0
_feLngCnt = 0
_feSngCnt = 0
_feBoolCnt = 0
_feNullCnt = 0
HmForEach(m6, BIND(@CountTypes))
TkAssertEq%(_feStrCnt, 2, "2 strings")
TkAssertEq%(_feLngCnt, 1, "1 long")
TkAssertEq%(_feSngCnt, 1, "1 single")
TkAssertEq%(_feBoolCnt, 1, "1 bool")
TkAssertEq%(_feNullCnt, 1, "1 null")

HmFree(m6)

{* --- Test 7: String value accessible via CSTR --- *}
PRINT "--- String value access ---"
DECLARE CLASS Hashmap m7
HmMake(m7, HM_SMALL)

rc% = HmPut$(m7, "msg", "hello world")

_feLastKey$ = ""
_feLastStr$ = ""
HmForEach(m7, BIND(@CaptureStr))
TkAssertEqStr(_feLastKey$, "msg", "key via CSTR")
TkAssertEqStr(_feLastStr$, "hello world", "val via CSTR")

HmFree(m7)

{* ============== Summary ============== *}
TkSummary

{* ============== Callback Implementations ============== *}

{* Count entries (side effects only) *}
SUB ADDRESS CountEntry(ADDRESS keyPtr, LONGINT rawVal&, ~
                       ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  SHARED _feCount
  _feCount = _feCount + 1
  CountEntry = 0
END SUB

{* Collect keys into comma-separated string *}
SUB ADDRESS CollectKeys(ADDRESS keyPtr, LONGINT rawVal&, ~
                        ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  SHARED _feKeys$
  IF LEN(_feKeys$) > 0 THEN _feKeys$ = _feKeys$ + ","
  _feKeys$ = _feKeys$ + CSTR(keyPtr)
  CollectKeys = 0
END SUB

{* Sum LONG rawVal values *}
SUB ADDRESS SumLongs(ADDRESS keyPtr, LONGINT rawVal&, ~
                     ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  SHARED _feSum
  _feSum = _feSum + rawVal&
  SumLongs = 0
END SUB

{* Count entries by type *}
SUB ADDRESS CountTypes(ADDRESS keyPtr, LONGINT rawVal&, ~
                       ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  SHARED _feStrCnt, _feLngCnt, _feSngCnt, _feBoolCnt, _feNullCnt
  IF typ% = HmTypeStr THEN
    _feStrCnt = _feStrCnt + 1
  ELSEIF typ% = HmTypeLng THEN
    _feLngCnt = _feLngCnt + 1
  ELSEIF typ% = HmTypeSng THEN
    _feSngCnt = _feSngCnt + 1
  ELSEIF typ% = HmTypeBool THEN
    _feBoolCnt = _feBoolCnt + 1
  ELSEIF typ% = HmTypeNull THEN
    _feNullCnt = _feNullCnt + 1
  END IF
  CountTypes = 0
END SUB

{* Capture key and string value *}
SUB ADDRESS CaptureStr(ADDRESS keyPtr, LONGINT rawVal&, ~
                       ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  SHARED _feLastKey$, _feLastStr$
  _feLastKey$ = CSTR(keyPtr)
  IF typ% = HmTypeStr THEN
    _feLastStr$ = CSTR(strPtr)
  END IF
  CaptureStr = 0
END SUB
