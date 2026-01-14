#ifndef EXEC_NODES_H
#define EXEC_NODES_H 1
/*
** nodes.h for ACE Basic
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
** This are the StructPointer defines for nodes.h
*/
#ifndef MinNodePtr
#define MinNodePtr ADDRESS
#endif
#ifndef NodePtr
#define NodePtr ADDRESS
#endif
/*
** End of StructPointer defines for nodes.h
*/
     
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEC_TYPES_H */



/*
 *  List Node Structure.  Each member in a list starts with a Node
 */

STRUCT Node  
    NodePtr  ln_Succ   /* Pointer to next (successor) */
    NodePtr  ln_Pred   /* Pointer to previous (predecessor) */
    BYTE    ln_Type 
    BYTE    ln_Pri      /* Priority,  for sorting */
    ADDRESS   ln_Name        /* ID string,  null terminated */
END STRUCT   /* Note: SHORTINT aligned */

/* minimal node -- no type checking possible */
STRUCT MinNode  
    MinNodePtr  mln_Succ 
    MinNodePtr  mln_Pred 
END STRUCT 


/*
** Note: Newly initialized IORequests,  and software interrupt structures
** used with Cause(),  should have type NT_UNKNOWN.  The OS will assign a type
** when they are first used.
*/
/*----- Node Types for LN_TYPE -----*/
#define NT_UNKNOWN  0
#define NT_TASK     1   /* Exec task */
#define NT_INTERRUPT    2
#define NT_DEVICE   3
#define NT_MSGPORT  4
#define NT_MESSAGE  5   /* Indicates message currently pending */
#define NT_FREEMSG  6
#define NT_REPLYMSG 7   /* Message has been replied */
#define NT_RESOURCE 8
#define NT_LIBRARY  9
#define NT_MEMORY   10
#define NT_SOFTINT  11  /* Internal flag used by SoftInits */
#define NT_FONT     12
#define NT_PROCESS  13  /* AmigaDOS Process */
#define NT_SEMAPHORE    14
#define NT_SIGNALSEM    15  /* signal semaphores */
#define NT_BOOTNODE 16
#define NT_KICKMEM  17
#define NT_GRAPHICS 18
#define NT_DEATHMESSAGE 19

#define NT_USER     254 /* User node types work down from here */
#define NT_EXTENDED 255

#endif  /* EXEC_NODES_H */
