#ifndef PREFS_PALETTE_H
#define PREFS_PALETTE_H 1
/*
** palette.h for ACE Basic
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
** This are the StructPointer defines for palette.h
*/
#ifndef PalettePrefsPtr
#define PalettePrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for palette.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif


/*****************************************************************************/


#define ID_PALT 1346456660 


STRUCT PalettePrefs
 
    STRING pap_Reserved SIZE 16  /* 4*SIZEOF(LONGINT) */    /* SYSTEM reserved        */
    STRING pap_4ColorPens SIZE 64  /* 32*SIZEOF(SHORTINT) */
    STRING pap_8ColorPens SIZE 64  /* 32*SIZEOF(SHORTINT) */
    STRING pap_Colors SIZE 256                /* Used AS full 16-bit RGB values */
END STRUCT 


/*****************************************************************************/


#endif /* PREFS_PALETTE_H */
