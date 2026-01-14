#ifndef INTUITION_CGHOOKS_H
#define INTUITION_CGHOOKS_H 1
/*
** cghooks.h for ACE Basic
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
** This are the StructPointer defines for cghooks.h
*/
#ifndef GadgetInfoPtr
#define GadgetInfoPtr ADDRESS
#endif
#ifndef PGXPtr
#define PGXPtr ADDRESS
#endif
#ifndef gi_Pens_StructPtr
#define gi_Pens_StructPtr ADDRESS
#endif
/*
** End of StructPointer defines for cghooks.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef DrawInfoPtr
#define DrawInfoPtr ADDRESS
#endif

/*
 * Package of information passed to custom and 'boopsi'
 * gadget "hook" functions.  This structure is READ ONLY.
 */

STRUCT gi_Pens_Struct  
    BYTE     DetailPen 
    BYTE     BlockPen 
END STRUCT 

STRUCT GadgetInfo  

    ScreenPtr  gi_Screen 
    WindowPtr  gi_Window  /* null for screen gadgets */
    RequesterPtr  gi_Requester   /* null if not GTYP_REQGADGET */

    /* rendering information:
     * don't use these without cloning/locking.
     * Official way is to call ObtainRPort()
     */
    RastPortPtr  gi_RastPort 
    LayerPtr  gi_Layer 

    /* copy of dimensions of screen/window/g00/req(/group)
     * that gadget resides in.  Left/Top of this box is
     * offset from window mouse coordinates to gadget coordinates
     *      screen gadgets:         0, 0 (from screen coords)
     *  window gadgets (no g00):    0, 0
     *  GTYP_GZZGADGETs (borderlayer):      0, 0
     *  GZZ innerlayer gadget:      borderleft,  bordertop
     *  Requester gadgets:      reqleft,  reqtop
     */
    IBox gi_Domain 

    /* these are the pens for the window or screen  */
    gi_Pens_Struct gi_Pens 

    /* the Detail and Block pens in gi_DrInfo->dri_Pens[] are
     * for the screen.  Use the above for window-sensitive
     * colors.
     */
    DrawInfoPtr  gi_DrInfo 

    /* reserved space: this structure is extensible
     * anyway,  but using these saves some recompilation
     */
    STRING gi_Reserved SIZE 24   /* 6*SIZEOF(LONGINT) */
END STRUCT 

/*** system private data structure for now ***/
/* prop gadget extra info   */
STRUCT PGX   
    IBox pgx_Container 
    IBox pgx_NewKnob 
END STRUCT 
/* this casts MutualExclude for easy assignment of a hook
 * pointer to the unused MutualExclude field of a custom gadget
 */
/*
#define CUSTOM_HOOK( gadget ) ( (STRUCT Hook *) (gadget)->MutualExclude)
*/

#endif
