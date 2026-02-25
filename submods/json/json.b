REM json.b - JSON parser and generator for ACE BASIC
REM
REM Dependencies: hashmap.o, dynarray.o
REM Uses Hashmap for JSON objects, DynArray for JSON arrays.
REM TYPECASE discriminates object vs array at each node.

#include <submods/hashmap.h>
#include <submods/dynarray.h>

{* ============== Constants ============== *}

CONST _JS_HM_SIZE = 48   ' Hashmap CLASS struct size (4 + 6*4 + 5*4)
CONST _JS_DA_SIZE = 28   ' DynArray CLASS struct size (4 + 3*4 + 3*4)

CONST JS_SUCCESS      = 0
CONST JS_ERR_SYNTAX   = -1
CONST JS_ERR_DEPTH    = -2
CONST JS_ERR_OVERFLOW = -3
CONST JS_ERR_IO       = -4

CONST JsObject = 0
CONST JsArray  = 1

CONST JS_MAX_INPUT = 8192
CONST JS_MAX_DEPTH = 10

{* ============== Module-level shared state ============== *}

LONGINT _jsBase&          ' SADD of input string
LONGINT _jsPos&           ' Current byte offset (0-based)
LONGINT _jsLen&           ' Input length
SHORTINT _jsDepth%        ' Current nesting depth
SHORTINT _jsRootType%     ' JsObject(0) or JsArray(1)
STRING _jsErr$ SIZE 128

' Cached class descriptor pointers
LONGINT _jsHmDesc&
LONGINT _jsDaDesc&
SHORTINT _jsInited%

' Number scanner results (shared between _JsScanNumber and callers)
STRING _jsNumBuf$ SIZE 32
SHORTINT _jsNumIsFloat%
LONGINT _jsNumInt&

' Depth-indexed key stack (avoids BSS clobbering in recursive calls)
DIM _jsKeyStk$(10) SIZE 64

{* ============== Internal: Descriptor cache ============== *}

SUB _JsInitDesc
  SHARED _jsHmDesc&, _jsDaDesc&, _jsInited%
  IF _jsInited% THEN EXIT SUB

  DECLARE CLASS Hashmap tmpHm
  DECLARE CLASS DynArray tmpDa
  _jsHmDesc& = PEEKL(tmpHm)
  _jsDaDesc& = PEEKL(tmpDa)
  _jsInited% = -1
END SUB

{* ============== Internal: Scanner helpers ============== *}

SUB SHORTINT _JsCh%
  SHARED _jsBase&, _jsPos&, _jsLen&
  SHORTINT retVal%
  IF _jsPos& >= _jsLen& THEN
    retVal% = -1
  ELSE
    retVal% = PEEK(_jsBase& + _jsPos&)
  END IF
  _JsCh% = retVal%
END SUB

SUB _JsSkipWs
  SHARED _jsBase&, _jsPos&, _jsLen&
  SHORTINT ch%
  IF _jsPos& < _jsLen& THEN
    ch% = PEEK(_jsBase& + _jsPos&)
  ELSE
    ch% = -1
  END IF
  WHILE ch% = 32 OR ch% = 9 OR ch% = 10 OR ch% = 13
    _jsPos& = _jsPos& + 1
    IF _jsPos& < _jsLen& THEN
      ch% = PEEK(_jsBase& + _jsPos&)
    ELSE
      ch% = -1
    END IF
  WEND
END SUB

SUB _JsExpect(SHORTINT expected%)
  SHARED _jsBase&, _jsPos&, _jsLen&, _jsErr$
  IF LEN(_jsErr$) > 0 THEN EXIT SUB
  SHORTINT ch%
  IF _jsPos& < _jsLen& THEN
    ch% = PEEK(_jsBase& + _jsPos&)
  ELSE
    ch% = -1
  END IF
  IF ch% = expected% THEN
    _jsPos& = _jsPos& + 1
  ELSE
    IF LEN(_jsErr$) = 0 THEN
      _jsErr$ = "Expected " + CHR$(expected%)
    END IF
  END IF
END SUB

SUB _JsSetError(msg$)
  SHARED _jsErr$
  IF LEN(_jsErr$) = 0 THEN
    _jsErr$ = msg$
  END IF
END SUB

{* ============== Internal: Literal matching ============== *}

SUB SHORTINT _JsMatchLit(lit$)
  SHARED _jsBase&, _jsPos&, _jsLen&
  LONGINT litLen&, i&
  SHORTINT retVal%
  retVal% = 0
  litLen& = LEN(lit$)

  IF _jsPos& + litLen& <= _jsLen& THEN
    retVal% = -1
    i& = 0
    WHILE i& < litLen& AND retVal%
      IF PEEK(_jsBase& + _jsPos& + i&) <> ASC(MID$(lit$, i& + 1, 1)) THEN
        retVal% = 0
      END IF
      i& = i& + 1
    WEND
    IF retVal% THEN
      _jsPos& = _jsPos& + litLen&
    END IF
  END IF

  _JsMatchLit = retVal%
END SUB

{* ============== Internal: String parsing ============== *}

SUB STRING _JsParseString$
  SHARED _jsBase&, _jsPos&, _jsLen&, _jsErr$
  STRING retVal$ SIZE 256
  SHORTINT ch%
  retVal$ = ""

  IF LEN(_jsErr$) > 0 THEN
    _JsParseString$ = retVal$
    EXIT SUB
  END IF

  ' Expect opening quote
  IF _jsPos& < _jsLen& THEN
    ch% = PEEK(_jsBase& + _jsPos&)
  ELSE
    ch% = -1
  END IF

  IF ch% <> 34 THEN
    _JsSetError("Expected string")
    _JsParseString$ = retVal$
    EXIT SUB
  END IF

  _jsPos& = _jsPos& + 1

  ' Scan string content
  IF _jsPos& < _jsLen& THEN
    ch% = PEEK(_jsBase& + _jsPos&)
  ELSE
    ch% = -1
  END IF

  WHILE ch% <> 34 AND ch% >= 0
    IF ch% = 92 THEN
      ' Backslash escape
      _jsPos& = _jsPos& + 1
      IF _jsPos& < _jsLen& THEN
        ch% = PEEK(_jsBase& + _jsPos&)
      ELSE
        ch% = -1
      END IF
      IF ch% = 34 THEN
        retVal$ = retVal$ + CHR$(34)
      ELSEIF ch% = 92 THEN
        retVal$ = retVal$ + CHR$(92)
      ELSEIF ch% = 47 THEN
        retVal$ = retVal$ + CHR$(47)
      ELSEIF ch% = 110 THEN
        retVal$ = retVal$ + CHR$(10)
      ELSEIF ch% = 114 THEN
        retVal$ = retVal$ + CHR$(13)
      ELSEIF ch% = 116 THEN
        retVal$ = retVal$ + CHR$(9)
      ELSEIF ch% = 98 THEN
        retVal$ = retVal$ + CHR$(8)
      ELSEIF ch% = 102 THEN
        retVal$ = retVal$ + CHR$(12)
      ELSE
        retVal$ = retVal$ + CHR$(ch%)
      END IF
    ELSE
      retVal$ = retVal$ + CHR$(ch%)
    END IF
    _jsPos& = _jsPos& + 1
    IF _jsPos& < _jsLen& THEN
      ch% = PEEK(_jsBase& + _jsPos&)
    ELSE
      ch% = -1
    END IF
  WEND

  IF ch% = 34 THEN
    _jsPos& = _jsPos& + 1
  ELSE
    _JsSetError("Unterminated string")
  END IF

  _JsParseString$ = retVal$
END SUB

{* ============== Internal: Number scanning ============== *}

SUB _JsScanNumber
  SHARED _jsBase&, _jsPos&, _jsLen&, _jsErr$
  SHARED _jsNumBuf$, _jsNumIsFloat%, _jsNumInt&
  SHORTINT ch%, hasDigit%, isNeg%
  LONGINT i&

  IF LEN(_jsErr$) > 0 THEN EXIT SUB

  _jsNumBuf$ = ""
  _jsNumIsFloat% = 0
  _jsNumInt& = 0
  hasDigit% = 0

  IF _jsPos& < _jsLen& THEN
    ch% = PEEK(_jsBase& + _jsPos&)
  ELSE
    ch% = -1
  END IF

  ' Optional leading minus
  IF ch% = 45 THEN
    _jsNumBuf$ = "-"
    _jsPos& = _jsPos& + 1
    IF _jsPos& < _jsLen& THEN
      ch% = PEEK(_jsBase& + _jsPos&)
    ELSE
      ch% = -1
    END IF
  END IF

  ' Digits before decimal
  WHILE ch% >= 48 AND ch% <= 57
    _jsNumBuf$ = _jsNumBuf$ + CHR$(ch%)
    hasDigit% = -1
    _jsPos& = _jsPos& + 1
    IF _jsPos& < _jsLen& THEN
      ch% = PEEK(_jsBase& + _jsPos&)
    ELSE
      ch% = -1
    END IF
  WEND

  ' Optional decimal point + digits
  IF ch% = 46 THEN
    _jsNumIsFloat% = -1
    _jsNumBuf$ = _jsNumBuf$ + CHR$(46)
    _jsPos& = _jsPos& + 1
    IF _jsPos& < _jsLen& THEN
      ch% = PEEK(_jsBase& + _jsPos&)
    ELSE
      ch% = -1
    END IF
    WHILE ch% >= 48 AND ch% <= 57
      _jsNumBuf$ = _jsNumBuf$ + CHR$(ch%)
      hasDigit% = -1
      _jsPos& = _jsPos& + 1
      IF _jsPos& < _jsLen& THEN
        ch% = PEEK(_jsBase& + _jsPos&)
      ELSE
        ch% = -1
      END IF
    WEND
  END IF

  ' Optional exponent
  IF ch% = 101 OR ch% = 69 THEN
    _jsNumIsFloat% = -1
    _jsNumBuf$ = _jsNumBuf$ + CHR$(ch%)
    _jsPos& = _jsPos& + 1
    IF _jsPos& < _jsLen& THEN
      ch% = PEEK(_jsBase& + _jsPos&)
    ELSE
      ch% = -1
    END IF
    IF ch% = 43 OR ch% = 45 THEN
      _jsNumBuf$ = _jsNumBuf$ + CHR$(ch%)
      _jsPos& = _jsPos& + 1
      IF _jsPos& < _jsLen& THEN
        ch% = PEEK(_jsBase& + _jsPos&)
      ELSE
        ch% = -1
      END IF
    END IF
    WHILE ch% >= 48 AND ch% <= 57
      _jsNumBuf$ = _jsNumBuf$ + CHR$(ch%)
      _jsPos& = _jsPos& + 1
      IF _jsPos& < _jsLen& THEN
        ch% = PEEK(_jsBase& + _jsPos&)
      ELSE
        ch% = -1
      END IF
    WEND
  END IF

  IF NOT hasDigit% THEN
    _JsSetError("Invalid number")
    EXIT SUB
  END IF

  ' Parse integer value for non-float case
  IF NOT _jsNumIsFloat% THEN
    _jsNumInt& = 0
    isNeg% = 0
    i& = 1
    IF LEFT$(_jsNumBuf$, 1) = "-" THEN
      isNeg% = -1
      i& = 2
    END IF
    WHILE i& <= LEN(_jsNumBuf$)
      _jsNumInt& = _jsNumInt& * 10 + (ASC(MID$(_jsNumBuf$, i&, 1)) - 48)
      i& = i& + 1
    WEND
    IF isNeg% THEN _jsNumInt& = -_jsNumInt&
  END IF
END SUB

{* ============== Internal: Recursive container parser ============== *}

SUB LONGINT _JsParseContainer
  SHARED _jsBase&, _jsPos&, _jsLen&, _jsErr$
  SHARED _jsHmDesc&, _jsDaDesc&, _jsDepth%
  SHARED _jsNumBuf$, _jsNumIsFloat%, _jsNumInt&
  SHARED _jsKeyStk$
  LONGINT retVal&, childAddr&
  SHORTINT ch%, done%
  STRING sVal$ SIZE 256
  DECLARE CLASS Hashmap hm
  DECLARE CLASS DynArray da

  retVal& = 0

  IF LEN(_jsErr$) > 0 THEN
    _JsParseContainer = 0
    EXIT SUB
  END IF

  _jsDepth% = _jsDepth% + 1
  IF _jsDepth% > JS_MAX_DEPTH THEN
    _JsSetError("Max nesting depth exceeded")
    _jsDepth% = _jsDepth% - 1
    _JsParseContainer = 0
    EXIT SUB
  END IF

  ' Peek at opening character
  IF _jsPos& < _jsLen& THEN
    ch% = PEEK(_jsBase& + _jsPos&)
  ELSE
    ch% = -1
  END IF

  IF ch% = 123 THEN
    {* ===== OBJECT ===== *}

    retVal& = ALLOC(_JS_HM_SIZE)
    IF retVal& = 0 THEN
      _JsSetError("Out of memory")
      _jsDepth% = _jsDepth% - 1
      _JsParseContainer = 0
      EXIT SUB
    END IF
    POKEL retVal&, _jsHmDesc&
    hm = retVal&
    HmMake(hm, HM_MEDIUM)

    _jsPos& = _jsPos& + 1
    _JsSkipWs

    IF _jsPos& < _jsLen& THEN
      ch% = PEEK(_jsBase& + _jsPos&)
    ELSE
      ch% = -1
    END IF

    IF ch% <> 125 THEN
      done% = 0
      WHILE NOT done% AND LEN(_jsErr$) = 0
        _JsSkipWs
        _jsKeyStk$(_jsDepth%) = _JsParseString$
        IF LEN(_jsErr$) > 0 THEN
          done% = -1
        ELSE
          _JsSkipWs
          _JsExpect(58)
          _JsSkipWs

          ' Dispatch object value
          IF _jsPos& < _jsLen& THEN
            ch% = PEEK(_jsBase& + _jsPos&)
          ELSE
            ch% = -1
          END IF

          IF ch% = 34 THEN
            sVal$ = _JsParseString$
            IF LEN(_jsErr$) = 0 THEN
              HmPut$(hm, _jsKeyStk$(_jsDepth%), sVal$)
            END IF
          ELSEIF ch% = 123 OR ch% = 91 THEN
            childAddr& = _JsParseContainer
            hm = retVal&
            IF LEN(_jsErr$) = 0 THEN
              HmPutRef(hm, _jsKeyStk$(_jsDepth%), childAddr&)
            END IF
          ELSEIF ch% = 116 THEN
            IF _JsMatchLit("true") THEN
              HmPutBool(hm, _jsKeyStk$(_jsDepth%), -1)
            ELSE
              _JsSetError("Invalid literal")
            END IF
          ELSEIF ch% = 102 THEN
            IF _JsMatchLit("false") THEN
              HmPutBool(hm, _jsKeyStk$(_jsDepth%), 0)
            ELSE
              _JsSetError("Invalid literal")
            END IF
          ELSEIF ch% = 110 THEN
            IF _JsMatchLit("null") THEN
              HmPutNull(hm, _jsKeyStk$(_jsDepth%))
            ELSE
              _JsSetError("Invalid literal")
            END IF
          ELSEIF ch% = 45 OR (ch% >= 48 AND ch% <= 57) THEN
            _JsScanNumber
            IF LEN(_jsErr$) = 0 THEN
              IF _jsNumIsFloat% THEN
                HmPut!(hm, _jsKeyStk$(_jsDepth%), VAL(_jsNumBuf$))
              ELSE
                HmPut&(hm, _jsKeyStk$(_jsDepth%), _jsNumInt&)
              END IF
            END IF
          ELSE
            _JsSetError("Unexpected character")
          END IF

          _JsSkipWs
          IF _jsPos& < _jsLen& THEN
            ch% = PEEK(_jsBase& + _jsPos&)
          ELSE
            ch% = -1
          END IF
          IF ch% = 44 THEN
            _jsPos& = _jsPos& + 1
          ELSE
            done% = -1
          END IF
        END IF
      WEND
    END IF

    IF LEN(_jsErr$) = 0 THEN
      _JsExpect(125)
    END IF

    IF LEN(_jsErr$) > 0 THEN
      HmFree(hm)
      FREE retVal&
      retVal& = 0
    END IF

  ELSEIF ch% = 91 THEN
    {* ===== ARRAY ===== *}

    retVal& = ALLOC(_JS_DA_SIZE)
    IF retVal& = 0 THEN
      _JsSetError("Out of memory")
      _jsDepth% = _jsDepth% - 1
      _JsParseContainer = 0
      EXIT SUB
    END IF
    POKEL retVal&, _jsDaDesc&
    da = retVal&
    DaMake(da, DA_MEDIUM)

    _jsPos& = _jsPos& + 1
    _JsSkipWs

    IF _jsPos& < _jsLen& THEN
      ch% = PEEK(_jsBase& + _jsPos&)
    ELSE
      ch% = -1
    END IF

    IF ch% <> 93 THEN
      done% = 0
      WHILE NOT done% AND LEN(_jsErr$) = 0
        _JsSkipWs

        ' Dispatch array value
        IF _jsPos& < _jsLen& THEN
          ch% = PEEK(_jsBase& + _jsPos&)
        ELSE
          ch% = -1
        END IF

        IF ch% = 34 THEN
          sVal$ = _JsParseString$
          IF LEN(_jsErr$) = 0 THEN
            DaAppend$(da, sVal$)
          END IF
        ELSEIF ch% = 123 OR ch% = 91 THEN
          childAddr& = _JsParseContainer
          da = retVal&
          IF LEN(_jsErr$) = 0 THEN
            DaAppendRef(da, childAddr&)
          END IF
        ELSEIF ch% = 116 THEN
          IF _JsMatchLit("true") THEN
            DaAppendBool(da, -1)
          ELSE
            _JsSetError("Invalid literal")
          END IF
        ELSEIF ch% = 102 THEN
          IF _JsMatchLit("false") THEN
            DaAppendBool(da, 0)
          ELSE
            _JsSetError("Invalid literal")
          END IF
        ELSEIF ch% = 110 THEN
          IF _JsMatchLit("null") THEN
            DaAppendNull(da)
          ELSE
            _JsSetError("Invalid literal")
          END IF
        ELSEIF ch% = 45 OR (ch% >= 48 AND ch% <= 57) THEN
          _JsScanNumber
          IF LEN(_jsErr$) = 0 THEN
            IF _jsNumIsFloat% THEN
              DaAppend!(da, VAL(_jsNumBuf$))
            ELSE
              DaAppend&(da, _jsNumInt&)
            END IF
          END IF
        ELSE
          _JsSetError("Unexpected character")
        END IF

        _JsSkipWs
        IF _jsPos& < _jsLen& THEN
          ch% = PEEK(_jsBase& + _jsPos&)
        ELSE
          ch% = -1
        END IF
        IF ch% = 44 THEN
          _jsPos& = _jsPos& + 1
        ELSE
          done% = -1
        END IF
      WEND
    END IF

    IF LEN(_jsErr$) = 0 THEN
      _JsExpect(93)
    END IF

    IF LEN(_jsErr$) > 0 THEN
      DaFree(da)
      FREE retVal&
      retVal& = 0
    END IF

  ELSE
    _JsSetError("Expected { or [")
  END IF

  _jsDepth% = _jsDepth% - 1
  _JsParseContainer = retVal&
END SUB

{* ============== Public API ============== *}

SUB LONGINT JsParse(src$) EXTERNAL
  SHARED _jsBase&, _jsPos&, _jsLen&, _jsDepth%, _jsRootType%, _jsErr$
  LONGINT retVal&
  SHORTINT ch%
  retVal& = 0

  _JsInitDesc

  _jsBase& = SADD(src$)
  _jsPos& = 0
  _jsLen& = LEN(src$)
  _jsDepth% = 0
  _jsErr$ = ""

  _JsSkipWs
  ch% = _JsCh%

  IF ch% = 123 THEN
    _jsRootType% = JsObject
  ELSEIF ch% = 91 THEN
    _jsRootType% = JsArray
  ELSE
    _JsSetError("Expected { or [")
    JsParse = 0
    EXIT SUB
  END IF

  retVal& = _JsParseContainer

  JsParse = retVal&
END SUB

SUB LONGINT JsParseFile(SHORTINT ch%) EXTERNAL
  SHARED _jsBase&, _jsPos&, _jsLen&, _jsDepth%, _jsRootType%, _jsErr$
  STRING buf$ SIZE 8192
  STRING ln$ SIZE 1024
  LONGINT retVal&
  SHORTINT c%

  _JsInitDesc

  buf$ = ""
  _jsErr$ = ""
  retVal& = 0

  WHILE NOT EOF(ch%)
    LINE INPUT #ch%, ln$
    IF LEN(buf$) = 0 THEN
      buf$ = ln$
    ELSEIF LEN(buf$) + LEN(ln$) + 1 <= JS_MAX_INPUT THEN
      buf$ = buf$ + " " + ln$
    ELSE
      _JsSetError("Input too large")
    END IF
  WEND

  IF LEN(_jsErr$) > 0 THEN
    JsParseFile = 0
    EXIT SUB
  END IF

  IF LEN(buf$) = 0 THEN
    _JsSetError("Expected { or [")
    JsParseFile = 0
    EXIT SUB
  END IF

  _jsBase& = SADD(buf$)
  _jsPos& = 0
  _jsLen& = LEN(buf$)
  _jsDepth% = 0

  _JsSkipWs
  c% = _JsCh%

  IF c% = 123 THEN
    _jsRootType% = JsObject
  ELSEIF c% = 91 THEN
    _jsRootType% = JsArray
  ELSE
    _JsSetError("Expected { or [")
    JsParseFile = 0
    EXIT SUB
  END IF

  retVal& = _JsParseContainer
  JsParseFile = retVal&
END SUB

{* ============== Generator: String escaping ============== *}

SUB _JsWriteStr(s$, SHORTINT ch%)
  STRING esc$ SIZE 600
  LONGINT i&
  SHORTINT c%
  esc$ = CHR$(34)
  FOR i& = 1 TO LEN(s$)
    c% = ASC(MID$(s$, i&, 1))
    IF c% = 34 THEN
      esc$ = esc$ + "\" + CHR$(34)
    ELSEIF c% = 92 THEN
      esc$ = esc$ + "\\"
    ELSEIF c% = 10 THEN
      esc$ = esc$ + "\n"
    ELSEIF c% = 13 THEN
      esc$ = esc$ + "\r"
    ELSEIF c% = 9 THEN
      esc$ = esc$ + "\t"
    ELSEIF c% = 8 THEN
      esc$ = esc$ + "\b"
    ELSEIF c% = 12 THEN
      esc$ = esc$ + "\f"
    ELSEIF c% < 32 THEN
      ' skip other control chars
    ELSE
      esc$ = esc$ + CHR$(c%)
    END IF
  NEXT
  esc$ = esc$ + CHR$(34)
  PRINT #ch%, esc$;
END SUB

{* ============== Generator: Recursive node writer ============== *}
' lvl% = -1: compact mode (no whitespace)
' lvl% >= 0: formatted mode (2-space indent at that level)

SUB _JsWriteNode(ADDRESS addr&, SHORTINT ch%, SHORTINT lvl%)
  LONGINT savedAddr&, i&, cnt&, nextLvl&
  SHORTINT first%, typ%, fmt%, pad%
  SINGLE fVal!
  DECLARE CLASS Hashmap tcItem

  IF addr& = 0 THEN EXIT SUB

  savedAddr& = addr&
  tcItem = addr&
  fmt% = (lvl% >= 0)
  IF fmt% THEN nextLvl& = lvl% + 1 ELSE nextLvl& = -1

  TYPECASE tcItem
    CASE Hashmap
      PRINT #ch%, "{";
      HmIterReset(tcItem)
      first% = -1
      WHILE HmIterNext(tcItem)
        IF NOT first% THEN PRINT #ch%, ",";
        IF fmt% THEN
          PRINT #ch%, CHR$(10);
          pad% = (lvl% + 1) * 2
          IF pad% > 0 THEN PRINT #ch%, SPACE$(pad%);
        END IF
        first% = 0
        _JsWriteStr(HmIterKey$(tcItem), ch%)
        IF fmt% THEN PRINT #ch%, ": "; ELSE PRINT #ch%, ":";

        typ% = HmIterType(tcItem)
        IF typ% = HmTypeStr THEN
          _JsWriteStr(HmIterVal$(tcItem), ch%)
        ELSEIF typ% = HmTypeLng THEN
          PRINT #ch%, LTRIM$(STR$(HmIterVal&(tcItem)));
        ELSEIF typ% = HmTypeSng THEN
          fVal! = HmIterVal!(tcItem)
          PRINT #ch%, LTRIM$(STR$(fVal!));
        ELSEIF typ% = HmTypeBool THEN
          IF HmIterVal&(tcItem) THEN
            PRINT #ch%, "true";
          ELSE
            PRINT #ch%, "false";
          END IF
        ELSEIF typ% = HmTypeNull THEN
          PRINT #ch%, "null";
        ELSEIF typ% = HmTypeRef THEN
          _JsWriteNode(HmIterVal&(tcItem), ch%, nextLvl&)
          tcItem = savedAddr&
        END IF
      WEND
      IF fmt% AND NOT first% THEN
        PRINT #ch%, CHR$(10);
        pad% = lvl% * 2
        IF pad% > 0 THEN PRINT #ch%, SPACE$(pad%);
      END IF
      PRINT #ch%, "}";

    CASE DynArray
      cnt& = DaCount(tcItem)
      PRINT #ch%, "[";
      FOR i& = 0 TO cnt& - 1
        IF i& > 0 THEN PRINT #ch%, ",";
        IF fmt% THEN
          PRINT #ch%, CHR$(10);
          pad% = (lvl% + 1) * 2
          IF pad% > 0 THEN PRINT #ch%, SPACE$(pad%);
        END IF

        typ% = DaType(tcItem, i&)
        IF typ% = DaTypeStr THEN
          _JsWriteStr(DaGet$(tcItem, i&), ch%)
        ELSEIF typ% = DaTypeLng THEN
          PRINT #ch%, LTRIM$(STR$(DaGet&(tcItem, i&)));
        ELSEIF typ% = DaTypeSng THEN
          fVal! = DaGet!(tcItem, i&)
          PRINT #ch%, LTRIM$(STR$(fVal!));
        ELSEIF typ% = DaTypeBool THEN
          IF DaGet&(tcItem, i&) THEN
            PRINT #ch%, "true";
          ELSE
            PRINT #ch%, "false";
          END IF
        ELSEIF typ% = DaTypeNull THEN
          PRINT #ch%, "null";
        ELSEIF typ% = DaTypeRef THEN
          _JsWriteNode(DaGet&(tcItem, i&), ch%, nextLvl&)
          tcItem = savedAddr&
        END IF
      NEXT
      IF fmt% AND cnt& > 0 THEN
        PRINT #ch%, CHR$(10);
        pad% = lvl% * 2
        IF pad% > 0 THEN PRINT #ch%, SPACE$(pad%);
      END IF
      PRINT #ch%, "]";
  END TYPECASE
END SUB

{* ============== Public API: Generator ============== *}

SUB JsWrite(ADDRESS root&, SHORTINT ch%) EXTERNAL
  IF root& = 0 THEN EXIT SUB
  _JsWriteNode(root&, ch%, -1)
END SUB

SUB JsWriteFmt(ADDRESS root&, SHORTINT ch%) EXTERNAL
  IF root& = 0 THEN EXIT SUB
  _JsWriteNode(root&, ch%, 0)
END SUB

SUB STRING JsToStr$(ADDRESS root&) EXTERNAL
  STRING retVal$ SIZE 4096
  retVal$ = ""
  IF root& = 0 THEN
    JsToStr$ = retVal$
    EXIT SUB
  END IF

  OPEN "O", #9, "T:js_tmp"
  JsWrite(root&, 9)
  CLOSE #9

  OPEN "I", #9, "T:js_tmp"
  LINE INPUT #9, retVal$
  CLOSE #9

  IF LEN(retVal$) > 4000 THEN
    retVal$ = ""
  END IF

  JsToStr$ = retVal$
END SUB

{* ============== Public API: Info ============== *}

SUB STRING JsError$ EXTERNAL
  SHARED _jsErr$
  JsError$ = _jsErr$
END SUB

SUB SHORTINT JsRootType EXTERNAL
  SHARED _jsRootType%
  JsRootType = _jsRootType%
END SUB

{* ============== Public API: Cleanup ============== *}

SUB JsFree(ADDRESS root&) EXTERNAL
  LONGINT savedAddr&, i&, cnt&, childAddr&
  DECLARE CLASS Hashmap tcItem

  IF root& = 0 THEN EXIT SUB

  savedAddr& = root&
  tcItem = root&

  TYPECASE tcItem
    CASE Hashmap
      HmIterReset(tcItem)
      WHILE HmIterNext(tcItem)
        IF HmIterType(tcItem) = HmTypeRef THEN
          childAddr& = HmIterVal&(tcItem)
          JsFree(childAddr&)
          tcItem = savedAddr&
        END IF
      WEND
      HmFree(tcItem)
      FREE root&

    CASE DynArray
      cnt& = DaCount(tcItem)
      FOR i& = 0 TO cnt& - 1
        IF DaType(tcItem, i&) = DaTypeRef THEN
          childAddr& = DaGet&(tcItem, i&)
          JsFree(childAddr&)
          tcItem = savedAddr&
        END IF
      NEXT
      DaFree(tcItem)
      FREE root&
  END TYPECASE
END SUB

{* ============== Public API: Convenience ============== *}

SUB JsMakeObj(Hashmap hm, LONGINT cap&) EXTERNAL
  HmMake(hm, cap&)
END SUB

SUB JsMakeArr(DynArray da, LONGINT cap&) EXTERNAL
  DaMake(da, cap&)
END SUB
