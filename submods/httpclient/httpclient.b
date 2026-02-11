{* HTTPClient - HTTP/1.1 client submodule for ACE BASIC *}
{* Phase 1: TCP foundation - socket, DNS, connect, send, recv, close *}

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

{ ============== Connection Table ============== }

DIM connSocket&(3)    ' socket FD (-1 = unused)
DIM connState%(3)     ' CONN_FREE or CONN_OPEN
DIM connSSL&(3)       ' SSL pointer (0 = plain) [Phase 6]
LONGINT _httpInited   ' 0 = not initialized

{ ============== Init ============== }

SUB _HttpInit
  SHARED connSocket&, connState%, connSSL&, _httpInited
  LONGINT i

  IF _httpInited = 1 THEN EXIT SUB

  LIBRARY "bsdsocket.library"

  FOR i = 0 TO 3
    connSocket&(i) = -1
    connState%(i) = CONN_FREE
    connSSL&(i) = 0
  NEXT i

  _httpInited = 1
END SUB

{ ============== Internal Helpers ============== }

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
  addrList = PEEKL(he + 16)   ' h_addr_list
  addrPtr = PEEKL(addrList)    ' h_addr_list[0]
  ipAddr = PEEKL(addrPtr)      ' actual 4-byte IP
  _HttpResolve = ipAddr
END SUB

SUB LONGINT _HttpConnectTCP(LONGINT ipAddr, LONGINT port)
  LONGINT sock, rc
  ADDRESS sa

  ' Create socket
  sock = socket(AF_INET, SOCK_STREAM, 0)
  IF sock < 0 THEN
    _HttpConnectTCP = -1
    EXIT SUB
  END IF

  ' Build sockaddr_in (16 bytes, cleared by ALLOC)
  sa = ALLOC(16)
  POKE sa, 16            ' sin_len
  POKE sa + 1, 2         ' sin_family = AF_INET
  POKEW sa + 2, port     ' sin_port (big-endian = network order on 68k)
  POKEL sa + 4, ipAddr   ' sin_addr

  ' Connect
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

{ ============== Public API - Core ============== }

SUB LONGINT HttpOpen(STRING host, LONGINT port, LONGINT useSSL) EXTERNAL
  SHARED connSocket&, connState%
  LONGINT slot, ipAddr, sock

  _HttpInit

  ' Allocate connection slot
  slot = _HttpAllocSlot
  IF slot < 0 THEN
    HttpOpen = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  ' Resolve hostname
  ipAddr = _HttpResolve(host)
  IF ipAddr = 0 THEN
    HttpOpen = HTTP_ERR_DNS
    EXIT SUB
  END IF

  ' TCP connect
  sock = _HttpConnectTCP(ipAddr, port)
  IF sock < 0 THEN
    HttpOpen = HTTP_ERR_SOCKET
    EXIT SUB
  END IF

  ' Store in table
  connSocket&(slot) = sock
  connState%(slot) = CONN_OPEN

  ' Return 1-based handle (positive = success)
  HttpOpen = slot + 1
END SUB

SUB HttpClose(LONGINT hConn) EXTERNAL
  SHARED connSocket&, connState%
  LONGINT slot

  slot = hConn - 1
  IF slot < 0 OR slot > 3 THEN EXIT SUB
  IF connState%(slot) = CONN_FREE THEN EXIT SUB

  CloseSocket(connSocket&(slot))
  connSocket&(slot) = -1
  connState%(slot) = CONN_FREE
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

SUB LONGINT HttpRecvRawBytes(LONGINT hConn, ADDRESS buf, LONGINT bufSize) EXTERNAL
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

  HttpRecvRawBytes = recv(connSocket&(slot), buf, bufSize, 0)
END SUB

{ ============== Stubs - High-level convenience API ============== }

SUB LONGINT HttpGet(STRING url, STRING resp) EXTERNAL
  HttpGet = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpHead(STRING url) EXTERNAL
  HttpHead = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpPost(STRING url, STRING ct, ~
                     STRING body, STRING resp) EXTERNAL
  HttpPost = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpPut(STRING url, STRING ct, ~
                    STRING body, STRING resp) EXTERNAL
  HttpPut = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpRequest(STRING url, STRING meth, ~
                        STRING ct, STRING body, ~
                        STRING resp) EXTERNAL
  HttpRequest = HTTP_ERR_SOCKET
END SUB

{ ============== Stubs - Streaming API ============== }

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

{ ============== Stubs - Low-level handle API ============== }

SUB HttpSetHeader(LONGINT h, STRING hdrName, STRING hdrVal) EXTERNAL
  REM stub
END SUB

SUB LONGINT HttpSendRequest(LONGINT h, STRING meth, ~
                            STRING path) EXTERNAL
  HttpSendRequest = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpWriteBody(LONGINT h, LONGINT dataBuf, ~
                          LONGINT bodyLen) EXTERNAL
  HttpWriteBody = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpWriteBodyChunked(LONGINT h, LONGINT dataBuf, ~
                                 LONGINT bodyLen) EXTERNAL
  HttpWriteBodyChunked = HTTP_ERR_SOCKET
END SUB

SUB LONGINT HttpReadStatus(LONGINT h) EXTERNAL
  HttpReadStatus = HTTP_ERR_SOCKET
END SUB

SUB STRING HttpGetResponseHeader(LONGINT h, STRING hdrName) EXTERNAL
  HttpGetResponseHeader = ""
END SUB

SUB LONGINT HttpReadBody(LONGINT h, LONGINT dataBuf, ~
                         LONGINT bufSize, LONGINT bytesRead) EXTERNAL
  HttpReadBody = HTTP_ERR_SOCKET
END SUB

{ ============== Stubs - Utility ============== }

SUB STRING UrlEncode(STRING raw) EXTERNAL
  UrlEncode = raw
END SUB
