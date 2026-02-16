REM #using ace:submods/amissl/amissl.o

{* TCPClient - TCP connection submodule for ACE BASIC *}
{* Stateless struct-based API - caller owns TcpConn structs *}

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
CONST TCP_ERR_BAD_HANDLE = -7

CONST TCP_BUF_SIZE   = 4096
CONST TCP_LINE_MAX   = 1024

' Socket constants
CONST AF_INET        = 2
CONST SOCK_STREAM    = 1

{ ============== TcpConn Struct ============== }

STRUCT TcpConn
  LONGINT _sockFd
  LONGINT _sslHnd
  LONGINT _bufPos
  LONGINT _bufLen
  BYTE _bufData SIZE 4096
END STRUCT

{ ============== Module Data ============== }

LONGINT _tcpInited

' BSD socket library base (for SSL init)
LONGINT _bsdSockBase

' SSL initialized flag
LONGINT _tcpSslReady

{ ============== Internal Helpers ============== }

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
  LONGINT sock, rc
  STRING sockAddr$ SIZE 16
  ADDRESS sa

  sock = socket(AF_INET, SOCK_STREAM, 0)
  IF sock < 0 THEN
    _TcpDoConnect = -1
    EXIT SUB
  END IF

  sa = @sockAddr$
  POKE sa, 16
  POKE sa + 1, 2
  POKEW sa + 2, port
  POKEL sa + 4, ipAddr

  rc = connect(sock, sa, 16)
  IF rc < 0 THEN
    CloseSocket(sock)
    _TcpDoConnect = -1
    EXIT SUB
  END IF

  _TcpDoConnect = sock
END SUB

' _TcpFillBuf - Ensure internal buffer has data
'   If buffer is not empty, returns bytes remaining.
'   If buffer is empty, reads from socket/SSL to refill.
'   Returns: >0 = bytes available, <=0 = EOF or error
SUB LONGINT _TcpFillBuf(ADDRESS conn)
  DECLARE STRUCT TcpConn *c
  LONGINT n, bufAddr

  c = conn

  ' Buffer still has data
  IF c->_bufPos < c->_bufLen THEN
    _TcpFillBuf = c->_bufLen - c->_bufPos
    EXIT SUB
  END IF

  ' Refill from socket
  bufAddr = @c->_bufData
  c->_bufPos = 0
  c->_bufLen = 0

  IF c->_sslHnd <> 0 THEN
    n = SslRead(c->_sslHnd, bufAddr, TCP_BUF_SIZE)
  ELSE
    n = recv(c->_sockFd, bufAddr, TCP_BUF_SIZE, 0)
  END IF

  IF n > 0 THEN c->_bufLen = n
  _TcpFillBuf = n
END SUB

{ ============== Public API ============== }

SUB LONGINT TcpInit EXTERNAL
  SHARED _tcpInited
  SHARED _bsdSockBase, _tcpSslReady

  IF _tcpInited = 1 THEN
    TcpInit = TCP_SUCCESS
    EXIT SUB
  END IF

  LIBRARY "bsdsocket.library"

  ' Read _BSDSOCKETBase into module variable for later SSL init
  ASSEM
    move.l  _BSDSOCKETBase,_modv__BSDSOCKBASE
  END ASSEM

  _tcpSslReady = 0
  _tcpInited = 1
  TcpInit = TCP_SUCCESS
END SUB

SUB TcpCleanup EXTERNAL
  SHARED _tcpInited
  SHARED _tcpSslReady

  IF _tcpInited <> 1 THEN EXIT SUB

  IF _tcpSslReady = 1 THEN
    SslCleanup
    _tcpSslReady = 0
  END IF

  _tcpInited = 0
END SUB

SUB LONGINT TcpOpen(ADDRESS conn, STRING host$, ~
                     LONGINT port, LONGINT useSSL) EXTERNAL
  SHARED _bsdSockBase, _tcpSslReady
  DECLARE STRUCT TcpConn *c
  LONGINT ipAddr, sock, ssl, rc

  c = conn

  ' Auto-init
  rc = TcpInit
  IF rc <> TCP_SUCCESS THEN
    TcpOpen = rc
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
      rc = SslInit
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

  ' Initialize struct fields
  c->_sockFd = sock
  c->_sslHnd = ssl
  c->_bufPos = 0
  c->_bufLen = 0
  TcpOpen = TCP_SUCCESS
END SUB

SUB TcpClose(ADDRESS conn) EXTERNAL
  DECLARE STRUCT TcpConn *c
  c = conn

  IF c->_sockFd = -1 THEN EXIT SUB

  IF c->_sslHnd <> 0 THEN
    SslFreeConn(c->_sslHnd)
    c->_sslHnd = 0
  END IF

  CloseSocket(c->_sockFd)
  c->_sockFd = -1
  c->_bufPos = 0
  c->_bufLen = 0
END SUB

SUB LONGINT TcpSend(ADDRESS conn, ADDRESS buf, ~
                     LONGINT bufLen) EXTERNAL
  DECLARE STRUCT TcpConn *c
  c = conn

  IF c->_sockFd = -1 THEN
    TcpSend = TCP_ERR_BAD_HANDLE
    EXIT SUB
  END IF

  IF c->_sslHnd <> 0 THEN
    TcpSend = SslWrite(c->_sslHnd, buf, bufLen)
  ELSE
    TcpSend = send(c->_sockFd, buf, bufLen, 0)
  END IF
END SUB

SUB LONGINT TcpRecv(ADDRESS conn, ADDRESS buf, ~
                     LONGINT bufSz) EXTERNAL
  DECLARE STRUCT TcpConn *c
  c = conn

  IF c->_sockFd = -1 THEN
    TcpRecv = TCP_ERR_BAD_HANDLE
    EXIT SUB
  END IF

  IF c->_sslHnd <> 0 THEN
    TcpRecv = SslRead(c->_sslHnd, buf, bufSz)
  ELSE
    TcpRecv = recv(c->_sockFd, buf, bufSz, 0)
  END IF
END SUB

SUB LONGINT TcpRecvBuf(ADDRESS conn, ADDRESS destBuf, ~
                        LONGINT maxBytes) EXTERNAL
  DECLARE STRUCT TcpConn *c
  LONGINT avail, n, i, bufAddr

  c = conn

  IF c->_sockFd = -1 THEN
    TcpRecvBuf = TCP_ERR_BAD_HANDLE
    EXIT SUB
  END IF

  IF maxBytes <= 0 THEN
    TcpRecvBuf = 0
    EXIT SUB
  END IF

  ' Ensure buffer has data (refills from socket if empty)
  n = _TcpFillBuf(conn)
  IF n <= 0 THEN
    TcpRecvBuf = 0
    EXIT SUB
  END IF

  ' Copy up to maxBytes from buffer
  bufAddr = @c->_bufData
  avail = c->_bufLen - c->_bufPos
  IF avail > maxBytes THEN avail = maxBytes
  FOR i = 0 TO avail - 1
    POKE destBuf + i, PEEK(bufAddr + c->_bufPos + i)
  NEXT i
  c->_bufPos = c->_bufPos + avail
  TcpRecvBuf = avail
END SUB

SUB LONGINT TcpRecvLine(ADDRESS conn, ADDRESS lineBuf, ~
                         LONGINT maxLen) EXTERNAL
  DECLARE STRUCT TcpConn *c
  LONGINT resultLen, found, lineErr
  LONGINT scanPos, gotLF, copyEnd, n, i
  LONGINT bufAddr

  c = conn

  IF c->_sockFd = -1 THEN
    TcpRecvLine = -1
    EXIT SUB
  END IF

  bufAddr = @c->_bufData
  resultLen = 0
  found = 0
  lineErr = 0

  WHILE found = 0 AND lineErr = 0
    ' Ensure buffer has data (refills from socket if empty)
    n = _TcpFillBuf(conn)
    IF n <= 0 THEN
      lineErr = 1
    END IF

    IF lineErr = 0 THEN
      ' Scan for LF (byte 10)
      scanPos = c->_bufPos
      gotLF = 0
      WHILE scanPos < c->_bufLen AND gotLF = 0
        IF PEEK(bufAddr + scanPos) = 10 THEN
          gotLF = 1
        ELSE
          scanPos = scanPos + 1
        END IF
      WEND

      IF gotLF = 1 THEN
        ' Found LF: copy bytes before it (strip CR if present)
        copyEnd = scanPos
        IF copyEnd > c->_bufPos THEN
          IF PEEK(bufAddr + copyEnd - 1) = 13 THEN
            copyEnd = copyEnd - 1
          END IF
        END IF
        FOR i = c->_bufPos TO copyEnd - 1
          IF resultLen < maxLen THEN
            POKE lineBuf + resultLen, PEEK(bufAddr + i)
            resultLen = resultLen + 1
          END IF
        NEXT i
        c->_bufPos = scanPos + 1
        found = 1
      ELSE
        ' No LF yet: copy all remaining buffer bytes
        FOR i = c->_bufPos TO c->_bufLen - 1
          IF resultLen < maxLen THEN
            POKE lineBuf + resultLen, PEEK(bufAddr + i)
            resultLen = resultLen + 1
          END IF
        NEXT i
        c->_bufPos = c->_bufLen
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

SUB TcpBufFlush(ADDRESS conn) EXTERNAL
  DECLARE STRUCT TcpConn *c
  c = conn

  IF c->_sockFd = -1 THEN EXIT SUB

  c->_bufPos = 0
  c->_bufLen = 0
END SUB
