#ifndef  DISKFONT_GLYPH_H
#define  DISKFONT_GLYPH_H 1
/*
** glyph.h for ACE Basic
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
** This are the StructPointer defines for glyph.h
*/
#ifndef GlyphEnginePtr
#define GlyphEnginePtr ADDRESS
#endif
#ifndef GlyphMapPtr
#define GlyphMapPtr ADDRESS
#endif
#ifndef GlyphWidthEntryPtr
#define GlyphWidthEntryPtr ADDRESS
#endif
/*
** End of StructPointer defines for glyph.h
*/
        
#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef  EXEC_NODES_H
#include <exec/nodes.h>
#endif


/* A GlyphEngine must be acquired via OpenEngine and is read-only */
STRUCT GlyphEngine  
    LibraryPtr  gle_Library  /* engine library */
    ADDRESS   gle_Name      /* library basename: e.g. "bullet" */
    /* private library data follows... */
END STRUCT 

#define FIXED LONGINT      /* 32 bit signed w/ 16 bits of fraction */

STRUCT GlyphMap  
    SHORTINT   glm_BMModulo    /* # of bytes in row: always multiple of 4 */
    SHORTINT   glm_BMRows      /* # of rows in bitmap */
    SHORTINT   glm_BlackLeft   /* # of blank pixel columns at left */
    SHORTINT   glm_BlackTop    /* # of blank rows at top */
    SHORTINT   glm_BlackWidth  /* span of contiguous non-blank columns */
    SHORTINT   glm_BlackHeight     /* span of contiguous non-blank rows */
    FIXED   glm_XOrigin     /* distance from upper left corner of bitmap */
    FIXED   glm_YOrigin     /*   to initial CP,  in fractional pixels */
    SHORTINT    glm_X0      /* approximation of XOrigin in whole pixels */
    SHORTINT    glm_Y0      /* approximation of YOrigin in whole pixels */
    SHORTINT    glm_X1      /* approximation of XOrigin + Width */
    SHORTINT    glm_Y1      /* approximation of YOrigin + Width */
    FIXED   glm_Width       /* character advance,  as fraction of em width */
    ADDRESS   glm_BitMap      /* actual glyph bitmap */
END STRUCT 

STRUCT GlyphWidthEntry  
    MinNode gwe_Node     /* on list returned by OT_WidthList inquiry */
    SHORTINT   gwe_Code        /* entry's character code value */
    FIXED   gwe_Width       /* character advance,  as fraction of em width */
END STRUCT 
#endif   /* DISKFONT_GLYPH_H */
