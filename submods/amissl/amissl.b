{* AmiSSL - AmiSSL library wrapper submodule for ACE BASIC *}
{* Provides SSL context management and SSL I/O via AmiSSL *}

{ ============== Constants ============== }

CONST SSL_SUCCESS     = 0
CONST SSL_ERR_INIT    = -1
CONST SSL_ERR_CONNECT = -2
CONST SSL_ERR_NO_LIB  = -3

{ ============== Module Data ============== }

' SSL global state
LONGINT _sslInited
LONGINT _masterBase
LONGINT _amisslBase
LONGINT _sslCtx
LONGINT _bsdBase

' ASSEM temporaries (module-level, BSS names: _modv__ASM*)
LONGINT _asmA0
LONGINT _asmA1
LONGINT _asmA6
LONGINT _asmD0
LONGINT _asmD1
LONGINT _asmSockBase

{ ============== Internal - exec library calls (base at absolute address 4) ============== }

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

{ ============== Internal - amisslmaster library calls ============== }

SUB LONGINT _MasterInit(LONGINT ver, LONGINT usesStructs)
  SHARED _asmA6, _asmD0, _asmD1, _masterBase

  _asmA6 = _masterBase
  _asmD0 = ver
  _asmD1 = usesStructs

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMD0,d0
    move.l  _modv__ASMD1,d1
    move.l  _modv__ASMA6,a6
    jsr     -30(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _MasterInit = _asmD0
END SUB

SUB LONGINT _MasterOpen
  SHARED _asmA6, _asmD0, _masterBase

  _asmA6 = _masterBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA6,a6
    jsr     -36(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _MasterOpen = _asmD0
END SUB

SUB _MasterClose
  SHARED _asmA6, _masterBase

  _asmA6 = _masterBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA6,a6
    jsr     -42(a6)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

{ ============== Internal - amissl library calls ============== }

SUB LONGINT _AmiSSLInit
  SHARED _asmA6, _asmD0, _asmSockBase, _amisslBase

  _asmA6 = _amisslBase

  ' Build tag list: [AmiSSL_SocketBase=$80000001, sockBase, TAG_DONE=0, 0]
  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    lea     _sslTagList,a0
    move.l  #$80000001,(a0)
    move.l  _modv__ASMSOCKBASE,4(a0)
    clr.l   8(a0)
    clr.l   12(a0)
    move.l  _modv__ASMA6,a6
    jsr     -36(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _AmiSSLInit = _asmD0
END SUB

SUB LONGINT _SslCtxNew
  SHARED _asmA6, _asmD0, _amisslBase

  _asmA6 = _amisslBase

  ' First call TLS_client_method (LVO -26934), then SSL_CTX_new (LVO -8208)
  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA6,a6
    jsr     -26934(a6)
    move.l  d0,a0
    move.l  _modv__ASMA6,a6
    jsr     -8208(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _SslCtxNew = _asmD0
END SUB

SUB _SslCtxFree(LONGINT ctx)
  SHARED _asmA0, _asmA6, _amisslBase

  _asmA0 = ctx
  _asmA6 = _amisslBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMA6,a6
    jsr     -8214(a6)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB _SslCtxSetVerify(LONGINT ctx, LONGINT md)
  SHARED _asmA0, _asmA6, _asmD0, _amisslBase

  _asmA0 = ctx
  _asmD0 = md
  _asmA6 = _amisslBase

  ' a1=callback (NULL=0)
  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMD0,d0
    sub.l   a1,a1
    move.l  _modv__ASMA6,a6
    jsr     -8700(a6)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB LONGINT _SslNewInt(LONGINT ctx)
  SHARED _asmA0, _asmA6, _asmD0, _amisslBase

  _asmA0 = ctx
  _asmA6 = _amisslBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMA6,a6
    jsr     -8784(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _SslNewInt = _asmD0
END SUB

SUB _SslFreeInt(LONGINT ssl)
  SHARED _asmA0, _asmA6, _amisslBase

  _asmA0 = ssl
  _asmA6 = _amisslBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMA6,a6
    jsr     -8820(a6)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

SUB LONGINT _SslSetFd(LONGINT ssl, LONGINT fd)
  SHARED _asmA0, _asmA6, _asmD0, _amisslBase

  _asmA0 = ssl
  _asmD0 = fd
  _asmA6 = _amisslBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMD0,d0
    move.l  _modv__ASMA6,a6
    jsr     -8358(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _SslSetFd = _asmD0
END SUB

SUB LONGINT _SslConnectInt(LONGINT ssl)
  SHARED _asmA0, _asmA6, _asmD0, _amisslBase

  _asmA0 = ssl
  _asmA6 = _amisslBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMA6,a6
    jsr     -8832(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _SslConnectInt = _asmD0
END SUB

SUB LONGINT _SslReadInt(LONGINT ssl, ADDRESS buf, LONGINT num)
  SHARED _asmA0, _asmA1, _asmA6, _asmD0, _amisslBase

  _asmA0 = ssl
  _asmA1 = buf
  _asmD0 = num
  _asmA6 = _amisslBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMA1,a1
    move.l  _modv__ASMD0,d0
    move.l  _modv__ASMA6,a6
    jsr     -8838(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _SslReadInt = _asmD0
END SUB

SUB LONGINT _SslWriteInt(LONGINT ssl, ADDRESS buf, LONGINT num)
  SHARED _asmA0, _asmA1, _asmA6, _asmD0, _amisslBase

  _asmA0 = ssl
  _asmA1 = buf
  _asmD0 = num
  _asmA6 = _amisslBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMA1,a1
    move.l  _modv__ASMD0,d0
    move.l  _modv__ASMA6,a6
    jsr     -8850(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _SslWriteInt = _asmD0
END SUB

SUB LONGINT _SslShutdownInt(LONGINT ssl)
  SHARED _asmA0, _asmA6, _asmD0, _amisslBase

  _asmA0 = ssl
  _asmA6 = _amisslBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMA6,a6
    jsr     -8994(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _SslShutdownInt = _asmD0
END SUB

{ ============== Public API ============== }

SUB LONGINT SslInit EXTERNAL
  SHARED _sslInited, _masterBase, _amisslBase, _sslCtx
  SHARED _asmSockBase, _bsdBase
  LONGINT rc

  ' Already initialized?
  IF _sslInited = 1 THEN
    SslInit = SSL_SUCCESS
    EXIT SUB
  END IF
  IF _sslInited = -1 THEN
    SslInit = SSL_ERR_NO_LIB
    EXIT SUB
  END IF

  ' Open bsdsocket.library for AmiSSL init
  _bsdBase = _ExecOpenLib(SADD("bsdsocket.library"), 0)
  IF _bsdBase = 0 THEN
    _sslInited = -1
    SslInit = SSL_ERR_NO_LIB
    EXIT SUB
  END IF
  _asmSockBase = _bsdBase

  ' Open amisslmaster.library via exec (not LIBRARY - would exit on fail)
  _masterBase = _ExecOpenLib(SADD("amisslmaster.library"), 0)
  IF _masterBase = 0 THEN
    _sslInited = -1
    SslInit = SSL_ERR_NO_LIB
    EXIT SUB
  END IF

  ' InitAmiSSLMaster(version=21 for OpenSSL 3.x, usesStructs=1)
  rc = _MasterInit(21, 1)
  IF rc = 0 THEN
    _ExecCloseLib(_masterBase)
    _masterBase = 0
    _sslInited = -1
    SslInit = SSL_ERR_INIT
    EXIT SUB
  END IF

  ' OpenAmiSSL -> amissl library base
  _amisslBase = _MasterOpen
  IF _amisslBase = 0 THEN
    _ExecCloseLib(_masterBase)
    _masterBase = 0
    _sslInited = -1
    SslInit = SSL_ERR_INIT
    EXIT SUB
  END IF

  ' InitAmiSSLA with socket base tag
  rc = _AmiSSLInit
  IF rc <> 0 THEN
    _MasterClose
    _ExecCloseLib(_masterBase)
    _masterBase = 0
    _amisslBase = 0
    _sslInited = -1
    SslInit = SSL_ERR_INIT
    EXIT SUB
  END IF

  ' Create shared SSL context
  _sslCtx = _SslCtxNew
  IF _sslCtx = 0 THEN
    _MasterClose
    _ExecCloseLib(_masterBase)
    _masterBase = 0
    _amisslBase = 0
    _sslInited = -1
    SslInit = SSL_ERR_INIT
    EXIT SUB
  END IF

  ' Disable certificate verification (no CA bundle on Amiga)
  _SslCtxSetVerify(_sslCtx, 0)

  _sslInited = 1
  SslInit = SSL_SUCCESS
END SUB

SUB SslCleanup EXTERNAL
  SHARED _sslInited, _masterBase, _amisslBase, _sslCtx, _bsdBase

  IF _sslInited <> 1 THEN EXIT SUB

  IF _sslCtx <> 0 THEN
    _SslCtxFree(_sslCtx)
    _sslCtx = 0
  END IF

  IF _amisslBase <> 0 THEN
    _MasterClose
    _amisslBase = 0
  END IF

  IF _masterBase <> 0 THEN
    _ExecCloseLib(_masterBase)
    _masterBase = 0
  END IF

  IF _bsdBase <> 0 THEN
    _ExecCloseLib(_bsdBase)
    _bsdBase = 0
  END IF

  _sslInited = 0
END SUB

SUB LONGINT SslNewConn(LONGINT sockFd) EXTERNAL
  SHARED _sslCtx
  LONGINT ssl, rc

  ssl = _SslNewInt(_sslCtx)
  IF ssl = 0 THEN
    SslNewConn = 0
    EXIT SUB
  END IF

  rc = _SslSetFd(ssl, sockFd)
  IF rc = 0 THEN
    _SslFreeInt(ssl)
    SslNewConn = 0
    EXIT SUB
  END IF

  rc = _SslConnectInt(ssl)
  IF rc <> 1 THEN
    _SslFreeInt(ssl)
    SslNewConn = 0
    EXIT SUB
  END IF

  SslNewConn = ssl
END SUB

SUB SslFreeConn(LONGINT ssl) EXTERNAL
  IF ssl <> 0 THEN
    _SslShutdownInt(ssl)
    _SslFreeInt(ssl)
  END IF
END SUB

SUB LONGINT SslRead(LONGINT ssl, ADDRESS buf, LONGINT num) EXTERNAL
  SslRead = _SslReadInt(ssl, buf, num)
END SUB

SUB LONGINT SslWrite(LONGINT ssl, ADDRESS buf, LONGINT num) EXTERNAL
  SslWrite = _SslWriteInt(ssl, buf, num)
END SUB

{ ============== ASSEM Storage ============== }
' Tag list for AmiSSL init (4 longints = 16 bytes).
' Referenced directly in _AmiSSLInit ASSEM block via LEA.

ASSEM
_sslTagList: dc.l 0,0,0,0
END ASSEM
