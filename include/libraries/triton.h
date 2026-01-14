#ifndef LIBRARIES_TRITON_H
#define LIBRARIES_TRITON_H
/*
** triton.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/28/95
**
**
*/

/*
** This are the StructPointer defines for triton.h
*/
#define TR_AppPtr ADDRESS
#define TR_DimensionsPtr ADDRESS
#define TR_MessagePtr ADDRESS
#define TR_ProjectPtr ADDRESS
/*
** End of StructPointer defines for triton.h
*/

#define TRITONNAME              "triton.library"
#define TRITON10VERSION         1&
#define TRITON11VERSION         2&
#define TRITON12VERSION         3&
#define TRITON13VERSION         4&
#define TRITON14VERSION         5&


/* ////////////////////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////////// Includes // */
/* ////////////////////////////////////////////////////////////////////// */

#ifndef INTUI_V36_NAMES_ONLY
#define INTUI_V36_NAMES_ONLY
#endif

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef INTUITION_INTUITIONBASE_H
#include <intuition/intuitionbase.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef INTUITION_GADGETCLASS_H
#include <intuition/gadgetclass.h>
#endif

#ifndef INTUITION_IMAGECLASS_H
#include <intuition/imageclass.h>
#endif

#ifndef INTUITION_CLASSUSR_H
#include <intuition/classusr.h>
#endif

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif

#ifndef GRAPHICS_GFXBASE_H
#include <graphics/gfxbase.h>
#endif

#ifndef GRAPHICS_GFXMACROS_H
#include <graphics/gfxmacros.h>
#endif

#ifndef LIBRARIES_GADTOOLS_H
#include <libraries/gadtools.h>
#endif

#ifndef LIBRARIES_DISKFONT_H
#include <libraries/diskfont.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef WORKBENCH_STARTUP_H
#include <workbench/startup.h>
#endif

#ifndef WORKBENCH_WORKBENCH_H
#include <workbench/workbench.h>
#endif


/* ////////////////////////////////////////////////////////////////////// */
/* //////////////////////////////////////////////////////////// Macros // */
/* ////////////////////////////////////////////////////////////////////// */

#ifndef TR_NOMACROS
#include <libraries/triton.macros>
#endif /* TR_NOMACROS */



/* ////////////////////////////////////////////////////////////////////// */
/* //////////////////////////////////////////////// The Triton message // */
/* ////////////////////////////////////////////////////////////////////// */

STRUCT TR_Message
 
  TR_ProjectPtr  trm_Project     /* The project which triggered the MESSAGE */
  LONGINT        trm_ID          /* The object's ID (where appropriate) */
  LONGINT        trm_Class       /* The Triton MESSAGE class */
  LONGINT        trm_Data        /* The class-specific DATA */
  LONGINT        trm_Code        /* Currently only used by TRMS_KEYPRESSED */
  LONGINT        trm_Qualifier   /* IEQUALIFIERs */
  LONGINT        trm_Seconds     /* \ Copy of system clock time (Only where */
  LONGINT        trm_Micros      /* / available! If not set,  trm_Seconds is 0) */
  TR_AppPtr      trm_App         /* The project's application */
END STRUCT 

/* Message classes */
#define TRMS_CLOSEWINDOW        1&  /* The window should be closed */
#define TRMS_ERROR              2&  /* An error occured. Error code in trm_Data */
#define TRMS_NEWVALUE           3&  /* Object's value has changed. New value in trm_Data */
#define TRMS_ACTION             4&  /* Object has triggered an action */
#define TRMS_ICONDROPPED        5&  /* Icon dropped over window (ID=0) or DropBox. AppMessage* in trm_Data */
#define TRMS_KEYPRESSED         6&  /* Key pressed. trm_Data contains ASCII code,  trm_Code raw code and */
                                    /* trm_Qualifier contains qualifiers */
#define TRMS_HELP               7&  /* The user requested help for the specified ID */
#define TRMS_DISKINSERTED       8&  /* A disk has been inserted into a drive */
#define TRMS_DISKREMOVED        9&  /* A disk has been removed from a drive */


/* ////////////////////////////////////////////////////////////////////// */
/* //////////////////////////////////////////////// Triton error codes // */
/* ////////////////////////////////////////////////////////////////////// */

#define TRER_OK                 0&        /* No error */

#define TRER_ALLOCMEM           1&        /* Not enough memory */
#define TRER_OPENWINDOW         2&        /* Can't open window */
#define TRER_WINDOWTOOBIG       3&        /* Window would be too big for screen */
#define TRER_DRAWINFO           4&        /* Can't get screen's DrawInfo */
#define TRER_OPENFONT           5&        /* Can't open font */
#define TRER_CREATEMSGPORT      6&        /* Can't create message port */
#define TRER_INSTALLOBJECT      7&        /* Can't create an object */
#define TRER_CREATECLASS        8&        /* Can't create a class */
#define TRER_NOLOCKPUBSCREEN    9&        /* Can't lock public screen */
#define TRER_CREATEMENUS        12&       /* Error while creating the menus */
#define TRER_GT_CREATECONTEXT   14&       /* Can't create gadget context */

#define TRER_MAXERRORNUM        15&       /* PRIVATE! */


/* ////////////////////////////////////////////////////////////////////// */
/* /////////////////////////////////////////////////// Object messages // */
/* ////////////////////////////////////////////////////////////////////// */

#define TROM_ACTIVATE 23&                 /* Activate an object */


/* ////////////////////////////////////////////////////////////////////// */
/* ///////////////////////////////////////// Tags for TR_OpenProject() // */
/* ////////////////////////////////////////////////////////////////////// */

/* Tag bases */
#define TRTG_OAT              (TAG_USER+&H400)  /* Object attribute */
#define TRTG_OBJ              (TAG_USER+&H100)  /* Object ID */
#define TRTG_OAT2             (TAG_USER+&H80)   /* PRIVATE! */
#define TRTG_PAT              (TAG_USER)        /* Project attribute */

/* Window/Project */
#define TRWI_Title              (TRTG_PAT+&H01) /* STRPTR: The window title */
#define TRWI_Flags              (TRTG_PAT+&H02) /* See below for window flags */
#define TRWI_Underscore         (TRTG_PAT+&H03) /* BYTE *: The underscore for menu and gadget shortcuts */
#define TRWI_Position           (TRTG_PAT+&H04) /* Window position,  see below */
#define TRWI_CustomScreen       (TRTG_PAT+&H05) /* STRUCT Screen * */
#define TRWI_PubScreen          (TRTG_PAT+&H06) /* STRUCT Screen *,  must have been locked! */
#define TRWI_PubScreenName      (TRTG_PAT+&H07) /* ADDRESS,  Triton is doing the locking */
#define TRWI_PropFontAttr       (TRTG_PAT+&H08) /* STRUCT TextAttr *: The proportional font */
#define TRWI_FixedWidthFontAttr (TRTG_PAT+&H09) /* STRUCT TextAttr *: The fixed-width font */
#define TRWI_Backfill           (TRTG_PAT+&H0A) /* The backfill type,  see below */
#define TRWI_ID                 (TRTG_PAT+&H0B) /* ULONG: The window ID */
#define TRWI_Dimensions         (TRTG_PAT+&H0C) /* STRUCT TR_Dimensions * */
#define TRWI_ScreenTitle        (TRTG_PAT+&H0D) /* STRPTR: The screen title */
#define TRWI_QuickHelp          (TRTG_PAT+&H0E) /* BOOL: Quick help active? */

/* Menus */
#define TRMN_Title              (TRTG_PAT+&H65) /* STRPTR: Menu */
#define TRMN_Item               (TRTG_PAT+&H66) /* STRPTR: Menu item */
#define TRMN_Sub                (TRTG_PAT+&H67) /* STRPTR: Menu subitem */
#define TRMN_Flags              (TRTG_PAT+&H68) /* See below for flags */

/* General object attributes */
#define TRAT_ID               (TRTG_OAT2+&H16)  /* The object's/menu's ID */
#define TRAT_Flags            (TRTG_OAT2+&H17)  /* The object's flags */
#define TRAT_Value            (TRTG_OAT2+&H18)  /* The object's value */
#define TRAT_Text             (TRTG_OAT2+&H19)  /* The object's text */
#define TRAT_Disabled         (TRTG_OAT2+&H1A)  /* Disabled object? */
#define TRAT_Backfill         (TRTG_OAT2+&H1B)  /* Backfill pattern */
#define TRAT_MinWidth         (TRTG_OAT2+&H1C)  /* Minimum width */
#define TRAT_MinHeight        (TRTG_OAT2+&H1D)  /* Minimum height */


/* ////////////////////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////// Window flags // */
/* ////////////////////////////////////////////////////////////////////// */

#define TRWF_BACKDROP           &H00000001&     /* Create a backdrop borderless window */
#define TRWF_NODRAGBAR          &H00000002&     /* Don't use a dragbar */
#define TRWF_NODEPTHGADGET      &H00000004&     /* Don't use a depth-gadget */
#define TRWF_NOCLOSEGADGET      &H00000008&     /* Don't use a close-gadget */
#define TRWF_NOACTIVATE         &H00000010&     /* Don't activate window */
#define TRWF_NOESCCLOSE         &H00000020&     /* Don't send TRMS_CLOSEWINDOW when Esc is pressed */
#define TRWF_NOPSCRFALLBACK     &H00000040&     /* Don't fall back onto default PubScreen */
#define TRWF_NOZIPGADGET        &H00000080&     /* Don't use a zip-gadget */
#define TRWF_ZIPCENTERTOP       &H00000100&     /* Center the zipped window on the title bar */
#define TRWF_NOMINTEXTWIDTH     &H00000200&     /* Minimum window width not according to title text */
#define TRWF_NOSIZEGADGET       &H00000400&     /* Don't use a sizing-gadget */
#define TRWF_NOFONTFALLBACK     &H00000800&     /* Don't fall back to topaz.8 */
#define TRWF_NODELZIP           &H00001000&     /* Don't zip the window when Del is pressed */
#define TRWF_SIMPLEREFRESH      &H00002000&     /* *** OBSOLETE *** (V3+) */
#define TRWF_ZIPTOCURRENTPOS    &H00004000&     /* Will zip the window at the current position (OS3.0+) */
#define TRWF_APPWINDOW          &H00008000&     /* Create an AppWindow without using class_dropbox */
#define TRWF_ACTIVATESTRGAD     &H00010000&     /* Activate the first string gadget after opening the window */
#define TRWF_HELP               &H00020000&     /* Pressing <Help> will create a TRMS_HELP message (V4) */
#define TRWF_SYSTEMACTION       &H00040000&     /* System status messages will be sent (V4) */


/* ////////////////////////////////////////////////////////////////////// */
/* //////////////////////////////////////////////////////// Menu flags // */
/* ////////////////////////////////////////////////////////////////////// */

#define TRMF_CHECKIT            &H00000001&     /* Leave space for a checkmark */
#define TRMF_CHECKED            &H00000002&     /* Check the item (includes TRMF_CHECKIT) */
#define TRMF_DISABLED           &H00000004&     /* Ghost the menu/item */


/* ////////////////////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////// Window positions // */
/* ////////////////////////////////////////////////////////////////////// */

#define TRWP_DEFAULT            0&              /* Let Triton choose a good position */
#define TRWP_BELOWTITLEBAR      1&              /* Left side of screen,  below title bar */
#define TRWP_CENTERTOP          1025&           /* Top of screen,  centered on the title bar */
#define TRWP_TOPLEFTSCREEN      1026&           /* Top left corner of screen */
#define TRWP_CENTERSCREEN       1027&           /* Centered on the screen */
#define TRWP_CENTERDISPLAY      1028&           /* Centered on the currently displayed clip */
#define TRWP_MOUSEPOINTER       1029&           /* Under the mouse pointer */
#define TRWP_ABOVECOORDS        2049&           /* Above coordinates from the dimensions STRUCT */
#define TRWP_BELOWCOORDS        2050&           /* Below coordinates from the dimensions STRUCT */


/* ////////////////////////////////////////////////////////////////////// */
/* //////////////////////////////////// Backfill types / System images // */
/* ////////////////////////////////////////////////////////////////////// */

#define TRBF_WINDOWBACK         &H00000000&     /* Window backfill */
#define TRBF_REQUESTERBACK      &H00000001&     /* Requester backfill */

#define TRBF_NONE               &H00000002&     /* No backfill (= Fill with BACKGROUNDPEN) */
#define TRBF_SHINE              &H00000003&     /* Fill with SHINEPEN */
#define TRBF_SHINE_SHADOW       &H00000004&     /* Fill with SHINEPEN + SHADOWPEN */
#define TRBF_SHINE_FILL         &H00000005&     /* Fill with SHINEPEN + FILLPEN */
#define TRBF_SHINE_BACKGROUND   &H00000006&     /* Fill with SHINEPEN + BACKGROUNDPEN */
#define TRBF_SHADOW             &H00000007&     /* Fill with SHADOWPEN */
#define TRBF_SHADOW_FILL        &H00000008&     /* Fill with SHADOWPEN + FILLPEN */
#define TRBF_SHADOW_BACKGROUND  &H00000009&     /* Fill with SHADOWPEN + BACKGROUNDPEN */
#define TRBF_FILL               &H0000000A&     /* Fill with FILLPEN */
#define TRBF_FILL_BACKGROUND    &H0000000B&     /* Fill with FILLPEN + BACKGROUNDPEN */

#define TRSI_USBUTTONBACK       &H00010002&     /* Unselected button backfill */
#define TRSI_SBUTTONBACK        &H00010003&     /* Selected button backfill */


/* ////////////////////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////// Display Object flags // */
/* ////////////////////////////////////////////////////////////////////// */

/* General flags */
#define TROF_RAISED             &H00000001&     /* Raised object */
#define TROF_HORIZ              &H00000002&     /* Horizontal object \ Works automatically */
#define TROF_VERT               &H00000004&     /* Vertical object   / in groups */
#define TROF_RIGHTALIGN         &H00000008&     /* Align object to the right border if available */

/* Text flags for different kinds of text-related objects */
#define TRTX_NOUNDERSCORE       &H00000100&     /* Don't interpret underscores */
#define TRTX_HIGHLIGHT          &H00000200&     /* Highlight text */
#define TRTX_3D                 &H00000400&     /* 3D design */
#define TRTX_BOLD               &H00000800&     /* Softstyle 'bold' */
#define TRTX_TITLE              &H00001000&     /* A title (e.g. of a group) */
#define TRTX_SELECTED           &H00002000&     /* PRIVATE! */


/* ////////////////////////////////////////////////////////////////////// */
/* ////////////////////////////////////////////////////// Menu entries // */
/* ////////////////////////////////////////////////////////////////////// */

#define TRMN_BARLABEL           (-1&)           /* A barlabel instead of text */


/* ////////////////////////////////////////////////////////////////////// */
/* /////////////////////////////////////////// Tags for TR_CreateApp() // */
/* ////////////////////////////////////////////////////////////////////// */

#define TRCA_Name               (TAG_USER+1)
#define TRCA_LongName           (TAG_USER+2)
#define TRCA_Info               (TAG_USER+3)
#define TRCA_Version            (TAG_USER+4)
#define TRCA_Release            (TAG_USER+5)
#define TRCA_Date               (TAG_USER+6)


/* ////////////////////////////////////////////////////////////////////// */
/* ///////////////////////////////////////// Tags for TR_EasyRequest() // */
/* ////////////////////////////////////////////////////////////////////// */

#define TREZ_ReqPos             (TAG_USER+1)
#define TREZ_LockProject        (TAG_USER+2)
#define TREZ_Return             (TAG_USER+3)
#define TREZ_Title              (TAG_USER+4)
#define TREZ_Activate           (TAG_USER+5)


/* ////////////////////////////////////////////////////////////////////// */
/* ///////////////////////////////////////// The Application Structure // */
/* ////////////////////////////////////////////////////////////////////// */

STRUCT TR_App /* This structure is PRIVATE! */
 
  ADDRESS      tra_MemPool         /* The memory pool */
  LONGINT      tra_BitMask         /* Bits to Wait() for. THIS FIELD IS NOT PRIVATE! */
  LONGINT      tra_LastError       /* TRER code of last error */
  ADDRESS      tra_Name            /* Unique name */
  ADDRESS      tra_LongName        /* User-readable name */
  ADDRESS      tra_Info            /* Info string */
  ADDRESS      tra_Version         /* Version */
  ADDRESS      tra_Release         /* Release */
  ADDRESS      tra_Date            /* Compilation date */
  MsgPortPtr   tra_AppPort         /* Application message port */
  MsgPortPtr   tra_IDCMPPort       /* IDCMP message port */
  ADDRESS      tra_Prefs           /* Pointer to Triton app prefs */
  TR_ProjectPtr  tra_LastProject     /* Used for menu item linking */
  InputEventPtr  tra_InputEvent      /* Used for RAWKEY conversion */
END STRUCT 


/* ////////////////////////////////////////////////////////////////////// */
/* ////////////////////////////////////////// The Dimensions Structure // */
/* ////////////////////////////////////////////////////////////////////// */

STRUCT TR_Dimensions
 
  SHORTINT                         trd_Left            /* Left */
  SHORTINT                         trd_Top             /* Top */
  SHORTINT                         trd_Width           /* Width */
  SHORTINT                         trd_Height          /* Height */
  SHORTINT                         trd_Left2           /* Left */
  SHORTINT                         trd_Top2            /* Top */
  SHORTINT                         trd_Width2          /* Width */
  SHORTINT                         trd_Height2         /* Height */
  SHORTINT                         trd_Zoomed          /* Window zoomed? */
  STRING reserved SIZE 6                               /* For future expansions */
END STRUCT 


/* ////////////////////////////////////////////////////////////////////// */
/* ///////////////////////////////////////////// The Project Structure // */
/* ////////////////////////////////////////////////////////////////////// */

STRUCT TR_Project /* This structure is PRIVATE! */
 
  TR_AppPtr             trp_App                         /* Our application */
  ScreenPtr             trp_Screen                      /* Our screen,  always valid */
  LONGINT               trp_ScreenType                  /* Type of screen (WA_...Screen) */

  LONGINT               trp_ID                          /* The project's ID */

  ScreenPtr             trp_LockedPubScreen             /* Only valid if we're using a PubScreen */
  ADDRESS               trp_ScreenTitle                 /* The screen title */

  WindowPtr             trp_Window                      /* The window */
  AppWindowPtr          trp_AppWindow                   /* AppWindow for icon dropping */

  LONGINT               trp_IDCMPFlags                  /* The IDCMP flags */
  LONGINT               trp_Flags                       /* Triton window flags */

  NewMenuPtr            trp_NewMenu                     /* The newmenu stucture built by Triton */
  LONGINT               trp_NewMenuSize                 /* The number of menu items in the list */
  MenuPtr               trp_Menu                        /* The menu structure */
  SHORTINT              trp_NextSelect                  /* The next selected menu item */

  ADDRESS               trp_VisualInfo                  /* The VisualInfo of our window */
  DrawInfoPtr           trp_DrawInfo                    /* The DrawInfo of the screen */
  TR_DimensionsPtr      trp_UserDimensions              /* User-supplied dimensions */
  TR_DimensionsPtr      trp_Dimensions                  /* Private dimensions */

  LONGINT               trp_WindowStdHeight             /* The standard height of the window */
  LONGINT               trp_LeftBorder                  /* The width of the left window border */
  LONGINT               trp_RightBorder                 /* The width of the right window border */
  LONGINT               trp_TopBorder                   /* The height of the top window border */
  LONGINT               trp_BottomBorder                /* The height of the bottom window border */
  LONGINT               trp_InnerWidth                  /* The inner width of the window */
  LONGINT               trp_InnerHeight                 /* The inner height of the window */
  STRING trp_ZipDimensions SIZE 8                       /* The dimensions for the zipped window */
  SHORTINT              trp_AspectFixing                /* Pixel aspect correction factor */

  MinList               trp_ObjectList                  /* The list of display objects */
  MinList               trp_MenuList                    /* The list of menus */
  MinList               trp_IDList                      /* The ID linking list (menus & objects) */
  ADDRESS               trp_MemPool                     /* The memory pool for the lists */
  SHORTINT              trp_HasObjects                  /* Do we have display objects? */

  TextAttrPtr           trp_PropAttr                    /* The proportional font attributes */
  TextAttrPtr           trp_FixedWidthAttr              /* The fixed-width font attributes */
  TextFontPtr           trp_PropFont                    /* The proportional font */
  TextFontPtr           trp_FixedWidthFont              /* The fixed-width font */
  SHORTINT              trp_OpenedPropFont              /* \ Have we opened the fonts ? */
  SHORTINT              trp_OpenedFixedWidthFont        /* /                            */
  SHORTINT              trp_TotalPropFontHeight         /* Height of prop font incl. underscore */

  LONGINT               trp_BackfillType                /* The backfill type */
  HookPtr               trp_BackfillHook                /* The backfill hook */

  GadgetPtr             trp_GadToolsGadgetList          /* List of GadTools gadgets */
  GadgetPtr             trp_PrevGadget                  /* Previous GadTools gadget */
  NewGadgetPtr          trp_NewGadget                   /* GadTools NewGadget */

  RequesterPtr          trp_InvisibleRequest            /* The invisible blocking requester */
  SHORTINT              trp_IsUserLocked                /* Project locked by the user? */

  LONGINT               trp_CurrentID                   /* The currently keyboard-selected ID */
  SHORTINT              trp_IsShortcutDown              /* Shortcut key pressed? */
  BYTE                  trp_Underscore                  /* The underscore character */

  SHORTINT              trp_EscClose                    /* Close window on Esc? */
  SHORTINT              trp_DelZip                      /* Zip window on Del? */
  SHORTINT              trp_PubScreenFallBack           /* Fall back onto default public screen? */
  SHORTINT              trp_FontFallBack                /* Fall back to topaz.8? */

  SHORTINT              trp_OldWidth                    /* Old window width */
  SHORTINT              trp_OldHeight                   /* Old window height */

  WindowPtr             trp_QuickHelpWindow             /* The QuickHelp window */
  ADDRESS               trp_QuickHelpObject             /* Object FOR which help is popped up */
  LONGINT               trp_TicksPassed                 /* IntuiTicks passed since last MouseMove */
END STRUCT 


/* ////////////////////////////////////////////////////////////////////// */
/* ///////////////////////////// Default classes,  attributes and flags // */
/* ////////////////////////////////////////////////////////////////////// */

/* The following code has been assembled automatically from the class
   sources _and may therefore look somehow unstructured and chaotic :-) */

/* class_DisplayObject */

#define TROB_DisplayObject      (TRTG_OBJ+&H3C) /* A basic display object */

#define TRDO_QuickHelpString    (TRTG_OAT+&H1E3)

/* class_Group */

#define TRGR_Horiz              (TAG_USER+201)  /* Horizontal group */
#define TRGR_Vert               (TAG_USER+202)  /* Vertical group */
#define TRGR_End                (TRTG_OAT2+&H4B)/* End of a group */

#define TRGR_PROPSHARE          &H00000000&     /* Default: Divide objects proportionally */
#define TRGR_EQUALSHARE         &H00000001&     /* Divide objects equally */
#define TRGR_PROPSPACES         &H00000002&     /* Divide spaces proportionally */
#define TRGR_ARRAY              &H00000004&     /* Top-level array group */

#define TRGR_ALIGN              &H00000008&     /* Align resizeable objects in secondary dimension */
#define TRGR_CENTER             &H00000010&     /* Center unresizeable objects in secondary dimension */

#define TRGR_FIXHORIZ           &H00000020&     /* Don't allow horizontal resizing */
#define TRGR_FIXVERT            &H00000040&     /* Don't allow vertical resizing */
#define TRGR_INDEP              &H00000080&     /* Group is independant of surrounding array */

/* class_Space */

#define TROB_Space              (TRTG_OBJ+&H285)/* The spaces class */

#define TRST_NONE               1&              /* No space */
#define TRST_SMALL              2&              /* Small space */
#define TRST_NORMAL             3&              /* Normal space (default) */
#define TRST_BIG                4&              /* Big space */

/* class_CheckBox */

#define TROB_CheckBox           (TRTG_OBJ+&H2F) /* A checkbox gadget */

/* class_Object */

#define TROB_Object             (TRTG_OBJ+&H3D) /* A rootclass object */

/* class_Cycle */

#define TROB_Cycle              (TRTG_OBJ+&H36) /* A cycle gadget */

#define TRCY_MX                 &H00010000&     /* Unfold the cycle gadget to a MX gadget */
#define TRCY_RIGHTLABELS        &H00020000&     /* Put the labels to the right of a MX gadget */

/* class_DropBox */

#define TROB_DropBox            (TRTG_OBJ+&H38) /* An icon drop box */

/* class_Scroller */

#define TROB_Scroller           (TRTG_OBJ+&H35) /* A scroller gadget */

#define TRSC_Total              (TRTG_OAT+&H1E0)
#define TRSC_Visible            (TRTG_OAT+&H1E1)

/* class_FrameBox */

#define TROB_FrameBox           (TRTG_OBJ+&H32) /* A framing box */

#define TRFB_GROUPING           &H00000001&     /* A grouping box */
#define TRFB_FRAMING            &H00000002&     /* A framing box */
#define TRFB_TEXT               &H00000004&     /* A text container */

/* class_Button */

#define TROB_Button             (TRTG_OBJ+&H31) /* A BOOPSI button gadget */

#define TRBU_RETURNOK           &H00010000&     /* <Return> answers the button */
#define TRBU_ESCOK              &H00020000&     /* <Esc> answers the button */
#define TRBU_SHIFTED            &H00040000&     /* Shifted shortcut only */
#define TRBU_UNSHIFTED          &H00080000&     /* Unshifted shortcut only */
#define TRBU_YRESIZE            &H00100000&     /* Button resizeable in Y direction */
#define TRBT_TEXT               0&              /* Text button */
#define TRBT_GETFILE            1&              /* GetFile button */
#define TRBT_GETDRAWER          2&              /* GetDrawer button */
#define TRBT_GETENTRY           3&              /* GetEntry button */

/* class_Line */

#define TROB_Line               (TRTG_OBJ+&H2D) /* A simple line */

/* class_Palette */

#define TROB_Palette            (TRTG_OBJ+&H33) /* A palette gadget */

/* class_Slider */

#define TROB_Slider             (TRTG_OBJ+&H34) /* A slider gadget */

#define TRSL_Min                (TRTG_OAT+&H1DE)
#define TRSL_Max                (TRTG_OAT+&H1DF)

/* class_Progress */

#define TROB_Progress           (TRTG_OBJ+&H3A) /* A progress indicator */

/* class_Text */

#define TROB_Text               (TRTG_OBJ+&H30) /* A line of text */

#define TRTX_CLIPPED            &H00010000&     /* Text is clipped */
/* class_Listview */

#define TROB_Listview           (TRTG_OBJ+&H39) /* A listview gadget */

#define TRLV_Top                (TRTG_OAT+&H1E2)

#define TRLV_READONLY           &H00010000&     /* A read-only list */
#define TRLV_SELECT             &H00020000&     /* You may select an entry */
#define TRLV_SHOWSELECTED       &H00040000&     /* Selected entry will be shown */
#define TRLV_NOCURSORKEYS       &H00080000&     /* Don't use arrow keys */
#define TRLV_NONUMPADKEYS       &H00100000&     /* Don't use numeric keypad keys */
#define TRLV_FWFONT             &H00200000&     /* Use the fixed-width font */
#define TRLV_NOGAP              &H00400000&     /* Don't leave a gap below the list */

/* class_Image */

#define TROB_Image              (TRTG_OBJ+&H3B) /* An image */

#define TRIM_BOOPSI             &H00010000&     /* Use a BOOPSI IClass image */

/* class_String */

#define TROB_String             (TRTG_OBJ+&H37) /* A string gadget */

#define TRST_INVISIBLE          &H00010000&     /* A password gadget -> invisible typing */
#define TRST_NORETURNBROADCAST  &H00020000&     /* <Return> keys will not be broadcast to the window */

/* End of automatically assembled code */


/* ////////////////////////////////////////////////////////////////////// */
/* /////////////////////////////////////////////////////////// The End // */
/* ////////////////////////////////////////////////////////////////////// */

#endif /* LIBRARIES_TRITON_H */
