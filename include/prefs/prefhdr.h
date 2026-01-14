#ifndef PREFS_PREFHDR_H
#define PREFS_PREFHDR_H 1
/*
** prefhdr.h for ACE Basic
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
** This are the StructPointer defines for prefhdr.h
*/
#ifndef PrefHeaderPtr
#define PrefHeaderPtr ADDRESS
#endif
/*
** End of StructPointer defines for prefhdr.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/*****************************************************************************/


#define ID_PREF  1347568966 
#define ID_PRHD  1347569732 


STRUCT PrefHeader
 
    BYTE  ph_Version    /* version of following data */
    BYTE  ph_Type   /* type of following data    */
    LONGINT ph_Flags  /* always set to 0 for now   */
END STRUCT 


/*****************************************************************************/


#endif /* PREFS_PREFHDR_H */
