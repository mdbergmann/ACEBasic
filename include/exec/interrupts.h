#ifndef EXEC_INTERRUPTS_H
#define EXEC_INTERRUPTS_H 1
/*
** interrupts.h for ACE Basic
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
** This are the StructPointer defines for interrupts.h
*/
#ifndef IntVectorPtr
#define IntVectorPtr ADDRESS
#endif
#ifndef InterruptPtr
#define InterruptPtr ADDRESS
#endif
#ifndef SoftIntListPtr
#define SoftIntListPtr ADDRESS
#endif
/*
** End of StructPointer defines for interrupts.h
*/
        
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif /* EXEC_NODES_H */

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif /* EXEC_LISTS_H */



STRUCT Interrupt  
    Node is_Node 
    ADDRESS    is_Data             /* server data segment  */
    ADDRESS   is_Code        /* server code entry    */
END STRUCT 


STRUCT IntVector        /* For EXEC use ONLY! */
    ADDRESS    iv_Data 
    ADDRESS   iv_Code
    NodePtr  iv_Node 
END STRUCT 


STRUCT SoftIntList          /* For EXEC use ONLY! */
    _List sh_List 
    SHORTINT  sh_Pad 
END STRUCT 

#define SIH_PRIMASK (&Hf0)

/* this is a fake LONGINT definition,  used only for AddIntServer and the like */
#define INTB_NMI    15
#define INTF_NMI    (32768)

#endif  /* EXEC_INTERRUPTS_H */
