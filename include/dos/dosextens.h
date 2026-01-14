#ifndef DOS_DOSEXTENS_H
#define DOS_DOSEXTENS_H 1
/*
** dosextens.h for ACE Basic
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
** This are the StructPointer defines for dosextens.h
*/
#ifndef AssignListPtr
#define AssignListPtr ADDRESS
#endif
#ifndef CliProcListPtr
#define CliProcListPtr ADDRESS
#endif
#ifndef CommandLineInterfacePtr
#define CommandLineInterfacePtr ADDRESS
#endif
#ifndef DevInfoPtr
#define DevInfoPtr ADDRESS
#endif
#ifndef DevProcPtr
#define DevProcPtr ADDRESS
#endif
#ifndef DeviceListPtr
#define DeviceListPtr ADDRESS
#endif
#ifndef DosInfoPtr
#define DosInfoPtr ADDRESS
#endif
#ifndef DosLibraryPtr
#define DosLibraryPtr ADDRESS
#endif
#ifndef DosListPtr
#define DosListPtr ADDRESS
#endif
#ifndef DosPacketPtr
#define DosPacketPtr ADDRESS
#endif
#ifndef ErrorStringPtr
#define ErrorStringPtr ADDRESS
#endif
#ifndef FileHandlePtr
#define FileHandlePtr ADDRESS
#endif
#ifndef FileLockPtr
#define FileLockPtr ADDRESS
#endif
#ifndef ProcessPtr
#define ProcessPtr ADDRESS
#endif
#ifndef RootNodePtr
#define RootNodePtr ADDRESS
#endif
#ifndef SegmentPtr
#define SegmentPtr ADDRESS
#endif
#ifndef StandardPacketPtr
#define StandardPacketPtr ADDRESS
#endif
#ifndef dol_assign_StructPtr
#define dol_assign_StructPtr ADDRESS
#endif
#ifndef dol_handler_StructPtr
#define dol_handler_StructPtr ADDRESS
#endif
#ifndef dol_volume_StructPtr
#define dol_volume_StructPtr ADDRESS
#endif
/*
** End of StructPointer defines for dosextens.h
*/
                 
#ifndef EXEC_TASKS_H
#include <exec/tasks.h>
#endif
#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif
#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#ifndef EXEC_SEMAPHORES_H
#include <exec/semaphores.h>
#endif
#ifndef DEVICES_TIMER_H
#include <devices/timer.h>
#endif

#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif



/* All DOS processes have this structure */
/* Create and Device Proc returns pointer to the MsgPort in this structure */
/* dev_proc = (STRUCT Process *) (DeviceProc(..) - sizeof(STRUCT Task))  */

STRUCT Process  
    Task pr_Task 
    MsgPort pr_MsgPort  /* This is ADDRESS address from DOS functions  */
    SHORTINT    pr_Pad      /* Remaining variables on 4 byte boundaries */
    ADDRESS    pr_SegList      /* Array of seg lists used by this process  */
    LONGINT    pr_StackSize    /* Size of process stack in bytes       */
    ADDRESS    pr_GlobVec      /* Global vector for this process (BCPL)    */
    LONGINT    pr_TaskNum      /* CLI task number of zero if not a CLI     */
    ADDRESS    pr_StackBase    /* Ptr to high memory end of process stack  */
    LONGINT    pr_Result2      /* Value of secondary result from last call */
    ADDRESS    pr_CurrentDir   /* Lock associated with current directory   */
    ADDRESS    pr_CIS      /* Current CLI Input Stream         */
    ADDRESS    pr_COS      /* Current CLI Output Stream            */
    ADDRESS    pr_ConsoleTask  /* Console handler process for current window*/
    ADDRESS    pr_FileSystemTask   /* File handler process for current drive   */
    ADDRESS    pr_CLI      /* pointer to CommandLineInterface      */
    ADDRESS    pr_ReturnAddr   /* pointer to previous stack frame      */
    ADDRESS    pr_PktWait      /* Function to be called when awaiting msg  */
    ADDRESS    pr_WindowPtr    /* Window for error printing            */

    /* following definitions are new with 2.0 */
    ADDRESS    pr_HomeDir      /* Home directory of executing program      */
    LONGINT    pr_Flags        /* flags telling dos about process      */
    ADDRESS   pr_ExitCode    /* code TO CALL ON EXIT of program OR NULL  */
    LONGINT    pr_ExitData     /* Passed as an argument to pr_ExitCode.    */
    ADDRESS   pr_Arguments   /* Arguments passed to the process at start */
    MinList pr_LocalVars  /* Local environment variables         */
    LONGINT   pr_ShellPrivate     /* for the use of the current shell     */
    ADDRESS    pr_CES      /* Error stream - if NULL,  use pr_COS       */
END STRUCT   /* Process */

/*
 * Flags for pr_Flags
 */
#define PRB_FREESEGLIST     0
#define PRF_FREESEGLIST     1
#define PRB_FREECURRDIR     1
#define PRF_FREECURRDIR     2
#define PRB_FREECLI     2
#define PRF_FREECLI     4
#define PRB_CLOSEINPUT      3
#define PRF_CLOSEINPUT      8
#define PRB_CLOSEOUTPUT     4
#define PRF_CLOSEOUTPUT     16
#define PRB_FREEARGS        5
#define PRF_FREEARGS        32

/* The LONGINT SHORTINT address (ADDRESS) of this structure is returned by
 * Open() and other routines that return a file.  You need only worry
 * about this STRUCT to do async io's via PutMsg() instead of
 * standard file system calls */

STRUCT FileHandle  
   MessagePtr  fh_Link   /* EXEC message          */
   MsgPortPtr  fh_Port   /* Reply port for the packet */
   MsgPortPtr  fh_Type   /* Port to do PutMsg() to
                  * Address is negative if a plain file */
   LONGINT fh_Buf 
   LONGINT fh_Pos 
   LONGINT fh_End 
   LONGINT fh_Funcs 
#define fh_Func1 fh_Funcs
   LONGINT fh_Func2 
   LONGINT fh_Func3 
   LONGINT fh_Args 
#define fh_Arg1 fh_Args
   LONGINT fh_Arg2 
END STRUCT  /* FileHandle */

/* This is the extension to EXEC Messages used by DOS */

STRUCT DosPacket  
   MessagePtr  dp_Link   /* EXEC message          */
   MsgPortPtr  dp_Port   /* Reply port for the packet */
                 /* Must be filled in each send. */
   LONGINT dp_Type          /* See ACTION_... below and
                  * 'R' means Read,  'W' means Write to the
                  * file system */
   LONGINT dp_Res1          /* For file system calls this is the result
                  * that would have been returned by the
                  * function,  e.g. Write ('W') returns actual
                  * length written */
   LONGINT dp_Res2          /* For file system calls this is what would
                  * have been returned by IoErr() */
/*  Device packets common equivalents */
#define dp_Action  dp_Type
#define dp_Status  dp_Res1
#define dp_Status2 dp_Res2
#define dp_BufAddr dp_Arg1
   LONGINT dp_Arg1 
   LONGINT dp_Arg2 
   LONGINT dp_Arg3 
   LONGINT dp_Arg4 
   LONGINT dp_Arg5 
   LONGINT dp_Arg6 
   LONGINT dp_Arg7 
END STRUCT  /* DosPacket */

/* A Packet does not require the Message to be before it in memory,  but
 * for convenience it is useful to associate the two.
 * Also see the function init_std_pkt for initializing this structure */

STRUCT StandardPacket  
   _Message sp_Msg 
   DosPacket sp_Pkt 
END STRUCT  /* StandardPacket */

/* Packet types */
#define ACTION_NIL      0
#define ACTION_STARTUP      0
#define ACTION_GET_BLOCK    2   /* OBSOLETE */
#define ACTION_SET_MAP      4
#define ACTION_DIE      5
#define ACTION_EVENT        6
#define ACTION_CURRENT_VOLUME   7
#define ACTION_LOCATE_OBJECT    8
#define ACTION_RENAME_DISK  9
#define ACTION_WRITE       &H57     /*  'W' */
#define ACTION_READ        &H52     /*  'R' */
#define ACTION_FREE_LOCK    15
#define ACTION_DELETE_OBJECT    16
#define ACTION_RENAME_OBJECT    17
#define ACTION_MORE_CACHE   18
#define ACTION_COPY_DIR     19
#define ACTION_WAIT_CHAR    20
#define ACTION_SET_PROTECT  21
#define ACTION_CREATE_DIR   22
#define ACTION_EXAMINE_OBJECT   23
#define ACTION_EXAMINE_NEXT 24
#define ACTION_DISK_INFO    25
#define ACTION_INFO     26
#define ACTION_FLUSH        27
#define ACTION_SET_COMMENT  28
#define ACTION_PARENT       29
#define ACTION_TIMER        30
#define ACTION_INHIBIT      31
#define ACTION_DISK_TYPE    32
#define ACTION_DISK_CHANGE  33
#define ACTION_SET_DATE     34

#define ACTION_SCREEN_MODE  994

#define ACTION_READ_RETURN  1001
#define ACTION_WRITE_RETURN 1002
#define ACTION_SEEK     1008
#define ACTION_FINDUPDATE   1004
#define ACTION_FINDINPUT    1005
#define ACTION_FINDOUTPUT   1006
#define ACTION_END      1007
#define ACTION_SET_FILE_SIZE    1022    /* fast file system only in 1.3 */
#define ACTION_WRITE_PROTECT    1023    /* fast file system only in 1.3 */

/* new 2.0 packets */
#define ACTION_SAME_LOCK    40
#define ACTION_CHANGE_SIGNAL    995
#define ACTION_FORMAT       1020
#define ACTION_MAKE_LINK    1021
/**/
/**/
#define ACTION_READ_LINK    1024
#define ACTION_FH_FROM_LOCK 1026
#define ACTION_IS_FILESYSTEM    1027
#define ACTION_CHANGE_MODE  1028
/**/
#define ACTION_COPY_DIR_FH  1030
#define ACTION_PARENT_FH    1031
#define ACTION_EXAMINE_ALL  1033
#define ACTION_EXAMINE_FH   1034

#define ACTION_LOCK_RECORD  2008
#define ACTION_FREE_RECORD  2009

#define ACTION_ADD_NOTIFY   4097
#define ACTION_REMOVE_NOTIFY    4098

/* Added in V39: */
#define ACTION_EXAMINE_ALL_END  1035
#define ACTION_SET_OWNER    1036

/* Tell a file system to serialize the current volume. This is typically
 * done by changing the creation date of the disk. This packet does not take
 * any arguments.  NOTE: be prepared to handle failure of this packet for
 * V37 ROM filesystems.
 */
#define ACTION_SERIALIZE_DISK   4200

/*
 * A structure for holding error messages - stored as array with error == 0
 * for the last entry.
 */
STRUCT ErrorString  
    ADDRESS   estr_Nums 
    ADDRESS   estr_Strings 
END STRUCT 

/* DOS library node structure.
 * This is the data at positive offsets from the library node.
 * Negative offsets from the node is the jump table to DOS functions
 * node = (STRUCT DosLibrary *) OpenLibrary( "dos.library" .. )      */

STRUCT DosLibrary  
    _Library dl_lib 
    RootNodePtr  dl_Root  /* Pointer to RootNode,  described below */
    ADDRESS    dl_GV         /* Pointer to BCPL global vector        */
    LONGINT    dl_A2         /* BCPL standard register values        */
    LONGINT    dl_A5 
    LONGINT    dl_A6 
    ErrorStringPtr  dl_Errors     /* PRIVATE pointer to array of error msgs */
    timerequestPtr  dl_TimeReq    /* PRIVATE pointer to timer request */
    LibraryPtr  dl_UtilityBase    /* PRIVATE ptr to utility library */
    LibraryPtr  dl_IntuitionBase  /* PRIVATE ptr to intuition library */
END STRUCT   /*  DosLibrary */

/*                 */

STRUCT RootNode  
    ADDRESS    rn_TaskArray         /* [0] is max number of CLI's
                      * [1] is ADDRESS to process id of CLI 1
                      * [n] is ADDRESS to process id of CLI n */
    ADDRESS    rn_ConsoleSegment  /* SegList for the CLI              */
    DateStamp rn_Time  /* Current time                 */
    LONGINT    rn_RestartSeg      /* SegList for the disk validator process   */
    ADDRESS    rn_Info            /* Pointer to the Info structure        */
    ADDRESS    rn_FileHandlerSegment  /* segment for a file handler       */
    MinList rn_CliList  /* new list of all CLI processes */
                   /* the first cpl_Array is also rn_TaskArray */
    MsgPortPtr  rn_BootProc  /* private ptr to msgport of boot fs      */
    ADDRESS    rn_ShellSegment    /* seglist for Shell (for NewShell)     */
    LONGINT    rn_Flags           /* dos flags */
END STRUCT   /* RootNode */

#define RNB_WILDSTAR    24
#define RNF_WILDSTAR    (16777216&)
#define RNB_PRIVATE1    1   /* private for dos */
#define RNF_PRIVATE1    2

/* ONLY to be allocated by DOS! */
STRUCT CliProcList  
    MinNode cpl_Node 
    LONGINT cpl_First       /* number of first entry in array */
    ADDRESS   cpl_Array 
                 /* [0] is max number of CLI's in this entry (n)
                  * [1] is CPTR to process id of CLI cpl_First
                  * [n] is CPTR to process id of CLI cpl_First+n-1
                  */
END STRUCT 

STRUCT DosInfo  
    ADDRESS    di_McName          /* PRIVATE: system resident module list      */
#define di_ResList di_McName
    ADDRESS    di_DevInfo         /* Device List                   */
    ADDRESS    di_Devices         /* Currently zero                */
    ADDRESS    di_Handlers        /* Currently zero                */
    ADDRESS    di_NetHand         /* Network handler processid  currently zero */
    SignalSemaphore di_DevLock     /* do NOT access directly! */
    SignalSemaphore di_EntryLock   /* do NOT access directly! */
    SignalSemaphore di_DeleteLock  /* do NOT access directly! */
END STRUCT   /* DosInfo */

/* structure for the Dos resident list.  Do NOT allocate these,  use   */
/* AddSegment(),  and heed the warnings in the autodocs!           */

STRUCT Segment  
    ADDRESS seg_Next 
    LONGINT seg_UC 
    ADDRESS seg_Seg 
    STRING seg_Name SIZE 4    /* actually the first 4 chars of ADDRESS name */
END STRUCT 

#define CMD_SYSTEM  -1
#define CMD_INTERNAL    -2
#define CMD_DISABLED    -999


/* DOS Processes started from the CLI via RUN or NEWCLI have this additional
 * set to data associated with them */

STRUCT CommandLineInterface  
    LONGINT   cli_Result2         /* Value of IoErr from last command    */
    ADDRESS   cli_SetName         /* Name of current directory       */
    ADDRESS   cli_CommandDir      /* Head of the path locklist       */
    LONGINT   cli_ReturnCode      /* Return code from last command       */
    ADDRESS   cli_CommandName     /* Name of current command         */
    LONGINT   cli_FailLevel       /* Fail level (set by FAILAT)          */
    ADDRESS   cli_Prompt          /* Current prompt (set by PROMPT)      */
    ADDRESS   cli_StandardInput   /* Default (terminal) CLI input        */
    ADDRESS   cli_CurrentInput    /* Current CLI input           */
    ADDRESS   cli_CommandFile     /* Name of EXECUTE command file        */
    LONGINT   cli_Interactive     /* Boolean  True if prompts required   */
    LONGINT   cli_Background      /* Boolean  True if CLI created by RUN     */
    ADDRESS   cli_CurrentOutput   /* Current CLI output              */
    LONGINT   cli_DefaultStack    /* Stack size to be obtained in LONGINT words */
    ADDRESS   cli_StandardOutput  /* Default (terminal) CLI output       */
    ADDRESS   cli_Module          /* SegList of currently loaded command     */
END STRUCT   /* CommandLineInterface */

/* This structure can take on different values depending on whether it is
 * a device,  an assigned directory,  or a volume.  Below is the structure
 * reflecting volumes only.  Following that is the structure representing
 * only devices. Following that is the unioned structure representing all
 * the values
 */

/* structure representing a volume */

STRUCT DeviceList  
    ADDRESS        dl_Next     /* ADDRESS to next device list */
    LONGINT        dl_Type     /* see DLT below */
    MsgPortPtr  dl_Task     /* ptr to handler task */
    ADDRESS        dl_Lock     /* not for volumes */
    DateStamp dl_VolumeDate   /* creation date */
    ADDRESS        dl_LockList     /* outstanding locks */
    LONGINT        dl_DiskType     /* 'DOS',  etc */
    LONGINT        dl_unused 
    ADDRESS        dl_Name     /* ADDRESS to bcpl name */
END STRUCT 

/* device structure (same as the DeviceNode structure in filehandler.h) */

STRUCT DevInfo  
    ADDRESS  dvi_Next 
    LONGINT  dvi_Type 
    ADDRESS  dvi_Task 
    ADDRESS  dvi_Lock 
    ADDRESS  dvi_Handler 
    LONGINT  dvi_StackSize 
    LONGINT  dvi_Priority 
    LONGINT  dvi_Startup 
    ADDRESS  dvi_SegList 
    ADDRESS  dvi_GlobVec 
    ADDRESS  dvi_Name 
END STRUCT 

/* combined structure for devices,  assigned directories,  volumes */

STRUCT dol_handler_Struct  
    ADDRESS    dol_Handler 
    LONGINT    dol_StackSize 
    LONGINT    dol_Priority 
    LONGINT   dol_Startup 
    ADDRESS    dol_SegList 
    ADDRESS    dol_GlobVec 
END STRUCT 

STRUCT dol_volume_Struct  
    DateStamp dol_VolumeDate 
    ADDRESS     dol_LockList 
    LONGINT     dol_DiskType 
END STRUCT 

STRUCT dol_assign_Struct
    ADDRESS   dol_AssignName 
    AssignListPtr  dol_List 
END STRUCT 

STRUCT DosList  
    ADDRESS        dol_Next     /* ADDRESS to next device on list */
    LONGINT        dol_Type     /* see DLT below */
    MsgPortPtr  dol_Task     /* ptr to handler task */
    ADDRESS        dol_Lock 
    STRING dol_Misc SIZE 24  

    ADDRESS        dol_Name     /* ADDRESS to bcpl name */
END STRUCT 

/* structure used for multi-directory assigns. AllocVec()ed. */

STRUCT AssignList  
    AssignListPtr  al_Next 
    ADDRESS           al_Lock 
END STRUCT 

/* definitions for dl_Type */
#define DLT_DEVICE  0
#define DLT_DIRECTORY   1   /* assign */
#define DLT_VOLUME  2
#define DLT_LATE    3   /* late-binding assign */
#define DLT_NONBINDING  4   /* non-binding assign */
#define DLT_PRIVATE -1  /* for internal use only */

/* structure return by GetDeviceProc() */
STRUCT DevProc  
    MsgPortPtr  dvp_Port 
    ADDRESS        dvp_Lock 
    LONGINT       dvp_Flags 
    DosListPtr  dvp_DevNode     /* DON'T TOUCH OR USE! */
END STRUCT 

/* definitions for dvp_Flags */
#define DVPB_UNLOCK 0
#define DVPF_UNLOCK (1&)
#define DVPB_ASSIGN 1
#define DVPF_ASSIGN (2&)

/* Flags to be passed to LockDosList(),  etc */
#define LDB_DEVICES 2
#define LDF_DEVICES (4&)
#define LDB_VOLUMES 3
#define LDF_VOLUMES (8&)
#define LDB_ASSIGNS 4
#define LDF_ASSIGNS (16&)
#define LDB_ENTRY   5
#define LDF_ENTRY   (32&)
#define LDB_DELETE  6
#define LDF_DELETE  (64&)

/* you MUST specify one of LDF_READ or LDF_WRITE */
#define LDB_READ    0
#define LDF_READ    (1&)
#define LDB_WRITE   1
#define LDF_WRITE   (2)

/* actually all but LDF_ENTRY (which is used for internal locking) */
#define LDF_ALL     (LDF_DEVICES OR LDF_VOLUMES OR LDF_ASSIGNS)

/* a lock structure,  as returned by Lock() or DupLock() */
STRUCT FileLock  
    ADDRESS        fl_Link     /* bcpl pointer to next lock */
    LONGINT        fl_Key      /* disk block number */
    LONGINT        fl_Access   /* exclusive or shared */
    MsgPortPtr  fl_Task     /* handler task's port */
    ADDRESS        fl_Volume   /* ADDRESS to DLT_VOLUME DosList entry */
END STRUCT 

/* error report types for ErrorReport() */
#define REPORT_STREAM       0   /* a stream */
#define REPORT_TASK     1   /* a process - unused */
#define REPORT_LOCK     2   /* a lock */
#define REPORT_VOLUME       3   /* a volume node */
#define REPORT_INSERT       4   /* please insert volume */

/* Special error codes for ErrorReport() */
#define ABORT_DISK_ERROR    296 /* Read/write error */
#define ABORT_BUSY      288 /* You MUST replace... */

/* types for initial packets to shells from run/newcli/execute/system. */
/* For shell-writers only */
#define RUN_EXECUTE     -1
#define RUN_SYSTEM      -2
#define RUN_SYSTEM_ASYNCH   -3

/* Types for fib_DirEntryType.  NOTE that both USERDIR and ROOT are  */
/* directories,  and that directory/file checks should use <0 and >=0.    */
/* This is not necessarily exhaustive!  Some handlers may use other  */
/* values as needed,  though <0 and >=0 should remain as supported as     */
/* possible.                                 */
#define ST_ROOT     1
#define ST_USERDIR  2
#define ST_SOFTLINK 3   /* looks like dir,  but may point to a file! */
#define ST_LINKDIR  4   /* hard link to dir */
#define ST_FILE     -3  /* must be negative for FIB! */
#define ST_LINKFILE -4  /* hard link to file */
#define ST_PIPEFILE -5  /* for pipes that support ExamineFH */

#endif  /* DOS_DOSEXTENS_H */
