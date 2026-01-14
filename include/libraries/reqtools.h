#ifndef LIBRARIES_REQTOOLS_H
#define LIBRARIES_REQTOOLS_H
/*
** reqtools.h for ACE Basic
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
** This are the StructPointer defines for reqtools.h
*/
#ifndef ReqDefaultsPtr
#define ReqDefaultsPtr ADDRESS
#endif
#ifndef ReqToolsBasePtr
#define ReqToolsBasePtr ADDRESS
#endif
#ifndef ReqToolsPrefsPtr
#define ReqToolsPrefsPtr ADDRESS
#endif
#ifndef rtFileListPtr
#define rtFileListPtr ADDRESS
#endif
#ifndef rtFileRequesterPtr
#define rtFileRequesterPtr ADDRESS
#endif
#ifndef rtFontRequesterPtr
#define rtFontRequesterPtr ADDRESS
#endif
#ifndef rtHandlerInfoPtr
#define rtHandlerInfoPtr ADDRESS
#endif
#ifndef rtReqInfoPtr
#define rtReqInfoPtr ADDRESS
#endif
#ifndef rtScreenModeRequesterPtr
#define rtScreenModeRequesterPtr ADDRESS
#endif
#ifndef rtVolumeEntryPtr
#define rtVolumeEntryPtr ADDRESS
#endif
/*
** End of StructPointer defines for reqtools.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif  /* EXEC_TYPES_H */

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif  /* EXEC_LISTS_H */

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif  /* EXEC_LIBRARIES_H */

#ifndef EXEC_SEMAPHORES_H
#include <exec/semaphores.h>
#endif  /* EXEC_SEMAPHORES_H */

#ifndef LIBRARIES_DOS_H
#include <libraries/dos.h>
#endif  /* LIBRARIES_DOS_H */

#ifndef LIBRARIES_DOSEXTENS_H
#include <libraries/dosextens.h>
#endif  /* LIBRARIES_DOSEXTENS_H */

#ifndef LIBRARIES_DISKFONT_H
#include <libraries/diskfont.h>
#endif  /* LIBRARIES_DISKFONT_H */

#ifndef GRAPHICS_TEXT_H
#include <graphics/text.h>
#endif  /* GRAPHICS_TEXT_H */

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif  /* UTILITY_TAGITEM_H */

#define REQTOOLSNAME         "reqtools.library"
#define REQTOOLSVERSION      38&

/***********************
*                      *
*     Preferences      *
*                      *
***********************/

#define RTPREF_FILEREQ       0&
#define RTPREF_FONTREQ       1&
#define RTPREF_PALETTEREQ    2&
#define RTPREF_SCREENMODEREQ     3&
#define RTPREF_VOLUMEREQ     4&
#define RTPREF_OTHERREQ      5&
#define RTPREF_NR_OF_REQ     6&

STRUCT ReqDefaults  
   LONGINT _Size 
   LONGINT ReqPos 
   SHORTINT LeftOffset 
   SHORTINT TopOffset 
   SHORTINT MinEntries 
   SHORTINT MaxEntries 
END STRUCT 

STRUCT ReqToolsPrefs  
   /* Size of preferences (_without_ this field and the semaphore) */
   LONGINT PrefsSize 
   SignalSemaphore PrefsSemaphore 
   /* Start of real preferences */
   LONGINT Flags 
   STRING ReqDefaults0 SIZE 96   /* RTPREF_NR_OF_REQ*16 */
END STRUCT 

#define RTPREFS_SIZE \
   (SIZEOF(ReqToolsPrefs) - SIZEOF(SignalSemaphore) - 4)

/* Flags */

#define RTPRB_DIRSFIRST      0&
#define RTPRF_DIRSFIRST      (1&)
#define RTPRB_DIRSMIXED      1&
#define RTPRF_DIRSMIXED      (2&)
#define RTPRB_IMMSORT        2&
#define RTPRF_IMMSORT        (4&)
#define RTPRB_NOSCRTOFRONT   3&
#define RTPRF_NOSCRTOFRONT   (8&)
#define RTPRB_NOLED      4&
#define RTPRF_NOLED      (16&)
#define RTPRB_DEFAULTFONT    5&
#define RTPRF_DEFAULTFONT    (32&)

/***********************
*                      *
*     Library Base     *
*                      *
***********************/

STRUCT ReqToolsBase  
   _Library LibNode 
   BYTE  RTFlags 
   STRING pad SIZE 3  
   ADDRESS SegList 

   /* PUBLIC FIELDS */

   /* NOTE: Some versions of the Manx C compiler contain a bug so it gets
            confused by the library bases below.  Add the rt_ prefix to the
            _library names to fix the problem (e.g. rt_IntuitionBase). */

   /* The following library bases may be read and used by your program */
   IntuitionBasePtr  IntuitionBase 
   GfxBasePtr  GfxBase 
   DosLibraryPtr  DOSBase 
   /* Next two library bases are only (and always) valid on Kickstart 2.0!
      (1.3 version of reqtools also initializes these when run on 2.0) */
   LibraryPtr  GadToolsBase 
   LibraryPtr  UtilityBase 

   /* PRIVATE FIELDS,   THESE WILL CHANGE FROM RELEASE TO RELEASE! */

   /* The RealOpenCnt is for the buffered AvailFonts feature.  Since
      Kickstart 3.0 offers low memory handlers a release of ReqTools for 3.0
      will _not use this field and start using the normal OpenCnt again. */
   SHORTINT RealOpenCnt 
   SHORTINT AvailFontsLock 
   AvailFontsHeaderPtr  AvailFontsHeader 
   LONGINT FontsAssignType 
   ADDRESS FontsAssignLock 
   AssignListPtr  FontsAssignList 
   ReqToolsPrefs ReqToolsPrefs 
   SHORTINT prefspad 
END STRUCT 

/* types of requesters,   for rtAllocRequestA() */
#define RT_FILEREQ       0&
#define RT_REQINFO       1&
#define RT_FONTREQ       2&
/* (V38) */
#define RT_SCREENMODEREQ     3&

/***********************
*                      *
*    File requester    *
*                      *
***********************/

/* structure _MUST_ be allocated with rtAllocRequest() */

STRUCT rtFileRequester  
   LONGINT ReqPos 
   SHORTINT LeftOffset 
   SHORTINT TopOffset 
   LONGINT Flags 
   /* OBSOLETE IN V38! DON'T USE! */
   HookPtr Hook_
   /* */
   ADDRESS   Dir            /* READ ONLY! Change with rtChangeReqAttrA()! */
   ADDRESS   MatchPat       /* READ ONLY! Change with rtChangeReqAttrA()! */
   /* */
   TextFontPtr  DefaultFont 
   LONGINT WaitPointer 
   /* (V38) */
   LONGINT LockWindow 
   LONGINT ShareIDCMP 
   HookPtr  IntuiMsgFunc 
   SHORTINT reserved1 
   SHORTINT reserved2 
   SHORTINT reserved3 
   SHORTINT ReqHeight       /* READ ONLY!  Use RTFI_Height tag! */
   /* Private data follows! HANDS OFF :-) */
END STRUCT 

/* returned by rtFileRequestA() if multiselect is enabled,  
   free _list with rtFreeFileList() */

STRUCT rtFileList  
   rtFileListPtr  _Next 
   LONGINT StrLen          /* -1 for directories */
   ADDRESS   _Name 
END STRUCT 

/* structure passed to RTFI_FilterFunc callback hook by
   volume requester (see RTFI_VolumeRequest tag) */

STRUCT rtVolumeEntry  
   LONGINT _Type            /* DLT_DEVICE or DLT_DIRECTORY */
   ADDRESS   _Name 
END STRUCT 

/***********************
*                      *
*    Font requester    *
*                      *
***********************/

/* structure _MUST_ be allocated with rtAllocRequest() */

STRUCT rtFontRequester  
   LONGINT ReqPos 
   SHORTINT LeftOffset 
   SHORTINT TopOffset 
   LONGINT Flags 
   /* OBSOLETE IN V38! DON'T USE! */
   HookPtr Hook_
   /* */
   TextAttr Attr      /* READ ONLY! */
   /* */
   TextFontPtr  DefaultFont 
   LONGINT WaitPointer 
   /* (V38) */
   LONGINT LockWindow 
   LONGINT ShareIDCMP 
   HookPtr  IntuiMsgFunc 
   SHORTINT reserved1 
   SHORTINT reserved2 
   SHORTINT reserved3 
   SHORTINT ReqHeight       /* READ ONLY!  Use RTFO_Height tag! */
   /* Private data follows! HANDS OFF :-) */
END STRUCT 

/*************************
*                        *
*  ScreenMode requester  *
*                        *
*************************/

/* structure _MUST_ be allocated with rtAllocRequest() */

STRUCT rtScreenModeRequester  
   LONGINT ReqPos 
   SHORTINT LeftOffset 
   SHORTINT TopOffset 
   LONGINT Flags 
   LONGINT private1 
   /* */
   LONGINT DisplayID       /* READ ONLY! */
   SHORTINT DisplayWidth        /* READ ONLY! */
   SHORTINT DisplayHeight       /* READ ONLY! */
   /* */
   TextFontPtr  DefaultFont 
   LONGINT WaitPointer 
   LONGINT LockWindow 
   LONGINT ShareIDCMP 
   HookPtr  IntuiMsgFunc 
   SHORTINT reserved1 
   SHORTINT reserved2 
   SHORTINT reserved3 
   SHORTINT ReqHeight       /* READ ONLY!  Use RTSC_Height tag! */
   /* */
   SHORTINT DisplayDepth        /* READ ONLY! */
   SHORTINT OverscanType        /* READ ONLY! */
   LONGINT AutoScroll          /* READ ONLY! */
   /* Private data follows! HANDS OFF :-) */
END STRUCT 

/***********************
*                      *
*    Requester Info    *
*                      *
***********************/

/* for rtEZRequestA(),   rtGetLongA(),   rtGetStringA() and rtPaletteRequestA(),  
   _MUST_ be allocated with rtAllocRequest() */

STRUCT rtReqInfo  
   LONGINT ReqPos 
   SHORTINT LeftOffset 
   SHORTINT TopOffset 
   LONGINT _Width           /* not for rtEZRequestA() */
   ADDRESS   ReqTitle        /* currently only for rtEZRequestA() */
   LONGINT Flags 
   TextFontPtr  DefaultFont  /* currently only for rtPaletteRequestA() */
   LONGINT WaitPointer 
   /* (V38) */
   LONGINT LockWindow 
   LONGINT ShareIDCMP 
   HookPtr  IntuiMsgFunc 
   /* structure may be extended in future */
END STRUCT 

/***********************
*                      *
*     Handler Info     *
*                      *
***********************/

/* for rtReqHandlerA(),   will be allocated for you when you use
   the RT_ReqHandler tag,   never try to allocate this yourself! */

STRUCT rtHandlerInfo  
   LONGINT private1 
   LONGINT WaitMask 
   LONGINT DoNotWait 
   /* Private data follows,   HANDS OFF :-) */
END STRUCT 

/* possible return codes from rtReqHandlerA() */

#define CALL_HANDLER         &H80000000&


/*************************************
*                                    *
*                TAGS                *
*                                    *
*************************************/

#define RT_TagBase       TAG_USER

/*** tags understood by most requester functions ***
*/
/* optional pointer to window */
#define RT_Window        (RT_TagBase+1)
/* idcmp flags requester should abort on (useful for IDCMP_DISKINSERTED) */
#define RT_IDCMPFlags        (RT_TagBase+2)
/* position of requester window (see below) - default REQPOS_POINTER */
#define RT_ReqPos        (RT_TagBase+3)
/* leftedge offset of requester relative to position specified by RT_ReqPos */
#define RT_LeftOffset        (RT_TagBase+4)
/* topedge offset of requester relative to position specified by RT_ReqPos */
#define RT_TopOffset         (RT_TagBase+5)
/* name of public screen to put requester on (Kickstart 2.0 only!) */
#define RT_PubScrName        (RT_TagBase+6)
/* address of screen to put requester on */
#define RT_Screen        (RT_TagBase+7)
/* tagdata must hold the address of (!) an ADDRESS variable */
#define RT_ReqHandler        (RT_TagBase+8)
/* font to use when screen font is rejected,   _MUST_ be fixed-width font!
   (STRUCT TextFont *,   not STRUCT TextAttr *!)
   - default GfxBase->DefaultFont */
#define RT_DefaultFont       (RT_TagBase+9)
/* boolean to set the standard wait pointer in window - default FALSE */
#define RT_WaitPointer       (RT_TagBase+10)
/* (V38) BYTE preceding keyboard shortcut characters (will be underlined) */
#define RT_Underscore        (RT_TagBase+11)
/* (V38) share IDCMP port with window - default FALSE */
#define RT_ShareIDCMP        (RT_TagBase+12)
/* (V38) lock window and set standard wait pointer - default FALSE */
#define RT_LockWindow        (RT_TagBase+13)
/* (V38) boolean to make requester's screen pop to front - default TRUE */
#define RT_ScreenToFront     (RT_TagBase+14)
/* (V38) Requester should use this font - default: screen font */
#define RT_TextAttr      (RT_TagBase+15)
/* (V38) call this hook for every IDCMP message not for requester */
#define RT_IntuiMsgFunc      (RT_TagBase+16)
/* (V38) Locale ReqTools should use for text */
#define RT_Locale        (RT_TagBase+17)

/*** tags specific to rtEZRequestA ***
*/
/* title of requester window - english default "Request" or "Information" */
#define RTEZ_ReqTitle        (RT_TagBase+20)
/* (RT_TagBase+21) reserved */
/* various flags (see below) */
#define RTEZ_Flags       (RT_TagBase+22)
/* default response (activated by pressing RETURN) - default TRUE */
#define RTEZ_DefaultResponse     (RT_TagBase+23)

/*** tags specific to rtGetLongA ***
*/
/* minimum allowed value - default MININT */
#define RTGL_Min         (RT_TagBase+30)
/* maximum allowed value - default MAXINT */
#define RTGL_Max         (RT_TagBase+31)
/* suggested width of requester window (in pixels) */
#define RTGL_Width       (RT_TagBase+32)
/* boolean to show the default value - default TRUE */
#define RTGL_ShowDefault     (RT_TagBase+33)
/* (V38) string with possible responses - english default " _Ok |_Cancel" */
#define RTGL_GadFmt          (RT_TagBase+34)
/* (V38) optional arguments for RTGL_GadFmt */
#define RTGL_GadFmtArgs      (RT_TagBase+35)
/* (V38) invisible typing - default FALSE */
#define RTGL_Invisible       (RT_TagBase+36)
/* (V38) window backfill - default TRUE */
#define RTGL_BackFill        (RT_TagBase+37)
/* (V38) optional text above gadget */
#define RTGL_TextFmt         (RT_TagBase+38)
/* (V38) optional arguments for RTGS_TextFmt */
#define RTGL_TextFmtArgs     (RT_TagBase+39)
/* (V38) various flags (see below) */
#define RTGL_Flags       RTEZ_Flags

/*** tags specific to rtGetStringA ***
*/
/* suggested width of requester window (in pixels) */
#define RTGS_Width       RTGL_Width
/* allow empty string to be accepted - default FALSE */
#define RTGS_AllowEmpty      (RT_TagBase+80)
/* (V38) string with possible responses - english default " _Ok |_Cancel" */
#define RTGS_GadFmt          RTGL_GadFmt
/* (V38) optional arguments for RTGS_GadFmt */
#define RTGS_GadFmtArgs      RTGL_GadFmtArgs
/* (V38) invisible typing - default FALSE */
#define RTGS_Invisible       RTGL_Invisible
/* (V38) window backfill - default TRUE */
#define RTGS_BackFill        RTGL_BackFill
/* (V38) optional text above gadget */
#define RTGS_TextFmt         RTGL_TextFmt
/* (V38) optional arguments for RTGS_TextFmt */
#define RTGS_TextFmtArgs     RTGL_TextFmtArgs
/* (V38) various flags (see below) */
#define RTGS_Flags       RTEZ_Flags

/*** tags specific to rtFileRequestA ***
*/
/* various flags (see below) */
#define RTFI_Flags       (RT_TagBase+40)
/* suggested height of file requester */
#define RTFI_Height      (RT_TagBase+41)
/* replacement text for 'Ok' gadget (max 6 chars) */
#define RTFI_OkText      (RT_TagBase+42)
/* (V38) bring up volume requester,   tag data holds flags (see below) */
#define RTFI_VolumeRequest   (RT_TagBase+43)
/* (V38) call this hook for every file in the directory */
#define RTFI_FilterFunc      (RT_TagBase+44)
/* (V38) allow empty file to be accepted - default FALSE */
#define RTFI_AllowEmpty      (RT_TagBase+45)

/*** tags specific to rtFontRequestA ***
*/
/* various flags (see below) */
#define RTFO_Flags       RTFI_Flags
/* suggested height of font requester */
#define RTFO_Height      RTFI_Height
/* replacement text for 'Ok' gadget (max 6 chars) */
#define RTFO_OkText      RTFI_OkText
/* suggested height of font sample display - default 24 */
#define RTFO_SampleHeight    (RT_TagBase+60)
/* minimum height of font displayed */
#define RTFO_MinHeight       (RT_TagBase+61)
/* maximum height of font displayed */
#define RTFO_MaxHeight       (RT_TagBase+62)
/* [(RT_TagBase+63) to (RT_TagBase+66) used below] */
/* (V38) call this hook for every font */
#define RTFO_FilterFunc      RTFI_FilterFunc

/*** (V38) tags for rtScreenModeRequestA ***
*/
/* various flags (see below) */
#define RTSC_Flags       RTFI_Flags
/* suggested height of screenmode requester */
#define RTSC_Height      RTFI_Height
/* replacement text for 'Ok' gadget (max 6 chars) */
#define RTSC_OkText      RTFI_OkText
/* property flags (see also RTSC_PropertyMask) */
#define RTSC_PropertyFlags   (RT_TagBase+90)
/* property mask - default all bits in RTSC_PropertyFlags considered */
#define RTSC_PropertyMask    (RT_TagBase+91)
/* minimum display width allowed */
#define RTSC_MinWidth        (RT_TagBase+92)
/* maximum display width allowed */
#define RTSC_MaxWidth        (RT_TagBase+93)
/* minimum display height allowed */
#define RTSC_MinHeight       (RT_TagBase+94)
/* maximum display height allowed */
#define RTSC_MaxHeight       (RT_TagBase+95)
/* minimum display depth allowed */
#define RTSC_MinDepth        (RT_TagBase+96)
/* maximum display depth allowed */
#define RTSC_MaxDepth        (RT_TagBase+97)
/* call this hook for every display mode id */
#define RTSC_FilterFunc      RTFI_FilterFunc

/*** tags for rtChangeReqAttrA ***
*/
/* file requester - set directory */
#define RTFI_Dir         (RT_TagBase+50)
/* file requester - set wildcard pattern */
#define RTFI_MatchPat        (RT_TagBase+51)
/* file requester - add a file or directory to the buffer */
#define RTFI_AddEntry        (RT_TagBase+52)
/* file requester - remove a file or directory from the buffer */
#define RTFI_RemoveEntry     (RT_TagBase+53)
/* font requester - set font name of selected font */
#define RTFO_FontName        (RT_TagBase+63)
/* font requester - set font size */
#define RTFO_FontHeight      (RT_TagBase+64)
/* font requester - set font style */
#define RTFO_FontStyle       (RT_TagBase+65)
/* font requester - set font flags */
#define RTFO_FontFlags       (RT_TagBase+66)
/* (V38) screenmode requester - get display attributes from screen */
#define RTSC_ModeFromScreen  (RT_TagBase+80)
/* (V38) screenmode requester - set display mode id (32-bit extended) */
#define RTSC_DisplayID       (RT_TagBase+81)
/* (V38) screenmode requester - set display width */
#define RTSC_DisplayWidth    (RT_TagBase+82)
/* (V38) screenmode requester - set display height */
#define RTSC_DisplayHeight   (RT_TagBase+83)
/* (V38) screenmode requester - set display depth */
#define RTSC_DisplayDepth    (RT_TagBase+84)
/* (V38) screenmode requester - set overscan type,   0 for regular size */
#define RTSC_OverscanType    (RT_TagBase+85)
/* (V38) screenmode requester - set autoscroll */
#define RTSC_AutoScroll      (RT_TagBase+86)

/*** tags for rtPaletteRequestA ***
*/
/* initially selected color - default 1 */
#define RTPA_Color       (RT_TagBase+70)

/*** tags for rtReqHandlerA ***
*/
/* end requester by software control,   set tagdata to REQ_CANCEL,   REQ_OK or
   in _case of rtEZRequest to the return value */
#define RTRH_EndRequest      (RT_TagBase+60)

/*** tags for rtAllocRequestA ***/
/* no tags defined yet */


/************
* RT_ReqPos *
************/
#define REQPOS_POINTER       0&
#define REQPOS_CENTERWIN     1&
#define REQPOS_CENTERSCR     2&
#define REQPOS_TOPLEFTWIN    3&
#define REQPOS_TOPLEFTSCR    4&

/******************
* RTRH_EndRequest *
******************/
#define REQ_CANCEL       0&
#define REQ_OK           1&

/***************************************
* flags for RTFI_Flags and RTFO_Flags  *
* or filereq->Flags and fontreq->Flags *
***************************************/
#define FREQB_NOBUFFER       2&
#define FREQF_NOBUFFER       (4&)

/*****************************************
* flags for RTFI_Flags or filereq->Flags *
*****************************************/
#define FREQB_MULTISELECT    0&
#define FREQF_MULTISELECT    (1&)
#define FREQB_SAVE       1&
#define FREQF_SAVE       (2&)
#define FREQB_NOFILES        3&
#define FREQF_NOFILES        (8&)
#define FREQB_PATGAD         4&
#define FREQF_PATGAD         (16&)
#define FREQB_SELECTDIRS     12&
#define FREQF_SELECTDIRS     (4096&)

/*****************************************
* flags for RTFO_Flags or fontreq->Flags *
*****************************************/
#define FREQB_FIXEDWIDTH     5&
#define FREQF_FIXEDWIDTH     (32&)
#define FREQB_COLORFONTS     6&
#define FREQF_COLORFONTS     (64&)
#define FREQB_CHANGEPALETTE  7&
#define FREQF_CHANGEPALETTE  (128&)
#define FREQB_LEAVEPALETTE   8&
#define FREQF_LEAVEPALETTE   (256&)
#define FREQB_SCALE      9&
#define FREQF_SCALE      (512&)
#define FREQB_STYLE      10&
#define FREQF_STYLE      (1024&)

/*****************************************************
* (V38) flags for RTSC_Flags or screenmodereq->Flags *
*****************************************************/
#define SCREQB_SIZEGADS      13&
#define SCREQF_SIZEGADS      (8192&)
#define SCREQB_DEPTHGAD      14&
#define SCREQF_DEPTHGAD      (16384&)
#define SCREQB_NONSTDMODES   15&
#define SCREQF_NONSTDMODES   (32768&)
#define SCREQB_GUIMODES      16&
#define SCREQF_GUIMODES      (65536&)
#define SCREQB_AUTOSCROLLGAD     18&
#define SCREQF_AUTOSCROLLGAD     (262144&)
#define SCREQB_OVERSCANGAD   19&
#define SCREQF_OVERSCANGAD   (524288&)

/*****************************************
* flags for RTEZ_Flags or reqinfo->Flags *
*****************************************/
#define EZREQB_NORETURNKEY   0&
#define EZREQF_NORETURNKEY   (1&)
#define EZREQB_LAMIGAQUAL    1&
#define EZREQF_LAMIGAQUAL    (2&)
#define EZREQB_CENTERTEXT    2&
#define EZREQF_CENTERTEXT    (4&)

/***********************************************
* (V38) flags for RTGL_Flags or reqinfo->Flags *
***********************************************/
#define GLREQB_CENTERTEXT    EZREQB_CENTERTEXT
#define GLREQF_CENTERTEXT    EZREQF_CENTERTEXT
#define GLREQB_HIGHLIGHTTEXT     3&
#define GLREQF_HIGHLIGHTTEXT     (8&)

/***********************************************
* (V38) flags for RTGS_Flags or reqinfo->Flags *
***********************************************/
#define GSREQB_CENTERTEXT    EZREQB_CENTERTEXT
#define GSREQF_CENTERTEXT    EZREQF_CENTERTEXT
#define GSREQB_HIGHLIGHTTEXT     GLREQB_HIGHLIGHTTEXT
#define GSREQF_HIGHLIGHTTEXT     GLREQF_HIGHLIGHTTEXT

/*****************************************
* (V38) flags for RTFI_VolumeRequest tag *
*****************************************/
#define VREQB_NOASSIGNS      0&
#define VREQF_NOASSIGNS      (1&)
#define VREQB_NODISKS        1&
#define VREQF_NODISKS        (2&)
#define VREQB_ALLDISKS       2&
#define VREQF_ALLDISKS       (4&)

/*
   Following things are obsolete in ReqTools V38.
   DON'T USE THESE IN NEW CODE!
*/
#ifndef NO_REQTOOLS_OBSOLETE
#define REQHOOK_WILDFILE 0&
#define REQHOOK_WILDFONT 1&
#define FREQB_DOWILDFUNC 11&
#define FREQF_DOWILDFUNC (2048&)
#endif



#endif /* LIBRARIES_REQTOOLS_H */
