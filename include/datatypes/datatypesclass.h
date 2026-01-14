#ifndef DATATYPES_DATATYPESCLASS_H
#define DATATYPES_DATATYPESCLASS_H 1
/*
** datatypesclass.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/02/95
**
**
*/

/*
** This are the StructPointer defines for datatypesclass.h
*/
#ifndef DTMethodPtr
#define DTMethodPtr ADDRESS
#endif
#ifndef DTSpecialInfoPtr
#define DTSpecialInfoPtr ADDRESS
#endif
#ifndef FrameInfoPtr
#define FrameInfoPtr ADDRESS
#endif
#ifndef dtDrawPtr
#define dtDrawPtr ADDRESS
#endif
#ifndef dtFrameBoxPtr
#define dtFrameBoxPtr ADDRESS
#endif
#ifndef dtGeneralPtr
#define dtGeneralPtr ADDRESS
#endif
#ifndef dtGotoPtr
#define dtGotoPtr ADDRESS
#endif
#ifndef dtPrintPtr
#define dtPrintPtr ADDRESS
#endif
#ifndef dtSelectPtr
#define dtSelectPtr ADDRESS
#endif
#ifndef dtTriggerPtr
#define dtTriggerPtr ADDRESS
#endif
#ifndef dtWritePtr
#define dtWritePtr ADDRESS
#endif
#ifndef fri_Dimensions_StructPtr
#define fri_Dimensions_StructPtr ADDRESS
#endif
#ifndef printerIOPtr
#define printerIOPtr ADDRESS
#endif
/*
** End of StructPointer defines for datatypesclass.h
*/
               

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef DATATYPES_DATATYPES_H
#include <datatypes/datatypes.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef DEVICES_PRINTER_H
#include <devices/printer.h>
#endif

#ifndef DEVICES_PRTBASE_H
#include <devices/prtbase.h>
#endif


/*****************************************************************************/

#define DATATYPESCLASS      "datatypesclass"

/*****************************************************************************/

#define DTA_Dummy       (TAG_USER+&H1000)

/* Generic attributes */
#define DTA_TextAttr        (DTA_Dummy+10)
    /* (STRUCT TextAttr *) Pointer to the default TextAttr to use for
     * the text within the object. */

#define DTA_TopVert     (DTA_Dummy+11)
    /* (LONGINT) Current top vertical unit */

#define DTA_VisibleVert     (DTA_Dummy+12)
    /* (LONGINT) Number of visible vertical units */

#define DTA_TotalVert       (DTA_Dummy+13)
    /* (LONGINT) Total number of vertical units */

#define DTA_VertUnit        (DTA_Dummy+14)
    /* (LONGINT) Number of pixels per vertical unit */

#define DTA_TopHoriz        (DTA_Dummy+15)
    /* (LONGINT) Current top horizontal unit */

#define DTA_VisibleHoriz    (DTA_Dummy+16)
    /* (LONGINT)  Number of visible horizontal units */

#define DTA_TotalHoriz      (DTA_Dummy+17)
    /* (LONGINT) Total number of horizontal units */

#define DTA_HorizUnit       (DTA_Dummy+18)
    /* (LONGINT) Number of pixels per horizontal unit */

#define DTA_NodeName        (DTA_Dummy+19)
    /* (BYTE  *) Name of the current element within the object. */

#define DTA_Title       (DTA_Dummy+20)
    /* (BYTE  *) Title of the object. */

#define DTA_TriggerMethods  (DTA_Dummy+21)
    /* (STRUCT DTMethod *) Pointer to a NULL terminated array of
     * supported trigger methods. */

#define DTA_Data        (DTA_Dummy+22)
    /* (ADDRESS) Object specific data. */

#define DTA_TextFont        (DTA_Dummy+23)
    /* (STRUCT TextFont *) Default font to use for text within the
     * object. */

#define DTA_Methods     (DTA_Dummy+24)
    /* (LONGINT *) Pointer to a ~0 terminated array of supported
     * methods. */

#define DTA_PrinterStatus   (DTA_Dummy+25)
    /* (LONGINT) Printer error message.  Error numbers are defined in
     * <devices/printer.h> */

#define DTA_PrinterProc     (DTA_Dummy+26)
    /* PRIVATE (STRUCT Process *) Pointer to the print process. */

#define DTA_LayoutProc      (DTA_Dummy+27)
    /* PRIVATE (STRUCT Process *) Pointer to the layout process. */

#define DTA_Busy        (DTA_Dummy+28)
    /* Used to turn the applications' busy pointer off and on */

#define DTA_Sync        (DTA_Dummy+29)
    /* Used to indicate that new information has been loaded into
     * an object.  This is for models that cache the DTA_TopVert-
     * like tags */

#define DTA_BaseName        (DTA_Dummy+30)
    /* The base name of the class */

#define DTA_GroupID     (DTA_Dummy+31)
    /* Group that the object must belong in */

#define DTA_ErrorLevel      (DTA_Dummy+32)
    /* Error level */

#define DTA_ErrorNumber     (DTA_Dummy+33)
    /* datatypes.library error number */

#define DTA_ErrorString     (DTA_Dummy+34)
    /* Argument for datatypes.library error */

#define DTA_Conductor       (DTA_Dummy+35)
    /* New for V40. (BYTE  *) specifies the name of the
     * realtime.library conductor.  Defaults to "Main". */

#define DTA_ControlPanel    (DTA_Dummy+36)
    /* New for V40. (SHORTINT) Indicate whether a control panel should be
     * embedded within the object (in the animation datatype,  for
     * example).  Defaults to TRUE. */

#define DTA_Immediate       (DTA_Dummy+37)
    /* New for V40. (SHORTINT) Indicate whether the object should
     * immediately begin playing.  Defaults to FALSE. */

#define DTA_Repeat      (DTA_Dummy+38)
    /* New for V40. (SHORTINT) Indicate that the object should repeat
     * playing.  Defaults to FALSE. */


/* DTObject attributes */
#define DTA_Name        (DTA_Dummy+100)
#define DTA_SourceType      (DTA_Dummy+101)
#define DTA_Handle      (DTA_Dummy+102)
#define DTA_DataType        (DTA_Dummy+103)
#define DTA_Domain      (DTA_Dummy+104)

/* DON'T USE THE FOLLOWING FOUR TAGS.  USE THE CORRESPONDING TAGS IN
 * <intuition/gadgetclass.h> */
#define DTA_Left        (DTA_Dummy+105)
#define DTA_Top         (DTA_Dummy+106)
#define DTA_Width       (DTA_Dummy+107)
#define DTA_Height      (DTA_Dummy+108)

#define DTA_ObjName     (DTA_Dummy+109)
#define DTA_ObjAuthor       (DTA_Dummy+110)
#define DTA_ObjAnnotation   (DTA_Dummy+111)
#define DTA_ObjCopyright    (DTA_Dummy+112)
#define DTA_ObjVersion      (DTA_Dummy+113)
#define DTA_ObjectID        (DTA_Dummy+114)
#define DTA_UserData        (DTA_Dummy+115)
#define DTA_FrameInfo       (DTA_Dummy+116)

/* DON'T USE THE FOLLOWING FOUR TAGS.  USE THE CORRESPONDING TAGS IN
 * <intuition/gadgetclass.h> */
#define DTA_RelRight        (DTA_Dummy+117)
#define DTA_RelBottom       (DTA_Dummy+118)
#define DTA_RelWidth        (DTA_Dummy+119)
#define DTA_RelHeight       (DTA_Dummy+120)

#define DTA_SelectDomain    (DTA_Dummy+121)
#define DTA_TotalPVert      (DTA_Dummy+122)
#define DTA_TotalPHoriz     (DTA_Dummy+123)
#define DTA_NominalVert     (DTA_Dummy+124)
#define DTA_NominalHoriz    (DTA_Dummy+125)

/* Printing attributes */
#define DTA_DestCols        (DTA_Dummy+400)
    /* (LONGINT) Destination X width */

#define DTA_DestRows        (DTA_Dummy+401)
    /* (LONGINT) Destination Y height */

#define DTA_Special     (DTA_Dummy+402)
    /* (SHORTINT) Option flags */

#define DTA_RastPort        (DTA_Dummy+403)
    /* (STRUCT RastPort *) RastPort to use when printing. (V40) */

#define DTA_ARexxPortName   (DTA_Dummy+404)
    /* (ADDRESS) Pointer to base name for ARexx port (V40) */


/*****************************************************************************/

#define DTST_RAM        1
#define DTST_FILE       2
#define DTST_CLIPBOARD      3
#define DTST_HOTLINK        4

/*****************************************************************************/

/* Attached to the Gadget.SpecialInfo field of the gadget.  Don't access directly, 
 * use the Get/Set calls instead.
 */
STRUCT DTSpecialInfo
 
    SignalSemaphore si_Lock    /* Locked while in DoAsyncLayout() */
    LONGINT            si_Flags 

    LONGINT             si_TopVert     /* Top row (in units) */
    LONGINT             si_VisVert     /* Number of visible rows (in units) */
    LONGINT             si_TotVert     /* Total number of rows (in units) */
    LONGINT             si_OTopVert    /* Previous top (in units) */
    LONGINT             si_VertUnit    /* Number of pixels in vertical unit */

    LONGINT             si_TopHoriz    /* Top column (in units) */
    LONGINT             si_VisHoriz    /* Number of visible columns (in units) */
    LONGINT             si_TotHoriz    /* Total number of columns (in units) */
    LONGINT             si_OTopHoriz   /* Previous top (in units) */
    LONGINT             si_HorizUnit   /* Number of pixels in horizontal unit */
END STRUCT 


/* Object is in layout processing */
#define DTSIF_LAYOUT        (1&)

/* Object needs to be layed out */
#define DTSIF_NEWSIZE       (2&)

#define DTSIF_DRAGGING      (4&)
#define DTSIF_DRAGSELECT    (8&)

#define DTSIF_HIGHLIGHT     (16&)

/* Object is being printed */
#define DTSIF_PRINTING      (32&)

/* Object is in layout process */
#define DTSIF_LAYOUTPROC    (64&)

/*****************************************************************************/

STRUCT DTMethod
 
    ADDRESS   dtm_Label 
    ADDRESS   dtm_Command 
    LONGINT    dtm_Method 
END STRUCT 

/*****************************************************************************/

#define DTM_Dummy       (&H600)

/* Inquire what environment an object requires */
#define DTM_FRAMEBOX        (&H601)

/* Same as GM_LAYOUT except guaranteed to be on a process already */
#define DTM_PROCLAYOUT      (&H602)

/* Layout that is occurring on a process */
#define DTM_ASYNCLAYOUT     (&H603)

/* When a RemoveDTObject() is called */
#define DTM_REMOVEDTOBJECT  (&H604)

#define DTM_SELECT      (&H605)
#define DTM_CLEARSELECTED   (&H606)

#define DTM_COPY        (&H607)
#define DTM_PRINT       (&H608)
#define DTM_ABORTPRINT      (&H609)

#define DTM_NEWMEMBER       (&H610)
#define DTM_DISPOSEMEMBER   (&H611)

#define DTM_GOTO        (&H630)
#define DTM_TRIGGER     (&H631)

#define DTM_OBTAINDRAWINFO  (&H640)
#define DTM_DRAW        (&H641)
#define DTM_RELEASEDRAWINFO (&H642)

#define DTM_WRITE       (&H650)

/* Used TO ask the object about itself */

STRUCT fri_Dimensions_Struct  
    LONGINT _Width 
    LONGINT Height 
    LONGINT Depth   
END STRUCT 

STRUCT FrameInfo
 
    LONGINT        fri_PropertyFlags      /* DisplayInfo (graphics/displayinfo.h) */
    _Point fri_Resolution         /* DisplayInfo */

    BYTE         fri_RedBits 
    BYTE         fri_GreenBits 
    BYTE         fri_BlueBits 
    fri_Dimensions_Struct fri_Dimensions 
    ScreenPtr  fri_Screen 
    ColorMapPtr  fri_ColorMap 

    LONGINT        fri_Flags 
END STRUCT 

#define FIF_SCALABLE    &H1
#define FIF_SCROLLABLE  &H2
#define FIF_REMAPPABLE  &H4

/* DTM_REMOVEDTOBJECT,  DTM_CLEARSELECTED,  DTM_COPY,  DTM_ABORTPRINT */
STRUCT dtGeneral
 
    LONGINT        MethodID 
    GadgetInfoPtr  dtg_GInfo 
END STRUCT 

/* DTM_SELECT */
STRUCT dtSelect
 
    LONGINT        MethodID 
    GadgetInfoPtr  dts_GInfo 
    Rectangle dts_Select 
END STRUCT 

/* DTM_FRAMEBOX */
STRUCT dtFrameBox
 
    LONGINT        MethodID 
    GadgetInfoPtr  dtf_GInfo 
    FrameInfoPtr  dtf_ContentsInfo   /* Input */
    FrameInfoPtr  dtf_FrameInfo      /* Output */
    LONGINT        dtf_SizeFrameInfo 
    LONGINT        dtf_FrameFlags 
END STRUCT 

#ifndef FRAMEF_SPECIFY
#define FRAMEF_SPECIFY  (1)  /* Make do with the dimensions of FrameBox provided. */
#endif

/* DTM_GOTO */
STRUCT dtGoto
 
    LONGINT        MethodID 
    GadgetInfoPtr  dtg_GInfo 
    ADDRESS       dtg_NodeName       /* Node to goto */
    TagItemPtr  dtg_AttrList       /* Additional attributes */
END STRUCT 

/* DTM_TRIGGER */
STRUCT dtTrigger
 
    LONGINT        MethodID 
    GadgetInfoPtr  dtt_GInfo 
    LONGINT        dtt_Function 
    ADDRESS         dtt_Data 
END STRUCT 

#define STM_PAUSE       1
#define STM_PLAY        2
#define STM_CONTENTS        3
#define STM_INDEX       4
#define STM_RETRACE     5
#define STM_BROWSE_PREV     6
#define STM_BROWSE_NEXT     7

#define STM_NEXT_FIELD      8
#define STM_PREV_FIELD      9
#define STM_ACTIVATE_FIELD  10

#define STM_COMMAND     11

/* New for V40 */
#define STM_REWIND      12
#define STM_FASTFORWARD     13
#define STM_STOP        14
#define STM_RESUME      15
#define STM_LOCATE      16

/* Printer IO request */
STRUCT printerIO
 
    IOStdReq ios 
    IODRPReq iodrp 
    IOPrtCmdReq iopc 
END STRUCT 

/* DTM_PRINT */
STRUCT dtPrint
 
    LONGINT        MethodID 
    GadgetInfoPtr  dtp_GInfo      /* Gadget information */
    printerIOPtr  dtp_PIO        /* Printer IO request */
    TagItemPtr  dtp_AttrList       /* Additional attributes */
END STRUCT 

/* DTM_DRAW */
STRUCT dtDraw
 
    LONGINT        MethodID 
    RastPortPtr  dtd_RPort 
    LONGINT         dtd_Left 
    LONGINT         dtd_Top 
    LONGINT         dtd_Width 
    LONGINT         dtd_Height 
    LONGINT         dtd_TopHoriz 
    LONGINT         dtd_TopVert 
    TagItemPtr  dtd_AttrList       /* Additional attributes */
END STRUCT 

/* DTM_WRITE */
STRUCT dtWrite
 
    LONGINT        MethodID 
    GadgetInfoPtr  dtw_GInfo      /* Gadget information */
    ADDRESS         dtw_FileHandle     /* File handle to write to */
    LONGINT        dtw_Mode 
    TagItemPtr  dtw_AttrList       /* Additional attributes */
END STRUCT 

/* Save data as IFF data */
#define DTWM_IFF    0

/* Save data as local data format */
#define DTWM_RAW    1

#endif /* DATATYPES_DATATYPESCLASS_H */
