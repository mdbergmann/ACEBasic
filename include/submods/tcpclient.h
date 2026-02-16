#ifndef TCPCLIENT_H
#define TCPCLIENT_H 1

{*
 * tcpclient.h - TCP connection submodule for ACE BASIC
 *
 * Stateless struct-based API. Caller owns connection state
 * via TcpConn structs - no connection limit.
 *
 * Usage:
 *   #include <submods/tcpclient.h>
 *   EXTERNAL tcpclient
 *
 * Typical sequence:
 *   DECLARE STRUCT TcpConn myConn
 *   TcpInit
 *   rc = TcpOpen(myConn, "example.com", 80, 0)
 *   TcpSend(myConn, SADD(msg$), LEN(msg$))
 *   n = TcpRecvLine(myConn, lineBuf, TCP_LINE_MAX)
 *   TcpClose(myConn)
 *   TcpCleanup
 *
 * Convention: struct fields prefixed with _ are private/internal.
 *   Do not read or write them directly.
 *
 * Requirements:
 *   - bsdsocket.library (AmiTCP, Roadshow, or compatible)
 *   - amisslmaster.library + amissl.library (optional, for SSL)
 *}

#include <submods/amissl.h>

' TcpConn - Per-connection state struct (owned by caller)
'   All fields are private (_prefix = do not access directly).
STRUCT TcpConn
  LONGINT _sockFd          ' socket file descriptor (-1 = not connected)
  LONGINT _sslHnd          ' SSL handle (0 = plain TCP)
  LONGINT _bufPos          ' current read position in buffer
  LONGINT _bufLen          ' bytes available in buffer
  BYTE _bufData SIZE 4096   ' read-ahead buffer
END STRUCT

' Error constants
CONST TCP_SUCCESS        = 0    ' Operation succeeded
CONST TCP_ERR_SOCKET     = -1   ' Socket creation or connect failed
CONST TCP_ERR_DNS        = -2   ' Host name resolution failed
CONST TCP_ERR_SEND       = -3   ' Send failed
CONST TCP_ERR_RECV       = -4   ' Receive failed
CONST TCP_ERR_SSL        = -5   ' SSL init or handshake failed
CONST TCP_ERR_BAD_HANDLE = -7   ' Invalid connection (_sockFd = -1)

' Buffer size (matches internal buffer)
CONST TCP_BUF_SIZE   = 4096
CONST TCP_LINE_MAX   = 1024

' TcpInit - Initialize TCP subsystem
'   Opens bsdsocket.library.
'   Returns: TCP_SUCCESS (0) or negative error code
'   Note: Called automatically by TcpOpen if needed.
DECLARE SUB LONGINT TcpInit EXTERNAL

' TcpCleanup - Free global resources
'   Calls SslCleanup if SSL was initialized.
'   Note: Does NOT close connections - caller must TcpClose each.
DECLARE SUB TcpCleanup EXTERNAL

' TcpOpen - Open a TCP connection (optionally with SSL)
'   conn  - Address of caller's TcpConn struct
'   host$ - Host name or dotted IP address
'   port  - Port number (e.g. 80, 443)
'   useSSL - 0 for plain TCP, 1 for SSL/TLS
'   Returns: TCP_SUCCESS (0) on success, negative error code on failure
DECLARE SUB LONGINT TcpOpen(ADDRESS conn, STRING host, ~
                             LONGINT port, LONGINT useSSL) EXTERNAL

' TcpClose - Close a connection and reset struct fields
'   conn - Address of TcpConn struct
'   Note: Performs SSL shutdown if applicable.
DECLARE SUB TcpClose(ADDRESS conn) EXTERNAL

' TcpSend - Send raw bytes (SSL-aware)
'   conn   - Address of TcpConn struct
'   buf    - Address of data to send
'   bufLen - Number of bytes to send
'   Returns: bytes sent (>0) or negative error code
DECLARE SUB LONGINT TcpSend(ADDRESS conn, ADDRESS buf, ~
                             LONGINT bufLen) EXTERNAL

' TcpRecv - Receive raw bytes, unbuffered (SSL-aware)
'   conn  - Address of TcpConn struct
'   buf   - Address of buffer to read into
'   bufSz - Maximum bytes to read
'   Returns: bytes received (>0), 0 on EOF, or negative error
'   WARNING: Bypasses the internal read-ahead buffer. Do NOT mix
'   with TcpRecvLine or TcpRecvBuf on the same connection — data
'   already buffered by those calls will be skipped and lost.
'   Use this only when you manage all reads yourself.
DECLARE SUB LONGINT TcpRecv(ADDRESS conn, ADDRESS buf, ~
                             LONGINT bufSz) EXTERNAL

' TcpRecvBuf - Buffered read of up to maxBytes
'   conn     - Address of TcpConn struct
'   destBuf  - Address of buffer to read into
'   maxBytes - Maximum bytes to read
'   Returns: bytes read (>0), 0 on EOF/empty
'   Uses the same internal read-ahead buffer as TcpRecvLine,
'   so it is safe to mix both on the same connection. Prefer
'   this over TcpRecv when also using TcpRecvLine.
DECLARE SUB LONGINT TcpRecvBuf(ADDRESS conn, ADDRESS destBuf, ~
                                LONGINT maxBytes) EXTERNAL

' TcpRecvLine - Read one line (up to LF, strips CR)
'   conn    - Address of TcpConn struct
'   lineBuf - Address of buffer for line data
'   maxLen  - Maximum bytes to store (excluding null terminator)
'   Returns: line length (>=0) on success, -1 on error/EOF
'   Note: Buffer is null-terminated. Uses per-connection buffer.
DECLARE SUB LONGINT TcpRecvLine(ADDRESS conn, ADDRESS lineBuf, ~
                                 LONGINT maxLen) EXTERNAL

' TcpBufFlush - Discard buffered data for a connection
'   conn - Address of TcpConn struct
'   Note: Use after switching from buffered to unbuffered reads.
DECLARE SUB TcpBufFlush(ADDRESS conn) EXTERNAL

#endif
