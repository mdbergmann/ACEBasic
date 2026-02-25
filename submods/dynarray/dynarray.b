{*
** DynArray - Growable, type-tagged, indexed collection
**
** CLASS-based: multiple independent instances, each with own storage.
** ALLOC'd backing arrays with DIM...ADDRESS overlay for array access.
** Auto-grows by doubling capacity (up to DA_MAX_CAP).
** Remove shifts elements left (no gaps).
**
** Usage:
**   #include <submods/dynarray.h>
**   DECLARE CLASS DynArray da
**   DaMake(da, DA_MEDIUM)
**   DaAppend$(da, "hello")
**   PRINT DaGet$(da, 0)
**   DaFree(da)
*}

{* ============== Constants ============== *}

' Error codes
CONST DA_SUCCESS    = 0
CONST DA_ERR_FULL   = -1
CONST DA_ERR_BOUNDS = -2

' Capacity presets
CONST DA_SMALL  = 16
CONST DA_MEDIUM = 64
CONST DA_LARGE  = 256
CONST DA_MAX_CAP   = 2048
CONST DA_MAX_BOUND = 2047

' Value type tags
CONST DaTypeStr  = 0
CONST DaTypeLng  = 1
CONST DaTypeSng  = 2
CONST DaTypeRef  = 3
CONST DaTypeBool = 4
CONST DaTypeNull = 5

' String buffer size per element
CONST DA_VAL_SIZE = 256

{* ============== CLASS Definition ============== *}

CLASS DynArray
  ADDRESS vals
  ADDRESS valsL
  ADDRESS types
  LONGINT cap
  LONGINT count
  LONGINT cursor
END CLASS

{* ============== Module-Level State ============== *}

' Size of DynArray CLASS: 4 (descriptor) + 3*4 (ADDRESS) + 3*4 (LONGINT) = 28
CONST _DA_STRUCT_SIZE = 28

{* ============== Internal Helpers ============== *}

{*
** Double capacity when count == cap.
** Returns DA_SUCCESS or DA_ERR_FULL if at DA_MAX_CAP.
*}
SUB SHORTINT _DaGrow(DynArray da)
  LONGINT newCap&, i&, oldCap&
  ADDRESS oldV, oldVL, oldTP
  ADDRESS newV, newVL, newTP

  oldCap& = da->cap
  newCap& = oldCap& * 2

  IF newCap& > DA_MAX_CAP THEN
    _DaGrow = DA_ERR_FULL
    EXIT SUB
  END IF

  ' Allocate new arrays
  newV = ALLOC(newCap& * DA_VAL_SIZE)
  newVL = ALLOC(newCap& * 4)
  newTP = ALLOC(newCap& * 2)

  ' Copy old data via overlay
  oldV = da->vals
  oldVL = da->valsL
  oldTP = da->types

  DIM srcV$(DA_MAX_BOUND) SIZE DA_VAL_SIZE ADDRESS oldV
  DIM dstV$(DA_MAX_BOUND) SIZE DA_VAL_SIZE ADDRESS newV
  DIM srcVL&(DA_MAX_BOUND) ADDRESS oldVL
  DIM dstVL&(DA_MAX_BOUND) ADDRESS newVL
  DIM srcTP%(DA_MAX_BOUND) ADDRESS oldTP
  DIM dstTP%(DA_MAX_BOUND) ADDRESS newTP

  FOR i& = 0 TO da->count - 1
    dstV$(i&) = srcV$(i&)
    dstVL&(i&) = srcVL&(i&)
    dstTP%(i&) = srcTP%(i&)
  NEXT

  ' Free old arrays
  FREE oldV
  FREE oldVL
  FREE oldTP

  ' Update struct
  da->vals = newV
  da->valsL = newVL
  da->types = newTP
  da->cap = newCap&

  _DaGrow = DA_SUCCESS
END SUB

{*
** Shift elements [fromIdx+1..count-1] one position left.
** Decrements count. Used by DaRemove.
*}
SUB _DaShiftLeft(DynArray da, LONGINT fromIdx&)
  LONGINT i&
  ADDRESS vAddr, vlAddr, tpAddr

  vAddr = da->vals
  vlAddr = da->valsL
  tpAddr = da->types

  DIM v$(DA_MAX_BOUND) SIZE DA_VAL_SIZE ADDRESS vAddr
  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  FOR i& = fromIdx& TO da->count - 2
    v$(i&) = v$(i& + 1)
    vL&(i&) = vL&(i& + 1)
    tp%(i&) = tp%(i& + 1)
  NEXT

  da->count = da->count - 1
END SUB

{*
** Swap elements at positions i and j across all 3 backing arrays.
*}
SUB _DaSwap(DynArray da, LONGINT ii&, LONGINT jj&)
  ADDRESS vAddr, vlAddr, tpAddr
  STRING tmpV$
  LONGINT tmpL&
  SHORTINT tmpT%

  vAddr = da->vals
  vlAddr = da->valsL
  tpAddr = da->types

  DIM v$(DA_MAX_BOUND) SIZE DA_VAL_SIZE ADDRESS vAddr
  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  tmpV$ = v$(ii&)
  v$(ii&) = v$(jj&)
  v$(jj&) = tmpV$

  tmpL& = vL&(ii&)
  vL&(ii&) = vL&(jj&)
  vL&(jj&) = tmpL&

  tmpT% = tp%(ii&)
  tp%(ii&) = tp%(jj&)
  tp%(jj&) = tmpT%
END SUB

{*
** Grow if at capacity. Returns DA_SUCCESS or DA_ERR_FULL.
*}
SUB SHORTINT _DaEnsureSpace(DynArray da)
  IF da->count >= da->cap THEN
    _DaEnsureSpace = _DaGrow(da)
  ELSE
    _DaEnsureSpace = DA_SUCCESS
  END IF
END SUB

{*
** Append a LONGINT value with given type tag. Used by Append&/AppendRef.
*}
SUB SHORTINT _DaAppendLong(DynArray da, LONGINT theVal&, SHORTINT typ%)
  SHORTINT rc%
  ADDRESS vlAddr, tpAddr

  rc% = _DaEnsureSpace(da)
  IF rc% <> DA_SUCCESS THEN
    _DaAppendLong = rc%
    EXIT SUB
  END IF

  vlAddr = da->valsL
  tpAddr = da->types
  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  vL&(da->count) = theVal&
  tp%(da->count) = typ%
  da->count = da->count + 1
  _DaAppendLong = DA_SUCCESS
END SUB

{*
** Set a LONGINT value at index with given type tag. Used by Set&/SetRef.
*}
SUB SHORTINT _DaSetLong(DynArray da, LONGINT idx&, LONGINT theVal&, SHORTINT typ%)
  ADDRESS vlAddr, tpAddr

  IF idx& < 0 OR idx& >= da->count THEN
    _DaSetLong = DA_ERR_BOUNDS
    EXIT SUB
  END IF

  vlAddr = da->valsL
  tpAddr = da->types
  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  vL&(idx&) = theVal&
  tp%(idx&) = typ%
  _DaSetLong = DA_SUCCESS
END SUB

{* ============== Factory & Cleanup ============== *}

SUB DaMake(DynArray da, LONGINT initCap&) EXTERNAL
  IF initCap& <= 0 THEN
    PRINT "DaMake: capacity must be > 0"
    EXIT SUB
  END IF

  IF initCap& > DA_MAX_CAP THEN
    PRINT "DaMake: capacity exceeds DA_MAX_CAP"
    EXIT SUB
  END IF

  da->cap = initCap&
  da->count = 0
  da->cursor = -1

  ' Allocate backing arrays
  da->vals = ALLOC(initCap& * DA_VAL_SIZE)
  da->valsL = ALLOC(initCap& * 4)
  da->types = ALLOC(initCap& * 2)
END SUB

SUB DaFree(DynArray da) EXTERNAL
  IF da->vals <> 0 THEN FREE da->vals
  IF da->valsL <> 0 THEN FREE da->valsL
  IF da->types <> 0 THEN FREE da->types
  da->vals = 0
  da->valsL = 0
  da->types = 0
  da->cap = 0
  da->count = 0
  da->cursor = -1
END SUB

SUB DaClear(DynArray da) EXTERNAL
  da->count = 0
  da->cursor = -1
END SUB

{* ============== Append ============== *}

SUB SHORTINT DaAppend$(DynArray da, theVal$) EXTERNAL
  SHORTINT rc%
  ADDRESS vAddr, tpAddr

  rc% = _DaEnsureSpace(da)
  IF rc% <> DA_SUCCESS THEN
    DaAppend$ = rc%
    EXIT SUB
  END IF

  vAddr = da->vals
  tpAddr = da->types
  DIM v$(DA_MAX_BOUND) SIZE DA_VAL_SIZE ADDRESS vAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  v$(da->count) = theVal$
  tp%(da->count) = DaTypeStr
  da->count = da->count + 1
  DaAppend$ = DA_SUCCESS
END SUB

SUB SHORTINT DaAppend&(DynArray da, LONGINT theVal&) EXTERNAL
  DaAppend& = _DaAppendLong(da, theVal&, DaTypeLng)
END SUB

SUB SHORTINT DaAppend!(DynArray da, SINGLE theVal!) EXTERNAL
  SHORTINT rc%
  ADDRESS vlAddr, tpAddr

  rc% = _DaEnsureSpace(da)
  IF rc% <> DA_SUCCESS THEN
    DaAppend! = rc%
    EXIT SUB
  END IF

  vlAddr = da->valsL
  tpAddr = da->types
  DIM vF!(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  vF!(da->count) = theVal!
  tp%(da->count) = DaTypeSng
  da->count = da->count + 1
  DaAppend! = DA_SUCCESS
END SUB

SUB SHORTINT DaAppendRef(DynArray da, ADDRESS theRef&) EXTERNAL
  DaAppendRef = _DaAppendLong(da, theRef&, DaTypeRef)
END SUB

SUB SHORTINT DaAppendBool(DynArray da, SHORTINT theVal%) EXTERNAL
  LONGINT normalized&
  IF theVal% THEN normalized& = 1 ELSE normalized& = 0
  DaAppendBool = _DaAppendLong(da, normalized&, DaTypeBool)
END SUB

SUB SHORTINT DaAppendNull(DynArray da) EXTERNAL
  SHORTINT rc%
  ADDRESS tpAddr

  rc% = _DaEnsureSpace(da)
  IF rc% <> DA_SUCCESS THEN
    DaAppendNull = rc%
    EXIT SUB
  END IF

  tpAddr = da->types
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  tp%(da->count) = DaTypeNull
  da->count = da->count + 1
  DaAppendNull = DA_SUCCESS
END SUB

{*
** Copy one element from source array at index srcIdx to dest array (append).
** Handles all type tags correctly including SINGLE raw bits.
*}
SUB _DaCopyElement(DynArray src, LONGINT srcIdx&, DynArray dest)
  ADDRESS vAddr, vlAddr, tpAddr
  SHORTINT typ%

  vAddr = src->vals
  vlAddr = src->valsL
  tpAddr = src->types

  DIM v$(DA_MAX_BOUND) SIZE DA_VAL_SIZE ADDRESS vAddr
  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM vF!(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  typ% = tp%(srcIdx&)

  IF typ% = DaTypeStr THEN
    DaAppend$(dest, v$(srcIdx&))
  ELSEIF typ% = DaTypeSng THEN
    DaAppend!(dest, vF!(srcIdx&))
  ELSEIF typ% = DaTypeRef THEN
    DaAppendRef(dest, vL&(srcIdx&))
  ELSEIF typ% = DaTypeBool THEN
    DaAppendBool(dest, vL&(srcIdx&))
  ELSEIF typ% = DaTypeNull THEN
    DaAppendNull(dest)
  ELSE
    DaAppend&(dest, vL&(srcIdx&))
  END IF
END SUB

{* ============== Get ============== *}

SUB STRING DaGet$(DynArray da, LONGINT idx&) EXTERNAL
  ADDRESS vAddr

  IF idx& < 0 OR idx& >= da->count THEN
    DaGet$ = ""
    EXIT SUB
  END IF

  vAddr = da->vals
  DIM v$(DA_MAX_BOUND) SIZE DA_VAL_SIZE ADDRESS vAddr
  DaGet$ = v$(idx&)
END SUB

SUB LONGINT DaGet&(DynArray da, LONGINT idx&) EXTERNAL
  ADDRESS vlAddr

  IF idx& < 0 OR idx& >= da->count THEN
    DaGet& = 0
    EXIT SUB
  END IF

  vlAddr = da->valsL
  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DaGet& = vL&(idx&)
END SUB

SUB SINGLE DaGet!(DynArray da, LONGINT idx&) EXTERNAL
  ADDRESS vlAddr

  IF idx& < 0 OR idx& >= da->count THEN
    DaGet! = 0
    EXIT SUB
  END IF

  vlAddr = da->valsL
  DIM vF!(DA_MAX_BOUND) ADDRESS vlAddr
  DaGet! = vF!(idx&)
END SUB

SUB LONGINT DaGetRef(DynArray da, LONGINT idx&) EXTERNAL
  DaGetRef = DaGet&(da, idx&)
END SUB

SUB SHORTINT DaType(DynArray da, LONGINT idx&) EXTERNAL
  ADDRESS tpAddr

  IF idx& < 0 OR idx& >= da->count THEN
    DaType = -1
    EXIT SUB
  END IF

  tpAddr = da->types
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr
  DaType = tp%(idx&)
END SUB

{* ============== Set ============== *}

SUB SHORTINT DaSet$(DynArray da, LONGINT idx&, theVal$) EXTERNAL
  ADDRESS vAddr, tpAddr

  IF idx& < 0 OR idx& >= da->count THEN
    DaSet$ = DA_ERR_BOUNDS
    EXIT SUB
  END IF

  vAddr = da->vals
  tpAddr = da->types
  DIM v$(DA_MAX_BOUND) SIZE DA_VAL_SIZE ADDRESS vAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  v$(idx&) = theVal$
  tp%(idx&) = DaTypeStr
  DaSet$ = DA_SUCCESS
END SUB

SUB SHORTINT DaSet&(DynArray da, LONGINT idx&, LONGINT theVal&) EXTERNAL
  DaSet& = _DaSetLong(da, idx&, theVal&, DaTypeLng)
END SUB

SUB SHORTINT DaSet!(DynArray da, LONGINT idx&, SINGLE theVal!) EXTERNAL
  ADDRESS vlAddr, tpAddr

  IF idx& < 0 OR idx& >= da->count THEN
    DaSet! = DA_ERR_BOUNDS
    EXIT SUB
  END IF

  vlAddr = da->valsL
  tpAddr = da->types
  DIM vF!(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  vF!(idx&) = theVal!
  tp%(idx&) = DaTypeSng
  DaSet! = DA_SUCCESS
END SUB

SUB SHORTINT DaSetRef(DynArray da, LONGINT idx&, ADDRESS theRef&) EXTERNAL
  DaSetRef = _DaSetLong(da, idx&, theRef&, DaTypeRef)
END SUB

SUB SHORTINT DaSetBool(DynArray da, LONGINT idx&, SHORTINT theVal%) EXTERNAL
  LONGINT normalized&
  IF theVal% THEN normalized& = 1 ELSE normalized& = 0
  DaSetBool = _DaSetLong(da, idx&, normalized&, DaTypeBool)
END SUB

SUB SHORTINT DaSetNull(DynArray da, LONGINT idx&) EXTERNAL
  ADDRESS tpAddr

  IF idx& < 0 OR idx& >= da->count THEN
    DaSetNull = DA_ERR_BOUNDS
    EXIT SUB
  END IF

  tpAddr = da->types
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  tp%(idx&) = DaTypeNull
  DaSetNull = DA_SUCCESS
END SUB

{* ============== Remove ============== *}

SUB SHORTINT DaRemove(DynArray da, LONGINT idx&) EXTERNAL
  IF idx& < 0 OR idx& >= da->count THEN
    DaRemove = DA_ERR_BOUNDS
    EXIT SUB
  END IF

  _DaShiftLeft(da, idx&)
  DaRemove = DA_SUCCESS
END SUB

{* ============== Info ============== *}

SUB LONGINT DaCount(DynArray da) EXTERNAL
  DaCount = da->count
END SUB

SUB LONGINT DaCapacity(DynArray da) EXTERNAL
  DaCapacity = da->cap
END SUB

{* ============== Iteration ============== *}

SUB DaIterReset(DynArray da) EXTERNAL
  da->cursor = -1
END SUB

SUB SHORTINT DaIterNext(DynArray da) EXTERNAL
  da->cursor = da->cursor + 1
  IF da->cursor < da->count THEN
    DaIterNext = -1
  ELSE
    DaIterNext = 0
  END IF
END SUB

SUB LONGINT DaIterIdx(DynArray da) EXTERNAL
  DaIterIdx = da->cursor
END SUB

SUB STRING DaIterVal$(DynArray da) EXTERNAL
  ADDRESS vAddr

  IF da->cursor < 0 OR da->cursor >= da->count THEN
    DaIterVal$ = ""
    EXIT SUB
  END IF

  vAddr = da->vals
  DIM v$(DA_MAX_BOUND) SIZE DA_VAL_SIZE ADDRESS vAddr
  DaIterVal$ = v$(da->cursor)
END SUB

SUB LONGINT DaIterVal&(DynArray da) EXTERNAL
  ADDRESS vlAddr

  IF da->cursor < 0 OR da->cursor >= da->count THEN
    DaIterVal& = 0
    EXIT SUB
  END IF

  vlAddr = da->valsL
  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DaIterVal& = vL&(da->cursor)
END SUB

SUB SINGLE DaIterVal!(DynArray da) EXTERNAL
  ADDRESS vlAddr

  IF da->cursor < 0 OR da->cursor >= da->count THEN
    DaIterVal! = 0
    EXIT SUB
  END IF

  vlAddr = da->valsL
  DIM vF!(DA_MAX_BOUND) ADDRESS vlAddr
  DaIterVal! = vF!(da->cursor)
END SUB

SUB LONGINT DaIterRef(DynArray da) EXTERNAL
  DaIterRef = DaIterVal&(da)
END SUB

SUB SHORTINT DaIterType(DynArray da) EXTERNAL
  ADDRESS tpAddr

  IF da->cursor < 0 OR da->cursor >= da->count THEN
    DaIterType = -1
    EXIT SUB
  END IF

  tpAddr = da->types
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr
  DaIterType = tp%(da->cursor)
END SUB

{* ============== Builder Pattern ============== *}

LONGINT _daBldPtr

SUB DaNew(LONGINT initCap&) EXTERNAL
  SHARED _daBldPtr
  DECLARE CLASS DynArray bld

  _daBldPtr = ALLOC(_DA_STRUCT_SIZE)
  POKEL _daBldPtr, PEEKL(bld)        ' stamp class descriptor for TYPECASE
  bld = _daBldPtr
  DaMake(bld, initCap&)
END SUB

SUB SHORTINT DaAdd$(theVal$) EXTERNAL
  SHARED _daBldPtr
  DECLARE CLASS DynArray bld
  bld = _daBldPtr
  DaAdd$ = DaAppend$(bld, theVal$)
END SUB

SUB SHORTINT DaAdd&(LONGINT theVal&) EXTERNAL
  SHARED _daBldPtr
  DECLARE CLASS DynArray bld
  bld = _daBldPtr
  DaAdd& = DaAppend&(bld, theVal&)
END SUB

SUB SHORTINT DaAdd!(SINGLE theVal!) EXTERNAL
  SHARED _daBldPtr
  DECLARE CLASS DynArray bld
  bld = _daBldPtr
  DaAdd! = DaAppend!(bld, theVal!)
END SUB

SUB SHORTINT DaAddRef(ADDRESS theRef&) EXTERNAL
  SHARED _daBldPtr
  DECLARE CLASS DynArray bld
  bld = _daBldPtr
  DaAddRef = DaAppendRef(bld, theRef&)
END SUB

SUB SHORTINT DaAddBool(SHORTINT theVal%) EXTERNAL
  SHARED _daBldPtr
  DECLARE CLASS DynArray bld
  bld = _daBldPtr
  DaAddBool = DaAppendBool(bld, theVal%)
END SUB

SUB SHORTINT DaAddNull EXTERNAL
  SHARED _daBldPtr
  DECLARE CLASS DynArray bld
  bld = _daBldPtr
  DaAddNull = DaAppendNull(bld)
END SUB

SUB LONGINT DaEnd EXTERNAL
  SHARED _daBldPtr
  LONGINT retVal&
  retVal& = _daBldPtr
  _daBldPtr = 0
  DaEnd = retVal&
END SUB

{* ============== Search & Mutate ============== *}

SUB LONGINT DaIndexOf$(DynArray da, theVal$) EXTERNAL
  LONGINT i&
  ADDRESS vAddr

  vAddr = da->vals
  DIM v$(DA_MAX_BOUND) SIZE DA_VAL_SIZE ADDRESS vAddr

  FOR i& = 0 TO da->count - 1
    IF v$(i&) = theVal$ THEN
      DaIndexOf$ = i&
      EXIT SUB
    END IF
  NEXT

  DaIndexOf$ = -1
END SUB

SUB LONGINT DaIndexOf&(DynArray da, LONGINT theVal&) EXTERNAL
  LONGINT i&
  ADDRESS vlAddr, tpAddr

  vlAddr = da->valsL
  tpAddr = da->types
  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  FOR i& = 0 TO da->count - 1
    IF tp%(i&) = DaTypeLng AND vL&(i&) = theVal& THEN
      DaIndexOf& = i&
      EXIT SUB
    END IF
  NEXT

  DaIndexOf& = -1
END SUB

SUB SHORTINT DaContains$(DynArray da, theVal$) EXTERNAL
  IF DaIndexOf$(da, theVal$) >= 0 THEN
    DaContains$ = -1
  ELSE
    DaContains$ = 0
  END IF
END SUB

SUB SHORTINT DaContains&(DynArray da, LONGINT theVal&) EXTERNAL
  IF DaIndexOf&(da, theVal&) >= 0 THEN
    DaContains& = -1
  ELSE
    DaContains& = 0
  END IF
END SUB

SUB DaReverse(DynArray da) EXTERNAL
  LONGINT lo&, hi&

  IF da->count < 2 THEN EXIT SUB

  lo& = 0
  hi& = da->count - 1

  WHILE lo& < hi&
    _DaSwap(da, lo&, hi&)
    lo& = lo& + 1
    hi& = hi& - 1
  WEND
END SUB

{* ============== Higher-Order Functions ============== *}

{*
** DaForEach - Call callback for each element.
** Callback: SUB ADDRESS cb(LONGINT idx&, LONGINT rawVal&,
**              ADDRESS strPtr, SHORTINT typ%) INVOKABLE
** Use CSTR(strPtr) for string access. Pass as BIND(@MySub).
*}
SUB DaForEach(DynArray da, ADDRESS fun) EXTERNAL
  LONGINT i&
  ADDRESS vlAddr, tpAddr, sPtr

  vlAddr = da->valsL
  tpAddr = da->types

  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  FOR i& = 0 TO da->count - 1
    sPtr = da->vals + i& * DA_VAL_SIZE
    INVOKE fun(i&, vL&(i&), sPtr, tp%(i&))
  NEXT
END SUB

SUB DaFilter(DynArray da, DynArray dest, ADDRESS predFun) EXTERNAL
  LONGINT i&, keepIt&
  ADDRESS vlAddr, tpAddr, sPtr

  vlAddr = da->valsL
  tpAddr = da->types

  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  FOR i& = 0 TO da->count - 1
    sPtr = da->vals + i& * DA_VAL_SIZE
    keepIt& = INVOKE predFun(i&, vL&(i&), sPtr, tp%(i&))
    IF keepIt& THEN
      _DaCopyElement(da, i&, dest)
    END IF
  NEXT
END SUB

SUB LONGINT DaFind(DynArray da, ADDRESS predFun) EXTERNAL
  LONGINT i&, result&
  ADDRESS vlAddr, tpAddr, sPtr

  vlAddr = da->valsL
  tpAddr = da->types

  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  FOR i& = 0 TO da->count - 1
    sPtr = da->vals + i& * DA_VAL_SIZE
    result& = INVOKE predFun(i&, vL&(i&), sPtr, tp%(i&))
    IF result& THEN
      DaFind = i&
      EXIT SUB
    END IF
  NEXT

  DaFind = -1
END SUB

SUB LONGINT DaReduce(DynArray da, LONGINT init&, ADDRESS foldFun) EXTERNAL
  LONGINT i&, acc&
  ADDRESS vlAddr, tpAddr, sPtr

  acc& = init&
  vlAddr = da->valsL
  tpAddr = da->types

  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  FOR i& = 0 TO da->count - 1
    sPtr = da->vals + i& * DA_VAL_SIZE
    acc& = INVOKE foldFun(acc&, vL&(i&), sPtr, tp%(i&))
  NEXT

  DaReduce = acc&
END SUB

SUB DaMap(DynArray da, DynArray dest, ADDRESS mapFun) EXTERNAL
  DaForEach(da, mapFun)
END SUB

{* ============== Sort ============== *}

{*
** DaSort - Shellsort with Knuth gap sequence.
** Comparator callback:
**   SUB ADDRESS CmpFun(LONGINT rawA&, LONGINT rawB&,
**       ADDRESS strPtrA, ADDRESS strPtrB,
**       SHORTINT typA%, SHORTINT typB%) INVOKABLE
** Return: negative (a < b), 0 (equal), positive (a > b)
*}
SUB DaSort(DynArray da, ADDRESS cmpFun) EXTERNAL
  LONGINT gap&, ii&, jj&, cmpRes&, cnt&
  ADDRESS vlAddr, tpAddr

  cnt& = da->count
  IF cnt& < 2 THEN EXIT SUB

  vlAddr = da->valsL
  tpAddr = da->types

  DIM vL&(DA_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(DA_MAX_BOUND) ADDRESS tpAddr

  ' Compute initial gap (Knuth sequence)
  gap& = 1
  WHILE gap& < cnt& \ 3
    gap& = gap& * 3 + 1
  WEND

  WHILE gap& >= 1
    ii& = gap&
    WHILE ii& < cnt&
      jj& = ii&
      SHORTINT keepGoing%
      keepGoing% = -1
      WHILE jj& >= gap& AND keepGoing%
        LONGINT ja&
        ja& = jj& - gap&
        cmpRes& = INVOKE cmpFun(vL&(jj&), vL&(ja&), ~
          da->vals + jj& * DA_VAL_SIZE, ~
          da->vals + ja& * DA_VAL_SIZE, ~
          tp%(jj&), tp%(ja&))
        IF cmpRes& < 0 THEN
          _DaSwap(da, jj&, ja&)
          jj& = ja&
        ELSE
          keepGoing% = 0
        END IF
      WEND
      ii& = ii& + 1
    WEND
    gap& = gap& \ 3
  WEND
END SUB

' String comparator: ascending alphabetical
SUB ADDRESS _DaCmpStr(LONGINT rawA&, LONGINT rawB&, ~
    ADDRESS strPtrA, ADDRESS strPtrB, ~
    SHORTINT typA%, SHORTINT typB%) INVOKABLE
  STRING sa$, sb$
  sa$ = CSTR(strPtrA)
  sb$ = CSTR(strPtrB)
  IF sa$ < sb$ THEN
    _DaCmpStr = -1
  ELSEIF sa$ > sb$ THEN
    _DaCmpStr = 1
  ELSE
    _DaCmpStr = 0
  END IF
END SUB

' LONGINT comparator: ascending numeric
SUB ADDRESS _DaCmpLng(LONGINT rawA&, LONGINT rawB&, ~
    ADDRESS strPtrA, ADDRESS strPtrB, ~
    SHORTINT typA%, SHORTINT typB%) INVOKABLE
  IF rawA& < rawB& THEN
    _DaCmpLng = -1
  ELSEIF rawA& > rawB& THEN
    _DaCmpLng = 1
  ELSE
    _DaCmpLng = 0
  END IF
END SUB

SUB DaSortStr(DynArray da) EXTERNAL
  DaSort(da, BIND(@_DaCmpStr))
END SUB

SUB DaSortLng(DynArray da) EXTERNAL
  DaSort(da, BIND(@_DaCmpLng))
END SUB
