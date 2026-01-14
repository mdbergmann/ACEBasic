#ifndef EXEC_TASKS_H
#define EXEC_TASKS_H 1
/*
** tasks.h for ACE Basic
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
** This are the StructPointer defines for tasks.h
*/
#ifndef StackSwapStructPtr
#define StackSwapStructPtr ADDRESS
#endif
#ifndef TaskPtr
#define TaskPtr ADDRESS
#endif
/*
** End of StructPointer defines for tasks.h
*/
        
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif /* EXEC_NODES_H */

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif /* EXEC_LISTS_H */



/* Please use Exec functions to modify task structure fields,  where available.
 */
STRUCT Task  
    Node tc_Node 
    BYTE    tc_Flags 
    BYTE    tc_State 
    BYTE    tc_IDNestCnt        /* intr disabled nesting*/
    BYTE    tc_TDNestCnt        /* task disabled nesting*/
    LONGINT   tc_SigAlloc         /* sigs allocated */
    LONGINT   tc_SigWait      /* sigs we are waiting for */
    LONGINT   tc_SigRecvd         /* sigs we have received */
    LONGINT   tc_SigExcept        /* sigs we will take excepts for */
    SHORTINT   tc_TrapAlloc        /* traps allocated */
    SHORTINT   tc_TrapAble         /* traps enabled */
    ADDRESS    tc_ExceptData       /* points to except data */
    ADDRESS    tc_ExceptCode       /* points to except code */
    ADDRESS    tc_TrapData         /* points to trap data */
    ADDRESS    tc_TrapCode         /* points to trap code */
    ADDRESS    tc_SPReg            /* stack pointer        */
    ADDRESS    tc_SPLower      /* stack lower bound    */
    ADDRESS    tc_SPUpper      /* stack upper bound + 2*/
    ADDRESS   tc_Switch      /* task losing CPU    */
    ADDRESS   tc_Launch      /* task getting CPU  */
    _List tc_MemEntry        /* Allocated memory. Freed by RemTask() */
    ADDRESS    tc_UserData         /* For use by the task  no restrictions! */
END STRUCT 

/*
 * Stack swap structure as passed to StackSwap()
 */
STRUCT  StackSwapStruct  
    ADDRESS    stk_Lower   /* Lowest byte of stack */
    LONGINT   stk_Upper   /* Upper end of stack (size + Lowest) */
    ADDRESS    stk_Pointer     /* Stack pointer at switch point */
END STRUCT 

/*----- Flag Bits ------------------------------------------*/
#define TB_PROCTIME 0
#define TB_ETASK    3
#define TB_STACKCHK 4
#define TB_EXCEPT   5
#define TB_SWITCH   6
#define TB_LAUNCH   7

#define TF_PROCTIME (1&)
#define TF_ETASK    (8&)
#define TF_STACKCHK (16&)
#define TF_EXCEPT   (32&)
#define TF_SWITCH   (64&)
#define TF_LAUNCH   (128&)

/*----- Task States ----------------------------------------*/
#define TS_INVALID  0
#define TS_ADDED    1
#define TS_RUN      2
#define TS_READY    3
#define TS_WAIT 4
#define TS_EXCEPT   5
#define TS_REMOVED  6

/*----- Predefined Signals -------------------------------------*/
#define SIGB_ABORT  0
#define SIGB_CHILD  1
#define SIGB_BLIT   4   /* Note: same as SINGLE */
#define SIGB_SINGLE 4   /* Note: same as BLIT */
#define SIGB_INTUITION  5
#define SIGB_NET    7
#define SIGB_DOS    8

#define SIGF_ABORT  (1&)
#define SIGF_CHILD  (2&)
#define SIGF_BLIT   (16&)
#define SIGF_SINGLE (16&)
#define SIGF_INTUITION  (32&)
#define SIGF_NET    (128&)
#define SIGF_DOS    (256)

#endif  /* EXEC_TASKS_H */
