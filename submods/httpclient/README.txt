HTTP/1.1 Client Library for ACE BASIC
======================================

An HTTP/1.1 client submodule for ACE BASIC with optional HTTPS support
via AmiSSL. Provides three API tiers for different use cases.

For detailed API documentation, constants, and function signatures see:
  include/submods/HTTPClient.h


Requirements
------------

- bsdsocket.library (AmiTCP, Roadshow, or compatible TCP/IP stack)
- amisslmaster.library + amissl.library (optional, for HTTPS only)


API Overview
------------

The library provides three API tiers:

1. High-level convenience (one-call, string-based):
   HttpGet, HttpPost, HttpPut, HttpHead, HttpRequest

2. Streaming (callback-based for large/binary transfers):
   HttpGetStream, HttpPostStream, HttpPutStream, HttpRequestStream

3. Low-level handle-based (full control):
   HttpOpen, HttpSetHeader, HttpSendRequest, HttpWriteBody,
   HttpWriteBodyChunked, HttpReadStatus, HttpGetResponseHeader,
   HttpResponseHeaderCount, HttpResponseHeaderName,
   HttpResponseHeaderVal, HttpReadBody, HttpClose

Plus utility: UrlEncode

See HTTPClient.h for full signatures and usage documentation.


Quick Example
-------------

High-level GET:

    REM #using ace:submods/httpclient/httpclient.o
    #include <submods/HTTPClient.h>

    STRING resp$ SIZE 8192
    LONGINT st

    st = HttpGet("http://httpbin.org/get", SADD(resp$), 8192)
    IF st = 200 THEN PRINT resp$

Low-level POST:

    REM #using ace:submods/httpclient/httpclient.o
    #include <submods/HTTPClient.h>

    LONGINT h, st
    STRING body$ SIZE 64
    body$ = "key=value"

    h = HttpOpen("httpbin.org", 80, HTTP_PLAIN)
    HttpSetHeader(h, "Content-Type", "application/x-www-form-urlencoded")
    HttpSetHeader(h, "Content-Length", "9")
    st = HttpSendRequest(h, "POST", "/post")
    HttpWriteBody(h, SADD(body$), LEN(body$))
    st = HttpReadStatus(h)
    PRINT "Status:"; st
    HttpClose(h)


Building
--------

On Amiga (or emulator):

    cd ACE:submods/httpclient
    bas -m httpclient

This compiles httpclient.b as a module, producing httpclient.o


Using in Your Programs
----------------------

1. Include the header and declare the external module:

    #include <submods/HTTPClient.h>

2. Add a #using directive so bas auto-links the module:

    REM #using ace:submods/httpclient/httpclient.o

3. Compile your program:

    bas myprogram

   Or link manually:

    bas myprogram ace:submods/httpclient/httpclient.o


Running Tests
-------------

A test runner script is provided that builds the module and runs all
tests in sequence:

    cd ACE:submods/httpclient
    execute RunTests ace:test-output.txt

Individual tests can also be compiled and run separately:

    bas test_http_get
    test_http_get

Tests require a working network connection (they contact httpbin.org
and www.google.com). The HTTPS tests require AmiSSL and will print
SKIP if it is not available.

Test files:
  test_tcp.b            - TCP connection foundation
  test_lowlevel.b       - Basic low-level API (GET)
  test_lowlevel_full.b  - Comprehensive low-level API coverage
  test_http_get.b       - HttpHead + low-level GET regression
  test_chunked.b        - Chunked transfer decoding
  test_post.b           - POST, PUT, UrlEncode
  test_stream.b         - Streaming callbacks
  test_https.b          - HTTPS via AmiSSL


Limitations
-----------

- Single connection at a time (call HttpClose before re-opening)
- Maximum 32 response headers stored per connection
- No certificate verification (accepts all certificates)
- No HTTP/2 (HTTP/1.1 only)
- No automatic redirect following
- No cookie management (use HttpSetHeader manually)
- No keep-alive connection pooling
- Not thread-safe (single process only)


Files
-----

httpclient.b      - Library source code
httpclient.o      - Compiled module (after building)
RunTests          - AmigaDOS test runner script
test_*.b          - Test programs
README.txt        - This file
LICENSE           - Apache License 2.0

include/submods/HTTPClient.h - Header with declarations and documentation
