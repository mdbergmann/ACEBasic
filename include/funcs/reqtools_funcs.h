#ifndef FUNCS_REQTOOLS_FUNCS_H
#define FUNCS_REQTOOLS_FUNCS_H 1

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

/************
* Functions *
************/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

DECLARE FUNCTION APTR rtAllocRequestA(LONGINT _type, \
                                         STRUCTPTR taglist) LIBRARY reqtools
DECLARE FUNCTION rtFreeRequest(APTR req) LIBRARY reqtools
DECLARE FUNCTION rtFreeReqBuffer(APTR req) LIBRARY reqtools
DECLARE FUNCTION LONGINT rtChangeReqAttrA(APTR req, \
                                          STRUCTPTR taglist) LIBRARY reqtools
DECLARE FUNCTION APTR rtFileRequestA(STRUCTPTR filereq, STRING file, \
                                     STRING title, STRUCTPTR taglist) LIBRARY reqtools
DECLARE FUNCTION rtFreeFileList(STRUCTPTR filelist) LIBRARY reqtools
DECLARE FUNCTION LONGINT rtEZRequestA(STRING bodyfmt, STRING gadfmt, \
                                      STRUCTPTR reqinfo, APTR argarray, \
                                      STRUCTPTR taglist) LIBRARY reqtools
DECLARE FUNCTION LONGINT rtGetStringA(STRING buffer, LONGINT maxchars, \
                                      STRING title, STRUCTPTR reqinfo, \
                                      STRUCTPTR taglist) LIBRARY reqtools
DECLARE FUNCTION LONGINT rtGetLongA(ADDRESS longptr, STRING title, \
                                    STRUCTPTR reqinfo, \
                                    STRUCTPTR taglist) LIBRARY reqtools
DECLARE FUNCTION LONGINT rtFontRequestA(STRUCTPTR fontreq, STRING title, \
                                        STRUCTPTR taglist) LIBRARY reqtools
DECLARE FUNCTION LONGINT rtPaletteRequestA(STRING title, STRUCTPTR reqinfo, \
                                           STRUCTPTR taglist) LIBRARY reqtools
DECLARE FUNCTION LONGINT rtReqHandlerA(STRUCTPTR handlerinfo, LONGINT sigs, \
                                       STRUCTPTR taglist) LIBRARY reqtools
DECLARE FUNCTION rtSetWaitPointer(STRUCTPTR win) LIBRARY reqtools
DECLARE FUNCTION LONGINT rtGetVScreenSize(STRUCTPTR scr, ADDRESS widthptr, \
                                          ADDRESS heightptr) LIBRARY reqtools
DECLARE FUNCTION rtSetReqPosition(LONGINT reqpos, STRUCTPTR newwin, STRUCTPTR scr, \
                                  STRUCTPTR win) LIBRARY reqtools
DECLARE FUNCTION rtSpread(ADDRESS posarray, ADDRESS sizearray, LONGINT length, \
                          LONGINT min,  LONGINT max, LONGINT num) LIBRARY reqtools
DECLARE FUNCTION rtScreenToFrontSafely(STRUCTPTR scr) LIBRARY reqtools
DECLARE FUNCTION LONGINT rtScreenModeRequestA(STRUCTPTR screenmodereq, \
                                              STRING title, \
                                              STRUCTPTR taglist) LIBRARY reqtools
DECLARE FUNCTION rtCloseWindowSafely(STRUCTPTR win) LIBRARY reqtools
DECLARE FUNCTION APTR rtLockWindow(STRUCTPTR win) LIBRARY reqtools
DECLARE FUNCTION rtUnlockWindow(STRUCTPTR win, APTR winlock) LIBRARY reqtools

#endif

