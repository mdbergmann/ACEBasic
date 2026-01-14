#ifndef PREFS_FONT_H
#define PREFS_FONT_H 1
/*
** font.h for ACE Basic
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
** This are the StructPointer defines for font.h
*/
#ifndef FontPrefsPtr
#define FontPrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for font.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif

#ifndef GRAPHICS_TEXT_H
#include <graphics/text.h>
#endif


/*****************************************************************************/


#define ID_FONT 1179602516 


#define FONTNAMESIZE (128)

STRUCT FontPrefs
 
    STRING fp_Reserved SIZE 12  /* 3*SIZEOF(LONGINT) */
    SHORTINT       fp_Reserved2 
    SHORTINT       fp_Type 
    BYTE        fp_FrontPen 
    BYTE        fp_BackPen 
    BYTE        fp_DrawMode 
    TextAttr fp_TextAttr 
    STRING fp_Name SIZE 128  /* FONTNAMESIZE  */
END STRUCT 


/* constants for FontPrefs.fp_Type */
#define FP_WBFONT     0
#define FP_SYSFONT    1
#define FP_SCREENFONT 2


/*****************************************************************************/


#endif /* PREFS_FONT_H */
