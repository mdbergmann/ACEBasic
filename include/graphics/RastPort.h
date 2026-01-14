#ifndef GRAPHICS_RASTPORT_H
#define GRAPHICS_RASTPORT_H 1
/*
** rastport.h for ACE Basic
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
** This are the StructPointer defines for rastport.h
*/
#ifndef AreaInfoPtr
#define AreaInfoPtr ADDRESS
#endif
#ifndef GelsInfoPtr
#define GelsInfoPtr ADDRESS
#endif
#ifndef RastPortPtr
#define RastPortPtr ADDRESS
#endif
#ifndef TmpRasPtr
#define TmpRasPtr ADDRESS
#endif
/*
** End of StructPointer defines for rastport.h
*/
       
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif

#ifndef GRAPHICS_GELS_H
#include <graphics/gels.h>
#endif

#ifndef GRAPHICS_TEXT_H
#include <graphics/text.h>
#endif



STRUCT AreaInfo
 
    ADDRESS   VctrTbl          /* ptr to start of vector table */
    ADDRESS   VctrPtr          /* ptr to current vertex */
    ADDRESS   FlagTbl          /* ptr to start of vector flag table */
    ADDRESS   FlagPtr          /* ptrs to areafill flags */
    SHORTINT   Count         /* number of vertices in list */
    SHORTINT   MaxCount          /* AreaMove/Draw will not allow Count>MaxCount*/
    SHORTINT   FirstX 
    SHORTINT  FirstY     /* first point for this polygon */
END STRUCT 

STRUCT TmpRas
 
    ADDRESS   RasPtr 
    LONGINT _Size 
END STRUCT 

/* unoptimized for 32bit alignment of pointers */
STRUCT GelsInfo
 
    BYTE sprRsrvd         /* flag of which sprites to reserve from
                 vsprite _system */
    BYTE  Flags           /* system use */
    VSpritePtr  gelHead 
    VSpritePtr  gelTail  /* dummy vSprites for list management*/
    /* pointer to array of 8 WORDS for sprite available lines */
    ADDRESS   nextLine 
    /* pointer to array of 8 pointers for color-last-assigned to vSprites */
    ADDRESS   lastColor
    collTablePtr  collHandler      /* addresses of collision routines */
    SHORTINT leftmost 
    SHORTINT   rightmost 
    SHORTINT   topmost 
    SHORTINT   bottommost 
    ADDRESS firstBlissObj
    ADDRESS lastBlissObj     /* SYSTEM use only */
END STRUCT 

STRUCT RastPort
 
    LayerPtr  Layer 
    BitMapPtr  BitMap 
    ADDRESS   AreaPtrn         /* ptr to areafill pattern */
    TmpRasPtr  TmpRas 
    AreaInfoPtr  AreaInfo 
    GelsInfoPtr  GelsInfo 
    BYTE    Mask          /* write mask for this raster */
    BYTE    FgPen         /* foreground pen for this raster */
    BYTE    BgPen         /* background pen  */
    BYTE    AOlPen        /* areafill outline pen */
    BYTE    DrawMode          /* drawing mode for fill,  lines,  and text */
    BYTE    AreaPtSz          /* 2^n words for areafill pattern */
    BYTE    linpatcnt         /* current line drawing pattern preshift */
    BYTE    dummy 
    SHORTINT  Flags         /* miscellaneous control bits */
    SHORTINT  LinePtrn          /* 16 bits for textured lines */
    SHORTINT   cp_x 
    SHORTINT   cp_y        /* current pen position */
    STRING minterms SIZE 8  
    SHORTINT   PenWidth 
    SHORTINT   PenHeight 
    TextFontPtr  _Font    /* current font address */
    BYTE    AlgoStyle         /* the algorithmically generated style */
    BYTE    TxFlags           /* text specific flags */
    SHORTINT   TxHeight          /* text height */
    SHORTINT   TxWidth           /* text nominal width */
    SHORTINT   TxBaseline        /* text baseline */
    SHORTINT    TxSpacing         /* text spacing (per character) */
    ADDRESS    RP_User
    STRING longreserved SIZE 8  /* 2*SIZEOF(LONGINT) */
#ifndef GFX_RASTPORT_1_2
    STRING wordreserved SIZE 14  /* 7*SIZEOF(SHORTINT) */  /* used TO be a node */
    STRING reserved SIZE 8        /* for future use */
#endif
END STRUCT 

/* drawing modes */
#define JAM1        0         /* jam 1 color into raster */
#define JAM2        1         /* jam 2 colors into raster */
#define COMPLEMENT  2         /* XOR bits into raster */
#define INVERSVID   4         /* inverse video for drawing modes */

/* these are the flag bits for RastPort flags */
#define FRST_DOT    &H01      /* draw the first dot of this line ? */
#define ONE_DOT     &H02      /* use one dot mode for drawing lines */
#define DBUFFER     &H04      /* flag set when RastPorts
                 are double-buffered */

         /* only used for bobs */

#define AREAOUTLINE &H08      /* used by areafiller */
#define NOCROSSFILL &H20      /* areafills have no crossovers */

/* there is only one style of clipping: raster clipping */
/* this preserves the continuity of jaggies regardless of clip window */
/* When drawing into a RastPort,  if the ptr to ClipRect is nil then there */
/* is no clipping done,  this is dangerous but useful for speed */

#endif  /* GRAPHICS_RASTPORT_H */
