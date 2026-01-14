#ifndef  FUNCS_DISKFONT_FUNCS
#define  FUNCS_DISKFONT_FUNCS

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

DECLARE FUNCTION STRUCTPTR OpenDiskFont( STRUCTPTR textAttr ) LIBRARY diskfont
DECLARE FUNCTION LONGINT AvailFonts( STRPTR buffer, LONGINT bufBytes, LONGINT flags ) LIBRARY diskfont

/*--- functions in V34 or higher (Release 1.3) ---*/
DECLARE FUNCTION STRUCTPTR NewFontContents( BPTR fontsLock, STRPTR fontName ) LIBRARY diskfont
DECLARE FUNCTION DisposeFontContents( STRUCTPTR fontContentsHeader ) LIBRARY diskfont

/*--- functions in V36 or higher (Release 2.0) ---*/
DECLARE FUNCTION STRUCTPTR NewScaledDiskFont( STRUCTPTR sourceFont, \
                                              STRUCTPTR destTextAttr ) LIBRARY diskfont

#endif   /* FUNCS_DISKFONT_FUNCS */
