#ifndef UTILITY_UTILITY_H
#define UTILITY_UTILITY_H 1
/*
** utility.h for ACE Basic
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
** This are the StructPointer defines for utility.h
*/
#ifndef UtilityBasePtr
#define UtilityBasePtr ADDRESS
#endif
/*
** End of StructPointer defines for utility.h
*/



/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif


/*****************************************************************************/


#define UTILITYNAME "utility.library"


STRUCT UtilityBase
 
    _Library ub_LibNode 
    BYTE       ub_Language 
    BYTE       ub_Reserved 
END STRUCT 


/*****************************************************************************/


#endif /* UTILITY_UTILITY_H */
