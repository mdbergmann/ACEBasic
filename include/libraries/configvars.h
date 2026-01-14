#ifndef LIBRARIES_CONFIGVARS_H
#define LIBRARIES_CONFIGVARS_H 1
/*
** configvars.h for ACE Basic
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
** This are the StructPointer defines for configvars.h
*/
#ifndef ConfigDevPtr
#define ConfigDevPtr ADDRESS
#endif
#ifndef CurrentBindingPtr
#define CurrentBindingPtr ADDRESS
#endif
/*
** End of StructPointer defines for configvars.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif  /* EXEC_TYPES_H */

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif /* EXEC_NODES_H */

#ifndef LIBRARIES_CONFIGREGS_H
#include <libraries/configregs.h>
#endif /* LIBRARIES_CONFIGREGS_H */

/*
** At early system startup time,  one ConfigDev structure is created for
** each board found in the system.  Software may seach for ConfigDev
** structures by vendor & product ID number.  For debugging and diagnostic
** use,  the entire list can be accessed.  See the expansion.library document
** for more information.
*/
STRUCT ConfigDev  
    Node cd_Node 
    BYTE        cd_Flags    /* (read/write) */
    BYTE        cd_Pad      /* reserved */
    ExpansionRom cd_Rom      /* copy of board's expansion ROM */
    ADDRESS        cd_BoardAddr  /* where in memory the board was placed */
    LONGINT       cd_BoardSize    /* size of board in bytes */
    SHORTINT       cd_SlotAddr     /* which slot number (PRIVATE) */
    SHORTINT       cd_SlotSize     /* number of slots (PRIVATE) */
    ADDRESS        cd_Driver   /* pointer to node of driver */
    ConfigDevPtr  cd_NextCD   /* linked LIST of drivers TO config */
    STRING cd_Unused SIZE 16  /* 4*SIZEOF(LONGINT)*/    /* FOR whatever the driver wants */
END STRUCT 

/* cd_Flags */
#define CDB_SHUTUP  0   /* this board has been shut up */
#define CDB_CONFIGME    1   /* this board needs a driver to claim it */
#define CDB_BADMEMORY   2   /* this board contains bad memory */
#define CDB_PROCESSED   3   /* private flag */

#define CDF_SHUTUP  &H01
#define CDF_CONFIGME    &H02
#define CDF_BADMEMORY   &H04
#define CDF_PROCESSED   &H08

/*
** Boards are usually "bound" to software drivers.
** This structure is used by GetCurrentBinding() and SetCurrentBinding()
*/
STRUCT CurrentBinding  
    ConfigDevPtr  cb_ConfigDev        /* first configdev in CHAIN */
    ADDRESS   cb_FileName         /* file NAME of driver */
    ADDRESS   cb_ProductString    /* product # STRING */
ADDRESS   cb_ToolTypes        /* tooltypes from disk object */
END STRUCT 


#endif /* LIBRARIES_CONFIGVARS_H */
