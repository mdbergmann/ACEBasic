#ifndef GRAPHICS_SCALE_H
#define GRAPHICS_SCALE_H 1
/*
** scale.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/

/*
** This are the StructPointer defines for scale.h
*/
#ifndef BitScaleArgsPtr
#define BitScaleArgsPtr ADDRESS
#endif
/*
** End of StructPointer defines for scale.h
*/
     
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif


STRUCT BitScaleArgs  
    SHORTINT   bsa_SrcX 
    SHORTINT   bsa_SrcY          /* source origin */
    SHORTINT   bsa_SrcWidth 
    SHORTINT   bsa_SrcHeight     /* source size */
    SHORTINT   bsa_XSrcFactor 
    SHORTINT   bsa_YSrcFactor  /* scale factor denominators */
    SHORTINT   bsa_DestX 
    SHORTINT   bsa_DestY        /* destination origin */
    SHORTINT   bsa_DestWidth 
    SHORTINT   bsa_DestHeight   /* destination size result */
    SHORTINT   bsa_XDestFactor 
    SHORTINT   bsa_YDestFactor    /* scale factor numerators */
    BitMapPtr  bsa_SrcBitMap        /* source BitMap */
    BitMapPtr  bsa_DestBitMap       /* destination BitMap */
    LONGINT   bsa_Flags               /* reserved.  Must be zero! */
    SHORTINT   bsa_XDDA 
    SHORTINT   bsa_YDDA          /* reserved */
    LONGINT    bsa_Reserved1 
    LONGINT    bsa_Reserved2 
END STRUCT 
#endif  /* GRAPHICS_SCALE_H */
