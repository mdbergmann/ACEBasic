#ifndef GRAPHICS_LAYERS_H
#define GRAPHICS_LAYERS_H 1
/*
** layers.h for ACE Basic
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
** This are the StructPointer defines for layers.h
*/
#ifndef Layer_InfoPtr
#define Layer_InfoPtr ADDRESS
#endif
/*
** End of StructPointer defines for layers.h
*/
     
#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef EXEC_SEMAPHORES_H
#include <exec/semaphores.h>
#endif


#define LAYERSIMPLE     1
#define LAYERSMART      2
#define LAYERSUPER      4
#define LAYERUPDATING       &H10
#define LAYERBACKDROP       &H40
#define LAYERREFRESH        &H80
#define LAYERIREFRESH       &H200
#define LAYERIREFRESH2      &H400
#define LAYER_CLIPRECTS_LOST    &H100   /* during BeginUpdate */
                    /* or during layerop */
                    /* this happens if out of memory */

STRUCT Layer_Info
 
    LayerPtr  top_layer 
    LayerPtr  check_lp       /* !! Private !! */
    ClipRectPtr  obs 
    ClipRectPtr  FreeClipRects      /* !! Private !! */
    LONGINT        PrivateReserve1     /* !! Private !! */
    LONGINT        PrivateReserve2     /* !! Private !! */
    SignalSemaphore Lock            /* !! Private !! */
    MinList gs_Head         /* !! Private !! */
    SHORTINT        PrivateReserve3     /* !! Private !! */
    ADDRESS   PrivateReserve4    /* !! Private !! */
    SHORTINT       Flags 
    BYTE        fatten_count        /* !! Private !! */
    BYTE        LockLayersCount     /* !! Private !! */
    SHORTINT        PrivateReserve5     /* !! Private !! */
    ADDRESS   BlankHook      /* !! Private !! */
    ADDRESS   LayerInfo_extra    /* !! Private !! */
END STRUCT 

#define NEWLAYERINFO_CALLED 1

/*
 * LAYERS_NOBACKFILL is the value needed to get no backfill hook
 * LAYERS_BACKFILL is the value needed to get the default backfill hook
 */
/*
#define LAYERS_NOBACKFILL   ((STRUCT Hook *)1)
#define LAYERS_BACKFILL     ((STRUCT Hook *)0)
*/

#endif  /* GRAPHICS_LAYERS_H */
