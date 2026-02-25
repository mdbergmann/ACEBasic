#ifndef JSON_H
#define JSON_H

#include <submods/hashmap.h>
#include <submods/dynarray.h>

{* ============== Constants ============== *}

CONST JS_SUCCESS      = 0
CONST JS_ERR_SYNTAX   = -1
CONST JS_ERR_DEPTH    = -2
CONST JS_ERR_OVERFLOW = -3
CONST JS_ERR_IO       = -4

CONST JsObject = 0
CONST JsArray  = 1

CONST JS_MAX_INPUT = 8192
CONST JS_MAX_DEPTH = 10

{* ============== Parser ============== *}

DECLARE SUB LONGINT JsParse(src$) EXTERNAL
DECLARE SUB LONGINT JsParseFile(SHORTINT ch%) EXTERNAL
DECLARE SUB STRING JsError$ EXTERNAL
DECLARE SUB SHORTINT JsRootType EXTERNAL

{* ============== Generator ============== *}

DECLARE SUB JsWrite(ADDRESS root&, SHORTINT ch%) EXTERNAL
DECLARE SUB JsWriteFmt(ADDRESS root&, SHORTINT ch%) EXTERNAL
DECLARE SUB STRING JsToStr$(ADDRESS root&) EXTERNAL

{* ============== Cleanup ============== *}

DECLARE SUB JsFree(ADDRESS root&) EXTERNAL

{* ============== Convenience ============== *}

DECLARE SUB JsMakeObj(Hashmap hm, LONGINT cap&) EXTERNAL
DECLARE SUB JsMakeArr(DynArray da, LONGINT cap&) EXTERNAL

#endif
