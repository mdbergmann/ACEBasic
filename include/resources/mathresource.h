#ifndef RESOURCES_MATHRESOURCE_H
#define RESOURCES_MATHRESOURCE_H 1
/*
** mathresource.h for ACE Basic
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
** This are the StructPointer defines for mathresource.h
*/
#ifndef MathIEEEResourcePtr
#define MathIEEEResourcePtr ADDRESS
#endif
/*
** End of StructPointer defines for mathresource.h
*/


#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

/*
*   The 'Init' entries are only used if the corresponding
*   bit is set in the Flags field.
*
*   So if you are just a 68881,  you do not need the Init stuff
*   just make sure you have cleared the Flags field.
*
*   This should allow us to add Extended Precision later.
*
*   For Init users,  if you need to be called whenever a task
*   opens this library for use,  you need to change the appropriate
*   entries in MathIEEELibrary.
*/

STRUCT MathIEEEResource
 
    Node MathIEEEResource_Node 
    SHORTINT  MathIEEEResource_Flags
    ADDRESS   MathIEEEResource_BaseAddr  /* ptr TO 881 IF exists */
    ADDRESS   MathIEEEResource_DblBasInit 
    ADDRESS   MathIEEEResource_DblTransInit 
    ADDRESS   MathIEEEResource_SglBasInit 
    ADDRESS   MathIEEEResource_SglTransInit 
    ADDRESS   MathIEEEResource_ExtBasInit 
ADDRESS   MathIEEEResource_ExtTransInit 
END STRUCT 

/* definations for MathIEEEResource_FLAGS */
#define MATHIEEERESOURCEF_DBLBAS    (1)
#define MATHIEEERESOURCEF_DBLTRANS  (2)
#define MATHIEEERESOURCEF_SGLBAS    (4)
#define MATHIEEERESOURCEF_SGLTRANS  (8)
#define MATHIEEERESOURCEF_EXTBAS    (16)
#define MATHIEEERESOURCEF_EXTTRANS  (32)

#endif  /* RESOURCES_MATHRESOURCE_H */
