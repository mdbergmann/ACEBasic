README + ASSERT Tests + Reentrancy State
=========================================
Branch: readme-assert-tests
Date: 2026-02-15

Status: ALL DONE - RUNTIME VERIFIED

Changes Made
============

1. submods/amissl/amissl.b (API change)
   - SslInit no longer takes bsdSockBase parameter
   - SslInit opens bsdsocket.library internally via _ExecOpenLib
   - SslCleanup closes bsdsocket.library
   - New module-level variable _bsdBase for internal base storage

2. include/submods/amissl.h
   - Updated SslInit signature: no parameter
   - Removed EXTERNAL amissl from usage docs

3. submods/tcpclient/tcpclient.b + include/submods/tcpclient.h
   - Updated SslInit call (no param)
   - All TcpConn struct fields prefixed with _ (private)
   - Sockaddr buffer moved from heap-allocated module variable to
     stack-local STRING in _TcpDoConnect (reentrancy)

4. submods/httpclient/httpclient.b + include/submods/httpclient.h
   - All HttpRequest struct fields prefixed with _ (private)
   - HttpResponse: public fields (statusCode, contentLen, respHdr*)
     grouped first, private fields (_bodyLeft, _xfer, _chunkState,
     _chunkLeft) prefixed with _ and moved to end
   - Streaming buffer: module-level _streamBuf replaced with
     stack-local STRING in HttpRequestStream
   - URL parse: module-level _urlHost$/Port/Path/SSL replaced with
     UrlParts struct, each caller declares local instance
   - Line reader: module-level _lineBuf/_lineResult$/_lineOk replaced
     with HttpLine struct, each caller declares local instance
   - Only _httpInited and _crlf$ remain as module variables (safe)

5. Documentation
   - _ prefix convention documented in tcpclient.h, httpclient.h,
     and httpclient README.txt
   - httpclient README.txt updated for struct-based API

6. ASSERT test conversions (11 test files)
   - test_amissl.b: ASSERT + SKIP for SSL_ERR_NO_LIB
   - test_tcpclient.b: ASSERT + SKIP for TCP_ERR_SSL
   - test_tcp.b, test_lowlevel.b, test_http_get.b, test_chunked.b,
     test_lowlevel_full.b, test_post.b, test_stream.b, test_https.b

Runtime Verification
====================
All 4 tcpclient tests pass (plain TCP, SSL, dual conn, buffered read)
All 8 httpclient tests pass (tcp, lowlevel, http_get, chunked,
  lowlevel_full, post, stream, https)
user-startup cleaned up (no build/test commands left)
