#ifndef AMISSL_H
#define AMISSL_H 1

{*
 * amissl.h - AmiSSL wrapper submodule for ACE BASIC
 *
 * Provides SSL/TLS context management and I/O via AmiSSL.
 * Requires amisslmaster.library + amissl.library on Amiga.
 *
 * Usage:
 *   #include <submods/amissl.h>
 *
 * Typical sequence:
 *   rc = SslInit
 *   ssl& = SslNewConn(sockFd&)
 *   SslWrite(ssl&, buf&, len&)
 *   n& = SslRead(ssl&, buf&, len&)
 *   SslFreeConn(ssl&)
 *   SslCleanup
 *}

REM #using amissl.o

' Error constants
CONST SSL_SUCCESS     = 0    ' Operation succeeded
CONST SSL_ERR_INIT    = -1   ' AmiSSL initialization failed
CONST SSL_ERR_CONNECT = -2   ' SSL/TLS handshake failed
CONST SSL_ERR_NO_LIB  = -3   ' Required library not available

' SslInit - Initialize AmiSSL libraries and create SSL context
'   Opens bsdsocket.library internally (closed by SslCleanup).
'   Returns: SSL_SUCCESS (0) or negative error code
'   Note: Lazy init - calling multiple times is safe (returns success).
DECLARE SUB LONGINT SslInit EXTERNAL

' SslCleanup - Close AmiSSL libraries and free SSL context
'   Note: Safe to call even if SslInit was not called.
DECLARE SUB SslCleanup EXTERNAL

' SslNewConn - Create SSL connection on an existing TCP socket
'   sockFd   - TCP socket file descriptor (already connected)
'   hostName - ADDRESS of null-terminated hostname for SNI, or 0 to skip
'   Returns: SSL handle (positive) or 0 on failure
'   Note: Performs SSL_new + SSL_set_fd + SSL_set_tlsext_host_name + SSL_connect.
DECLARE SUB LONGINT SslNewConn(LONGINT sockFd, ADDRESS hostName) EXTERNAL

' SslFreeConn - Shut down and free an SSL connection
'   ssl - SSL handle from SslNewConn
'   Note: Performs SSL_shutdown + SSL_free. Safe if ssl=0.
DECLARE SUB SslFreeConn(LONGINT ssl) EXTERNAL

' SslRead - Read data from SSL connection
'   ssl - SSL handle from SslNewConn
'   buf - Address of buffer to read into
'   num - Maximum bytes to read
'   Returns: Number of bytes read, or <=0 on error
DECLARE SUB LONGINT SslRead(LONGINT ssl, ADDRESS buf, LONGINT num) EXTERNAL

' SslWrite - Write data to SSL connection
'   ssl - SSL handle from SslNewConn
'   buf - Address of data to write
'   num - Number of bytes to write
'   Returns: Number of bytes written, or <=0 on error
DECLARE SUB LONGINT SslWrite(LONGINT ssl, ADDRESS buf, LONGINT num) EXTERNAL

#endif
