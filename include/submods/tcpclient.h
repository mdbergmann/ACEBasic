#ifndef TCPCLIENT_H
#define TCPCLIENT_H 1

{*
 * tcpclient.h - TCP connection submodule for ACE BASIC
 *
 * Provides multi-connection TCP client with optional SSL via amissl.
 * Supports up to 4 simultaneous connections.
 *
 * Usage:
 *   #include <submods/tcpclient.h>
 *   EXTERNAL tcpclient
 *
 * Typical sequence:
 *   rc = TcpInit
 *   h = TcpOpen("example.com", 80, 0)   ' plain TCP
 *   TcpSend(h, SADD(msg$), LEN(msg$))
 *   n = TcpRecv(h, buf, bufSz)
 *   TcpClose(h)
 *   TcpCleanup
 *
 * Requirements:
 *   - bsdsocket.library (AmiTCP, Roadshow, or compatible)
 *   - amisslmaster.library + amissl.library (optional, for SSL)
 *}

#include <submods/amissl.h>

' Error constants
CONST TCP_SUCCESS        = 0    ' Operation succeeded
CONST TCP_ERR_SOCKET     = -1   ' Socket creation or connect failed
CONST TCP_ERR_DNS        = -2   ' Host name resolution failed
CONST TCP_ERR_SEND       = -3   ' Send failed
CONST TCP_ERR_RECV       = -4   ' Receive failed
CONST TCP_ERR_SSL        = -5   ' SSL init or handshake failed
CONST TCP_ERR_NO_SLOT    = -6   ' All connection slots in use
CONST TCP_ERR_BAD_HANDLE = -7   ' Invalid connection handle

' Buffer size (matches internal buffer)
CONST TCP_BUF_SIZE   = 4096
CONST TCP_LINE_MAX   = 1024

' TcpInit - Initialize TCP subsystem
'   Opens bsdsocket.library and allocates connection table.
'   Returns: TCP_SUCCESS (0) or negative error code
'   Note: Called automatically by TcpOpen if needed.
DECLARE SUB LONGINT TcpInit EXTERNAL

' TcpCleanup - Close all connections and free resources
'   Also calls SslCleanup if SSL was initialized.
DECLARE SUB TcpCleanup EXTERNAL

' TcpOpen - Open a TCP connection (optionally with SSL)
'   host$ - Host name or dotted IP address
'   port  - Port number (e.g. 80, 443)
'   useSSL - 0 for plain TCP, 1 for SSL/TLS
'   Returns: positive handle (1-4) on success, negative error code
DECLARE SUB LONGINT TcpOpen(STRING host, LONGINT port, ~
                             LONGINT useSSL) EXTERNAL

' TcpClose - Close a connection and free its slot
'   h - Connection handle from TcpOpen
'   Note: Performs SSL shutdown if applicable.
DECLARE SUB TcpClose(LONGINT h) EXTERNAL

' TcpSend - Send raw bytes (SSL-aware)
'   h      - Connection handle
'   buf    - Address of data to send
'   bufLen - Number of bytes to send
'   Returns: bytes sent (>0) or negative error code
DECLARE SUB LONGINT TcpSend(LONGINT h, ADDRESS buf, ~
                             LONGINT bufLen) EXTERNAL

' TcpRecv - Receive raw bytes, unbuffered (SSL-aware)
'   h    - Connection handle
'   buf  - Address of buffer to read into
'   bufSz - Maximum bytes to read
'   Returns: bytes received (>0), 0 on EOF, or negative error
DECLARE SUB LONGINT TcpRecv(LONGINT h, ADDRESS buf, ~
                             LONGINT bufSz) EXTERNAL

' TcpRecvBuf - Buffered read of up to maxBytes
'   h        - Connection handle
'   destBuf  - Address of buffer to read into
'   maxBytes - Maximum bytes to read
'   Returns: bytes read (>0), 0 on EOF/empty
'   Note: Uses per-connection internal buffer for efficiency.
DECLARE SUB LONGINT TcpRecvBuf(LONGINT h, ADDRESS destBuf, ~
                                LONGINT maxBytes) EXTERNAL

' TcpRecvLine - Read one line (up to LF, strips CR)
'   h       - Connection handle
'   lineBuf - Address of buffer for line data
'   maxLen  - Maximum bytes to store (excluding null terminator)
'   Returns: line length (>=0) on success, -1 on error/EOF
'   Note: Buffer is null-terminated. Uses per-connection buffer.
DECLARE SUB LONGINT TcpRecvLine(LONGINT h, ADDRESS lineBuf, ~
                                 LONGINT maxLen) EXTERNAL

' TcpBufFlush - Discard buffered data for a connection
'   h - Connection handle
'   Note: Use after switching from buffered to unbuffered reads.
DECLARE SUB TcpBufFlush(LONGINT h) EXTERNAL

#endif
