REM #using ace:submods/dynarray/dynarray.o
REM #using ace:submods/testkit/testkit.o

{*
** DynArray Phase 5: Higher-Order Function Tests
** Tests ForEach, Filter, Find, Reduce, Map.
*}

#include <submods/dynarray.h>
#include <submods/testkit.h>

{* ============== Shared state for callbacks ============== *}

LONGINT _feSum
LONGINT _feCount

{* ============== Callbacks ============== *}

' ForEach callback: accumulate count and sum of LONGINTs
SUB ADDRESS _CbCountSum(LONGINT idx&, LONGINT rawVal&, ~
                        ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  SHARED _feSum, _feCount
  _feCount = _feCount + 1
  IF typ% = DaTypeLng THEN _feSum = _feSum + rawVal&
  _CbCountSum = 0
END SUB

' Filter predicate: keep only LONGINTs > 10
SUB ADDRESS _CbGt10(LONGINT idx&, LONGINT rawVal&, ~
                    ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  IF typ% = DaTypeLng AND rawVal& > 10 THEN
    _CbGt10 = -1
  ELSE
    _CbGt10 = 0
  END IF
END SUB

' Filter predicate: keep only strings
SUB ADDRESS _CbIsStr(LONGINT idx&, LONGINT rawVal&, ~
                     ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  IF typ% = DaTypeStr THEN
    _CbIsStr = -1
  ELSE
    _CbIsStr = 0
  END IF
END SUB

' Find predicate: find element with value 30
SUB ADDRESS _CbFind30(LONGINT idx&, LONGINT rawVal&, ~
                      ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  IF typ% = DaTypeLng AND rawVal& = 30 THEN
    _CbFind30 = -1
  ELSE
    _CbFind30 = 0
  END IF
END SUB

' Find predicate: find element with value 999 (not present)
SUB ADDRESS _CbFind999(LONGINT idx&, LONGINT rawVal&, ~
                       ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  IF typ% = DaTypeLng AND rawVal& = 999 THEN
    _CbFind999 = -1
  ELSE
    _CbFind999 = 0
  END IF
END SUB

' Reduce callback: sum accumulator
SUB ADDRESS _CbSum(LONGINT acc&, LONGINT rawVal&, ~
                   ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  _CbSum = acc& + rawVal&
END SUB

' Map callback: double each LONGINT into dest via SHARED
LONGINT _mapDestAddr
SUB ADDRESS _CbDouble(LONGINT idx&, LONGINT rawVal&, ~
                      ADDRESS strPtr, SHORTINT typ%) INVOKABLE
  SHARED _mapDestAddr
  DECLARE CLASS DynArray md
  md = _mapDestAddr
  DaAppend&(md, rawVal& * 2)
  _CbDouble = 0
END SUB

{* ============== Test Suite ============== *}

PRINT "=== DynArray Phase 5: Higher-Order Tests ==="
PRINT

TkInit

SHORTINT rc%

{* --- Test 1: ForEach --- *}
PRINT "--- ForEach ---"
DECLARE CLASS DynArray da
DaMake(da, DA_SMALL)

rc% = DaAppend&(da, 10)
rc% = DaAppend&(da, 20)
rc% = DaAppend&(da, 30)

_feSum = 0
_feCount = 0
DaForEach(da, BIND(@_CbCountSum))

TkAssertEq&(_feCount, 3, "forEach count = 3")
TkAssertEq&(_feSum, 60, "forEach sum = 60")

DaFree(da)

{* --- Test 2: ForEach on empty --- *}
PRINT "--- ForEach empty ---"
DECLARE CLASS DynArray de
DaMake(de, DA_SMALL)

_feSum = 0
_feCount = 0
DaForEach(de, BIND(@_CbCountSum))

TkAssertEq&(_feCount, 0, "forEach empty count = 0")
TkAssertEq&(_feSum, 0, "forEach empty sum = 0")

DaFree(de)

{* --- Test 3: Filter LONGINTs > 10 --- *}
PRINT "--- Filter > 10 ---"
DECLARE CLASS DynArray df
DaMake(df, DA_SMALL)

rc% = DaAppend&(df, 5)
rc% = DaAppend&(df, 15)
rc% = DaAppend&(df, 8)
rc% = DaAppend&(df, 25)
rc% = DaAppend&(df, 3)

DECLARE CLASS DynArray fr
DaMake(fr, DA_SMALL)

DaFilter(df, fr, BIND(@_CbGt10))

TkAssertEq&(DaCount(fr), 2, "filter count = 2")
TkAssertEq&(DaGet&(fr, 0), 15, "filter 0 = 15")
TkAssertEq&(DaGet&(fr, 1), 25, "filter 1 = 25")

DaFree(df)
DaFree(fr)

{* --- Test 4: Filter mixed types (keep strings only) --- *}
PRINT "--- Filter strings only ---"
DECLARE CLASS DynArray fm
DaMake(fm, DA_SMALL)

rc% = DaAppend$(fm, "hello")
rc% = DaAppend&(fm, 42)
rc% = DaAppend$(fm, "world")
rc% = DaAppendNull(fm)

DECLARE CLASS DynArray fs
DaMake(fs, DA_SMALL)

DaFilter(fm, fs, BIND(@_CbIsStr))

TkAssertEq&(DaCount(fs), 2, "filter str count = 2")
TkAssertEqStr(DaGet$(fs, 0), "hello", "filter str 0 = hello")
TkAssertEqStr(DaGet$(fs, 1), "world", "filter str 1 = world")

DaFree(fm)
DaFree(fs)

{* --- Test 5: Filter all rejected --- *}
PRINT "--- Filter none match ---"
DECLARE CLASS DynArray fz
DaMake(fz, DA_SMALL)

rc% = DaAppend&(fz, 1)
rc% = DaAppend&(fz, 2)

DECLARE CLASS DynArray fq
DaMake(fq, DA_SMALL)

DaFilter(fz, fq, BIND(@_CbGt10))

TkAssertEq&(DaCount(fq), 0, "filter none count = 0")

DaFree(fz)
DaFree(fq)

{* --- Test 6: Find --- *}
PRINT "--- Find ---"
DECLARE CLASS DynArray dd
DaMake(dd, DA_SMALL)

rc% = DaAppend&(dd, 10)
rc% = DaAppend&(dd, 20)
rc% = DaAppend&(dd, 30)
rc% = DaAppend&(dd, 40)

TkAssertEq&(DaFind(dd, BIND(@_CbFind30)), 2, "find 30 = idx 2")
TkAssertEq&(DaFind(dd, BIND(@_CbFind999)), -1, "find 999 = -1")

DaFree(dd)

{* --- Test 7: Reduce (sum) --- *}
PRINT "--- Reduce ---"
DECLARE CLASS DynArray dr
DaMake(dr, DA_SMALL)

rc% = DaAppend&(dr, 1)
rc% = DaAppend&(dr, 2)
rc% = DaAppend&(dr, 3)
rc% = DaAppend&(dr, 4)

LONGINT total&
total& = DaReduce(dr, 0, BIND(@_CbSum))
TkAssertEq&(total&, 10, "reduce sum = 10")

' Reduce with initial value
total& = DaReduce(dr, 100, BIND(@_CbSum))
TkAssertEq&(total&, 110, "reduce sum with init 100 = 110")

DaFree(dr)

{* --- Test 8: Reduce empty --- *}
PRINT "--- Reduce empty ---"
DECLARE CLASS DynArray re
DaMake(re, DA_SMALL)

total& = DaReduce(re, 42, BIND(@_CbSum))
TkAssertEq&(total&, 42, "reduce empty returns init")

DaFree(re)

{* --- Test 9: Map (double) --- *}
PRINT "--- Map ---"
DECLARE CLASS DynArray dm
DaMake(dm, DA_SMALL)

rc% = DaAppend&(dm, 5)
rc% = DaAppend&(dm, 10)
rc% = DaAppend&(dm, 15)

DECLARE CLASS DynArray mr
DaMake(mr, DA_SMALL)

_mapDestAddr = mr
DaMap(dm, mr, BIND(@_CbDouble))

TkAssertEq&(DaCount(mr), 3, "map count = 3")
TkAssertEq&(DaGet&(mr, 0), 10, "map 0 = 10")
TkAssertEq&(DaGet&(mr, 1), 20, "map 1 = 20")
TkAssertEq&(DaGet&(mr, 2), 30, "map 2 = 30")

DaFree(dm)
DaFree(mr)

{* ============== Summary ============== *}
TkSummary
