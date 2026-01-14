#ifndef INTUITION_INTUITION_H
#define INTUITION_INTUITION_H TRUE
/*
** intuition.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
** Note: Fixed some missing kludgefill.
**       It was missing in:
**       Struct IntuiText
**       Struct Requester
**       Struct MenuItem
**       Date 14-Oct-95   Nils Sjoholm
**
*/


/*
** This are the StructPointer defines for intuition.h
*/
#ifndef BoolInfoPtr
#define BoolInfoPtr ADDRESS
#endif
#ifndef BorderPtr
#define BorderPtr ADDRESS
#endif
#ifndef ColorSpecPtr
#define ColorSpecPtr ADDRESS
#endif
#ifndef EasyStructPtr
#define EasyStructPtr ADDRESS
#endif
#ifndef ExtGadgetPtr
#define ExtGadgetPtr ADDRESS
#endif
#ifndef ExtIntuiMessagePtr
#define ExtIntuiMessagePtr ADDRESS
#endif
#ifndef ExtNewWindowPtr
#define ExtNewWindowPtr ADDRESS
#endif
#ifndef GadgetPtr
#define GadgetPtr ADDRESS
#endif
#ifndef IBoxPtr
#define IBoxPtr ADDRESS
#endif
#ifndef ImagePtr
#define ImagePtr ADDRESS
#endif
#ifndef IntuiMessagePtr
#define IntuiMessagePtr ADDRESS
#endif
#ifndef IntuiTextPtr
#define IntuiTextPtr ADDRESS
#endif
#ifndef MenuPtr
#define MenuPtr ADDRESS
#endif
#ifndef MenuItemPtr
#define MenuItemPtr ADDRESS
#endif
#ifndef NewWindowPtr
#define NewWindowPtr ADDRESS
#endif
#ifndef PropInfoPtr
#define PropInfoPtr ADDRESS
#endif
#ifndef RememberPtr
#define RememberPtr ADDRESS
#endif
#ifndef RequesterPtr
#define RequesterPtr ADDRESS
#endif
#ifndef StringInfoPtr
#define StringInfoPtr ADDRESS
#endif
#ifndef TabletDataPtr
#define TabletDataPtr ADDRESS
#endif
#ifndef TabletHookDataPtr
#define TabletHookDataPtr ADDRESS
#endif
#ifndef WindowPtr
#define WindowPtr ADDRESS
#endif
/*
** End of StructPointer defines for intuition.h
*/                  



#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif

#ifndef GRAPHICS_CLIP_H
#include <graphics/clip.h>
#endif

#ifndef GRAPHICS_VIEW_H
#include <graphics/view.h>
#endif

#ifndef GRAPHICS_RASTPORT_H
#include <graphics/rastport.h>
#endif

#ifndef GRAPHICS_LAYERS_H
#include <graphics/layers.h>
#endif

#ifndef GRAPHICS_TEXT_H
#include <graphics/text.h>
#endif

#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif

#ifndef DEVICES_INPUTEVENT_H
#include <devices/inputevent.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif


#ifndef KeyMapPtr
#define KeyMapPtr ADDRESS
#endif
#ifndef ScreenPtr
#define ScreenPtr ADDRESS
#endif
#ifndef StringExtendPtr
#define StringExtendPtr ADDRESS
#endif

/*
 * NOTE:  intuition/iobsolete.h is included at the END of this file!
 */

/* ======================================================================== */
/* === Menu =============================================================== */
/* ======================================================================== */
STRUCT _Menu
 
    MenuPtr  NextMenu  /* same level */
    SHORTINT LeftEdge 
    SHORTINT   TopEdge    /* position of the select box */
    SHORTINT _Width 
    SHORTINT   Height  /* dimensions of the select box */
    SHORTINT Flags      /* see flag definitions below */
    ADDRESS   MenuName      /* text for this Menu Header */
    MenuItemPtr  FirstItem  /* pointer to first in chain */

    /* these mysteriously-named variables are for internal use only */
    SHORTINT JazzX 
    SHORTINT   JazzY 
    SHORTINT   BeatX 
    SHORTINT   BeatY 
END STRUCT 


/* FLAGS SET BY BOTH THE APPLIPROG AND INTUITION */
#define MENUENABLED &H0001 /* whether or not this menu is enabled */

/* FLAGS SET BY INTUITION */
#define MIDRAWN &H0100     /* this menu's items are currently drawn */






/* ======================================================================== */
/* === MenuItem =========================================================== */
/* ======================================================================== */
STRUCT MenuItem
 
    MenuItemPtr  NextItem    /* pointer to next in chained list */
    SHORTINT LeftEdge 
    SHORTINT   TopEdge    /* position of the select box */
    SHORTINT _Width 
    SHORTINT   Height     /* dimensions of the select box */
    SHORTINT Flags      /* see the defines below */

    LONGINT MutualExclude     /* set bits mean this item excludes that */

    ADDRESS ItemFill       /* points to Image,  IntuiText,  or NULL */

    /* when this item is pointed to by the cursor and the items highlight
     *   mode HIGHIMAGE is selected,  this alternate image will be displayed
     */
    ADDRESS SelectFill     /* points to Image,  IntuiText,  or NULL */

    BYTE Command     /* only if appliprog sets the COMMSEQ flag */
    BYTE KludgeFill000
    MenuItemPtr  SubItem  /* if non-zero,  points to MenuItem for submenu */

    /* The NextSelect field represents the menu number of next selected
     *   item (when user has drag-selected several items)
     */
    SHORTINT NextSelect 
END STRUCT 


/* FLAGS SET BY THE APPLIPROG */
#define CHECKIT      &H0001   /* set to indicate checkmarkable item */
#define ITEMTEXT  &H0002   /* set if textual,  clear if graphical item */
#define COMMSEQ      &H0004   /* set if there's an command sequence */
#define MENUTOGGLE   &H0008   /* set for toggling checks (else mut. exclude) */
#define ITEMENABLED  &H0010   /* set if this item is enabled */

/* these are the SPECIAL HIGHLIGHT FLAG state meanings */
#define HIGHFLAGS &H00C0   /* see definitions below for these bits */
#define HIGHIMAGE &H0000   /* use the user's "select image" */
#define HIGHCOMP  &H0040   /* highlight by complementing the selectbox */
#define HIGHBOX      &H0080   /* highlight by "boxing" the selectbox */
#define HIGHNONE  &H00C0   /* don't highlight */

/* FLAGS SET BY BOTH APPLIPROG AND INTUITION */
#define CHECKED   &H0100   /* state of the checkmark */

/* FLAGS SET BY INTUITION */
#define ISDRAWN      &H1000   /* this item's subs are currently drawn */
#define HIGHITEM  &H2000   /* this item is currently highlighted */
#define MENUTOGGLED  &H4000   /* this item was already toggled */





/* ======================================================================== */
/* === Requester ========================================================== */
/* ======================================================================== */
STRUCT Requester
 
    RequesterPtr  OlderRequest 
    SHORTINT LeftEdge 
    SHORTINT   TopEdge       /* dimensions of the entire box */
    SHORTINT _Width 
    SHORTINT   Height        /* dimensions of the entire box */
    SHORTINT RelLeft 
    SHORTINT   RelTop      /* for Pointer relativity offsets */

    GadgetPtr  ReqGadget     /* pointer to a list of Gadgets */
    BorderPtr  ReqBorder     /* the box's border */
    IntuiTextPtr  ReqText       /* the box's text */
    SHORTINT Flags         /* see definitions below */

    /* pen number for back-plane fill before draws */
    BYTE  BackFill 
    BYTE  KludgeFill00
    /* Layer in place of clip rect  */
    LayerPtr  ReqLayer 

    STRING ReqPad1 SIZE 32  

    /* If the BitMap plane pointers are non-zero,  this tells the system
     * that the image comes pre-drawn (if the appliprog wants to define
     * its own box,  in any shape or size it wants!)   this is OK by
     * Intuition as LONGINT as there's a good correspondence between
     * the image and the specified Gadgets
     */
    BitMapPtr  ImageBMap  /* points to the BitMap of PREDRAWN imagery */
    WindowPtr  RWindow    /* added.  points back to Window */

    ImagePtr  ReqImage   /* new for V36: drawn if USEREQIMAGE set */

    STRING ReqPad2 SIZE 32  
END STRUCT 


/* FLAGS SET BY THE APPLIPROG */
#define POINTREL  &H0001
           /* if POINTREL set,  TopLeft is relative to pointer
            * for DMRequester,  relative to window center
            * for Request().
            */
#define PREDRAWN  &H0002
   /* set if Requester.ImageBMap points to predrawn Requester imagery */
#define NOISYREQ  &H0004
   /* if you don't want requester to filter input     */
#define SIMPLEREQ &H0010
   /* to use SIMPLEREFRESH layer (recommended)  */

/* New for V36    */
#define USEREQIMAGE  &H0020
   /*  render linked list ReqImage after BackFill
    * but before gadgets and text
    */
#define NOREQBACKFILL   &H0040
   /* don't bother filling requester with Requester.BackFill pen  */


/* FLAGS SET BY INTUITION */
#define REQOFFWINDOW &H1000   /* part of one of the Gadgets was offwindow */
#define REQACTIVE &H2000   /* this requester is active */
#define SYSREQUEST   &H4000   /* (unused) this requester caused by system */
#define DEFERREFRESH &H8000   /* this Requester stops a Refresh broadcast */






/* ======================================================================== */
/* === Gadget ============================================================= */
/* ======================================================================== */
STRUCT _Gadget
 
    GadgetPtr  NextGadget    /* next gadget in the list */

    SHORTINT LeftEdge 
    SHORTINT   TopEdge    /* "hit box" of gadget */
    SHORTINT _Width 
    SHORTINT   Height     /* "hit box" of gadget */

    SHORTINT Flags      /* see below for list of defines */

    SHORTINT Activation       /* see below for list of defines */

    SHORTINT GadgetType       /* see below for defines */

    /* appliprog can specify that the Gadget be rendered as either as Border
     * or an Image.  This variable points to which (or equals NULL if there's
     * nothing to be rendered about this Gadget)
     */
    ADDRESS GadgetRender 

    /* appliprog can specify "highlighted" imagery rather than algorithmic
     * this can point to either Border or Image data
     */
    ADDRESS SelectRender 

    IntuiTextPtr  GadgetText    /* text for this gadget */

    /* MutualExclude,  never implemented,  is now declared obsolete.
     * There are published examples of implementing a more general
     * and practical exclusion in your applications.
     *
     * Starting with V36,  this field is used to point to a hook
     * for a custom gadget.
     *
     * Programs using this field for their own processing will
     * continue to work,  as LONGINT as they don't try the
     * trick with custom gadgets.
     */
    LONGINT MutualExclude   /* obsolete */

    /* pointer to a structure of special data required by Proportional, 
     * String and Integer Gadgets
     */
    ADDRESS SpecialInfo 

    SHORTINT GadgetID   /* user-definable ID field */
    ADDRESS UserData    /* ptr to general purpose User data (ignored by In) */
END STRUCT 


STRUCT ExtGadget
 
    /* The first fields match STRUCT Gadget exactly */
    ExtGadgetPtr  NextGadget  /* Matches STRUCT Gadget */
    SHORTINT LeftEdge 
    SHORTINT   TopEdge      /* Matches STRUCT Gadget */
    SHORTINT _Width 
    SHORTINT   Height       /* Matches STRUCT Gadget */
    SHORTINT Flags        /* Matches STRUCT Gadget */
    SHORTINT Activation         /* Matches STRUCT Gadget */
    SHORTINT GadgetType         /* Matches STRUCT Gadget */
    ADDRESS GadgetRender        /* Matches STRUCT Gadget */
    ADDRESS SelectRender        /* Matches STRUCT Gadget */
    IntuiTextPtr  GadgetText  /* Matches STRUCT Gadget */
    LONGINT MutualExclude       /* Matches STRUCT Gadget */
    ADDRESS SpecialInfo         /* Matches STRUCT Gadget */
    SHORTINT GadgetID        /* Matches STRUCT Gadget */
    ADDRESS UserData         /* Matches STRUCT Gadget */

    /* These fields only exist under V39 and only if GFLG_EXTENDED is set */
    LONGINT MoreFlags     /* see GMORE_ flags below */
    SHORTINT BoundsLeftEdge    /* Bounding extent for gadget,  valid   */
    SHORTINT BoundsTopEdge     /* only if GMORE_BOUNDS is set.  The   */
    SHORTINT BoundsWidth       /* GFLG_RELxxx flags affect these      */
    SHORTINT BoundsHeight      /* coordinates as well.        */
END STRUCT 


/* --- Gadget.Flags values --- */
/* combinations in these bits describe the highlight technique to be used */
#define GFLG_GADGHIGHBITS &H0003
#define GFLG_GADGHCOMP    &H0000  /* Complement the select box */
#define GFLG_GADGHBOX     &H0001  /* Draw a box around the image */
#define GFLG_GADGHIMAGE   &H0002  /* Blast in this alternate image */
#define GFLG_GADGHNONE    &H0003  /* don't highlight */

#define GFLG_GADGIMAGE       &H0004  /* set if GadgetRender and SelectRender
               * point to an Image structure,  clear
               * if they point to Border structures
               */

/* combinations in these next two bits specify to which corner the gadget's
 *  Left & Top coordinates are relative.  If relative to Top/Left, 
 *  these are "normal" coordinates (everything is relative to something in
 *  this universe).
 *
 * Gadget positions and dimensions are relative to the window or
 * requester which contains the gadget
 */
#define GFLG_RELBOTTOM    &H0008  /* vert. pos. is relative to bottom edge */
#define GFLG_RELRIGHT     &H0010  /* horiz. pos. is relative to right edge */
#define GFLG_RELWIDTH     &H0020  /* width is relative to req/window */
#define GFLG_RELHEIGHT    &H0040  /* height is relative to req/window   */

/* New for V39: GFLG_RELSPECIAL allows custom gadget implementors to
 * make gadgets whose position and size depend in an arbitrary way
 * on their window's dimensions.  The GM_LAYOUT method will be invoked
 * for such a gadget (or any other GREL_xxx gadget) at suitable times, 
 * such as when the window opens or the window's size changes.
 */
#define GFLG_RELSPECIAL   &H4000  /* custom gadget has special relativity.
               * Gadget box values are absolutes,  but
               * can be changed via the GM_LAYOUT method.
               */
#define GFLG_SELECTED     &H0080  /* you may initialize and look at this   */

/* the GFLG_DISABLED flag is initialized by you and later set by Intuition
 * according to your calls to On/OffGadget().  It specifies whether or not
 * this Gadget is currently disabled from being selected
 */
#define GFLG_DISABLED     &H0100

/* These flags specify the type of text field that Gadget.GadgetText
 * points to.  In all normal (pre-V36) gadgets which you initialize
 * this field should always be zero.  Some types of gadget objects
 * created from classes will use these fields to keep track of
 * types of labels/contents that different from IntuiText,  but are
 * stashed in GadgetText.
 */

#define GFLG_LABELMASK    &H3000
#define GFLG_LABELITEXT   &H0000  /* GadgetText points to IntuiText  */
#define  GFLG_LABELSTRING  &H1000  /* GadgetText points to (BYTE  *) */
#define GFLG_LABELIMAGE   &H2000  /* GadgetText points to Image (object)   */

/* New for V37: GFLG_TABCYCLE */
#define GFLG_TABCYCLE     &H0200  /* (string or custom) gadget participates in
               * cycling activation with Tab or Shift-Tab
               */
/* New for V37: GFLG_STRINGEXTEND.  We discovered that V34 doesn't properly
 * ignore the value we had chosen for the Gadget->Activation flag
 * GACT_STRINGEXTEND.  NEVER SET THAT FLAG WHEN RUNNING UNDER V34.
 * The Gadget->Flags bit GFLG_STRINGEXTEND is provided as a synonym which is
 * safe under V34,  and equivalent to GACT_STRINGEXTEND under V37.
 * (Note that the two flags are not numerically equal)
 */
#define GFLG_STRINGEXTEND &H0400  /* this String Gadget has StringExtend   */

/* New for V39: GFLG_IMAGEDISABLE.  This flag is automatically set if
 * the custom image of this gadget knows how to do disabled rendering
 * (more specifically,  if its IA_SupportsDisable attribute is TRUE).
 * Intuition uses this to defer the ghosting to the image-class, 
 * instead of doing it itself (the old compatible way).
 * Do not set this flag yourself - Intuition will do it for you.
 */

#define GFLG_IMAGEDISABLE &H0800  /* Gadget's image knows how to do disabled
               * rendering
               */

/* New for V39:  If set,  this bit means that the Gadget is actually
 * a STRUCT ExtGadget,  with new fields and flags.  All V39 boopsi
 * gadgets are ExtGadgets.  Never ever attempt to read the extended
 * fields of a gadget if this flag is not set.
 */
#define GFLG_EXTENDED     &H8000  /* Gadget is extended */

/* ---   Gadget.Activation flag values --- */
/* Set GACT_RELVERIFY if you want to verify that the pointer was still over
 * the gadget when the select button was released.  Will cause
 * an IDCMP_GADGETUP message to be sent if so.
 */
#define GACT_RELVERIFY    &H0001

/* the flag GACT_IMMEDIATE,  when set,  informs the caller that the gadget
 *  was activated when it was activated.  This flag works in conjunction with
 *  the GACT_RELVERIFY flag
 */
#define GACT_IMMEDIATE    &H0002

/* the flag GACT_ENDGADGET,  when set,  tells the system that this gadget, 
 * when selected,  causes the Requester to be ended.  Requesters
 * that are ended are erased and unlinked from the system.
 */
#define GACT_ENDGADGET    &H0004

/* the GACT_FOLLOWMOUSE flag,  when set,  specifies that you want to receive
 * reports on mouse movements while this gadget is active.
 * You probably want to set the GACT_IMMEDIATE flag when using
 * GACT_FOLLOWMOUSE,  since that's the only reasonable way you have of
 * learning why Intuition is suddenly sending you a stream of mouse
 * movement events.  If you don't set GACT_RELVERIFY,  you'll get at
 * least one Mouse Position event.
 * Note: boolean FOLLOWMOUSE gadgets require GACT_RELVERIFY to get
 * _any_ mouse movement events (this unusual behavior is a compatibility
 * hold-over from the old days).
 */
#define GACT_FOLLOWMOUSE  &H0008

/* if any of the BORDER flags are set in a Gadget that's included in the
 * Gadget list when a Window is opened,  the corresponding Border will
 * be adjusted to make room for the Gadget
 */
#define GACT_RIGHTBORDER  &H0010
#define GACT_LEFTBORDER   &H0020
#define GACT_TOPBORDER    &H0040
#define GACT_BOTTOMBORDER &H0080
#define GACT_BORDERSNIFF  &H8000  /* neither set nor rely on this bit   */

#define GACT_TOGGLESELECT &H0100  /* this bit for toggle-select mode */
#define GACT_BOOLEXTEND   &H2000  /* this Boolean Gadget has a BoolInfo */

/* should properly be in StringInfo,  but aren't */
#define GACT_STRINGLEFT   &H0000  /* NOTE WELL: that this has value zero   */
#define GACT_STRINGCENTER &H0200
#define GACT_STRINGRIGHT  &H0400
#define GACT_LONGINT   &H0800  /* this String Gadget is for LONGINT Ints   */
#define GACT_ALTKEYMAP    &H1000  /* this String has an alternate keymap   */
#define GACT_STRINGEXTEND &H2000  /* this String Gadget has StringExtend   */
              /* NOTE: NEVER SET GACT_STRINGEXTEND IF YOU
               * ARE RUNNING ON LESS THAN V36!  SEE
               * GFLG_STRINGEXTEND (ABOVE) INSTEAD
               */

#define GACT_ACTIVEGADGET &H4000  /* this gadget is "active".  This flag
               * is maintained by Intuition,  and you
               * cannot count on its value persisting
               * while you do something on your program's
               * task.  It can only be trusted by
               * people implementing custom gadgets
               */

/* note &H8000 is used above (GACT_BORDERSNIFF) 
 * all Activation flags defined */

/* --- GADGET TYPES ------------------------------------------------------- */
/* These are the Gadget Type definitions for the variable GadgetType
 * gadget number type MUST start from one.  NO TYPES OF ZERO ALLOWED.
 * first comes the mask for Gadget flags reserved for Gadget typing
 */
#define GTYP_GADGETTYPE &HFC00   /* all Gadget Global Type flags (padded) */

#define GTYP_SCRGADGET     &H4000   /* 1 = ScreenGadget,  0 = WindowGadget */
#define GTYP_GZZGADGET     &H2000   /* 1 = for WFLG_GIMMEZEROZERO borders */
#define GTYP_REQGADGET     &H1000   /* 1 = this is a Requester Gadget */

/* GTYP_SYSGADGET means that Intuition ALLOCATED the gadget.
 * GTYP_SYSTYPEMASK is the mask you can apply to tell what type of
 * system-gadget it is.  The possible types follow.
 */
#define GTYP_SYSGADGET     &H8000
#define GTYP_SYSTYPEMASK   &H00F0

/* These definitions describe system gadgets in V36 and higher: */
#define GTYP_SIZING     &H0010   /* Window sizing gadget */
#define GTYP_WDRAGGING     &H0020   /* Window drag bar */
#define GTYP_SDRAGGING     &H0030   /* Screen drag bar */
#define GTYP_WDEPTH     &H0040   /* Window depth gadget */
#define GTYP_SDEPTH     &H0050   /* Screen depth gadget */
#define GTYP_WZOOM      &H0060   /* Window zoom gadget */
#define GTYP_SUNUSED    &H0070   /* Unused screen gadget */
#define GTYP_CLOSE      &H0080   /* Window close gadget */

/* These definitions describe system gadgets prior to V36: */
#define GTYP_WUPFRONT      GTYP_WDEPTH /* Window to-front gadget */
#define GTYP_SUPFRONT      GTYP_SDEPTH /* Screen to-front gadget */
#define GTYP_WDOWNBACK     GTYP_WZOOM  /* Window to-back gadget */
#define GTYP_SDOWNBACK     GTYP_SUNUSED   /* Screen to-back gadget */

/* GTYP_GTYPEMASK is a mask you can apply to tell what class
 * of gadget this is.  The possible classes follow.
 */
#define GTYP_GTYPEMASK     &H0007

#define GTYP_BOOLGADGET    &H0001
#define GTYP_GADGET0002    &H0002
#define GTYP_PROPGADGET    &H0003
#define GTYP_STRGADGET     &H0004
#define GTYP_CUSTOMGADGET  &H0005

/* This bit in GadgetType is reserved for undocumented internal use
 * by the Gadget Toolkit,  and cannot be used nor relied on by
 * applications:  &H0100
 */

/* New for V39.  Gadgets which have the GFLG_EXTENDED flag set are
 * actually ExtGadgets,  which have more flags.  The GMORE_xxx
 * identifiers describe those flags.  For GMORE_SCROLLRASTER,  see
 * important information in the ScrollWindowRaster() autodoc.
 * NB: GMORE_SCROLLRASTER must be set before the gadget is
 * added to a window.
 */
#define GMORE_BOUNDS    &H00000001 /* ExtGadget has valid Bounds */
#define GMORE_GADGETHELP   &H00000002 /* This gadget responds to gadget help */
#define GMORE_SCROLLRASTER &H00000004 /* This (custom) gadget uses ScrollRaster */


/* ======================================================================== */
/* === BoolInfo======================================================= */
/* ======================================================================== */
/* This is the special data needed by an Extended Boolean Gadget
 * Typically this structure will be pointed to by the Gadget field SpecialInfo
 */
STRUCT BoolInfo
 
    SHORTINT  Flags  /* defined below */
    ADDRESS   Mask  /* bit mask for highlighting and selecting
          * mask must follow the same rules as an Image
          * plane.  Its width and height are determined
          * by the width and height of the gadget's
          * select box. (i.e. Gadget.Width and .Height).
          */
    LONGINT  Reserved  /* set to 0 */
END STRUCT 

/* set BoolInfo.Flags to this flag bit.
 * in the future,  additional bits might mean more stuff hanging
 * off of BoolInfo.Reserved.
 */
#define BOOLMASK  &H0001   /* extension is for masked gadget */

/* ======================================================================== */
/* === PropInfo =========================================================== */
/* ======================================================================== */
/* this is the special data required by the proportional Gadget
 * typically,  this data will be pointed to by the Gadget variable SpecialInfo
 */
STRUCT PropInfo
 
    SHORTINT Flags   /* general purpose flag bits (see defines below) */

    /* You initialize the Pot variables before the Gadget is added to
     * the system.  Then you can look here for the current settings
     * any time,  even while User is playing with this Gadget.  To
     * adjust these after the Gadget is added to the System,  use
     * ModifyProp()   The Pots are the actual proportional settings, 
     * where a value of zero means zero and a value of MAXPOT means
     * that the Gadget is set to its maximum setting.
     */
    SHORTINT HorizPot   /* 16-bit FixedPoint horizontal quantity percentage */
    SHORTINT VertPot    /* 16-bit FixedPoint vertical quantity percentage */

    /* the 16-bit FixedPoint Body variables describe what percentage of
     * the entire body of stuff referred to by this Gadget is actually
     * shown at one time.  This is used with the AUTOKNOB routines, 
     * to adjust the size of the AUTOKNOB according to how much of
     * the data can be seen.  This is also used to decide how far
     * to advance the Pots when User hits the Container of the Gadget.
     * For instance,  if you were controlling the display of a 5-line
     * Window of text with this Gadget,  and there was a total of 15
     * lines that could be displayed,  you would set the VertBody value to
     *      (MAXBODY / (TotalLines / DisplayLines)) = MAXBODY / 3.
     * Therefore,  the AUTOKNOB would fill 1/3 of the container,  and
     * if User hits the Cotainer outside of the knob,  the pot would
     * advance 1/3 (plus or minus) If there's no body to show,  or
     * the total amount of displayable info is less than the display area, 
     * set the Body variables to the MAX.  To adjust these after the
     * Gadget is added to the System,  use ModifyProp() 
     */
    SHORTINT HorizBody     /* horizontal Body */
    SHORTINT VertBody      /* vertical Body */

    /* these are the variables that Intuition sets and maintains */
    SHORTINT CWidth  /* Container width (with any relativity absoluted) */
    SHORTINT CHeight    /* Container height (with any relativity absoluted) */
    SHORTINT HPotRes 
    SHORTINT   VPotRes    /* pot increments */
    SHORTINT LeftBorder       /* Container borders */
    SHORTINT TopBorder     /* Container borders */
END STRUCT 


/* --- FLAG BITS ---------------------------------------------------------- */
#define AUTOKNOB  &H0001   /* this flag sez:  gimme that old auto-knob */
/* NOTE: if you do not use an AUTOKNOB for a proportional gadget, 
 * you are currently limited to using a single Image of your own
 * design: Intuition won't handle a linked list of images as
 * a proportional gadget knob.
 */

#define FREEHORIZ &H0002   /* if set,  the knob can move horizontally */
#define FREEVERT  &H0004   /* if set,  the knob can move vertically */
#define PROPBORDERLESS  &H0008   /* if set,  no border will be rendered */
#define KNOBHIT      &H0100   /* set when this Knob is hit */
#define PROPNEWLOOK  &H0010   /* set this if you want to get the new
             * V36 look
             */

#define KNOBHMIN  6  /* minimum horizontal size of the Knob */
#define KNOBVMIN  4  /* minimum vertical size of the Knob */
#define MAXBODY      &HFFFF   /* maximum body value */
#define MAXPOT       &HFFFF   /* maximum pot value */


/* ======================================================================== */
/* === StringInfo ========================================================= */
/* ======================================================================== */
/* this is the special data required by the string Gadget
 * typically,  this data will be pointed to by the Gadget variable SpecialInfo
 */
STRUCT StringInfo
 
    /* you initialize these variables,  and then Intuition maintains them */
    ADDRESS   Buffer    /* the buffer containing the start and final string */
    ADDRESS   UndoBuffer   /* optional buffer for undoing current entry */
    SHORTINT BufferPos   /* character position in Buffer */
    SHORTINT MaxChars    /* max number of chars in Buffer (including NULL) */
    SHORTINT DispPos  /* Buffer position of first displayed character */

    /* Intuition initializes and maintains these variables for you */
    SHORTINT UndoPos  /* character position in the undo buffer */
    SHORTINT NumChars    /* number of characters currently in Buffer */
    SHORTINT DispCount   /* number of whole characters visible in Container */
    SHORTINT CLeft 
    SHORTINT   CTop    /* topleft offset of the container */

    /* This unused field is changed to allow extended specification
     * of string gadget parameters.  It is ignored unless the flag
     * GACT_STRINGEXTEND is set in the Gadget's Activation field
     * or the GFLG_STRINGEXTEND flag is set in the Gadget Flags field.
     * (See GFLG_STRINGEXTEND for an important note)
     */
    /* STRUCT Layer *LayerPtr    --- obsolete --- */
    StringExtendPtr  Extension 

    /* you can initialize this variable before the gadget is submitted to
     * Intuition,  and then examine it later to discover what integer
     * the user has entered (if the user never plays with the gadget, 
     * the value will be unchanged from your initial setting)
     */
    LONGINT _LongInt 

    /* If you want this Gadget to use your own Console keymapping,  you
     * set the GACT_ALTKEYMAP bit in the Activation flags of the Gadget, 
     * and then set this variable to point to your keymap.  If you don't
     * set the GACT_ALTKEYMAP,  you'll get the standard ASCII keymapping.
     */
    KeyMapPtr  AltKeyMap 
END STRUCT 

/* ======================================================================== */
/* === IntuiText ========================================================== */
/* ======================================================================== */
/* IntuiText is a series of strings that start with a location
 *  (always relative to the upper-left corner of something) and then the
 *  text of the string.  The text is null-terminated.
 */
STRUCT IntuiText
 
    BYTE  FrontPen 
    BYTE   BackPen   /* the pen numbers for the rendering */
    BYTE  DrawMode      /* the mode for rendering the text */
    BYTE  KludgeFill00
    SHORTINT LeftEdge       /* relative start location for the text */
    SHORTINT TopEdge     /* relative start location for the text */
    TextAttrPtr  ITextFont   /* if NULL,  you accept the default */
    ADDRESS   IText     /* pointer to null-terminated text */
    IntuiTextPtr  NextText  /* pointer to another IntuiText to render */
END STRUCT 






/* ======================================================================== */
/* === Border ============================================================= */
/* ======================================================================== */
/* Data type Border,  used for drawing a series of lines which is intended for
 *  use as a border drawing,  but which may,  in fact,  be used to render any
 *  arbitrary vector shape.
 *  The routine DrawBorder sets up the RastPort with the appropriate
 *  variables,  then does a Move to the first coordinate,  then does Draws
 *  to the subsequent coordinates.
 *  After all the Draws are done,  if NextBorder is non-zero we call DrawBorder
 *  on NextBorder
 */
STRUCT Border
 
    SHORTINT LeftEdge 
    SHORTINT   TopEdge    /* initial offsets from the origin */
    BYTE  FrontPen 
    BYTE   BackPen   /* pens numbers for rendering */
    BYTE  DrawMode      /* mode for rendering */
    BYTE Count          /* number of XY pairs */
    ADDRESS   XY         /* vector coordinate pairs rel to LeftTop */
    BorderPtr  NextBorder    /* pointer to any other Border too */
END STRUCT 






/* ======================================================================== */
/* === Image ============================================================== */
/* ======================================================================== */
/* This is a brief image structure for very simple transfers of
 * image data to a RastPort
 */
STRUCT Image
 
    SHORTINT LeftEdge       /* starting offset relative to some origin */
    SHORTINT TopEdge     /* starting offsets relative to some origin */
    SHORTINT _Width          /* pixel size (though data is SHORTINT-aligned) */
    SHORTINT Height 
    SHORTINT Depth          /* >= 0,  for images you create      */
    ADDRESS   ImageData       /* pointer to the actual SHORTINT-aligned bits */

    /* the PlanePick and PlaneOnOff variables work much the same way as the
     * equivalent GELS Bob variables.  It's a space-saving
     * mechanism for image data.  Rather than defining the image data
     * for every plane of the RastPort,  you need define data only
     * for the planes that are not entirely zero or one.  As you
     * define your Imagery,  you will often find that most of the planes
     * ARE just as color selectors.  For instance,  if you're designing
     * a two-color Gadget to use colors one and three,  and the Gadget
     * will reside in a five-plane display,  bit plane zero of your
     * imagery would be all ones,  bit plane one would have data that
     * describes the imagery,  and bit planes two through four would be
     * all zeroes.  Using these flags avoids wasting all
     * that memory in this way:  first,  you specify which planes you
     * want your data to appear in using the PlanePick variable.  For
     * each bit set in the variable,  the next "plane" of your image
     * data is blitted to the display. For each bit clear in this
     * variable,  the corresponding bit in PlaneOnOff is examined.
     * If that bit is clear,  a "plane" of zeroes will be used.
     * If the bit is set,  ones will go out instead.  So,  for our example:
     *    Gadget.PlanePick = &H02 
     *    Gadget.PlaneOnOff = &H01 
     * Note that this also allows for generic Gadgets,  like the
     * System Gadgets,  which will work in any number of bit planes.
     * Note also that if you want an Image that is only a filled
     * rectangle,  you can get this by setting PlanePick to zero
     * (pick no planes of data) and set PlaneOnOff to describe the pen
     * color of the rectangle.
     *
     * NOTE:  Intuition relies on PlanePick to know how many planes
     * of data are found in ImageData. There should be no more
     * '1'-bits in PlanePick than there are planes in ImageData.
     */
    BYTE  PlanePick 
    BYTE   PlaneOnOff 

    /* if the NextImage variable is not NULL,  Intuition presumes that
     * it points to another Image structure with another Image to be
     * rendered
     */
    ImagePtr  NextImage 
END STRUCT 






/* ======================================================================== */
/* === IntuiMessage ======================================================= */
/* ======================================================================== */
STRUCT IntuiMessage
 
    _Message ExecMessage 

    /* the Class bits correspond directly with the IDCMP Flags,  except for the
     * special bit IDCMP_LONELYMESSAGE (defined below)
     */
    LONGINT Class 

    /* the Code field is for special values like MENU number */
    SHORTINT Code 

    /* the Qualifier field is a copy of the current InputEvent's Qualifier */
    SHORTINT Qualifier 

    /* IAddress contains particular addresses for Intuition functions,  like
     * the pointer to the Gadget or the Screen
     */
    ADDRESS IAddress 

    /* when getting mouse movement reports,  any event you get will have the
     * the mouse coordinates in these variables.  the coordinates are relative
     * to the upper-left corner of your Window (WFLG_GIMMEZEROZERO
     * notwithstanding).  If IDCMP_DELTAMOVE is set,  these values will
     * be deltas from the last reported position.
     */
    SHORTINT MouseX 
    SHORTINT   MouseY 

    /* the time values are copies of the current system clock time.  Micros
     * are in units of microseconds,  Seconds in seconds.
     */
    LONGINT Seconds 
    LONGINT   Micros 

    /* the IDCMPWindow variable will always have the address of the Window of
     * this IDCMP
     */
    WindowPtr  IDCMPWindow 

    /* system-use variable */
    IntuiMessagePtr  SpecialLink 
END STRUCT 

/* New for V39:
 * All IntuiMessages are now slightly extended.  The ExtIntuiMessage
 * structure has an additional field for tablet data,  which is usually
 * NULL.  If a tablet driver which is sending IESUBCLASS_NEWTABLET
 * events is installed in the system,  windows with the WA_TabletMessages
 * property set will find that eim_TabletData points to the TabletData
 * structure.  Applications must first check that this field is non-NULL 
 * it will be NULL for certain kinds of message,  including mouse activity
 * generated from other than the tablet (i.e. the keyboard equivalents
 * or the mouse itself).
 *
 * NEVER EVER examine any extended fields when running under pre-V39!
 *
 * NOTE: This structure is subject to grow in the future.  Making
 * assumptions about its size is A BAD IDEA.
 */

STRUCT ExtIntuiMessage
 
    IntuiMessage eim_IntuiMessage 
    TabletDataPtr  eim_TabletData 
END STRUCT 

/* --- IDCMP Classes ------------------------------------------------------ */
/* Please refer to the Autodoc for OpenWindow() and to the Rom Kernel
 * Manual for full details on the IDCMP classes.
 */
#define IDCMP_SIZEVERIFY   &H00000001
#define IDCMP_NEWSIZE      &H00000002
#define IDCMP_REFRESHWINDOW   &H00000004
#define IDCMP_MOUSEBUTTONS &H00000008
#define IDCMP_MOUSEMOVE    &H00000010
#define IDCMP_GADGETDOWN   &H00000020
#define IDCMP_GADGETUP     &H00000040
#define IDCMP_REQSET    &H00000080
#define IDCMP_MENUPICK     &H00000100
#define IDCMP_CLOSEWINDOW  &H00000200
#define IDCMP_RAWKEY    &H00000400
#define IDCMP_REQVERIFY    &H00000800
#define IDCMP_REQCLEAR     &H00001000
#define IDCMP_MENUVERIFY   &H00002000
#define IDCMP_NEWPREFS     &H00004000
#define IDCMP_DISKINSERTED &H00008000
#define IDCMP_DISKREMOVED  &H00010000
#define IDCMP_WBENCHMESSAGE   &H00020000  /* System use only      */
#define IDCMP_ACTIVEWINDOW &H00040000
#define IDCMP_INACTIVEWINDOW  &H00080000
#define IDCMP_DELTAMOVE    &H00100000
#define IDCMP_VANILLAKEY   &H00200000
#define IDCMP_INTUITICKS   &H00400000
/*  for notifications from "boopsi" gadgets  */
#define IDCMP_IDCMPUPDATE  &H00800000  /* new for V36 */
/* for getting help key report during menu session */
#define IDCMP_MENUHELP     &H01000000  /* new for V36 */
/* for notification of any move/size/zoom/change window     */
#define IDCMP_CHANGEWINDOW &H02000000  /* new for V36 */
#define IDCMP_GADGETHELP   &H04000000  /* new for V39 */

/* NOTEZ-BIEN:          &H80000000 is reserved for internal use   */

/* the IDCMP Flags do not use this special bit,  which is cleared when
 * Intuition sends its special message to the Task,  and set when Intuition
 * gets its Message back from the Task.  Therefore,  I can check here to
 * find out fast whether or not this Message is available for me to send
 */
#define IDCMP_LONELYMESSAGE   &H80000000


/* --- IDCMP Codes -------------------------------------------------------- */
/* This group of codes is for the IDCMP_CHANGEWINDOW message */
#define CWCODE_MOVESIZE &H0000   /* Window was moved and/or sized */
#define CWCODE_DEPTH &H0001   /* Window was depth-arranged (new for V39) */

/* This group of codes is for the IDCMP_MENUVERIFY message */
#define MENUHOT      &H0001   /* IntuiWants verification or MENUCANCEL    */
#define MENUCANCEL   &H0002   /* HOT Reply of this cancels Menu operation */
#define MENUWAITING  &H0003   /* Intuition simply wants a ReplyMsg() ASAP */

/* These are internal tokens to represent state of verification attempts
 * shown here as a clue.
 */
#define OKOK      MENUHOT  /* guy didn't care         */
#define OKABORT      &H0004   /* window rendered question moot */
#define OKCANCEL  MENUCANCEL /* window sent cancel reply    */

/* This group of codes is for the IDCMP_WBENCHMESSAGE messages */
#define WBENCHOPEN   &H0001
#define WBENCHCLOSE  &H0002


/* A data structure common in V36 Intuition processing   */
STRUCT IBox
 
    SHORTINT Left 
    SHORTINT Top 
    SHORTINT _Width 
    SHORTINT Height 
END STRUCT 



/* ======================================================================== */
/* === Window ============================================================= */
/* ======================================================================== */
STRUCT _Window
 
    WindowPtr  NextWindow       /* for the linked list in a screen */

    SHORTINT LeftEdge 
    SHORTINT   TopEdge       /* screen dimensions of window */
    SHORTINT _Width 
    SHORTINT   Height        /* screen dimensions of window */

    SHORTINT MouseY 
    SHORTINT   MouseX       /* relative to upper-left of window */

    SHORTINT MinWidth 
    SHORTINT   MinHeight     /* minimum sizes */
    SHORTINT MaxWidth 
    SHORTINT   MaxHeight       /* maximum sizes */

    LONGINT Flags         /* see below for defines */

    MenuPtr  MenuStrip       /* the strip of Menu headers */

    ADDRESS   Title        /* the title text for this window */

    RequesterPtr  FirstRequest  /* all active Requesters */

    RequesterPtr  DMRequest  /* double-click Requester */

    SHORTINT ReqCount          /* count of reqs blocking Window */

    ScreenPtr  WScreen       /* this Window's Screen */
    RastPortPtr  RPort       /* this Window's very own RastPort */

    /* the border variables describe the window border.  If you specify
     * WFLG_GIMMEZEROZERO when you open the window,  then the upper-left of
     * the ClipRect for this window will be upper-left of the BitMap (with
     * correct offsets when in SuperBitMap mode  you MUST select
     * WFLG_GIMMEZEROZERO when using SuperBitMap).  If you don't specify
     * ZeroZero,  then you save memory (no allocation of RastPort,  Layer, 
     * ClipRect and associated Bitmaps),  but you also must offset all your
     * writes by BorderTop,  BorderLeft and do your own mini-clipping to
     * prevent writing over the system gadgets
     */
    BYTE BorderLeft 
    BYTE   BorderTop 
    BYTE   BorderRight 
    BYTE   BorderBottom 
    RastPortPtr  BorderRPort 


    /* You supply a linked-list of Gadgets for your Window.
     * This list DOES NOT include system gadgets.  You get the standard
     * window system gadgets by setting flag-bits in the variable Flags (see
     * the bit definitions below)
     */
    GadgetPtr  FirstGadget 

    /* these are for opening/closing the windows */
    WindowPtr  Parent 
    WindowPtr  Descendant 

    /* sprite data information for your own Pointer
     * set these AFTER you Open the Window by calling SetPointer()
     */
    ADDRESS   Pointer   /* sprite data */
    BYTE PtrHeight   /* sprite height (not including sprite padding) */
    BYTE PtrWidth    /* sprite width (must be less than or equal to 16) */
    BYTE XOffset 
    BYTE   YOffset  /* sprite offsets */

    /* the IDCMP Flags and User's and Intuition's Message Ports */
    LONGINT IDCMPFlags    /* User-selected flags */
    MsgPortPtr  UserPort 
    MsgPortPtr  WindowPort 
    IntuiMessagePtr  MessageKey 

    BYTE  DetailPen 
    BYTE   BlockPen    /* for bar/border/gadget rendering */

    /* the CheckMark is a pointer to the imagery that will be used when
     * rendering MenuItems of this Window that want to be checkmarked
     * if this is equal to NULL,  you'll get the default imagery
     */
    ImagePtr  CheckMark 

    ADDRESS   ScreenTitle  /* if non-null,  Screen title when Window is active */

    /* These variables have the mouse coordinates relative to the
     * inner-Window of WFLG_GIMMEZEROZERO Windows.  This is compared with the
     * MouseX and MouseY variables,  which contain the mouse coordinates
     * relative to the upper-left corner of the Window,  WFLG_GIMMEZEROZERO
     * notwithstanding
     */
    SHORTINT GZZMouseX 
    SHORTINT GZZMouseY 
    /* these variables contain the width and height of the inner-Window of
     * WFLG_GIMMEZEROZERO Windows
     */
    SHORTINT GZZWidth 
    SHORTINT GZZHeight 

    ADDRESS   ExtData 

    ADDRESS   UserData   /* general-purpose pointer to User data extension */

    /** 11/18/85: this pointer keeps a duplicate of what
     * Window.RPort->Layer is _supposed_ to be pointing at
     */
    LayerPtr  WLayer 

    /* NEW 1.2: need to keep track of the font that
     * OpenWindow opened,  in case user SetFont's into RastPort
     */
    TextFontPtr  IFont 

    /* (V36) another flag SHORTINT (the Flags field is used up).
     * At present,  all flag values are system private.
     * Until further notice,  you may not change nor use this field.
     */
    LONGINT   MoreFlags 

    /**** Data beyond this point are Intuition Private.  DO NOT USE ****/
END STRUCT 


/* --- Flags requested at OpenWindow() time by the application --------- */
#define WFLG_SIZEGADGET     &H00000001 /* include sizing system-gadget? */
#define WFLG_DRAGBAR     &H00000002 /* include dragging system-gadget? */
#define WFLG_DEPTHGADGET    &H00000004 /* include depth arrangement gadget? */
#define WFLG_CLOSEGADGET    &H00000008 /* include close-box system-gadget? */

#define WFLG_SIZEBRIGHT     &H00000010 /* size gadget uses right border */
#define WFLG_SIZEBBOTTOM    &H00000020 /* size gadget uses bottom border */

/* --- refresh modes ------------------------------------------------------ */
/* combinations of the WFLG_REFRESHBITS select the refresh type */
#define WFLG_REFRESHBITS    &H000000C0
#define WFLG_SMART_REFRESH  &H00000000
#define WFLG_SIMPLE_REFRESH &H00000040
#define WFLG_SUPER_BITMAP   &H00000080
#define WFLG_OTHER_REFRESH  &H000000C0

#define WFLG_BACKDROP       &H00000100 /* this is a backdrop window */

#define WFLG_REPORTMOUSE    &H00000200 /* to hear about every mouse move */

#define WFLG_GIMMEZEROZERO  &H00000400 /* a GimmeZeroZero window  */

#define WFLG_BORDERLESS     &H00000800 /* to get a Window sans border */

#define WFLG_ACTIVATE       &H00001000 /* when Window opens,  it's Active */

/* --- Other User Flags --------------------------------------------------- */
#define WFLG_RMBTRAP     &H00010000 /* Catch RMB events for your own */
#define WFLG_NOCAREREFRESH  &H00020000 /* not to be bothered with REFRESH */

/* - V36 new Flags which the programmer may specify in NewWindow.Flags  */
#define WFLG_NW_EXTENDED    &H00040000 /* extension data provided */
               /* see STRUCT ExtNewWindow */

/* - V39 new Flags which the programmer may specify in NewWindow.Flags  */
#define WFLG_NEWLOOKMENUS   &H00200000 /* window has NewLook menus   */


/* These flags are set only by Intuition.  YOU MAY NOT SET THEM YOURSELF! */
#define WFLG_WINDOWACTIVE   &H00002000 /* this window is the active one */
#define WFLG_INREQUEST      &H00004000 /* this window is in request mode */
#define WFLG_MENUSTATE      &H00008000 /* Window is active with Menus on */
#define WFLG_WINDOWREFRESH  &H01000000 /* Window is currently refreshing */
#define WFLG_WBENCHWINDOW   &H02000000 /* WorkBench tool ONLY Window */
#define WFLG_WINDOWTICKED   &H04000000 /* only one timer tick at a time */

/* V36 and higher flags to be set only by Intuition: */
#define WFLG_VISITOR     &H08000000 /* visitor window    */
#define WFLG_ZOOMED      &H10000000 /* identifies "zoom state" */
#define WFLG_HASZOOM     &H20000000 /* window has a zoom gadget   */


/* --- Other Window Values ---------------------------------------------- */
#define DEFAULTMOUSEQUEUE  (5)   /* no more mouse messages  */

/* --- see STRUCT IntuiMessage for the IDCMP Flag definitions ------------- */


/* ======================================================================== */
/* === NewWindow ========================================================== */
/* ======================================================================== */
/*
 * Note that the new extension fields have been removed.  Use ExtNewWindow
 * structure below to make use of these fields
 */
STRUCT NewWindow
 
    SHORTINT LeftEdge 
    SHORTINT   TopEdge       /* screen dimensions of window */
    SHORTINT _Width 
    SHORTINT   Height        /* screen dimensions of window */

    BYTE  DetailPen 
    BYTE   BlockPen       /* for bar/border/gadget rendering */

    LONGINT IDCMPFlags          /* User-selected IDCMP flags */

    LONGINT Flags         /* see Window STRUCT for defines */

    /* You supply a linked-list of Gadgets for your Window.
     *   This list DOES NOT include system Gadgets.  You get the standard
     *   system Window Gadgets by setting flag-bits in the variable Flags (see
     *   the bit definitions under the Window structure definition)
     */
    GadgetPtr  FirstGadget 

    /* the CheckMark is a pointer to the imagery that will be used when
     * rendering MenuItems of this Window that want to be checkmarked
     * if this is equal to NULL,  you'll get the default imagery
     */
    ImagePtr  CheckMark 

    ADDRESS   Title          /* the title text for this window */

    /* the Screen pointer is used only if you've defined a CUSTOMSCREEN and
     * want this Window to open in it. If so,  you pass the address of the
     * Custom Screen structure in this variable.  Otherwise,  this variable
     * is ignored and doesn't have to be initialized.
     */
    ScreenPtr  _Screen 

    /* WFLG_SUPER_BITMAP Window?  If so,  put the address of your BitMap
     * structure in this variable.  If not,  this variable is ignored and
     * doesn't have to be initialized
     */
    BitMapPtr  BitMap 

    /* the values describe the minimum and maximum sizes of your Windows.
     * these matter only if you've chosen the WFLG_SIZEGADGET option, 
     * which means that you want to let the User to change the size of
     * this Window.  You describe the minimum and maximum sizes that the
     * Window can grow by setting these variables.  You can initialize
     * any one these to zero,  which will mean that you want to duplicate
     * the setting for that dimension (if MinWidth == 0,  MinWidth will be
     * set to the opening Width of the Window).
     * You can change these settings later using SetWindowLimits().
     * If you haven't asked for a SIZING Gadget,  you don't have to
     * initialize any of these variables.
     */
    SHORTINT MinWidth 
    SHORTINT   MinHeight      /* minimums */
    SHORTINT MaxWidth 
    SHORTINT   MaxHeight         /* maximums */

    /* the type variable describes the Screen in which you want this Window to
     * open.  The type value can either be CUSTOMSCREEN or one of the
     * system standard Screen Types such as WBENCHSCREEN.  See the
     * type definitions under the Screen structure.
     */
    SHORTINT _Type 

END STRUCT 

/* The following structure is the future NewWindow.  Compatibility
 * issues require that the size of NewWindow not change.
 * Data in the common part (NewWindow) indicates the the extension
 * fields are being used.
 * NOTE WELL: This structure may be subject to future extension.
 * Writing code depending on its size is not allowed.
 */
STRUCT ExtNewWindow
 
    SHORTINT LeftEdge 
    SHORTINT   TopEdge 
    SHORTINT _Width 
    SHORTINT   Height 

    BYTE  DetailPen 
    BYTE   BlockPen 
    LONGINT IDCMPFlags 
    LONGINT Flags 
    GadgetPtr  FirstGadget 

    ImagePtr  CheckMark 

    ADDRESS   Title 
    ScreenPtr  _Screen 
    BitMapPtr  BitMap 

    SHORTINT MinWidth 
    SHORTINT   MinHeight 
    SHORTINT MaxWidth 
    SHORTINT   MaxHeight 

    /* the type variable describes the Screen in which you want this Window to
     * open.  The type value can either be CUSTOMSCREEN or one of the
     * system standard Screen Types such as WBENCHSCREEN.  See the
     * type definitions under the Screen structure.
     * A new possible value for this field is PUBLICSCREEN,  which
     * defines the window as a 'visitor' window.  See below for
     * additional information provided.
     */
    SHORTINT _Type 

    /* ------------------------------------------------------- *
     * extensions for V36
     * if the NewWindow Flag value WFLG_NW_EXTENDED is set,  then
     * this field is assumed to point to an array ( or chain of arrays)
     * of TagItem structures.  See also ExtNewScreen for another
     * use of TagItems to pass optional data.
     *
     * see below for tag values and the corresponding data.
     */
    TagItemPtr  Extension 
END STRUCT 

/*
 * The TagItem ID's (ti_Tag values) for OpenWindowTagList() follow.
 * They are values in a TagItem array passed as extension/replacement
 * values for the data in NewWindow.  OpenWindowTagList() can actually
 * work well with a NULL NewWindow pointer.
 */

#define WA_Dummy  (TAG_USER + 99)   /* &H80000063  */

/* these tags simply override NewWindow parameters */
#define WA_Left         (WA_Dummy + &H01)
#define WA_Top       (WA_Dummy + &H02)
#define WA_Width     (WA_Dummy + &H03)
#define WA_Height    (WA_Dummy + &H04)
#define WA_DetailPen    (WA_Dummy + &H05)
#define WA_BlockPen     (WA_Dummy + &H06)
#define WA_IDCMP     (WA_Dummy + &H07)
         /* "bulk" initialization of NewWindow.Flags */
#define WA_Flags     (WA_Dummy + &H08)
#define WA_Gadgets      (WA_Dummy + &H09)
#define WA_Checkmark    (WA_Dummy + &H0A)
#define WA_Title     (WA_Dummy + &H0B)
         /* means you don't have to call SetWindowTitles
          * after you open your window
          */
#define WA_ScreenTitle     (WA_Dummy + &H0C)
#define WA_CustomScreen    (WA_Dummy + &H0D)
#define WA_SuperBitMap     (WA_Dummy + &H0E)
         /* also implies WFLG_SUPER_BITMAP property   */
#define WA_MinWidth     (WA_Dummy + &H0F)
#define WA_MinHeight    (WA_Dummy + &H10)
#define WA_MaxWidth     (WA_Dummy + &H11)
#define WA_MaxHeight    (WA_Dummy + &H12)

/* The following are specifications for new features  */

#define WA_InnerWidth      (WA_Dummy + &H13)
#define WA_InnerHeight     (WA_Dummy + &H14)
         /* You can specify the dimensions of the interior
          * region of your window,  independent of what
          * the border widths will be.  You probably want
          * to also specify WA_AutoAdjust to allow
          * Intuition to move your window or even
          * shrink it so that it is completely on screen.
          */

#define WA_PubScreenName   (WA_Dummy + &H15)
         /* declares that you want the window to open as
          * a visitor on the public screen whose name is
          * pointed to by (BYTE  *) ti_Data
          */
#define WA_PubScreen    (WA_Dummy + &H16)
         /* open as a visitor window on the public screen
          * whose address is in (STRUCT Screen *) ti_Data.
          * To ensure that this screen remains open,  you
          * should either be the screen's owner,  have a
          * window open on the screen,  or use LockPubScreen().
          */
#define WA_PubScreenFallBack  (WA_Dummy + &H17)
         /* A Boolean,  specifies whether a visitor window
          * should "fall back" to the default public screen
          * (or Workbench) if the named public screen isn't
          * available
          */
#define WA_WindowName      (WA_Dummy + &H18)
         /* not implemented   */
#define WA_Colors    (WA_Dummy + &H19)
         /* a ColorSpec array for colors to be set
          * when this window is active.   This is not
          * implemented,  and may not be,  since the default
          * values to restore would be hard to track.
          * We'd like to at least support per-window colors
          * for the mouse pointer sprite.
          */
#define WA_Zoom      (WA_Dummy + &H1A)
         /* ti_Data points to an array of four WORD's, 
          * the initial Left/Top/Width/Height values of
          * the "alternate" zoom position/dimensions.
          * It also specifies that you want a Zoom gadget
          * for your window,  whether or not you have a
          * sizing gadget.
          */
#define WA_MouseQueue      (WA_Dummy + &H1B)
         /* ti_Data contains initial value for the mouse
          * message backlog limit for this window.
          */
#define WA_BackFill     (WA_Dummy + &H1C)
         /* provides a "backfill hook" for your window's Layer.
          * See layers.library/CreateUpfrontHookLayer().
          */
#define WA_RptQueue     (WA_Dummy + &H1D)
         /* initial value of repeat key backlog limit */

    /* These Boolean tag items are alternatives to the NewWindow.Flags
     * boolean flags with similar names.
     */
#define WA_SizeGadget      (WA_Dummy + &H1E)
#define WA_DragBar      (WA_Dummy + &H1F)
#define WA_DepthGadget     (WA_Dummy + &H20)
#define WA_CloseGadget     (WA_Dummy + &H21)
#define WA_Backdrop     (WA_Dummy + &H22)
#define WA_ReportMouse     (WA_Dummy + &H23)
#define WA_NoCareRefresh   (WA_Dummy + &H24)
#define WA_Borderless      (WA_Dummy + &H25)
#define WA_Activate     (WA_Dummy + &H26)
#define WA_RMBTrap      (WA_Dummy + &H27)
#define WA_WBenchWindow    (WA_Dummy + &H28) /* PRIVATE!! */
#define WA_SimpleRefresh   (WA_Dummy + &H29)
         /* only specify if TRUE */
#define WA_SmartRefresh    (WA_Dummy + &H2A)
         /* only specify if TRUE */
#define WA_SizeBRight      (WA_Dummy + &H2B)
#define WA_SizeBBottom     (WA_Dummy + &H2C)

    /* New Boolean properties */
#define WA_AutoAdjust      (WA_Dummy + &H2D)
         /* shift or squeeze the window's position and
          * dimensions to fit it on screen.
          */

#define WA_GimmeZeroZero   (WA_Dummy + &H2E)
         /* equiv. to NewWindow.Flags WFLG_GIMMEZEROZERO */

/* New for V37: WA_MenuHelp (ignored by V36) */
#define WA_MenuHelp     (WA_Dummy + &H2F)
         /* Enables IDCMP_MENUHELP:  Pressing HELP during menus
          * will return IDCMP_MENUHELP message.
          */

/* New for V39:  (ignored by V37 and earlier) */
#define WA_NewLookMenus    (WA_Dummy + &H30)
         /* Set to TRUE if you want NewLook menus */
#define WA_AmigaKey     (WA_Dummy + &H31)
         /* Pointer to image for Amiga-key equiv in menus */
#define WA_NotifyDepth     (WA_Dummy + &H32)
         /* Requests IDCMP_CHANGEWINDOW message when
          * window is depth arranged
          * (imsg->Code = CWCODE_DEPTH)
          */

/* WA_Dummy + &H33 is obsolete */

#define WA_Pointer      (WA_Dummy + &H34)
         /* Allows you to specify a custom pointer
          * for your window.  ti_Data points to a
          * pointer object you obtained via
          * "pointerclass". NULL signifies the
          * default pointer.
          * This tag may be passed to OpenWindowTags()
          * or SetWindowPointer().
          */

#define WA_BusyPointer     (WA_Dummy + &H35)
         /* ti_Data is boolean.  Set to TRUE to
          * request the standard busy pointer.
          * This tag may be passed to OpenWindowTags()
          * or SetWindowPointer().
          */

#define WA_PointerDelay    (WA_Dummy + &H36)
         /* ti_Data is boolean.  Set to TRUE to
          * request that the changing of the
          * pointer be slightly delayed.  The change
          * will be called off if you call NewSetPointer()
          * before the delay expires.  This allows
          * you to post a busy-pointer even if you think
          * the busy-time may be very SHORTINT,  without
          * fear of a flashing pointer.
          * This tag may be passed to OpenWindowTags()
          * or SetWindowPointer().
          */

#define WA_TabletMessages  (WA_Dummy + &H37)
         /* ti_Data is a boolean.  Set to TRUE to
          * request that tablet information be included
          * in IntuiMessages sent to your window.
          * Requires that something (i.e. a tablet driver)
          * feed IESUBCLASS_NEWTABLET InputEvents into
          * the system. For a pointer to the TabletData, 
          * examine the ExtIntuiMessage->eim_TabletData
          * field.  It is UNSAFE to check this field
          * when running on pre-V39 systems.  It's always
          * safe to check this field under V39 and up, 
          * though it may be NULL.
          */

#define WA_HelpGroup    (WA_Dummy + &H38)
         /* When the active window has gadget help enabled, 
          * other windows of the same HelpGroup number
          * will also get GadgetHelp.  This allows GadgetHelp
          * to work for multi-windowed applications.
          * Use GetGroupID() to get an ID number.  Pass
          * this number as ti_Data to all your windows.
          * See also the HelpControl() function.
          */

#define WA_HelpGroupWindow (WA_Dummy + &H39)
         /* When the active window has gadget help enabled, 
          * other windows of the same HelpGroup will also get
          * GadgetHelp. This allows GadgetHelp to work
          * for multi-windowed applications.  As an alternative
          * to WA_HelpGroup,  you can pass a pointer to any
          * other window of the same group to join its help
          * group.  Defaults to NULL,  which has no effect.
          * See also the HelpControl() function.
          */


/* HelpControl() flags:
 *
 * HC_GADGETHELP - Set this flag to enable Gadget-Help for one or more
 * windows.
 */

#define HC_GADGETHELP   (1)


#ifndef INTUITION_SCREENS_H
#include <intuition/screens.h>
#endif

#ifndef INTUITION_PREFERENCES_H
#include <intuition/preferences.h>
#endif

/* ======================================================================== */
/* === Remember =========================================================== */
/* ======================================================================== */
/* this structure is used for remembering what memory has been allocated to
 * date by a given routine,  so that a premature abort or systematic exit
 * can deallocate memory cleanly,  easily,  and completely
 */
STRUCT Remember
 
    RememberPtr  NextRemember 
    LONGINT RememberSize 
    ADDRESS   Memory 
END STRUCT 


/* === Color Spec ====================================================== */
/* How to tell Intuition about RGB values for a color table entry.
 * NOTE:  The way the structure was defined,  the color value was
 * right-justified within each UWORD.  This poses problems for
 * extensibility to more bits-per-gun. The SA_Colors32 tag to
 * OpenScreenTags() provides an alternate way to specify colors
 * with greater precision.
 */
STRUCT ColorSpec
 
    SHORTINT ColorIndex  /* -1 terminates an array of ColorSpec */
    SHORTINT   Red   /* only the _bottom_ 4 bits recognized */
    SHORTINT   Green    /* only the _bottom_ 4 bits recognized */
    SHORTINT   Blue  /* only the _bottom_ 4 bits recognized */
END STRUCT 

/* === Easy Requester Specification ======================================= */
/* see also autodocs for EasyRequest and BuildEasyRequest   */
/* NOTE: This structure may grow in size in the future      */
STRUCT EasyStruct  
    LONGINT   es_StructSize  /* should be sizeof (STRUCT EasyStruct )*/
    LONGINT   es_Flags    /* should be 0 for now        */
    ADDRESS   es_Title   /* title of requester window     */
    ADDRESS   es_TextFormat    /* 'printf' style formatting string */
    ADDRESS   es_GadgetFormat  /* 'printf' style formatting string */
END STRUCT 



/* ======================================================================== */
/* === Miscellaneous ====================================================== */
/* ======================================================================== */


/* = MENU STUFF =========================================================== */
#define NOMENU &H001F
#define NOITEM &H003F
#define NOSUB  &H001F
#define MENUNULL &HFFFF


/* = =RJ='s peculiarities ================================================= */
/*
#define FOREVER for( ;)
#define SIGN(x) ( ((x) > 0) - ((x) < 0) )
#define NOT !
*/

/* these defines are for the COMMSEQ and CHECKIT menu stuff.  If CHECKIT, 
 * I'll use a generic Width (for all resolutions) for the CheckMark.
 * If COMMSEQ,  likewise I'll use this generic stuff
 */
#define CHECKWIDTH   19
#define COMMWIDTH 27
#define LOWCHECKWIDTH   13
#define LOWCOMMWIDTH 16


/* these are the AlertNumber defines.  if you are calling DisplayAlert()
 * the AlertNumber you supply must have the ALERT_TYPE bits set to one
 * of these patterns
 */
#define ALERT_TYPE   &H80000000
#define RECOVERY_ALERT  &H00000000  /* the system can recover from this */
#define DEADEND_ALERT   &H80000000  /* no recovery possible,  this is it */


/* When you're defining IntuiText for the Positive and Negative Gadgets
 * created by a call to AutoRequest(),  these defines will get you
 * reasonable-looking text.  The only field without a define is the IText
 * field  you decide what text goes with the Gadget
 */
#define AUTOFRONTPEN 0
#define AUTOBACKPEN  1
#define AUTODRAWMODE JAM2
#define AUTOLEFTEDGE 6
#define AUTOTOPEDGE  3
#define AUTOITEXTFONT   NULL
#define AUTONEXTTEXT NULL


/* --- RAWMOUSE Codes and Qualifiers (Console OR IDCMP) ------------------- */
#define SELECTUP  (IECODE_LBUTTON OR IECODE_UP_PREFIX)
#define SELECTDOWN   (IECODE_LBUTTON)
#define MENUUP    (IECODE_RBUTTON OR IECODE_UP_PREFIX)
#define MENUDOWN  (IECODE_RBUTTON)
#define MIDDLEUP  (IECODE_MBUTTON OR IECODE_UP_PREFIX)
#define MIDDLEDOWN   (IECODE_MBUTTON)
#define ALTLEFT      (IEQUALIFIER_LALT)
#define ALTRIGHT  (IEQUALIFIER_RALT)
#define AMIGALEFT (IEQUALIFIER_LCOMMAND)
#define AMIGARIGHT   (IEQUALIFIER_RCOMMAND)
#define AMIGAKEYS (AMIGALEFT OR AMIGARIGHT)

#define CURSORUP  &H4C
#define CURSORLEFT   &H4F
#define CURSORRIGHT  &H4E
#define CURSORDOWN   &H4D
#define KEYCODE_Q &H10
#define KEYCODE_Z &H31
#define KEYCODE_X &H32
#define KEYCODE_V &H34
#define KEYCODE_B &H35
#define KEYCODE_N &H36
#define KEYCODE_M &H37
#define KEYCODE_LESS &H38
#define KEYCODE_GREATER &H39



/* New for V39,  Intuition supports the IESUBCLASS_NEWTABLET subclass
 * of the IECLASS_NEWPOINTERPOS event. The ie_EventAddress of such
 * an event points to a TabletData structure (see below).
 *
 * The TabletData structure contains certain elements including a taglist.
 * The taglist can be used for special tablet parameters.  A tablet driver
 * should include only those tag-items the tablet supports.  An application
 * can listen for any tag-items that interest it.  Note: an application
 * must set the WA_TabletMessages attribute to TRUE to receive this
 * extended information in its IntuiMessages.
 *
 * The definitions given here MUST be followed.  Pay careful attention
 * to normalization and the interpretation of signs.
 *
 * TABLETA_TabletZ:  the current value of the tablet in the Z direction.
 * This unsigned value should typically be in the natural units of the
 * tablet.  You should also provide TABLETA_RangeZ.
 *
 * TABLETA_RangeZ:  the maximum value of the tablet in the Z direction.
 * Normally specified along with TABLETA_TabletZ,  this allows the
 * application to scale the actual Z value across its range.
 *
 * TABLETA_AngleX:  the angle of rotation or tilt about the X-axis.  This
 * number should be normalized to fill a signed LONGINT integer.  Positive
 * values imply a clockwise rotation about the X-axis when viewing
 * from +X towards the origin.
 *
 * TABLETA_AngleY:  the angle of rotation or tilt about the Y-axis.  This
 * number should be normalized to fill a signed LONGINT integer.  Positive
 * values imply a clockwise rotation about the Y-axis when viewing
 * from +Y towards the origin.
 *
 * TABLETA_AngleZ:  the angle of rotation or tilt about the Z axis.  This
 * number should be normalized to fill a signed LONGINT integer.  Positive
 * values imply a clockwise rotation about the Z-axis when viewing
 * from +Z towards the origin.
 *
 * Note: a stylus that supports tilt should use the TABLETA_AngleX
 * and TABLETA_AngleY attributes.   Tilting the stylus so the tip
 * points towards increasing or decreasing X is actually a rotation
 * around the Y-axis.  Thus,  if the stylus tip points towards
 * positive X,  then that tilt is represented as a negative
 * TABLETA_AngleY.  Likewise,  if the stylus tip points towards
 * positive Y,  that tilt is represented by positive TABLETA_AngleX.
 *
 * TABLETA_Pressure:  the pressure reading of the stylus.  The pressure
 * should be normalized to fill a signed LONGINT integer.   Typical devices
 * won't generate negative pressure,  but the possibility is not precluded.
 * The pressure threshold which is considered to cause a button-click is
 * expected to be set in a Preferences program supplied by the tablet
 * vendor.  The tablet driver would send IECODE_LBUTTON-type events as
 * the pressure crossed that threshold.
 *
 * TABLETA_ButtonBits:  ti_Data is a LONGINT integer whose bits are to
 * be interpreted at the state of the first 32 buttons of the tablet.
 *
 * TABLETA_InProximity:  ti_Data is a boolean.  For tablets that support
 * proximity,  they should send the  TABLETA_InProximity, FALSEEND STRUCT tag item
 * when the stylus is out of proximity.  One possible use we can forsee
 * is a mouse-blanking commodity which keys off this to blank the
 * mouse.  When this tag is absent,  the stylus is assumed to be
 * in proximity.
 *
 * TABLETA_ResolutionX:  ti_Data is an unsigned LONGINT integer which
 * is the x-axis resolution in dots per inch.
 *
 * TABLETA_ResolutionY:  ti_Data is an unsigned LONGINT integer which
 * is the y-axis resolution in dots per inch.
 */

#define TABLETA_Dummy      (TAG_USER + &H3A000)
#define TABLETA_TabletZ    (TABLETA_Dummy + &H01)
#define TABLETA_RangeZ     (TABLETA_Dummy + &H02)
#define TABLETA_AngleX     (TABLETA_Dummy + &H03)
#define TABLETA_AngleY     (TABLETA_Dummy + &H04)
#define TABLETA_AngleZ     (TABLETA_Dummy + &H05)
#define TABLETA_Pressure   (TABLETA_Dummy + &H06)
#define TABLETA_ButtonBits (TABLETA_Dummy + &H07)
#define TABLETA_InProximity   (TABLETA_Dummy + &H08)
#define TABLETA_ResolutionX   (TABLETA_Dummy + &H09)
#define TABLETA_ResolutionY   (TABLETA_Dummy + &H0A)

/* If your window sets WA_TabletMessages to TRUE,  then it will receive
 * extended IntuiMessages (STRUCT ExtIntuiMessage) whose eim_TabletData
 * field points at a TabletData structure.  This structure contains
 * additional information about the input event.
 */

STRUCT TabletData
 
    /* Sub-pixel position of tablet,  in screen coordinates, 
     * scaled to fill a SHORTINT fraction:
     */
    SHORTINT td_XFraction 
    SHORTINT   td_YFraction 

    /* Current tablet coordinates along each axis: */
    LONGINT td_TabletX 
    LONGINT   td_TabletY 

    /* Tablet range along each axis.  For example,  if td_TabletX
     * can take values 0-999,  td_RangeX should be 1000.
     */
    LONGINT td_RangeX 
    LONGINT   td_RangeY 

    /* Pointer to tag-list of additional tablet attributes.
     * See <intuition/intuition.h> for the tag values.
     */
    TagItemPtr  td_TagList 
END STRUCT 

/* If a tablet driver supplies a hook for ient_CallBack,  it will be
 * invoked in the standard hook manner.  A0 will point to the Hook
 * itself,  A2 will point to the InputEvent that was sent,  and
 * A1 will point to a TabletHookData structure.  The InputEvent's
 * ie_EventAddress field points at the IENewTablet structure that
 * the driver supplied.
 *
 * Based on the thd_Screen,  thd_Width,  and thd_Height fields,  the driver
 * should scale the ient_TabletX and ient_TabletY fields and store the
 * result in ient_ScaledX,  ient_ScaledY,  ient_ScaledXFraction,  and
 * ient_ScaledYFraction.
 *
 * The tablet hook must currently return NULL.  This is the only
 * acceptable return-value under V39.
 */

STRUCT TabletHookData
 
    /* Pointer to the active screen:
     * Note: if there are no open screens,  thd_Screen will be NULL.
     * thd_Width and thd_Height will then describe an NTSC 64&H400
     * screen. Please scale accordingly.
     */
    ScreenPtr  thd_Screen 

    /* The width and height (measured in pixels of the active screen)
     * that your are to scale to:
     */
    LONGINT thd_Width 
    LONGINT thd_Height 

    /* Non-zero if the screen or something about the screen
     * changed since the last time you were invoked:
     */
    LONGINT thd_ScreenChanged 
END STRUCT 

/* Include obsolete identifiers: */
#ifndef INTUITION_IOBSOLETE_H
#include <intuition/iobsolete.h>
#endif

#endif
