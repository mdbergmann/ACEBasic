#ifndef EXEC_PORTS_H
#define EXEC_PORTS_H 1
/*
** ports.h for ACE Basic
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
** This are the StructPointer defines for ports.h
*/
#ifndef MessagePtr
#define MessagePtr ADDRESS
#endif
#ifndef MsgPortPtr
#define MsgPortPtr ADDRESS
#endif
/*
** End of StructPointer defines for ports.h
*/
      
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif /* EXEC_NODES_H */

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif /* EXEC_LISTS_H */

#ifndef EXEC_TASKS_H
#include <exec/tasks.h>
#endif /* EXEC_TASKS_H */


/****** MsgPort *****************************************************/

STRUCT MsgPort  
    Node mp_Node 
    BYTE    mp_Flags 
    BYTE    mp_SigBit       /* signal bit number    */
    ADDRESS   mp_SigTask      /* object to be signalled */
    _List mp_MsgList     /* message linked list  */
END STRUCT 

#define mp_SoftInt mp_SigTask   /* Alias */

/* mp_Flags: Port arrival actions (PutMsg) */
#define PF_ACTION   3   /* Mask */
#define PA_SIGNAL   0   /* Signal task in mp_SigTask */
#define PA_SOFTINT  1   /* Signal SoftInt in mp_SoftInt/mp_SigTask */
#define PA_IGNORE   2   /* Ignore arrival */


/****** Message *****************************************************/

STRUCT _Message
    Node mn_Node 
    MsgPortPtr  mn_ReplyPort   /* message reply port */
    SHORTINT   mn_Length           /* total message length,  in bytes */
                    /* (include the size of the Message */
                    /* structure in the length) */
END STRUCT 

#endif  /* EXEC_PORTS_H */
