{*
** Lisp-style List Library for ACE BASIC
** Singly-linked lists with mixed types (integers, longs, singles, strings, nested lists)
**
** Based on Common Lisp list semantics:
** - Cons cells with car (value) and cdr (next pointer)
** - Type tags for runtime type checking
** - Copy semantics for all values including strings
**
** Memory Management:
** - Uses AllocVec/FreeVec for explicit control
** - LFree must be called to release memory
** - Strings are copied on insertion and freed on LFree
*}

{* ============== Constants ============== *}

CONST LNil = 0

' Type tags
CONST LTypeNil = 0
CONST LTypeInt = 1
CONST LTypeLng = 2
CONST LTypeSng = 3
CONST LTypeStr = 4
CONST LTypeList = 5

{* Memory flags for AllocVec *}
CONST LMEMF_PUBLIC = 1&
CONST LMEMF_CLEAR = 65536&

{* ============== Cell Structure ============== *}

STRUCT LCell
  LONGINT car
  ADDRESS cdr
  BYTE tag
END STRUCT

{* ============== Builder State (module-level) ============== *}

ADDRESS _LBuildHead, _LBuildTail

{* ============== Library Declarations ============== *}

DECLARE FUNCTION ADDRESS AllocVec(LONGINT byteSize, LONGINT requirements) LIBRARY exec
DECLARE FUNCTION FreeVec(ADDRESS memoryBlock) LIBRARY exec
DECLARE FUNCTION CopyMem(ADDRESS source, ADDRESS dest, LONGINT sz) LIBRARY exec

{* ============== Initialization ============== *}

SUB LInit EXTERNAL
  LIBRARY "exec.library"
END SUB

SUB LCleanup EXTERNAL
  LIBRARY CLOSE "exec.library"
END SUB

{* ============== Internal Helper: Allocate a cell ============== *}

SUB ADDRESS _LAllocCell
  ADDRESS res
  res = AllocVec(SIZEOF(LCell), LMEMF_PUBLIC OR LMEMF_CLEAR)
  _LAllocCell = res
END SUB

{* ============== Internal Helper: Allocate and copy string ============== *}

SUB ADDRESS _LCopyString(src$)
  ADDRESS buf
  LONGINT slen

  slen = LEN(src$) + 1  ' +1 for null terminator
  buf = AllocVec(slen, LMEMF_PUBLIC)
  IF buf <> LNil THEN
    CopyMem(SADD(src$), buf, slen)
  END IF
  _LCopyString = buf
END SUB

{* ============== Cell Creation - Prepend (O(1)) ============== *}

SUB ADDRESS LCons%(SHORTINT v, ADDRESS tl) EXTERNAL
  DECLARE STRUCT LCell *cel
  ADDRESS result

  cel = _LAllocCell
  IF cel <> LNil THEN
    cel->tag = LTypeInt
    cel->car = v
    cel->cdr = tl
  END IF
  result = cel
  LCons% = result
END SUB

SUB ADDRESS LCons&(LONGINT v, ADDRESS tl) EXTERNAL
  DECLARE STRUCT LCell *cel

  cel = _LAllocCell
  IF cel <> LNil THEN
    cel->tag = LTypeLng
    cel->car = v
    cel->cdr = tl
  END IF
  LCons& = cel
END SUB

SUB ADDRESS LCons!(SINGLE v, ADDRESS tl) EXTERNAL
  DECLARE STRUCT LCell *cel
  ADDRESS vAddr

  cel = _LAllocCell
  IF cel <> LNil THEN
    cel->tag = LTypeSng
    ' Store float bits as LONG
    vAddr = VARPTR(v)
    cel->car = PEEKL(vAddr)
    cel->cdr = tl
  END IF
  LCons! = cel
END SUB

SUB ADDRESS LCons$(src$, ADDRESS tl) EXTERNAL
  DECLARE STRUCT LCell *cel
  ADDRESS strCopy

  strCopy = _LCopyString(src$)
  IF strCopy = LNil THEN
    LCons$ = LNil
    EXIT SUB
  END IF

  cel = _LAllocCell
  IF cel <> LNil THEN
    cel->tag = LTypeStr
    cel->car = strCopy
    cel->cdr = tl
  ELSE
    FreeVec(strCopy)
  END IF
  LCons$ = cel
END SUB

SUB ADDRESS LConsList(ADDRESS ptr, ADDRESS tl) EXTERNAL
  DECLARE STRUCT LCell *cel

  cel = _LAllocCell
  IF cel <> LNil THEN
    cel->tag = LTypeList
    cel->car = ptr
    cel->cdr = tl
  END IF
  LConsList = cel
END SUB

{* ============== Cell Creation - Append (O(n)) ============== *}

{* Internal helper: find last cell *}
SUB ADDRESS _LLastCell(ADDRESS lst)
  DECLARE STRUCT LCell *cr

  IF lst = LNil THEN
    _LLastCell = LNil
    EXIT SUB
  END IF

  cr = lst
  WHILE cr->cdr <> LNil
    cr = cr->cdr
  WEND
  _LLastCell = cr
END SUB

SUB ADDRESS LSnoc%(SHORTINT v, ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *lastCel
  ADDRESS newAddr

  newAddr = LCons%(v, LNil)
  IF newAddr = LNil THEN
    LSnoc% = LNil
    EXIT SUB
  END IF

  IF lst = LNil THEN
    LSnoc% = newAddr
    EXIT SUB
  END IF

  lastCel = _LLastCell(lst)
  lastCel->cdr = newAddr
  LSnoc% = lst
END SUB

SUB ADDRESS LSnoc&(LONGINT v, ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *lastCel
  ADDRESS newAddr

  newAddr = LCons&(v, LNil)
  IF newAddr = LNil THEN
    LSnoc& = LNil
    EXIT SUB
  END IF

  IF lst = LNil THEN
    LSnoc& = newAddr
    EXIT SUB
  END IF

  lastCel = _LLastCell(lst)
  lastCel->cdr = newAddr
  LSnoc& = lst
END SUB

SUB ADDRESS LSnoc!(SINGLE v, ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *lastCel
  ADDRESS newAddr

  newAddr = LCons!(v, LNil)
  IF newAddr = LNil THEN
    LSnoc! = LNil
    EXIT SUB
  END IF

  IF lst = LNil THEN
    LSnoc! = newAddr
    EXIT SUB
  END IF

  lastCel = _LLastCell(lst)
  lastCel->cdr = newAddr
  LSnoc! = lst
END SUB

SUB ADDRESS LSnoc$(src$, ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *lastCel
  ADDRESS newAddr

  newAddr = LCons$(src$, LNil)
  IF newAddr = LNil THEN
    LSnoc$ = LNil
    EXIT SUB
  END IF

  IF lst = LNil THEN
    LSnoc$ = newAddr
    EXIT SUB
  END IF

  lastCel = _LLastCell(lst)
  lastCel->cdr = newAddr
  LSnoc$ = lst
END SUB

SUB ADDRESS LSnocList(ADDRESS ptr, ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *lastCel
  ADDRESS newAddr

  newAddr = LConsList(ptr, LNil)
  IF newAddr = LNil THEN
    LSnocList = LNil
    EXIT SUB
  END IF

  IF lst = LNil THEN
    LSnocList = newAddr
    EXIT SUB
  END IF

  lastCel = _LLastCell(lst)
  lastCel->cdr = newAddr
  LSnocList = lst
END SUB

{* ============== Accessors ============== *}

SUB SHORTINT LCar%(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cel

  IF lst = LNil THEN
    PRINT "LCar%: empty list"
    LCar% = 0
    EXIT SUB
  END IF

  cel = lst
  IF cel->tag <> LTypeInt THEN
    PRINT "LCar%: type mismatch, expected INT got"; cel->tag
    LCar% = 0
    EXIT SUB
  END IF

  LCar% = cel->car
END SUB

SUB LONGINT LCar&(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cel

  IF lst = LNil THEN
    PRINT "LCar&: empty list"
    LCar& = 0
    EXIT SUB
  END IF

  cel = lst
  IF cel->tag <> LTypeLng THEN
    PRINT "LCar&: type mismatch, expected LNG got"; cel->tag
    LCar& = 0
    EXIT SUB
  END IF

  LCar& = cel->car
END SUB

SUB SINGLE LCar!(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cel
  SINGLE res
  ADDRESS resAddr

  IF lst = LNil THEN
    PRINT "LCar!: empty list"
    LCar! = 0!
    EXIT SUB
  END IF

  cel = lst
  IF cel->tag <> LTypeSng THEN
    PRINT "LCar!: type mismatch, expected SNG got"; cel->tag
    LCar! = 0!
    EXIT SUB
  END IF

  ' Interpret stored LONG bits as SINGLE
  resAddr = VARPTR(res)
  POKEL resAddr, cel->car
  LCar! = res
END SUB

SUB STRING LCar$(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cel

  IF lst = LNil THEN
    PRINT "LCar$: empty list"
    LCar$ = ""
    EXIT SUB
  END IF

  cel = lst
  IF cel->tag <> LTypeStr THEN
    PRINT "LCar$: type mismatch, expected STR got"; cel->tag
    LCar$ = ""
    EXIT SUB
  END IF

  LCar$ = CSTR(cel->car)
END SUB

SUB ADDRESS LCar(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cel
  ADDRESS result

  IF lst = LNil THEN
    result = LNil
  ELSE
    cel = lst
    result = cel->car
  END IF
  LCar = result
END SUB

SUB ADDRESS LCdr(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cel
  ADDRESS result

  IF lst = LNil THEN
    result = LNil
  ELSE
    cel = lst
    result = cel->cdr
  END IF
  LCdr = result
END SUB

SUB ADDRESS LRest(ADDRESS lst) EXTERNAL
  LRest = LCdr(lst)
END SUB

{* ============== Convenience Accessors ============== *}

SUB SHORTINT LFirst%(ADDRESS lst) EXTERNAL
  LFirst% = LCar%(lst)
END SUB

SUB LONGINT LFirst&(ADDRESS lst) EXTERNAL
  LFirst& = LCar&(lst)
END SUB

SUB SINGLE LFirst!(ADDRESS lst) EXTERNAL
  LFirst! = LCar!(lst)
END SUB

SUB STRING LFirst$(ADDRESS lst) EXTERNAL
  LFirst$ = LCar$(lst)
END SUB

SUB ADDRESS LFirst(ADDRESS lst) EXTERNAL
  LFirst = LCar(lst)
END SUB

SUB SHORTINT LSecond%(ADDRESS lst) EXTERNAL
  LSecond% = LCar%(LCdr(lst))
END SUB

SUB LONGINT LSecond&(ADDRESS lst) EXTERNAL
  LSecond& = LCar&(LCdr(lst))
END SUB

SUB SINGLE LSecond!(ADDRESS lst) EXTERNAL
  LSecond! = LCar!(LCdr(lst))
END SUB

SUB STRING LSecond$(ADDRESS lst) EXTERNAL
  LSecond$ = LCar$(LCdr(lst))
END SUB

SUB ADDRESS LSecond(ADDRESS lst) EXTERNAL
  LSecond = LCar(LCdr(lst))
END SUB

{* ============== Predicates & Info ============== *}

SUB SHORTINT LNull(ADDRESS lst) EXTERNAL
  IF lst = LNil THEN
    LNull = -1
  ELSE
    LNull = 0
  END IF
END SUB

SUB SHORTINT LType(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cel

  IF lst = LNil THEN
    LType = LTypeNil
    EXIT SUB
  END IF

  cel = lst
  LType = cel->tag
END SUB

SUB LONGINT LLen(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cr
  LONGINT cnt

  cnt = 0
  cr = lst
  WHILE cr <> LNil
    cnt = cnt + 1
    cr = cr->cdr
  WEND
  LLen = cnt
END SUB

{* ============== Builder Pattern ============== *}

SUB LNew EXTERNAL
  SHARED _LBuildHead, _LBuildTail
  _LBuildHead = LNil
  _LBuildTail = LNil
END SUB

SUB LAdd%(SHORTINT v) EXTERNAL
  SHARED _LBuildHead, _LBuildTail
  DECLARE STRUCT LCell *tail
  ADDRESS newAddr

  newAddr = LCons%(v, LNil)
  IF newAddr = LNil THEN
    EXIT SUB
  END IF

  IF _LBuildHead = LNil THEN
    _LBuildHead = newAddr
    _LBuildTail = newAddr
  ELSE
    tail = _LBuildTail
    tail->cdr = newAddr
    _LBuildTail = newAddr
  END IF
END SUB

SUB LAdd&(LONGINT v) EXTERNAL
  SHARED _LBuildHead, _LBuildTail
  DECLARE STRUCT LCell *tail
  ADDRESS newAddr

  newAddr = LCons&(v, LNil)
  IF newAddr = LNil THEN
    EXIT SUB
  END IF

  IF _LBuildHead = LNil THEN
    _LBuildHead = newAddr
    _LBuildTail = newAddr
  ELSE
    tail = _LBuildTail
    tail->cdr = newAddr
    _LBuildTail = newAddr
  END IF
END SUB

SUB LAdd!(SINGLE v) EXTERNAL
  SHARED _LBuildHead, _LBuildTail
  DECLARE STRUCT LCell *tail
  ADDRESS newAddr

  newAddr = LCons!(v, LNil)
  IF newAddr = LNil THEN
    EXIT SUB
  END IF

  IF _LBuildHead = LNil THEN
    _LBuildHead = newAddr
    _LBuildTail = newAddr
  ELSE
    tail = _LBuildTail
    tail->cdr = newAddr
    _LBuildTail = newAddr
  END IF
END SUB

SUB LAdd$(src$) EXTERNAL
  SHARED _LBuildHead, _LBuildTail
  DECLARE STRUCT LCell *tail
  ADDRESS newAddr

  newAddr = LCons$(src$, LNil)
  IF newAddr = LNil THEN
    EXIT SUB
  END IF

  IF _LBuildHead = LNil THEN
    _LBuildHead = newAddr
    _LBuildTail = newAddr
  ELSE
    tail = _LBuildTail
    tail->cdr = newAddr
    _LBuildTail = newAddr
  END IF
END SUB

SUB LAddList(ADDRESS ptr) EXTERNAL
  SHARED _LBuildHead, _LBuildTail
  DECLARE STRUCT LCell *tail
  ADDRESS newAddr

  newAddr = LConsList(ptr, LNil)
  IF newAddr = LNil THEN
    EXIT SUB
  END IF

  IF _LBuildHead = LNil THEN
    _LBuildHead = newAddr
    _LBuildTail = newAddr
  ELSE
    tail = _LBuildTail
    tail->cdr = newAddr
    _LBuildTail = newAddr
  END IF
END SUB

SUB ADDRESS LEnd EXTERNAL
  SHARED _LBuildHead, _LBuildTail
  ADDRESS result
  result = _LBuildHead
  _LBuildHead = LNil
  _LBuildTail = LNil
  LEnd = result
END SUB

{* ============== List Operations - Non-destructive ============== *}

SUB ADDRESS LAppend(ADDRESS a, ADDRESS b) EXTERNAL
  DECLARE STRUCT LCell *cr, *newCel, *tailCel
  ADDRESS res, newAddr, newTailAddr

  ' If a is empty, just return b
  IF a = LNil THEN
    LAppend = b
    EXIT SUB
  END IF

  ' Copy cells from a
  res = LNil
  newTailAddr = LNil
  cr = a

  WHILE cr <> LNil
    ' Allocate new cell with same content
    newAddr = _LAllocCell
    IF newAddr = LNil THEN
      ' Allocation failed - should free what we've built, but skip for simplicity
      LAppend = LNil
      EXIT SUB
    END IF

    newCel = newAddr
    newCel->tag = cr->tag
    ' For strings, we need to copy the string
    IF cr->tag = LTypeStr THEN
      newCel->car = _LCopyString(CSTR(cr->car))
    ELSE
      newCel->car = cr->car
    END IF
    newCel->cdr = LNil

    IF res = LNil THEN
      res = newAddr
      newTailAddr = newAddr
    ELSE
      tailCel = newTailAddr
      tailCel->cdr = newAddr
      newTailAddr = newAddr
    END IF

    cr = cr->cdr
  WEND

  ' Link tail to b (shared, not copied)
  IF newTailAddr <> LNil THEN
    tailCel = newTailAddr
    tailCel->cdr = b
  END IF

  LAppend = res
END SUB

SUB ADDRESS LRev(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cr, *newCel
  ADDRESS res, newAddr

  res = LNil
  cr = lst

  WHILE cr <> LNil
    ' Cons each element onto result (reverses order)
    newAddr = _LAllocCell
    IF newAddr = LNil THEN
      LRev = LNil
      EXIT SUB
    END IF

    newCel = newAddr
    newCel->tag = cr->tag
    IF cr->tag = LTypeStr THEN
      newCel->car = _LCopyString(CSTR(cr->car))
    ELSE
      newCel->car = cr->car
    END IF
    newCel->cdr = res
    res = newAddr

    cr = cr->cdr
  WEND

  LRev = res
END SUB

SUB ADDRESS LCopy(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cr, *newCel, *tailCel
  ADDRESS res, newAddr, newTailAddr, nestedCopy

  IF lst = LNil THEN
    LCopy = LNil
    EXIT SUB
  END IF

  res = LNil
  newTailAddr = LNil
  cr = lst

  WHILE cr <> LNil
    newAddr = _LAllocCell
    IF newAddr = LNil THEN
      LCopy = LNil
      EXIT SUB
    END IF

    newCel = newAddr
    newCel->tag = cr->tag

    ' Deep copy: strings and nested lists
    IF cr->tag = LTypeStr THEN
      newCel->car = _LCopyString(CSTR(cr->car))
    ELSEIF cr->tag = LTypeList THEN
      nestedCopy = LCopy(cr->car)
      newCel->car = nestedCopy
    ELSE
      newCel->car = cr->car
    END IF
    newCel->cdr = LNil

    IF res = LNil THEN
      res = newAddr
      newTailAddr = newAddr
    ELSE
      tailCel = newTailAddr
      tailCel->cdr = newAddr
      newTailAddr = newAddr
    END IF

    cr = cr->cdr
  WEND

  LCopy = res
END SUB

SUB ADDRESS LNth(ADDRESS lst, SHORTINT n) EXTERNAL
  DECLARE STRUCT LCell *cr
  SHORTINT idx

  IF lst = LNil OR n < 0 THEN
    LNth = LNil
    EXIT SUB
  END IF

  cr = lst
  idx = 0
  WHILE cr <> LNil AND idx < n
    cr = cr->cdr
    idx = idx + 1
  WEND

  LNth = cr
END SUB

{* ============== List Operations - Destructive ============== *}

SUB LNconc(ADDRESS a, ADDRESS b) EXTERNAL
  DECLARE STRUCT LCell *lastCel

  IF a = LNil THEN
    EXIT SUB
  END IF

  lastCel = _LLastCell(a)
  lastCel->cdr = b
END SUB

SUB ADDRESS LNrev(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cr
  ADDRESS prevAddr, crAddr, nxtAddr

  IF lst = LNil THEN
    LNrev = LNil
    EXIT SUB
  END IF

  prevAddr = LNil
  crAddr = lst

  WHILE crAddr <> LNil
    cr = crAddr
    nxtAddr = cr->cdr
    cr->cdr = prevAddr
    prevAddr = crAddr
    crAddr = nxtAddr
  WEND

  LNrev = prevAddr
END SUB

SUB LFree(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cr
  ADDRESS crAddr, nxtAddr

  crAddr = lst

  WHILE crAddr <> LNil
    cr = crAddr
    nxtAddr = cr->cdr

    ' Free string data if this is a string cell
    IF cr->tag = LTypeStr THEN
      IF cr->car <> LNil THEN
        FreeVec(cr->car)
      END IF
    ' Recursively free nested lists
    ELSEIF cr->tag = LTypeList THEN
      IF cr->car <> LNil THEN
        LFree(cr->car)
      END IF
    END IF

    ' Free the cell itself
    FreeVec(crAddr)

    crAddr = nxtAddr
  WEND
END SUB

{* ============== Debugging ============== *}

DECLARE SUB LDump(ADDRESS lst)

SUB _LDumpValue(ADDRESS cel)
  DECLARE STRUCT LCell *c
  SINGLE floatVal
  ADDRESS floatAddr

  c = cel
  IF c->tag = LTypeInt THEN
    PRINT c->car;
  ELSEIF c->tag = LTypeLng THEN
    PRINT c->car;
  ELSEIF c->tag = LTypeSng THEN
    floatAddr = VARPTR(floatVal)
    POKEL floatAddr, c->car
    PRINT floatVal;
  ELSEIF c->tag = LTypeStr THEN
    PRINT CHR$(34); CSTR(c->car); CHR$(34);
  ELSEIF c->tag = LTypeList THEN
    LDump(c->car)
  ELSE
    PRINT "?";
  END IF
END SUB

SUB LDump(ADDRESS lst) EXTERNAL
  DECLARE STRUCT LCell *cr
  ADDRESS crAddr
  SHORTINT frst

  PRINT "(";

  frst = -1
  crAddr = lst
  WHILE crAddr <> LNil
    IF NOT frst THEN
      PRINT " ";
    END IF
    frst = 0

    _LDumpValue(crAddr)

    cr = crAddr
    crAddr = cr->cdr
  WEND

  PRINT ")";
END SUB

SUB LDumpLn(ADDRESS lst) EXTERNAL
  LDump(lst)
  PRINT
END SUB
