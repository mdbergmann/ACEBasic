#ifndef HTTPCLIENT_H
#define HTTPCLIENT_H 1

{*
 * HTTPClient.h - HTTP/1.1 client submodule for ACE BASIC
 *
 * Provides HTTP/1.1 client functionality with optional HTTPS via AmiSSL.
 * Three API tiers:
 *   - High-level convenience (one-call string-based requests)
 *   - Streaming (callback-based for large/binary transfers)
 *   - Low-level handle-based (full control over request lifecycle)
 *
 * Requirements:
 *   - bsdsocket.library (AmiTCP, Roadshow, or compatible TCP/IP stack)
 *   - amisslmaster.library + amissl.library (optional, for HTTPS only)
 *
 * Usage:
 *   #include <submods/HTTPClient.h>
 *   EXTERNAL httpclient
 *
 * Thread safety:
 *   This module is NOT thread-safe. All calls must be made from a
 *   single thread/process. The module uses shared global state for
 *   buffers, connection state, header storage, and SSL context.
 *
 * Limitations:
 *   - Single connection at a time (call HttpClose before re-opening)
 *   - Maximum 32 response headers stored per connection
 *   - No certificate verification (accepts all certificates)
 *   - No HTTP/2 (HTTP/1.1 only)
 *   - No automatic redirect following
 *   - No cookie management (use HttpSetHeader manually)
 *   - No keep-alive connection pooling
 *}


' =====================================================================
' ERROR CODES
' =====================================================================
' All functions returning LONGINT use these codes for errors.
' Positive return values are HTTP status codes (200, 404, etc.).
' Negative return values indicate client-side errors.

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
' URL format: http[s]://host[:port]/path[?query]
'   - Scheme determines SSL (https) or plain (http)
'   - Port defaults to 80 (http) or 443 (https)
'
' Response buffer (respBuf/bufSz):
'   - Pass SADD(str$) as respBuf, where str$ is a STRING SIZE N
'   - bufSz is the total buffer size in bytes
'   - Response body is capped to bufSz-1 bytes and null-terminated
'
' Return value:
'   - HTTP status code (e.g. 200, 404, 500) on success
'   - Negative error code (HTTP_ERR_*) on failure
'
' Note: Response headers are not accessible through this API.
' The connection is closed before the function returns.
' Use the low-level handle API if you need response headers.
' =====================================================================

' HttpGet - Perform an HTTP GET request
'   url$    - Full URL (http:// or https://)
'   respBuf - Address of response buffer (use SADD(str$))
'   bufSz   - Total size of response buffer in bytes
'   Returns: HTTP status code or negative error code
DECLARE SUB LONGINT HttpGet(STRING url, ADDRESS respBuf, ~
                            LONGINT bufSz) EXTERNAL

' HttpHead - Perform an HTTP HEAD request (no response body)
'   url$    - Full URL (http:// or https://)
'   Returns: HTTP status code or negative error code
DECLARE SUB LONGINT HttpHead(STRING url) EXTERNAL

' HttpPost - Perform an HTTP POST with string body
'   url$    - Full URL (http:// or https://)
'   ct$     - Content-Type header value (e.g. "application/json")
'   body$   - Request body string
'   respBuf - Address of response buffer (use SADD(str$))
'   bufSz   - Total size of response buffer in bytes
'   Returns: HTTP status code or negative error code
DECLARE SUB LONGINT HttpPost(STRING url, STRING ct, ~
                             STRING body, ADDRESS respBuf, ~
                             LONGINT bufSz) EXTERNAL

' HttpPut - Perform an HTTP PUT with string body
'   url$    - Full URL (http:// or https://)
'   ct$     - Content-Type header value
'   body$   - Request body string
'   respBuf - Address of response buffer (use SADD(str$))
'   bufSz   - Total size of response buffer in bytes
'   Returns: HTTP status code or negative error code
DECLARE SUB LONGINT HttpPut(STRING url, STRING ct, ~
                            STRING body, ADDRESS respBuf, ~
                            LONGINT bufSz) EXTERNAL

' HttpRequest - Generic request with arbitrary HTTP method
'   url$    - Full URL (http:// or https://)
'   meth$   - HTTP method (e.g. "GET", "POST", "DELETE", "PATCH")
'   ct$     - Content-Type header value (ignored for GET/HEAD/DELETE)
'   body$   - Request body string (ignored for GET/HEAD/DELETE)
'   respBuf - Address of response buffer (use SADD(str$))
'   bufSz   - Total size of response buffer in bytes
'   Returns: HTTP status code or negative error code
DECLARE SUB LONGINT HttpRequest(STRING url, STRING meth, ~
                                STRING ct, STRING body, ~
                                ADDRESS respBuf, ~
                                LONGINT bufSz) EXTERNAL


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
' Return value:
'   - HTTP status code (e.g. 200, 404, 500) on success
'   - Negative error code (HTTP_ERR_*) on failure
'
' Note: Response headers are not accessible through this API.
' Use the low-level handle API if you need response headers.
' =====================================================================

' HttpGetStream - Streaming GET request
'   url$    - Full URL (http:// or https://)
'   onRecv  - Address of onReceive callback (use @SubName)
'   Returns: HTTP status code or negative error code
DECLARE SUB LONGINT HttpGetStream(STRING url, ~
                                  ADDRESS onRecv) EXTERNAL

' HttpPostStream - Streaming POST with chunked request body
'   url$    - Full URL (http:// or https://)
'   ct$     - Content-Type header value
'   onSend  - Address of onSend callback (use @SubName)
'   onRecv  - Address of onReceive callback (use @SubName)
'   Returns: HTTP status code or negative error code
DECLARE SUB LONGINT HttpPostStream(STRING url, STRING ct, ~
                                   ADDRESS onSend, ~
                                   ADDRESS onRecv) EXTERNAL

' HttpPutStream - Streaming PUT with chunked request body
'   url$    - Full URL (http:// or https://)
'   ct$     - Content-Type header value
'   onSend  - Address of onSend callback (use @SubName)
'   onRecv  - Address of onReceive callback (use @SubName)
'   Returns: HTTP status code or negative error code
DECLARE SUB LONGINT HttpPutStream(STRING url, STRING ct, ~
                                  ADDRESS onSend, ~
                                  ADDRESS onRecv) EXTERNAL

' HttpRequestStream - Generic streaming request
'   url$    - Full URL (http:// or https://)
'   meth$   - HTTP method (e.g. "GET", "POST", "PUT")
'   ct$     - Content-Type header value (ignored for bodyless methods)
'   onSend  - Address of onSend callback, or 0& for no body
'   onRecv  - Address of onReceive callback, or 0& for no body (HEAD)
'   Returns: HTTP status code or negative error code
DECLARE SUB LONGINT HttpRequestStream(STRING url, STRING meth, ~
                                      STRING ct, ADDRESS onSend, ~
                                      ADDRESS onRecv) EXTERNAL


' =====================================================================
' LOW-LEVEL HANDLE API
' =====================================================================
' For full control over the HTTP request/response lifecycle.
' Typical sequence:
'   h = HttpOpen(host$, port, HTTP_PLAIN)
'   HttpSetHeader(h, "Accept", "application/json")
'   HttpSendRequest(h, "GET", "/path")
'   status = HttpReadStatus(h)
'   ct$ = HttpGetResponseHeader(h, "Content-Type")
'   WHILE HttpReadBody(h, buf, bufSz) > 0 : ... : WEND
'   HttpClose(h)
'
' Handle values:
'   - Positive LONGINT = valid connection handle
'   - Negative LONGINT = error code (HTTP_ERR_*)
' =====================================================================

' HttpOpen - Open a TCP connection (optionally with SSL)
'   host$   - Host name or IP address (e.g. "example.com")
'   port    - Port number (e.g. 80, 443)
'   useSSL  - HTTP_PLAIN (0) or HTTP_SSL (1)
'   Returns: positive handle on success, negative error code on failure
DECLARE SUB LONGINT HttpOpen(STRING host, LONGINT port, ~
                             LONGINT useSSL) EXTERNAL

' HttpSetHeader - Set a request header (before HttpSendRequest)
'   h       - Connection handle from HttpOpen
'   hdrName - Header name (e.g. "Authorization", "Accept")
'   hdrVal  - Header value (e.g. "Bearer token123")
'   Note: Host and Content-Length are set automatically.
'         Overwrites any previous value for the same header name.
DECLARE SUB HttpSetHeader(LONGINT h, STRING hdrName, ~
                          STRING hdrVal) EXTERNAL

' HttpSendRequest - Send request line and headers
'   h       - Connection handle from HttpOpen
'   meth$   - HTTP method (e.g. "GET", "POST")
'   path$   - Request path with optional query (e.g. "/api?key=val")
'   Returns: HTTP_SUCCESS on success, negative error code on failure
'   Note: For POST/PUT/PATCH, follow with HttpWriteBody or
'         HttpWriteBodyChunked to send the request body.
DECLARE SUB LONGINT HttpSendRequest(LONGINT h, STRING meth, ~
                                    STRING path) EXTERNAL

' HttpWriteBody - Send a fixed-length request body
'   h       - Connection handle
'   dataBuf - Address of data to send
'   bodyLen - Number of bytes to send
'   Returns: HTTP_SUCCESS on success, negative error code on failure
'   Note: Set Content-Length via HttpSetHeader before HttpSendRequest.
DECLARE SUB LONGINT HttpWriteBody(LONGINT h, LONGINT dataBuf, ~
                                  LONGINT bodyLen) EXTERNAL

' HttpWriteBodyChunked - Send one chunk of a chunked request body
'   h       - Connection handle
'   dataBuf - Address of data to send
'   bodyLen - Number of bytes in this chunk, or 0 to end the body
'   Returns: HTTP_SUCCESS on success, negative error code on failure
'   Note: Transfer-Encoding: chunked is added automatically.
'         Call repeatedly with data, then once with bodyLen=0 to finish.
DECLARE SUB LONGINT HttpWriteBodyChunked(LONGINT h, ~
                                         LONGINT dataBuf, ~
                                         LONGINT bodyLen) EXTERNAL

' HttpReadStatus - Read and parse the HTTP response status line
'   h       - Connection handle (after sending request)
'   Returns: HTTP status code (e.g. 200, 404) or negative error code
'   Note: Also reads and stores all response headers internally.
'         Must be called before HttpGetResponseHeader or HttpReadBody.
DECLARE SUB LONGINT HttpReadStatus(LONGINT h) EXTERNAL

' HttpGetResponseHeader - Get a response header value
'   h       - Connection handle (after HttpReadStatus)
'   hdrName - Header name (case-insensitive, e.g. "Content-Type")
'   Returns: Header value string, or "" if not present
DECLARE SUB STRING HttpGetResponseHeader(LONGINT h, ~
                                         STRING hdrName) EXTERNAL

' HttpResponseHeaderCount - Get number of response headers
'   h       - Connection handle (after HttpReadStatus)
'   Returns: Number of headers (0 if none or wrong handle)
DECLARE SUB LONGINT HttpResponseHeaderCount(LONGINT h) EXTERNAL

' HttpResponseHeaderName - Get response header name by index
'   h       - Connection handle (after HttpReadStatus)
'   idx     - Zero-based header index (0 to count-1)
'   Returns: Header name string, or "" if index out of range
DECLARE SUB STRING HttpResponseHeaderName(LONGINT h, ~
                                          LONGINT idx) EXTERNAL

' HttpResponseHeaderVal - Get response header value by index
'   h       - Connection handle (after HttpReadStatus)
'   idx     - Zero-based header index (0 to count-1)
'   Returns: Header value string, or "" if index out of range
'
' Example - enumerate all response headers:
'   cnt = HttpResponseHeaderCount(h)
'   FOR i = 0 TO cnt - 1
'     PRINT HttpResponseHeaderName(h, i); ": ";
'     PRINT HttpResponseHeaderVal(h, i)
'   NEXT i
DECLARE SUB STRING HttpResponseHeaderVal(LONGINT h, ~
                                         LONGINT idx) EXTERNAL

' HttpReadBody - Read a chunk of the response body
'   h       - Connection handle (after HttpReadStatus)
'   dataBuf - Address of buffer to read into
'   bufSz   - Maximum number of bytes to read
'   Returns: Number of bytes read (>0), or 0 when body is complete,
'            or negative error code on failure
'   Note: Handles Content-Length, chunked, and close-delimited
'         transfer modes transparently. Call in a loop until 0.
DECLARE SUB LONGINT HttpReadBody(LONGINT h, LONGINT dataBuf, ~
                                 LONGINT bufSz) EXTERNAL

' HttpClose - Close connection and free all associated resources
'   h       - Connection handle
'   Note: Performs SSL shutdown if applicable, then closes socket.
'         The handle is invalid after this call.
DECLARE SUB HttpClose(LONGINT h) EXTERNAL


' =====================================================================
' UTILITY FUNCTIONS
' =====================================================================

' UrlEncode - Percent-encode a string per RFC 3986
'   raw$    - String to encode
'   Returns: Encoded string (unreserved chars A-Z a-z 0-9 -_.~ pass
'            through; all others become %XX hex escapes)
'   Example: UrlEncode("hello world!") -> "hello%20world%21"
DECLARE SUB STRING UrlEncode(STRING raw) EXTERNAL

#endif
