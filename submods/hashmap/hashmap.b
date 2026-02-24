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
  HmPut$ = HM_SUCCESS
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
