#ifndef EXEC_EXECBASE_H
#define EXEC_EXECBASE_H 1
/*
** execbase.h for ACE Basic
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
** This are the StructPointer defines for execbase.h
*/
#ifndef ExecBasePtr
#define ExecBasePtr ADDRESS
#endif
/*
** End of StructPointer defines for execbase.h
*/
      
#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif /* EXEC_LISTS_H */

#ifndef EXEC_INTERRUPTS_H
#include <exec/interrupts.h>
#endif /* EXEC_INTERRUPTS_H */

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */

#ifndef EXEC_TASKS_H
#include <exec/tasks.h>
#endif /* EXEC_TASKS_H */


/* Definition of the Exec library base structure (pointed to by location 4).
** Most fields are not to be viewed or modified by user programs.  Use
** extreme caution.
*/
STRUCT ExecBase  
    _Library LibNode  /* Standard library node */

/******** Static System Variables ********/

    SHORTINT   SoftVer     /* kickstart release number (obs.) */
    SHORTINT    LowMemChkSum    /* checksum of 68000 trap vectors */
    LONGINT   ChkBase     /* system base pointer complement */
    ADDRESS    ColdCapture     /* coldstart soft capture vector */
    ADDRESS    CoolCapture     /* coolstart soft capture vector */
    ADDRESS    WarmCapture     /* warmstart soft capture vector */
    ADDRESS    SysStkUpper     /* system stack base   (upper bound) */
    ADDRESS    SysStkLower     /* top of system stack (lower bound) */
    LONGINT   MaxLocMem   /* top of chip memory */
    ADDRESS    DebugEntry  /* global debugger entry point */
    ADDRESS    DebugData   /* global debugger data segment */
    ADDRESS    AlertData   /* alert data segment */
    ADDRESS    MaxExtMem   /* top of extended mem,  or null if none */

    SHORTINT   ChkSum  /* for all of the above (minus 2) */

/****** Interrupt Related ***************************************/

    STRING IntVects SIZE 192  /* 16*12  */

/****** Dynamic System Variables *************************************/

    TaskPtr  ThisTask  /* pointer to current task (readable) */

    LONGINT   IdleCount   /* idle counter */
    LONGINT   DispCount   /* dispatch counter */
    SHORTINT   Quantum     /* time slice quantum */
    SHORTINT   Elapsed     /* current quantum ticks */
    SHORTINT   SysFlags    /* misc internal system flags */
    BYTE    IDNestCnt   /* interrupt disable nesting count */
    BYTE    TDNestCnt   /* task disable nesting count */

    SHORTINT   AttnFlags   /* special attention flags (readable) */

    SHORTINT   AttnResched     /* rescheduling attention */
    ADDRESS    ResModules  /* resident module array pointer */
    ADDRESS    TaskTrapCode 
    ADDRESS    TaskExceptCode 
    ADDRESS    TaskExitCode 
    LONGINT   TaskSigAlloc 
    SHORTINT   TaskTrapAlloc 


/****** System Lists (private!) ********************************/

    _List MemList 
    _List ResourceList 
    _List DeviceList 
    _List IntrList 
    _List LibList 
    _List PortList 
    _List TaskReady 
    _List TaskWait 

    STRING SoftInts SIZE 80  /* 5*16 */

/****** Other Globals *******************************************/

    STRING LastAlert SIZE 16   /* 4*SIZEOF(LONGINT)  */

    /* these next two variables are provided to allow
    ** system developers to have a rough idea of the
    ** period of two externally controlled signals --
    ** the time between vertical blank interrupts and the
    ** external line rate (which is counted by CIA A's
    ** "time of day" clock).  In general these values
    ** will be 50 or 60,  and may or may not track each
    ** other.  These values replace the obsolete AFB_PAL
    ** and AFB_50HZ flags.
    */
    BYTE    VBlankFrequency     /* (readable) */
    BYTE    PowerSupplyFrequency    /* (readable) */

    _List SemaphoreList 

    /* these next two are to be able to kickstart into user ram.
    ** KickMemPtr holds a singly linked list of MemLists which
    ** will be removed from the memory list via AllocAbs.  If
    ** all the AllocAbs's succeeded,  then the KickTagPtr will
    ** be added to the rom tag list.
    */
    ADDRESS    KickMemPtr  /* ptr to queue of mem lists */
    ADDRESS    KickTagPtr  /* ptr to rom tag queue */
    ADDRESS    KickCheckSum    /* checksum for mem and tags */

/****** V36 Exec additions start here **************************************/

    SHORTINT   ex_Pad0         /* Private internal use */
    LONGINT   ex_LaunchPoint      /* Private to Launch/Switch */
    ADDRESS    ex_RamLibPrivate 
    /* The next LONGINT contains the system "E" clock frequency, 
    ** expressed in Hertz.  The E clock is used as a timebase for
    ** the Amiga's 8520 I/O chips. (E is connected to "02").
    ** Typical values are 715909 for NTSC,  or 709379 for PAL.
    */
    LONGINT   ex_EClockFrequency  /* (readable) */
    LONGINT   ex_CacheControl     /* Private to CacheControl calls */
    LONGINT   ex_TaskID       /* Next available task ID */

    STRING ex_Reserved1 SIZE 20  /* 5*SIZEOF(LONGINT) */

    ADDRESS    ex_MMULock      /* private */

    STRING ex_Reserved2 SIZE 12   /* 3*SIZEOF(LONGINT)  */

/****** V39 Exec additions start here **************************************/

    /* The following list and data element are used
     * for V39 exec's low memory handler...
     */
    MinList ex_MemHandlers  /* The handler list */
    ADDRESS    ex_MemHandler       /* Private! handler pointer */
END STRUCT 


/****** Bit defines for AttnFlags (see above) ******************************/

/*  Processors and Co-processors: */
#define AFB_68010   0   /* also set for 68020 */
#define AFB_68020   1   /* also set for 68030 */
#define AFB_68030   2   /* also set for 68040 */
#define AFB_68040   3
#define AFB_68881   4   /* also set for 68882 */
#define AFB_68882   5
#define AFB_FPU40   6   /* Set if 68040 FPU */
/*
 * The AFB_FPU40 bit is set when a working 68040 FPU
 * is in the system.  If this bit is set and both the
 * AFB_68881 and AFB_68882 bits are not set,  then the 68040
 * math emulation code has not been loaded and only 68040
 * FPU instructions are available.  This bit is valid *ONLY*
 * if the AFB_68040 bit is set.
 */

#define AFB_PRIVATE 15  /* Just what it says */

#define AFF_68010   (1&)
#define AFF_68020   (2&)
#define AFF_68030   (4&)
#define AFF_68040   (8&)
#define AFF_68881   (16&)
#define AFF_68882   (32&)
#define AFF_FPU40   (64&)

#define AFF_PRIVATE (32768&)

/* #define AFB_RESERVED8   8 */
/* #define AFB_RESERVED9   9 */


/****** Selected flag definitions for Cache manipulation calls **********/

#define CACRF_EnableI       (1&)  /* Enable instruction cache */
#define CACRF_FreezeI       (2&)  /* Freeze instruction cache */
#define CACRF_ClearI        (8&)  /* Clear instruction cache  */
#define CACRF_IBE       (16&)  /* Instruction burst enable */
#define CACRF_EnableD       (256&)  /* 68030 Enable data cache  */
#define CACRF_FreezeD       (512&)  /* 68030 Freeze data cache  */
#define CACRF_ClearD        (2048&) /* 68030 Clear data cache   */
#define CACRF_DBE       (4096&) /* 68030 Data burst enable */
#define CACRF_WriteAllocate (8192&) /* 68030 Write-Allocate mode
                    (must always be set!)    */
#define CACRF_EnableE       (1073741824&) /* Master enable for external caches */
                     /* External caches should track the */
                     /* state of the internal caches */
                     /* such that they do not cache anything */
                     /* that the internal cache turned off */
                     /* for. */
#define CACRF_CopyBack      (2147483648&) /* Master enable for copyback caches */

#define DMA_Continue        (2&)  /* Continuation flag for CachePreDMA */
#define DMA_NoModify        (4&)  /* Set if DMA does not update memory */
#define DMA_ReadFromRAM     (8&)  /* Set IF DMA goes *FROM* RAM TO device */


#endif  /* EXEC_EXECBASE_H */
