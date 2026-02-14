REM #using ace:submods/amissl/amissl.o

{* TCPClient - TCP connection submodule for ACE BASIC *}
{* Multi-connection model with optional SSL via amissl submodule *}

#include <submods/amissl.h>

{ ============== Library Declarations ============== }

DECLARE FUNCTION socket& LIBRARY bsdsocket
DECLARE FUNCTION connect& LIBRARY bsdsocket
DECLARE FUNCTION send& LIBRARY bsdsocket
DECLARE FUNCTION recv& LIBRARY bsdsocket
DECLARE FUNCTION CloseSocket& LIBRARY bsdsocket
DECLARE FUNCTION gethostbyname& LIBRARY bsdsocket
DECLARE FUNCTION inet_addr& LIBRARY bsdsocket

{ ============== Constants ============== }

CONST TCP_SUCCESS        = 0
CONST TCP_ERR_SOCKET     = -1
CONST TCP_ERR_DNS        = -2
CONST TCP_ERR_SEND       = -3
CONST TCP_ERR_RECV       = -4
CONST TCP_ERR_SSL        = -5
CONST TCP_ERR_NO_SLOT    = -6
CONST TCP_ERR_BAD_HANDLE = -7

CONST MAX_TCP_CONNS  = 4
CONST TCP_BUF_SIZE   = 4096
CONST TCP_LINE_MAX   = 1024

' Socket constants
CONST AF_INET        = 2
CONST SOCK_STREAM    = 1

{ ============== Module Data ============== }

LONGINT _tcpInited

' Connection table (indices 1..MAX_TCP_CONNS, 0 unused)
DIM _tcpSockFd&(4)
DIM _tcpSslHnd&(4)
DIM _tcpBufPtr&(4)
DIM _tcpBufPos&(4)
DIM _tcpBufLen&(4)

' Reusable sockaddr_in buffer (16 bytes)
ADDRESS _tcpSockAddr

' BSD socket library base (for SSL init)
LONGINT _bsdSockBase

' SSL initialized flag
LONGINT _tcpSslReady

{ ============== Internal Helpers ============== }

SUB LONGINT _TcpValidHandle(LONGINT h)
  SHARED _tcpSockFd&
  IF h < 1 OR h > MAX_TCP_CONNS THEN
    _TcpValidHandle = 0
  ELSEIF _tcpSockFd&(h) = -1 THEN
    _TcpValidHandle = 0
  ELSE
    _TcpValidHandle = 1
  END IF
END SUB

SUB LONGINT _TcpFindSlot
  SHARED _tcpSockFd&
  LONGINT i
  FOR i = 1 TO MAX_TCP_CONNS
    IF _tcpSockFd&(i) = -1 THEN
      _TcpFindSlot = i
      EXIT SUB
    END IF
  NEXT i
  _TcpFindSlot = 0
END SUB

SUB LONGINT _TcpResolve(STRING host$)
  LONGINT he, addrList, addrPtr, ipAddr

  ' Try as dotted IP first
  ipAddr = inet_addr(SADD(host$))
  IF ipAddr <> -1 THEN
    _TcpResolve = ipAddr
    EXIT SUB
  END IF

  ' DNS lookup
  he = gethostbyname(SADD(host$))
  IF he = 0 THEN
    _TcpResolve = 0
    EXIT SUB
  END IF

  ' hostent: h_addr_list is at offset 16
  addrList = PEEKL(he + 16)
  addrPtr = PEEKL(addrList)
  ipAddr = PEEKL(addrPtr)
  _TcpResolve = ipAddr
END SUB

SUB LONGINT _TcpDoConnect(LONGINT ipAddr, LONGINT port)
  SHARED _tcpSockAddr
  LONGINT sock, rc

  sock = socket(AF_INET, SOCK_STREAM, 0)
  IF sock < 0 THEN
    _TcpDoConnect = -1
    EXIT SUB
  END IF

  POKE _tcpSockAddr, 16
  POKE _tcpSockAddr + 1, 2
  POKEW _tcpSockAddr + 2, port
  POKEL _tcpSockAddr + 4, ipAddr

  rc = connect(sock, _tcpSockAddr, 16)
  IF rc < 0 THEN
    CloseSocket(sock)
    _TcpDoConnect = -1
    EXIT SUB
  END IF

  _TcpDoConnect = sock
END SUB

{ ============== Public API ============== }

SUB LONGINT TcpInit EXTERNAL
  SHARED _tcpInited
  SHARED _tcpSockFd&, _tcpSslHnd&, _tcpBufPtr&, _tcpBufPos&, _tcpBufLen&
  SHARED _tcpSockAddr, _bsdSockBase, _tcpSslReady
  LONGINT i

  IF _tcpInited = 1 THEN
    TcpInit = TCP_SUCCESS
    EXIT SUB
  END IF

  LIBRARY "bsdsocket.library"

  ' Read _BSDSOCKETBase into module variable for later SSL init
  ASSEM
    move.l  _BSDSOCKETBase,_modv__BSDSOCKBASE
  END ASSEM

  ' Init connection table
  FOR i = 1 TO MAX_TCP_CONNS
    _tcpSockFd&(i) = -1
    _tcpSslHnd&(i) = 0
    _tcpBufPtr&(i) = ALLOC(TCP_BUF_SIZE)
    _tcpBufPos&(i) = 0
    _tcpBufLen&(i) = 0
  NEXT i

  ' Allocate sockaddr buffer
  _tcpSockAddr = ALLOC(16)

  _tcpSslReady = 0
  _tcpInited = 1
  TcpInit = TCP_SUCCESS
END SUB

SUB TcpCleanup EXTERNAL
  SHARED _tcpInited
  SHARED _tcpSockFd&, _tcpSslHnd&
  SHARED _tcpSslReady
  LONGINT i

  IF _tcpInited <> 1 THEN EXIT SUB

  FOR i = 1 TO MAX_TCP_CONNS
    IF _tcpSockFd&(i) <> -1 THEN
      IF _tcpSslHnd&(i) <> 0 THEN
        SslFreeConn(_tcpSslHnd&(i))
        _tcpSslHnd&(i) = 0
      END IF
      CloseSocket(_tcpSockFd&(i))
      _tcpSockFd&(i) = -1
    END IF
  NEXT i

  IF _tcpSslReady = 1 THEN
    SslCleanup
    _tcpSslReady = 0
  END IF

  _tcpInited = 0
END SUB

SUB LONGINT TcpOpen(STRING host$, LONGINT port, LONGINT useSSL) EXTERNAL
  SHARED _tcpSockFd&, _tcpSslHnd&, _tcpBufPos&, _tcpBufLen&
  SHARED _bsdSockBase, _tcpSslReady
  LONGINT h, ipAddr, sock, ssl, rc

  ' Auto-init
  rc = TcpInit
  IF rc <> TCP_SUCCESS THEN
    TcpOpen = rc
    EXIT SUB
  END IF

  ' Find free slot
  h = _TcpFindSlot
  IF h = 0 THEN
    TcpOpen = TCP_ERR_NO_SLOT
    EXIT SUB
  END IF

  ' DNS resolve
  ipAddr = _TcpResolve(host$)
  IF ipAddr = 0 THEN
    TcpOpen = TCP_ERR_DNS
    EXIT SUB
  END IF

  ' TCP connect
  sock = _TcpDoConnect(ipAddr, port)
  IF sock < 0 THEN
    TcpOpen = TCP_ERR_SOCKET
    EXIT SUB
  END IF

  ' Optional SSL handshake
  IF useSSL = 1 THEN
    ' Lazy SSL init
    IF _tcpSslReady = 0 THEN
      rc = SslInit(_bsdSockBase)
      IF rc < 0 THEN
        CloseSocket(sock)
        TcpOpen = TCP_ERR_SSL
        EXIT SUB
      END IF
      _tcpSslReady = 1
    END IF

    ssl = SslNewConn(sock)
    IF ssl = 0 THEN
      CloseSocket(sock)
      TcpOpen = TCP_ERR_SSL
      EXIT SUB
    END IF
  ELSE
    ssl = 0
  END IF

  ' Store in connection table
  _tcpSockFd&(h) = sock
  _tcpSslHnd&(h) = ssl
  _tcpBufPos&(h) = 0
  _tcpBufLen&(h) = 0

  TcpOpen = h
END SUB

SUB TcpClose(LONGINT h) EXTERNAL
  SHARED _tcpSockFd&, _tcpSslHnd&, _tcpBufPos&, _tcpBufLen&

  IF _TcpValidHandle(h) = 0 THEN EXIT SUB

  IF _tcpSslHnd&(h) <> 0 THEN
    SslFreeConn(_tcpSslHnd&(h))
    _tcpSslHnd&(h) = 0
  END IF

  CloseSocket(_tcpSockFd&(h))
  _tcpSockFd&(h) = -1
  _tcpBufPos&(h) = 0
  _tcpBufLen&(h) = 0
END SUB

SUB LONGINT TcpSend(LONGINT h, ADDRESS buf, LONGINT bufLen) EXTERNAL
  SHARED _tcpSockFd&, _tcpSslHnd&

  IF _TcpValidHandle(h) = 0 THEN
    TcpSend = TCP_ERR_BAD_HANDLE
    EXIT SUB
  END IF

  IF _tcpSslHnd&(h) <> 0 THEN
    TcpSend = SslWrite(_tcpSslHnd&(h), buf, bufLen)
  ELSE
    TcpSend = send(_tcpSockFd&(h), buf, bufLen, 0)
  END IF
END SUB

SUB LONGINT TcpRecv(LONGINT h, ADDRESS buf, LONGINT bufSz) EXTERNAL
  SHARED _tcpSockFd&, _tcpSslHnd&

  IF _TcpValidHandle(h) = 0 THEN
    TcpRecv = TCP_ERR_BAD_HANDLE
    EXIT SUB
  END IF

  IF _tcpSslHnd&(h) <> 0 THEN
    TcpRecv = SslRead(_tcpSslHnd&(h), buf, bufSz)
  ELSE
    TcpRecv = recv(_tcpSockFd&(h), buf, bufSz, 0)
  END IF
END SUB

SUB LONGINT TcpRecvBuf(LONGINT h, ADDRESS destBuf, ~
                        LONGINT maxBytes) EXTERNAL
  SHARED _tcpSockFd&, _tcpSslHnd&
  SHARED _tcpBufPtr&, _tcpBufPos&, _tcpBufLen&
  LONGINT avail, n, i, bufAddr

  IF _TcpValidHandle(h) = 0 THEN
    TcpRecvBuf = TCP_ERR_BAD_HANDLE
    EXIT SUB
  END IF

  IF maxBytes <= 0 THEN
    TcpRecvBuf = 0
    EXIT SUB
  END IF

  bufAddr = _tcpBufPtr&(h)

  ' If buffer has data, drain up to maxBytes
  IF _tcpBufPos&(h) < _tcpBufLen&(h) THEN
    avail = _tcpBufLen&(h) - _tcpBufPos&(h)
    IF avail > maxBytes THEN avail = maxBytes
    FOR i = 0 TO avail - 1
      POKE destBuf + i, PEEK(bufAddr + _tcpBufPos&(h) + i)
    NEXT i
    _tcpBufPos&(h) = _tcpBufPos&(h) + avail
    TcpRecvBuf = avail
    EXIT SUB
  END IF

  ' Buffer empty - refill from socket
  _tcpBufPos&(h) = 0
  _tcpBufLen&(h) = 0

  IF _tcpSslHnd&(h) <> 0 THEN
    n = SslRead(_tcpSslHnd&(h), bufAddr, TCP_BUF_SIZE)
  ELSE
    n = recv(_tcpSockFd&(h), bufAddr, TCP_BUF_SIZE, 0)
  END IF

  IF n <= 0 THEN
    TcpRecvBuf = 0
    EXIT SUB
  END IF
  _tcpBufLen&(h) = n

  ' Copy up to maxBytes from freshly filled buffer
  avail = n
  IF avail > maxBytes THEN avail = maxBytes
  FOR i = 0 TO avail - 1
    POKE destBuf + i, PEEK(bufAddr + i)
  NEXT i
  _tcpBufPos&(h) = avail
  TcpRecvBuf = avail
END SUB

SUB LONGINT TcpRecvLine(LONGINT h, ADDRESS lineBuf, ~
                         LONGINT maxLen) EXTERNAL
  SHARED _tcpSockFd&, _tcpSslHnd&
  SHARED _tcpBufPtr&, _tcpBufPos&, _tcpBufLen&
  LONGINT resultLen, found, lineErr
  LONGINT scanPos, gotLF, copyEnd, n, i
  LONGINT bufAddr

  IF _TcpValidHandle(h) = 0 THEN
    TcpRecvLine = -1
    EXIT SUB
  END IF

  bufAddr = _tcpBufPtr&(h)
  resultLen = 0
  found = 0
  lineErr = 0

  WHILE found = 0 AND lineErr = 0
    ' Refill buffer if empty
    IF _tcpBufPos&(h) >= _tcpBufLen&(h) THEN
      _tcpBufPos&(h) = 0
      _tcpBufLen&(h) = 0
      IF _tcpSslHnd&(h) <> 0 THEN
        n = SslRead(_tcpSslHnd&(h), bufAddr, TCP_BUF_SIZE)
      ELSE
        n = recv(_tcpSockFd&(h), bufAddr, TCP_BUF_SIZE, 0)
      END IF
      IF n <= 0 THEN
        lineErr = 1
      ELSE
        _tcpBufLen&(h) = n
      END IF
    END IF

    IF lineErr = 0 THEN
      ' Scan for LF (byte 10)
      scanPos = _tcpBufPos&(h)
      gotLF = 0
      WHILE scanPos < _tcpBufLen&(h) AND gotLF = 0
        IF PEEK(bufAddr + scanPos) = 10 THEN
          gotLF = 1
        ELSE
          scanPos = scanPos + 1
        END IF
      WEND

      IF gotLF = 1 THEN
        ' Found LF: copy bytes before it (strip CR if present)
        copyEnd = scanPos
        IF copyEnd > _tcpBufPos&(h) THEN
          IF PEEK(bufAddr + copyEnd - 1) = 13 THEN
            copyEnd = copyEnd - 1
          END IF
        END IF
        FOR i = _tcpBufPos&(h) TO copyEnd - 1
          IF resultLen < maxLen THEN
            POKE lineBuf + resultLen, PEEK(bufAddr + i)
            resultLen = resultLen + 1
          END IF
        NEXT i
        _tcpBufPos&(h) = scanPos + 1
        found = 1
      ELSE
        ' No LF yet: copy all remaining buffer bytes
        FOR i = _tcpBufPos&(h) TO _tcpBufLen&(h) - 1
          IF resultLen < maxLen THEN
            POKE lineBuf + resultLen, PEEK(bufAddr + i)
            resultLen = resultLen + 1
          END IF
        NEXT i
        _tcpBufPos&(h) = _tcpBufLen&(h)
      END IF
    END IF
  WEND

  ' Null-terminate
  POKE lineBuf + resultLen, 0

  IF lineErr THEN
    TcpRecvLine = -1
  ELSE
    TcpRecvLine = resultLen
  END IF
END SUB

SUB TcpBufFlush(LONGINT h) EXTERNAL
  SHARED _tcpBufPos&, _tcpBufLen&

  IF _TcpValidHandle(h) = 0 THEN EXIT SUB

  _tcpBufPos&(h) = 0
  _tcpBufLen&(h) = 0
END SUB
