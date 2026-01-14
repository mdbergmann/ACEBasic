#ifndef EXEC_SEMAPHORES_H
#define EXEC_SEMAPHORES_H 1
/*
** semaphores.h for ACE Basic
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
** This are the StructPointer defines for semaphores.h
*/
#ifndef SemaphorePtr
#define SemaphorePtr ADDRESS
#endif
#ifndef SemaphoreMessagePtr
#define SemaphoreMessagePtr ADDRESS
#endif
#ifndef SemaphoreRequestPtr
#define SemaphoreRequestPtr ADDRESS
#endif
#ifndef SignalSemaphorePtr
#define SignalSemaphorePtr ADDRESS
#endif
/*
** End of StructPointer defines for semaphores.h
*/
      
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif /* EXEC_NODES_H */

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif /* EXEC_LISTS_H */

#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif /* EXEC_PORTS_H */

#ifndef EXEC_TASKS_H
#include <exec/tasks.h>
#endif /* EXEC_TASKS_H */


/****** SignalSemaphore *********************************************/

/* Private structure used by ObtainSemaphore() */
STRUCT SemaphoreRequest
 
    MinNode sr_Link 
    TaskPtr  sr_Waiter 
END STRUCT 

/* Signal Semaphore data structure */
STRUCT SignalSemaphore
 
    Node ss_Link 
    SHORTINT            ss_NestCount 
    MinList ss_WaitQueue 
    SemaphoreRequest ss_MultipleLink 
    TaskPtr  ss_Owner 
    SHORTINT            ss_QueueCount 
END STRUCT 

/****** Semaphore procure message (for use in V39 Procure/Vacate ****/
STRUCT SemaphoreMessage
 
    _Message ssm_Message 
    SignalSemaphorePtr  ssm_Semaphore 
END STRUCT 

#define SM_SHARED   (1&)
#define SM_EXCLUSIVE    (0&)

/****** Semaphore (Old Procure/Vacate type,  not reliable) ***********/

STRUCT Semaphore    /* Do not use these semaphores! */
 
    MsgPort sm_MsgPort 
    SHORTINT    sm_Bids 
END STRUCT 

#define sm_LockMsg  mp_SigTask


#endif  /* EXEC_SEMAPHORES_H */
