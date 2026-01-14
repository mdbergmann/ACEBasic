#ifndef LIBRARIES_AMIGAGUIDE_H
#define LIBRARIES_AMIGAGUIDE_H 1
/*
** amigaguide.h for ACE Basic
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
** This are the StructPointer defines for amigaguide.h
*/
#ifndef AmigaGuideHostPtr
#define AmigaGuideHostPtr ADDRESS
#endif
#ifndef AmigaGuideMsgPtr
#define AmigaGuideMsgPtr ADDRESS
#endif
#ifndef NewAmigaGuidePtr
#define NewAmigaGuidePtr ADDRESS
#endif
#ifndef XRefPtr
#define XRefPtr ADDRESS
#endif
#ifndef opExpungeNodePtr
#define opExpungeNodePtr ADDRESS
#endif
#ifndef opFindHostPtr
#define opFindHostPtr ADDRESS
#endif
#ifndef opNodeIOPtr
#define opNodeIOPtr ADDRESS
#endif
/*
** End of StructPointer defines for amigaguide.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEC_TYPES_H */

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif /* EXEC_LISTS_H */

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif /* EXEC_NODES_H */

#ifndef EXEC_SEMAPHORES_H
#include <exec/semaphores.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef INTUITION_SCREENS_H
#include <intuition/screens.h>
#endif

#ifndef INTUITION_CLASSUSR_H
#include <intuition/classusr.h>
#endif

#ifndef DO_DOS_H
#include <dos/dos.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef APSH_TOOL_ID
#define APSH_TOOL_ID 11000&
#define StartupMsgID        (APSH_TOOL_ID+1&)   /* Startup MESSAGE */
#define LoginToolID     (APSH_TOOL_ID+2&)   /* Login a tool SIPC port */
#define LogoutToolID        (APSH_TOOL_ID+3&)   /* Logout a tool SIPC port */
#define ShutdownMsgID       (APSH_TOOL_ID+4&)   /* Shutdown message */
#define ActivateToolID      (APSH_TOOL_ID+5&)   /* Activate tool */
#define DeactivateToolID    (APSH_TOOL_ID+6&)   /* Deactivate tool */
#define ActiveToolID        (APSH_TOOL_ID+7&)   /* Tool Active */
#define InactiveToolID      (APSH_TOOL_ID+8&)   /* Tool Inactive */
#define ToolStatusID        (APSH_TOOL_ID+9&)   /* Status message */
#define ToolCmdID       (APSH_TOOL_ID+10&)  /* Tool command message */
#define ToolCmdReplyID      (APSH_TOOL_ID+11&)  /* Reply to tool command */
#define ShutdownToolID      (APSH_TOOL_ID+12&)  /* Shutdown tool */
#endif

/* Attributes accepted by GetAmigaGuideAttr() */
#define AGA_Dummy       (TAG_USER)
#define AGA_Path        (AGA_Dummy+1)
#define AGA_XRefList        (AGA_Dummy+2)
#define AGA_Activate        (AGA_Dummy+3)
#define AGA_Context     (AGA_Dummy+4)

#define AGA_HelpGroup       (AGA_Dummy+5)
    /* (LONGINT) Unique identifier */

#define AGA_Reserved1       (AGA_Dummy+6)
#define AGA_Reserved2       (AGA_Dummy+7)
#define AGA_Reserved3       (AGA_Dummy+8)

#define AGA_ARexxPort       (AGA_Dummy+9)
    /* (STRUCT MsgPort *) Pointer to the ARexx message port (V40) */

#define AGA_ARexxPortName   (AGA_Dummy+10)
   /* (ADDRESS) Used to specify the ARexx port name (V40) (not copied) */


#define AMIGAGUIDECONTEXT ADDRESS

STRUCT AmigaGuideMsg
 
    _Message agm_Msg            /* Embedded Exec message structure */
    LONGINT        agm_Type           /* Type of message */
    ADDRESS         agm_Data           /* Pointer to message data */
    LONGINT        agm_DSize          /* Size of message data */
    LONGINT        agm_DType          /* Type of message data */
    LONGINT        agm_Pri_Ret            /* Primary return value */
    LONGINT        agm_Sec_Ret            /* Secondary return value */
    ADDRESS         agm_System1 
    ADDRESS         agm_System2 
END STRUCT 

/* Allocation description structure */
STRUCT NewAmigaGuide
 
    ADDRESS         nag_Lock           /* Lock on the document directory */
    ADDRESS       nag_Name           /* Name of document file */
    ScreenPtr  nag_Screen             /* Screen to place windows within */
    ADDRESS       nag_PubScreen          /* Public screen name to open on */
    ADDRESS       nag_HostPort           /* Application's ARexx port name */
    ADDRESS       nag_ClientPort         /* Name to assign to the clients ARexx port */
    ADDRESS       nag_BaseName           /* Base name of the application */
    LONGINT        nag_Flags          /* Flags */
    ADDRESS       nag_Context            /* NULL terminated context table */
    ADDRESS       nag_Node           /* Node to align on first (defaults to Main) */
    LONGINT         nag_Line           /* Line to align on */
    TagItemPtr  nag_Extens             /* Tag array extension */
    ADDRESS   nag_Client             /* Private! MUST be NULL */
END STRUCT 

/* public Client flags */
#define HTF_LOAD_INDEX      (1&)         /* Force load the index at init time */
#define HTF_LOAD_ALL        (2&)         /* Force load the entire database at init */
#define HTF_CACHE_NODE      (4&)         /* Cache each node as visited */
#define HTF_CACHE_DB        (8&)         /* Keep the buffers around until expunge */
#define HTF_UNIQUE      (32768&)        /* Unique ARexx port name */
#define HTF_NOACTIVATE      (65536&)        /* Don't activate window */

#define HTFC_SYSGADS        &H80000000

/* Callback function ID's */
#define HTH_OPEN        0
#define HTH_CLOSE       1

#define HTERR_NOT_ENOUGH_MEMORY     100&
#define HTERR_CANT_OPEN_DATABASE    101&
#define HTERR_CANT_FIND_NODE        102&
#define HTERR_CANT_OPEN_NODE        103&
#define HTERR_CANT_OPEN_WINDOW      104&
#define HTERR_INVALID_COMMAND       105&
#define HTERR_CANT_COMPLETE     106&
#define HTERR_PORT_CLOSED       107&
#define HTERR_CANT_CREATE_PORT      108&
#define HTERR_KEYWORD_NOT_FOUND     113&

/*
typedef STRUCT AmigaGuideHost *AMIGAGUIDEHOST 
*/

/* Cross reference node */
STRUCT XRef
 
    Node xr_Node            /* Embedded node */
    SHORTINT        xr_Pad             /* Padding */
    DocFilePtr  xr_DF              /* Document defined in */
    ADDRESS       xr_File            /* Name of document file */
    ADDRESS       xr_Name            /* Name of item */
    LONGINT         xr_Line            /* Line defined at */
END STRUCT 

#define XRSIZE  (SIZEOF(XRef))

/* Types of cross reference nodes */
#define XR_GENERIC  0
#define XR_FUNCTION 1
#define XR_COMMAND  2
#define XR_INCLUDE  3
#define XR_MACRO    4
#define XR_STRUCT   5
#define XR_FIELD    6
#define XR_TYPEDEF  7
#define XR_DEFINE   8

/* Callback handle */
STRUCT AmigaGuideHost
 
    Hook agh_Dispatcher         /* Dispatcher */
    LONGINT        agh_Reserved           /* Must be 0 */
    LONGINT        agh_Flags 
    LONGINT        agh_UseCnt             /* Number of open nodes */
    ADDRESS         agh_SystemData         /* Reserved for system use */
    ADDRESS         agh_UserData           /* Anything you want... */
END STRUCT 

/* Methods */
#define HM_FINDNODE 1
#define HM_OPENNODE 2
#define HM_CLOSENODE    3
#define HM_EXPUNGE  10      /* Expunge DataBase */

/* HM_FINDNODE */
STRUCT opFindHost
 
    LONGINT MethodID 
    TagItemPtr  ofh_Attrs       /*  R: Additional attributes */
    ADDRESS ofh_Node             /*  R: Name of node */
    ADDRESS ofh_TOC          /*  W: Table of Contents */
    ADDRESS ofh_Title            /*  W: Title to give to the node */
    ADDRESS ofh_Next             /*  W: Next node to browse to */
    ADDRESS ofh_Prev             /*  W: Previous node to browse to */
END STRUCT 

/* HM_OPENNODE,  HM_CLOSENODE */
STRUCT opNodeIO
 
    LONGINT MethodID 
    TagItemPtr  onm_Attrs       /*  R: Additional attributes */
    ADDRESS onm_Node             /*  R: Node name and arguments */
    ADDRESS onm_FileName         /*  W: File name buffer */
    ADDRESS onm_DocBuffer        /*  W: Node buffer */
    LONGINT onm_BuffLen           /*  W: Size of buffer */
    LONGINT onm_Flags             /* RW: Control flags */
END STRUCT 

/* onm_Flags */
#define HTNF_KEEP   (1&) /* Don't flush this node until database is
                 * closed. */
#define HTNF_RESERVED1  (2&) /* Reserved for system use */
#define HTNF_RESERVED2  (4&) /* Reserved for system use */
#define HTNF_ASCII  (8&) /* Node is straight ASCII */
#define HTNF_RESERVED3  (16&) /* Reserved for system use */
#define HTNF_CLEAN  (32&) /* Remove the node from the database */
#define HTNF_DONE   (64) /* Done with node */

/* onm_Attrs */
#define HTNA_Dummy  (TAG_USER)
#define HTNA_Screen (HTNA_Dummy+1)  /* (STRUCT Screen *) Screen that window resides in */
#define HTNA_Pens   (HTNA_Dummy+2)  /* Pen array (from DrawInfo) */
#define HTNA_Rectangle  (HTNA_Dummy+3)  /* Window box */

#define HTNA_HelpGroup  (HTNA_Dummy+5)  /* (LONGINT) unique identifier */


/* HM_EXPUNGE */
STRUCT opExpungeNode
 
    LONGINT MethodID 
    TagItemPtr  oen_Attrs       /*  R: Additional attributes */
END STRUCT 

#endif /* LIBRARIES_AMIGAGUIDE_H */
