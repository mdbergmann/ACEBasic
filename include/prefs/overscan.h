#ifndef PREFS_OVERSCAN_H
#define PREFS_OVERSCAN_H 1
/*
** overscan.h for ACE Basic
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
** This are the StructPointer defines for overscan.h
*/
#ifndef OverscanPrefsPtr
#define OverscanPrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for overscan.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif


/*****************************************************************************/


#define ID_OSCN 1330856782 

#define OSCAN_MAGIC  &HFEDCBA89


STRUCT OverscanPrefs
 
    LONGINT        os_Reserved 
    LONGINT        os_Magic 
    SHORTINT        os_HStart 
    SHORTINT        os_HStop 
    SHORTINT        os_VStart 
    SHORTINT        os_VStop 
    LONGINT        os_DisplayID 
    _Point os_ViewPos 
    _Point os_Text 
    Rectangle os_Standard 
END STRUCT 

/* os_HStart,  os_HStop,  os_VStart,  os_VStop can only be looked at if
 * os_Magic equals OSCAN_MAGIC. If os_Magic is set to any other value, 
 * these four fields are undefined
 */


/*****************************************************************************/


#endif /* PREFS_OVERSCAN_H */
