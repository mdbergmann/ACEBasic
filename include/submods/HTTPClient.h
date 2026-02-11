#ifndef HTTPCLIENT_H
#define HTTPCLIENT_H 1

{* HTTPClient.h - HTTP/1.1 client submod for ACE BASIC *}

' Error codes
CONST HTTP_OK              = 0
CONST HTTP_ERR_SOCKET      = -1
CONST HTTP_ERR_DNS         = -2
CONST HTTP_ERR_SEND        = -3
CONST HTTP_ERR_RECV        = -4
CONST HTTP_ERR_SSL_INIT    = -5
CONST HTTP_ERR_SSL_CONNECT = -6
CONST HTTP_ERR_PARSE       = -7
CONST HTTP_ERR_OVERFLOW    = -8
CONST HTTP_ERR_CALLBACK    = -9
CONST HTTP_ERR_NO_LIB      = -10

' Callback return values
CONST HTTP_CONTINUE        = 0
CONST HTTP_ABORT           = 1

' SSL flag
CONST HTTP_SSL             = 1
CONST HTTP_PLAIN           = 0

' --- High-level convenience API ---
DECLARE SUB LONGINT HttpGet(STRING url, STRING resp) EXTERNAL
DECLARE SUB LONGINT HttpHead(STRING url) EXTERNAL
DECLARE SUB LONGINT HttpPost(STRING url, STRING ct, ~
                             STRING body, STRING resp) EXTERNAL
DECLARE SUB LONGINT HttpPut(STRING url, STRING ct, ~
                            STRING body, STRING resp) EXTERNAL
DECLARE SUB LONGINT HttpRequest(STRING url, STRING meth, ~
                                STRING ct, STRING body, ~
                                STRING resp) EXTERNAL

' --- Streaming API ---
DECLARE SUB LONGINT HttpGetStream(STRING url, ~
                                  ADDRESS onRecv) EXTERNAL
DECLARE SUB LONGINT HttpPostStream(STRING url, STRING ct, ~
                                   ADDRESS onSend, ~
                                   ADDRESS onRecv) EXTERNAL
DECLARE SUB LONGINT HttpPutStream(STRING url, STRING ct, ~
                                  ADDRESS onSend, ~
                                  ADDRESS onRecv) EXTERNAL
DECLARE SUB LONGINT HttpRequestStream(STRING url, STRING meth, ~
                                      STRING ct, ADDRESS onSend, ~
                                      ADDRESS onRecv) EXTERNAL

' --- Low-level handle API ---
DECLARE SUB LONGINT HttpOpen(STRING host, LONGINT port, ~
                             LONGINT ssl) EXTERNAL
DECLARE SUB HttpSetHeader(LONGINT h, STRING name, ~
                          STRING val) EXTERNAL
DECLARE SUB LONGINT HttpSendRequest(LONGINT h, STRING meth, ~
                                    STRING path) EXTERNAL
DECLARE SUB LONGINT HttpWriteBody(LONGINT h, LONGINT buf, ~
                                  LONGINT len) EXTERNAL
DECLARE SUB LONGINT HttpWriteBodyChunked(LONGINT h, ~
                                         LONGINT buf, ~
                                         LONGINT len) EXTERNAL
DECLARE SUB LONGINT HttpReadStatus(LONGINT h) EXTERNAL
DECLARE SUB STRING HttpGetResponseHeader(LONGINT h, ~
                                         STRING name) EXTERNAL
DECLARE SUB LONGINT HttpReadBody(LONGINT h, LONGINT buf, ~
                                 LONGINT sz, ~
                                 LONGINT rd) EXTERNAL
DECLARE SUB HttpClose(LONGINT h) EXTERNAL

' --- Utility ---
DECLARE SUB STRING UrlEncode(STRING raw) EXTERNAL

#endif
