#ifndef PREFS_ICONTROL_H
#define PREFS_ICONTROL_H 1
/*
** icontrol.h for ACE Basic
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
** This are the StructPointer defines for icontrol.h
*/
#ifndef IControlPrefsPtr
#define IControlPrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for icontrol.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/*****************************************************************************/


#define ID_ICTL 1229149260 


STRUCT IControlPrefs
 
    STRING ic_Reserved SIZE 16  /*  4*SIZEOF(LONGINT) */   /* SYSTEM reserved      */
    SHORTINT ic_TimeOut        /* Verify timeout       */
    SHORTINT  ic_MetaDrag       /* Meta drag mouse event    */
    LONGINT ic_Flags      /* IControl flags (see below)   */
    BYTE  ic_WBtoFront      /* CKey: WB to front        */
    BYTE  ic_FrontToBack    /* CKey: front screen to back   */
    BYTE  ic_ReqTrue        /* CKey: Requester TRUE     */
    BYTE  ic_ReqFalse       /* CKey: Requester FALSE    */
END STRUCT 

/* flags for IControlPrefs.ic_Flags */
#define ICB_COERCE_COLORS 0
#define ICB_COERCE_LACE   1
#define ICB_STRGAD_FILTER 2
#define ICB_MENUSNAP      3
#define ICB_MODEPROMOTE   4

#define ICF_COERCE_COLORS (1)
#define ICF_COERCE_LACE   (2)
#define ICF_STRGAD_FILTER (4)
#define ICF_MENUSNAP      (8)
#define ICF_MODEPROMOTE   (16)


/*****************************************************************************/


#endif /* PREFS_ICONTROL_H */
