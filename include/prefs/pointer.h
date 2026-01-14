#ifndef PREFS_POINTER_H
#define PREFS_POINTER_H 1
/*
** pointer.h for ACE Basic
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
** This are the StructPointer defines for pointer.h
*/
#ifndef PointerPrefsPtr
#define PointerPrefsPtr ADDRESS
#endif
#ifndef RGBTablePtr
#define RGBTablePtr ADDRESS
#endif
/*
** End of StructPointer defines for pointer.h
*/


/*****************************************************************************/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif

/*****************************************************************************/

#define ID_PNTR 1347310674 

/*****************************************************************************/

STRUCT PointerPrefs
 
    STRING pp_Reserved SIZE 16  /* 4*SIZEOF(LONGINT)  */
    SHORTINT pp_Which              /* 0=NORMAL,  1=BUSY */
    SHORTINT pp_Size               /* see <intuition/pointerclass.h> */
    SHORTINT pp_Width              /* Width in pixels */
    SHORTINT pp_Height                 /* Height in pixels */
    SHORTINT pp_Depth              /* Depth */
    SHORTINT pp_YSize              /* YSize */
    SHORTINT pp_X 
    SHORTINT   pp_Y                /* Hotspot */

    /* Color Table:  numEntries = (1) - 1 */

    /* Data follows */
END STRUCT 

/*****************************************************************************/

/* constants for PointerPrefs.pp_Which */
#define WBP_NORMAL  0
#define WBP_BUSY    1

/*****************************************************************************/

STRUCT RGBTable
 
    BYTE  t_Red 
    BYTE  t_Green 
    BYTE  t_Blue 
END STRUCT 

/*****************************************************************************/

#endif /* PREFS_POINTER_H */
