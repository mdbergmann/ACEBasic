#ifndef REXX_RXSLIB_H
#define REXX_RXSLIB_H 1
/*
** rxslib.h for ACE Basic
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
** This are the StructPointer defines for rxslib.h
*/
#ifndef RxsLibPtr
#define RxsLibPtr ADDRESS
#endif
/*
** End of StructPointer defines for rxslib.h
*/


#ifndef REXX_STORAGE_H
#include <rexx/storage.h>
#endif

#define RXSNAME  "rexxsyslib.library"
#define RXSDIR   "REXX"
#define RXSTNAME "ARexx"

/* The REXX systems library structure.  This should be considered as    */
/* semi-private and read-only,  except for documented exceptions.    */

STRUCT RxsLib  
   _Library rl_Node          /* EXEC library node     */
   BYTE     rl_Flags               /* global flags          */
   BYTE     rl_Shadow              /* shadow flags          */
   ADDRESS     rl_SysBase         /* EXEC library base     */
   ADDRESS     rl_DOSBase         /* DOS library base      */
   ADDRESS     rl_IeeeDPBase          /* IEEE DP math library base */
   LONGINT     rl_SegList         /* library seglist       */
   LONGINT     rl_NIL             /* global NIL: filehandle    */
   LONGINT     rl_Chunk               /* allocation quantum        */
   LONGINT     rl_MaxNest         /* maximum expression nesting    */
   NexxStrPtr  rl_NULL         /* static string: NULL       */
   NexxStrPtr  rl_FALSE            /* static string: FALSE      */
   NexxStrPtr  rl_TRUE         /* static string: TRUE       */
   NexxStrPtr  rl_REXX         /* static string: REXX       */
   NexxStrPtr  rl_COMMAND          /* static string: COMMAND    */
   NexxStrPtr  rl_STDIN            /* static string: STDIN      */
   NexxStrPtr  rl_STDOUT           /* static string: STDOUT */
   NexxStrPtr  rl_STDERR           /* static string: STDERR */
   ADDRESS    rl_Version            /* version string        */

   ADDRESS    rl_TaskName           /* name string for tasks */
   LONGINT      rl_TaskPri            /* starting priority     */
   LONGINT      rl_TaskSeg            /* startup seglist       */
   LONGINT      rl_StackSize          /* stack size            */
   ADDRESS    rl_RexxDir            /* REXX directory        */
   ADDRESS    rl_CTABLE         /* character attribute table */
   ADDRESS    rl_Notice         /* copyright notice      */

   MsgPort rl_RexxPort          /* REXX public port      */
   SHORTINT     rl_ReadLock           /* lock count            */
   LONGINT      rl_TraceFH            /* global trace console      */
   _List rl_TaskList         /* REXX task list        */
   SHORTINT      rl_NumTask            /* task count            */
   _List rl_LibList          /* Library List header       */
   SHORTINT      rl_NumLib         /* library count     */
   _List rl_ClipList         /* ClipList header       */
   SHORTINT      rl_NumClip            /* clip node count       */
   _List rl_MsgList          /* pending messages      */
   SHORTINT      rl_NumMsg         /* pending count     */
   _List rl_PgmList          /* cached programs       */
   SHORTINT      rl_NumPgm         /* program count     */

   SHORTINT     rl_TraceCnt           /* usage count for trace console */
   SHORTINT      rl_avail 
   END STRUCT 

/* Global flag bit definitions for RexxMaster               */
#define RLFB_TRACE RTFB_TRACE          /* interactive tracing?      */
#define RLFB_HALT  RTFB_HALT           /* halt execution?       */
#define RLFB_SUSP  RTFB_SUSP           /* suspend execution?        */
#define RLFB_STOP  6               /* deny further invocations  */
#define RLFB_CLOSE 7               /* close the master      */

#define RLFMASK    (1) OR (2) OR (4)

/* Initialization constants                     */
#define RXSCHUNK   1024        /* allocation quantum        */
#define RXSNEST    32              /* expression nesting limit  */
#define RXSTPRI    0               /* task priority     */
#define RXSSTACK   4096        /* stack size            */

/* Character attribute flag bits used in REXX.              */
#define CTB_SPACE   0              /* white space characters    */
#define CTB_DIGIT   1              /* decimal digits 0-9        */
#define CTB_ALPHA   2              /* alphabetic characters */
#define CTB_REXXSYM 3              /* REXX symbol characters    */
#define CTB_REXXOPR 4              /* REXX operator characters  */
#define CTB_REXXSPC 5              /* REXX special symbols      */
#define CTB_UPPER   6              /* UPPERCASE alphabetic      */
#define CTB_LOWER   7              /* lowercase alphabetic      */

/* Attribute flags                          */
#define CTF_SPACE   (1)
#define CTF_DIGIT   (2)
#define CTF_ALPHA   (4)
#define CTF_REXXSYM (8)
#define CTF_REXXOPR (16)
#define CTF_REXXSPC (32)
#define CTF_UPPER   (64)
#define CTF_LOWER   (128)

#endif
