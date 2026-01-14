#ifndef LIBRARIES_ASL_H
#define LIBRARIES_ASL_H 1
/*
** asl.h for ACE Basic
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
** This are the StructPointer defines for asl.h
*/
#ifndef DisplayModePtr
#define DisplayModePtr ADDRESS
#endif
#ifndef FileRequesterPtr
#define FileRequesterPtr ADDRESS
#endif
#ifndef FontRequesterPtr
#define FontRequesterPtr ADDRESS
#endif
#ifndef ScreenModeRequesterPtr
#define ScreenModeRequesterPtr ADDRESS
#endif
/*
** End of StructPointer defines for asl.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef WORKBENCH_STARTUP_H
#include <workbench/startup.h>
#endif

#ifndef GRAPHICS_TEXT_H
#include <graphics/text.h>
#endif

#ifndef GRAPHICS_DISPLAYINFO_H
#include <graphics/displayinfo.h>
#endif


/*****************************************************************************/


#define AslName "asl.library"
#define ASL_TB  (TAG_USER+&H80000)


/*****************************************************************************/


/* Types of requesters known to ASL,  used as arguments to AllocAslRequest() */
#define ASL_FileRequest       0
#define ASL_FontRequest       1
#define ASL_ScreenModeRequest 2


/*****************************************************************************
 *
 * ASL File Requester data structures and constants
 *
 * This structure must only be allocated by asl.library amd is READ-ONLY!
 * Control of the various fields is provided via tags when the requester
 * is created with AllocAslRequest() and when it is displayed via
 * AslRequest()
 */
STRUCT FileRequester
 
    STRING fr_Reserved0 SIZE 4  
    ADDRESS    fr_File         /* Contents of File gadget on exit    */
    ADDRESS    fr_Drawer           /* Contents of Drawer gadget on exit  */
    STRING fr_Reserved1 SIZE 10  
    SHORTINT      fr_LeftEdge         /* Coordinates of requester on exit   */
    SHORTINT      fr_TopEdge 
    SHORTINT      fr_Width 
    SHORTINT      fr_Height 
    STRING fr_Reserved2 SIZE 2  
    LONGINT      fr_NumArgs          /* Number of files selected       */
    WBArgPtr  fr_ArgList          /* List of files selected     */
    ADDRESS      fr_UserData         /* You can store your own data here   */
    STRING fr_Reserved3 SIZE 8  
    ADDRESS    fr_Pattern          /* Contents of Pattern gadget on exit */
END STRUCT 

/* File requester tag values,  used by AllocAslRequest() and AslRequest() */

/* Window control */
#define ASLFR_Window          ASL_TB+2   /* Parent window            */
#define ASLFR_Screen          ASL_TB+40  /* Screen to open on if no window   */
#define ASLFR_PubScreenName   ASL_TB+41  /* Name of public screen        */
#define ASLFR_PrivateIDCMP    ASL_TB+42  /* Allocate private IDCMP?      */
#define ASLFR_IntuiMsgFunc    ASL_TB+70  /* Function to handle IntuiMessages */
#define ASLFR_SleepWindow     ASL_TB+43  /* Block input in ASLFR_Window?     */
#define ASLFR_UserData        ASL_TB+52  /* What to put in fr_UserData       */

/* Text display */
#define ASLFR_TextAttr        ASL_TB+51  /* Text font to use for gadget text */
#define ASLFR_Locale          ASL_TB+50  /* Locale ASL should use for text   */
#define ASLFR_TitleText       ASL_TB+1   /* Title of requester           */
#define ASLFR_PositiveText    ASL_TB+18  /* Positive gadget text         */
#define ASLFR_NegativeText    ASL_TB+19  /* Negative gadget text         */

/* Initial settings */
#define ASLFR_InitialLeftEdge ASL_TB+3   /* Initial requester coordinates    */
#define ASLFR_InitialTopEdge  ASL_TB+4
#define ASLFR_InitialWidth    ASL_TB+5   /* Initial requester dimensions     */
#define ASLFR_InitialHeight   ASL_TB+6
#define ASLFR_InitialFile     ASL_TB+8   /* Initial contents of File gadget  */
#define ASLFR_InitialDrawer   ASL_TB+9   /* Initial contents of Drawer gadg. */
#define ASLFR_InitialPattern  ASL_TB+10  /* Initial contents of Pattern gadg.*/

/* Options */
#define ASLFR_Flags1          ASL_TB+20  /* Option flags             */
#define ASLFR_Flags2          ASL_TB+22  /* Additional option flags      */
#define ASLFR_DoSaveMode      ASL_TB+44  /* Being used for saving?       */
#define ASLFR_DoMultiSelect   ASL_TB+45  /* Do multi-select?             */
#define ASLFR_DoPatterns      ASL_TB+46  /* Display a Pattern gadget?        */

/* Filtering */
#define ASLFR_DrawersOnly     ASL_TB+47  /* Don't display files?         */
#define ASLFR_FilterFunc      ASL_TB+49  /* Function to filter files         */
#define ASLFR_RejectIcons     ASL_TB+60  /* Display .info files?         */
#define ASLFR_RejectPattern   ASL_TB+61  /* Don't display files matching pat */
#define ASLFR_AcceptPattern   ASL_TB+62  /* Accept only files matching pat   */
#define ASLFR_FilterDrawers   ASL_TB+63  /* Also filter drawers with patterns*/
#define ASLFR_HookFunc        ASL_TB+7   /* Combined callback function       */

/* Flag bits for the ASLFR_Flags1 tag */
#define FRB_FILTERFUNC     7
#define FRB_INTUIFUNC      6
#define FRB_DOSAVEMODE     5
#define FRB_PRIVATEIDCMP   4
#define FRB_DOMULTISELECT  3
#define FRB_DOPATTERNS     0

#define FRF_FILTERFUNC     (128&)
#define FRF_INTUIFUNC      (64&)
#define FRF_DOSAVEMODE     (32&)
#define FRF_PRIVATEIDCMP   (16&)
#define FRF_DOMULTISELECT  (8&)
#define FRF_DOPATTERNS     (1&)

/* Flag bits for the ASLFR_Flags2 tag */
#define FRB_DRAWERSONLY    0
#define FRB_FILTERDRAWERS  1
#define FRB_REJECTICONS    2

#define FRF_DRAWERSONLY    (1&)
#define FRF_FILTERDRAWERS  (2&)
#define FRF_REJECTICONS    (4&)


/*****************************************************************************
 *
 * ASL Font Requester data structures and constants
 *
 * This structure must only be allocated by asl.library amd is READ-ONLY!
 * Control of the various fields is provided via tags when the requester
 * is created with AllocAslRequest() and when it is displayed via
 * AslRequest()
 */
STRUCT FontRequester
 
    STRING fo_Reserved0 SIZE 8  
    TextAttr fo_Attr        /* Returned TextAttr            */
    BYTE         fo_FrontPen    /* Returned front pen           */
    BYTE         fo_BackPen     /* Returned back pen            */
    BYTE         fo_DrawMode    /* Returned drawing mode        */
    BYTE         fo_Reserved1 
    ADDRESS         fo_UserData    /* You can store your own data here */
    SHORTINT         fo_LeftEdge    /* Coordinates of requester on exit */
    SHORTINT         fo_TopEdge 
    SHORTINT         fo_Width 
    SHORTINT         fo_Height 
    TTextAttr fo_TAttr       /* Returned TTextAttr           */
END STRUCT 

/* Font requester tag values,  used by AllocAslRequest() and AslRequest() */

/* Window control */
#define ASLFO_Window          ASL_TB+2   /* Parent window            */
#define ASLFO_Screen          ASL_TB+40  /* Screen to open on if no window   */
#define ASLFO_PubScreenName   ASL_TB+41  /* Name of public screen        */
#define ASLFO_PrivateIDCMP    ASL_TB+42  /* Allocate private IDCMP?      */
#define ASLFO_IntuiMsgFunc    ASL_TB+70  /* Function to handle IntuiMessages */
#define ASLFO_SleepWindow     ASL_TB+43  /* Block input in ASLFO_Window?     */
#define ASLFO_UserData        ASL_TB+52  /* What to put in fo_UserData       */

/* Text display */
#define ASLFO_TextAttr        ASL_TB+51  /* Text font to use for gadget text */
#define ASLFO_Locale          ASL_TB+50  /* Locale ASL should use for text   */
#define ASLFO_TitleText       ASL_TB+1   /* Title of requester           */
#define ASLFO_PositiveText    ASL_TB+18  /* Positive gadget text         */
#define ASLFO_NegativeText    ASL_TB+19  /* Negative gadget text         */

/* Initial settings */
#define ASLFO_InitialLeftEdge ASL_TB+3   /* Initial requester coordinates    */
#define ASLFO_InitialTopEdge  ASL_TB+4
#define ASLFO_InitialWidth    ASL_TB+5   /* Initial requester dimensions     */
#define ASLFO_InitialHeight   ASL_TB+6
#define ASLFO_InitialName     ASL_TB+10  /* Initial contents of Name gadget  */
#define ASLFO_InitialSize     ASL_TB+11  /* Initial contents of Size gadget  */
#define ASLFO_InitialStyle    ASL_TB+12  /* Initial font style           */
#define ASLFO_InitialFlags    ASL_TB+13  /* Initial font flags for TextAttr  */
#define ASLFO_InitialFrontPen ASL_TB+14  /* Initial front pen            */
#define ASLFO_InitialBackPen  ASL_TB+15  /* Initial back pen             */
#define ASLFO_InitialDrawMode ASL_TB+59  /* Initial draw mode            */

/* Options */
#define ASLFO_Flags       ASL_TB+20  /* Option flags             */
#define ASLFO_DoFrontPen      ASL_TB+44  /* Display Front color selector?    */
#define ASLFO_DoBackPen       ASL_TB+45  /* Display Back color selector?     */
#define ASLFO_DoStyle         ASL_TB+46  /* Display Style checkboxes?        */
#define ASLFO_DoDrawMode      ASL_TB+47  /* Display DrawMode cycle gadget?   */

/* Filtering */
#define ASLFO_FixedWidthOnly  ASL_TB+48  /* Only allow fixed-width fonts?    */
#define ASLFO_MinHeight       ASL_TB+16  /* Minimum font height to display   */
#define ASLFO_MaxHeight       ASL_TB+17  /* Maximum font height to display   */
#define ASLFO_FilterFunc      ASL_TB+49  /* Function to filter fonts         */
#define ASLFO_HookFunc        ASL_TB+7   /* Combined callback function       */
#define ASLFO_MaxFrontPen     ASL_TB+66  /* Max # of colors in front palette */
#define ASLFO_MaxBackPen      ASL_TB+67  /* Max # of colors in back palette  */

/* Custom additions */
#define ASLFO_ModeList        ASL_TB+21  /* Substitute list for drawmodes    */
#define ASLFO_FrontPens       ASL_TB+64  /* Color table for front pen palette*/
#define ASLFO_BackPens        ASL_TB+65  /* Color table for back pen palette */

/* Flag bits for ASLFO_Flags tag */
#define FOB_DOFRONTPEN     0
#define FOB_DOBACKPEN      1
#define FOB_DOSTYLE    2
#define FOB_DODRAWMODE     3
#define FOB_FIXEDWIDTHONLY 4
#define FOB_PRIVATEIDCMP   5
#define FOB_INTUIFUNC      6
#define FOB_FILTERFUNC     7

#define FOF_DOFRONTPEN     (1&)
#define FOF_DOBACKPEN      (2&)
#define FOF_DOSTYLE    (4&)
#define FOF_DODRAWMODE     (8&)
#define FOF_FIXEDWIDTHONLY (16&)
#define FOF_PRIVATEIDCMP   (32&)
#define FOF_INTUIFUNC      (64&)
#define FOF_FILTERFUNC     (128&)


/*****************************************************************************
 *
 * ASL Screen Mode Requester data structures and constants
 *
 * This structure must only be allocated by asl.library and is READ-ONLY!
 * Control of the various fields is provided via tags when the requester
 * is created with AllocAslRequest() and when it is displayed via
 * AslRequest()
 */
STRUCT ScreenModeRequester
 
    LONGINT sm_DisplayID     /* Display mode ID              */
    LONGINT sm_DisplayWidth      /* Width of display in pixels       */
    LONGINT sm_DisplayHeight     /* Height of display in pixels      */
    SHORTINT sm_DisplayDepth      /* Number of bit-planes of display  */
    SHORTINT sm_OverscanType      /* Type of overscan of display      */
    SHORTINT  sm_AutoScroll        /* Display should auto-scroll?      */

    LONGINT sm_BitMapWidth       /* Used to create your own BitMap   */
    LONGINT sm_BitMapHeight 

    SHORTINT  sm_LeftEdge          /* Coordinates of requester on exit */
    SHORTINT  sm_TopEdge 
    SHORTINT  sm_Width 
    SHORTINT  sm_Height 

    SHORTINT  sm_InfoOpened        /* Info window opened on exit?      */
    SHORTINT  sm_InfoLeftEdge      /* Last coordinates of Info window  */
    SHORTINT  sm_InfoTopEdge 
    SHORTINT  sm_InfoWidth 
    SHORTINT  sm_InfoHeight 

    ADDRESS  sm_UserData          /* You can store your own data here */
END STRUCT 

/* An Exec list of custom modes can be added to the list of available modes.
 * The DimensionInfo structure must be completely initialized,  including the
 * Header. See <graphics/displayinfo.h>. Custom mode ID's must be in the range
 * &HFFFF0000..&HFFFFFFFF. Regular properties which apply to your custom modes
 * can be added in the dn_PropertyFlags field. Custom properties are not
 * allowed.
 */
STRUCT DisplayMode
 
    Node dm_Node          /* see ln_Name           */
    DimensionInfo dm_DimensionInfo     /* mode description      */
    LONGINT        dm_PropertyFlags     /* applicable properties */
END STRUCT 

/* ScreenMode requester tag values,  used by AllocAslRequest() and AslRequest() */

/* Window control */
#define ASLSM_Window          ASL_TB+2   /* Parent window            */
#define ASLSM_Screen          ASL_TB+40  /* Screen to open on if no window   */
#define ASLSM_PubScreenName   ASL_TB+41  /* Name of public screen        */
#define ASLSM_PrivateIDCMP    ASL_TB+42  /* Allocate private IDCMP?      */
#define ASLSM_IntuiMsgFunc    ASL_TB+70  /* Function to handle IntuiMessages */
#define ASLSM_SleepWindow     ASL_TB+43  /* Block input in ASLSM_Window?     */
#define ASLSM_UserData        ASL_TB+52  /* What to put in sm_UserData       */

/* Text display */
#define ASLSM_TextAttr        ASL_TB+51  /* Text font to use for gadget text */
#define ASLSM_Locale          ASL_TB+50  /* Locale ASL should use for text   */
#define ASLSM_TitleText       ASL_TB+1   /* Title of requester           */
#define ASLSM_PositiveText    ASL_TB+18  /* Positive gadget text         */
#define ASLSM_NegativeText    ASL_TB+19  /* Negative gadget text         */

/* Initial settings */
#define ASLSM_InitialLeftEdge ASL_TB+3   /* Initial requester coordinates    */
#define ASLSM_InitialTopEdge  ASL_TB+4
#define ASLSM_InitialWidth    ASL_TB+5   /* Initial requester dimensions     */
#define ASLSM_InitialHeight   ASL_TB+6
#define ASLSM_InitialDisplayID     ASL_TB+100 /* Initial display mode id     */
#define ASLSM_InitialDisplayWidth  ASL_TB+101 /* Initial display width       */
#define ASLSM_InitialDisplayHeight ASL_TB+102 /* Initial display height      */
#define ASLSM_InitialDisplayDepth  ASL_TB+103 /* Initial display depth       */
#define ASLSM_InitialOverscanType  ASL_TB+104 /* Initial type of overscan    */
#define ASLSM_InitialAutoScroll    ASL_TB+105 /* Initial autoscroll setting  */
#define ASLSM_InitialInfoOpened    ASL_TB+106 /* Info wndw initially opened? */
#define ASLSM_InitialInfoLeftEdge  ASL_TB+107 /* Initial Info window coords. */
#define ASLSM_InitialInfoTopEdge   ASL_TB+108

/* Options */
#define ASLSM_DoWidth         ASL_TB+109  /* Display Width gadget?       */
#define ASLSM_DoHeight        ASL_TB+110  /* Display Height gadget?      */
#define ASLSM_DoDepth         ASL_TB+111  /* Display Depth gadget?       */
#define ASLSM_DoOverscanType  ASL_TB+112  /* Display Overscan Type gadget?   */
#define ASLSM_DoAutoScroll    ASL_TB+113  /* Display AutoScroll gadget?      */

/* Filtering */
#define ASLSM_PropertyFlags   ASL_TB+114  /* Must have these Property flags  */
#define ASLSM_PropertyMask    ASL_TB+115  /* Only these should be looked at  */
#define ASLSM_MinWidth        ASL_TB+116  /* Minimum display width to allow  */
#define ASLSM_MaxWidth        ASL_TB+117  /* Maximum display width to allow  */
#define ASLSM_MinHeight       ASL_TB+118  /* Minimum display height to allow */
#define ASLSM_MaxHeight       ASL_TB+119  /* Maximum display height to allow */
#define ASLSM_MinDepth        ASL_TB+120  /* Minimum display depth       */
#define ASLSM_MaxDepth        ASL_TB+121  /* Maximum display depth       */
#define ASLSM_FilterFunc      ASL_TB+122  /* Function to filter mode id's    */

/* Custom additions */
#define ASLSM_CustomSMList    ASL_TB+123  /* Exec list of STRUCT DisplayMode */


/*****************************************************************************
 *
 * Obsolete ASL definitions,  here for source code compatibility only.
 * Please do NOT use in new code.
 *
 * #define ASL_V38_NAMES_ONLY to remove these older names
 */
#ifndef ASL_V38_NAMES_ONLY
#define rf_File      fr_File
#define rf_Dir       fr_Drawer
#define rf_LeftEdge  fr_LeftEdge
#define rf_TopEdge   fr_TopEdge
#define rf_Width     fr_Width
#define rf_Height    fr_Height
#define rf_NumArgs   fr_NumArgs
#define rf_ArgList   fr_ArgList
#define rf_UserData  fr_UserData
#define rf_Pat       fr_Pattern
#define ASL_Dummy    (TAG_USER + &H80000)
#define ASL_Hail     ASL_Dummy+1
#define ASL_Window   ASL_Dummy+2
#define ASL_LeftEdge     ASL_Dummy+3
#define ASL_TopEdge  ASL_Dummy+4
#define ASL_Width    ASL_Dummy+5
#define ASL_Height   ASL_Dummy+6
#define ASL_HookFunc     ASL_Dummy+7
#define ASL_File     ASL_Dummy+8
#define ASL_Dir      ASL_Dummy+9
#define ASL_FontName     ASL_Dummy+10
#define ASL_FontHeight   ASL_Dummy+11
#define ASL_FontStyles   ASL_Dummy+12
#define ASL_FontFlags    ASL_Dummy+13
#define ASL_FrontPen     ASL_Dummy+14
#define ASL_BackPen  ASL_Dummy+15
#define ASL_MinHeight    ASL_Dummy+16
#define ASL_MaxHeight    ASL_Dummy+17
#define ASL_OKText   ASL_Dummy+18
#define ASL_CancelText   ASL_Dummy+19
#define ASL_FuncFlags    ASL_Dummy+20
#define ASL_ModeList     ASL_Dummy+21
#define ASL_ExtFlags1    ASL_Dummy+22
#define ASL_Pattern  ASL_FontName
/* remember what I said up there? Do not use these anymore! */
#define FILB_DOWILDFUNC  7L
#define FILB_DOMSGFUNC   6L
#define FILB_SAVE    5L
#define FILB_NEWIDCMP    4L
#define FILB_MULTISELECT 3L
#define FILB_PATGAD  0L
#define FILF_DOWILDFUNC  (128&)
#define FILF_DOMSGFUNC   (64&)
#define FILF_SAVE    (32&)
#define FILF_NEWIDCMP    (16&)
#define FILF_MULTISELECT (8&)
#define FILF_PATGAD  (1&)
#define FIL1B_NOFILES    0L
#define FIL1B_MATCHDIRS  1L
#define FIL1F_NOFILES    (1&)
#define FIL1F_MATCHDIRS  (2&)
#define FONB_FRONTCOLOR 0
#define FONB_BACKCOLOR  1
#define FONB_STYLES 2
#define FONB_DRAWMODE   3
#define FONB_FIXEDWIDTH 4
#define FONB_NEWIDCMP   5
#define FONB_DOMSGFUNC  6
#define FONB_DOWILDFUNC 7
#define FONF_FRONTCOLOR (1&)
#define FONF_BACKCOLOR  (2&)
#define FONF_STYLES     (4&)
#define FONF_DRAWMODE   (8&)
#define FONF_FIXEDWIDTH (16&)
#define FONF_NEWIDCMP   (32&)
#define FONF_DOMSGFUNC  (64&)
#define FONF_DOWILDFUNC (128)
#endif


/*****************************************************************************/


#endif /* LIBRARIES_ASL_H */
