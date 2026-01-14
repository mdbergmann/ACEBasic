#ifndef  FUNCS_BATTCLOCK_FUNCS_H
#define  FUNCS_BATTCLOCK_FUNCS_H

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

DECLARE FUNCTION ResetBattClock() LIBRARY battclock
DECLARE FUNCTION LONGINT ReadBattClock() LIBRARY battclock
DECLARE FUNCTION WriteBattClock( LONGINT time ) LIBRARY battclock

#endif   /* FUNCS_BATTCLOCK_FUNCS_H */
