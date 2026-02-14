{* HTTPClient - HTTP/1.1 client submodule for ACE BASIC *}
{* Single-connection model, delegates TCP/SSL to tcpclient/amissl *}

REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/tcpclient.h>

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

' Connection state
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

' Connection state (single connection)
SHORTINT _connState
LONGINT _tcpHandle
LONGINT _httpInited

' Per-connection state
STRING _connHost$ SIZE 128
SHORTINT _connPort
LONGINT _connContentLen
LONGINT _connBodyLeft
SHORTINT _connXfer

' Chunked decoder state
SHORTINT _connChunkState
LONGINT _connChunkLeft

' Response headers
DIM _respHdrName$(31) SIZE 64
DIM _respHdrVal$(31) SIZE 256
LONGINT _respHdrCount

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

' CRLF constant
STRING _crlf$ SIZE 4


{ ============== Init ============== }

SUB _HttpInit
  SHARED _connState, _tcpHandle, _httpInited
  SHARED _connHost$, _connPort, _connContentLen, _connBodyLeft, _connXfer
  SHARED _connChunkState, _connChunkLeft
  SHARED _respHdrCount, _reqHdrCount
  SHARED _lineBuf, _lineResult$, _lineOk
  SHARED _streamBuf
  SHARED _crlf$

  IF _httpInited = 1 THEN EXIT SUB

  ' Initialize TCP subsystem
  TcpInit

  _connState = CONN_FREE
  _tcpHandle = 0
  _connHost$ = ""
  _connPort = 0
  _connContentLen = 0
  _connBodyLeft = 0
  _connXfer = XFER_CLOSE
  _connChunkState = CHK_SIZE
  _connChunkLeft = 0

  ' Allocate line buffer
  _lineBuf = ALLOC(MAX_LINE_LEN + 1)

  ' Allocate streaming buffer
  _streamBuf = ALLOC(READ_BUF_SIZE)

  ' Init header counts
  _respHdrCount = 0
  _reqHdrCount = 0

  ' Init line reader
  _lineResult$ = ""
  _lineOk = 0

  ' CRLF constant
  _crlf$ = CHR$(13) + CHR$(10)

  _httpInited = 1
END SUB

{ ============== Internal Helpers - TCP wrappers ============== }

SUB LONGINT _HttpSendRaw(ADDRESS buf, LONGINT bufLen)
  SHARED _tcpHandle

  _HttpSendRaw = TcpSend(_tcpHandle, buf, bufLen)
END SUB

SUB _HttpRecvLine
  SHARED _tcpHandle, _lineBuf, _lineResult$, _lineOk
  LONGINT rc

  rc = TcpRecvLine(_tcpHandle, _lineBuf, MAX_LINE_LEN)
  IF rc >= 0 THEN
    _lineResult$ = CSTR(_lineBuf)
    _lineOk = 1
  ELSE
    _lineResult$ = ""
    _lineOk = 0
  END IF
END SUB

SUB LONGINT _HttpReadBuf(LONGINT destAddr, LONGINT maxBytes)
  SHARED _tcpHandle

  _HttpReadBuf = TcpRecvBuf(_tcpHandle, destAddr, maxBytes)
END SUB

{ ============== Internal Helpers - HTTP ============== }

SUB LONGINT _HttpSendStr(STRING msg$)
  _HttpSendStr = _HttpSendRaw(SADD(msg$), LEN(msg$))
END SUB

SUB STRING _HttpLongToHex(LONGINT v)
  _HttpLongToHex = FMT$("%lx", v)
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

  IF STARTSWITH(url$, "https://") THEN
    _urlSSL = 1
    _urlPort = 443
    rest$ = MID$(url$, 9)
  ELSEIF STARTSWITH(url$, "http://") THEN
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

{ ============== Internal Helpers - Chunked Decoder ============== }

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

SUB LONGINT _HttpReadChunked(LONGINT bufAddr, LONGINT bufSz)
  SHARED _connChunkState, _connChunkLeft
  SHARED _lineResult$, _lineOk
  LONGINT toRead, nRead, retVal
  LONGINT looping

  retVal = 0
  looping = 1
  WHILE looping = 1
    IF _connChunkState = CHK_DONE THEN
      retVal = 0
      looping = 0
    ELSEIF _connChunkState = CHK_TRAIL THEN
      ' Consume trailing CRLF after chunk data
      _HttpRecvLine
      _connChunkState = CHK_SIZE
    ELSEIF _connChunkState = CHK_SIZE THEN
      ' Read hex chunk size line
      _HttpRecvLine
      IF _lineOk = 0 THEN
        retVal = 0
        looping = 0
      ELSE
        _connChunkLeft = _HttpParseHex(_lineResult$)
        IF _connChunkLeft = 0 THEN
          ' Final zero-length chunk - consume trailing CRLF
          _HttpRecvLine
          _connChunkState = CHK_DONE
          retVal = 0
          looping = 0
        ELSE
          _connChunkState = CHK_DATA
        END IF
      END IF
    ELSEIF _connChunkState = CHK_DATA THEN
      toRead = bufSz
      IF toRead > _connChunkLeft THEN
        toRead = _connChunkLeft
      END IF
      nRead = _HttpReadBuf(bufAddr, toRead)
      IF nRead <= 0 THEN
        retVal = 0
        looping = 0
      ELSE
        _connChunkLeft = _connChunkLeft - nRead
        IF _connChunkLeft = 0 THEN
          _connChunkState = CHK_TRAIL
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
  SHARED _connState, _tcpHandle, _connHost$, _connPort
  LONGINT h

  _HttpInit

  ' Only one connection at a time
  IF _connState <> CONN_FREE THEN
    HttpOpen = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  h = TcpOpen(host, port, useSSL)

  ' Map tcpclient errors to HTTP error codes
  IF h = TCP_ERR_DNS THEN
    HttpOpen = HTTP_ERR_DNS
    EXIT SUB
  ELSEIF h = TCP_ERR_SSL THEN
    HttpOpen = HTTP_ERR_SSL_INIT
    EXIT SUB
  ELSEIF h = TCP_ERR_NO_SLOT THEN
    HttpOpen = HTTP_ERR_SOCKET
    EXIT SUB
  ELSEIF h < 0 THEN
    HttpOpen = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  _tcpHandle = h
  _connState = CONN_OPEN
  _connHost$ = host
  _connPort = port

  HttpOpen = 1
END SUB

SUB HttpClose(LONGINT hConn) EXTERNAL
  SHARED _connState, _tcpHandle
  SHARED _connHost$, _connPort, _connContentLen, _connBodyLeft, _connXfer
  SHARED _connChunkState, _connChunkLeft
  SHARED _respHdrCount, _reqHdrCount

  IF hConn <> 1 THEN EXIT SUB
  IF _connState = CONN_FREE THEN EXIT SUB

  TcpClose(_tcpHandle)

  _tcpHandle = 0
  _connState = CONN_FREE
  _connHost$ = ""
  _connPort = 0
  _connContentLen = 0
  _connBodyLeft = 0
  _connXfer = XFER_CLOSE
  _connChunkState = CHK_SIZE
  _connChunkLeft = 0

  ' Reset headers
  _respHdrCount = 0
  _reqHdrCount = 0
END SUB

{ ============== Public API - Raw byte helpers ============== }

SUB LONGINT HttpSendRawBytes(LONGINT hConn, STRING msg) EXTERNAL
  SHARED _connState, _tcpHandle

  IF hConn <> 1 THEN
    HttpSendRawBytes = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF _connState <> CONN_OPEN THEN
    HttpSendRawBytes = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  HttpSendRawBytes = TcpSend(_tcpHandle, SADD(msg), LEN(msg))
END SUB

SUB LONGINT HttpRecvRawBytes(LONGINT hConn, ADDRESS buf, LONGINT bufSz) EXTERNAL
  SHARED _connState, _tcpHandle

  IF hConn <> 1 THEN
    HttpRecvRawBytes = HTTP_ERR_RECV
    EXIT SUB
  END IF
  IF _connState <> CONN_OPEN THEN
    HttpRecvRawBytes = HTTP_ERR_RECV
    EXIT SUB
  END IF

  HttpRecvRawBytes = TcpRecv(_tcpHandle, buf, bufSz)
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
  SHARED _connState, _connHost$, _connPort
  SHARED _reqHdrName$, _reqHdrVal$, _reqHdrCount, _crlf$
  LONGINT i, rc

  IF h <> 1 THEN
    HttpSendRequest = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF _connState <> CONN_OPEN THEN
    HttpSendRequest = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  ' Request line: METHOD path HTTP/1.1\r\n
  rc = _HttpSendStr(meth$ + " " + reqPath$ + " HTTP/1.1" + _crlf$)
  IF rc < 0 THEN
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Host header (with port if non-standard)
  IF _connPort = 80 OR _connPort = 443 THEN
    rc = _HttpSendStr("Host: " + _connHost$ + _crlf$)
  ELSE
    rc = _HttpSendStr(FMT$("Host: %s:%ld", _connHost$, _connPort) + _crlf$)
  END IF
  IF rc < 0 THEN
    _reqHdrCount = 0
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Custom request headers
  FOR i = 0 TO _reqHdrCount - 1
    rc = _HttpSendStr(_reqHdrName$(i) + ": " + _reqHdrVal$(i) + _crlf$)
    IF rc < 0 THEN
      _reqHdrCount = 0
      HttpSendRequest = HTTP_ERR_SEND
      EXIT SUB
    END IF
  NEXT i

  ' Connection: close
  rc = _HttpSendStr("Connection: close" + _crlf$)
  IF rc < 0 THEN
    _reqHdrCount = 0
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Blank line ends headers
  rc = _HttpSendStr(_crlf$)
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
  SHARED _connState, _tcpHandle
  SHARED _connContentLen, _connBodyLeft, _connXfer
  SHARED _connChunkState, _connChunkLeft
  SHARED _respHdrName$, _respHdrVal$, _respHdrCount
  SHARED _lineResult$, _lineOk
  LONGINT spPos, statusCode
  LONGINT colonPos, gotBlank
  STRING tmpNm$ SIZE 64
  STRING tmpVl$ SIZE 256

  IF h <> 1 THEN
    HttpReadStatus = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF _connState <> CONN_OPEN THEN
    HttpReadStatus = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  ' Reset transfer state
  _connXfer = XFER_CLOSE
  _connContentLen = 0
  _connBodyLeft = 0
  _connChunkState = CHK_SIZE
  _connChunkLeft = 0

  ' Flush any leftover buffered data in tcpclient
  TcpBufFlush(_tcpHandle)

  ' Read status line: "HTTP/1.x NNN reason"
  _HttpRecvLine
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
  gotBlank = 0

  WHILE gotBlank = 0
    _HttpRecvLine
    IF _lineOk = 0 THEN
      gotBlank = 1
    ELSEIF LEN(_lineResult$) = 0 THEN
      gotBlank = 1
    ELSE
      ' Parse "Name: Value" (handle optional whitespace after colon)
      colonPos = INSTR(_lineResult$, ":")
      IF colonPos > 0 AND _respHdrCount < MAX_RSP_HDRS THEN
        tmpNm$ = LEFT$(_lineResult$, colonPos - 1)
        tmpVl$ = LTRIM$(MID$(_lineResult$, colonPos + 1))

        _respHdrName$(_respHdrCount) = tmpNm$
        _respHdrVal$(_respHdrCount) = tmpVl$

        ' Detect Content-Length
        IF UCASE$(tmpNm$) = "CONTENT-LENGTH" THEN
          _connContentLen = CLNG(VAL(tmpVl$))
          _connBodyLeft = _connContentLen
          _connXfer = XFER_LENGTH
        END IF

        ' Detect Transfer-Encoding: chunked
        IF UCASE$(tmpNm$) = "TRANSFER-ENCODING" THEN
          IF INSTR(UCASE$(tmpVl$), "CHUNKED") > 0 THEN
            _connXfer = XFER_CHUNKED
          END IF
        END IF

        _respHdrCount = _respHdrCount + 1
      END IF
    END IF
  WEND

  HttpReadStatus = statusCode
END SUB

SUB STRING HttpGetResponseHeader(LONGINT h, STRING hdrNm$) EXTERNAL
  SHARED _respHdrName$, _respHdrVal$, _respHdrCount
  LONGINT i
  STRING upperNm$ SIZE 64

  IF h <> 1 THEN
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

SUB LONGINT HttpResponseHeaderCount(LONGINT h) EXTERNAL
  SHARED _respHdrCount

  IF h <> 1 THEN
    HttpResponseHeaderCount = 0
    EXIT SUB
  END IF

  HttpResponseHeaderCount = _respHdrCount
END SUB

SUB STRING HttpResponseHeaderName(LONGINT h, LONGINT idx) EXTERNAL
  SHARED _respHdrName$, _respHdrCount

  IF h <> 1 THEN
    HttpResponseHeaderName = ""
    EXIT SUB
  END IF
  IF idx < 0 OR idx >= _respHdrCount THEN
    HttpResponseHeaderName = ""
    EXIT SUB
  END IF

  HttpResponseHeaderName = _respHdrName$(idx)
END SUB

SUB STRING HttpResponseHeaderVal(LONGINT h, LONGINT idx) EXTERNAL
  SHARED _respHdrVal$, _respHdrCount

  IF h <> 1 THEN
    HttpResponseHeaderVal = ""
    EXIT SUB
  END IF
  IF idx < 0 OR idx >= _respHdrCount THEN
    HttpResponseHeaderVal = ""
    EXIT SUB
  END IF

  HttpResponseHeaderVal = _respHdrVal$(idx)
END SUB

SUB LONGINT HttpReadBody(LONGINT h, LONGINT dataBuf, ~
                         LONGINT bufSz) EXTERNAL
  SHARED _connState, _tcpHandle, _connXfer, _connBodyLeft
  LONGINT toRead, totalRd, n

  IF h <> 1 THEN
    HttpReadBody = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF _connState <> CONN_OPEN THEN
    HttpReadBody = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  ' Chunked mode - use chunk decoder
  IF _connXfer = XFER_CHUNKED THEN
    HttpReadBody = _HttpReadChunked(dataBuf, bufSz)
    EXIT SUB
  END IF

  ' Determine how much to read
  IF _connXfer = XFER_LENGTH THEN
    IF _connBodyLeft <= 0 THEN
      HttpReadBody = 0
      EXIT SUB
    END IF
    toRead = bufSz
    IF toRead > _connBodyLeft THEN
      toRead = _connBodyLeft
    END IF
  ELSE
    toRead = bufSz
  END IF

  ' Read via tcpclient buffered reader
  totalRd = TcpRecvBuf(_tcpHandle, dataBuf, toRead)

  IF totalRd <= 0 THEN
    IF _connXfer = XFER_CLOSE THEN
      HttpReadBody = 0
    ELSE
      HttpReadBody = HTTP_ERR_RECV
    END IF
    EXIT SUB
  END IF

  ' Update remaining body length for Content-Length mode
  IF _connXfer = XFER_LENGTH THEN
    _connBodyLeft = _connBodyLeft - totalRd
  END IF

  HttpReadBody = totalRd
END SUB

{ ============== Public API - Low-level write ============== }

SUB LONGINT HttpWriteBody(LONGINT h, LONGINT dataBuf, ~
                          LONGINT bodyLen) EXTERNAL
  SHARED _connState
  LONGINT rc

  IF h <> 1 THEN
    HttpWriteBody = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF _connState <> CONN_OPEN THEN
    HttpWriteBody = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  rc = _HttpSendRaw(dataBuf, bodyLen)
  IF rc < 0 THEN
    HttpWriteBody = HTTP_ERR_SEND
  ELSE
    HttpWriteBody = HTTP_SUCCESS
  END IF
END SUB

SUB LONGINT HttpWriteBodyChunked(LONGINT h, LONGINT dataBuf, ~
                                 LONGINT bodyLen) EXTERNAL
  SHARED _connState, _crlf$
  LONGINT rc

  IF h <> 1 THEN
    HttpWriteBodyChunked = HTTP_ERR_SOCKET
    EXIT SUB
  END IF
  IF _connState <> CONN_OPEN THEN
    HttpWriteBodyChunked = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  IF bodyLen = 0 THEN
    ' Final chunk terminator: "0\r\n\r\n"
    rc = _HttpSendStr("0" + _crlf$ + _crlf$)
    IF rc < 0 THEN
      HttpWriteBodyChunked = HTTP_ERR_SEND
    ELSE
      HttpWriteBodyChunked = HTTP_SUCCESS
    END IF
    EXIT SUB
  END IF

  ' Send chunk: hex(len) + CRLF + data + CRLF
  rc = _HttpSendStr(_HttpLongToHex(bodyLen) + _crlf$)
  IF rc < 0 THEN
    HttpWriteBodyChunked = HTTP_ERR_SEND
    EXIT SUB
  END IF

  rc = _HttpSendRaw(dataBuf, bodyLen)
  IF rc < 0 THEN
    HttpWriteBodyChunked = HTTP_ERR_SEND
    EXIT SUB
  END IF

  rc = _HttpSendStr(_crlf$)
  IF rc < 0 THEN
    HttpWriteBodyChunked = HTTP_ERR_SEND
  ELSE
    HttpWriteBodyChunked = HTTP_SUCCESS
  END IF
END SUB

{ ============== Public API - Utility ============== }

SUB STRING UrlEncode(STRING raw) EXTERNAL
  STRING result$ SIZE 1024
  LONGINT i, c

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
      result$ = result$ + FMT$("%%%02lx", c)
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
    HttpSetHeader(hConn, "Content-Length", FMT$("%ld", LEN(body)))
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
