#ifndef EXEC_LISTS_H
#define EXEC_LISTS_H 1
/*
** lists.h for ACE Basic
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
** This are the StructPointer defines for lists.h
*/
#ifndef ListPtr
#define ListPtr ADDRESS
#endif
#ifndef MinListPtr
#define MinListPtr ADDRESS
#endif
/*
** End of StructPointer defines for lists.h
*/
      
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif /* EXEC_NODES_H */


/*
 *  Full featured list header.
 */
STRUCT _List  
   NodePtr  lh_Head 
   NodePtr  lh_Tail 
   NodePtr  lh_TailPred 
   BYTE    lh_Type 
   BYTE    l_pad 
END STRUCT   /* SHORTINT aligned */

/*
 * Minimal List Header - no type checking
 */
STRUCT MinList  
   MinNodePtr  mlh_Head 
   MinNodePtr  mlh_Tail 
   MinNodePtr  mlh_TailPred 
END STRUCT   /* longword aligned */


/*
 *  Check for the presence of any nodes on the given list.  These
 *  macros are even safe to use on lists that are modified by other
 *  tasks.  However  if something is simultaneously changing the
 *  list,  the result of the test is unpredictable.
 *
 *  Unless you first arbitrated for ownership of the list,  you can't
 *  _depend_ on the contents of the list.  Nodes might have been added
 *  or removed during or after the macro executes.
 *
 *      if( IsListEmpty(list) )     printf("List is empty\n") 
 */
/*
#define IsListEmpty(x) \
    ( ((x)->lh_TailPred) == (STRUCT Node *)(x) )

#define IsMsgPortEmpty(x) \
    ( ((x)->mp_MsgList.lh_TailPred) == (STRUCT Node *)(&(x)->mp_MsgList) )
*/

#endif  /* EXEC_LISTS_H */
