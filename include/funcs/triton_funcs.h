#ifndef FUNCS_TRITON_FUNCS_H
#define FUNCS_TRITON_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 18-Oct-95
**
*/       

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

DECLARE FUNCTION LONGINT TR_AutoRequest(STRUCTPTR app, STRUCTPTR project, \
                                        STRUCTPTR taglist) LIBRARY triton
DECLARE FUNCTION TR_CloseProject(STRUCTPTR project) LIBRARY triton
DECLARE FUNCTION TR_CloseWindowSafely(STRUCTPTR win) LIBRARY triton
DECLARE FUNCTION STRUCTPTR TR_CreateApp(STRUCTPTR taglist) LIBRARY triton
DECLARE FUNCTION TR_DeleteApp(STRUCTPTR app) LIBRARY triton
DECLARE FUNCTION LONGINT TR_EasyRequest(STRUCTPTR app, STRPTR BodyFmt, \
                                        STRPTR GadFmt, STRUCTPTR taglist) LIBRARY triton
DECLARE FUNCTION LONGINT TR_GetAttribute(STRUCTPTR project, LONGINT id, \
                                         LONGINT attribute) LIBRARY triton
DECLARE FUNCTION STRPTR TR_GetErrorString(SHORTINT number) LIBRARY triton
DECLARE FUNCTION SHORTINT TR_GetLastError(STRUCTPTR app) LIBRARY triton
DECLARE FUNCTION STRUCTPTR TR_GetMsg(STRUCTPTR app) LIBRARY triton
DECLARE FUNCTION TR_LockProject(STRUCTPTR project) LIBRARY triton
DECLARE FUNCTION STRUCTPTR TR_LockScreen(STRUCTPTR project) LIBRARY triton
DECLARE FUNCTION STRUCTPTR TR_ObtainWindow(STRUCTPTR project) LIBRARY triton
DECLARE FUNCTION STRUCTPTR TR_OpenProject(STRUCTPTR app, STRUCTPTR taglist) LIBRARY triton
DECLARE FUNCTION TR_ReleaseWindow(STRUCTPTR win) LIBRARY triton
DECLARE FUNCTION TR_ReplyMsg(STRUCTPTR msg) LIBRARY triton
DECLARE FUNCTION TR_SetAttribute(STRUCTPTR project, LONGINT id, LONGINT attribute, \
                                 LONGINT value) LIBRARY triton
DECLARE FUNCTION TR_UnlockProject(STRUCTPTR project) LIBRARY triton
DECLARE FUNCTION TR_UnlockScreen(STRUCTPTR scr) LIBRARY triton
DECLARE FUNCTION LONGINT TR_Wait(STRUCTPTR app, LONGINT otherbits) LIBRARY triton
DECLARE FUNCTION LONGINT TR_SendMessage(STRUCTPTR project, LONGINT objectid, \
                                        LONGINT messageid, \
                                        ADDRESS messagedata) LIBRARY triton
DECLARE FUNCTION LONGINT TR_FirstOccurance(LONGINT ch, STRPTR str) LIBRARY triton
DECLARE FUNCTION LONGINT TR_NumOccurances(LONGINT ch, STRPTR str) LIBRARY triton

#endif

