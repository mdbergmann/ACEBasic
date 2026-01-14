#ifndef  FUNCS_CONSOLE_FUNCS_H
#define  FUNCS_CONSOLE_FUNCS_H

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

DECLARE FUNCTION STRUCTPTR CDInputHandler( STRUCTPTR events, \
                                           STRUCTPTR consoleDevice ) LIBRARY console

DECLARE FUNCTION LONGINT RawKeyConvert( STRUCTPTR events, STRPTR buffer, \
                                        LONGINT length, \
                                        STRUCTPTR _keyMap ) LIBRARY console

/*--- functions in V36 or higher (Release 2.0) ---*/
#endif   /* FUNCS_CONSOLE_FUNCS_H */
