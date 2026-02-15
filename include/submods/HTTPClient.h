#ifndef HTTPCLIENT_H
#define HTTPCLIENT_H 1

{*
 * HTTPClient.h - HTTP/1.1 client submodule for ACE BASIC
 *
 * Stateless struct-based API. Caller owns 3 independent structs:
 *   - TcpConn      (from tcpclient) - TCP/SSL connection state
 *   - HttpRequest   - host, port, request headers
 *   - HttpResponse  - status, transfer state, response headers
 *
 * No struct references another. Each function takes only what it needs.
 *
 * Provides HTTP/1.1 client functionality with optional HTTPS via AmiSSL.
 * Three API tiers:
 *   - High-level convenience (one-call string-based requests)
 *   - Streaming (callback-based for large/binary transfers)
 *   - Low-level struct-based (full control over request lifecycle)
 *
 * Convention: struct fields prefixed with _ are private/internal.
 *   Do not read or write them directly.
 *
 * Requirements:
 *   - bsdsocket.library (AmiTCP, Roadshow, or compatible TCP/IP stack)
 *   - amisslmaster.library + amissl.library (optional, for HTTPS only)
 *
 * Usage:
 *   #include <submods/httpclient.h>
 *   EXTERNAL httpclient
 *
 *   DECLARE STRUCT TcpConn myTcp
 *   DECLARE STRUCT HttpRequest myReq
 *   DECLARE STRUCT HttpResponse myResp
 *
 *   rc = HttpOpen(myReq, myTcp, "www.example.com", 80, HTTP_PLAIN)
 *   HttpSetHeader(myReq, "Accept", "star/star")
 *   rc = HttpSendRequest(myReq, myTcp, "GET", "/")
 *   statusCode = HttpReadStatus(myTcp, myResp)
 *   ct$ = HttpGetResponseHeader(myResp, "Content-Type")
 *   bytesGot = HttpReadBody(myTcp, myResp, buf, 4096)
 *   HttpClose(myTcp)
 *
 * Thread safety:
 *   This module is NOT thread-safe. All calls must be made from a
 *   single thread/process. The module uses shared workspace buffers.
 *
 * Struct lifecycle (low-level API):
 *   1. HttpOpen stores host/port in req and resets req headers to 0.
 *      -> Call HttpSetHeader AFTER HttpOpen, not before.
 *   2. HttpSendRequest sends all req headers, then clears them
 *      (_reqHdrCount=0). Headers must be re-set for the next request.
 *   3. HttpReadStatus resets ALL response state in resp (status,
 *      content-length, transfer mode, chunk state, headers) before
 *      reading. Previous response data in resp is replaced.
 *   4. HttpClose closes the TCP connection but does NOT touch the
 *      resp struct. Response headers remain accessible after close.
 *   5. All three structs are reusable across multiple requests.
 *      Each HttpOpen/HttpReadStatus cycle resets the relevant struct.
 *
 * Size limits:
 *   - Header name: max 63 characters (HDR_NAME_SZ = 64 bytes)
 *   - Header value: max 255 characters (HDR_VAL_SZ = 256 bytes)
 *   - Host name: max 127 characters (128-byte field)
 *   - Request headers: max 16 per HttpRequest struct
 *   - Response headers: max 32 per HttpResponse struct
 *
 * Limitations:
 *   - Connection: close is always sent (no keep-alive pooling)
 *   - No certificate verification (accepts all certificates)
 *   - No HTTP/2 (HTTP/1.1 only)
 *   - No automatic redirect following
 *   - No cookie management (use HttpSetHeader manually)
 *
 * Raw TCP access:
 *   Since the caller owns the TcpConn struct, TcpSend/TcpRecv from
 *   tcpclient can be used directly for raw byte I/O on the connection.
 *}

#include <submods/tcpclient.h>


' =====================================================================
' STRUCT DEFINITIONS
' =====================================================================

' HttpHeader - one name/value pair (320 bytes per slot)
'   Used internally as array elements within HttpRequest and HttpResponse.
'   Header name: max 63 characters (64-byte field)
'   Header value: max 255 characters (256-byte field)
STRUCT HttpHeader
  STRING hdrName SIZE 64
  STRING hdrVal SIZE 256
END STRUCT

' Header slot size constants
CONST HDR_NAME_SZ   = 64
CONST HDR_VAL_SZ    = 256
CONST HDR_SLOT_SZ   = 320

' HttpRequest - Request state (host, port, custom headers)
'   Passed to functions that build/send requests.
'   All fields are private (managed by HttpOpen, HttpSetHeader, etc.)
'   _reqHdrs holds up to 16 HttpHeader entries (16 * 320 = 5120 bytes)
STRUCT HttpRequest
  STRING _reqHost SIZE 128
  LONGINT _reqPort
  STRING _reqHdrs SIZE 5120
  LONGINT _reqHdrCount
END STRUCT

' HttpResponse - Response state (status, headers, transfer tracking)
'   Filled by HttpReadStatus, queried by header accessors.
'   Public: statusCode, contentLen, respHdrCount
'   Private (_prefix): transfer tracking fields and header storage
'   _respHdrs holds up to 32 HttpHeader entries (32 * 320 = 10240 bytes)
STRUCT HttpResponse
  LONGINT statusCode
  LONGINT contentLen
  STRING _respHdrs SIZE 10240
  LONGINT respHdrCount
  LONGINT _bodyLeft
  LONGINT _xfer
  LONGINT _chunkState
  LONGINT _chunkLeft
END STRUCT


' =====================================================================
' ERROR CODES
' =====================================================================
' All functions returning LONGINT use these codes for errors.
' Positive return values are HTTP status codes (200, 404, etc.).
' Negative return values indicate client-side errors.
' HTTP_SUCCESS (0) indicates success for non-status-returning functions.

CONST HTTP_SUCCESS         = 0    ' Operation succeeded (no error)
CONST HTTP_ERR_SOCKET      = -1   ' Socket creation or connect failed
CONST HTTP_ERR_DNS         = -2   ' Host name resolution failed
CONST HTTP_ERR_SEND        = -3   ' Send failed (connection lost)
CONST HTTP_ERR_RECV        = -4   ' Receive failed or connection closed
CONST HTTP_ERR_SSL_INIT    = -5   ' AmiSSL initialization failed
CONST HTTP_ERR_SSL_CONNECT = -6   ' SSL/TLS handshake failed
CONST HTTP_ERR_PARSE       = -7   ' Malformed HTTP response
CONST HTTP_ERR_OVERFLOW    = -8   ' Response exceeds buffer size
CONST HTTP_ERR_CALLBACK    = -9   ' Callback returned HTTP_ABORT
CONST HTTP_ERR_NO_LIB      = -10  ' Required library not available
CONST HTTP_ERR_NOMEM       = -11  ' Not enough memory for allocation


' =====================================================================
' CALLBACK RETURN VALUES
' =====================================================================
' Used by onReceive and onSend callbacks in the streaming API.

CONST HTTP_CONTINUE        = 0    ' Continue the transfer
CONST HTTP_ABORT           = 1    ' Abort the transfer


' =====================================================================
' SSL FLAGS
' =====================================================================
' Used by HttpOpen to select plain TCP or SSL/TLS connection.
' The high-level and streaming APIs detect this from the URL scheme.

CONST HTTP_SSL             = 1    ' Use SSL/TLS (https)
CONST HTTP_PLAIN           = 0    ' Plain TCP (http)


' =====================================================================
' HIGH-LEVEL CONVENIENCE API
' =====================================================================
' These functions perform a complete HTTP request in one call:
' open connection, send request, read response, close connection.
'
' All take ADDRESS params for the 3 caller-owned structs:
'   req  - HttpRequest struct (used for request headers)
'   resp - HttpResponse struct (filled with response state)
'   tcpConn - TcpConn struct (used for TCP connection)
'
' URL format: http[s]://host[:port]/path[?query]
'   - Scheme determines SSL (https) or plain (http)
'   - Port defaults to 80 (http) or 443 (https)
'
' HttpGet/HttpPost/HttpPut/HttpRequest auto-allocate the response
'   buffer based on Content-Length (exact allocation) or via growing
'   buffer for chunked transfers. Caller must free with HttpFreeBuf().
'
' After the call returns:
'   - resp struct retains response headers (query with
'     HttpGetResponseHeader, HttpResponseHeaderCount, etc.)
'   - resp->contentLen has actual body size (even for chunked)
'   - req struct's headers are cleared (_reqHdrCount=0)
'   - tcpConn is closed (connection no longer usable)
'   - All three structs are ready for reuse with the next request.
' =====================================================================

' HttpGet - Perform an HTTP GET with auto-allocated response buffer
'   Returns: ADDRESS of allocated body buffer (null-terminated) if > 0,
'            or negative error code (HTTP_ERR_*) on failure.
'   On success (return > 0):
'     resp->statusCode has HTTP status (200, 404, etc.)
'     resp->contentLen has actual body size in bytes
'     Caller MUST call HttpFreeBuf() to free the returned buffer
'   On error (return < 0): no buffer allocated, nothing to free.
'   Checks available memory before allocating; returns HTTP_ERR_NOMEM
'     if insufficient.
DECLARE SUB LONGINT HttpGet(ADDRESS req, ADDRESS resp, ~
                            ADDRESS tcpConn, ~
                            STRING url) EXTERNAL

' HttpHead - Perform an HTTP HEAD request (no response body)
DECLARE SUB LONGINT HttpHead(ADDRESS req, ADDRESS resp, ~
                             ADDRESS tcpConn, ~
                             STRING url) EXTERNAL

' HttpPost - Perform an HTTP POST with auto-allocated response buffer
'   Returns: ADDRESS of allocated body buffer (null-terminated) if > 0,
'            or negative error code (HTTP_ERR_*) on failure.
'   On success: resp->statusCode, resp->contentLen set. Free with HttpFreeBuf().
DECLARE SUB LONGINT HttpPost(ADDRESS req, ADDRESS resp, ~
                             ADDRESS tcpConn, STRING url, ~
                             STRING contentType, STRING body) EXTERNAL

' HttpPut - Perform an HTTP PUT with auto-allocated response buffer
'   Returns: ADDRESS of allocated body buffer (null-terminated) if > 0,
'            or negative error code (HTTP_ERR_*) on failure.
'   On success: resp->statusCode, resp->contentLen set. Free with HttpFreeBuf().
DECLARE SUB LONGINT HttpPut(ADDRESS req, ADDRESS resp, ~
                            ADDRESS tcpConn, STRING url, ~
                            STRING contentType, STRING body) EXTERNAL

' HttpRequest - Generic request with auto-allocated response buffer
'   Returns: ADDRESS of allocated body buffer (null-terminated) if > 0,
'            or negative error code (HTTP_ERR_*) on failure.
'   For HEAD requests: returns HTTP status code directly (no body buffer).
'   On success: resp->statusCode, resp->contentLen set. Free with HttpFreeBuf().
DECLARE SUB LONGINT HttpRequest(ADDRESS req, ADDRESS resp, ~
                                ADDRESS tcpConn, STRING url, ~
                                STRING method, STRING contentType, ~
                                STRING body) EXTERNAL


' =====================================================================
' STREAMING API (callback-based)
' =====================================================================
' These functions use INVOKABLE callbacks for sending and receiving
' data. Suitable for binary data and arbitrarily large transfers.
'
' onReceive callback signature:
'   SUB LONGINT MyReceiver(LONGINT bufAddr, LONGINT bufLen) INVOKABLE
'     ' bufAddr = address of received data
'     ' bufLen  = number of bytes available
'     ' Return HTTP_CONTINUE to continue, HTTP_ABORT to stop
'   END SUB
'
' onSend callback signature:
'   SUB LONGINT MySender(LONGINT bufAddr, LONGINT bufSize) INVOKABLE
'     ' bufAddr = address of buffer to fill with data
'     ' bufSize = maximum number of bytes to write
'     ' Return number of bytes written, or 0 when done
'   END SUB
'
' Pass callback address using @SubName or a BIND closure.
' Pass 0& for unused callbacks (e.g. onSend for GET).
'
' Sending uses chunked Transfer-Encoding automatically.
'
' After the call returns:
'   - resp struct retains response headers
'   - req struct's headers are cleared (_reqHdrCount=0)
'   - tcpConn is closed
'   - All three structs are ready for reuse with the next request.
' =====================================================================

' HttpGetStream - Streaming GET request
DECLARE SUB LONGINT HttpGetStream(ADDRESS req, ADDRESS resp, ~
                                  ADDRESS tcpConn, STRING url, ~
                                  ADDRESS onRecv) EXTERNAL

' HttpPostStream - Streaming POST with chunked request body
DECLARE SUB LONGINT HttpPostStream(ADDRESS req, ADDRESS resp, ~
                                   ADDRESS tcpConn, STRING url, ~
                                   STRING contentType, ADDRESS onSend, ~
                                   ADDRESS onRecv) EXTERNAL

' HttpPutStream - Streaming PUT with chunked request body
DECLARE SUB LONGINT HttpPutStream(ADDRESS req, ADDRESS resp, ~
                                  ADDRESS tcpConn, STRING url, ~
                                  STRING contentType, ADDRESS onSend, ~
                                  ADDRESS onRecv) EXTERNAL

' HttpRequestStream - Generic streaming request
DECLARE SUB LONGINT HttpRequestStream(ADDRESS req, ADDRESS resp, ~
                                      ADDRESS tcpConn, STRING url, ~
                                      STRING method, STRING contentType, ~
                                      ADDRESS onSend, ~
                                      ADDRESS onRecv) EXTERNAL


' =====================================================================
' LOW-LEVEL STRUCT-BASED API
' =====================================================================
' For full control over the HTTP request/response lifecycle.
' Each function takes only the struct(s) it needs.
'
' Typical sequence:
'   DECLARE STRUCT TcpConn myTcp
'   DECLARE STRUCT HttpRequest myReq
'   DECLARE STRUCT HttpResponse myResp
'
'   rc = HttpOpen(myReq, myTcp, "example.com", 80, HTTP_PLAIN)
'   HttpSetHeader(myReq, "Accept", "application/json")
'   rc = HttpSendRequest(myReq, myTcp, "GET", "/path")
'   status = HttpReadStatus(myTcp, myResp)
'   ct$ = HttpGetResponseHeader(myResp, "Content-Type")
'   WHILE HttpReadBody(myTcp, myResp, buf, bufSz) > 0 : ... : WEND
'   HttpClose(myTcp)
' =====================================================================

' HttpOpen - Open a TCP connection (optionally with SSL)
'   req     - HttpRequest struct (stores host/port, resets headers)
'   tcpConn - TcpConn struct (connection state)
'   host$   - Host name or IP address (max 127 chars)
'   port    - Port number (e.g. 80, 443)
'   useSSL  - HTTP_PLAIN (0) or HTTP_SSL (1)
'   Returns: HTTP_SUCCESS (0) on success, negative error code on failure
'   Note: Resets reqHdrCount to 0. Set headers AFTER this call.
DECLARE SUB LONGINT HttpOpen(ADDRESS req, ADDRESS tcpConn, ~
                             STRING host, LONGINT port, ~
                             LONGINT useSSL) EXTERNAL

' HttpClearReqHeaders - Clear all request headers in the struct
'   req     - HttpRequest struct
'   Note: Resets reqHdrCount to 0. Use this to discard previously set
'         headers without closing the connection. Also called implicitly
'         by HttpOpen and HttpSendRequest.
DECLARE SUB HttpClearReqHeaders(ADDRESS req) EXTERNAL

' HttpSetHeader - Set a request header (before HttpSendRequest)
'   req     - HttpRequest struct
'   hdrName - Header name (max 63 chars, e.g. "Authorization")
'   hdrVal  - Header value (max 255 chars, e.g. "Bearer token123")
'   Note: Host and Connection are set automatically by HttpSendRequest.
'         Overwrites any previous value for the same header name.
'         Call AFTER HttpOpen (which resets headers) and BEFORE
'         HttpSendRequest (which clears them after sending).
DECLARE SUB HttpSetHeader(ADDRESS req, STRING hdrName, ~
                          STRING hdrVal) EXTERNAL

' HttpSendRequest - Send request line and headers
'   req     - HttpRequest struct (headers, host)
'   tcpConn - TcpConn struct (connection)
'   method$ - HTTP method (e.g. "GET", "POST")
'   path$   - Request path with optional query (e.g. "/api?key=val")
'   Returns: HTTP_SUCCESS on success, negative error code on failure
'   IMPORTANT: Clears all request headers in req after sending
'         (_reqHdrCount=0), even on error. Headers must be re-set
'         via HttpSetHeader before the next HttpSendRequest call.
'   Note: Automatically sends Host and Connection: close headers.
'         For POST/PUT/PATCH, follow with HttpWriteBody or
'         HttpWriteBodyChunked to send the request body.
DECLARE SUB LONGINT HttpSendRequest(ADDRESS req, ADDRESS tcpConn, ~
                                    STRING method, ~
                                    STRING reqPath) EXTERNAL

' HttpWriteBody - Send a fixed-length request body
'   tcpConn - TcpConn struct (connection)
'   dataBuf - Address of data to send
'   bodyLen - Number of bytes to send
'   Returns: HTTP_SUCCESS on success, negative error code on failure
'   Note: Set Content-Length via HttpSetHeader before HttpSendRequest.
DECLARE SUB LONGINT HttpWriteBody(ADDRESS tcpConn, ~
                                  ADDRESS dataBuf, ~
                                  LONGINT bodyLen) EXTERNAL

' HttpWriteBodyChunked - Send one chunk of a chunked request body
'   tcpConn - TcpConn struct (connection)
'   dataBuf - Address of data to send
'   bodyLen - Number of bytes in this chunk, or 0 to end the body
'   Returns: HTTP_SUCCESS on success, negative error code on failure
DECLARE SUB LONGINT HttpWriteBodyChunked(ADDRESS tcpConn, ~
                                         ADDRESS dataBuf, ~
                                         LONGINT bodyLen) EXTERNAL

' HttpReadStatus - Read and parse the HTTP response
'   tcpConn - TcpConn struct (connection, to receive)
'   resp    - HttpResponse struct (filled with status + headers)
'   Returns: HTTP status code (e.g. 200, 404) or negative error code
'   IMPORTANT: Resets ALL fields in resp before reading (statusCode,
'         contentLen, _bodyLeft, _xfer, _chunkState, _chunkLeft, and all
'         response headers). Any previous response data is replaced.
'   Note: Also reads and stores all response headers in resp.
'         Must be called before HttpGetResponseHeader or HttpReadBody.
DECLARE SUB LONGINT HttpReadStatus(ADDRESS tcpConn, ~
                                   ADDRESS resp) EXTERNAL

' HttpGetResponseHeader - Get a response header value
'   resp    - HttpResponse struct (after HttpReadStatus)
'   hdrName - Header name (case-insensitive, e.g. "Content-Type")
'   Returns: Header value string, or "" if not present
DECLARE SUB STRING HttpGetResponseHeader(ADDRESS resp, ~
                                         STRING hdrName) EXTERNAL

' HttpResponseHeaderCount - Get number of response headers
'   resp    - HttpResponse struct (after HttpReadStatus)
'   Returns: Number of headers (0 if none)
DECLARE SUB LONGINT HttpResponseHeaderCount(ADDRESS resp) EXTERNAL

' HttpResponseHeaderName - Get response header name by index
'   resp    - HttpResponse struct (after HttpReadStatus)
'   idx     - Zero-based header index (0 to count-1)
'   Returns: Header name string, or "" if index out of range
DECLARE SUB STRING HttpResponseHeaderName(ADDRESS resp, ~
                                          LONGINT idx) EXTERNAL

' HttpResponseHeaderVal - Get response header value by index
'   resp    - HttpResponse struct (after HttpReadStatus)
'   idx     - Zero-based header index (0 to count-1)
'   Returns: Header value string, or "" if index out of range
DECLARE SUB STRING HttpResponseHeaderVal(ADDRESS resp, ~
                                         LONGINT idx) EXTERNAL

' HttpReadBody - Read a chunk of the response body
'   tcpConn - TcpConn struct (connection, to receive)
'   resp    - HttpResponse struct (transfer state tracking)
'   dataBuf - Address of buffer to read into
'   bufSz   - Maximum number of bytes to read
'   Returns: Number of bytes read (>0), or 0 when body is complete,
'            or negative error code on failure
'   Note: Handles Content-Length, chunked, and close-delimited
'         transfer modes transparently. Call in a loop until 0.
DECLARE SUB LONGINT HttpReadBody(ADDRESS tcpConn, ADDRESS resp, ~
                                 ADDRESS dataBuf, ~
                                 LONGINT bufSz) EXTERNAL

' HttpClose - Close connection
'   tcpConn - TcpConn struct
'   Note: Delegates to TcpClose. Performs SSL shutdown if applicable.
'         Does NOT modify the req or resp structs. Response headers
'         in resp remain accessible after this call.
DECLARE SUB HttpClose(ADDRESS tcpConn) EXTERNAL


' =====================================================================
' UTILITY FUNCTIONS
' =====================================================================

' HttpFreeBuf - Free a buffer allocated by HttpGet
'   buf     - ADDRESS returned by HttpGet (safe to pass 0)
DECLARE SUB HttpFreeBuf(ADDRESS buf) EXTERNAL

' HttpDumpReqHeaders - Format request headers for display
'   req     - HttpRequest struct
'   Returns: String with each header as "name = value\n"
DECLARE SUB STRING HttpDumpReqHeaders(ADDRESS req) EXTERNAL

' HttpDumpRespHeaders - Format response headers for display
'   resp    - HttpResponse struct
'   Returns: String with each header as "name = value\n"
DECLARE SUB STRING HttpDumpRespHeaders(ADDRESS resp) EXTERNAL

' UrlEncode - Percent-encode a string per RFC 3986
'   raw$    - String to encode
'   Returns: Encoded string (unreserved chars A-Z a-z 0-9 -_.~ pass
'            through; all others become %XX hex escapes)
DECLARE SUB STRING UrlEncode(STRING raw) EXTERNAL

#endif
