#ifndef UTILITY_HOOKS_H
#define UTILITY_HOOKS_H 1
/*
** hooks.h for ACE Basic
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
** This are the StructPointer defines for hooks.h
*/
#ifndef HookPtr
#define HookPtr ADDRESS
#endif
/*
** End of StructPointer defines for hooks.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif


/*****************************************************************************/


STRUCT Hook
 
    MinNode h_MinNode 
    ADDRESS   h_Entry     /* assembler entry point */
    ADDRESS   h_SubEntry  /* often HLL entry point */
    ADDRESS       h_Data       /* owner specific    */
END STRUCT 

/* Useful definition for casting function pointers:
 * hook.h_SubEntry = (HOOKFUNC)AFunction
 */
/*
typedef unsigned LONGINT *HOOKFUNC 
*/

/* Hook calling conventions.
 *
 * The function pointed to by Hook.h_Entry is called with the following
 * parameters:
 *
 *  A0 - pointer to hook data structure itself
 *  A1 - pointer to parameter structure ("message")
 *  A2 - Hook specific address data ("object")
 *
 * Control will be passed to the routine h_Entry.  For many
 * High-Level Languages (HLL),  this will be an assembly language
 * stub which pushes registers on the stack,  does other setup, 
 * and then calls the function at h_SubEntry.
 *
 * The standard C receiving code is:
 *
 *    HookFunc(STRUCT Hook *hook,  ADDRESS object,  ADDRESS message)
 *
 * Note that register natural order differs from this convention for C
 * parameter order,  which is A0, A2, A1.
 *
 * The assembly language stub for "vanilla" C parameter conventions
 * could be:
 *
 * _hookEntry:
 *  move.l  a1, -(sp)          push message packet pointer
 *  move.l  a2, -(sp)          push object pointer
 *  move.l  a0, -(sp)          push hook pointer
 *  move.l  h_SubEntry(a0), a0     fetch C entry point ...
 *  jsr (a0)              ... and call it
 *  lea 12(sp), sp         fix stack
 *  rts
 *
 * With this function as your interface stub,  you can write a Hook setup
 * function as:
 *
 * InitHook(STRUCT Hook *hook,  LONGINT (*c_function)(),  ADDRESS userdata)
 *  
 * LONGINT *hookEntry
 *
 *     hook->h_Entry    = hookEntry 
 *     hook->h_SubEntry = c_function 
 *     hook->h_Data = userdata 
 * END STRUCT
 *
 * With a compiler capable of registerized parameters,  such as SAS C,  you
 * can put the C function in the h_Entry field directly. For example,  for
 * SAS C:
 *
 *   LONGINT __saveds __asm HookFunc(register __a0 STRUCT Hook *hook, 
 *                 register __a2 ADDRESS         object, 
 *                 register __a1 ADDRESS         message) 
 *
 */


/*****************************************************************************/


#endif /* UTILITY_HOOKS_H */
