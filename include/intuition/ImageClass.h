#ifndef INTUITION_IMAGECLASS_H
#define INTUITION_IMAGECLASS_H TRUE
/*
** imageclass.h for ACE Basic
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
** This are the StructPointer defines for imageclass.h
*/
#ifndef impDrawPtr
#define impDrawPtr ADDRESS
#endif
#ifndef impErasePtr
#define impErasePtr ADDRESS
#endif
#ifndef impFrameBoxPtr
#define impFrameBoxPtr ADDRESS
#endif
#ifndef impHitTestPtr
#define impHitTestPtr ADDRESS
#endif
#ifndef imp_Dimensions_StructPtr
#define imp_Dimensions_StructPtr ADDRESS
#endif
#ifndef imp_Offset_StructPtr
#define imp_Offset_StructPtr ADDRESS
#endif
#ifndef imp_Point_StructPtr
#define imp_Point_StructPtr ADDRESS
#endif
/*
** End of StructPointer defines for imageclass.h
*/



#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

/*
 * NOTE:  <intuition/iobsolete.h> is included at the END of this file!
 */

#define CUSTOMIMAGEDEPTH    (-1)
/* if image.Depth is this,  it's a new Image class object */

/* some convenient macros and casts */
/*
#define GADGET_BOX( g ) ( (STRUCT IBox *) &((STRUCT Gadget *)(g))->LeftEdge )
#define IM_BOX( im )    ( (STRUCT IBox *) &((STRUCT Image *)(im))->LeftEdge )
#define IM_FGPEN( im )  ( (im)->PlanePick )
#define IM_BGPEN( im )  ( (im)->PlaneOnOff )
*/

/******************************************************/
#define IA_Dummy        (TAG_USER + &H20000)
#define IA_Left         (IA_Dummy + &H01)
#define IA_Top          (IA_Dummy + &H02)
#define IA_Width        (IA_Dummy + &H03)
#define IA_Height       (IA_Dummy + &H04)
#define IA_FGPen        (IA_Dummy + &H05)
            /* IA_FGPen also means "PlanePick"  */
#define IA_BGPen        (IA_Dummy + &H06)
            /* IA_BGPen also means "PlaneOnOff" */
#define IA_Data         (IA_Dummy + &H07)
            /* bitplanes,  for classic image, 
             * other image classes may use it for other things
             */
#define IA_LineWidth        (IA_Dummy + &H08)
#define IA_Pens         (IA_Dummy + &H0E)
            /* pointer to SHORTINT pens[], 
             * ala DrawInfo.Pens,  MUST be
             * terminated by ~0.  Some classes can
             * choose to have this,  or SYSIA_DrawInfo, 
             * or both.
             */
#define IA_Resolution       (IA_Dummy + &H0F)
            /* packed uwords for x/y resolution into a longword
             * ala DrawInfo.Resolution
             */

/**** see class documentation to learn which    *****/
/**** classes recognize these           *****/
#define IA_APattern     (IA_Dummy + &H10)
#define IA_APatSize     (IA_Dummy + &H11)
#define IA_Mode         (IA_Dummy + &H12)
#define IA_Font         (IA_Dummy + &H13)
#define IA_Outline      (IA_Dummy + &H14)
#define IA_Recessed     (IA_Dummy + &H15)
#define IA_DoubleEmboss     (IA_Dummy + &H16)
#define IA_EdgesOnly        (IA_Dummy + &H17)

/**** "sysiclass" attributes            *****/
#define SYSIA_Size      (IA_Dummy + &H0B)
            /* #define's below      */
#define SYSIA_Depth     (IA_Dummy + &H0C)
            /* this is unused by Intuition.  SYSIA_DrawInfo
             * is used instead for V36
             */
#define SYSIA_Which     (IA_Dummy + &H0D)
            /* see #define's below  */
#define SYSIA_DrawInfo      (IA_Dummy + &H18)
            /* pass to sysiclass,  please */

/*****  obsolete: don't use these,  use IA_Pens  *****/
#define SYSIA_Pens      IA_Pens
#define IA_ShadowPen        (IA_Dummy + &H09)
#define IA_HighlightPen     (IA_Dummy + &H0A)

/* New for V39: */
#define SYSIA_ReferenceFont (IA_Dummy + &H19)
            /* Font to use as reference for scaling
             * certain sysiclass images
             */
#define IA_SupportsDisable  (IA_Dummy + &H1a)
            /* By default,  Intuition ghosts gadgets itself, 
             * instead of relying on IDS_DISABLED or
             * IDS_SELECTEDDISABLED.  An imageclass that
             * supports these states should return this attribute
             * as TRUE.  You cannot set or clear this attribute, 
             * however.
             */

#define IA_FrameType        (IA_Dummy + &H1b)
            /* Starting with V39,  FrameIClass recognizes
             * several standard types of frame.  Use one
             * of the FRAME_ specifiers below.  Defaults
             * to FRAME_DEFAULT.
             */

/** next attribute: (IA_Dummy + &H1c)   **/
/*************************************************/

/* data values for SYSIA_Size   */
#define SYSISIZE_MEDRES (0)
#define SYSISIZE_LOWRES (1)
#define SYSISIZE_HIRES  (2)

/*
 * SYSIA_Which tag data values:
 * Specifies which system gadget you want an image for.
 * Some numbers correspond to internal Intuition #defines
 */
#define DEPTHIMAGE  (&H00&) /* Window depth gadget image */
#define ZOOMIMAGE   (&H01&) /* Window zoom gadget image */
#define SIZEIMAGE   (&H02&) /* Window sizing gadget image */
#define CLOSEIMAGE  (&H03&) /* Window close gadget image */
#define SDEPTHIMAGE (&H05&) /* Screen depth gadget image */
#define LEFTIMAGE   (&H0A&) /* Left-arrow gadget image */
#define UPIMAGE     (&H0B&) /* Up-arrow gadget image */
#define RIGHTIMAGE  (&H0C&) /* Right-arrow gadget image */
#define DOWNIMAGE   (&H0D&) /* Down-arrow gadget image */
#define CHECKIMAGE  (&H0E&) /* GadTools checkbox image */
#define MXIMAGE     (&H0F&) /* GadTools mutual exclude "button" image */
/* New for V39: */
#define MENUCHECK   (&H10&) /* Menu checkmark image */
#define AMIGAKEY    (&H11&) /* Menu Amiga-key image */

/* Data values for IA_FrameType (recognized by FrameIClass)
 *
 * FRAME_DEFAULT:  The standard V37-type frame,  which has
 *  thin edges.
 * FRAME_BUTTON:  Standard button gadget frames,  having thicker
 *  sides and nicely edged corners.
 * FRAME_RIDGE:  A ridge such as used by standard string gadgets.
 *  You can recess the ridge to get a groove image.
 * FRAME_ICONDROPBOX: A broad ridge which is the standard imagery
 *  for areas in AppWindows where icons may be dropped.
 */

#define FRAME_DEFAULT       0
#define FRAME_BUTTON        1
#define FRAME_RIDGE     2
#define FRAME_ICONDROPBOX   3


/* image message id's   */
#define    IM_DRAW  &H202&  /* draw yourself,  with "state"      */
#define    IM_HITTEST   &H203&  /* return TRUE if click hits image  */
#define    IM_ERASE &H204&  /* erase yourself           */
#define    IM_MOVE  &H205&  /* draw new and erase old,  smoothly */

#define    IM_DRAWFRAME &H206&  /* draw with specified dimensions   */
#define    IM_FRAMEBOX  &H207&  /* get recommended frame around some box*/
#define    IM_HITFRAME  &H208&  /* hittest with dimensions      */
#define    IM_ERASEFRAME &H209& /* hittest with dimensions      */

/* image draw states or styles,  for IM_DRAW */
/* Note that they have no bitwise meanings (unfortunately) */
#define    IDS_NORMAL       (0&)
#define    IDS_SELECTED     (1&)    /* for selected gadgets     */
#define    IDS_DISABLED     (2&)    /* for disabled gadgets     */
#define    IDS_BUSY     (3&)    /* for future functionality */
#define    IDS_INDETERMINATE    (4&)    /* for future functionality */
#define    IDS_INACTIVENORMAL   (5&)    /* normal,  in inactive window border */
#define    IDS_INACTIVESELECTED (6&)    /* selected,  in inactive border */
#define    IDS_INACTIVEDISABLED (7&)    /* disabled,  in inactive border */
#define    IDS_SELECTEDDISABLED (8&)    /* disabled and selected    */

/* oops,  please forgive spelling error by jimm */
#define IDS_INDETERMINANT IDS_INDETERMINATE

/* IM_FRAMEBOX  */
STRUCT impFrameBox  
    LONGINT       MethodID 
    IBoxPtr  imp_ContentsBox    /* input: relative box of contents */
    IBoxPtr  imp_FrameBox       /* output: rel. box of encl frame  */
    DrawInfoPtr  imp_DrInfo     /* NB: May be NULL */
    LONGINT   imp_FrameFlags 
END STRUCT 

#define FRAMEF_SPECIFY  (&H1)  /* Make do with the dimensions of FrameBox
                 * provided.
                 */

/* IM_DRAW,  IM_DRAWFRAME    */

STRUCT imp_Offset_Struct  
    SHORTINT    X 
    SHORTINT    Y 
END STRUCT 

STRUCT imp_Dimensions_Struct  
    SHORTINT    _Width 
    SHORTINT    Height 
END STRUCT 

STRUCT impDraw  
    LONGINT       MethodID 
    RastPortPtr  imp_RPort 
    imp_Offset_Struct imp_Offset 

    LONGINT       imp_State 
    DrawInfoPtr  imp_DrInfo     /* NB: May be NULL */

    /* these parameters only valid for IM_DRAWFRAME */
    imp_Dimensions_Struct imp_Dimensions 
END STRUCT 

/* IM_ERASE,  IM_ERASEFRAME  */
/* NOTE: This is a subset of impDraw    */

STRUCT impErase  
    LONGINT       MethodID 
    RastPortPtr  imp_RPort 
    imp_Offset_Struct imp_Offset 

    /* these parameters only valid for IM_ERASEFRAME */
    imp_Dimensions_Struct imp_Dimensions 
END STRUCT 

/* IM_HITTEST,  IM_HITFRAME  */

STRUCT imp_Point_Struct  
    SHORTINT    X 
    SHORTINT    Y 
END STRUCT 

STRUCT impHitTest  
    LONGINT       MethodID 
    imp_Point_Struct imp_Point 

    /* these parameters only valid for IM_HITFRAME */
    imp_Dimensions_Struct imp_Dimensions 
END STRUCT 

/* Include obsolete identifiers: */
#ifndef INTUITION_IOBSOLETE_H
#include <intuition/iobsolete.h>
#endif

#endif
