#ifndef  FUNCS_RAMDRIVE_FUNCS_H
#define  FUNCS_RAMDRIVE_FUNCS_H

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

/*--- functions in V34 OR higher (Release 1.3) ---*/
DECLARE FUNCTION STRPTR KillRAD0() LIBRARY ramdrive
/*--- functions in V36 OR higher (Release 2.0) ---*/
DECLARE FUNCTION STRPTR KillRAD( LONGINT unit ) LIBRARY ramdrive
#endif   /* FUNCS_RAMDRIVE_FUNCS_H */
