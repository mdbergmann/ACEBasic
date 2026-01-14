#ifndef LIBRARIES_EXPANSIONBASE_H
#define LIBRARIES_EXPANSIONBASE_H 1
/*
** expansionbase.h for ACE Basic
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
** This are the StructPointer defines for expansionbase.h
*/
#ifndef BootNodePtr
#define BootNodePtr ADDRESS
#endif
#ifndef ExpansionBasePtr
#define ExpansionBasePtr ADDRESS
#endif
/*
** End of StructPointer defines for expansionbase.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif  /* EXEC_TYPES_H */

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif  /* EXEC_LIBRARIES_H */

#ifndef EXEC_SEMAPHORES_H
#include <exec/semaphores.h>
#endif  /* EXEC_SEMAPHORES_H */

#ifndef LIBRARIES_CONFIGVARS_H
#include <libraries/configvars.h>
#endif  /* LIBRARIES_CONFIGVARS_H */


/* BootNodes are scanned by dos.library at startup.  Items found on the
   _list are started by dos. BootNodes are added with the AddDosNode() or
   the V36 AddBootNode() calls. */
STRUCT BootNode
 
    Node bn_Node 
    SHORTINT   bn_Flags 
    ADDRESS    bn_DeviceNode 
END STRUCT 


/* expansion.library has functions to manipulate most of the information in
   ExpansionBase.  Direct access is not permitted.  Use FindConfigDev()
   _to scan the board list. */
STRUCT  ExpansionBase
 
    _Library LibNode 
    BYTE    Flags               /* read only (see below) */
    BYTE    eb_Private01            /* private */
    LONGINT   eb_Private02            /* private */
    LONGINT   eb_Private03            /* private */
    CurrentBinding eb_Private04    /* private */
    _List eb_Private05        /* private */
    _List MountList   /* contains STRUCT BootNode entries */
    /* private */
END STRUCT 

/* error codes */
#define EE_OK       0
#define EE_LASTBOARD    40  /* could not shut him up */
#define EE_NOEXPANSION  41  /* not enough expansion mem  board shut up */
#define EE_NOMEMORY 42  /* not enough normal memory */
#define EE_NOBOARD  43  /* no board at that address */
#define EE_BADMEM   44  /* tried to add bad memory card */

/* Flags */
#define EBB_CLOGGED 0   /* someone could not be shutup */
#define EBF_CLOGGED (1)
#define EBB_SHORTMEM    1   /* ran out of expansion mem */
#define EBF_SHORTMEM    (2)
#define EBB_BADMEM  2   /* tried to add bad memory card */
#define EBF_BADMEM  (4)
#define EBB_DOSFLAG 3   /* reserved for use by AmigaDOS */
#define EBF_DOSFLAG (8)
#define EBB_KICKBACK33  4   /* reserved for use by AmigaDOS */
#define EBF_KICKBACK33  (16)
#define EBB_KICKBACK36  5   /* reserved for use by AmigaDOS */
#define EBF_KICKBACK36  (32)
/* If the following flag is set by a floppy's bootblock code,  the initial
   _open of the initial shell window will be delayed until the first output
   _to that shell.  Otherwise the 1.3 compatible behavior applies. */
#define EBB_SILENTSTART 6
#define EBF_SILENTSTART (64)

/* Magic kludge for CC0 use */
#define EBB_START_CC0   7
#define EBF_START_CC0   (128)


#endif  /* LIBRARIES_EXPANSIONBASE_H */
