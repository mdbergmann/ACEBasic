{* HTTPClient - HTTP/1.1 client submodule for ACE BASIC *}
{* Phase 6: AmiSSL/HTTPS integration *}

{ ============== Library Declarations ============== }

DECLARE FUNCTION socket& LIBRARY bsdsocket
DECLARE FUNCTION connect& LIBRARY bsdsocket
DECLARE FUNCTION send& LIBRARY bsdsocket
DECLARE FUNCTION recv& LIBRARY bsdsocket
DECLARE FUNCTION CloseSocket& LIBRARY bsdsocket
DECLARE FUNCTION gethostbyname& LIBRARY bsdsocket
DECLARE FUNCTION inet_addr& LIBRARY bsdsocket

{ ============== Constants ============== }

' Error codes (match HTTPClient.h)
CONST HTTP_SUCCESS              = 0
CONST HTTP_ERR_SOCKET      = -1
CONST HTTP_ERR_DNS         = -2
CONST HTTP_ERR_SEND        = -3
CONST HTTP_ERR_RECV        = -4
CONST HTTP_ERR_SSL_INIT    = -5
CONST HTTP_ERR_SSL_CONNECT = -6
CONST HTTP_ERR_PARSE       = -7
CONST HTTP_ERR_OVERFLOW    = -8
CONST HTTP_ERR_CALLBACK    = -9
CONST HTTP_ERR_NO_LIB      = -10

' Socket constants
CONST AF_INET       = 2
CONST SOCK_STREAM   = 1

' Connection table
CONST CONN_FREE     = 0
CONST CONN_OPEN     = 1

' Transfer encoding modes
CONST XFER_CLOSE    = 0
CONST XFER_LENGTH   = 1
CONST XFER_CHUNKED  = 2

' Chunk decoder states
CONST CHK_SIZE    = 0
CONST CHK_DATA    = 1
CONST CHK_TRAIL   = 2
CONST CHK_DONE    = 3

' Buffer/header limits
CONST READ_BUF_SIZE = 4096
CONST MAX_REQ_HDRS  = 16
CONST MAX_RSP_HDRS  = 32
CONST MAX_LINE_LEN  = 1024

{ ============== Module Data ============== }

' Connection table (Phase 1)
DIM connSocket&(3)
DIM connState%(3)
DIM connSSL&(3)
LONGINT _httpInited

' Per-connection state (Phase 2)
DIM connHost$(3) SIZE 128
DIM connPort%(3)
DIM connContentLen&(3)
DIM connBodyLeft&(3)
DIM connXfer%(3)

' Chunked decoder state (Phase 3)
DIM connChunkState%(3)
DIM connChunkLeft&(3)

' Shared read buffer
ADDRESS _bufAddr
LONGINT _bufPos
LONGINT _bufLen
LONGINT _bufSlot

' Response headers
DIM _respHdrName$(31) SIZE 64
DIM _respHdrVal$(31) SIZE 256
LONGINT _respHdrCount
LONGINT _respHdrSlot

' Request headers
DIM _reqHdrName$(15) SIZE 64
DIM _reqHdrVal$(15) SIZE 256
LONGINT _reqHdrCount

' URL parse results
STRING _urlHost$ SIZE 128
LONGINT _urlPort
STRING _urlPath$ SIZE 512
LONGINT _urlSSL

' Line reader
ADDRESS _lineBuf
STRING _lineResult$ SIZE 1025
LONGINT _lineOk

' Streaming buffer (shared for send/receive, not concurrent)
ADDRESS _streamBuf

' Reusable sockaddr_in buffer (16 bytes, allocated once)
ADDRESS _sockAddr

' CRLF constant
STRING _crlf$ SIZE 4

' SSL global state (Phase 6)
LONGINT _sslInited
LONGINT _masterBase
LONGINT _amisslBase
LONGINT _sslCtx

' ASSEM temporaries (module-level, BSS names: _modv__asm*)
LONGINT _asmA0
LONGINT _asmA1
LONGINT _asmA6
LONGINT _asmD0
LONGINT _asmD1
LONGINT _asmSockBase


{ ============== Init ============== }

SUB _HttpInit
  SHARED connSocket&, connState%, connSSL&, _httpInited
  SHARED connHost$, connPort%, connContentLen&, connBodyLeft&, connXfer%
  SHARED connChunkState%, connChunkLeft&
  SHARED _bufAddr, _bufPos, _bufLen, _bufSlot
  SHARED _respHdrCount, _respHdrSlot, _reqHdrCount
  SHARED _lineBuf, _lineResult$, _lineOk
  SHARED _streamBuf, _sockAddr
  SHARED _crlf$
  LONGINT i

  IF _httpInited = 1 THEN EXIT SUB

  LIBRARY "bsdsocket.library"

  FOR i = 0 TO 3
    connSocket&(i) = -1
    connState%(i) = CONN_FREE
    connSSL&(i) = 0
    connHost$(i) = ""
    connPort%(i) = 0
    connContentLen&(i) = 0
    connBodyLeft&(i) = 0
    connXfer%(i) = XFER_CLOSE
    connChunkState%(i) = CHK_SIZE
    connChunkLeft&(i) = 0
  NEXT i

  ' Allocate read buffer
  _bufAddr = ALLOC(READ_BUF_SIZE)
  _bufSlot = -1
  _bufPos = 0
  _bufLen = 0

  ' Allocate line buffer
  _lineBuf = ALLOC(MAX_LINE_LEN + 1)

  ' Allocate streaming buffer
  _streamBuf = ALLOC(READ_BUF_SIZE)

  ' Allocate reusable sockaddr_in buffer
  _sockAddr = ALLOC(16)

  ' Init header counts
  _respHdrCount = 0
  _respHdrSlot = -1
  _reqHdrCount = 0

  ' Init line reader
  _lineResult$ = ""
  _lineOk = 0

  ' CRLF constant
  _crlf$ = CHR$(13) + CHR$(10)

  _httpInited = 1
END SUB

{ ============== Internal Helpers - SSL ASSEM Wrappers (Phase 6) ============== }
' Module-level _asm* vars (SHARED) pass values to/from ASSEM blocks.
' ASSEM references BSS labels: _modv__ASMA0, _modv__ASMD0, etc.

' --- exec library calls (base at absolute address 4) ---

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

' --- amisslmaster library calls ---

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

' --- amissl library calls ---

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

SUB LONGINT _SslNew(LONGINT ctx)
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

  _SslNew = _asmD0
END SUB

SUB _SslFree(LONGINT ssl)
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

SUB LONGINT _SslConnect(LONGINT ssl)
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

  _SslConnect = _asmD0
END SUB

SUB LONGINT _SslRead(LONGINT ssl, ADDRESS buf, LONGINT num)
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

  _SslRead = _asmD0
END SUB

SUB LONGINT _SslWrite(LONGINT ssl, ADDRESS buf, LONGINT num)
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

  _SslWrite = _asmD0
END SUB

SUB LONGINT _SslShutdown(LONGINT ssl)
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

  _SslShutdown = _asmD0
END SUB

{ ============== Internal Helpers - SSL Init/Handshake (Phase 6) ============== }

SUB LONGINT _HttpInitSSL
  SHARED _sslInited, _masterBase, _amisslBase, _sslCtx
  LONGINT rc

  ' Already initialized?
  IF _sslInited = 1 THEN
    _HttpInitSSL = HTTP_SUCCESS
    EXIT SUB
  END IF
  IF _sslInited = -1 THEN
    _HttpInitSSL = HTTP_ERR_NO_LIB
    EXIT SUB
  END IF

  ' Open amisslmaster.library via exec (not LIBRARY - would exit on fail)
  _masterBase = _ExecOpenLib(SADD("amisslmaster.library"), 0)
  IF _masterBase = 0 THEN
    _sslInited = -1
    _HttpInitSSL = HTTP_ERR_NO_LIB
    EXIT SUB
  END IF

  ' InitAmiSSLMaster(version=21 for OpenSSL 3.x, usesStructs=1)
  rc = _MasterInit(21, 1)
  IF rc = 0 THEN
    _ExecCloseLib(_masterBase)
    _masterBase = 0
    _sslInited = -1
    _HttpInitSSL = HTTP_ERR_SSL_INIT
    EXIT SUB
  END IF

  ' OpenAmiSSL -> amissl library base
  _amisslBase = _MasterOpen
  IF _amisslBase = 0 THEN
    _ExecCloseLib(_masterBase)
    _masterBase = 0
    _sslInited = -1
    _HttpInitSSL = HTTP_ERR_SSL_INIT
    EXIT SUB
  END IF

  ' Copy bsdsocket.library base to ASSEM-accessible storage
  ' _BSDSOCKETBase is created by ACE's LIBRARY statement
  ASSEM
    move.l  _BSDSOCKETBase,d0
    move.l  d0,_modv__ASMSOCKBASE
  END ASSEM

  ' InitAmiSSLA with socket base tag
  rc = _AmiSSLInit
  IF rc <> 0 THEN
    _MasterClose
    _ExecCloseLib(_masterBase)
    _masterBase = 0
    _amisslBase = 0
    _sslInited = -1
    _HttpInitSSL = HTTP_ERR_SSL_INIT
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
    _HttpInitSSL = HTTP_ERR_SSL_INIT
    EXIT SUB
  END IF

  ' Disable certificate verification (no CA bundle on Amiga)
  _SslCtxSetVerify(_sslCtx, 0)

  _sslInited = 1
  _HttpInitSSL = HTTP_SUCCESS
END SUB

SUB LONGINT _HttpSSLHandshake(LONGINT slot)
  SHARED connSocket&, connSSL&, _sslCtx
  LONGINT ssl, rc

  ssl = _SslNew(_sslCtx)
  IF ssl = 0 THEN
    _HttpSSLHandshake = HTTP_ERR_SSL_INIT
    EXIT SUB
  END IF

  rc = _SslSetFd(ssl, connSocket&(slot))
  IF rc = 0 THEN
    _SslFree(ssl)
    _HttpSSLHandshake = HTTP_ERR_SSL_CONNECT
    EXIT SUB
  END IF

  rc = _SslConnect(ssl)
  IF rc <> 1 THEN
    _SslFree(ssl)
    _HttpSSLHandshake = HTTP_ERR_SSL_CONNECT
    EXIT SUB
  END IF

  connSSL&(slot) = ssl
  _HttpSSLHandshake = HTTP_SUCCESS
END SUB

SUB _HttpSSLShutdown(LONGINT slot)
  SHARED connSSL&

  IF connSSL&(slot) <> 0 THEN
    _SslShutdown(connSSL&(slot))
    _SslFree(connSSL&(slot))
    connSSL&(slot) = 0
  END IF
END SUB

{ ============== Internal Helpers - TCP ============== }

SUB LONGINT _HttpAllocSlot
  SHARED connState%
  LONGINT i

  FOR i = 0 TO 3
    IF connState%(i) = CONN_FREE THEN
      _HttpAllocSlot = i
      EXIT SUB
    END IF
  NEXT i

  _HttpAllocSlot = -1
END SUB

SUB LONGINT _HttpResolve(host$)
  LONGINT he, addrList, addrPtr, ipAddr

  ' Try as dotted IP first
  ipAddr = inet_addr(SADD(host$))
  IF ipAddr <> -1 THEN
    _HttpResolve = ipAddr
    EXIT SUB
  END IF

  ' DNS lookup
  he = gethostbyname(SADD(host$))
  IF he = 0 THEN
    _HttpResolve = 0
    EXIT SUB
  END IF

  ' hostent: h_addr_list is at offset 16
  addrList = PEEKL(he + 16)
  addrPtr = PEEKL(addrList)
  ipAddr = PEEKL(addrPtr)
  _HttpResolve = ipAddr
END SUB

SUB LONGINT _HttpConnectTCP(LONGINT ipAddr, LONGINT port)
  SHARED _sockAddr
  LONGINT sock, rc

  sock = socket(AF_INET, SOCK_STREAM, 0)
  IF sock < 0 THEN
    _HttpConnectTCP = -1
    EXIT SUB
  END IF

  POKE _sockAddr, 16
  POKE _sockAddr + 1, 2
  POKEW _sockAddr + 2, port
  POKEL _sockAddr + 4, ipAddr

  rc = connect(sock, _sockAddr, 16)
  IF rc < 0 THEN
    CloseSocket(sock)
    _HttpConnectTCP = -1
    EXIT SUB
  END IF

  _HttpConnectTCP = sock
END SUB

SUB LONGINT _HttpSendRaw(LONGINT slot, ADDRESS buf, LONGINT bufLen)
  SHARED connSocket&, connSSL&

  IF connSSL&(slot) <> 0 THEN
    _HttpSendRaw = _SslWrite(connSSL&(slot), buf, bufLen)
  ELSE
    _HttpSendRaw = send(connSocket&(slot), buf, bufLen, 0)
  END IF
END SUB

SUB LONGINT _HttpRecvRaw(LONGINT slot, ADDRESS buf, LONGINT bufLen)
  SHARED connSocket&, connSSL&

  IF connSSL&(slot) <> 0 THEN
    _HttpRecvRaw = _SslRead(connSSL&(slot), buf, bufLen)
  ELSE
    _HttpRecvRaw = recv(connSocket&(slot), buf, bufLen, 0)
  END IF
END SUB

{ ============== Internal Helpers - HTTP ============== }

SUB LONGINT _HttpSendStr(LONGINT slot, STRING msg$)
  _HttpSendStr = _HttpSendRaw(slot, SADD(msg$), LEN(msg$))
END SUB

SUB STRING _HttpLongToHex(LONGINT v)
  STRING hexDig$ SIZE 20
  STRING result$ SIZE 12
  LONGINT digit

  hexDig$ = "0123456789ABCDEF"

  IF v = 0 THEN
    _HttpLongToHex = "0"
    EXIT SUB
  END IF

  result$ = ""
  WHILE v > 0
    digit = v AND 15
    result$ = MID$(hexDig$, digit + 1, 1) + result$
    v = v \ 16
  WEND

  _HttpLongToHex = result$
END SUB

SUB _HttpParseUrl(STRING url$)
  SHARED _urlHost$, _urlPort, _urlPath$, _urlSSL
  LONGINT slashPos, colonPos
  STRING rest$ SIZE 640
  STRING hostPart$ SIZE 128

  _urlHost$ = ""
  _urlPort = 80
  _urlPath$ = "/"
  _urlSSL = 0

  IF LEFT$(url$, 8) = "https://" THEN
    _urlSSL = 1
    _urlPort = 443
    rest$ = MID$(url$, 9)
  ELSEIF LEFT$(url$, 7) = "http://" THEN
    _urlSSL = 0
    _urlPort = 80
    rest$ = MID$(url$, 8)
  ELSE
    rest$ = url$
  END IF

  ' Find first / to separate host from path
  slashPos = INSTR(rest$, "/")
  IF slashPos = 0 THEN
    hostPart$ = rest$
    _urlPath$ = "/"
  ELSE
    hostPart$ = LEFT$(rest$, slashPos - 1)
    _urlPath$ = MID$(rest$, slashPos)
  END IF

  ' Check for :port in host part
  colonPos = INSTR(hostPart$, ":")
  IF colonPos > 0 THEN
    _urlHost$ = LEFT$(hostPart$, colonPos - 1)
    _urlPort = CLNG(VAL(MID$(hostPart$, colonPos + 1)))
  ELSE
    _urlHost$ = hostPart$
  END IF
END SUB

SUB _HttpRecvLine(LONGINT slot)
  SHARED _bufAddr, _bufPos, _bufLen, _bufSlot
  SHARED _lineBuf, _lineResult$, _lineOk
  LONGINT resultLen, found, lineErr
  LONGINT scanPos, gotLF, copyEnd, avail, n, i

  ' Ensure buffer is for this slot
  IF _bufSlot <> slot THEN
    _bufSlot = slot
    _bufPos = 0
    _bufLen = 0
  END IF

  resultLen = 0
  found = 0
  lineErr = 0

  WHILE found = 0 AND lineErr = 0
    ' Refill buffer if empty
    IF _bufPos >= _bufLen THEN
      _bufPos = 0
      _bufLen = 0
      n = _HttpRecvRaw(slot, _bufAddr, READ_BUF_SIZE)
      IF n <= 0 THEN
        lineErr = 1
      ELSE
        _bufLen = n
      END IF
    END IF

    IF lineErr = 0 THEN
      ' Scan for LF (byte 10)
      scanPos = _bufPos
      gotLF = 0
      WHILE scanPos < _bufLen AND gotLF = 0
        IF PEEK(_bufAddr + scanPos) = 10 THEN
          gotLF = 1
        ELSE
          scanPos = scanPos + 1
        END IF
      WEND

      IF gotLF = 1 THEN
        ' Found LF: copy bytes before it (strip CR if present)
        copyEnd = scanPos
        IF copyEnd > _bufPos THEN
          IF PEEK(_bufAddr + copyEnd - 1) = 13 THEN
            copyEnd = copyEnd - 1
          END IF
        END IF
        FOR i = _bufPos TO copyEnd - 1
          IF resultLen < MAX_LINE_LEN THEN
            POKE _lineBuf + resultLen, PEEK(_bufAddr + i)
            resultLen = resultLen + 1
          END IF
        NEXT i
        _bufPos = scanPos + 1
        found = 1
      ELSE
        ' No LF yet: copy all remaining buffer bytes
        FOR i = _bufPos TO _bufLen - 1
          IF resultLen < MAX_LINE_LEN THEN
            POKE _lineBuf + resultLen, PEEK(_bufAddr + i)
            resultLen = resultLen + 1
          END IF
        NEXT i
        _bufPos = _bufLen
      END IF
    END IF
  WEND

  ' Null-terminate and convert to string
  POKE _lineBuf + resultLen, 0
  _lineResult$ = CSTR(_lineBuf)

  IF lineErr THEN
    _lineOk = 0
  ELSE
    _lineOk = 1
  END IF
END SUB

{ ============== Internal Helpers - Chunked Decoder (Phase 3) ============== }

SUB LONGINT _HttpParseHex(STRING hx$)
  LONGINT result, i, c, dgt, done

  result = 0
  i = 1
  done = 0
  WHILE i <= LEN(hx$) AND done = 0
    c = ASC(MID$(hx$, i, 1))
    IF c >= 48 AND c <= 57 THEN
      dgt = c - 48
    ELSEIF c >= 65 AND c <= 70 THEN
      dgt = c - 55
    ELSEIF c >= 97 AND c <= 102 THEN
      dgt = c - 87
    ELSE
      done = 1
    END IF
    IF done = 0 THEN
      result = result * 16 + dgt
    END IF
    i = i + 1
  WEND

  _HttpParseHex = result
END SUB

SUB LONGINT _HttpReadBuf(LONGINT slot, LONGINT destAddr, LONGINT maxBytes)
  SHARED _bufAddr, _bufPos, _bufLen, _bufSlot
  LONGINT avail, n, i

  IF maxBytes <= 0 THEN
    _HttpReadBuf = 0
    EXIT SUB
  END IF

  IF _bufSlot <> slot THEN
    _bufSlot = slot
    _bufPos = 0
    _bufLen = 0
  END IF

  ' If buffer has data, drain up to maxBytes
  IF _bufPos < _bufLen THEN
    avail = _bufLen - _bufPos
    IF avail > maxBytes THEN avail = maxBytes
    FOR i = 0 TO avail - 1
      POKE destAddr + i, PEEK(_bufAddr + _bufPos + i)
    NEXT i
    _bufPos = _bufPos + avail
    _HttpReadBuf = avail
    EXIT SUB
  END IF

  ' Buffer empty - refill from socket
  _bufPos = 0
  _bufLen = 0
  n = _HttpRecvRaw(slot, _bufAddr, READ_BUF_SIZE)
  IF n <= 0 THEN
    _HttpReadBuf = 0
    EXIT SUB
  END IF
  _bufLen = n

  ' Copy up to maxBytes from freshly filled buffer
  avail = n
  IF avail > maxBytes THEN avail = maxBytes
  FOR i = 0 TO avail - 1
    POKE destAddr + i, PEEK(_bufAddr + i)
  NEXT i
  _bufPos = avail
  _HttpReadBuf = avail
END SUB

SUB LONGINT _HttpReadChunked(LONGINT slot, LONGINT bufAddr, LONGINT bufSz)
  SHARED connChunkState%, connChunkLeft&
  SHARED _lineResult$, _lineOk
  LONGINT toRead, nRead, retVal
  LONGINT looping

  retVal = 0
  looping = 1
  WHILE looping = 1
    IF connChunkState%(slot) = CHK_DONE THEN
      retVal = 0
      looping = 0
    ELSEIF connChunkState%(slot) = CHK_TRAIL THEN
      ' Consume trailing CRLF after chunk data
      _HttpRecvLine(slot)
      connChunkState%(slot) = CHK_SIZE
    ELSEIF connChunkState%(slot) = CHK_SIZE THEN
      ' Read hex chunk size line
      _HttpRecvLine(slot)
      IF _lineOk = 0 THEN
        retVal = 0
        looping = 0
      ELSE
        connChunkLeft&(slot) = _HttpParseHex(_lineResult$)
        IF connChunkLeft&(slot) = 0 THEN
          ' Final zero-length chunk - consume trailing CRLF
          _HttpRecvLine(slot)
          connChunkState%(slot) = CHK_DONE
          retVal = 0
          looping = 0
        ELSE
          connChunkState%(slot) = CHK_DATA
        END IF
      END IF
    ELSEIF connChunkState%(slot) = CHK_DATA THEN
      toRead = bufSz
      IF toRead > connChunkLeft&(slot) THEN
        toRead = connChunkLeft&(slot)
      END IF
      nRead = _HttpReadBuf(slot, bufAddr, toRead)
      IF nRead <= 0 THEN
        retVal = 0
        looping = 0
      ELSE
        connChunkLeft&(slot) = connChunkLeft&(slot) - nRead
        IF connChunkLeft&(slot) = 0 THEN
          connChunkState%(slot) = CHK_TRAIL
        END IF
        retVal = nRead
        looping = 0
      END IF
    ELSE
      ' Unknown state
      retVal = 0
      looping = 0
    END IF
  WEND

  _HttpReadChunked = retVal
END SUB

{ ============== Public API - Core ============== }

SUB LONGINT HttpOpen(STRING host, LONGINT port, LONGINT useSSL) EXTERNAL
  SHARED connSocket&, connState%, connHost$, connPort%
  LONGINT slot, ipAddr, sock, rc

  _HttpInit

  ' SSL init on first HTTPS request (lazy)
  IF useSSL = 1 THEN
    rc = _HttpInitSSL
    IF rc < 0 THEN
      HttpOpen = rc
      EXIT SUB
    END IF
  END IF

  slot = _HttpAllocSlot
  IF slot < 0 THEN
    HttpOpen = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  ipAddr = _HttpResolve(host)
  IF ipAddr = 0 THEN
    HttpOpen = HTTP_ERR_DNS
    EXIT SUB
  END IF

  sock = _HttpConnectTCP(ipAddr, port)
  IF sock < 0 THEN
    HttpOpen = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  connSocket&(slot) = sock
  connState%(slot) = CONN_OPEN
  connHost$(slot) = host
  connPort%(slot) = port

  ' SSL handshake after TCP connect
  IF useSSL = 1 THEN
    rc = _HttpSSLHandshake(slot)
    IF rc < 0 THEN
      CloseSocket(sock)
      connSocket&(slot) = -1
      connState%(slot) = CONN_FREE
      connHost$(slot) = ""
      connPort%(slot) = 0
      HttpOpen = rc
      EXIT SUB
    END IF
  END IF

  HttpOpen = slot + 1
END SUB

SUB HttpClose(LONGINT hConn) EXTERNAL
  SHARED connSocket&, connState%
  SHARED connHost$, connPort%, connContentLen&, connBodyLeft&, connXfer%
  SHARED connChunkState%, connChunkLeft&
  SHARED _bufSlot, _bufPos, _bufLen
  SHARED _respHdrSlot, _respHdrCount
  LONGINT slot

  slot = hConn - 1
  IF slot < 0 OR slot > 3 THEN EXIT SUB
  IF connState%(slot) = CONN_FREE THEN EXIT SUB

  ' SSL shutdown before closing socket
  _HttpSSLShutdown(slot)

  CloseSocket(connSocket&(slot))
  connSocket&(slot) = -1
  connState%(slot) = CONN_FREE
  connHost$(slot) = ""
  connPort%(slot) = 0
  connContentLen&(slot) = 0
  connBodyLeft&(slot) = 0
  connXfer%(slot) = XFER_CLOSE
  connChunkState%(slot) = CHK_SIZE
  connChunkLeft&(slot) = 0

  ' Release buffer/header ownership if this slot owned them
  IF _bufSlot = slot THEN
    _bufSlot = -1
    _bufPos = 0
    _bufLen = 0
  END IF
  IF _respHdrSlot = slot THEN
    _respHdrSlot = -1
    _respHdrCount = 0
  END IF
END SUB

{ ============== Public API - Raw byte helpers (Phase 1 testing) ============== }

SUB LONGINT HttpSendRawBytes(LONGINT hConn, STRING msg) EXTERNAL
  SHARED connSocket&, connState%
  LONGINT slot

  slot = hConn - 1
  IF slot < 0 OR slot > 3 THEN
    HttpSendRawBytes = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF connState%(slot) = CONN_FREE THEN
    HttpSendRawBytes = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  HttpSendRawBytes = send(connSocket&(slot), SADD(msg), LEN(msg), 0)
END SUB

SUB LONGINT HttpRecvRawBytes(LONGINT hConn, ADDRESS buf, LONGINT bufSz) EXTERNAL
  SHARED connSocket&, connState%
  LONGINT slot

  slot = hConn - 1
  IF slot < 0 OR slot > 3 THEN
    HttpRecvRawBytes = HTTP_ERR_RECV
    EXIT SUB
  END IF
  IF connState%(slot) = CONN_FREE THEN
    HttpRecvRawBytes = HTTP_ERR_RECV
    EXIT SUB
  END IF

  HttpRecvRawBytes = recv(connSocket&(slot), buf, bufSz, 0)
END SUB

{ ============== Public API - Low-level handle API ============== }

SUB HttpSetHeader(LONGINT h, STRING hdrNm$, STRING hdrVl$) EXTERNAL
  SHARED _reqHdrName$, _reqHdrVal$, _reqHdrCount
  LONGINT i
  STRING upperNm$ SIZE 64

  upperNm$ = UCASE$(hdrNm$)

  ' Overwrite if header already exists (case-insensitive)
  FOR i = 0 TO _reqHdrCount - 1
    IF UCASE$(_reqHdrName$(i)) = upperNm$ THEN
      _reqHdrVal$(i) = hdrVl$
      EXIT SUB
    END IF
  NEXT i

  ' Add new header
  IF _reqHdrCount < MAX_REQ_HDRS THEN
    _reqHdrName$(_reqHdrCount) = hdrNm$
    _reqHdrVal$(_reqHdrCount) = hdrVl$
    _reqHdrCount = _reqHdrCount + 1
  END IF
END SUB

SUB LONGINT HttpSendRequest(LONGINT h, STRING meth$, ~
                            STRING reqPath$) EXTERNAL
  SHARED connState%, connHost$, connPort%
  SHARED _reqHdrName$, _reqHdrVal$, _reqHdrCount, _crlf$
  LONGINT slot, i, rc
  STRING portStr$ SIZE 8

  slot = h - 1
  IF slot < 0 OR slot > 3 THEN
    HttpSendRequest = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF connState%(slot) <> CONN_OPEN THEN
    HttpSendRequest = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  ' Request line: METHOD path HTTP/1.1\r\n
  rc = _HttpSendStr(slot, meth$ + " " + reqPath$ + " HTTP/1.1" + _crlf$)
  IF rc < 0 THEN
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Host header (with port if non-standard)
  IF connPort%(slot) = 80 OR connPort%(slot) = 443 THEN
    rc = _HttpSendStr(slot, "Host: " + connHost$(slot) + _crlf$)
  ELSE
    portStr$ = MID$(STR$(connPort%(slot)), 2)
    rc = _HttpSendStr(slot, "Host: " + connHost$(slot) + ":" + portStr$ + _crlf$)
  END IF
  IF rc < 0 THEN
    _reqHdrCount = 0
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Custom request headers
  FOR i = 0 TO _reqHdrCount - 1
    rc = _HttpSendStr(slot, _reqHdrName$(i) + ": " + _reqHdrVal$(i) + _crlf$)
    IF rc < 0 THEN
      _reqHdrCount = 0
      HttpSendRequest = HTTP_ERR_SEND
      EXIT SUB
    END IF
  NEXT i

  ' Connection: close
  rc = _HttpSendStr(slot, "Connection: close" + _crlf$)
  IF rc < 0 THEN
    _reqHdrCount = 0
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Blank line ends headers
  rc = _HttpSendStr(slot, _crlf$)
  IF rc < 0 THEN
    _reqHdrCount = 0
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Clear request headers for next use
  _reqHdrCount = 0

  HttpSendRequest = HTTP_SUCCESS
END SUB

SUB LONGINT HttpReadStatus(LONGINT h) EXTERNAL
  SHARED connState%
  SHARED connContentLen&, connBodyLeft&, connXfer%
  SHARED connChunkState%, connChunkLeft&
  SHARED _bufSlot, _bufPos, _bufLen
  SHARED _respHdrName$, _respHdrVal$, _respHdrCount, _respHdrSlot
  SHARED _lineResult$, _lineOk
  LONGINT slot, spPos, statusCode
  LONGINT colonPos, gotBlank
  STRING tmpNm$ SIZE 64
  STRING tmpVl$ SIZE 256

  slot = h - 1
  IF slot < 0 OR slot > 3 THEN
    HttpReadStatus = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF connState%(slot) <> CONN_OPEN THEN
    HttpReadStatus = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  ' Reset transfer state for this slot
  connXfer%(slot) = XFER_CLOSE
  connContentLen&(slot) = 0
  connBodyLeft&(slot) = 0
  connChunkState%(slot) = CHK_SIZE
  connChunkLeft&(slot) = 0

  ' Claim read buffer for this slot
  _bufSlot = slot
  _bufPos = 0
  _bufLen = 0

  ' Read status line: "HTTP/1.x NNN reason"
  _HttpRecvLine(slot)
  IF _lineOk = 0 THEN
    HttpReadStatus = HTTP_ERR_RECV
    EXIT SUB
  END IF

  ' Parse status code (3 digits after first space)
  spPos = INSTR(_lineResult$, " ")
  IF spPos = 0 THEN
    HttpReadStatus = HTTP_ERR_PARSE
    EXIT SUB
  END IF
  statusCode = CLNG(VAL(MID$(_lineResult$, spPos + 1, 3)))
  IF statusCode < 100 OR statusCode > 999 THEN
    HttpReadStatus = HTTP_ERR_PARSE
    EXIT SUB
  END IF

  ' Read headers until blank line
  _respHdrCount = 0
  _respHdrSlot = slot
  gotBlank = 0

  WHILE gotBlank = 0
    _HttpRecvLine(slot)
    IF _lineOk = 0 THEN
      gotBlank = 1
    ELSEIF LEN(_lineResult$) = 0 THEN
      gotBlank = 1
    ELSE
      ' Parse "Name: Value" (handle optional space after colon)
      colonPos = INSTR(_lineResult$, ":")
      IF colonPos > 0 AND _respHdrCount < MAX_RSP_HDRS THEN
        tmpNm$ = LEFT$(_lineResult$, colonPos - 1)
        tmpVl$ = MID$(_lineResult$, colonPos + 1)
        ' Trim leading space
        IF LEFT$(tmpVl$, 1) = " " THEN
          tmpVl$ = MID$(tmpVl$, 2)
        END IF

        _respHdrName$(_respHdrCount) = tmpNm$
        _respHdrVal$(_respHdrCount) = tmpVl$

        ' Detect Content-Length
        IF UCASE$(tmpNm$) = "CONTENT-LENGTH" THEN
          connContentLen&(slot) = CLNG(VAL(tmpVl$))
          connBodyLeft&(slot) = connContentLen&(slot)
          connXfer%(slot) = XFER_LENGTH
        END IF

        ' Detect Transfer-Encoding: chunked
        IF UCASE$(tmpNm$) = "TRANSFER-ENCODING" THEN
          IF INSTR(UCASE$(tmpVl$), "CHUNKED") > 0 THEN
            connXfer%(slot) = XFER_CHUNKED
          END IF
        END IF

        _respHdrCount = _respHdrCount + 1
      END IF
    END IF
  WEND

  HttpReadStatus = statusCode
END SUB

SUB STRING HttpGetResponseHeader(LONGINT h, STRING hdrNm$) EXTERNAL
  SHARED _respHdrName$, _respHdrVal$, _respHdrCount, _respHdrSlot
  LONGINT slot, i
  STRING upperNm$ SIZE 64

  slot = h - 1
  IF slot <> _respHdrSlot THEN
    HttpGetResponseHeader = ""
    EXIT SUB
  END IF

  upperNm$ = UCASE$(hdrNm$)
  FOR i = 0 TO _respHdrCount - 1
    IF UCASE$(_respHdrName$(i)) = upperNm$ THEN
      HttpGetResponseHeader = _respHdrVal$(i)
      EXIT SUB
    END IF
  NEXT i

  HttpGetResponseHeader = ""
END SUB

SUB LONGINT HttpReadBody(LONGINT h, LONGINT dataBuf, ~
                         LONGINT bufSz) EXTERNAL
  SHARED connState%, connXfer%, connBodyLeft&
  SHARED _bufAddr, _bufPos, _bufLen, _bufSlot
  LONGINT slot, toRead, totalRd, avail, n, i

  slot = h - 1
  IF slot < 0 OR slot > 3 THEN
    HttpReadBody = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF connState%(slot) <> CONN_OPEN THEN
    HttpReadBody = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  ' Chunked mode - use chunk decoder
  IF connXfer%(slot) = XFER_CHUNKED THEN
    HttpReadBody = _HttpReadChunked(slot, dataBuf, bufSz)
    EXIT SUB
  END IF

  ' Determine how much to read
  IF connXfer%(slot) = XFER_LENGTH THEN
    IF connBodyLeft&(slot) <= 0 THEN
      HttpReadBody = 0
      EXIT SUB
    END IF
    toRead = bufSz
    IF toRead > connBodyLeft&(slot) THEN
      toRead = connBodyLeft&(slot)
    END IF
  ELSE
    toRead = bufSz
  END IF

  totalRd = 0

  ' First drain leftover bytes from read buffer (from header parsing)
  IF _bufSlot = slot AND _bufPos < _bufLen THEN
    avail = _bufLen - _bufPos
    IF avail > toRead THEN avail = toRead
    FOR i = 0 TO avail - 1
      POKE dataBuf + totalRd + i, PEEK(_bufAddr + _bufPos + i)
    NEXT i
    _bufPos = _bufPos + avail
    totalRd = totalRd + avail
    toRead = toRead - avail
  END IF

  ' Read remaining directly from socket
  IF toRead > 0 THEN
    n = _HttpRecvRaw(slot, dataBuf + totalRd, toRead)
    IF n > 0 THEN
      totalRd = totalRd + n
    ELSEIF totalRd = 0 THEN
      IF connXfer%(slot) = XFER_CLOSE THEN
        HttpReadBody = 0
      ELSE
        HttpReadBody = HTTP_ERR_RECV
      END IF
      EXIT SUB
    END IF
  END IF

  ' Update remaining body length for Content-Length mode
  IF connXfer%(slot) = XFER_LENGTH THEN
    connBodyLeft&(slot) = connBodyLeft&(slot) - totalRd
  END IF

  HttpReadBody = totalRd
END SUB

{ ============== Public API - Low-level write ============== }

SUB LONGINT HttpWriteBody(LONGINT h, LONGINT dataBuf, ~
                          LONGINT bodyLen) EXTERNAL
  SHARED connState%
  LONGINT slot, rc

  slot = h - 1
  IF slot < 0 OR slot > 3 THEN
    HttpWriteBody = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF connState%(slot) <> CONN_OPEN THEN
    HttpWriteBody = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  rc = _HttpSendRaw(slot, dataBuf, bodyLen)
  IF rc < 0 THEN
    HttpWriteBody = HTTP_ERR_SEND
  ELSE
    HttpWriteBody = HTTP_SUCCESS
  END IF
END SUB

SUB LONGINT HttpWriteBodyChunked(LONGINT h, LONGINT dataBuf, ~
                                 LONGINT bodyLen) EXTERNAL
  SHARED connState%, _crlf$
  LONGINT slot, rc

  slot = h - 1
  IF slot < 0 OR slot > 3 THEN
    HttpWriteBodyChunked = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF connState%(slot) <> CONN_OPEN THEN
    HttpWriteBodyChunked = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  IF bodyLen = 0 THEN
    ' Final chunk terminator: "0\r\n\r\n"
    rc = _HttpSendStr(slot, "0" + _crlf$ + _crlf$)
    IF rc < 0 THEN
      HttpWriteBodyChunked = HTTP_ERR_SEND
    ELSE
      HttpWriteBodyChunked = HTTP_SUCCESS
    END IF
    EXIT SUB
  END IF

  ' Send chunk: hex(len) + CRLF + data + CRLF
  rc = _HttpSendStr(slot, _HttpLongToHex(bodyLen) + _crlf$)
  IF rc < 0 THEN
    HttpWriteBodyChunked = HTTP_ERR_SEND
    EXIT SUB
  END IF

  rc = _HttpSendRaw(slot, dataBuf, bodyLen)
  IF rc < 0 THEN
    HttpWriteBodyChunked = HTTP_ERR_SEND
    EXIT SUB
  END IF

  rc = _HttpSendStr(slot, _crlf$)
  IF rc < 0 THEN
    HttpWriteBodyChunked = HTTP_ERR_SEND
  ELSE
    HttpWriteBodyChunked = HTTP_SUCCESS
  END IF
END SUB

{ ============== Public API - Utility ============== }

SUB STRING UrlEncode(STRING raw) EXTERNAL
  STRING hexDig$ SIZE 20
  STRING result$ SIZE 1024
  STRING ch$ SIZE 4
  LONGINT i, c, hi, lo

  hexDig$ = "0123456789ABCDEF"
  result$ = ""

  FOR i = 1 TO LEN(raw)
    c = ASC(MID$(raw, i, 1))
    IF (c >= 65 AND c <= 90) THEN
      ' A-Z
      result$ = result$ + CHR$(c)
    ELSEIF (c >= 97 AND c <= 122) THEN
      ' a-z
      result$ = result$ + CHR$(c)
    ELSEIF (c >= 48 AND c <= 57) THEN
      ' 0-9
      result$ = result$ + CHR$(c)
    ELSEIF c = 45 OR c = 95 OR c = 46 OR c = 126 THEN
      ' - _ . ~
      result$ = result$ + CHR$(c)
    ELSE
      ' Percent-encode
      hi = (c \ 16) AND 15
      lo = c AND 15
      result$ = result$ + "%" + MID$(hexDig$, hi + 1, 1) + MID$(hexDig$, lo + 1, 1)
    END IF
  NEXT i

  UrlEncode = result$
END SUB

{ ============== Public API - High-level convenience ============== }

SUB LONGINT HttpGet(STRING url, ADDRESS respBuf, ~
                    LONGINT bufSz) EXTERNAL
  SHARED _urlHost$, _urlPort, _urlPath$, _urlSSL
  LONGINT hConn, statusCode, rc
  LONGINT totalLen, bytesGot, rdDone

  _HttpInit

  _HttpParseUrl(url)
  IF LEN(_urlHost$) = 0 THEN
    HttpGet = HTTP_ERR_PARSE
    EXIT SUB
  END IF

  hConn = HttpOpen(_urlHost$, _urlPort, _urlSSL)
  IF hConn < 1 THEN
    HttpGet = hConn
    EXIT SUB
  END IF

  rc = HttpSendRequest(hConn, "GET", _urlPath$)
  IF rc < 0 THEN
    HttpClose(hConn)
    HttpGet = rc
    EXIT SUB
  END IF

  statusCode = HttpReadStatus(hConn)
  IF statusCode < 0 THEN
    HttpClose(hConn)
    HttpGet = statusCode
    EXIT SUB
  END IF

  ' Read body directly into caller's buffer (reserve 1 byte for null)
  totalLen = 0
  rdDone = 0
  WHILE rdDone = 0
    bytesGot = HttpReadBody(hConn, respBuf + totalLen, ~
                            bufSz - 1 - totalLen)
    IF bytesGot > 0 THEN
      totalLen = totalLen + bytesGot
      IF totalLen >= bufSz - 1 THEN rdDone = 1
    ELSE
      rdDone = 1
    END IF
  WEND

  ' Null-terminate for CSTR conversion
  POKE respBuf + totalLen, 0

  HttpClose(hConn)
  HttpGet = statusCode
END SUB

SUB LONGINT HttpHead(STRING url) EXTERNAL
  SHARED _urlHost$, _urlPort, _urlPath$, _urlSSL
  LONGINT hConn, statusCode, rc

  _HttpInit

  _HttpParseUrl(url)
  IF LEN(_urlHost$) = 0 THEN
    HttpHead = HTTP_ERR_PARSE
    EXIT SUB
  END IF

  hConn = HttpOpen(_urlHost$, _urlPort, _urlSSL)
  IF hConn < 1 THEN
    HttpHead = hConn
    EXIT SUB
  END IF

  rc = HttpSendRequest(hConn, "HEAD", _urlPath$)
  IF rc < 0 THEN
    HttpClose(hConn)
    HttpHead = rc
    EXIT SUB
  END IF

  statusCode = HttpReadStatus(hConn)
  HttpClose(hConn)
  HttpHead = statusCode
END SUB

SUB LONGINT HttpRequest(STRING url, STRING meth, ~
                        STRING ct, STRING body, ~
                        ADDRESS respBuf, LONGINT bufSz) EXTERNAL
  SHARED _urlHost$, _urlPort, _urlPath$, _urlSSL
  LONGINT hConn, statusCode, rc
  LONGINT totalLen, bytesGot, rdDone
  LONGINT hasBody
  STRING clenStr$ SIZE 16

  _HttpInit

  _HttpParseUrl(url)
  IF LEN(_urlHost$) = 0 THEN
    HttpRequest = HTTP_ERR_PARSE
    EXIT SUB
  END IF

  hConn = HttpOpen(_urlHost$, _urlPort, _urlSSL)
  IF hConn < 1 THEN
    HttpRequest = hConn
    EXIT SUB
  END IF

  ' Determine if this method sends a body
  hasBody = 0
  IF meth <> "GET" AND meth <> "HEAD" AND meth <> "DELETE" THEN
    IF LEN(body) > 0 THEN
      hasBody = 1
    END IF
  END IF

  ' Set Content-Type and Content-Length for body-bearing requests
  IF hasBody THEN
    IF LEN(ct) > 0 THEN
      HttpSetHeader(hConn, "Content-Type", ct)
    END IF
    clenStr$ = MID$(STR$(LEN(body)), 2)
    HttpSetHeader(hConn, "Content-Length", clenStr$)
  END IF

  rc = HttpSendRequest(hConn, meth, _urlPath$)
  IF rc < 0 THEN
    HttpClose(hConn)
    HttpRequest = rc
    EXIT SUB
  END IF

  ' Send body if present
  IF hasBody THEN
    rc = HttpWriteBody(hConn, SADD(body), LEN(body))
    IF rc < 0 THEN
      HttpClose(hConn)
      HttpRequest = rc
      EXIT SUB
    END IF
  END IF

  statusCode = HttpReadStatus(hConn)
  IF statusCode < 0 THEN
    HttpClose(hConn)
    HttpRequest = statusCode
    EXIT SUB
  END IF

  ' Read response body (unless HEAD)
  IF meth <> "HEAD" THEN
    totalLen = 0
    rdDone = 0
    WHILE rdDone = 0
      bytesGot = HttpReadBody(hConn, respBuf + totalLen, ~
                              bufSz - 1 - totalLen)
      IF bytesGot > 0 THEN
        totalLen = totalLen + bytesGot
        IF totalLen >= bufSz - 1 THEN rdDone = 1
      ELSE
        rdDone = 1
      END IF
    WEND
    ' Null-terminate
    POKE respBuf + totalLen, 0
  END IF

  HttpClose(hConn)
  HttpRequest = statusCode
END SUB

SUB LONGINT HttpPost(STRING url, STRING ct, ~
                     STRING body, ADDRESS respBuf, ~
                     LONGINT bufSz) EXTERNAL
  HttpPost = HttpRequest(url, "POST", ct, body, respBuf, bufSz)
END SUB

SUB LONGINT HttpPut(STRING url, STRING ct, ~
                    STRING body, ADDRESS respBuf, ~
                    LONGINT bufSz) EXTERNAL
  HttpPut = HttpRequest(url, "PUT", ct, body, respBuf, bufSz)
END SUB

{ ============== Public API - Streaming ============== }

SUB LONGINT HttpRequestStream(STRING url, STRING meth, ~
                              STRING ct, ADDRESS onSend, ~
                              ADDRESS onRecv) EXTERNAL
  SHARED _urlHost$, _urlPort, _urlPath$, _urlSSL
  SHARED _streamBuf, _crlf$
  LONGINT hConn, statusCode, rc
  LONGINT hasBody, sendLen, bytesGot, cbRet
  LONGINT rdDone

  _HttpInit

  _HttpParseUrl(url)
  IF LEN(_urlHost$) = 0 THEN
    HttpRequestStream = HTTP_ERR_PARSE
    EXIT SUB
  END IF

  hConn = HttpOpen(_urlHost$, _urlPort, _urlSSL)
  IF hConn < 1 THEN
    HttpRequestStream = hConn
    EXIT SUB
  END IF

  ' Determine if this method sends a body
  hasBody = 0
  IF meth <> "GET" AND meth <> "HEAD" AND meth <> "DELETE" THEN
    IF onSend <> 0 THEN
      hasBody = 1
    END IF
  END IF

  ' Set up headers for body-bearing requests with chunked encoding
  IF hasBody THEN
    IF LEN(ct) > 0 THEN
      HttpSetHeader(hConn, "Content-Type", ct)
    END IF
    HttpSetHeader(hConn, "Transfer-Encoding", "chunked")
  END IF

  rc = HttpSendRequest(hConn, meth, _urlPath$)
  IF rc < 0 THEN
    HttpClose(hConn)
    HttpRequestStream = rc
    EXIT SUB
  END IF

  ' Send body via callback in chunked mode
  IF hasBody THEN
    sendLen = 1
    WHILE sendLen > 0
      sendLen = INVOKE onSend(_streamBuf, READ_BUF_SIZE)
      IF sendLen > 0 THEN
        rc = HttpWriteBodyChunked(hConn, _streamBuf, sendLen)
        IF rc < 0 THEN
          HttpClose(hConn)
          HttpRequestStream = HTTP_ERR_SEND
          EXIT SUB
        END IF
      END IF
    WEND
    ' Send final zero-length chunk
    rc = HttpWriteBodyChunked(hConn, _streamBuf, 0)
    IF rc < 0 THEN
      HttpClose(hConn)
      HttpRequestStream = HTTP_ERR_SEND
      EXIT SUB
    END IF
  END IF

  statusCode = HttpReadStatus(hConn)
  IF statusCode < 0 THEN
    HttpClose(hConn)
    HttpRequestStream = statusCode
    EXIT SUB
  END IF

  ' Read response body via callback (unless HEAD or no callback)
  IF meth <> "HEAD" AND onRecv <> 0 THEN
    rdDone = 0
    WHILE rdDone = 0
      bytesGot = HttpReadBody(hConn, _streamBuf, READ_BUF_SIZE)
      IF bytesGot > 0 THEN
        cbRet = INVOKE onRecv(_streamBuf, bytesGot)
        IF cbRet = HTTP_ABORT THEN
          HttpClose(hConn)
          HttpRequestStream = HTTP_ERR_CALLBACK
          EXIT SUB
        END IF
      ELSE
        rdDone = 1
      END IF
    WEND
  END IF

  HttpClose(hConn)
  HttpRequestStream = statusCode
END SUB

SUB LONGINT HttpGetStream(STRING url, ADDRESS onRecv) EXTERNAL
  HttpGetStream = HttpRequestStream(url, "GET", "", 0&, onRecv)
END SUB

SUB LONGINT HttpPostStream(STRING url, STRING ct, ~
                           ADDRESS onSend, ADDRESS onRecv) EXTERNAL
  HttpPostStream = HttpRequestStream(url, "POST", ct, onSend, onRecv)
END SUB

SUB LONGINT HttpPutStream(STRING url, STRING ct, ~
                          ADDRESS onSend, ADDRESS onRecv) EXTERNAL
  HttpPutStream = HttpRequestStream(url, "PUT", ct, onSend, onRecv)
END SUB

{ ============== ASSEM Storage (Phase 6) ============== }
' Tag list for AmiSSL init (4 longints = 16 bytes).
' Referenced directly in _AmiSSLInit ASSEM block via LEA.

ASSEM
_sslTagList: dc.l 0,0,0,0
END ASSEM
