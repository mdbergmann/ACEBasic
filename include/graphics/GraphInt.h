#ifndef GRAPHICS_GRAPHINT_H
#define GRAPHICS_GRAPHINT_H 1
/*
** graphint.h for ACE Basic
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
** This are the StructPointer defines for graphint.h
*/
#ifndef IsrvstrPtr
#define IsrvstrPtr ADDRESS
#endif
/*
** End of StructPointer defines for graphint.h
*/
       
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

/* structure used by AddTOFTask */
STRUCT Isrvstr
 
    Node is_Node 
    IsrvstrPtr  Iptr    /* passed to srvr by os */
    ADDRESS   code 
    ADDRESS   ccode
    LONGINT Carg 
END STRUCT 

#endif  /* GRAPHICS_GRAPHINT_H */
