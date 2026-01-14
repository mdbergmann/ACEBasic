#ifndef UTILITY_DATE_H
#define UTILITY_DATE_H 1
/*
** date.h for ACE Basic
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
** This are the StructPointer defines for date.h
*/
#ifndef ClockDataPtr
#define ClockDataPtr ADDRESS
#endif
/*
** End of StructPointer defines for date.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif


/*****************************************************************************/


STRUCT ClockData
 
    SHORTINT sec 
    SHORTINT min 
    SHORTINT hour 
    SHORTINT mday 
    SHORTINT month 
    SHORTINT year 
    SHORTINT wday 
END STRUCT 


/*****************************************************************************/


#endif /* UTILITY_DATE_H */
