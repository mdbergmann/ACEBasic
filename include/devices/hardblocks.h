#ifndef DEVICES_HARDBLOCKS_H
#define DEVICES_HARDBLOCKS_H 1
/*
** hardblocks.h for ACE Basic
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
** This are the StructPointer defines for hardblocks.h
*/
#ifndef BadBlockBlockPtr
#define BadBlockBlockPtr ADDRESS
#endif
#ifndef BadBlockEntryPtr
#define BadBlockEntryPtr ADDRESS
#endif
#ifndef FileSysHeaderBlockPtr
#define FileSysHeaderBlockPtr ADDRESS
#endif
#ifndef LoadSegBlockPtr
#define LoadSegBlockPtr ADDRESS
#endif
#ifndef PartitionBlockPtr
#define PartitionBlockPtr ADDRESS
#endif
#ifndef RigidDiskBlockPtr
#define RigidDiskBlockPtr ADDRESS
#endif
/*
** End of StructPointer defines for hardblocks.h
*/
                   
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEC_TYPES_H */


/*--------------------------------------------------------------------
 *
 *  This file describes blocks of data that exist on a hard disk
 *  to describe that disk.  They are not generically accessable to
 *  the user as they do not appear on any DOS drive.  The blocks
 *  are tagged with a unique identifier,  checksummed,  and linked
 *  together.  The root of these blocks is the RigidDiskBlock.
 *
 *  The RigidDiskBlock must exist on the disk within the first
 *  RDB_LOCATION_LIMIT blocks.  This inhibits the use of the zero
 *  cylinder in an AmigaDOS partition: although it is strictly
 *  possible to store the RigidDiskBlock data in the reserved
 *  area of a partition,  this practice is discouraged since the
 *  reserved blocks of a partition are overwritten by "Format", 
 *  "Install",  "DiskCopy",  etc.  The recommended disk layout, 
 *  then,  is to use the first cylinder(s) to store all the drive
 *  data specified by these blocks: i.e. partition descriptions, 
 *  file system load images,  drive bad block maps,  spare blocks, 
 *  etc.
 *
 *  Though only 512 byte blocks are currently supported by the
 *  file system,  this proposal tries to be forward-looking by
 *  making the block size explicit,  and by using only the first
 *  256 bytes for all blocks but the LoadSeg data.
 *
 *------------------------------------------------------------------*/

/*
 *  NOTE
 *  optional block addresses below contain $ffffffff to indicate
 *  a NULL address,  as zero is a valid address
 */
STRUCT RigidDiskBlock  
    LONGINT   rdb_ID      /* 4 character identifier */
    LONGINT   rdb_SummedLongs     /* size of this checksummed structure */
    LONGINT    rdb_ChkSum      /* block checksum (longword sum to zero) */
    LONGINT   rdb_HostID      /* SCSI Target ID of host */
    LONGINT   rdb_BlockBytes  /* size of disk blocks */
    LONGINT   rdb_Flags       /* see below for defines */
    /* block list heads */
    LONGINT   rdb_BadBlockList    /* optional bad block list */
    LONGINT   rdb_PartitionList   /* optional first partition block */
    LONGINT   rdb_FileSysHeaderList  /* optional file system header block */
    LONGINT   rdb_DriveInit   /* optional drive-specific init code */
                /* DriveInit(lun, rdb, ior): "C" stk & d0/a0/a1 */
    STRING rdb_Reserved1 SIZE 24  /* 6*SIZEOF(LONGINT) */   /* set TO $ffffffff */
    /* physical drive characteristics */
    LONGINT   rdb_Cylinders   /* number of drive cylinders */
    LONGINT   rdb_Sectors     /* sectors per track */
    LONGINT   rdb_Heads       /* number of drive heads */
    LONGINT   rdb_Interleave  /* interleave */
    LONGINT   rdb_Park        /* landing zone cylinder */
    STRING rdb_Reserved2 SIZE 12  /* 3*SIZEOF(LONGINT) */
    LONGINT   rdb_WritePreComp    /* starting cylinder: write precompensation */
    LONGINT   rdb_ReducedWrite    /* starting cylinder: reduced write current */
    LONGINT   rdb_StepRate    /* drive step rate */
    STRING rdb_Reserved3 SIZE 20  /* 5*SIZEOF(LONGINT) */
    /* logical drive characteristics */
    LONGINT   rdb_RDBBlocksLo     /* low block of range reserved for hardblocks */
    LONGINT   rdb_RDBBlocksHi     /* high block of range for these hardblocks */
    LONGINT   rdb_LoCylinder  /* low cylinder of partitionable disk area */
    LONGINT   rdb_HiCylinder  /* high cylinder of partitionable data area */
    LONGINT   rdb_CylBlocks   /* number of blocks available per cylinder */
    LONGINT   rdb_AutoParkSeconds  /* zero for no auto park */
    LONGINT   rdb_HighRDSKBlock   /* highest block used by RDSK */
                /* (not including replacement bad blocks) */
    LONGINT   rdb_Reserved4 
    /* drive identification */
    STRING rdb_DiskVendor SIZE 8  
    STRING rdb_DiskProduct SIZE 16  
    STRING rdb_DiskRevision SIZE 4  
    STRING rdb_ControllerVendor SIZE 8  
    STRING rdb_ControllerProduct SIZE 16  
    STRING rdb_ControllerRevision SIZE 4  
    STRING rdb_Reserved5 SIZE 40  /* 10*SIZEOF(LONGINT) */
END STRUCT 

#define IDNAME_RIGIDDISK    &H5244534B  /* 'RDSK' */

#define RDB_LOCATION_LIMIT  16

#define RDBFB_LAST  0   /* no disks exist to be configured after */
#define RDBFF_LAST  &H01&   /*   this one ON this controller */
#define RDBFB_LASTLUN   1   /* no LUNs exist to be configured greater */
#define RDBFF_LASTLUN   &H02&   /*   than this one at this SCSI Target ID */
#define RDBFB_LASTTID   2   /* no Target IDs exist to be configured */
#define RDBFF_LASTTID   &H04&   /*   greater than this one ON this SCSI bus */
#define RDBFB_NORESELECT 3  /* don't bother trying to perform reselection */
#define RDBFF_NORESELECT &H08&  /*   when talking TO this drive */
#define RDBFB_DISKID    4   /* rdb_Disk... identification valid */
#define RDBFF_DISKID    &H10&
#define RDBFB_CTRLRID   5   /* rdb_Controller... identification valid */
#define RDBFF_CTRLRID   &H20&
                /* added 7/20/89 by commodore: */
#define RDBFB_SYNCH 6   /* drive supports scsi synchronous mode */
#define RDBFF_SYNCH &H40&   /* CAN BE DANGEROUS TO USE IF IT DOESN'T! */

/*------------------------------------------------------------------*/
STRUCT BadBlockEntry  
    LONGINT   bbe_BadBlock    /* block number of bad block */
    LONGINT   bbe_GoodBlock   /* block number of replacement block */
END STRUCT 

STRUCT BadBlockBlock  
    LONGINT   bbb_ID      /* 4 character identifier */
    LONGINT   bbb_SummedLongs     /* size of this checksummed structure */
    LONGINT    bbb_ChkSum      /* block checksum (longword sum to zero) */
    LONGINT   bbb_HostID      /* SCSI Target ID of host */
    LONGINT   bbb_Next        /* block number of the next BadBlockBlock */
    LONGINT   bbb_Reserved 
    STRING bbb_BlockPairs SIZE 488  /* 61*8 */  /* bad block entry pairs */
    /* note [61] assumes 512 byte blocks */
END STRUCT 

#define IDNAME_BADBLOCK     &H42414442  /* 'BADB' */

/*------------------------------------------------------------------*/
STRUCT PartitionBlock  
    LONGINT   pb_ID       /* 4 character identifier */
    LONGINT   pb_SummedLongs  /* size of this checksummed structure */
    LONGINT    pb_ChkSum       /* block checksum (longword sum to zero) */
    LONGINT   pb_HostID       /* SCSI Target ID of host */
    LONGINT   pb_Next         /* block number of the next PartitionBlock */
    LONGINT   pb_Flags        /* see below for defines */
    STRING pb_Reserved1 SIZE 8  /* 2*SIZEOF(LONGINT) */
    LONGINT   pb_DevFlags     /* preferred flags for OpenDevice */
    STRING pb_DriveName SIZE 32     /* preferred DOS device name: ADDRESS form */
                /* (not used if this name is in use) */
    STRING pb_Reserved2 SIZE 60  /* 15*SIZEOF(LONGINT) */   /* filler TO 32 longwords */
    STRING pb_Environment SIZE 68  /* 17*SIZEOF(LONGINT) */ /* environment vector FOR this partition */
    STRING pb_EReserved SIZE 60  /* 15*SIZEOF(LONGINT) */   /* reserved FOR future environment vector */
END STRUCT 

#define IDNAME_PARTITION    &H50415254  /* 'PART' */

#define PBFB_BOOTABLE   0   /* this partition is intended to be bootable */
#define PBFF_BOOTABLE   1&  /*   (expected directories AND FILES exist) */
#define PBFB_NOMOUNT    1   /* do not mount this partition (e.g. manually */
#define PBFF_NOMOUNT    2&  /*   mounted,  but space reserved here) */

/*------------------------------------------------------------------*/
STRUCT FileSysHeaderBlock  
    LONGINT   fhb_ID      /* 4 character identifier */
    LONGINT   fhb_SummedLongs     /* size of this checksummed structure */
    LONGINT    fhb_ChkSum      /* block checksum (longword sum to zero) */
    LONGINT   fhb_HostID      /* SCSI Target ID of host */
    LONGINT   fhb_Next        /* block number of next FileSysHeaderBlock */
    LONGINT   fhb_Flags       /* see below for defines */
    STRING fhb_Reserved1 SIZE 8  /* 2*SIZEOF(LONGINT) */
    LONGINT   fhb_DosType     /* file system description: match this with */
                /* partition environment's DE_DOSTYPE entry */
    LONGINT   fhb_Version     /* release version of this code */
    LONGINT   fhb_PatchFlags  /* bits set for those of the following that */
                /*   need to be substituted into a standard */
                /*   device node for this file system: e.g. */
                /*   &H180 to substitute SegList & GlobalVec */
    LONGINT   fhb_Type        /* device node type: zero */
    LONGINT   fhb_Task        /* standard dos "task" field: zero */
    LONGINT   fhb_Lock        /* not used for devices: zero */
    LONGINT   fhb_Handler     /* filename to loadseg: zero placeholder */
    LONGINT   fhb_StackSize   /* stacksize to use when starting task */
    LONGINT    fhb_Priority    /* task priority when starting task */
    LONGINT    fhb_Startup     /* startup msg: zero placeholder */
    LONGINT    fhb_SegListBlocks   /* first of linked list of LoadSegBlocks: */
                /*   note that this entry requires some */
                /*   processing before substitution */
    LONGINT    fhb_GlobalVec   /* BCPL global vector when starting task */
    STRING fhb_Reserved2 SIZE 92  /* 23*SIZEOF(LONGINT) */  /* (those reserved by PatchFlags) */
    STRING fhb_Reserved3 SIZE 84  /* 21*SIZEOF(LONGINT) */
END STRUCT 

#define IDNAME_FILESYSHEADER    &H46534844  /* 'FSHD' */

/*------------------------------------------------------------------*/
STRUCT LoadSegBlock  
    LONGINT   lsb_ID      /* 4 character identifier */
    LONGINT   lsb_SummedLongs     /* size of this checksummed structure */
    LONGINT    lsb_ChkSum      /* block checksum (longword sum to zero) */
    LONGINT   lsb_HostID      /* SCSI Target ID of host */
    LONGINT   lsb_Next        /* block number of the next LoadSegBlock */
    STRING lsb_LoadData SIZE 492  /* 123*SIZEOF(LONGINT) */  /* DATA FOR "loadseg" */
    /* note [123] assumes 512 byte blocks */
END STRUCT 

#define IDNAME_LOADSEG      &H4C534547  /* 'LSEG' */

#endif  /* DEVICES_HARDBLOCKS_H */
