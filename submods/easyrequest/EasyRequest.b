/*
** An EasyRequester SUBmod to use as a more capable
** alternative to ACE's inbuilt MsgBox function/statement.
**
** Requires Release 2.0 or higher of Amiga OS.
**
** By Nils Sjoholm. Modified by David Benn, July 1995, September 1996.
*/

#include <ace/acedef.h>

STRUCT EasyStruct
    LONGINT es_StructSize
    LONGINT es_Flags
    ADDRESS es_Title
    ADDRESS es_TextFormat
    ADDRESS es_GadgetFormat
END STRUCT

DECLARE FUNCTION LONGINT EasyRequestArgs(STRING title, ~
                                         STRING text, ~
                                         STRING gadtxt) LIBRARY intuition

SUB LONGINT EasyRequest(STRING wintitle, ~
                        STRING bodytext, ~
                        STRING gadgettext) EXTERNAL

DECLARE STRUCT EasyStruct es

  es->es_StructSize = SIZEOF(EasyStruct)
  es->es_Flags = 0
  es->es_Title = @wintitle
  es->es_TextFormat = @bodytext
  es->es_GadgetFormat = @gadgettext

  EasyRequest = EasyRequestArgs(null,es,null,null)
END SUB
