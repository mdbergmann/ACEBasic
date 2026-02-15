{* HTTPClient - HTTP/1.1 client submodule for ACE BASIC *}
{* Stateless struct-based API, delegates TCP/SSL to tcpclient/amissl *}
{* Caller owns 3 independent structs: TcpConn, HttpRequest, HttpResponse *}

REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/tcpclient.h>

{ ============== Constants ============== }

' Error codes
CONST HTTP_SUCCESS         = 0
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

' Streaming callback return values
CONST HTTP_CONTINUE = 0
CONST HTTP_ABORT    = 1

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

{ ============== Struct Definitions ============== }

STRUCT HttpRequest
  STRING _reqHost SIZE 128
  LONGINT _reqPort
  STRING _reqHdrNames SIZE 1024
  STRING _reqHdrVals SIZE 4096
  LONGINT _reqHdrCount
END STRUCT

STRUCT HttpResponse
  LONGINT statusCode
  LONGINT contentLen
  STRING respHdrNames SIZE 2048
  STRING respHdrVals SIZE 8192
  LONGINT respHdrCount
  LONGINT _bodyLeft
  LONGINT _xfer
  LONGINT _chunkState
  LONGINT _chunkLeft
END STRUCT

{ ============== URL Parse Result ============== }

STRUCT UrlParts
  STRING host SIZE 128
  LONGINT port
  STRING path SIZE 512
  LONGINT ssl
END STRUCT

{ ============== Module Data ============== }

' Global init flag
LONGINT _httpInited

' Line reader (workspace)
ADDRESS _lineBuf
STRING _lineResult$ SIZE 1025
LONGINT _lineOk

' CRLF constant
STRING _crlf$ SIZE 4


{ ============== Init ============== }

SUB _HttpInit
  SHARED _httpInited
  SHARED _lineBuf, _lineResult$, _lineOk
  SHARED _crlf$

  IF _httpInited = 1 THEN EXIT SUB

  ' Initialize TCP subsystem
  TcpInit

  ' Allocate line buffer
  _lineBuf = ALLOC(MAX_LINE_LEN + 1)

  ' Init line reader
  _lineResult$ = ""
  _lineOk = 0

  ' CRLF constant
  _crlf$ = CHR$(13) + CHR$(10)

  _httpInited = 1
END SUB

{ ============== Internal Helpers - String copy ============== }

SUB _StrToAddr(ADDRESS destAddr, STRING src$, LONGINT maxLen)
  LONGINT i, sLen
  ADDRESS srcAddr

  sLen = LEN(src$)
  IF sLen > maxLen - 1 THEN sLen = maxLen - 1
  srcAddr = SADD(src$)
  FOR i = 0 TO sLen - 1
    POKE destAddr + i, PEEK(srcAddr + i)
  NEXT i
  POKE destAddr + sLen, 0
END SUB

{ ============== Internal Helpers - TCP wrappers ============== }

SUB LONGINT _HttpSendRaw(ADDRESS tcpConn, ADDRESS buf, LONGINT bufLen)
  _HttpSendRaw = TcpSend(tcpConn, buf, bufLen)
END SUB

SUB _HttpRecvLine(ADDRESS tcpConn)
  SHARED _lineBuf, _lineResult$, _lineOk
  LONGINT rc

  rc = TcpRecvLine(tcpConn, _lineBuf, MAX_LINE_LEN)
  IF rc >= 0 THEN
    _lineResult$ = CSTR(_lineBuf)
    _lineOk = 1
  ELSE
    _lineResult$ = ""
    _lineOk = 0
  END IF
END SUB

SUB LONGINT _HttpReadBuf(ADDRESS tcpConn, ADDRESS destBuf, LONGINT maxBytes)
  _HttpReadBuf = TcpRecvBuf(tcpConn, destBuf, maxBytes)
END SUB

{ ============== Internal Helpers - HTTP ============== }

SUB LONGINT _HttpSendStr(ADDRESS tcpConn, STRING msg$)
  _HttpSendStr = _HttpSendRaw(tcpConn, SADD(msg$), LEN(msg$))
END SUB

SUB STRING _HttpLongToHex(LONGINT v)
  _HttpLongToHex = FMT$("%lx", v)
END SUB

SUB _HttpParseUrl(STRING url$, ADDRESS parts)
  DECLARE STRUCT UrlParts *p
  LONGINT slashPos, colonPos
  STRING rest$ SIZE 640
  STRING hostPart$ SIZE 128

  p = parts
  p->host = ""
  p->port = 80
  p->path = "/"
  p->ssl = 0

  IF STARTSWITH(url$, "https://") THEN
    p->ssl = 1
    p->port = 443
    rest$ = MID$(url$, 9)
  ELSEIF STARTSWITH(url$, "http://") THEN
    p->ssl = 0
    p->port = 80
    rest$ = MID$(url$, 8)
  ELSE
    rest$ = url$
  END IF

  ' Find first / to separate host from path
  slashPos = INSTR(rest$, "/")
  IF slashPos = 0 THEN
    hostPart$ = rest$
    p->path = "/"
  ELSE
    hostPart$ = LEFT$(rest$, slashPos - 1)
    p->path = MID$(rest$, slashPos)
  END IF

  ' Check for :port in host part
  colonPos = INSTR(hostPart$, ":")
  IF colonPos > 0 THEN
    p->host = LEFT$(hostPart$, colonPos - 1)
    p->port = CLNG(VAL(MID$(hostPart$, colonPos + 1)))
  ELSE
    p->host = hostPart$
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

SUB LONGINT _HttpReadChunked(ADDRESS tcpConn, ADDRESS resp, ~
                             ADDRESS bufAddr, LONGINT bufSz)
  DECLARE STRUCT HttpResponse *rp
  SHARED _lineResult$, _lineOk
  LONGINT toRead, nRead, retVal
  LONGINT looping

  rp = resp
  retVal = 0
  looping = 1
  WHILE looping = 1
    IF rp->_chunkState = CHK_DONE THEN
      retVal = 0
      looping = 0
    ELSEIF rp->_chunkState = CHK_TRAIL THEN
      ' Consume trailing CRLF after chunk data
      _HttpRecvLine(tcpConn)
      rp->_chunkState = CHK_SIZE
    ELSEIF rp->_chunkState = CHK_SIZE THEN
      ' Read hex chunk size line
      _HttpRecvLine(tcpConn)
      IF _lineOk = 0 THEN
        retVal = 0
        looping = 0
      ELSE
        rp->_chunkLeft = _HttpParseHex(_lineResult$)
        IF rp->_chunkLeft = 0 THEN
          ' Final zero-length chunk - consume trailing CRLF
          _HttpRecvLine(tcpConn)
          rp->_chunkState = CHK_DONE
          retVal = 0
          looping = 0
        ELSE
          rp->_chunkState = CHK_DATA
        END IF
      END IF
    ELSEIF rp->_chunkState = CHK_DATA THEN
      toRead = bufSz
      IF toRead > rp->_chunkLeft THEN
        toRead = rp->_chunkLeft
      END IF
      nRead = _HttpReadBuf(tcpConn, bufAddr, toRead)
      IF nRead <= 0 THEN
        retVal = 0
        looping = 0
      ELSE
        rp->_chunkLeft = rp->_chunkLeft - nRead
        IF rp->_chunkLeft = 0 THEN
          rp->_chunkState = CHK_TRAIL
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

SUB LONGINT HttpOpen(ADDRESS req, ADDRESS tcpConn, ~
                     STRING host$, LONGINT port, ~
                     LONGINT useSSL) EXTERNAL
  DECLARE STRUCT HttpRequest *r
  LONGINT rc

  _HttpInit

  rc = TcpOpen(tcpConn, host$, port, useSSL)

  ' Map tcpclient errors to HTTP error codes
  IF rc = TCP_ERR_DNS THEN
    HttpOpen = HTTP_ERR_DNS
    EXIT SUB
  ELSEIF rc = TCP_ERR_SSL THEN
    HttpOpen = HTTP_ERR_SSL_INIT
    EXIT SUB
  ELSEIF rc < 0 THEN
    HttpOpen = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  ' Store host/port in request struct
  r = req
  r->_reqHost = host$
  r->_reqPort = port
  r->_reqHdrCount = 0

  HttpOpen = HTTP_SUCCESS
END SUB

SUB HttpClose(ADDRESS tcpConn) EXTERNAL
  TcpClose(tcpConn)
END SUB

{ ============== Public API - Request Headers ============== }

SUB HttpClearReqHeaders(ADDRESS req) EXTERNAL
  DECLARE STRUCT HttpRequest *r
  LONGINT i, baseN, baseV
  r = req
  baseN = @r->_reqHdrNames
  baseV = @r->_reqHdrVals
  FOR i = 0 TO MAX_REQ_HDRS - 1
    POKE baseN + (i * 64), 0
    POKE baseV + (i * 256), 0
  NEXT i
  r->_reqHdrCount = 0
END SUB

SUB HttpSetHeader(ADDRESS req, STRING hdrNm$, ~
                  STRING hdrVl$) EXTERNAL
  DECLARE STRUCT HttpRequest *r
  LONGINT i, nameAddr, valAddr
  STRING upperNm$ SIZE 64
  STRING curNm$ SIZE 64

  r = req
  upperNm$ = UCASE$(hdrNm$)

  ' Overwrite if header already exists (case-insensitive)
  FOR i = 0 TO r->_reqHdrCount - 1
    nameAddr = @r->_reqHdrNames + (i * 64)
    curNm$ = CSTR(nameAddr)
    IF UCASE$(curNm$) = upperNm$ THEN
      valAddr = @r->_reqHdrVals + (i * 256)
      _StrToAddr(valAddr, hdrVl$, 256)
      EXIT SUB
    END IF
  NEXT i

  ' Add new header
  IF r->_reqHdrCount < MAX_REQ_HDRS THEN
    nameAddr = @r->_reqHdrNames + (r->_reqHdrCount * 64)
    _StrToAddr(nameAddr, hdrNm$, 64)
    valAddr = @r->_reqHdrVals + (r->_reqHdrCount * 256)
    _StrToAddr(valAddr, hdrVl$, 256)
    r->_reqHdrCount = r->_reqHdrCount + 1
  END IF
END SUB

SUB LONGINT HttpSendRequest(ADDRESS req, ADDRESS tcpConn, ~
                            STRING meth$, ~
                            STRING reqPath$) EXTERNAL
  DECLARE STRUCT HttpRequest *r
  SHARED _crlf$
  LONGINT i, rc, nameAddr, valAddr
  STRING curNm$ SIZE 64
  STRING curVl$ SIZE 256
  STRING hostStr$ SIZE 128

  r = req

  ' Request line: METHOD path HTTP/1.1\r\n
  rc = _HttpSendStr(tcpConn, meth$ + " " + reqPath$ + " HTTP/1.1" + _crlf$)
  IF rc < 0 THEN
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Host header (with port if non-standard)
  hostStr$ = CSTR(@r->_reqHost)
  IF r->_reqPort = 80 OR r->_reqPort = 443 THEN
    rc = _HttpSendStr(tcpConn, "Host: " + hostStr$ + _crlf$)
  ELSE
    rc = _HttpSendStr(tcpConn, ~
         FMT$("Host: %s:%ld", hostStr$, r->_reqPort) + _crlf$)
  END IF
  IF rc < 0 THEN
    r->_reqHdrCount = 0
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Custom request headers
  FOR i = 0 TO r->_reqHdrCount - 1
    nameAddr = @r->_reqHdrNames + (i * 64)
    valAddr = @r->_reqHdrVals + (i * 256)
    curNm$ = CSTR(nameAddr)
    curVl$ = CSTR(valAddr)
    rc = _HttpSendStr(tcpConn, curNm$ + ": " + curVl$ + _crlf$)
    IF rc < 0 THEN
      r->_reqHdrCount = 0
      HttpSendRequest = HTTP_ERR_SEND
      EXIT SUB
    END IF
  NEXT i

  ' Connection: close
  rc = _HttpSendStr(tcpConn, "Connection: close" + _crlf$)
  IF rc < 0 THEN
    r->_reqHdrCount = 0
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Blank line ends headers
  rc = _HttpSendStr(tcpConn, _crlf$)
  IF rc < 0 THEN
    r->_reqHdrCount = 0
    HttpSendRequest = HTTP_ERR_SEND
    EXIT SUB
  END IF

  ' Clear request headers for next use
  r->_reqHdrCount = 0

  HttpSendRequest = HTTP_SUCCESS
END SUB

{ ============== Public API - Response Reading ============== }

SUB LONGINT HttpReadStatus(ADDRESS tcpConn, ~
                           ADDRESS resp) EXTERNAL
  DECLARE STRUCT HttpResponse *rp
  SHARED _lineResult$, _lineOk
  LONGINT spPos, sc
  LONGINT colonPos, gotBlank
  STRING tmpNm$ SIZE 64
  STRING tmpVl$ SIZE 256
  LONGINT nameAddr, valAddr

  rp = resp

  ' Reset transfer state
  rp->_xfer = XFER_CLOSE
  rp->contentLen = 0
  rp->_bodyLeft = 0
  rp->_chunkState = CHK_SIZE
  rp->_chunkLeft = 0
  rp->respHdrCount = 0

  ' Flush any leftover buffered data in tcpclient
  TcpBufFlush(tcpConn)

  ' Read status line: "HTTP/1.x NNN reason"
  _HttpRecvLine(tcpConn)
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
  sc = CLNG(VAL(MID$(_lineResult$, spPos + 1, 3)))
  IF sc < 100 OR sc > 999 THEN
    HttpReadStatus = HTTP_ERR_PARSE
    EXIT SUB
  END IF

  rp->statusCode = sc

  ' Read headers until blank line
  gotBlank = 0

  WHILE gotBlank = 0
    _HttpRecvLine(tcpConn)
    IF _lineOk = 0 THEN
      gotBlank = 1
    ELSEIF LEN(_lineResult$) = 0 THEN
      gotBlank = 1
    ELSE
      ' Parse "Name: Value" (handle optional whitespace after colon)
      colonPos = INSTR(_lineResult$, ":")
      IF colonPos > 0 AND rp->respHdrCount < MAX_RSP_HDRS THEN
        tmpNm$ = LEFT$(_lineResult$, colonPos - 1)
        tmpVl$ = LTRIM$(MID$(_lineResult$, colonPos + 1))

        nameAddr = @rp->respHdrNames + (rp->respHdrCount * 64)
        _StrToAddr(nameAddr, tmpNm$, 64)
        valAddr = @rp->respHdrVals + (rp->respHdrCount * 256)
        _StrToAddr(valAddr, tmpVl$, 256)

        ' Detect Content-Length
        IF UCASE$(tmpNm$) = "CONTENT-LENGTH" THEN
          rp->contentLen = CLNG(VAL(tmpVl$))
          rp->_bodyLeft = rp->contentLen
          rp->_xfer = XFER_LENGTH
        END IF

        ' Detect Transfer-Encoding: chunked
        IF UCASE$(tmpNm$) = "TRANSFER-ENCODING" THEN
          IF INSTR(UCASE$(tmpVl$), "CHUNKED") > 0 THEN
            rp->_xfer = XFER_CHUNKED
          END IF
        END IF

        rp->respHdrCount = rp->respHdrCount + 1
      END IF
    END IF
  WEND

  HttpReadStatus = sc
END SUB

SUB STRING HttpGetResponseHeader(ADDRESS resp, ~
                                 STRING hdrNm$) EXTERNAL
  DECLARE STRUCT HttpResponse *rp
  LONGINT i, nameAddr, valAddr
  STRING upperNm$ SIZE 64
  STRING curNm$ SIZE 64

  rp = resp
  upperNm$ = UCASE$(hdrNm$)

  FOR i = 0 TO rp->respHdrCount - 1
    nameAddr = @rp->respHdrNames + (i * 64)
    curNm$ = CSTR(nameAddr)
    IF UCASE$(curNm$) = upperNm$ THEN
      valAddr = @rp->respHdrVals + (i * 256)
      HttpGetResponseHeader = CSTR(valAddr)
      EXIT SUB
    END IF
  NEXT i

  HttpGetResponseHeader = ""
END SUB

SUB LONGINT HttpResponseHeaderCount(ADDRESS resp) EXTERNAL
  DECLARE STRUCT HttpResponse *rp
  rp = resp
  HttpResponseHeaderCount = rp->respHdrCount
END SUB

SUB STRING HttpResponseHeaderName(ADDRESS resp, ~
                                  LONGINT idx) EXTERNAL
  DECLARE STRUCT HttpResponse *rp
  LONGINT nameAddr
  rp = resp
  IF idx < 0 OR idx >= rp->respHdrCount THEN
    HttpResponseHeaderName = ""
    EXIT SUB
  END IF
  nameAddr = @rp->respHdrNames + (idx * 64)
  HttpResponseHeaderName = CSTR(nameAddr)
END SUB

SUB STRING HttpResponseHeaderVal(ADDRESS resp, ~
                                 LONGINT idx) EXTERNAL
  DECLARE STRUCT HttpResponse *rp
  LONGINT valAddr
  rp = resp
  IF idx < 0 OR idx >= rp->respHdrCount THEN
    HttpResponseHeaderVal = ""
    EXIT SUB
  END IF
  valAddr = @rp->respHdrVals + (idx * 256)
  HttpResponseHeaderVal = CSTR(valAddr)
END SUB

SUB LONGINT HttpReadBody(ADDRESS tcpConn, ADDRESS resp, ~
                         ADDRESS dataBuf, ~
                         LONGINT bufSz) EXTERNAL
  DECLARE STRUCT HttpResponse *rp
  LONGINT toRead, totalRd

  rp = resp

  ' Chunked mode - use chunk decoder
  IF rp->_xfer = XFER_CHUNKED THEN
    HttpReadBody = _HttpReadChunked(tcpConn, resp, dataBuf, bufSz)
    EXIT SUB
  END IF

  ' Determine how much to read
  IF rp->_xfer = XFER_LENGTH THEN
    IF rp->_bodyLeft <= 0 THEN
      HttpReadBody = 0
      EXIT SUB
    END IF
    toRead = bufSz
    IF toRead > rp->_bodyLeft THEN
      toRead = rp->_bodyLeft
    END IF
  ELSE
    toRead = bufSz
  END IF

  ' Read via tcpclient buffered reader
  totalRd = TcpRecvBuf(tcpConn, dataBuf, toRead)

  IF totalRd <= 0 THEN
    IF rp->_xfer = XFER_CLOSE THEN
      HttpReadBody = 0
    ELSE
      HttpReadBody = HTTP_ERR_RECV
    END IF
    EXIT SUB
  END IF

  ' Update remaining body length for Content-Length mode
  IF rp->_xfer = XFER_LENGTH THEN
    rp->_bodyLeft = rp->_bodyLeft - totalRd
  END IF

  HttpReadBody = totalRd
END SUB

{ ============== Public API - Request Body Write ============== }

SUB LONGINT HttpWriteBody(ADDRESS tcpConn, ADDRESS dataBuf, ~
                          LONGINT bodyLen) EXTERNAL
  LONGINT rc

  rc = _HttpSendRaw(tcpConn, dataBuf, bodyLen)
  IF rc < 0 THEN
    HttpWriteBody = HTTP_ERR_SEND
  ELSE
    HttpWriteBody = HTTP_SUCCESS
  END IF
END SUB

SUB LONGINT HttpWriteBodyChunked(ADDRESS tcpConn, ~
                                 ADDRESS dataBuf, ~
                                 LONGINT bodyLen) EXTERNAL
  SHARED _crlf$
  LONGINT rc

  IF bodyLen = 0 THEN
    ' Final chunk terminator: "0\r\n\r\n"
    rc = _HttpSendStr(tcpConn, "0" + _crlf$ + _crlf$)
    IF rc < 0 THEN
      HttpWriteBodyChunked = HTTP_ERR_SEND
    ELSE
      HttpWriteBodyChunked = HTTP_SUCCESS
    END IF
    EXIT SUB
  END IF

  ' Send chunk: hex(len) + CRLF + data + CRLF
  rc = _HttpSendStr(tcpConn, _HttpLongToHex(bodyLen) + _crlf$)
  IF rc < 0 THEN
    HttpWriteBodyChunked = HTTP_ERR_SEND
    EXIT SUB
  END IF

  rc = _HttpSendRaw(tcpConn, dataBuf, bodyLen)
  IF rc < 0 THEN
    HttpWriteBodyChunked = HTTP_ERR_SEND
    EXIT SUB
  END IF

  rc = _HttpSendStr(tcpConn, _crlf$)
  IF rc < 0 THEN
    HttpWriteBodyChunked = HTTP_ERR_SEND
  ELSE
    HttpWriteBodyChunked = HTTP_SUCCESS
  END IF
END SUB

{ ============== Public API - Utility ============== }

SUB STRING UrlEncode(STRING raw$) EXTERNAL
  STRING result$ SIZE 1024
  LONGINT i, c

  result$ = ""

  FOR i = 1 TO LEN(raw$)
    c = ASC(MID$(raw$, i, 1))
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

SUB LONGINT HttpGet(ADDRESS req, ADDRESS resp, ~
                    ADDRESS tcpConn, STRING url$, ~
                    ADDRESS respBuf, LONGINT bufSz) EXTERNAL
  DECLARE STRUCT UrlParts urlP
  LONGINT rc, sc
  LONGINT totalLen, bytesGot, rdDone

  _HttpParseUrl(url$, urlP)
  IF LEN(CSTR(@urlP->host)) = 0 THEN
    HttpGet = HTTP_ERR_PARSE
    EXIT SUB
  END IF

  rc = HttpOpen(req, tcpConn, CSTR(@urlP->host), urlP->port, urlP->ssl)
  IF rc <> HTTP_SUCCESS THEN
    HttpGet = rc
    EXIT SUB
  END IF

  rc = HttpSendRequest(req, tcpConn, "GET", CSTR(@urlP->path))
  IF rc < 0 THEN
    HttpClose(tcpConn)
    HttpGet = rc
    EXIT SUB
  END IF

  sc = HttpReadStatus(tcpConn, resp)
  IF sc < 0 THEN
    HttpClose(tcpConn)
    HttpGet = sc
    EXIT SUB
  END IF

  ' Read body directly into caller's buffer (reserve 1 byte for null)
  totalLen = 0
  rdDone = 0
  WHILE rdDone = 0
    bytesGot = HttpReadBody(tcpConn, resp, respBuf + totalLen, ~
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

  HttpClose(tcpConn)
  HttpGet = sc
END SUB

SUB LONGINT HttpHead(ADDRESS req, ADDRESS resp, ~
                     ADDRESS tcpConn, STRING url$) EXTERNAL
  DECLARE STRUCT UrlParts urlP
  LONGINT rc, sc

  _HttpParseUrl(url$, urlP)
  IF LEN(CSTR(@urlP->host)) = 0 THEN
    HttpHead = HTTP_ERR_PARSE
    EXIT SUB
  END IF

  rc = HttpOpen(req, tcpConn, CSTR(@urlP->host), urlP->port, urlP->ssl)
  IF rc <> HTTP_SUCCESS THEN
    HttpHead = rc
    EXIT SUB
  END IF

  rc = HttpSendRequest(req, tcpConn, "HEAD", CSTR(@urlP->path))
  IF rc < 0 THEN
    HttpClose(tcpConn)
    HttpHead = rc
    EXIT SUB
  END IF

  sc = HttpReadStatus(tcpConn, resp)
  HttpClose(tcpConn)
  HttpHead = sc
END SUB

SUB LONGINT HttpRequest(ADDRESS req, ADDRESS resp, ~
                        ADDRESS tcpConn, STRING url$, ~
                        STRING meth$, STRING ct$, ~
                        STRING body$, ADDRESS respBuf, ~
                        LONGINT bufSz) EXTERNAL
  DECLARE STRUCT UrlParts urlP
  LONGINT rc, sc
  LONGINT totalLen, bytesGot, rdDone
  LONGINT hasBody

  _HttpParseUrl(url$, urlP)
  IF LEN(CSTR(@urlP->host)) = 0 THEN
    HttpRequest = HTTP_ERR_PARSE
    EXIT SUB
  END IF

  rc = HttpOpen(req, tcpConn, CSTR(@urlP->host), urlP->port, urlP->ssl)
  IF rc <> HTTP_SUCCESS THEN
    HttpRequest = rc
    EXIT SUB
  END IF

  ' Determine if this method sends a body
  hasBody = 0
  IF meth$ <> "GET" AND meth$ <> "HEAD" AND meth$ <> "DELETE" THEN
    IF LEN(body$) > 0 THEN
      hasBody = 1
    END IF
  END IF

  ' Set Content-Type and Content-Length for body-bearing requests
  IF hasBody THEN
    IF LEN(ct$) > 0 THEN
      HttpSetHeader(req, "Content-Type", ct$)
    END IF
    HttpSetHeader(req, "Content-Length", FMT$("%ld", LEN(body$)))
  END IF

  rc = HttpSendRequest(req, tcpConn, meth$, CSTR(@urlP->path))
  IF rc < 0 THEN
    HttpClose(tcpConn)
    HttpRequest = rc
    EXIT SUB
  END IF

  ' Send body if present
  IF hasBody THEN
    rc = HttpWriteBody(tcpConn, SADD(body$), LEN(body$))
    IF rc < 0 THEN
      HttpClose(tcpConn)
      HttpRequest = rc
      EXIT SUB
    END IF
  END IF

  sc = HttpReadStatus(tcpConn, resp)
  IF sc < 0 THEN
    HttpClose(tcpConn)
    HttpRequest = sc
    EXIT SUB
  END IF

  ' Read response body (unless HEAD)
  IF meth$ <> "HEAD" THEN
    totalLen = 0
    rdDone = 0
    WHILE rdDone = 0
      bytesGot = HttpReadBody(tcpConn, resp, respBuf + totalLen, ~
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

  HttpClose(tcpConn)
  HttpRequest = sc
END SUB

SUB LONGINT HttpPost(ADDRESS req, ADDRESS resp, ~
                     ADDRESS tcpConn, STRING url$, ~
                     STRING ct$, STRING body$, ~
                     ADDRESS respBuf, ~
                     LONGINT bufSz) EXTERNAL
  HttpPost = HttpRequest(req, resp, tcpConn, url$, ~
                         "POST", ct$, body$, respBuf, bufSz)
END SUB

SUB LONGINT HttpPut(ADDRESS req, ADDRESS resp, ~
                    ADDRESS tcpConn, STRING url$, ~
                    STRING ct$, STRING body$, ~
                    ADDRESS respBuf, ~
                    LONGINT bufSz) EXTERNAL
  HttpPut = HttpRequest(req, resp, tcpConn, url$, ~
                        "PUT", ct$, body$, respBuf, bufSz)
END SUB

{ ============== Public API - Streaming ============== }

SUB LONGINT HttpRequestStream(ADDRESS req, ADDRESS resp, ~
                              ADDRESS tcpConn, STRING url$, ~
                              STRING meth$, STRING ct$, ~
                              ADDRESS onSend, ~
                              ADDRESS onRecv) EXTERNAL
  DECLARE STRUCT UrlParts urlP
  SHARED _crlf$
  LONGINT rc, sc
  LONGINT hasBody, sendLen, bytesGot, cbRet
  LONGINT rdDone
  STRING sBuf$ SIZE 4096
  ADDRESS sBufAddr

  sBufAddr = @sBuf$

  _HttpParseUrl(url$, urlP)
  IF LEN(CSTR(@urlP->host)) = 0 THEN
    HttpRequestStream = HTTP_ERR_PARSE
    EXIT SUB
  END IF

  rc = HttpOpen(req, tcpConn, CSTR(@urlP->host), urlP->port, urlP->ssl)
  IF rc <> HTTP_SUCCESS THEN
    HttpRequestStream = rc
    EXIT SUB
  END IF

  ' Determine if this method sends a body
  hasBody = 0
  IF meth$ <> "GET" AND meth$ <> "HEAD" AND meth$ <> "DELETE" THEN
    IF onSend <> 0 THEN
      hasBody = 1
    END IF
  END IF

  ' Set up headers for body-bearing requests with chunked encoding
  IF hasBody THEN
    IF LEN(ct$) > 0 THEN
      HttpSetHeader(req, "Content-Type", ct$)
    END IF
    HttpSetHeader(req, "Transfer-Encoding", "chunked")
  END IF

  rc = HttpSendRequest(req, tcpConn, meth$, CSTR(@urlP->path))
  IF rc < 0 THEN
    HttpClose(tcpConn)
    HttpRequestStream = rc
    EXIT SUB
  END IF

  ' Send body via callback in chunked mode
  IF hasBody THEN
    sendLen = 1
    WHILE sendLen > 0
      sendLen = INVOKE onSend(sBufAddr, READ_BUF_SIZE)
      IF sendLen > 0 THEN
        rc = HttpWriteBodyChunked(tcpConn, sBufAddr, sendLen)
        IF rc < 0 THEN
          HttpClose(tcpConn)
          HttpRequestStream = HTTP_ERR_SEND
          EXIT SUB
        END IF
      END IF
    WEND
    ' Send final zero-length chunk
    rc = HttpWriteBodyChunked(tcpConn, sBufAddr, 0)
    IF rc < 0 THEN
      HttpClose(tcpConn)
      HttpRequestStream = HTTP_ERR_SEND
      EXIT SUB
    END IF
  END IF

  sc = HttpReadStatus(tcpConn, resp)
  IF sc < 0 THEN
    HttpClose(tcpConn)
    HttpRequestStream = sc
    EXIT SUB
  END IF

  ' Read response body via callback (unless HEAD or no callback)
  IF meth$ <> "HEAD" AND onRecv <> 0 THEN
    rdDone = 0
    WHILE rdDone = 0
      bytesGot = HttpReadBody(tcpConn, resp, sBufAddr, READ_BUF_SIZE)
      IF bytesGot > 0 THEN
        cbRet = INVOKE onRecv(sBufAddr, bytesGot)
        IF cbRet = HTTP_ABORT THEN
          HttpClose(tcpConn)
          HttpRequestStream = HTTP_ERR_CALLBACK
          EXIT SUB
        END IF
      ELSE
        rdDone = 1
      END IF
    WEND
  END IF

  HttpClose(tcpConn)
  HttpRequestStream = sc
END SUB

SUB LONGINT HttpGetStream(ADDRESS req, ADDRESS resp, ~
                          ADDRESS tcpConn, STRING url$, ~
                          ADDRESS onRecv) EXTERNAL
  HttpGetStream = HttpRequestStream(req, resp, tcpConn, ~
                                    url$, "GET", "", 0&, onRecv)
END SUB

SUB LONGINT HttpPostStream(ADDRESS req, ADDRESS resp, ~
                           ADDRESS tcpConn, STRING url$, ~
                           STRING ct$, ADDRESS onSend, ~
                           ADDRESS onRecv) EXTERNAL
  HttpPostStream = HttpRequestStream(req, resp, tcpConn, ~
                                     url$, "POST", ct$, ~
                                     onSend, onRecv)
END SUB

SUB LONGINT HttpPutStream(ADDRESS req, ADDRESS resp, ~
                          ADDRESS tcpConn, STRING url$, ~
                          STRING ct$, ADDRESS onSend, ~
                          ADDRESS onRecv) EXTERNAL
  HttpPutStream = HttpRequestStream(req, resp, tcpConn, ~
                                    url$, "PUT", ct$, ~
                                    onSend, onRecv)
END SUB
