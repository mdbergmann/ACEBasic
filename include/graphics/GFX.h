#ifndef GRAPHICS_GFX_H
#define GRAPHICS_GFX_H 1
/*
** gfx.h for ACE Basic
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
** This are the StructPointer defines for gfx.h
*/
#ifndef BitMapPtr
#define BitMapPtr ADDRESS
#endif
#ifndef PointPtr
#define PointPtr ADDRESS
#endif
#ifndef Rect32Ptr
#define Rect32Ptr ADDRESS
#endif
#ifndef RectanglePtr
#define RectanglePtr ADDRESS
#endif
/*
** End of StructPointer defines for gfx.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif


#define BITSET  &H8000
#define BITCLR  0


STRUCT Rectangle
 
    SHORTINT   MinX 
    SHORTINT  MinY 
    SHORTINT   MaxX 
    SHORTINT  MaxY 
END STRUCT 

STRUCT Rect32
 
    LONGINT    MinX 
    LONGINT  MinY 
    LONGINT    MaxX 
    LONGINT  MaxY 
END STRUCT 

STRUCT _Point
 
    SHORTINT x 
    SHORTINT  y 
END STRUCT

#define PLANEPTR ADDRESS 
STRUCT BitMap
 
    SHORTINT   BytesPerRow 
    SHORTINT   Rows 
    BYTE    Flags 
    BYTE    Depth 
    SHORTINT   pad 
    STRING Planes SIZE 32  /*  8*SIZEOF(PLANEPTR)  */
END STRUCT 

/* This macro is obsolete as of V39. AllocBitMap() should be used for allocating
   bitmap data,  since it knows about the machine's particular alignment
   restrictions.
*/
#define RASSIZE(w, h)    ((LONGINT)(h)*( ((LONGINT)(w)+15)>>3&&HFFFE))

/* flags for AllocBitMap,  etc. */
#define BMB_CLEAR 0
#define BMB_DISPLAYABLE 1
#define BMB_INTERLEAVED 2
#define BMB_STANDARD 3
#define BMB_MINPLANES 4

#define BMF_CLEAR (1&)
#define BMF_DISPLAYABLE (2&)
#define BMF_INTERLEAVED (4&)
#define BMF_STANDARD (8&)
#define BMF_MINPLANES (16)

/* the following are for GetBitMapAttr() */
#define BMA_HEIGHT 0
#define BMA_DEPTH 4
#define BMA_WIDTH 8
#define BMA_FLAGS 12

#endif  /* GRAPHICS_GFX_H */


