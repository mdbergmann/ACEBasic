#ifndef PREFS_PRINTERPS_H
#define PREFS_PRINTERPS_H 1
/*
** printerps.h for ACE Basic
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
** This are the StructPointer defines for printerps.h
*/
#ifndef PrinterPSPrefsPtr
#define PrinterPSPrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for printerps.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/*****************************************************************************/


#define ID_PSPD 1347637316 


STRUCT PrinterPSPrefs
 
    STRING ps_Reserved SIZE 16  /* 4*SIZEOF(LONGINT) */       /* SYSTEM reserved */

    /* Global printing attributes */
    BYTE  ps_DriverMode 
    BYTE  ps_PaperFormat 
    STRING ps_Reserved1 SIZE 2  
    LONGINT  ps_Copies 
    LONGINT  ps_PaperWidth 
    LONGINT  ps_PaperHeight 
    LONGINT  ps_HorizontalDPI 
    LONGINT  ps_VerticalDPI 

    /* Text Options */
    BYTE  ps_Font 
    BYTE  ps_Pitch 
    BYTE  ps_Orientation 
    BYTE  ps_Tab 
    STRING ps_Reserved2 SIZE 8  

    /* Text Dimensions */
    LONGINT  ps_LeftMargin 
    LONGINT  ps_RightMargin 
    LONGINT  ps_TopMargin 
    LONGINT  ps_BottomMargin 
    LONGINT  ps_FontPointSize 
    LONGINT  ps_Leading 
    STRING ps_Reserved3 SIZE 8  

    /* Graphics Options */
    LONGINT  ps_LeftEdge 
    LONGINT  ps_TopEdge 
    LONGINT  ps_Width 
    LONGINT  ps_Height 
    BYTE  ps_Image 
    BYTE  ps_Shading 
    BYTE  ps_Dithering 
    STRING ps_Reserved4 SIZE 9  

    /* Graphics Scaling */
    BYTE  ps_Aspect 
    BYTE  ps_ScalingType 
    BYTE  ps_Reserved5 
    BYTE  ps_Centering 
    STRING ps_Reserved6 SIZE 8  
END STRUCT 

/* All measurements are in Millipoints which is 1/1000 of a point,  or
 * in other words 1/72000 of an inch
 */

/* constants for PrinterPSPrefs.ps_DriverMode */
#define DM_POSTSCRIPT  0
#define DM_PASSTHROUGH 1

/* constants for PrinterPSPrefs.ps_PaperFormat */
#define PF_USLETTER 0
#define PF_USLEGAL  1
#define PF_A4       2
#define PF_CUSTOM   3

/* constants for PrinterPSPrefs.ps_Font */
#define FONT_COURIER      0
#define FONT_TIMES    1
#define FONT_HELVETICA    2
#define FONT_HELV_NARROW  3
#define FONT_AVANTGARDE   4
#define FONT_BOOKMAN      5
#define FONT_NEWCENT      6
#define FONT_PALATINO     7
#define FONT_ZAPFCHANCERY 8

/* constants for PrinterPSPrefs.ps_Pitch */
#define PITCH_NORMAL     0
#define PITCH_COMPRESSED 1
#define PITCH_EXPANDED   2

/* constants for PrinterPSPrefs.ps_Orientation */
#define ORIENT_PORTRAIT  0
#define ORIENT_LANDSCAPE 1

/* constants for PrinterPSPrefs.ps_Tab */
#define TAB_4     0
#define TAB_8     1
#define TAB_QUART 2
#define TAB_HALF  3
#define TAB_INCH  4

/* constants for PrinterPSPrefs.ps_Image */
#define IM_POSITIVE 0
#define IM_NEGATIVE 1

/* constants for PrinterPSPrefs.ps_Shading */
#define SHAD_BW        0
#define SHAD_GREYSCALE 1
#define SHAD_COLOR     2

/* constants for PrinterPSPrefs.ps_Dithering */
#define DITH_DEFAULT 0
#define DITH_DOTTY   1
#define DITH_VERT    2
#define DITH_HORIZ   3
#define DITH_DIAG    4

/* constants for PrinterPSPrefs.ps_Aspect */
#define ASP_HORIZ 0
#define ASP_VERT  1

/* constants for PrinterPSPrefs.ps_ScalingType */
#define ST_ASPECT_ASIS    0
#define ST_ASPECT_WIDE    1
#define ST_ASPECT_TALL    2
#define ST_ASPECT_BOTH    3
#define ST_FITS_WIDE      4
#define ST_FITS_TALL      5
#define ST_FITS_BOTH      6

/* constants for PrinterPSPrefs.ps_Centering */
#define CENT_NONE  0
#define CENT_HORIZ 1
#define CENT_VERT  2
#define CENT_BOTH  3


/*****************************************************************************/


#endif /* PREFS_PRINTERPS_H */
