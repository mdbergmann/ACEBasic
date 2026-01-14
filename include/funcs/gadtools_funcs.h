#ifndef  FUNCS_GADTOOLS_FUNCS_H
#define  FUNCS_GADTOOLS_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

/*--- functions in V36 OR higher (Release 2.0) ---*/

/* GADGET Functions */

DECLARE FUNCTION STRUCTPTR CreateGadgetA( LONGINT kind, STRUCTPTR gad, \
                                          STRUCTPTR ng, STRUCTPTR taglist ) LIBRARY gadtools
DECLARE FUNCTION FreeGadgets( STRUCTPTR gad ) LIBRARY gadtools
DECLARE FUNCTION GT_SetGadgetAttrsA( STRUCTPTR gad, STRUCTPTR win, \
                                      STRUCTPTR req, STRUCTPTR taglist ) LIBRARY gadtools

/* MENU functions */

DECLARE FUNCTION STRUCTPTR CreateMenusA( STRUCTPTR newmenu, STRUCTPTR taglist ) LIBRARY gadtools
DECLARE FUNCTION FreeMenus( STRUCTPTR _MENU ) LIBRARY gadtools
DECLARE FUNCTION BOOL LayoutMenuItemsA( STRUCTPTR firstitem, APTR vi, \
                                        STRUCTPTR taglist ) LIBRARY gadtools
DECLARE FUNCTION BOOL LayoutMenusA( STRUCTPTR firstmenu, APTR vi, STRUCTPTR taglist ) LIBRARY gadtools

/* Misc Event-Handling Functions */

DECLARE FUNCTION STRUCTPTR GT_GetIMsg( STRUCTPTR iport ) LIBRARY gadtools
DECLARE FUNCTION GT_ReplyIMsg( STRUCTPTR imsg ) LIBRARY gadtools
DECLARE FUNCTION GT_RefreshWindow( STRUCTPTR win, STRUCTPTR req ) LIBRARY gadtools
DECLARE FUNCTION GT_BeginRefresh( STRUCTPTR win ) LIBRARY gadtools
DECLARE FUNCTION GT_EndRefresh( STRUCTPTR win, LONGINT complete ) LIBRARY gadtools
DECLARE FUNCTION STRUCTPTR GT_FilterIMsg( STRUCTPTR imsg ) LIBRARY gadtools
DECLARE FUNCTION STRUCTPTR GT_PostFilterIMsg( STRUCTPTR imsg ) LIBRARY gadtools
DECLARE FUNCTION STRUCTPTR CreateContext( STRUCTPTR glistptr ) LIBRARY gadtools

/* Rendering Functions */

DECLARE FUNCTION DrawBevelBoxA( STRUCTPTR rport, LONGINT left, LONGINT top, LONGINT _WIDTH, \
                                 LONGINT height, STRUCTPTR taglist ) LIBRARY gadtools

/* Visuals Functions */

DECLARE FUNCTION APTR GetVisualInfoA( STRUCTPTR _SCREEN, STRUCTPTR taglist ) LIBRARY gadtools
DECLARE FUNCTION FreeVisualInfo( APTR vi ) LIBRARY gadtools

/*--- functions in V39 OR higher (Release 3) ---*/

DECLARE FUNCTION LONGINT GT_GetGadgetAttrsA( STRUCTPTR gad, STRUCTPTR win, \
                                             STRUCTPTR req, STRUCTPTR taglist ) LIBRARY gadtools

#endif   /* FUNCS_GADTOOLS_FUNCS_H */
