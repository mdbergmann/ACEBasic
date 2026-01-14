#ifndef EXEC_LIBRARIES_H
#define EXEC_LIBRARIES_H 1
/*
** libraries.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/02/95
**
**
*/

/*
** This are the StructPointer defines for libraries.h
*/
#ifndef LibraryPtr
#define LibraryPtr ADDRESS
#endif
/*
** End of StructPointer defines for libraries.h
*/
     
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif /* EXEC_NODES_H */



/*------ Special Constants ---------------------------------------*/
#define LIB_VECTSIZE    6   /* Each library entry takes 6 bytes */
#define LIB_RESERVED    4   /* Exec reserves the first 4 vectors */
#define LIB_BASE    (-LIB_VECTSIZE)
#define LIB_USERDEF (LIB_BASE-(LIB_RESERVED*LIB_VECTSIZE))
#define LIB_NONSTD  (LIB_USERDEF)

/*------ Standard Functions --------------------------------------*/
#define LIB_OPEN    (-6)
#define LIB_CLOSE   (-12)
#define LIB_EXPUNGE (-18)
#define LIB_EXTFUNC (-24)   /* for future expansion */


/*------ Library Base Structure ----------------------------------*/
/* Also used for Devices and some Resources */
STRUCT _Library  
    Node lib_Node 
    BYTE    lib_Flags 
    BYTE    lib_pad 
    SHORTINT   lib_NegSize         /* number of bytes before library */
    SHORTINT   lib_PosSize         /* number of bytes after library */
    SHORTINT   lib_Version         /* major */
    SHORTINT   lib_Revision        /* minor */
    ADDRESS    lib_IdString        /* ASCII identification */
    LONGINT   lib_Sum             /* the checksum itself */
    SHORTINT   lib_OpenCnt         /* number of current opens */
END STRUCT   /* Warning: size is not a longword multiple! */

/* lib_Flags bit definitions (all others are system reserved) */
#define LIBF_SUMMING    (1)      /* we are currently checksumming */
#define LIBF_CHANGED    (2)      /* we have just changed the lib */
#define LIBF_SUMUSED    (4)      /* set if we should bother to sum */
#define LIBF_DELEXP (8)      /* delayed expunge */


/* Temporary Compatibility */
#define lh_Node lib_Node
#define lh_Flags    lib_Flags
#define lh_pad      lib_pad
#define lh_NegSize  lib_NegSize
#define lh_PosSize  lib_PosSize
#define lh_Version  lib_Version
#define lh_Revision lib_Revision
#define lh_IdString lib_IdString
#define lh_Sum      lib_Sum
#define lh_OpenCnt  lib_OpenCnt

#endif  /* EXEC_LIBRARIES_H */
