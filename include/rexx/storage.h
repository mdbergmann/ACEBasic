#ifndef REXX_STORAGE_H
#define REXX_STORAGE_H 1
/*
** storage.h for ACE Basic
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
** This are the StructPointer defines for storage.h
*/
#ifndef NexxStrPtr
#define NexxStrPtr ADDRESS
#endif
#ifndef RexxArgPtr
#define RexxArgPtr ADDRESS
#endif
#ifndef RexxMsgPtr
#define RexxMsgPtr ADDRESS
#endif
#ifndef RexxRsrcPtr
#define RexxRsrcPtr ADDRESS
#endif
#ifndef RexxTaskPtr
#define RexxTaskPtr ADDRESS
#endif
#ifndef SrcNodePtr
#define SrcNodePtr ADDRESS
#endif
/*
** End of StructPointer defines for storage.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

/* The NexxStr structure is used to maintain the internal strings in REXX.
 * It includes the buffer area for the string and associated attributes.
 * This is actually a variable-length structure  it is allocated for a
 * specific length string,  and the length is never modified thereafter
 * (since it's used for recycling).
 */

STRUCT NexxStr  
   LONGINT     ns_Ivalue              /* integer value     */
   SHORTINT    ns_Length              /* length in bytes (excl null)   */
   BYTE     ns_Flags               /* attribute flags       */
   BYTE     ns_Hash                /* hash code         */
   STRING ns_Buff SIZE 8          /* buffer area for strings   */
END STRUCT                       /* SIZE: 16 bytes (minimum)  */

#define NXADDLEN 9             /* offset plus null byte */
#define IVALUE(nsPtr) (nsPtr->ns_Ivalue)

/* String attribute flag bit definitions                */
#define NSB_KEEP     0             /* permanent string?     */
#define NSB_STRING   1             /* string form valid?        */
#define NSB_NOTNUM   2             /* non-numeric?          */
#define NSB_NUMBER   3             /* a valid number?       */
#define NSB_BINARY   4             /* integer value saved?      */
#define NSB_FLOAT    5             /* floating point format?    */
#define NSB_EXT      6             /* an external string?       */
#define NSB_SOURCE   7             /* part of the program source?   */

/* The flag form of the string attributes               */
#define NSF_KEEP     (1)
#define NSF_STRING   (2)
#define NSF_NOTNUM   (4)
#define NSF_NUMBER   (8)
#define NSF_BINARY   (16)
#define NSF_FLOAT    (32)
#define NSF_EXT      (64)
#define NSF_SOURCE   (128)

/* Combinations of flags                        */
#define NSF_INTNUM   (NSF_NUMBER OR NSF_BINARY OR NSF_STRING)
#define NSF_DPNUM    (NSF_NUMBER OR NSF_FLOAT)
#define NSF_ALPHA    (NSF_NOTNUM OR NSF_STRING)
#define NSF_OWNED    (NSF_SOURCE OR NSF_EXT    OR NSF_KEEP)
#define KEEPSTR      (NSF_STRING OR NSF_SOURCE OR NSF_NOTNUM)
#define KEEPNUM      (NSF_STRING OR NSF_SOURCE OR NSF_NUMBER OR NSF_BINARY)

/* The RexxArg structure is identical to the NexxStr structure,  but
 * is allocated from system memory rather than from internal storage.
 * This structure is used for passing arguments to external programs.
 * It is usually passed as an "argstring",  a pointer to the string buffer.
 */

STRUCT RexxArg  
   LONGINT     ra_Size                /* total allocated length    */
   SHORTINT    ra_Length              /* length of string      */
   BYTE     ra_Flags               /* attribute flags       */
   BYTE     ra_Hash                /* hash code         */
   STRING ra_Buff SIZE 8          /* buffer area           */
END STRUCT                       /* SIZE: 16 bytes (minimum)  */

/* The RexxMsg structure is used for all communications with REXX
 * programs.  It is an EXEC message with a parameter block appended.
 */

STRUCT RexxMsg  
   _Message rm_Node          /* EXEC message structure    */
   ADDRESS     rm_TaskBlock           /* global structure (private)    */
   ADDRESS     rm_LibBase         /* library base (private)    */
   LONGINT     rm_Action              /* command (action) code */
   LONGINT     rm_Result1         /* primary result (return code)  */
   LONGINT     rm_Result2         /* secondary result      */
   STRING rm_Args SIZE 64  /* 16*SIZEOF(ADDRESS) */           /* argument block (ARG0-ARG15)   */

   MsgPortPtr  rm_PassPort         /* forwarding port       */
   ADDRESS   rm_CommAddr            /* host address (port name)  */
   ADDRESS   rm_FileExt         /* file extension        */
   LONGINT     rm_Stdin               /* input stream (filehandle) */
   LONGINT     rm_Stdout              /* output stream (filehandle)    */
   LONGINT     rm_avail               /* future expansion      */
END STRUCT                       /* SIZE: 128 bytes       */

/* Field definitions                            */
#define ARG0(rmp) (rmp->rm_Args[0])    /* start of argblock     */
#define ARG1(rmp) (rmp->rm_Args[1])    /* first argument        */
#define ARG2(rmp) (rmp->rm_Args[2])    /* second argument       */

#define MAXRMARG  15               /* maximum arguments     */

/* Command (action) codes for message packets               */
#define RXCOMM    &H01000000           /* a command-level invocation    */
#define RXFUNC    &H02000000           /* a function call       */
#define RXCLOSE   &H03000000           /* close the REXX server */
#define RXQUERY   &H04000000           /* query for information */
#define RXADDFH   &H07000000           /* add a function host       */
#define RXADDLIB  &H08000000           /* add a function library    */
#define RXREMLIB  &H09000000           /* remove a function library */
#define RXADDCON  &H0A000000           /* add/update a ClipList string  */
#define RXREMCON  &H0B000000           /* remove a ClipList string  */
#define RXTCOPN   &H0C000000           /* open the trace console    */
#define RXTCCLS   &H0D000000           /* close the trace console   */

/* Command modifier flag bits                       */
#define RXFB_NOIO    16        /* suppress I/O inheritance? */
#define RXFB_RESULT  17        /* result string expected?   */
#define RXFB_STRING  18        /* program is a "string file"?   */
#define RXFB_TOKEN   19        /* tokenize the command line?    */
#define RXFB_NONRET  20        /* a "no-return" message?    */

/* The flag form of the command modifiers               */
#define RXFF_NOIO    (65536&)
#define RXFF_RESULT  (131072&)
#define RXFF_STRING  (262144&)
#define RXFF_TOKEN   (524288&)
#define RXFF_NONRET  (1048576&)

#define RXCODEMASK   &HFF000000
#define RXARGMASK    &H0000000F

/* The RexxRsrc structure is used to manage global resources.  Each node
 * has a name string created as a RexxArg structure,  and the total size
 * of the node is saved in the "rr_Size" field.  The REXX systems library
 * provides functions to allocate and release resource nodes.  If special
 * deletion operations are required,  an offset and base can be provided in
 * "rr_Func" and "rr_Base",  respectively.  This "autodelete" function will
 * be called with the base in register A6 and the node in A0.
 */

STRUCT RexxRsrc  
   Node rr_Node 
   SHORTINT     rr_Func                /* "auto-delete" offset      */
   ADDRESS     rr_Base                /* "auto-delete" base        */
   LONGINT     rr_Size                /* total size of node        */
   LONGINT     rr_Arg1                /* available ...     */
   LONGINT     rr_Arg2                /* available ...     */
END STRUCT                       /* SIZE: 32 bytes        */

/* Resource node types                          */
#define RRT_ANY      0             /* any node type ...     */
#define RRT_LIB      1             /* a function library        */
#define RRT_PORT     2             /* a public port     */
#define RRT_FILE     3             /* a file IoBuff     */
#define RRT_HOST     4             /* a function host       */
#define RRT_CLIP     5             /* a Clip List node      */

/* The RexxTask structure holds the fields used by REXX to communicate with
 * external processes,  including the client task.  It includes the global
 * data structure (and the base environment).  The structure is passed to
 * the newly-created task in its "wake-up" message.
 */

#define GLOBALSZ  200              /* total size of GlobalData  */

STRUCT RexxTask  
   STRING rt_Global SIZE 200  /* GLOBALSZ */        /* global DATA structure */
   MsgPort rt_MsgPort           /* global message port       */
   BYTE     rt_Flags               /* task flag bits        */
   BYTE     rt_SigBit              /* signal bit            */

   ADDRESS     rt_ClientID            /* the client's task ID      */
   ADDRESS     rt_MsgPkt              /* the packet being processed    */
   ADDRESS     rt_TaskID              /* our task ID           */
   ADDRESS     rt_RexxPort            /* the REXX public port      */

   ADDRESS     rt_ErrTrap         /* Error trap address        */
   ADDRESS     rt_StackPtr            /* stack pointer for traps   */

   _List rt_Header1          /* Environment list      */
   _List rt_Header2          /* Memory freelist       */
   _List rt_Header3          /* Memory allocation list    */
   _List rt_Header4          /* Files list            */
   _List rt_Header5          /* Message Ports List        */
END STRUCT

/* Definitions for RexxTask flag bits                   */
#define RTFB_TRACE   0             /* external trace flag       */
#define RTFB_HALT    1             /* external halt flag        */
#define RTFB_SUSP    2             /* suspend task?     */
#define RTFB_TCUSE   3             /* trace console in use? */
#define RTFB_WAIT    6             /* waiting for reply?        */
#define RTFB_CLOSE   7             /* task completed?       */

/* Definitions for memory allocation constants              */
#define MEMQUANT  16&              /* quantum of memory space   */
#define MEMMASK   &HFFFFFFF0           /* mask for rounding the size    */

#define MEMQUICK  (1&)           /* EXEC flags: MEMF_PUBLIC   */
#define MEMCLEAR  (65536&)           /* EXEC flags: MEMF_CLEAR    */

/* The SrcNode is a temporary structure used to hold values destined for
 * a segment array.  It is also used to maintain the memory freelist.
 */

STRUCT SrcNode  
   SrcNodePtr  sn_Succ         /* next node         */
   SrcNodePtr  sn_Pred         /* previous node     */
   ADDRESS     sn_Ptr             /* pointer value     */
   LONGINT     sn_Size                /* size of object        */
END STRUCT                       /* SIZE: 16 bytes        */

#endif
