#ifndef DOS_NOTIFY_H
#define DOS_NOTIFY_H 1
/*
** notify.h for ACE Basic
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
** This are the StructPointer defines for notify.h
*/
#ifndef NotifyMessagePtr
#define NotifyMessagePtr ADDRESS
#endif
#ifndef NotifyRequestPtr
#define NotifyRequestPtr ADDRESS
#endif
#ifndef nr_Msg_StructPtr
#define nr_Msg_StructPtr ADDRESS
#endif
#ifndef nr_Signal_StructPtr
#define nr_Signal_StructPtr ADDRESS
#endif
/*
** End of StructPointer defines for notify.h
*/
        
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif

#ifndef EXEC_TASKS_H
#include <exec/tasks.h>
#endif



/* use of Class and code is discouraged for the time being - we might want to
   change things */
/* --- NotifyMessage Class ------------------------------------------------ */
#define NOTIFY_CLASS    &H40000000

/* --- NotifyMessage Codes ------------------------------------------------ */
#define NOTIFY_CODE &H1234


/* Sent to the application if SEND_MESSAGE is specified.            */

STRUCT NotifyMessage  
    _Message nm_ExecMessage 
    LONGINT  nm_Class 
    SHORTINT  nm_Code 
    NotifyRequestPtr  nm_NReq   /* don't modify the request! */
    LONGINT  nm_DoNotTouch        /* like it says!  For use by handlers */
    LONGINT  nm_DoNotTouch2       /* ditto */
END STRUCT 

/* Do not modify or reuse the notifyrequest while active.           */
/* note: the first LONGINT of nr_Data has the length transfered            */

STRUCT nr_Msg_Struct  
    MsgPortPtr  nr_Port 
END STRUCT 

STRUCT nr_Signal_Struct  
    TaskPtr  nr_Task 
    BYTE   nr_SignalNum 
    STRING nr_Pad SIZE 3  
END STRUCT 

STRUCT NotifyRequest  
    ADDRESS   nr_Name 
    ADDRESS   nr_FullName      /* set by dos - don't touch */
    LONGINT nr_UserData       /* for applications use */
    LONGINT nr_Flags 
    STRING nr_stuff SIZE 8  
    STRING nr_Reserved SIZE 16  /* 4*SIZEOF(LONGINT) */       /* leave 0 FOR now */

    /* internal use by handlers */
    LONGINT nr_MsgCount       /* # of outstanding msgs */
    MsgPortPtr  nr_Handler  /* handler sent to (for EndNotify) */
END STRUCT 

/* --- NotifyRequest Flags ------------------------------------------------ */
#define NRF_SEND_MESSAGE    1
#define NRF_SEND_SIGNAL     2
#define NRF_WAIT_REPLY      8
#define NRF_NOTIFY_INITIAL  16

/* do NOT set or remove NRF_MAGIC!  Only for use by handlers! */
#define NRF_MAGIC   &H80000000

/* bit numbers */
#define NRB_SEND_MESSAGE    0
#define NRB_SEND_SIGNAL     1
#define NRB_WAIT_REPLY      3
#define NRB_NOTIFY_INITIAL  4

#define NRB_MAGIC       31

/* Flags reserved for private use by the handler: */
#define NR_HANDLER_FLAGS    &Hffff0000

#endif /* DOS_NOTIFY_H */
