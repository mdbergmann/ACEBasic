#ifndef  FUNCS_REALTIME_FUNCS_H
#define  FUNCS_REALTIME_FUNCS_H

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

/*--- functions in V37 OR higher (Release 2.04) ---*/

/* Locks */

DECLARE FUNCTION APTR LockRealTime( LONGINT lockType ) LIBRARY realtime
DECLARE FUNCTION UnlockRealTime( APTR lock ) LIBRARY realtime

/* Conductor */

DECLARE FUNCTION STRUCTPTR CreatePlayerA( STRUCTPTR tagList ) LIBRARY realtime
DECLARE FUNCTION DeletePlayer( STRUCTPTR player ) LIBRARY realtime
DECLARE FUNCTION BOOL SetPlayerAttrsA( STRUCTPTR player, STRUCTPTR tagList ) LIBRARY realtime
DECLARE FUNCTION LONGINT SetConductorState( STRUCTPTR player, LONGINT state, LONGINT time ) LIBRARY realtime
DECLARE FUNCTION BOOL ExternalSync( STRUCTPTR player, LONGINT minTime, LONGINT maxTime ) LIBRARY realtime
DECLARE FUNCTION STRUCTPTR NextConductor( STRUCTPTR previousConductor ) LIBRARY realtime
DECLARE FUNCTION STRUCTPTR FindConductor( STRPTR _NAME ) LIBRARY realtime
DECLARE FUNCTION LONGINT GetPlayerAttrsA( STRUCTPTR player, STRUCTPTR tagList ) LIBRARY realtime
#endif   /* FUNCS_REALTIME_FUNCS_H */
