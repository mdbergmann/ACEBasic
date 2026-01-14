#ifndef DATATYPES_PICTURECLASS_H
#define DATATYPES_PICTURECLASS_H 1
/*
** pictureclass.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/02/95
**
**
*/

/*
** This are the StructPointer defines for pictureclass.h
*/
#ifndef BitMapHeaderPtr
#define BitMapHeaderPtr ADDRESS
#endif
#ifndef ColorRegisterPtr
#define ColorRegisterPtr ADDRESS
#endif
/*
** End of StructPointer defines for pictureclass.h
*/
           
#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef DATATYPES_DATATYPESCLASS_H
#include <datatypes/datatypesclass.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif

/*****************************************************************************/

#define PICTUREDTCLASS      "picture.datatype"

/*****************************************************************************/

/* Picture attributes */
#define PDTA_ModeID     (DTA_Dummy + 200)
    /* Mode ID of the picture */

#define PDTA_BitMapHeader   (DTA_Dummy + 201)

#define PDTA_BitMap     (DTA_Dummy + 202)
    /* Pointer to a class-allocated bitmap,  that will end
     * up being freed by picture.class when DisposeDTObject()
     * is called */

#define PDTA_ColorRegisters (DTA_Dummy + 203)
#define PDTA_CRegs      (DTA_Dummy + 204)
#define PDTA_GRegs      (DTA_Dummy + 205)
#define PDTA_ColorTable     (DTA_Dummy + 206)
#define PDTA_ColorTable2    (DTA_Dummy + 207)
#define PDTA_Allocated      (DTA_Dummy + 208)
#define PDTA_NumColors      (DTA_Dummy + 209)
#define PDTA_NumAlloc       (DTA_Dummy + 210)

#define PDTA_Remap      (DTA_Dummy + 211)
    /* Boolean : Remap picture (defaults to TRUE) */

#define PDTA_Screen     (DTA_Dummy + 212)
    /* Screen to remap to */

#define PDTA_FreeSourceBitMap   (DTA_Dummy + 213)
    /* Boolean : Free the source bitmap after remapping */

#define PDTA_Grab       (DTA_Dummy + 214)
    /* Pointer to a Point structure */

#define PDTA_DestBitMap     (DTA_Dummy + 215)
    /* Pointer to the destination (remapped) bitmap */

#define PDTA_ClassBitMap    (DTA_Dummy + 216)
    /* Pointer to class-allocated bitmap,  that will end
     * up being freed by the class after DisposeDTObject()
     * is called */

#define PDTA_NumSparse      (DTA_Dummy + 217)
    /* (SHORTINT) Number of colors used for sparse remapping */

#define PDTA_SparseTable    (DTA_Dummy + 218)
    /* (BYTE  *) Pointer to a table of pen numbers indicating
     * which colors should be used when remapping the image.
     * This array must contain as many entries as there
     * are colors specified with PDTA_NumSparse */

/*****************************************************************************/

/*  Masking techniques  */
#define mskNone         0
#define mskHasMask      1
#define mskHasTransparentColor  2
#define mskLasso        3
#define mskHasAlpha     4

/*  Compression techniques  */
#define cmpNone         0
#define cmpByteRun1     1
#define cmpByteRun2     2

/*  Bitmap header (BMHD) structure  */
STRUCT BitMapHeader
 
    SHORTINT    bmh_Width      /* Width in pixels */
    SHORTINT    bmh_Height         /* Height in pixels */
    SHORTINT     bmh_Left       /* Left position */
    SHORTINT     bmh_Top        /* Top position */
    BYTE     bmh_Depth      /* Number of planes */
    BYTE     bmh_Masking        /* Masking type */
    BYTE     bmh_Compression    /* Compression type */
    BYTE     bmh_Pad 
    SHORTINT    bmh_Transparent    /* Transparent color */
    BYTE     bmh_XAspect 
    BYTE     bmh_YAspect 
    SHORTINT     bmh_PageWidth 
    SHORTINT     bmh_PageHeight 
END STRUCT 

/*****************************************************************************/

/*  Color register structure */
STRUCT ColorRegister
 
    BYTE  red 
    BYTE   green 
    BYTE   blue 
END STRUCT 

/*****************************************************************************/

/* IFF types that may be in pictures */
#define ID_ILBM     1229734477 
#define ID_BMHD     1112361028 
#define ID_BODY     1112491097 
#define ID_CMAP     1129136464 
#define ID_CRNG     1129467463 
#define ID_GRAB     1196572994 
#define ID_SPRT     1397772884 
#define ID_DEST     1145394004 
#define ID_CAMG     1128353095 

#endif  /* DATATYPES_PICTURECLASS_H */
