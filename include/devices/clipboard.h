#ifndef     DEVICES_CLIPBOARD_H
#define     DEVICES_CLIPBOARD_H 1
/*
** clipboard.h for ACE Basic
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
** This are the StructPointer defines for clipboard.h
*/
#ifndef ClipHookMsgPtr
#define ClipHookMsgPtr ADDRESS
#endif
#ifndef ClipboardUnitPartialPtr
#define ClipboardUnitPartialPtr ADDRESS
#endif
#ifndef IOClipReqPtr
#define IOClipReqPtr ADDRESS
#endif
#ifndef SatisfyMsgPtr
#define SatisfyMsgPtr ADDRESS
#endif
/*
** End of StructPointer defines for clipboard.h
*/
            
#ifndef EXEC_TYPES_H
#include    <exec/types.h>
#endif
#ifndef EXEC_NODES_H
#include    <exec/nodes.h>
#endif
#ifndef EXEC_LISTS_H
#include    <exec/lists.h>
#endif
#ifndef EXEC_PORTS_H
#include    <exec/ports.h>
#endif


#define CBD_POST        (CMD_NONSTD+0)
#define CBD_CURRENTREADID   (CMD_NONSTD+1)
#define CBD_CURRENTWRITEID  (CMD_NONSTD+2)
#define CBD_CHANGEHOOK      (CMD_NONSTD+3)

#define CBERR_OBSOLETEID    1


STRUCT ClipboardUnitPartial  
    Node cu_Node    /* list of units */
    LONGINT   cu_UnitNum      /* unit number for this unit */
    /* the remaining unit data is private to the device */
END STRUCT 


STRUCT IOClipReq  
    _Message io_Message 
    DevicePtr  io_Device    /* device node pointer  */
    ClipboardUnitPartialPtr  io_Unit  /* unit node pointer */
    SHORTINT   io_Command      /* device command */
    BYTE    io_Flags        /* including QUICK and SATISFY */
    BYTE    io_Error        /* error or warning num */
    LONGINT   io_Actual       /* number of bytes transferred */
    LONGINT   io_Length       /* number of bytes requested */
    ADDRESS  io_Data         /* either clip stream or post port */
    LONGINT   io_Offset       /* offset in clip stream */
    LONGINT    io_ClipID       /* ordinal clip identifier */
END STRUCT 

#define PRIMARY_CLIP    0   /* primary clip unit */

STRUCT SatisfyMsg  
    _Message sm_Msg   /* the length will be 6 */
    SHORTINT   sm_Unit         /* which clip unit this is */
    LONGINT    sm_ClipID       /* the clip identifier of the post */
END STRUCT 

STRUCT ClipHookMsg  
    LONGINT   chm_Type        /* zero for this structure format */
    LONGINT    chm_ChangeCmd   /* command that caused this hook invocation: */
                /*   either CMD_UPDATE or CBD_POST */
    LONGINT    chm_ClipID      /* the clip identifier of the new data */
END STRUCT 

#endif  /* DEVICES_CLIPBOARD_H */
