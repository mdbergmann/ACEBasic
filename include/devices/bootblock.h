#ifndef DEVICES_BOOTBLOCK_H
#define DEVICES_BOOTBLOCK_H 1
/*
** bootblock.h for ACE Basic
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
** This are the StructPointer defines for bootblock.h
*/
#ifndef BootBlockPtr
#define BootBlockPtr ADDRESS
#endif
/*
** End of StructPointer defines for bootblock.h
*/        
     

#ifndef EXEC_TYPES_H
#include    <exec/types.h>
#endif

STRUCT BootBlock  
    STRING bb_id SIZE 4         /* 4 character identifier */
    LONGINT    bb_chksum       /* boot block checksum (balance) */
    LONGINT    bb_dosblock         /* reserved for DOS patch */
END STRUCT 

#define     BOOTSECTS   2   /* 1K bootstrap */

#define BBID_DOS    "DOS"
#define BBID_KICK   "KICK"

#define BBNAME_DOS  &H444F5300  /* 'DOS\0' */
#define BBNAME_KICK &H4B49434B  /* 'KICK' */

#endif  /* DEVICES_BOOTBLOCK_H */
