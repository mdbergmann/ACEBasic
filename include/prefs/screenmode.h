#ifndef PREFS_SCREENMODE_H
#define PREFS_SCREENMODE_H 1
/*
** screenmode.h for ACE Basic
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
** This are the StructPointer defines for screenmode.h
*/
#ifndef ScreenModePrefsPtr
#define ScreenModePrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for screenmode.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/*****************************************************************************/


#define ID_SCRM 1396920909 


STRUCT ScreenModePrefs
 
    STRING smp_Reserved SIZE 16  /* 4*SIZEOF(LONGINT) */
    LONGINT smp_DisplayID 
    SHORTINT smp_Width 
    SHORTINT smp_Height 
    SHORTINT smp_Depth 
    SHORTINT smp_Control 
END STRUCT 

/* flags for ScreenModePrefs.smp_Control */
#define SMB_AUTOSCROLL 1

#define SMF_AUTOSCROLL (1)


/*****************************************************************************/


#endif /* PREFS_SCREENMODE_H */
