TCPClient - TCP Connection Submodule for ACE BASIC
==================================================

A struct-based TCP client library with optional SSL/TLS support.
The caller owns TcpConn structs, so there is no connection limit.

Requirements
------------
- bsdsocket.library (AmiTCP, Roadshow, or compatible)
- amisslmaster.library + amissl.library (optional, for HTTPS/TLS)
- amissl submodule (submods/amissl/)

Usage
-----

  #include <submods/tcpclient.h>

  DECLARE STRUCT TcpConn myConn

  rc = TcpOpen(myConn, "example.com", 80, 0)   ' 0=plain, 1=SSL
  rc = TcpSend(myConn, SADD(req$), LEN(req$))
  n  = TcpRecvLine(myConn, lineBuf, TCP_LINE_MAX)
  TcpClose(myConn)
  TcpCleanup

API Summary
-----------

  TcpInit          Initialize TCP subsystem (called automatically by TcpOpen)
  TcpCleanup       Free global resources (does NOT close connections)
  TcpOpen          Open a connection (plain or SSL)
  TcpClose         Close a connection

  TcpSend          Send raw bytes

  TcpRecv          Receive raw bytes - UNBUFFERED
  TcpRecvBuf       Receive raw bytes - BUFFERED
  TcpRecvLine      Read one line (up to LF, strips CR) - BUFFERED
  TcpBufFlush      Discard buffered data

Buffered vs Unbuffered Reads
-----------------------------

TcpRecvLine and TcpRecvBuf share an internal 4096-byte read-ahead
buffer inside the TcpConn struct. They are safe to mix on the same
connection.

TcpRecv bypasses this buffer entirely and reads directly from the
socket. Do NOT mix TcpRecv with TcpRecvLine or TcpRecvBuf on the
same connection - any data already buffered will be skipped and lost.

Use TcpRecv only when you manage all reads yourself (e.g. reading
a known-length binary payload without any line-based reads).

Use TcpBufFlush to discard buffered data when switching from buffered
to unbuffered reads.

Error Constants
---------------

  TCP_SUCCESS        =  0   Operation succeeded
  TCP_ERR_SOCKET     = -1   Socket creation or connect failed
  TCP_ERR_DNS        = -2   Host name resolution failed
  TCP_ERR_SEND       = -3   Send failed
  TCP_ERR_RECV       = -4   Receive failed
  TCP_ERR_SSL        = -5   SSL init or handshake failed
  TCP_ERR_BAD_HANDLE = -7   Connection not open (sockFd = -1)

Files
-----

  submods/tcpclient/tcpclient.b       Source code
  submods/tcpclient/test_tcpclient.b  Tests
  include/submods/tcpclient.h         Header file
