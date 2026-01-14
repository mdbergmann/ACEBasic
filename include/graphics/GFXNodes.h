#ifndef GRAPHICS_GFXNODES_H
#define GRAPHICS_GFXNODES_H 1
/*
** gfxnodes.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/

/*
** This are the StructPointer defines for gfxnodes.h
*/
#ifndef ExtendedNodePtr
#define ExtendedNodePtr ADDRESS
#endif
/*
** End of StructPointer defines for gfxnodes.h
*/
    
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif


STRUCT  ExtendedNode     
NodePtr  xln_Succ 
NodePtr  xln_Pred 
BYTE    xln_Type 
BYTE    xln_Pri 
ADDRESS   xln_Name 
BYTE    xln_Subsystem 
BYTE    xln_Subtype 
LONGINT    xln_Library 
ADDRESS    xln_Init
END STRUCT 

#define SS_GRAPHICS &H02

#define VIEW_EXTRA_TYPE     1
#define VIEWPORT_EXTRA_TYPE 2
#define SPECIAL_MONITOR_TYPE    3
#define MONITOR_SPEC_TYPE   4

#endif  /* GRAPHICS_GFXNODES_H */
