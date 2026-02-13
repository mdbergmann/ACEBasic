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
