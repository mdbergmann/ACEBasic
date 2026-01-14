#ifndef DOS_DOS_H
#define DOS_DOS_H 1
/*
** dos.h for ACE Basic
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
** This are the StructPointer defines for dos.h
*/
#ifndef DateStampPtr
#define DateStampPtr ADDRESS
#endif
#ifndef FileInfoBlockPtr
#define FileInfoBlockPtr ADDRESS
#endif
#ifndef InfoDataPtr
#define InfoDataPtr ADDRESS
#endif
/*
** End of StructPointer defines for dos.h
*/
       
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif



#define  DOSNAME  "dos.library"

/* Predefined Amiga DOS global constants */

#define DOSTRUE (-1&)
#define DOSFALSE (0&)

/* Mode parameter to Open() */
#define MODE_OLDFILE         1005   /* Open existing file read/write
                     * positioned at beginning of file. */
#define MODE_NEWFILE         1006   /* Open freshly created file (delete
                     * old file) read/write,  exclusive lock. */
#define MODE_READWRITE       1004   /* Open old file w/shared lock, 
                     * creates file if doesn't exist. */

/* Relative position to Seek() */
#define OFFSET_BEGINNING    -1      /* relative to Begining Of File */
#define OFFSET_CURRENT       0      /* relative to Current file position */
#define OFFSET_END       1      /* relative to End Of File    */

#define OFFSET_BEGINING     OFFSET_BEGINNING  /* ancient compatibility */

#define BITSPERBYTE      8
#define BYTESPERLONG         4
#define BITSPERLONG      32
#define MAXINT           &H7FFFFFFF
#define MININT           &H80000000

/* Passed as type to Lock() */
#define SHARED_LOCK      -2     /* File is readable by others */
#define ACCESS_READ      -2     /* Synonym */
#define EXCLUSIVE_LOCK       -1     /* No other access allowed    */
#define ACCESS_WRITE         -1     /* Synonym */

STRUCT DateStamp  
   LONGINT  ds_Days          /* Number of days since Jan. 1,  1978 */
   LONGINT  ds_Minute        /* Number of minutes past midnight */
   LONGINT  ds_Tick          /* Number of ticks past minute */
END STRUCT  /* DateStamp */

#define TICKS_PER_SECOND      50   /* Number of ticks in one second */

/* Returned by Examine() and ExNext(),  must be on a 4 byte boundary */
STRUCT FileInfoBlock  
   LONGINT   fib_DiskKey 
   LONGINT   fib_DirEntryType   /* Type of Directory. If < 0,  then a plain file.
                  * If > 0 a directory */
   STRING fib_FileName SIZE 108   /* Null terminated. Max 30 chars used for now */
   LONGINT   fib_Protection     /* bit mask of protection,  rwxd are 3-0.      */
   LONGINT   fib_EntryType 
   LONGINT   fib_Size       /* Number of bytes in file */
   LONGINT   fib_NumBlocks      /* Number of blocks in file */
   DateStamp fib_Date           /* Date file last changed */
   STRING fib_Comment SIZE 80    /* Null terminated comment associated with file */

   /* Note: the following fields are not supported by all filesystems.  */
   /* They should be initialized to 0 sending an ACTION_EXAMINE packet. */
   /* When Examine() is called,  these are set to 0 for you.     */
   /* AllocDosObject() also initializes them to 0.          */
   SHORTINT  fib_OwnerUID      /* owner's UID */
   SHORTINT  fib_OwnerGID      /* owner's GID */

   STRING fib_Reserved SIZE 32  
END STRUCT  /* FileInfoBlock */

/* FIB stands for FileInfoBlock */

/* FIBB are bit definitions,  FIBF are field definitions */
/* Regular RWED bits are 0 == allowed. */
/* NOTE: GRP and OTR RWED permissions are 0 == not allowed! */
/* Group and Other permissions are not directly handled by the filesystem */
#define FIBB_OTR_READ      15   /* Other: file is readable */
#define FIBB_OTR_WRITE     14   /* Other: file is writable */
#define FIBB_OTR_EXECUTE   13   /* Other: file is executable */
#define FIBB_OTR_DELETE    12   /* Other: prevent file from being deleted */
#define FIBB_GRP_READ      11   /* Group: file is readable */
#define FIBB_GRP_WRITE     10   /* Group: file is writable */
#define FIBB_GRP_EXECUTE   9    /* Group: file is executable */
#define FIBB_GRP_DELETE    8    /* Group: prevent file from being deleted */

#define FIBB_SCRIPT    6    /* program is a script (execute) file */
#define FIBB_PURE      5    /* program is reentrant and rexecutable */
#define FIBB_ARCHIVE   4    /* cleared whenever file is changed */
#define FIBB_READ      3    /* ignored by old filesystem */
#define FIBB_WRITE     2    /* ignored by old filesystem */
#define FIBB_EXECUTE   1    /* ignored by system,  used by Shell */
#define FIBB_DELETE    0    /* prevent file from being deleted */

#define FIBF_OTR_READ      (32768)
#define FIBF_OTR_WRITE     (16384)
#define FIBF_OTR_EXECUTE   (8192)
#define FIBF_OTR_DELETE    (4096)
#define FIBF_GRP_READ      (2048)
#define FIBF_GRP_WRITE     (1024)
#define FIBF_GRP_EXECUTE   (512)
#define FIBF_GRP_DELETE    (256)

#define FIBF_SCRIPT    (64)
#define FIBF_PURE      (32)
#define FIBF_ARCHIVE   (16)
#define FIBF_READ      (8)
#define FIBF_WRITE     (4)
#define FIBF_EXECUTE   (2)
#define FIBF_DELETE    (1)

/* Standard maximum length for an error string from fault.  However,  most */
/* error strings should be kept under 60 characters if possible.  Don't   */
/* forget space for the header you pass in. */
#define FAULT_MAX   82


/* BCPL strings have a length in the first byte and then the characters.
 * For example:  s[0]=3 s[1]=S s[2]=Y s[3]=S                 */

/* returned by Info(),  must be on a 4 byte boundary */
STRUCT InfoData  
   LONGINT   id_NumSoftErrors  /* number of soft errors on disk */
   LONGINT   id_UnitNumber     /* Which unit disk is (was) mounted on */
   LONGINT   id_DiskState      /* See defines below */
   LONGINT   id_NumBlocks      /* Number of blocks on disk */
   LONGINT   id_NumBlocksUsed  /* Number of block in use */
   LONGINT   id_BytesPerBlock 
   LONGINT   id_DiskType       /* Disk Type code */
   ADDRESS   id_VolumeNode     /* BCPL pointer to volume node */
   LONGINT   id_InUse      /* Flag,  zero if not in use */
END STRUCT  /* InfoData */

/* ID stands for InfoData */
    /* Disk states */
#define ID_WRITE_PROTECTED 80    /* Disk is write protected */
#define ID_VALIDATING      81    /* Disk is currently being validated */
#define ID_VALIDATED       82    /* Disk is consistent and writeable */

    /* Disk types */
/* ID_INTER_* use international case comparison routines for hashing */
/* Any other new filesystems should also,  if possible. */
#define ID_NO_DISK_PRESENT  (-1)
#define ID_UNREADABLE_DISK  (&H42414400&)   /* 'BAD\0' */
#define ID_DOS_DISK     (&H444F5300&)   /* 'DOS\0' */
#define ID_FFS_DISK     (&H444F5301&)   /* 'DOS\1' */
#define ID_INTER_DOS_DISK   (&H444F5302&)   /* 'DOS\2' */
#define ID_INTER_FFS_DISK   (&H444F5303&)   /* 'DOS\3' */
#define ID_FASTDIR_DOS_DISK (&H444F5304&)   /* 'DOS\4' */
#define ID_FASTDIR_FFS_DISK (&H444F5305&)   /* 'DOS\5' */
#define ID_NOT_REALLY_DOS   (&H4E444F53&)   /* 'NDOS'  */
#define ID_KICKSTART_DISK   (&H4B49434B&)   /* 'KICK'  */
#define ID_MSDOS_DISK       (&H4d534400&)   /* 'MSD\0' */

/* Errors from IoErr(),  etc. */
#define ERROR_NO_FREE_STORE       103
#define ERROR_TASK_TABLE_FULL         105
#define ERROR_BAD_TEMPLATE        114
#define ERROR_BAD_NUMBER          115
#define ERROR_REQUIRED_ARG_MISSING    116
#define ERROR_KEY_NEEDS_ARG       117
#define ERROR_TOO_MANY_ARGS       118
#define ERROR_UNMATCHED_QUOTES        119
#define ERROR_LINE_TOO_LONG       120
#define ERROR_FILE_NOT_OBJECT         121
#define ERROR_INVALID_RESIDENT_LIBRARY    122
#define ERROR_NO_DEFAULT_DIR          201
#define ERROR_OBJECT_IN_USE       202
#define ERROR_OBJECT_EXISTS       203
#define ERROR_DIR_NOT_FOUND       204
#define ERROR_OBJECT_NOT_FOUND        205
#define ERROR_BAD_STREAM_NAME         206
#define ERROR_OBJECT_TOO_LARGE        207
#define ERROR_ACTION_NOT_KNOWN        209
#define ERROR_INVALID_COMPONENT_NAME      210
#define ERROR_INVALID_LOCK        211
#define ERROR_OBJECT_WRONG_TYPE       212
#define ERROR_DISK_NOT_VALIDATED      213
#define ERROR_DISK_WRITE_PROTECTED    214
#define ERROR_RENAME_ACROSS_DEVICES   215
#define ERROR_DIRECTORY_NOT_EMPTY     216
#define ERROR_TOO_MANY_LEVELS         217
#define ERROR_DEVICE_NOT_MOUNTED      218
#define ERROR_SEEK_ERROR          219
#define ERROR_COMMENT_TOO_BIG         220
#define ERROR_DISK_FULL           221
#define ERROR_DELETE_PROTECTED        222
#define ERROR_WRITE_PROTECTED         223
#define ERROR_READ_PROTECTED          224
#define ERROR_NOT_A_DOS_DISK          225
#define ERROR_NO_DISK             226
#define ERROR_NO_MORE_ENTRIES         232
/* added for 1.4 */
#define ERROR_IS_SOFT_LINK        233
#define ERROR_OBJECT_LINKED       234
#define ERROR_BAD_HUNK            235
#define ERROR_NOT_IMPLEMENTED         236
#define ERROR_RECORD_NOT_LOCKED       240
#define ERROR_LOCK_COLLISION          241
#define ERROR_LOCK_TIMEOUT        242
#define ERROR_UNLOCK_ERROR        243

/* error codes 303-305 are defined in dosasl.h */

/* These are the return codes used by convention by AmigaDOS commands */
/* See FAILAT and IF for relvance to EXECUTE files            */
#define RETURN_OK               0  /* No problems,  success */
#define RETURN_WARN             5  /* A warning only */
#define RETURN_ERROR               10  /* Something wrong */
#define RETURN_FAIL            20  /* Complete or severe failure*/

/* Bit numbers that signal you that a user has issued a break */
#define SIGBREAKB_CTRL_C   12
#define SIGBREAKB_CTRL_D   13
#define SIGBREAKB_CTRL_E   14
#define SIGBREAKB_CTRL_F   15

/* Bit fields that signal you that a user has issued a break */
/* for example:  if (SetSignal(0, 0) & SIGBREAKF_CTRL_C) cleanup_and_exit()  */
#define SIGBREAKF_CTRL_C   (4096)
#define SIGBREAKF_CTRL_D   (8192)
#define SIGBREAKF_CTRL_E   (16384)
#define SIGBREAKF_CTRL_F   (32768)

/* Values returned by SameLock() */
#define LOCK_DIFFERENT      -1
#define LOCK_SAME       0
#define LOCK_SAME_VOLUME    1   /* locks are on same volume */
#define LOCK_SAME_HANDLER   LOCK_SAME_VOLUME
/* LOCK_SAME_HANDLER was a misleading name,  def kept for src compatibility */

/* types for ChangeMode() */
#define CHANGE_LOCK 0
#define CHANGE_FH   1

/* Values for MakeLink() */
#define LINK_HARD   0
#define LINK_SOFT   1   /* softlinks are not fully supported yet */

/* values returned by ReadItem */
#define ITEM_EQUAL  -2      /* "=" Symbol */
#define ITEM_ERROR  -1      /* error */
#define ITEM_NOTHING    0       /* *N,   ,  endstreamch */
#define ITEM_UNQUOTED   1       /* unquoted item */
#define ITEM_QUOTED 2       /* quoted item */

/* types for AllocDosObject/FreeDosObject */
#define DOS_FILEHANDLE      0   /* few people should use this */
#define DOS_EXALLCONTROL    1   /* Must be used to allocate this! */
#define DOS_FIB         2   /* useful */
#define DOS_STDPKT      3   /* for doing packet-level I/O */
#define DOS_CLI         4   /* for shell-writers,  etc */
#define DOS_RDARGS      5   /* for ReadArgs if you pass it in */

#endif  /* DOS_DOS_H */

