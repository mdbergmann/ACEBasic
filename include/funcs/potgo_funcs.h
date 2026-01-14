#ifndef  FUNCS_POTGO_FUNCS_H
#define  FUNCS_POTGO_FUNCS_H

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

DECLARE FUNCTION SHORTINT AllocPotBits( LONGINT bits ) LIBRARY potgo
DECLARE FUNCTION FreePotBits( LONGINT bits ) LIBRARY potgo
DECLARE FUNCTION WritePotgo( LONGINT word, LONGINT mask ) LIBRARY potgo
#endif   /* FUNCS_POTGO_FUNCS_H */
