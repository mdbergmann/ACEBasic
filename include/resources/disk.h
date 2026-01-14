#ifndef RESOURCES_DISK_H
#define RESOURCES_DISK_H 1
/*
** disk.h for ACE Basic
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
** This are the StructPointer defines for disk.h
*/
#ifndef DiscResourcePtr
#define DiscResourcePtr ADDRESS
#endif
#ifndef DiscResourceUnitPtr
#define DiscResourceUnitPtr ADDRESS
#endif
/*
** End of StructPointer defines for disk.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif

#ifndef EXEC_INTERRUPTS_H
#include <exec/interrupts.h>
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif


/********************************************************************
*
* Resource structures
*
********************************************************************/


STRUCT DiscResourceUnit  
    _Message dru_Message 
    Interrupt dru_DiscBlock 
    Interrupt dru_DiscSync 
    Interrupt dru_Index 
END STRUCT 

STRUCT DiscResource  
    _Library dr_Library 
    DiscResourceUnitPtr  dr_Current 
    BYTE            dr_Flags 
    BYTE            dr_pad 
    LibraryPtr  dr_SysLib 
    LibraryPtr  dr_CiaResource 
    STRING dr_UnitID SIZE 16  /* 4*SIZEOF(LONGINT) */
    _List dr_Waiting 
    Interrupt dr_DiscBlock 
    Interrupt dr_DiscSync 
    Interrupt dr_Index 
    TaskPtr  dr_CurrTask 
END STRUCT 

/* dr_Flags entries */
#define DRB_ALLOC0  0   /* unit zero is allocated */
#define DRB_ALLOC1  1   /* unit one is allocated */
#define DRB_ALLOC2  2   /* unit two is allocated */
#define DRB_ALLOC3  3   /* unit three is allocated */
#define DRB_ACTIVE  7   /* is the disc currently busy? */

#define DRF_ALLOC0  (1)  /* unit zero is allocated */
#define DRF_ALLOC1  (2)  /* unit one is allocated */
#define DRF_ALLOC2  (4)  /* unit two is allocated */
#define DRF_ALLOC3  (8)  /* unit three is allocated */
#define DRF_ACTIVE  (128)  /* is the disc currently busy? */



/********************************************************************
*
* Hardware Magic
*
********************************************************************/


#define DSKDMAOFF   &H4000  /* idle command for dsklen register */


/********************************************************************
*
* Resource specific commands
*
********************************************************************/

/*
 * DISKNAME is a generic macro to get the name of the resource.
 * This way if the name is ever changed you will pick up the
 *  change automatically.
 */

#define DISKNAME    "disk.resource"


#define DR_ALLOCUNIT    (LIB_BASE - 0*LIB_VECTSIZE)
#define DR_FREEUNIT (LIB_BASE - 1*LIB_VECTSIZE)
#define DR_GETUNIT  (LIB_BASE - 2*LIB_VECTSIZE)
#define DR_GIVEUNIT (LIB_BASE - 3*LIB_VECTSIZE)
#define DR_GETUNITID    (LIB_BASE - 4*LIB_VECTSIZE)
#define DR_READUNITID   (LIB_BASE - 5*LIB_VECTSIZE)

#define DR_LASTCOMM (DR_READUNITID)

/********************************************************************
*
* drive types
*
********************************************************************/

#define DRT_AMIGA   (&H00000000)
#define DRT_37422D2S    (&H55555555)
#define DRT_EMPTY   (&HFFFFFFFF)
#define DRT_150RPM  (&HAAAAAAAA)

#endif /* RESOURCES_DISK_H */
