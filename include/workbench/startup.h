#ifndef WORKBENCH_STARTUP_H
#define WORKBENCH_STARTUP_H 1
/*
** startup.h for ACE Basic
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
** This are the StructPointer defines for startup.h
*/
#ifndef WBArgPtr
#define WBArgPtr ADDRESS
#endif
#ifndef WBStartupPtr
#define WBStartupPtr ADDRESS
#endif
/*
** End of StructPointer defines for startup.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif

#ifndef LIBRARIES_DOS_H
#include <libraries/dos.h>
#endif

STRUCT WBStartup  
    _Message sm_Message  /* a standard message structure */
    MsgPortPtr  sm_Process  /* the process descriptor FOR you */
    ADDRESS        sm_Segment  /* a descriptor for your code */
    LONGINT        sm_NumArgs  /* the number of elements in ArgList */
    ADDRESS   sm_ToolWindow   /* description of window */
    WBArgPtr  sm_ArgList  /* the arguments themselves */
END STRUCT 

STRUCT WBArg  
    ADDRESS        wa_Lock     /* a lock descriptor */
    ADDRESS   wa_Name     /* a string relative to that lock */
END STRUCT 

#endif  /* !WORKBENCH_STARTUP_H */
