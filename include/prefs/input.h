#ifndef PREFS_INPUT_H
#define PREFS_INPUT_H 1
/*
** input.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
**
*/

/*
** This are the StructPointer defines for input.h
*/
#ifndef InputPrefsPtr
#define InputPrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for input.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif

#ifndef DEVICES_TIMER_H
#include <devices/timer.h>
#endif


/*****************************************************************************/


#define ID_INPT 1229869140 


STRUCT InputPrefs
 
    STRING ip_Keymap SIZE 16  
    SHORTINT      ip_PointerTicks 
    timeval ip_DoubleClick 
    timeval ip_KeyRptDelay 
    timeval ip_KeyRptSpeed 
    SHORTINT       ip_MouseAccel 
END STRUCT 


/*****************************************************************************/


#endif /* PREFS_INPUT_H */
