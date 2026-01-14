#ifndef EXEC_TYPES_H
#define EXEC_TYPES_H 1
/*
** types.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/02/95
**
** Note: Changed TRUE, FALSE and NULL from define
**       to CONST. Now they are case-insensitive.
**       Added various pointers as address.
**       Date 10/08/95   Nils Sjoholm
**
**       Added BOOL and STRUCTPTR, just to make it
**       easier to read declared functions.
**       This means that this header is always included
**       when you use the headerfunctions.
**       Date 10/09/95   NS
*/



#define INCLUDE_VERSION 40 /* Version of the include files in use. (Do not
                  use this label for OpenLibrary() calls!) */



#ifndef ACEDEF_H	/* These constants are also defined in ace/acedef.h. */
CONST NULL = 0&
CONST TRUE = -1&
CONST FALSE = 0&
#endif

#ifndef STRPTR
#define STRPTR      ADDRESS
#endif
#ifndef APTR
#define APTR        ADDRESS
#endif
#ifndef BPTR
#define BPTR        ADDRESS
#endif
#ifndef BSTR
#define BSTR        ADDRESS
#endif
#ifndef BOOL
#define BOOL        LONGINT
#endif
#ifndef STRUCTPTR
#define STRUCTPTR   ADDRESS
#endif

#ifndef DOUBLE                 /* This is just a temporary FIX, just so I could      */
#define DOUBLE      SINGLE     /* test some FUNCTION declarartions FOR some mathlib  */
#endif                         /* When ACE can HANDLE double this will be removed    */

#define BYTEMASK    &HFF


 /* #define LIBRARY_VERSION is now obsolete.  Please use LIBRARY_MINIMUM */
/* or code the specific minimum library version you require.        */
#define LIBRARY_MINIMUM 33 /* Lowest version supported by Commodore-Amiga */


#endif  /* EXEC_TYPES_H */
