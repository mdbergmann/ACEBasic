{* DP - Double-Precision Math Submodule for ACE BASIC *}
{* Wraps mathieeedoubbas.library and mathieeedoubtrans.library *}
{* Uses inline ASSEM blocks (same pattern as httpclient Phase 6) *}

{ ============== Module State ============== }

LONGINT _dpBasBase       ' mathieeedoubbas.library
LONGINT _dpTransBase     ' mathieeedoubtrans.library
LONGINT _dpMtBase        ' mathtrans.library (for FFP<->IEEE SP)
LONGINT _dpInited        ' 0=not init, -1=init

' ASSEM register transfer variables
LONGINT _asmD0
LONGINT _asmD1
LONGINT _asmD2
LONGINT _asmD3
LONGINT _asmA0
LONGINT _asmA1
LONGINT _asmA2
LONGINT _asmA6

{ ============== Internal: exec library calls ============== }

SUB LONGINT _ExecOpenLib(ADDRESS libName, LONGINT ver)
  SHARED _asmA1, _asmD0

  _asmA1 = libName
  _asmD0 = ver

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  _modv__ASMD0,d0
    move.l  4,a6
    jsr     -552(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _ExecOpenLib = _asmD0
END SUB

SUB _ExecCloseLib(ADDRESS libBase)
  SHARED _asmA1

  _asmA1 = libBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  4,a6
    jsr     -414(a6)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

{ ============== Lifecycle ============== }

SUB LONGINT DpOpen EXTERNAL
  SHARED _dpBasBase, _dpTransBase, _dpMtBase, _dpInited

  IF _dpInited = -1 THEN
    DpOpen = -1
    EXIT SUB
  END IF

  ' Open mathieeedoubbas.library
  _dpBasBase = _ExecOpenLib(SADD("mathieeedoubbas.library" + CHR$(0)), 34&)
  IF _dpBasBase = 0 THEN
    DpOpen = 0
    EXIT SUB
  END IF

  ' Open mathieeedoubtrans.library
  _dpTransBase = _ExecOpenLib(SADD("mathieeedoubtrans.library" + CHR$(0)), 34&)
  IF _dpTransBase = 0 THEN
    _ExecCloseLib(_dpBasBase)
    _dpBasBase = 0
    DpOpen = 0
    EXIT SUB
  END IF

  ' Open mathtrans.library (for SINGLE conversion)
  _dpMtBase = _ExecOpenLib(SADD("mathtrans.library" + CHR$(0)), 34&)
  IF _dpMtBase = 0 THEN
    _ExecCloseLib(_dpTransBase)
    _dpTransBase = 0
    _ExecCloseLib(_dpBasBase)
    _dpBasBase = 0
    DpOpen = 0
    EXIT SUB
  END IF

  _dpInited = -1
  DpOpen = -1
END SUB

SUB DpClose EXTERNAL
  SHARED _dpBasBase, _dpTransBase, _dpMtBase, _dpInited

  IF _dpInited = 0 THEN EXIT SUB

  IF _dpMtBase <> 0 THEN
    _ExecCloseLib(_dpMtBase)
    _dpMtBase = 0
  END IF

  IF _dpTransBase <> 0 THEN
    _ExecCloseLib(_dpTransBase)
    _dpTransBase = 0
  END IF

  IF _dpBasBase <> 0 THEN
    _ExecCloseLib(_dpBasBase)
    _dpBasBase = 0
  END IF

  _dpInited = 0
END SUB

{ ============== Allocation ============== }

SUB ADDRESS DpNew EXTERNAL
  DpNew = ALLOC(8)
END SUB

{ ============== Conversion ============== }

SUB DpFromLong(ADDRESS dr, LONGINT n) EXTERNAL
  SHARED _asmA0, _asmD0, _asmA6, _dpBasBase
  ' IEEEDPFlt: d0 (long) -> d0:d1 (double)
  _asmA0 = dr
  _asmD0 = n
  _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d1/a0/a6,-(sp)
    move.l  _modv__ASMD0,d0
    move.l  _modv__ASMA6,a6
    jsr     -36(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0/a6
  END ASSEM
END SUB

SUB LONGINT DpToLong(ADDRESS d) EXTERNAL
  SHARED _asmA1, _asmD0, _asmA6, _dpBasBase
  ' IEEEDPFix: d0:d1 (double) -> d0 (long)
  _asmA1 = d
  _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d1/a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -30(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a1/a6
  END ASSEM

  DpToLong = _asmD0
END SUB

{ ============== Arithmetic ============== }

SUB DpAdd(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA2, _asmA6, _dpBasBase
  ' IEEEDPAdd: d0:d1 + d2:d3 -> d0:d1
  _asmA0 = dr : _asmA1 = d1 : _asmA2 = d2 : _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d3/a0-a2/a6,-(sp)
    move.l  _modv__ASMA2,a2
    move.l  (a2)+,d2
    move.l  (a2),d3
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -66(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d3/a0-a2/a6
  END ASSEM
END SUB

SUB DpSub(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA2, _asmA6, _dpBasBase
  ' IEEEDPSub: d0:d1 - d2:d3 -> d0:d1
  _asmA0 = dr : _asmA1 = d1 : _asmA2 = d2 : _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d3/a0-a2/a6,-(sp)
    move.l  _modv__ASMA2,a2
    move.l  (a2)+,d2
    move.l  (a2),d3
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -72(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d3/a0-a2/a6
  END ASSEM
END SUB

SUB DpMul(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA2, _asmA6, _dpBasBase
  ' IEEEDPMul: d0:d1 * d2:d3 -> d0:d1
  _asmA0 = dr : _asmA1 = d1 : _asmA2 = d2 : _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d3/a0-a2/a6,-(sp)
    move.l  _modv__ASMA2,a2
    move.l  (a2)+,d2
    move.l  (a2),d3
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -78(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d3/a0-a2/a6
  END ASSEM
END SUB

SUB DpDiv(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA2, _asmA6, _dpBasBase
  ' IEEEDPDiv: d0:d1 / d2:d3 -> d0:d1
  _asmA0 = dr : _asmA1 = d1 : _asmA2 = d2 : _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d3/a0-a2/a6,-(sp)
    move.l  _modv__ASMA2,a2
    move.l  (a2)+,d2
    move.l  (a2),d3
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -84(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d3/a0-a2/a6
  END ASSEM
END SUB

{ ============== Comparison ============== }

SUB LONGINT DpCmp(ADDRESS d1, ADDRESS d2) EXTERNAL
  SHARED _asmA1, _asmA2, _asmD0, _asmA6, _dpBasBase
  ' IEEEDPCmp: d0:d1 vs d2:d3 -> d0 (+1/0/-1)
  _asmA1 = d1 : _asmA2 = d2 : _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d3/a1-a2/a6,-(sp)
    move.l  _modv__ASMA2,a2
    move.l  (a2)+,d2
    move.l  (a2),d3
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -42(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d3/a1-a2/a6
  END ASSEM

  DpCmp = _asmD0
END SUB

{ ============== Unary Operations ============== }

SUB DpAbs(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpBasBase
  ' IEEEDPAbs: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -54(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpNeg(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpBasBase
  ' IEEEDPNeg: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -60(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpCeil(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpBasBase
  ' IEEEDPCeil: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -96(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpFloor(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpBasBase
  ' IEEEDPFloor: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -90(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

{ ============== SINGLE Conversion ============== }

SUB DpFromSingle(ADDRESS dr, SINGLE s) EXTERNAL
  SHARED _asmA0, _asmD0, _asmA6, _dpMtBase, _dpTransBase
  ' FFP -> IEEE SP (mathtrans SPTieee -102) -> IEEE DP (doubtrans IEEEDPFieee -108)
  _asmA0 = dr
  _asmD0 = PEEKL(@s)
  _asmA6 = _dpMtBase

  ASSEM
    movem.l d0-d1/a0/a6,-(sp)
    move.l  _modv__ASMD0,d0
    move.l  _modv__ASMA6,a6
    jsr     -102(a6)
    move.l  _modv__DPTRANSBASE,a6
    jsr     -108(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0/a6
  END ASSEM
END SUB

SUB SINGLE DpToSingle(ADDRESS d) EXTERNAL
  SHARED _asmA1, _asmD0, _asmA6, _dpMtBase, _dpTransBase
  SINGLE retVal
  ' IEEE DP -> IEEE SP (doubtrans IEEEDPTieee -102) -> FFP (mathtrans SPFieee -108)
  _asmA1 = d
  _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -102(a6)
    move.l  _modv__DPMTBASE,a6
    jsr     -108(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a1/a6
  END ASSEM

  POKEL @retVal, _asmD0
  DpToSingle = retVal
END SUB

{ ============== Trigonometric (radians) ============== }

SUB DpSin(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPSin: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -36(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpCos(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPCos: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -42(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpTan(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPTan: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -48(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpAsin(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPAsin: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -114(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpAcos(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPAcos: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -120(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpAtan(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPAtan: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -30(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpSinCos(ADDRESS drSin, ADDRESS drCos, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA2, _asmA6, _dpTransBase
  ' IEEEDPSincos: d0:d1 (angle), a0 (ptr to cos result) -> d0:d1 (sin)
  _asmA0 = drSin : _asmA1 = drCos : _asmA2 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a2/a6,-(sp)
    move.l  _modv__ASMA2,a2
    move.l  (a2)+,d0
    move.l  (a2),d1
    move.l  _modv__ASMA1,a0
    move.l  _modv__ASMA6,a6
    jsr     -54(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a2/a6
  END ASSEM
END SUB

{ ============== Hyperbolic ============== }

SUB DpSinh(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPSinh: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -60(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpCosh(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPCosh: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -66(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpTanh(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPTanh: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -72(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

{ ============== Exponential / Logarithmic ============== }

SUB DpExp(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPExp: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -78(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpLog(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPLog: d0:d1 -> d0:d1 (natural log)
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -84(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpLog10(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPLog10: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -126(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpSqrt(ADDRESS dr, ADDRESS d) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA6, _dpTransBase
  ' IEEEDPSqrt: d0:d1 -> d0:d1
  _asmA0 = dr : _asmA1 = d : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -96(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB DpPow(ADDRESS dr, ADDRESS d1, ADDRESS d2) EXTERNAL
  SHARED _asmA0, _asmA1, _asmA2, _asmA6, _dpTransBase
  ' IEEEDPPow: d0:d1 ^ d2:d3 -> d0:d1
  _asmA0 = dr : _asmA1 = d1 : _asmA2 = d2 : _asmA6 = _dpTransBase

  ASSEM
    movem.l d0-d3/a0-a2/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA2,a2
    move.l  (a2)+,d2
    move.l  (a2),d3
    move.l  _modv__ASMA6,a6
    jsr     -90(a6)
    move.l  _modv__ASMA0,a0
    move.l  d0,(a0)+
    move.l  d1,(a0)
    movem.l (sp)+,d0-d3/a0-a2/a6
  END ASSEM
END SUB

{ ============== Internal: DpTst ============== }

SUB LONGINT _DpTst(ADDRESS d)
  SHARED _asmA1, _asmD0, _asmA6, _dpBasBase
  ' IEEEDPTst: d0:d1 -> d0 (+1/0/-1)
  _asmA1 = d : _asmA6 = _dpBasBase

  ASSEM
    movem.l d0-d1/a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  (a1)+,d0
    move.l  (a1),d1
    move.l  _modv__ASMA6,a6
    jsr     -48(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a1/a6
  END ASSEM

  _DpTst = _asmD0
END SUB

{ ============== Internal: DpCopy ============== }

SUB _DpCopy(ADDRESS dst, ADDRESS src)
  POKEL dst, PEEKL(src)
  POKEL dst + 4, PEEKL(src + 4)
END SUB

{ ============== String -> Double ============== }

SUB DpFromStr(ADDRESS dr, STRING s$) EXTERNAL
  LONGINT cc, sLen, numSign, ch
  LONGINT n0, n1, idx, periods, plcCnt, plcs, i
  SHORTINT hasDot
  LONGINT exVal, exSign
  ADDRESS ta, tb, tc, td

  ' Zero result
  POKEL dr, 0 : POKEL dr + 4, 0

  sLen = LEN(s$)
  IF sLen = 0 THEN EXIT SUB

  ' Allocate temp doubles
  ta = ALLOC(8) : tb = ALLOC(8) : tc = ALLOC(8) : td = ALLOC(8)

  cc = 1
  ' Skip leading whitespace
  ch = ASC(MID$(s$, cc, 1))
  WHILE ch <= 32 AND cc <= sLen
    cc = cc + 1
    IF cc <= sLen THEN ch = ASC(MID$(s$, cc, 1))
  WEND
  IF cc > sLen THEN EXIT SUB

  ' Sign
  numSign = 1
  IF ch = 45 THEN
    numSign = -1
    cc = cc + 1
  ELSEIF ch = 43 THEN
    cc = cc + 1
  END IF
  IF cc > sLen THEN EXIT SUB
  ch = ASC(MID$(s$, cc, 1))

  ' Must start with digit or dot
  IF (ch < 48 OR ch > 57) AND ch <> 46 THEN EXIT SUB

  n0 = 0 : n1 = 0 : idx = 0 : hasDot = 0 : periods = 0 : plcCnt = 0

  ' Check if first char is '.'
  IF ch = 46 THEN
    hasDot = 1 : plcCnt = 0 : idx = 1 : periods = 1
  END IF

  ' First digit (if not dot)
  IF hasDot = 0 THEN n0 = ch - 48

  ' Parse remaining digits and dot
  cc = cc + 1
  WHILE cc <= sLen AND periods <= 1
    ch = ASC(MID$(s$, cc, 1))
    IF ch >= 48 AND ch <= 57 THEN
      IF idx = 0 THEN
        n0 = 10 * n0 + (ch - 48)
      ELSE
        n1 = 10 * n1 + (ch - 48)
      END IF
      IF hasDot = 1 THEN plcCnt = plcCnt + 1
    ELSEIF ch = 46 THEN
      periods = periods + 1
      IF hasDot = 0 AND periods = 1 THEN
        hasDot = 1 : plcCnt = 0 : idx = 1
      END IF
    ELSE
      GOTO _dfs_afterDigits
    END IF
    cc = cc + 1
  WEND

_dfs_afterDigits:
  ' Build the double value
  IF hasDot = 1 AND periods = 1 THEN
    ' Compute places = 10^plcCnt
    plcs = 1
    FOR i = 1 TO plcCnt
      plcs = plcs * 10
    NEXT i

    ' integer part
    DpFromLong(ta, n0)
    ' fractional part
    DpFromLong(tb, n1)
    DpFromLong(tc, plcs)
    DpDiv(td, tb, tc)
    ' Combined
    DpAdd(dr, ta, td)
  ELSE
    DpFromLong(dr, n0)
  END IF

  ' Exponent part?
  IF cc <= sLen THEN
    ch = ASC(MID$(s$, cc, 1))
    IF ch = 69 OR ch = 101 THEN
      exVal = 0 : exSign = 1
      cc = cc + 1
      IF cc <= sLen THEN
        ch = ASC(MID$(s$, cc, 1))
        IF ch = 43 THEN
          exSign = 1 : cc = cc + 1
        ELSEIF ch = 45 THEN
          exSign = -1 : cc = cc + 1
        END IF
      END IF

      ' Must have digit
      IF cc > sLen THEN
        POKEL dr, 0 : POKEL dr + 4, 0
        GOTO _dfs_sign
      END IF
      ch = ASC(MID$(s$, cc, 1))
      IF ch < 48 OR ch > 57 THEN
        POKEL dr, 0 : POKEL dr + 4, 0
        GOTO _dfs_sign
      END IF

      ' Get exponent digits
      WHILE cc <= sLen
        ch = ASC(MID$(s$, cc, 1))
        IF ch >= 48 AND ch <= 57 THEN
          exVal = 10 * exVal + (ch - 48)
          cc = cc + 1
        ELSE
          GOTO _dfs_afterExp
        END IF
      WEND

_dfs_afterExp:
      exVal = exVal * exSign

      IF exVal >= -308 AND exVal <= 307 THEN
        IF exVal <> 0 THEN
          DpFromLong(ta, 10)
          DpFromLong(tb, exVal)
          DpPow(tc, ta, tb)
          _DpCopy(td, dr)
          DpMul(dr, tc, td)
        END IF
      ELSE
        POKEL dr, 0 : POKEL dr + 4, 0
      END IF
    END IF
  END IF

_dfs_sign:
  ' Apply sign
  IF numSign = -1 THEN
    _DpCopy(ta, dr)
    DpNeg(dr, ta)
  END IF
END SUB

{ ============== Double -> String ============== }

SUB STRING DpToStr$(ADDRESS d) EXTERNAL
  ADDRESS ta, tb, tc, td, te
  LONGINT tst, cmpVal, ex, digit, i
  STRING retVal$ SIZE 64
  STRING digs$ SIZE 20

  tst = _DpTst(d)

  ' Zero?
  IF tst = 0 THEN
    DpToStr$ = "0"
    EXIT SUB
  END IF

  ta = ALLOC(8) : tb = ALLOC(8) : tc = ALLOC(8)
  td = ALLOC(8) : te = ALLOC(8)

  ' Work with absolute value, track sign
  retVal$ = ""
  IF tst < 0 THEN
    retVal$ = "-"
    DpNeg(ta, d)
  ELSE
    _DpCopy(ta, d)
  END IF

  ' ta = |value|
  ' Find exponent: ex = floor(log10(|value|))
  DpLog10(tb, ta)
  DpFloor(tc, tb)
  ex = DpToLong(tc)

  ' Normalize: ta = |value| / 10^ex -> mantissa in [1, 10)
  IF ex <> 0 THEN
    DpFromLong(tb, 10)
    DpFromLong(tc, ex)
    DpPow(td, tb, tc)
    _DpCopy(te, ta)
    DpDiv(ta, te, td)
  END IF

  ' Guard: if mantissa >= 10, adjust
  DpFromLong(tb, 10)
  cmpVal = DpCmp(ta, tb)
  IF cmpVal >= 0 THEN
    DpDiv(tc, ta, tb)
    _DpCopy(ta, tc)
    ex = ex + 1
  END IF

  ' Guard: if mantissa < 1, adjust
  DpFromLong(tb, 1)
  cmpVal = DpCmp(ta, tb)
  IF cmpVal < 0 THEN
    DpFromLong(tc, 10)
    _DpCopy(te, ta)
    DpMul(ta, te, tc)
    ex = ex - 1
  END IF

  ' Extract up to 15 significant digits
  digs$ = ""
  FOR i = 1 TO 15
    DpFloor(tb, ta)
    digit = DpToLong(tb)
    IF digit < 0 THEN digit = 0
    IF digit > 9 THEN digit = 9
    digs$ = digs$ + CHR$(48 + digit)
    ' Subtract digit, multiply by 10
    DpFromLong(tc, digit)
    DpSub(td, ta, tc)
    DpFromLong(tc, 10)
    DpMul(ta, td, tc)
  NEXT i

  ' Trim trailing zeros
  i = 15
  WHILE i > 1 AND MID$(digs$, i, 1) = "0"
    i = i - 1
  WEND
  digs$ = LEFT$(digs$, i)

  ' Format output
  IF ex >= 0 AND ex <= 15 THEN
    ' Fixed notation
    IF ex + 1 >= LEN(digs$) THEN
      ' All digits before decimal point, pad with zeros if needed
      retVal$ = retVal$ + digs$
      FOR i = 1 TO (ex + 1 - LEN(digs$))
        retVal$ = retVal$ + "0"
      NEXT i
    ELSE
      ' Insert decimal point
      retVal$ = retVal$ + LEFT$(digs$, ex + 1)
      retVal$ = retVal$ + "."
      retVal$ = retVal$ + MID$(digs$, ex + 2)
    END IF
  ELSEIF ex < 0 AND ex >= -4 THEN
    ' Small number: 0.000xxx
    retVal$ = retVal$ + "0."
    FOR i = 1 TO (-ex - 1)
      retVal$ = retVal$ + "0"
    NEXT i
    retVal$ = retVal$ + digs$
  ELSE
    ' Scientific notation
    IF LEN(digs$) = 1 THEN
      retVal$ = retVal$ + digs$
    ELSE
      retVal$ = retVal$ + LEFT$(digs$, 1) + "." + MID$(digs$, 2)
    END IF
    retVal$ = retVal$ + "e"
    IF ex >= 0 THEN
      retVal$ = retVal$ + "+"
    ELSE
      retVal$ = retVal$ + "-"
      ex = -ex
    END IF
    retVal$ = retVal$ + LTRIM$(STR$(ex))
  END IF

  DpToStr$ = retVal$
END SUB
