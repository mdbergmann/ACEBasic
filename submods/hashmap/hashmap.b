{*
** Hashmap - String-keyed hashmap with open addressing and linear probing
**
** CLASS-based: multiple independent instances, each with own storage.
** ALLOC'd backing arrays with DIM...ADDRESS overlay for array access.
** DJB2 hash, power-of-2 capacity, 70% max load factor, tombstone deletion.
**
** Usage:
**   #include <submods/hashmap.h>
**   EXTERNAL hashmap
**   DECLARE CLASS Hashmap map
**   HmMake(map, HM_MEDIUM)
**   HmPut$(map, "name", "Alice")
**   PRINT HmGet$(map, "name")
**   HmFree(map)
*}

{* ============== Constants ============== *}

' Slot status
CONST HM_EMPTY = 0
CONST HM_OCCUPIED = 1
CONST HM_TOMBSTONE = 2

' Error codes
CONST HM_SUCCESS = 0
CONST HM_ERR_FULL = -1
CONST HM_ERR_NOTFOUND = -2
CONST HM_ERR_CAPACITY = -3

' Value type tags
CONST HmTypeStr = 0
CONST HmTypeLng = 1
CONST HmTypeSng = 2
CONST HmTypeRef = 3
CONST HmTypeBool = 4
CONST HmTypeNull = 5

' Capacity presets
CONST HM_SMALL = 32
CONST HM_MEDIUM = 128
CONST HM_LARGE = 512

' String buffer sizes per element
CONST HM_KEY_SIZE = 64
CONST HM_VAL_SIZE = 256

' Max bound for DIM...ADDRESS overlays (HM_LARGE - 1)
' DIM requires a CONST bound. Actual access is limited by hm->cap.
CONST HM_MAX_BOUND = 511

{* ============== CLASS Definition ============== *}

CLASS Hashmap
  ADDRESS keys
  ADDRESS vals
  ADDRESS valsL
  ADDRESS types
  ADDRESS status
  ADDRESS order
  LONGINT cap
  LONGINT count
  LONGINT orderCount
  LONGINT cursor
  LONGINT curIdx
END CLASS

{* ============== Internal: Hash Function (DJB2) ============== *}

SUB LONGINT _HmHash(theKey$, LONGINT theCap&)
  LONGINT h&
  SHORTINT i%

  h& = 5381
  FOR i% = 1 TO LEN(theKey$)
    h& = h& * 33 + ASC(MID$(theKey$, i%, 1))
  NEXT
  _HmHash = h& AND (theCap& - 1)
END SUB

{* ============== Internal: Order Array Maintenance ============== *}

{*
** Append a backing-array index to the insertion-order array.
** If the slot was previously used (tombstone reuse), the old
** order entry is invalidated first. Compacts if order array is full.
*}
SUB _HmOrderAppend(Hashmap hm, LONGINT backIdx&)
  ADDRESS oAddr, stAddr
  LONGINT i&, j&

  oAddr = hm->order
  stAddr = hm->status
  DIM ord%(HM_MAX_BOUND) ADDRESS oAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr

  ' Invalidate any old order entry for this slot (tombstone reuse)
  i& = 0
  WHILE i& < hm->orderCount
    IF ord%(i&) = backIdx& THEN
      ord%(i&) = -1
      i& = hm->orderCount
    ELSE
      i& = i& + 1
    END IF
  WEND

  ' Compact if order array is full
  IF hm->orderCount >= hm->cap THEN
    j& = 0
    FOR i& = 0 TO hm->orderCount - 1
      IF ord%(i&) >= 0 AND st%(ord%(i&)) = HM_OCCUPIED THEN
        ord%(j&) = ord%(i&)
        j& = j& + 1
      END IF
    NEXT
    hm->orderCount = j&
  END IF

  ' Append new entry
  ord%(hm->orderCount) = backIdx&
  hm->orderCount = hm->orderCount + 1
END SUB

{* ============== Factory & Cleanup ============== *}

SUB HmMake(Hashmap hm, LONGINT theCap&) EXTERNAL
  SHORTINT i
  ADDRESS stAddr

  ' Validate power of 2
  IF theCap& <= 0 OR (theCap& AND (theCap& - 1)) <> 0 THEN
    PRINT "HmMake: capacity must be power of 2"
    EXIT SUB
  END IF

  hm->cap = theCap&
  hm->count = 0
  hm->orderCount = 0
  hm->cursor = -1
  hm->curIdx = -1

  ' Allocate backing arrays
  hm->keys = ALLOC(theCap& * HM_KEY_SIZE)
  hm->vals = ALLOC(theCap& * HM_VAL_SIZE)
  hm->valsL = ALLOC(theCap& * 4)
  hm->types = ALLOC(theCap& * 2)
  hm->status = ALLOC(theCap& * 2)
  hm->order = ALLOC(theCap& * 2)

  ' Clear status array (all slots empty)
  stAddr = hm->status
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr
  FOR i = 0 TO theCap& - 1
    st%(i) = HM_EMPTY
  NEXT
END SUB

SUB HmFree(Hashmap hm) EXTERNAL
  IF hm->keys <> 0 THEN FREE hm->keys
  IF hm->vals <> 0 THEN FREE hm->vals
  IF hm->valsL <> 0 THEN FREE hm->valsL
  IF hm->types <> 0 THEN FREE hm->types
  IF hm->status <> 0 THEN FREE hm->status
  IF hm->order <> 0 THEN FREE hm->order
  hm->keys = 0
  hm->vals = 0
  hm->valsL = 0
  hm->types = 0
  hm->status = 0
  hm->order = 0
  hm->cap = 0
  hm->count = 0
  hm->orderCount = 0
END SUB

SUB HmClear(Hashmap hm) EXTERNAL
  SHORTINT i
  ADDRESS stAddr

  stAddr = hm->status
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr
  FOR i = 0 TO hm->cap - 1
    st%(i) = HM_EMPTY
  NEXT
  hm->count = 0
  hm->orderCount = 0
  hm->cursor = -1
  hm->curIdx = -1
END SUB

{* ============== Core: Put String ============== *}

SUB SHORTINT HmPut$(Hashmap hm, theKey$, theVal$) EXTERNAL
  LONGINT idx&, tombIdx&, maxLoad&, probes&, capVal&
  ADDRESS kAddr, vAddr, stAddr, tpAddr

  ' Extract struct members to locals for DIM
  capVal& = hm->cap
  kAddr = hm->keys
  vAddr = hm->vals
  stAddr = hm->status
  tpAddr = hm->types

  ' Overlay arrays
  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM v$(HM_MAX_BOUND) SIZE HM_VAL_SIZE ADDRESS vAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr
  DIM tp%(HM_MAX_BOUND) ADDRESS tpAddr

  ' Hash and probe
  idx& = _HmHash(theKey$, capVal&)
  tombIdx& = -1
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED THEN
      IF k$(idx&) = theKey$ THEN
        ' Key exists - update value
        v$(idx&) = theVal$
        tp%(idx&) = HmTypeStr
        HmPut$ = HM_SUCCESS
        EXIT SUB
      END IF
    ELSEIF tombIdx& = -1 THEN
      tombIdx& = idx&
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  ' Key not found - check load factor before inserting
  maxLoad& = (capVal& * 7) \ 10
  IF hm->count >= maxLoad& THEN
    HmPut$ = HM_ERR_FULL
    EXIT SUB
  END IF

  ' Use tombstone slot if available, else empty slot
  IF tombIdx& >= 0 THEN
    idx& = tombIdx&
  ELSEIF probes& >= capVal& THEN
    ' All slots occupied or tombstoned, no tombstone found
    HmPut$ = HM_ERR_FULL
    EXIT SUB
  END IF

  ' Insert new entry
  k$(idx&) = theKey$
  v$(idx&) = theVal$
  tp%(idx&) = HmTypeStr
  st%(idx&) = HM_OCCUPIED
  hm->count = hm->count + 1
  _HmOrderAppend(hm, idx&)
  HmPut$ = HM_SUCCESS
END SUB

{* ============== Core: Put Long ============== *}

SUB SHORTINT HmPut&(Hashmap hm, theKey$, LONGINT theVal&) EXTERNAL
  LONGINT idx&, tombIdx&, maxLoad&, probes&, capVal&
  ADDRESS kAddr, vlAddr, stAddr, tpAddr

  capVal& = hm->cap
  kAddr = hm->keys
  vlAddr = hm->valsL
  stAddr = hm->status
  tpAddr = hm->types

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM vL&(HM_MAX_BOUND) ADDRESS vlAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr
  DIM tp%(HM_MAX_BOUND) ADDRESS tpAddr

  idx& = _HmHash(theKey$, capVal&)
  tombIdx& = -1
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED THEN
      IF k$(idx&) = theKey$ THEN
        vL&(idx&) = theVal&
        tp%(idx&) = HmTypeLng
        HmPut& = HM_SUCCESS
        EXIT SUB
      END IF
    ELSEIF tombIdx& = -1 THEN
      tombIdx& = idx&
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  maxLoad& = (capVal& * 7) \ 10
  IF hm->count >= maxLoad& THEN
    HmPut& = HM_ERR_FULL
    EXIT SUB
  END IF

  IF tombIdx& >= 0 THEN
    idx& = tombIdx&
  ELSEIF probes& >= capVal& THEN
    HmPut& = HM_ERR_FULL
    EXIT SUB
  END IF

  k$(idx&) = theKey$
  vL&(idx&) = theVal&
  tp%(idx&) = HmTypeLng
  st%(idx&) = HM_OCCUPIED
  hm->count = hm->count + 1
  _HmOrderAppend(hm, idx&)
  HmPut& = HM_SUCCESS
END SUB

{* ============== Core: Put Single ============== *}

SUB SHORTINT HmPut!(Hashmap hm, theKey$, SINGLE theVal!) EXTERNAL
  LONGINT idx&, tombIdx&, maxLoad&, probes&, capVal&
  ADDRESS kAddr, vlAddr, stAddr, tpAddr

  capVal& = hm->cap
  kAddr = hm->keys
  vlAddr = hm->valsL
  stAddr = hm->status
  tpAddr = hm->types

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM vF!(HM_MAX_BOUND) ADDRESS vlAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr
  DIM tp%(HM_MAX_BOUND) ADDRESS tpAddr

  idx& = _HmHash(theKey$, capVal&)
  tombIdx& = -1
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED THEN
      IF k$(idx&) = theKey$ THEN
        vF!(idx&) = theVal!
        tp%(idx&) = HmTypeSng
        HmPut! = HM_SUCCESS
        EXIT SUB
      END IF
    ELSEIF tombIdx& = -1 THEN
      tombIdx& = idx&
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  maxLoad& = (capVal& * 7) \ 10
  IF hm->count >= maxLoad& THEN
    HmPut! = HM_ERR_FULL
    EXIT SUB
  END IF

  IF tombIdx& >= 0 THEN
    idx& = tombIdx&
  ELSEIF probes& >= capVal& THEN
    HmPut! = HM_ERR_FULL
    EXIT SUB
  END IF

  k$(idx&) = theKey$
  vF!(idx&) = theVal!
  tp%(idx&) = HmTypeSng
  st%(idx&) = HM_OCCUPIED
  hm->count = hm->count + 1
  _HmOrderAppend(hm, idx&)
  HmPut! = HM_SUCCESS
END SUB

{* ============== Core: Put Ref ============== *}

SUB SHORTINT HmPutRef(Hashmap hm, theKey$, ADDRESS theRef&) EXTERNAL
  LONGINT idx&, tombIdx&, maxLoad&, probes&, capVal&
  ADDRESS kAddr, vlAddr, stAddr, tpAddr

  capVal& = hm->cap
  kAddr = hm->keys
  vlAddr = hm->valsL
  stAddr = hm->status
  tpAddr = hm->types

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM vL&(HM_MAX_BOUND) ADDRESS vlAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr
  DIM tp%(HM_MAX_BOUND) ADDRESS tpAddr

  idx& = _HmHash(theKey$, capVal&)
  tombIdx& = -1
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED THEN
      IF k$(idx&) = theKey$ THEN
        vL&(idx&) = theRef&
        tp%(idx&) = HmTypeRef
        HmPutRef = HM_SUCCESS
        EXIT SUB
      END IF
    ELSEIF tombIdx& = -1 THEN
      tombIdx& = idx&
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  maxLoad& = (capVal& * 7) \ 10
  IF hm->count >= maxLoad& THEN
    HmPutRef = HM_ERR_FULL
    EXIT SUB
  END IF

  IF tombIdx& >= 0 THEN
    idx& = tombIdx&
  ELSEIF probes& >= capVal& THEN
    HmPutRef = HM_ERR_FULL
    EXIT SUB
  END IF

  k$(idx&) = theKey$
  vL&(idx&) = theRef&
  tp%(idx&) = HmTypeRef
  st%(idx&) = HM_OCCUPIED
  hm->count = hm->count + 1
  _HmOrderAppend(hm, idx&)
  HmPutRef = HM_SUCCESS
END SUB

{* ============== Core: Put Bool ============== *}

SUB SHORTINT HmPutBool(Hashmap hm, theKey$, SHORTINT theVal%) EXTERNAL
  LONGINT idx&, tombIdx&, maxLoad&, probes&, capVal&
  ADDRESS kAddr, vlAddr, stAddr, tpAddr

  capVal& = hm->cap
  kAddr = hm->keys
  vlAddr = hm->valsL
  stAddr = hm->status
  tpAddr = hm->types

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM vL&(HM_MAX_BOUND) ADDRESS vlAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr
  DIM tp%(HM_MAX_BOUND) ADDRESS tpAddr

  idx& = _HmHash(theKey$, capVal&)
  tombIdx& = -1
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED THEN
      IF k$(idx&) = theKey$ THEN
        IF theVal% THEN vL&(idx&) = 1 ELSE vL&(idx&) = 0
        tp%(idx&) = HmTypeBool
        HmPutBool = HM_SUCCESS
        EXIT SUB
      END IF
    ELSEIF tombIdx& = -1 THEN
      tombIdx& = idx&
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  maxLoad& = (capVal& * 7) \ 10
  IF hm->count >= maxLoad& THEN
    HmPutBool = HM_ERR_FULL
    EXIT SUB
  END IF

  IF tombIdx& >= 0 THEN
    idx& = tombIdx&
  ELSEIF probes& >= capVal& THEN
    HmPutBool = HM_ERR_FULL
    EXIT SUB
  END IF

  k$(idx&) = theKey$
  IF theVal% THEN vL&(idx&) = 1 ELSE vL&(idx&) = 0
  tp%(idx&) = HmTypeBool
  st%(idx&) = HM_OCCUPIED
  hm->count = hm->count + 1
  _HmOrderAppend(hm, idx&)
  HmPutBool = HM_SUCCESS
END SUB

{* ============== Core: Put Null ============== *}

SUB SHORTINT HmPutNull(Hashmap hm, theKey$) EXTERNAL
  LONGINT idx&, tombIdx&, maxLoad&, probes&, capVal&
  ADDRESS kAddr, stAddr, tpAddr

  capVal& = hm->cap
  kAddr = hm->keys
  stAddr = hm->status
  tpAddr = hm->types

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr
  DIM tp%(HM_MAX_BOUND) ADDRESS tpAddr

  idx& = _HmHash(theKey$, capVal&)
  tombIdx& = -1
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED THEN
      IF k$(idx&) = theKey$ THEN
        tp%(idx&) = HmTypeNull
        HmPutNull = HM_SUCCESS
        EXIT SUB
      END IF
    ELSEIF tombIdx& = -1 THEN
      tombIdx& = idx&
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  maxLoad& = (capVal& * 7) \ 10
  IF hm->count >= maxLoad& THEN
    HmPutNull = HM_ERR_FULL
    EXIT SUB
  END IF

  IF tombIdx& >= 0 THEN
    idx& = tombIdx&
  ELSEIF probes& >= capVal& THEN
    HmPutNull = HM_ERR_FULL
    EXIT SUB
  END IF

  k$(idx&) = theKey$
  tp%(idx&) = HmTypeNull
  st%(idx&) = HM_OCCUPIED
  hm->count = hm->count + 1
  _HmOrderAppend(hm, idx&)
  HmPutNull = HM_SUCCESS
END SUB

{* ============== Core: Get String ============== *}

SUB STRING HmGet$(Hashmap hm, theKey$) EXTERNAL
  LONGINT idx&, probes&, capVal&
  ADDRESS kAddr, vAddr, stAddr

  capVal& = hm->cap
  kAddr = hm->keys
  vAddr = hm->vals
  stAddr = hm->status

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM v$(HM_MAX_BOUND) SIZE HM_VAL_SIZE ADDRESS vAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr

  idx& = _HmHash(theKey$, capVal&)
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED AND k$(idx&) = theKey$ THEN
      HmGet$ = v$(idx&)
      EXIT SUB
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  HmGet$ = ""
END SUB

{* ============== Core: Get Long ============== *}

SUB LONGINT HmGet&(Hashmap hm, theKey$) EXTERNAL
  LONGINT idx&, probes&, capVal&
  ADDRESS kAddr, vlAddr, stAddr

  capVal& = hm->cap
  kAddr = hm->keys
  vlAddr = hm->valsL
  stAddr = hm->status

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM vL&(HM_MAX_BOUND) ADDRESS vlAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr

  idx& = _HmHash(theKey$, capVal&)
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED AND k$(idx&) = theKey$ THEN
      HmGet& = vL&(idx&)
      EXIT SUB
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  HmGet& = 0
END SUB

{* ============== Core: Get Single ============== *}

SUB SINGLE HmGet!(Hashmap hm, theKey$) EXTERNAL
  LONGINT idx&, probes&, capVal&
  ADDRESS kAddr, vlAddr, stAddr

  capVal& = hm->cap
  kAddr = hm->keys
  vlAddr = hm->valsL
  stAddr = hm->status

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM vF!(HM_MAX_BOUND) ADDRESS vlAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr

  idx& = _HmHash(theKey$, capVal&)
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED AND k$(idx&) = theKey$ THEN
      HmGet! = vF!(idx&)
      EXIT SUB
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  HmGet! = 0
END SUB

{* ============== Core: Get Ref ============== *}

SUB LONGINT HmGetRef(Hashmap hm, theKey$) EXTERNAL
  LONGINT idx&, probes&, capVal&
  ADDRESS kAddr, vlAddr, stAddr

  capVal& = hm->cap
  kAddr = hm->keys
  vlAddr = hm->valsL
  stAddr = hm->status

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM vL&(HM_MAX_BOUND) ADDRESS vlAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr

  idx& = _HmHash(theKey$, capVal&)
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED AND k$(idx&) = theKey$ THEN
      HmGetRef = vL&(idx&)
      EXIT SUB
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  HmGetRef = 0
END SUB

{* ============== Core: Has Key ============== *}

SUB SHORTINT HmHas(Hashmap hm, theKey$) EXTERNAL
  LONGINT idx&, probes&, capVal&
  ADDRESS kAddr, stAddr

  capVal& = hm->cap
  kAddr = hm->keys
  stAddr = hm->status

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr

  idx& = _HmHash(theKey$, capVal&)
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED AND k$(idx&) = theKey$ THEN
      HmHas = -1
      EXIT SUB
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  HmHas = 0
END SUB

{* ============== Core: Type ============== *}

SUB SHORTINT HmType(Hashmap hm, theKey$) EXTERNAL
  LONGINT idx&, probes&, capVal&
  ADDRESS kAddr, stAddr, tpAddr

  capVal& = hm->cap
  kAddr = hm->keys
  stAddr = hm->status
  tpAddr = hm->types

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr
  DIM tp%(HM_MAX_BOUND) ADDRESS tpAddr

  idx& = _HmHash(theKey$, capVal&)
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED AND k$(idx&) = theKey$ THEN
      HmType = tp%(idx&)
      EXIT SUB
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  HmType = -1
END SUB

{* ============== Core: Delete ============== *}

SUB SHORTINT HmDel(Hashmap hm, theKey$) EXTERNAL
  LONGINT idx&, probes&, capVal&
  ADDRESS kAddr, stAddr

  capVal& = hm->cap
  kAddr = hm->keys
  stAddr = hm->status

  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr

  idx& = _HmHash(theKey$, capVal&)
  probes& = 0

  WHILE probes& < capVal& AND st%(idx&) <> HM_EMPTY
    IF st%(idx&) = HM_OCCUPIED AND k$(idx&) = theKey$ THEN
      st%(idx&) = HM_TOMBSTONE
      hm->count = hm->count - 1
      HmDel = HM_SUCCESS
      EXIT SUB
    END IF
    idx& = (idx& + 1) AND (capVal& - 1)
    probes& = probes& + 1
  WEND

  HmDel = HM_ERR_NOTFOUND
END SUB

{* ============== Info ============== *}

SUB LONGINT HmCount(Hashmap hm) EXTERNAL
  HmCount = hm->count
END SUB

SUB LONGINT HmCapacity(Hashmap hm) EXTERNAL
  HmCapacity = hm->cap
END SUB

{* ============== Iteration ============== *}

{*
** Iterator walks entries in insertion order.
** Cursor state is stored in the Hashmap instance itself.
** Skips tombstoned entries and invalidated order slots.
*}

SUB HmIterReset(Hashmap hm) EXTERNAL
  hm->cursor = -1
  hm->curIdx = -1
END SUB

SUB SHORTINT HmIterNext(Hashmap hm) EXTERNAL
  ADDRESS oAddr, stAddr
  LONGINT pos&
  SHORTINT backIdx%

  oAddr = hm->order
  stAddr = hm->status
  DIM ord%(HM_MAX_BOUND) ADDRESS oAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr

  pos& = hm->cursor + 1
  WHILE pos& < hm->orderCount
    backIdx% = ord%(pos&)
    IF backIdx% >= 0 AND st%(backIdx%) = HM_OCCUPIED THEN
      hm->cursor = pos&
      hm->curIdx = backIdx%
      HmIterNext = -1
      EXIT SUB
    END IF
    pos& = pos& + 1
  WEND

  ' No more entries
  hm->cursor = hm->orderCount
  hm->curIdx = -1
  HmIterNext = 0
END SUB

SUB STRING HmIterKey$(Hashmap hm) EXTERNAL
  ADDRESS kAddr

  IF hm->curIdx < 0 THEN
    HmIterKey$ = ""
    EXIT SUB
  END IF

  kAddr = hm->keys
  DIM k$(HM_MAX_BOUND) SIZE HM_KEY_SIZE ADDRESS kAddr
  HmIterKey$ = k$(hm->curIdx)
END SUB

SUB STRING HmIterVal$(Hashmap hm) EXTERNAL
  ADDRESS vAddr

  IF hm->curIdx < 0 THEN
    HmIterVal$ = ""
    EXIT SUB
  END IF

  vAddr = hm->vals
  DIM v$(HM_MAX_BOUND) SIZE HM_VAL_SIZE ADDRESS vAddr
  HmIterVal$ = v$(hm->curIdx)
END SUB

SUB LONGINT HmIterVal&(Hashmap hm) EXTERNAL
  ADDRESS vlAddr

  IF hm->curIdx < 0 THEN
    HmIterVal& = 0
    EXIT SUB
  END IF

  vlAddr = hm->valsL
  DIM vL&(HM_MAX_BOUND) ADDRESS vlAddr
  HmIterVal& = vL&(hm->curIdx)
END SUB

SUB SINGLE HmIterVal!(Hashmap hm) EXTERNAL
  ADDRESS vlAddr

  IF hm->curIdx < 0 THEN
    HmIterVal! = 0
    EXIT SUB
  END IF

  vlAddr = hm->valsL
  DIM vF!(HM_MAX_BOUND) ADDRESS vlAddr
  HmIterVal! = vF!(hm->curIdx)
END SUB

SUB SHORTINT HmIterType(Hashmap hm) EXTERNAL
  ADDRESS tpAddr

  IF hm->curIdx < 0 THEN
    HmIterType = -1
    EXIT SUB
  END IF

  tpAddr = hm->types
  DIM tp%(HM_MAX_BOUND) ADDRESS tpAddr
  HmIterType = tp%(hm->curIdx)
END SUB

{* ============== Higher-Order Iteration ============== *}

{*
** HmForEach - Call a function for each entry in insertion order.
** Callback signature:
**   SUB ADDRESS cb(ADDRESS keyPtr, LONGINT rawVal&,
**                  ADDRESS strPtr, SHORTINT typ%) INVOKABLE
** Use CSTR(keyPtr) and CSTR(strPtr) in callback for string access.
** Pass callback as BIND(@MySub).
*}
SUB HmForEach(Hashmap hm, ADDRESS fun) EXTERNAL
  ADDRESS oAddr, stAddr, vlAddr, tpAddr, kPtr, vPtr
  LONGINT pos&, bIdx&

  oAddr = hm->order
  stAddr = hm->status
  vlAddr = hm->valsL
  tpAddr = hm->types

  DIM ord%(HM_MAX_BOUND) ADDRESS oAddr
  DIM st%(HM_MAX_BOUND) ADDRESS stAddr
  DIM vL&(HM_MAX_BOUND) ADDRESS vlAddr
  DIM tp%(HM_MAX_BOUND) ADDRESS tpAddr

  pos& = 0
  WHILE pos& < hm->orderCount
    bIdx& = ord%(pos&)
    IF bIdx& >= 0 AND st%(bIdx&) = HM_OCCUPIED THEN
      kPtr = hm->keys + bIdx& * HM_KEY_SIZE
      vPtr = hm->vals + bIdx& * HM_VAL_SIZE
      INVOKE fun(kPtr, vL&(bIdx&), vPtr, tp%(bIdx&))
    END IF
    pos& = pos& + 1
  WEND
END SUB
