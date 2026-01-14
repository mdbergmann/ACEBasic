#ifndef LIBRARIES_MATHLIBRARY_H
#define LIBRARIES_MATHLIBRARY_H 1
/*
** mathlibrary.h for ACE Basic
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
** This are the StructPointer defines for mathlibrary.h
*/
#ifndef MathIEEEBasePtr
#define MathIEEEBasePtr ADDRESS
#endif
/*
** End of StructPointer defines for mathlibrary.h
*/


#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

STRUCT MathIEEEBase
 
    _Library MathIEEEBase_LibNode 
    STRING MathIEEEBase_reserved SIZE 18  
    ADDRESS   MathIEEEBase_TaskOpenLib 
    ADDRESS   MathIEEEBase_TaskCloseLib
    /*  This structure may be extended in the future */
END STRUCT 
/*
* Math resources may need to know when a program opens or closes this
* library. The functions TaskOpenLib and TaskCloseLib are called when
* a task opens or closes this library. They are initialized to point to
* local initialization pertaining to 68881 stuff if 68881 resources
* are found. To override the default the vendor must provide appropriate
* hooks in the MathIEEEResource. If specified,  these will be called
* when the library initializes.
*/

#endif  /* LIBRARIES_MATHLIBRARY_H */
