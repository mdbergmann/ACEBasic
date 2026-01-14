#ifndef PREFS_PRINTERGFX_H
#define PREFS_PRINTERGFX_H 1
/*
** printergfx.h for ACE Basic
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
** This are the StructPointer defines for printergfx.h
*/
#ifndef PrinterGfxPrefsPtr
#define PrinterGfxPrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for printergfx.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/*****************************************************************************/


#define ID_PGFX 1346848344 


STRUCT PrinterGfxPrefs
 
    STRING pg_Reserved SIZE 16  /*  4*SIZEOF(LONGINT) */
    SHORTINT pg_Aspect 
    SHORTINT pg_Shade 
    SHORTINT pg_Image 
    SHORTINT  pg_Threshold 
    BYTE  pg_ColorCorrect 
    BYTE  pg_Dimensions 
    BYTE  pg_Dithering 
    SHORTINT pg_GraphicFlags 
    BYTE  pg_PrintDensity       /* Print density 1 - 7 */
    SHORTINT pg_PrintMaxWidth 
    SHORTINT pg_PrintMaxHeight 
    BYTE  pg_PrintXOffset 
    BYTE  pg_PrintYOffset 
END STRUCT 

/* constants for PrinterGfxPrefs.pg_Aspect */
#define PA_HORIZONTAL 0
#define PA_VERTICAL   1

/* constants for PrinterGfxPrefs.pg_Shade */
#define PS_BW       0
#define PS_GREYSCALE    1
#define PS_COLOR    2
#define PS_GREY_SCALE2  3

/* constants for PrinterGfxPrefs.pg_Image */
#define PI_POSITIVE 0
#define PI_NEGATIVE 1

/* flags for PrinterGfxPrefs.pg_ColorCorrect */
#define PCCB_RED   1    /* color correct red shades   */
#define PCCB_GREEN 2    /* color correct green shades */
#define PCCB_BLUE  3    /* color correct blue shades  */

#define PCCF_RED   (1)
#define PCCF_GREEN (2)
#define PCCF_BLUE  (4)

/* constants for PrinterGfxPrefs.pg_Dimensions */
#define PD_IGNORE   0  /* ignore max width/height settings */
#define PD_BOUNDED  1  /* use max w/h as boundaries    */
#define PD_ABSOLUTE 2  /* use max w/h as absolutes     */
#define PD_PIXEL    3  /* use max w/h as prt pixels    */
#define PD_MULTIPLY 4  /* use max w/h as multipliers       */

/* constants for PrinterGfxPrefs.pg_Dithering */
#define PD_ORDERED  0  /* ordered dithering */
#define PD_HALFTONE 1  /* halftone dithering    */
#define PD_FLOYD    2  /* Floyd-Steinberg dithering */

/* flags for PrinterGfxPrefs.pg_GraphicsFlags */
#define PGFB_CENTER_IMAGE   0   /* center image on paper */
#define PGFB_INTEGER_SCALING    1   /* force integer scaling */
#define PGFB_ANTI_ALIAS     2   /* anti-alias image  */

#define PGFF_CENTER_IMAGE   (1)
#define PGFF_INTEGER_SCALING    (2)
#define PGFF_ANTI_ALIAS     (4)


/*****************************************************************************/


#endif /* PREFS_PRINTERGFX_H */
