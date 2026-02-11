{* HTTPClient - HTTP/1.1 client submodule for ACE BASIC *}
{* Phase 2: HTTP/1.1 GET + request/response handling *}

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
CONST HTTP_OK              = 0
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

' Buffer/header limits
CONST READ_BUF_SIZE = 4096
CONST MAX_REQ_HDRS  = 16
CONST MAX_RSP_HDRS  = 32
CONST MAX_GET_BODY  = 16384
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

' Shared read buffer
ADDRESS _bufAddr
LONGINT _bufPos
LONGINT _bufLen
LONGINT _bufSlot

' Response headers
DIM _rHdrName$(31) SIZE 64
DIM _rHdrVal$(31) SIZE 256
LONGINT _rHdrCount
LONGINT _rHdrSlot

' Request headers
DIM _qHdrName$(15) SIZE 64
DIM _qHdrVal$(15) SIZE 256
LONGINT _qHdrCount

' URL parse results
STRING _urlHost$ SIZE 128
LONGINT _urlPort
STRING _urlPath$ SIZE 512
LONGINT _urlSSL

' Line reader
ADDRESS _lineBuf
STRING _lineResult$ SIZE 1025
LONGINT _lineOk

' CRLF constant
STRING _crlf$ SIZE 4

' Body read buffer for HttpGet
ADDRESS _bodyBuf

{ ============== Init ============== }

SUB _HttpInit
  SHARED connSocket&, connState%, connSSL&, _httpInited
  SHARED connHost$, connPort%, connContentLen&, connBodyLeft&, connXfer%
  SHARED _bufAddr, _bufPos, _bufLen, _bufSlot
  SHARED _rHdrCount, _rHdrSlot, _qHdrCount
  SHARED _lineBuf, _lineResult$, _lineOk
  SHARED _crlf$, _bodyBuf
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
  NEXT i

  ' Allocate read buffer
  _bufAddr = ALLOC(READ_BUF_SIZE)
  _bufSlot = -1
  _bufPos = 0
  _bufLen = 0

  ' Allocate line buffer
  _lineBuf = ALLOC(MAX_LINE_LEN + 1)

  ' Allocate body buffer for HttpGet
  _bodyBuf = ALLOC(MAX_GET_BODY + 1)

  ' Init header counts
  _rHdrCount = 0
  _rHdrSlot = -1
  _qHdrCount = 0

  ' Init line reader
  _lineResult$ = ""
  _lineOk = 0

  ' CRLF constant
  _crlf$ = CHR$(13) + CHR$(10)

  _httpInited = 1
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
  LONGINT sock, rc
  ADDRESS sa

  sock = socket(AF_INET, SOCK_STREAM, 0)
  IF sock < 0 THEN
    _HttpConnectTCP = -1
    EXIT SUB
  END IF

  sa = ALLOC(16)
  POKE sa, 16
  POKE sa + 1, 2
  POKEW sa + 2, port
  POKEL sa + 4, ipAddr

  rc = connect(sock, sa, 16)
  IF rc < 0 THEN
    CloseSocket(sock)
    _HttpConnectTCP = -1
    EXIT SUB
  END IF

  _HttpConnectTCP = sock
END SUB

SUB LONGINT _HttpSendRaw(LONGINT slot, ADDRESS buf, LONGINT bufLen)
  SHARED connSocket&
  _HttpSendRaw = send(connSocket&(slot), buf, bufLen, 0)
END SUB

SUB LONGINT _HttpRecvRaw(LONGINT slot, ADDRESS buf, LONGINT bufLen)
  SHARED connSocket&
  _HttpRecvRaw = recv(connSocket&(slot), buf, bufLen, 0)
END SUB

{ ============== Internal Helpers - HTTP ============== }

SUB LONGINT _HttpSendStr(LONGINT slot, STRING msg$)
  _HttpSendStr = _HttpSendRaw(slot, SADD(msg$), LEN(msg$))
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

{ ============== Public API - Core ============== }

SUB LONGINT HttpOpen(STRING host, LONGINT port, LONGINT useSSL) EXTERNAL
  SHARED connSocket&, connState%, connHost$, connPort%
  LONGINT slot, ipAddr, sock

  _HttpInit

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

  HttpOpen = slot + 1
END SUB

SUB HttpClose(LONGINT hConn) EXTERNAL
  SHARED connSocket&, connState%
  SHARED connHost$, connPort%, connContentLen&, connBodyLeft&, connXfer%
  SHARED _bufSlot, _bufPos, _bufLen
  SHARED _rHdrSlot, _rHdrCount
  LONGINT slot

  slot = hConn - 1
  IF slot < 0 OR slot > 3 THEN EXIT SUB
  IF connState%(slot) = CONN_FREE THEN EXIT SUB

  CloseSocket(connSocket&(slot))
  connSocket&(slot) = -1
  connState%(slot) = CONN_FREE
  connHost$(slot) = ""
  connPort%(slot) = 0
  connContentLen&(slot) = 0
  connBodyLeft&(slot) = 0
  connXfer%(slot) = XFER_CLOSE

  ' Release buffer/header ownership if this slot owned them
  IF _bufSlot = slot THEN
    _bufSlot = -1
    _bufPos = 0
    _bufLen = 0
  END IF
  IF _rHdrSlot = slot THEN
    _rHdrSlot = -1
    _rHdrCount = 0
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
  SHARED _qHdrName$, _qHdrVal$, _qHdrCount
  LONGINT i
  STRING upperNm$ SIZE 64

  upperNm$ = UCASE$(hdrNm$)

  ' Overwrite if header already exists (case-insensitive)
  FOR i = 0 TO _qHdrCount - 1
    IF UCASE$(_qHdrName$(i)) = upperNm$ THEN
      _qHdrVal$(i) = hdrVl$
      EXIT SUB
    END IF
  NEXT i

  ' Add new header
  IF _qHdrCount < MAX_REQ_HDRS THEN
    _qHdrName$(_qHdrCount) = hdrNm$
    _qHdrVal$(_qHdrCount) = hdrVl$
    _qHdrCount = _qHdrCount + 1
  END IF
END SUB

SUB LONGINT HttpSendRequest(LONGINT h, STRING meth$, ~
                            STRING reqPath$) EXTERNAL
  SHARED connState%, connHost$, connPort%
  SHARED _qHdrName$, _qHdrVal$, _qHdrCount, _crlf$
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
    _HttpSendStr(slot, "Host: " + connHost$(slot) + _crlf$)
  ELSE
    portStr$ = MID$(STR$(connPort%(slot)), 2)
    _HttpSendStr(slot, "Host: " + connHost$(slot) + ":" + portStr$ + _crlf$)
  END IF

  ' Custom request headers
  FOR i = 0 TO _qHdrCount - 1
    _HttpSendStr(slot, _qHdrName$(i) + ": " + _qHdrVal$(i) + _crlf$)
  NEXT i

  ' Connection: close
  _HttpSendStr(slot, "Connection: close" + _crlf$)

  ' Blank line ends headers
  _HttpSendStr(slot, _crlf$)

  ' Clear request headers for next use
  _qHdrCount = 0

  HttpSendRequest = HTTP_OK
END SUB

SUB LONGINT HttpReadStatus(LONGINT h) EXTERNAL
  SHARED connState%
  SHARED connContentLen&, connBodyLeft&, connXfer%
  SHARED _bufSlot, _bufPos, _bufLen
  SHARED _rHdrName$, _rHdrVal$, _rHdrCount, _rHdrSlot
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
  _rHdrCount = 0
  _rHdrSlot = slot
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
      IF colonPos > 0 AND _rHdrCount < MAX_RSP_HDRS THEN
        tmpNm$ = LEFT$(_lineResult$, colonPos - 1)
        tmpVl$ = MID$(_lineResult$, colonPos + 1)
        ' Trim leading space
        IF LEFT$(tmpVl$, 1) = " " THEN
          tmpVl$ = MID$(tmpVl$, 2)
        END IF

        _rHdrName$(_rHdrCount) = tmpNm$
        _rHdrVal$(_rHdrCount) = tmpVl$

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

        _rHdrCount = _rHdrCount + 1
      END IF
    END IF
  WEND

  HttpReadStatus = statusCode
END SUB

SUB STRING HttpGetResponseHeader(LONGINT h, STRING hdrNm$) EXTERNAL
  SHARED _rHdrName$, _rHdrVal$, _rHdrCount, _rHdrSlot
  LONGINT slot, i
  STRING upperNm$ SIZE 64

  slot = h - 1
  IF slot <> _rHdrSlot THEN
    HttpGetResponseHeader = ""
    EXIT SUB
  END IF

  upperNm$ = UCASE$(hdrNm$)
  FOR i = 0 TO _rHdrCount - 1
    IF UCASE$(_rHdrName$(i)) = upperNm$ THEN
      HttpGetResponseHeader = _rHdrVal$(i)
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

{ ============== Public API - High-level convenience ============== }

SUB LONGINT HttpGet(STRING url, ADDRESS respBuf) EXTERNAL
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

  ' Read body directly into caller's buffer
  totalLen = 0
  rdDone = 0
  WHILE rdDone = 0
    bytesGot = HttpReadBody(hConn, respBuf + totalLen, ~
                            MAX_GET_BODY - totalLen)
    IF bytesGot > 0 THEN
      totalLen = totalLen + bytesGot
      IF totalLen >= MAX_GET_BODY THEN rdDone = 1
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

{ ============== Stubs - Remaining API ============== }

SUB LONGINT HttpPost(STRING url, STRING ct, ~
                     STRING body, ADDRESS respBuf) EXTERNAL
  HttpPost = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpPut(STRING url, STRING ct, ~
                    STRING body, ADDRESS respBuf) EXTERNAL
  HttpPut = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpRequest(STRING url, STRING meth, ~
                        STRING ct, STRING body, ~
                        ADDRESS respBuf) EXTERNAL
  HttpRequest = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpGetStream(STRING url, ADDRESS onRecv) EXTERNAL
  HttpGetStream = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpPostStream(STRING url, STRING ct, ~
                           ADDRESS onSend, ADDRESS onRecv) EXTERNAL
  HttpPostStream = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpPutStream(STRING url, STRING ct, ~
                          ADDRESS onSend, ADDRESS onRecv) EXTERNAL
  HttpPutStream = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpRequestStream(STRING url, STRING meth, ~
                              STRING ct, ADDRESS onSend, ~
                              ADDRESS onRecv) EXTERNAL
  HttpRequestStream = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpWriteBody(LONGINT h, LONGINT dataBuf, ~
                          LONGINT bodyLen) EXTERNAL
  HttpWriteBody = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpWriteBodyChunked(LONGINT h, LONGINT dataBuf, ~
                                 LONGINT bodyLen) EXTERNAL
  HttpWriteBodyChunked = HTTP_ERR_SOCKET
END SUB

SUB STRING UrlEncode(STRING raw) EXTERNAL
  UrlEncode = raw
END SUB
