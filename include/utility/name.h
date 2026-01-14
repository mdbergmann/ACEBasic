#ifndef UTILITY_NAME_H
#define UTILITY_NAME_H 1
/*
** name.h for ACE Basic
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
** This are the StructPointer defines for name.h
*/
#ifndef NamedObjectPtr
#define NamedObjectPtr ADDRESS
#endif
/*
** End of StructPointer defines for name.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif


/*****************************************************************************/


/* The named object structure */
STRUCT NamedObject
 
    ADDRESS no_Object  /* Your pointer,  for whatever you want */
END STRUCT 

/* Tags for AllocNamedObject() */
#define ANO_NameSpace   4000    /* Tag to define namespace  */
#define ANO_UserSpace   4001    /* tag to define userspace  */
#define ANO_Priority    4002    /* tag to define priority   */
#define ANO_Flags   4003    /* tag to define flags      */

/* Flags for tag ANO_Flags */
#define NSB_NODUPS  0
#define NSB_CASE    1

#define NSF_NODUPS  (1&)  /* Default allow duplicates */
#define NSF_CASE    (2&)    /* Default TO caseless... */


/*****************************************************************************/


#endif /* UTILITY_NAME_H */
