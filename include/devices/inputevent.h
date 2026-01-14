#ifndef DEVICES_INPUTEVENT_H
#define DEVICES_INPUTEVENT_H 1
/*
** inputevent.h for ACE Basic
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
** This are the StructPointer defines for inputevent.h
*/
#ifndef IENewTabletPtr
#define IENewTabletPtr ADDRESS
#endif
#ifndef IEPointerPixelPtr
#define IEPointerPixelPtr ADDRESS
#endif
#ifndef IEPointerTabletPtr
#define IEPointerTabletPtr ADDRESS
#endif
#ifndef InputEventPtr
#define InputEventPtr ADDRESS
#endif
#ifndef ie_dead_StructPtr
#define ie_dead_StructPtr ADDRESS
#endif
#ifndef ie_xy_StructPtr
#define ie_xy_StructPtr ADDRESS
#endif
#ifndef iepi_Range_StructPtr
#define iepi_Range_StructPtr ADDRESS
#endif
#ifndef iepp_Position_StructPtr
#define iepp_Position_StructPtr ADDRESS
#endif
#ifndef iept_Value_StructPtr
#define iept_Value_StructPtr ADDRESS
#endif
/*
** End of StructPointer defines for inputevent.h
*/
                   
#ifndef DEVICES_TIMER_H
#include <devices/TIMER.h>
#endif

#ifndef UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef ScreenPtr
#define ScreenPtr ADDRESS
#endif


/*----- constants --------------------------------------------------*/

/*  --- InputEvent.ie_Class --- */
/* A NOP input event */
#define IECLASS_NULL            &H00
/* A raw keycode from the keyboard device */
#define IECLASS_RAWKEY          &H01
/* The raw mouse report from the game port device */
#define IECLASS_RAWMOUSE        &H02
/* A private console event */
#define IECLASS_EVENT           &H03
/* A Pointer Position report */
#define IECLASS_POINTERPOS      &H04
/* A timer event */
#define IECLASS_TIMER           &H06
/* select button pressed down over a Gadget (address in ie_EventAddress) */
#define IECLASS_GADGETDOWN      &H07
/* select button released over the same Gadget (address in ie_EventAddress) */
#define IECLASS_GADGETUP        &H08
/* some Requester activity has taken place.  See Codes REQCLEAR and REQSET */
#define IECLASS_REQUESTER       &H09
/* this is a Menu Number transmission (Menu number is in ie_Code) */
#define IECLASS_MENULIST        &H0A
/* User has selected the active Window's Close Gadget */
#define IECLASS_CLOSEWINDOW     &H0B
/* this Window has a new size */
#define IECLASS_SIZEWINDOW      &H0C
/* the Window pointed to by ie_EventAddress needs to be refreshed */
#define IECLASS_REFRESHWINDOW       &H0D
/* new preferences are available */
#define IECLASS_NEWPREFS        &H0E
/* the disk has been removed */
#define IECLASS_DISKREMOVED     &H0F
/* the disk has been inserted */
#define IECLASS_DISKINSERTED        &H10
/* the window is about to be been made active */
#define IECLASS_ACTIVEWINDOW        &H11
/* the window is about to be made inactive */
#define IECLASS_INACTIVEWINDOW      &H12
/* extended-function pointer position report (V36) */
#define IECLASS_NEWPOINTERPOS       &H13
/* Help key report during Menu session (V36) */
#define IECLASS_MENUHELP        &H14
/* the Window has been modified with move,  size,  zoom,  or change (V36) */
#define IECLASS_CHANGEWINDOW        &H15

/* the last class */
#define IECLASS_MAX         &H15


/*  --- InputEvent.ie_SubClass --- */
/*  IECLASS_NEWPOINTERPOS */
/*  like IECLASS_POINTERPOS */
#define IESUBCLASS_COMPATIBLE   &H00
/*  ie_EventAddress points to STRUCT IEPointerPixel */
#define IESUBCLASS_PIXEL    &H01
/*  ie_EventAddress points to STRUCT IEPointerTablet */
#define IESUBCLASS_TABLET   &H02
/*  ie_EventAddress points to STRUCT IENewTablet */
#define IESUBCLASS_NEWTABLET       &H03

/* pointed to by ie_EventAddress for IECLASS_NEWPOINTERPOS, 
 * and IESUBCLASS_PIXEL.
 *
 * You specify a screen and pixel coordinates in that screen
 * at which you'd like the mouse to be positioned.
 * Intuition will try to oblige,  but there will be restrictions
 * to positioning the pointer over offscreen pixels.
 *
 * IEQUALIFIER_RELATIVEMOUSE is supported for IESUBCLASS_PIXEL.
 */

STRUCT iepp_Position_Struct                  /* pixel coordinates in iepp_Screen */
    SHORTINT    X 
    SHORTINT    Y 
END STRUCT 

STRUCT IEPointerPixel    
    ScreenPtr  iepp_Screen    /* pointer to an open screen */
    iepp_Position_Struct iepp_Position   /* pixel coordinates in iepp_Screen */
END STRUCT 

/* pointed to by ie_EventAddress for IECLASS_NEWPOINTERPOS, 
 * and IESUBCLASS_TABLET.
 *
 * You specify a range of values and a value within the range
 * independently for each of X and Y (the minimum value of
 * the ranges is always normalized to 0).
 *
 * Intuition will position the mouse proportionally within its
 * natural mouse position rectangle limits.
 *
 * IEQUALIFIER_RELATIVEMOUSE is not supported for IESUBCLASS_TABLET.
 */

STRUCT iepi_Range_Struct  
    SHORTINT  X 
    SHORTINT  Y 
END STRUCT

STRUCT iept_Value_Struct  
    SHORTINT  X 
    SHORTINT  Y 
END STRUCT

STRUCT IEPointerTablet   
    iepi_Range_Struct iepi_Range 

    iept_Value_Struct iept_Value

    SHORTINT        iept_Pressure   /* -128 to 127 (unused,  set to 0)  */
END STRUCT 


/* The ie_EventAddress of an IECLASS_NEWPOINTERPOS event of subclass
 * IESUBCLASS_NEWTABLET points at an IENewTablet structure.
 *
 *
 * IEQUALIFIER_RELATIVEMOUSE is not supported for IESUBCLASS_NEWTABLET.
 */

STRUCT IENewTablet
 
    /* Pointer to a hook you wish to be called back through,  in
     * order to handle scaling.  You will be provided with the
     * width and height you are expected to scale your tablet
     * to,  perhaps based on some user preferences.
     * If NULL,  the tablet's specified range will be mapped directly
     * to that width and height for you,  and you will not be
     * called back.
     */
    HookPtr  ient_CallBack 

    /* Post-scaling coordinates and fractional coordinates.
     * DO NOT FILL THESE IN AT THE TIME THE EVENT IS WRITTEN!
     * Your driver will be called back and provided information
     * about the width and height of the area to scale the
     * tablet into.  It should scale the tablet coordinates
     * (perhaps based on some preferences controlling aspect
     * ratio,  etc.) and place the scaled result into these
     * fields.  The ient_ScaledX and ient_ScaledY fields are
     * in screen-pixel resolution,  but the origin ( [0, 0]-point )
     * is not defined.  The ient_ScaledXFraction and
     * ient_ScaledYFraction fields represent sub-pixel position
     * information,  and should be scaled to fill a SHORTINT fraction.
     */
    SHORTINT ient_ScaledX 
    SHORTINT   ient_ScaledY 
    SHORTINT ient_ScaledXFraction 
    SHORTINT   ient_ScaledYFraction 

    /* Current tablet coordinates along each axis: */
    LONGINT ient_TabletX 
    LONGINT   ient_TabletY 

    /* Tablet range along each axis.  For example,  if ient_TabletX
     * can take values 0-999,  ient_RangeX should be 1000.
     */
    LONGINT ient_RangeX 
    LONGINT   ient_RangeY 

    /* Pointer to tag-list of additional tablet attributes.
     * See <intuition/intuition.h> for the tag values.
     */
    TagItemPtr  ient_TagList 
END STRUCT 


/*  --- InputEvent.ie_Code --- */
/*  IECLASS_RAWKEY */
#define IECODE_UP_PREFIX        &H80
#define IECODE_KEY_CODE_FIRST       &H00
#define IECODE_KEY_CODE_LAST        &H77
#define IECODE_COMM_CODE_FIRST      &H78
#define IECODE_COMM_CODE_LAST       &H7F

/*  IECLASS_ANSI */
#define IECODE_C0_FIRST         &H00
#define IECODE_C0_LAST          &H1F
#define IECODE_ASCII_FIRST      &H20
#define IECODE_ASCII_LAST       &H7E
#define IECODE_ASCII_DEL        &H7F
#define IECODE_C1_FIRST         &H80
#define IECODE_C1_LAST          &H9F
#define IECODE_LATIN1_FIRST     &HA0
#define IECODE_LATIN1_LAST      &HFF

/*  IECLASS_RAWMOUSE */
#define IECODE_LBUTTON          &H68    /* also uses IECODE_UP_PREFIX */
#define IECODE_RBUTTON          &H69
#define IECODE_MBUTTON          &H6A
#define IECODE_NOBUTTON         &HFF

/*  IECLASS_EVENT (V36) */
#define IECODE_NEWACTIVE        &H01    /* new active input window */
#define IECODE_NEWSIZE          &H02    /* resize of window */
#define IECODE_REFRESH          &H03    /* refresh of window */

/*  IECLASS_REQUESTER */
/*  broadcast when the first Requester (not subsequent ones) opens up in */
/*  the Window */
#define IECODE_REQSET           &H01
/*  broadcast when the last Requester clears out of the Window */
#define IECODE_REQCLEAR         &H00



/*  --- InputEvent.ie_Qualifier --- */
#define IEQUALIFIER_LSHIFT      &H0001
#define IEQUALIFIER_RSHIFT      &H0002
#define IEQUALIFIER_CAPSLOCK        &H0004
#define IEQUALIFIER_CONTROL     &H0008
#define IEQUALIFIER_LALT        &H0010
#define IEQUALIFIER_RALT        &H0020
#define IEQUALIFIER_LCOMMAND        &H0040
#define IEQUALIFIER_RCOMMAND        &H0080
#define IEQUALIFIER_NUMERICPAD      &H0100
#define IEQUALIFIER_REPEAT      &H0200
#define IEQUALIFIER_INTERRUPT       &H0400
#define IEQUALIFIER_MULTIBROADCAST  &H0800
#define IEQUALIFIER_MIDBUTTON       &H1000
#define IEQUALIFIER_RBUTTON     &H2000
#define IEQUALIFIER_LEFTBUTTON      &H4000
#define IEQUALIFIER_RELATIVEMOUSE   &H8000

#define IEQUALIFIERB_LSHIFT     0
#define IEQUALIFIERB_RSHIFT     1
#define IEQUALIFIERB_CAPSLOCK       2
#define IEQUALIFIERB_CONTROL        3
#define IEQUALIFIERB_LALT       4
#define IEQUALIFIERB_RALT       5
#define IEQUALIFIERB_LCOMMAND       6
#define IEQUALIFIERB_RCOMMAND       7
#define IEQUALIFIERB_NUMERICPAD     8
#define IEQUALIFIERB_REPEAT     9
#define IEQUALIFIERB_INTERRUPT      10
#define IEQUALIFIERB_MULTIBROADCAST 11
#define IEQUALIFIERB_MIDBUTTON      12
#define IEQUALIFIERB_RBUTTON        13
#define IEQUALIFIERB_LEFTBUTTON     14
#define IEQUALIFIERB_RELATIVEMOUSE  15

/*----- InputEvent -------------------------------------------------*/

STRUCT ie_xy_Struct  
    SHORTINT    ie_x        /* the pointer position for the event*/
    SHORTINT    ie_y 
END STRUCT 

STRUCT ie_dead_Struct  
    BYTE    ie_prev1DownCode    /* previous down keys for dead */
    BYTE    ie_prev1DownQual    /*   key translation: the ie_Code */
    BYTE    ie_prev2DownCode    /*   & low byte of ie_Qualifier for */
    BYTE    ie_prev2DownQual    /*   last & second last down keys */
END STRUCT 

STRUCT InputEvent  
    InputEventPtr  ie_NextEvent    /* the chronologically next event */
    BYTE    ie_Class            /* the input event class */
    BYTE    ie_SubClass         /* optional subclass of the class */
    SHORTINT   ie_Code             /* the input event code */
    SHORTINT   ie_Qualifier        /* qualifiers in effect for the event*/
    ADDRESS    ie_addr_xy 
    timeval ie_TimeStamp     /* the system tick at the event */
END STRUCT 

#define ie_X            ie_position.ie_xy.ie_x
#define ie_Y            ie_position.ie_xy.ie_y
#define ie_EventAddress     ie_position.ie_addr
#define ie_Prev1DownCode    ie_position.ie_dead.ie_prev1DownCode
#define ie_Prev1DownQual    ie_position.ie_dead.ie_prev1DownQual
#define ie_Prev2DownCode    ie_position.ie_dead.ie_prev2DownCode
#define ie_Prev2DownQual    ie_position.ie_dead.ie_prev2DownQual

#endif  /* DEVICES_INPUTEVENT_H */
