#ifndef  FUNCS_LOWLEVEL_FUNCS_H
#define  FUNCS_LOWLEVEL_FUNCS_H

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

/*--- functions in V40 OR higher (Release 3.1) ---*/

/* CONTROLLER HANDLING */

DECLARE FUNCTION LONGINT ReadJoyPort( LONGINT port ) LIBRARY lowlevel

/* LANGUAGE HANDLING */

DECLARE FUNCTION LONGINT GetLanguageSelection() LIBRARY lowlevel

/* KEYBOARD HANDLING */

DECLARE FUNCTION LONGINT GetKey() LIBRARY lowlevel
DECLARE FUNCTION QueryKeys( STRUCTPTR queryArray, LONGINT arraySize ) LIBRARY lowlevel
DECLARE FUNCTION APTR AddKBInt( APTR intRoutine, APTR intData ) LIBRARY lowlevel
DECLARE FUNCTION RemKBInt( APTR intHandle ) LIBRARY lowlevel

/* SYSTEM HANDLING */

DECLARE FUNCTION LONGINT SystemControlA( STRUCTPTR tagList ) LIBRARY lowlevel

/* TIMER HANDLING */

DECLARE FUNCTION APTR AddTimerInt( APTR intRoutine, APTR intData ) LIBRARY lowlevel
DECLARE FUNCTION RemTimerInt( APTR intHandle ) LIBRARY lowlevel
DECLARE FUNCTION StopTimerInt( APTR intHandle ) LIBRARY lowlevel
DECLARE FUNCTION StartTimerInt( APTR intHandle, LONGINT timeInterval, \
                                LONGINT continuous ) LIBRARY lowlevel
DECLARE FUNCTION LONGINT ElapsedTime( STRUCTPTR context ) LIBRARY lowlevel

/* VBLANK HANDLING */

DECLARE FUNCTION APTR AddVBlankInt( APTR intRoutine, APTR intData ) LIBRARY lowlevel
DECLARE FUNCTION RemVBlankInt( APTR intHandle ) LIBRARY lowlevel

/* MORE CONTROLLER HANDLING */

DECLARE FUNCTION BOOL SetJoyPortAttrsA( LONGINT portNumber, STRUCTPTR tagList ) LIBRARY lowlevel
#endif   /* FUNCS_LOWLEVEL_FUNCS_H */
