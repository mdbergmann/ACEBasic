#ifndef  FUNCS_KEYMAP_FUNCS_H
#define  FUNCS_KEYMAP_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

/*--- functions in V36 OR higher (Release 2.0) ---*/
DECLARE FUNCTION SetKeyMapDefault( STRUCTPTR _keyMap ) LIBRARY keymap
DECLARE FUNCTION STRUCTPTR AskKeyMapDefault() LIBRARY keymap
DECLARE FUNCTION SHORTINT MapRawKey( STRUCTPTR event, STRPTR buffer, LONGINT length, \
                                     STRUCTPTR _keyMap ) LIBRARY keymap
DECLARE FUNCTION LONGINT MapANSI( STRPTR _STRING, LONGINT count, STRPTR buffer, LONGINT length, \
                                  STRUCTPTR _keyMap ) LIBRARY keymap
#endif   /* FUNCS_KEYMAP_FUNCS_H */
