#ifndef LIBRARIES_NONVOLATILE_H
#define LIBRARIES_NONVOLATILE_H 1
/*
** nonvolatile.h for ACE Basic
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
** This are the StructPointer defines for nonvolatile.h
*/
#ifndef NVEntryPtr
#define NVEntryPtr ADDRESS
#endif
#ifndef NVInfoPtr
#define NVInfoPtr ADDRESS
#endif
/*
** End of StructPointer defines for nonvolatile.h
*/



/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif


/*****************************************************************************/


STRUCT NVInfo
 
    LONGINT nvi_MaxStorage 
    LONGINT nvi_FreeStorage 
END STRUCT 


/*****************************************************************************/


STRUCT NVEntry
 
    MinNode nve_Node 
    ADDRESS     nve_Name 
    LONGINT      nve_Size 
    LONGINT      nve_Protection 
END STRUCT 

/* bit definitions for mask in SetNVProtection().  Also used for
 * NVEntry.nve_Protection.
 */
#define NVEB_DELETE  0
#define NVEB_APPNAME 31

#define NVEF_DELETE  (1)
#define NVEF_APPNAME (2147483648)


/*****************************************************************************/


/* errors from StoreNV() */
#define NVERR_BADNAME   1
#define NVERR_WRITEPROT 2
#define NVERR_FAIL  3
#define NVERR_FATAL 4


/*****************************************************************************/


/* determine the size of data returned by this library */
/*
#define SizeNVData(DataPtr) ((((LONGINT *) DataPtr)[-1]) - 4)
*/

/*****************************************************************************/


#endif /* LIBRARIES_NONVOLATILE_H */
