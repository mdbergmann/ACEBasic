#ifndef GRAPHICS_CLIP_H
#define GRAPHICS_CLIP_H 1
/*
** clip.h for ACE Basic
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
** This are the StructPointer defines for clip.h
*/
#ifndef ClipRectPtr
#define ClipRectPtr ADDRESS
#endif
#ifndef LayerPtr
#define LayerPtr ADDRESS
#endif
/*
** End of StructPointer defines for clip.h
*/    
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif
#ifndef EXEC_SEMAPHORES_H
#include <exec/semaphores.h>
#endif
#ifndef UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif
#ifndef GRAPHICS_REGIONS_H
#include <graphics/regions.h>
#endif

#ifndef RastPortPtr
#define RastPortPtr ADDRESS
#endif
#ifndef Layer_InfoPtr
#define Layer_InfoPtr ADDRESS
#endif

#define NEWLOCKS

STRUCT Layer
 
    LayerPtr  front 
    LayerPtr  _back 
    ClipRectPtr  ClipRect   /* read by roms to find first cliprect */
    RastPortPtr  rp 
    Rectangle bounds 
    STRING reserved SIZE 4  
    SHORTINT   priority            /* system use only */
    SHORTINT   Flags           /* obscured ?,  Virtual BitMap? */
    BitMapPtr  SuperBitMap 
    ClipRectPtr  SuperClipRect  /* super bitmap cliprects if VBitMap != 0*/
                  /* else damage cliprect list for refresh */
    ADDRESS    _Window        /* reserved for user interface use */
    SHORTINT    Scroll_X 
    SHORTINT  Scroll_Y 
    ClipRectPtr  cr 
    ClipRectPtr  cr2 
    ClipRectPtr  crnew    /* used by dedice */
    ClipRectPtr  SuperSaveClipRects  /* preallocated cr's */
    ClipRectPtr  _cliprects    /* system use during refresh */
    Layer_InfoPtr  LayerInfo  /* points to head of the list */
    SignalSemaphore Lock 
    HookPtr  BackFill 
    LONGINT   reserved1 
    RegionPtr  ClipRegion 
    RegionPtr  saveClipRects   /* used to back out when in trouble*/
    SHORTINT    _Width 
    SHORTINT  Height        /* system use */
    STRING reserved2 SIZE 18  
    /* this must stay here */
    RegionPtr  DamageList     /* list of rectangles to refresh
                       through */
END STRUCT 

STRUCT ClipRect
 
    ClipRectPtr  _Next      /* roms used to find next ClipRect */
    ClipRectPtr  prev      /* Temp use in layers (private) */
    LayerPtr  lobs       /* Private use for layers */
    BitMapPtr  BitMap         /* Bitmap for layers private use */
    Rectangle bounds      /* bounds of cliprect */
    ADDRESS   _p1            /* Layers private use!!! */
    ADDRESS   _p2            /* Layers private use!!! */
    LONGINT    reserved            /* system use (Layers private) */
#ifdef NEWCLIPRECTS_1_1
    LONGINT    Flags           /* Layers private field for cliprects */
                    /* that layers allocates... */
#endif                  /* MUST be multiple of 8 bytes to buffer */
END STRUCT 

/* internal cliprect flags */
#define CR_NEEDS_NO_CONCEALED_RASTERS  1
#define CR_NEEDS_NO_LAYERBLIT_DAMAGE   2

/* defines for code values for getcode */
#define ISLESSX 1
#define ISLESSY 2
#define ISGRTRX 4
#define ISGRTRY 8

#endif  /* GRAPHICS_CLIP_H */
