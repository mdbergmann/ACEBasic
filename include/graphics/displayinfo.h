#ifndef GRAPHICS_DISPLAYINFO_H
#define GRAPHICS_DISPLAYINFO_H 1
/*
** displayinfo.h for ACE Basic
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
** This are the StructPointer defines for displayinfo.h
*/
#ifndef DimensionInfoPtr
#define DimensionInfoPtr ADDRESS
#endif
#ifndef DisplayInfoPtr
#define DisplayInfoPtr ADDRESS
#endif
#ifndef MonitorInfoPtr
#define MonitorInfoPtr ADDRESS
#endif
#ifndef NameInfoPtr
#define NameInfoPtr ADDRESS
#endif
#ifndef QueryHeaderPtr
#define QueryHeaderPtr ADDRESS
#endif
#ifndef VecInfoPtr
#define VecInfoPtr ADDRESS
#endif
/*
** End of StructPointer defines for displayinfo.h
*/
         
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEC_TYPES_H */

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif /* GRAPHICS_GFX_H */

#ifndef GRAPHICS_MONITOR_H
#include <graphics/monitor.h>
#endif /* GRAPHICS_MONITOR_H */

#ifndef GRAPHICS_MODEID_H
#include <graphics/modeid.h>
#endif /* GRAPHICS_MODEID_H */

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif /* UTILITY_TAGITEM_H */


/* the "public" HANDLE TO a DisplayInfoRecord */

#define DisplayInfoHandle ADDRESS 

/* datachunk type identifiers */

#define DTAG_DISP       &H80000000
#define DTAG_DIMS       &H80001000
#define DTAG_MNTR       &H80002000
#define DTAG_NAME       &H80003000
#define DTAG_VEC        &H80004000  /* internal use only */

STRUCT QueryHeader
 
    LONGINT   StructID    /* datachunk type identifier */
    LONGINT   DisplayID   /* copy of display record key   */
    LONGINT   SkipID      /* TAG_SKIP -- see tagitems.h */
    LONGINT   Length      /* length of local data in double-longwords */
END STRUCT 

STRUCT DisplayInfo
 
    QueryHeader Header 
    SHORTINT   NotAvailable    /* if NULL available,  else see defines */
    LONGINT   PropertyFlags   /* Properties of this mode see defines */
    _Point   Resolution  /* ticks-per-pixel X/Y             */
    SHORTINT   PixelSpeed  /* aproximation in nanoseconds         */
    SHORTINT   NumStdSprites   /* number of standard amiga sprites    */
    SHORTINT   PaletteRange    /* OBSOLETE - use Red/Green/Blue bits instead */
    _Point   SpriteResolution  /* std sprite ticks-per-pixel X/Y    */
    STRING pad SIZE 4       /* used internally */
    BYTE    RedBits     /* number of Red bits this display supports (V39) */
    BYTE    GreenBits   /* number of Green bits this display supports (V39) */
    BYTE    BlueBits    /* number of Blue bits this display supports (V39) */
    STRING pad2 SIZE 5      /* find some use for this. */
    STRING reserved SIZE 8  /* 2*SIZEOF(LONGINT) */    /* terminator */
END STRUCT 

/* availability */

#define DI_AVAIL_NOCHIPS    &H0001
#define DI_AVAIL_NOMONITOR  &H0002
#define DI_AVAIL_NOTWITHGENLOCK &H0004

/* mode properties */

#define DIPF_IS_LACE        &H00000001
#define DIPF_IS_DUALPF      &H00000002
#define DIPF_IS_PF2PRI      &H00000004
#define DIPF_IS_HAM     &H00000008

#define DIPF_IS_ECS     &H00000010  /* note: ECS modes (SHIRES,  VGA,  and **
                                            ** PRODUCTIVITY) do not support      **
                                            ** attached sprites.             **
                                            */
#define DIPF_IS_AA      &H00010000  /* AA modes - may only be available
                        ** if machine has correct memory
                        ** type to support required
                        ** bandwidth - check availability.
                        ** (V39)
                        */
#define DIPF_IS_PAL     &H00000020
#define DIPF_IS_SPRITES     &H00000040
#define DIPF_IS_GENLOCK     &H00000080

#define DIPF_IS_WB      &H00000100
#define DIPF_IS_DRAGGABLE   &H00000200
#define DIPF_IS_PANELLED    &H00000400
#define DIPF_IS_BEAMSYNC    &H00000800

#define DIPF_IS_EXTRAHALFBRITE  &H00001000

/* The following DIPF_IS_... flags are new for V39 */
#define DIPF_IS_SPRITES_ATT     &H00002000  /* supports attached sprites */
#define DIPF_IS_SPRITES_CHNG_RES    &H00004000  /* supports variable sprite resolution */
#define DIPF_IS_SPRITES_BORDER      &H00008000  /* sprite can be displayed in the border */
#define DIPF_IS_SCANDBL         &H00020000  /* scan doubled */
#define DIPF_IS_SPRITES_CHNG_BASE   &H00040000
                                            /* can change the sprite base colour */
#define DIPF_IS_SPRITES_CHNG_PRI    &H00080000
                                            /* can change the sprite priority
                                            ** with respect to the playfield(s).
                                            */
#define DIPF_IS_DBUFFER     &H00100000  /* can support double buffering */
#define DIPF_IS_PROGBEAM    &H00200000  /* is a programmed beam-sync mode */
#define DIPF_IS_FOREIGN     &H80000000  /* this mode is not native to the Amiga */


STRUCT DimensionInfo
 
    QueryHeader Header 
    SHORTINT   MaxDepth          /* log2( max number of colors ) */
    SHORTINT   MinRasterWidth        /* minimum width in pixels      */
    SHORTINT   MinRasterHeight       /* minimum height in pixels     */
    SHORTINT   MaxRasterWidth        /* maximum width in pixels      */
    SHORTINT   MaxRasterHeight       /* maximum height in pixels     */
    Rectangle Nominal   /* "standard" dimensions        */
    Rectangle MaxOScan  /* fixed,  hardware dependent    */
    Rectangle VideoOScan  /* fixed,  hardware dependent    */
    Rectangle TxtOScan  /* editable via preferences     */
    Rectangle StdOScan  /* editable via preferences     */
    STRING pad SIZE 14  
    STRING reserved SIZE 8  /* 2*SIZEOF(LONGINT) */          /* terminator */
END STRUCT 

STRUCT MonitorInfo
 
    QueryHeader Header 
    MonitorSpecPtr  Mspc    /* pointer to monitor specification  */
    _Point   ViewPosition          /* editable via preferences      */
    _Point   ViewResolution        /* standard monitor ticks-per-pixel  */
    Rectangle ViewPositionRange   /* fixed,  hardware dependent */
    SHORTINT   TotalRows         /* display height in scanlines       */
    SHORTINT   TotalColorClocks      /* scanline width in 280 ns units    */
    SHORTINT   MinRow        /* absolute minimum active scanline  */
    SHORTINT    Compatibility         /* how this coexists with others     */
    STRING pad SIZE 32  
    _Point   MouseTicks 
    _Point   DefaultViewPosition   /* original,  never changes */
    LONGINT   PreferredModeID       /* for Preferences */
    STRING reserved SIZE 8   /* 2*SIZEOF(LONGINT) */          /* terminator */
END STRUCT 

/* monitor compatibility */

#define MCOMPAT_MIXED   0   /* can share display with other MCOMPAT_MIXED */
#define MCOMPAT_SELF    1   /* can share only within same monitor */
#define MCOMPAT_NOBODY -1   /* only one viewport at a time */

#define DISPLAYNAMELEN 32

STRUCT NameInfo
 
    QueryHeader Header 
    STRING _Name SIZE DISPLAYNAMELEN  
    STRING reserved SIZE 8  /* 2*SIZEOF(LONGINT)  */         /* terminator */
END STRUCT 

/******************************************************************************/

/* The following VecInfo structure is PRIVATE,  for our use only
 * Touch these,  and burn! (V39)
 */

STRUCT VecInfo
 
    QueryHeader Header 
    ADDRESS    Vec 
    ADDRESS    _Data 
    SHORTINT   _Type 
    STRING pad SIZE 6  /*  3*SIZEOF(SHORTINT) */
    STRING reserved SIZE 8  /*  2*SIZEOF(LONGINT)  */
END STRUCT 

#endif  /* GRAPHICS_DISPLAYINFO_H */
