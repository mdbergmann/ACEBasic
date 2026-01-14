#ifndef GRAPHICS_GELS_H
#define GRAPHICS_GELS_H 1
/*
** gels.h for ACE Basic
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
** This are the StructPointer defines for gels.h
*/
#ifndef AnimCompPtr
#define AnimCompPtr ADDRESS
#endif
#ifndef AnimObPtr
#define AnimObPtr ADDRESS
#endif
#ifndef BobPtr
#define BobPtr ADDRESS
#endif
#ifndef DBufPacketPtr
#define DBufPacketPtr ADDRESS
#endif
#ifndef VSpritePtr
#define VSpritePtr ADDRESS
#endif
#ifndef collTablePtr
#define collTablePtr ADDRESS
#endif
/*
** End of StructPointer defines for gels.h
*/
       
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif


/* VSprite flags */
/* user-set VSprite flags: */
#define SUSERFLAGS  &H00FF    /* mask of all user-settable VSprite-flags */
#define VSPRITE     &H0001    /* set if VSprite,  clear if Bob */
#define SAVEBACK    &H0002    /* set if background is to be saved/restored */
#define OVERLAY     &H0004    /* set to mask image of Bob onto background */
#define MUSTDRAW    &H0008    /* set if VSprite absolutely must be drawn */
/* system-set VSprite flags: */
#define BACKSAVED   &H0100    /* this Bob's background has been saved */
#define BOBUPDATE   &H0200    /* temporary flag,  useless to outside world */
#define GELGONE     &H0400    /* set if gel is completely clipped (offscreen) */
#define VSOVERFLOW  &H0800    /* VSprite overflow (if MUSTDRAW set we draw!) */

/* Bob flags */
/* these are the user flag bits */
#define BUSERFLAGS  &H00FF    /* mask of all user-settable Bob-flags */
#define SAVEBOB     &H0001    /* set to not erase Bob */
#define BOBISCOMP   &H0002    /* set to identify Bob as AnimComp */
/* these are the system flag bits */
#define BWAITING    &H0100    /* set while Bob is waiting on 'after' */
#define BDRAWN      &H0200    /* set when Bob is drawn this DrawG pass*/
#define BOBSAWAY    &H0400    /* set to initiate removal of Bob */
#define BOBNIX      &H0800    /* set when Bob is completely removed */
#define SAVEPRESERVE &H1000   /* for back-restore during double-buffer*/
#define OUTSTEP     &H2000    /* for double-clearing if double-buffer */

/* defines for the animation procedures */
#define ANFRACSIZE  6
#define ANIMHALF    &H0020
#define RINGTRIGGER &H0001


/* UserStuff definitions
 *  the user can define these to be a single variable or a sub-structure
 *  if undefined by the user,  the system turns these into innocuous variables
 *  see the manual for a thorough definition of the UserStuff definitions
 *
 */
#ifndef VUserStuff        /* VSprite user stuff */
#define VUserStuff SHORTINT
#endif

#ifndef BUserStuff        /* Bob user stuff */
#define BUserStuff SHORTINT
#endif

#ifndef AUserStuff        /* AnimOb user stuff */
#define AUserStuff SHORTINT
#endif




/*********************** GEL STRUCTURES ***********************************/

STRUCT VSprite
 
/* --------------------- SYSTEM VARIABLES ------------------------------- */
/* GEL linked list forward/backward pointers sorted by y, x value */
    VSpritePtr  NextVSprite 
    VSpritePtr  PrevVSprite 

/* GEL draw list constructed in the order the Bobs are actually drawn,  then
 *  list is copied to clear list
 *  must be here in VSprite for system boundary detection
 */
    VSpritePtr  DrawPath      /* pointer of overlay drawing */
    VSpritePtr  ClearPath     /* pointer for overlay clearing */

/* the VSprite positions are defined in (y, x) order to make sorting
 *  sorting easier,  since (y, x) as a LONGINT integer
 */
    SHORTINT OldY 
    SHORTINT   OldX           /* previous position */

/* --------------------- COMMON VARIABLES --------------------------------- */
    SHORTINT Flags        /* VSprite flags */


/* --------------------- USER VARIABLES ----------------------------------- */
/* the VSprite positions are defined in (y, x) order to make sorting
 *  sorting easier,  since (y, x) as a LONGINT integer
 */
    SHORTINT Y 
    SHORTINT   X             /* screen position */

    SHORTINT Height 
    SHORTINT _Width        /* number of words per row of image data */
    SHORTINT Depth        /* number of planes of data */

    SHORTINT MeMask           /* which types can collide with this VSprite*/
    SHORTINT HitMask          /* which types this VSprite can collide with*/

    ADDRESS   ImageData           /* pointer to VSprite image */

/* borderLine is the one-dimensional logical OR of all
 *  the VSprite bits,  used for fast collision detection of edge
 */
    ADDRESS   BorderLine          /* logical OR of all VSprite bits */
    ADDRESS   CollMask        /* similar to above except this is a matrix */

/* pointer to this VSprite's color definitions (not used by Bobs) */
    ADDRESS   SprColors 

    BobPtr  VSBob         /* points home if this VSprite is part of
                   a Bob */

/* planePick flag:  set bit selects a plane from image,  clear bit selects
 *  use of shadow mask for that plane
 * OnOff flag: if using shadow mask to fill plane,  this bit (corresponding
 *  to bit in planePick) describes whether to fill with 0's or 1's
 * There are two uses for these flags:
 *  - if this is the VSprite of a Bob,  these flags describe how the Bob
 *    is to be drawn into memory
 *  - if this is a simple VSprite and the user intends on setting the
 *    MUSTDRAW flag of the VSprite,  these flags must be set too to describe
 *    which color registers the user wants for the image
 */
    BYTE PlanePick 
    BYTE PlaneOnOff 

    VUserStuff VUserExt       /* user definable:  see note above */
END STRUCT 

STRUCT Bob
/* blitter-objects */
 
/* --------------------- SYSTEM VARIABLES --------------------------------- */

/* --------------------- COMMON VARIABLES --------------------------------- */
    SHORTINT Flags  /* general purpose flags (see definitions below) */

/* --------------------- USER VARIABLES ----------------------------------- */
    ADDRESS   SaveBuffer    /* pointer to the buffer for background save */

/* used by Bobs for "cookie-cutting" and multi-plane masking */
    ADDRESS   ImageShadow 

/* pointer to BOBs for sequenced drawing of Bobs
 *  for correct overlaying of multiple component animations
 */
    BobPtr  Before  /* draw this Bob before Bob pointed to by before */
    BobPtr  After   /* draw this Bob after Bob pointed to by after */

    VSpritePtr  BobVSprite    /* this Bob's VSprite definition */

    AnimCompPtr  BobComp       /* pointer to this Bob's AnimComp def */

    DBufPacketPtr  DBuffer      /* pointer to this Bob's dBuf packet */

    BUserStuff BUserExt         /* Bob user extension */
END STRUCT 

STRUCT AnimComp
 
/* --------------------- SYSTEM VARIABLES --------------------------------- */

/* --------------------- COMMON VARIABLES --------------------------------- */
    SHORTINT Flags          /* AnimComp flags for system & user */

/* timer defines how LONGINT to keep this component active:
 *  if set non-zero,  timer decrements to zero then switches to nextSeq
 *  if set to zero,  AnimComp never switches
 */
    SHORTINT _Timer 

/* --------------------- USER VARIABLES ----------------------------------- */
/* initial value for timer when the AnimComp is activated by the system */
    SHORTINT TimeSet 

/* pointer to next and previous components of animation object */
    AnimCompPtr  NextComp 
    AnimCompPtr  PrevComp 

/* pointer to component component definition of next image in sequence */
    AnimCompPtr  NextSeq 
    AnimCompPtr  PrevSeq 

    ADDRESS   AnimCRoutine  /* address of special animation procedure */

    SHORTINT YTrans      /* initial y translation (if this is a component) */
    SHORTINT XTrans      /* initial x translation (if this is a component) */

    AnimObPtr  HeadOb 

    BobPtr  AnimBob 
END STRUCT 

STRUCT AnimOb
 
/* --------------------- SYSTEM VARIABLES --------------------------------- */
    AnimObPtr  NextOb 
    AnimObPtr  PrevOb 

/* number of calls to Animate this AnimOb has endured */
    LONGINT Clock 

    SHORTINT AnOldY 
    SHORTINT   AnOldX         /* old y, x coordinates */

/* --------------------- COMMON VARIABLES --------------------------------- */
    SHORTINT AnY 
    SHORTINT   AnX           /* y, x coordinates of the AnimOb */

/* --------------------- USER VARIABLES ----------------------------------- */
    SHORTINT YVel 
    SHORTINT   XVel             /* velocities of this object */
    SHORTINT YAccel 
    SHORTINT   XAccel         /* accelerations of this object */

    SHORTINT RingYTrans 
    SHORTINT   RingXTrans     /* ring translation values */

    ADDRESS   AnimORoutine      /* address of special animation
                       procedure */

    AnimCompPtr  HeadComp      /* pointer to first component */

    AUserStuff AUserExt         /* AnimOb user extension */
END STRUCT 

/* dBufPacket defines the values needed to be saved across buffer to buffer
 *  when in double-buffer mode
 */
STRUCT DBufPacket
 
    SHORTINT BufY 
    SHORTINT   BufX             /* save the other buffers screen coordinates */
    VSpritePtr  BufPath       /* carry the draw path over the gap */

/* these pointers must be filled in by the user */
/* pointer to other buffer's background save buffer */
    ADDRESS   BufBuffer 
END STRUCT 



/* ************************************************************************ */

/* these are GEL functions that are currently simple enough to exist as a
 *  definition.  It should not be assumed that this will always be the case
 */
/*
#define InitAnimate(animKey) { *(animKey) = NULL }
#define RemBob(b)  {(b)->Flags |= BOBSAWAY }
*/

/* ************************************************************************ */

#define B2NORM      0
#define B2SWAP      1
#define B2BOBBER    2

/* ************************************************************************ */

/* a structure to contain the 16 collision procedure addresses */
STRUCT collTable
 
STRING collPtrs SIZE 64   /*  16*SIZEOF(ADDRESS)  */
END STRUCT 

#endif  /* GRAPHICS_GELS_H */
