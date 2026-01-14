#ifndef  FUNCS_WB_FUNCS_H
#define  FUNCS_WB_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

/*--- functions in V36 OR higher (Release 2.0) ---*/
#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

DECLARE FUNCTION STRUCTPTR AddAppWindowA( LONGINT id, LONGINT userdata, \
                                          STRUCTPTR _window, STRUCTPTR msgport, \
                                          STRUCTPTR taglist ) LIBRARY workbench

DECLARE FUNCTION BOOL RemoveAppWindow( STRUCTPTR appWindow ) LIBRARY workbench

DECLARE FUNCTION STRUCTPTR AddAppIconA( LONGINT id, LONGINT userdata, \
                                        ADDRESS text, STRUCTPTR msgport, \
                                        STRUCTPTR lock, STRUCTPTR diskobj, \
                                        STRUCTPTR taglist ) LIBRARY workbench

DECLARE FUNCTION BOOL RemoveAppIcon( STRUCTPTR appIcon ) LIBRARY workbench

DECLARE FUNCTION STRUCTPTR AddAppMenuItemA( LONGINT id, LONGINT userdata, \
                                           ADDRESS text, STRUCTPTR msgport, STRUCTPTR taglist ) LIBRARY workbench

DECLARE FUNCTION BOOL RemoveAppMenuItem( STRUCTPTR appMenuItem ) LIBRARY workbench

/*--- functions in V39 OR higher (Release 3) ---*/


DECLARE FUNCTION WBInfo( BPTR lock, STRPTR _NAME, STRUCTPTR _SCREEN ) LIBRARY workbench


#endif   /* FUNCS_WB_FUNCS_H */
