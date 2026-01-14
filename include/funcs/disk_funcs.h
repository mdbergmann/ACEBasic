#ifndef  FUNCS_DISK_FUNCS_H
#define  FUNCS_DISK_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

#ifndef  EXEC_TYPESH
#include <exec/types.h>
#endif

DECLARE FUNCTION BOOL AllocUnit( LONGINT unitNum ) LIBRARY disk
DECLARE FUNCTION FreeUnit( LONGINT unitNum ) LIBRARY disk
DECLARE FUNCTION STRUCTPTR GetUnit( STRUCTPTR unitPointer ) LIBRARY disk
DECLARE FUNCTION GiveUnit() LIBRARY disk
DECLARE FUNCTION LONGINT  GetUnitID( LONGINT unitNum ) LIBRARY disk

/*------ new for V37 ------*/
DECLARE FUNCTION LONGINT ReadUnitID( LONGINT unitNum ) LIBRARY disk

#endif   /* FUNCS_DISK_FUNCS_H */
