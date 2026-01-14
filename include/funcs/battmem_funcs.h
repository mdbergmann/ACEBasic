#ifndef  FUNCS_BATTMEM_FUNCS_H
#define  FUNCS_BATTMEM_FUNCS_H

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

DECLARE FUNCTION ObtainBattSemaphore() LIBRARY battmem
DECLARE FUNCTION ReleaseBattSemaphore() LIBRARY battmem
DECLARE FUNCTION LONGINT ReadBattMem( APTR buffer, LONGINT offset, LONGINT length ) LIBRARY battmem
DECLARE FUNCTION LONGINT WriteBattMem( APTR buffer, LONGINT offset, LONGINT length ) LIBRARY battmem

#endif   /* FUNCS_BATTMEM_FUNCS_H */
