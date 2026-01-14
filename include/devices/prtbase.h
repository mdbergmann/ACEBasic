#ifndef  DEVICES_PRTBASE_H
#define  DEVICES_PRTBASE_H 1
/*
** prtbase.h for ACE Basic
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
** This are the StructPointer defines for prtbase.h
*/
#ifndef DeviceDataPtr
#define DeviceDataPtr ADDRESS
#endif
#ifndef PrinterDataPtr
#define PrinterDataPtr ADDRESS
#endif
#ifndef PrinterExtendedDataPtr
#define PrinterExtendedDataPtr ADDRESS
#endif
#ifndef PrinterSegmentPtr
#define PrinterSegmentPtr ADDRESS
#endif
/*
** End of StructPointer defines for prtbase.h
*/
       
#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef  EXEC_NODES_H
#include <exec/nodes.h>
#endif
#ifndef  EXEC_LISTS_H
#include <exec/lists.h>
#endif
#ifndef  EXEC_PORTS_H
#include <exec/ports.h>
#endif
#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#ifndef  EXEC_TASKS_H
#include <exec/tasks.h>
#endif

#ifndef  DEVICES_PARALLEL_H
#include <devices/parallel.h>
#endif
#ifndef  DEVICES_SERIAL_H
#include <devices/SERIAL.h>
#endif
#ifndef  DEVICES_TIMER_H
#include <devices/timer.h>
#endif
#ifndef  LIBRARIES_DOSEXTENS_H
#include <libraries/dosextens.h>
#endif
#ifndef  INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif



STRUCT DeviceData  
    _Library dd_Device  /* standard library node */
    ADDRESS dd_Segment           /* A0 when initialized */
    ADDRESS dd_ExecBase          /* A6 for exec */
    ADDRESS dd_CmdVectors        /* command table for device commands */
    ADDRESS dd_CmdBytes          /* bytes describing which command queue */
    SHORTINT   dd_NumCommands    /* the number of commands supported */
END STRUCT 

#define P_OLDSTKSIZE    &H0800  /* stack size for child task (OBSOLETE) */
#define P_STKSIZE   &H1000  /* stack size for child task */
#define P_BUFSIZE   256 /* size of internal buffers for text i/o */
#define P_SAFESIZE  128 /* safety margin for text output buffer */

STRUCT   PrinterData  
    DeviceData pd_Device 
    MsgPort pd_Unit  /* the one and only unit */
    ADDRESS pd_PrinterSegment  /* the printer specific segment */
    SHORTINT pd_PrinterType    /* the segment printer type */
                /* the segment data structure */
    PrinterSegmentPtr  pd_SegmentData 
    ADDRESS   pd_PrintBuf  /* the raster print buffer */
    ADDRESS   pd_PWrite  /* the write function */
    ADDRESS   pd_PBothReady  /* write function's done */
                            /* port I/O request 0 */
    IOExtPar pd_ior0 
#define  pd_PIOR0 pd_ior0.pd_p0
#define  pd_SIOR0 pd_ior0.pd_s0

                            /*   and 1 for double buffering */
    IOExtPar pd_ior1 

#define  pd_PIOR1 pd_ior1.pd_p1
#define  pd_SIOR1 pd_ior1.pd_s1

    timerequest pd_TIOR  /* timer I/O request */
    MsgPort pd_IORPort   /* and message reply port */
    Task pd_TC       /* write task */
    STRING pd_OldStk SIZE &H0800 /* P_OLDSTKSIZE */   /* AND stack space (OBSOLETE) */
    BYTE  pd_Flags          /* device flags */
    BYTE  pd_pad            /* padding */
    Preferences pd_Preferences   /* the latest preferences */
    BYTE  pd_PWaitEnabled       /* wait function switch */
    /* new fields for V2.0 */
    BYTE  pd_Flags1         /* padding */
    STRING pd_Stk SIZE &H1000   /* P_STKSIZE */     /* stack space */
END STRUCT 

/* Printer Class */
#define PPCB_GFX    0   /* graphics (bit position) */
#define PPCF_GFX    &H1 /* graphics (and/or flag) */
#define PPCB_COLOR  1   /* color (bit position) */
#define PPCF_COLOR  &H2 /* color (and/or flag) */

#define PPC_BWALPHA &H00    /* black&white alphanumerics */
#define PPC_BWGFX   &H01    /* black&white graphics */
#define PPC_COLORALPHA  &H02    /* color alphanumerics */
#define PPC_COLORGFX    &H03    /* color graphics */

/* Color Class */
#define PCC_BW      &H01    /* black&white only */
#define PCC_YMC     &H02    /* yellow/magenta/cyan only */
#define PCC_YMC_BW  &H03    /* yellow/magenta/cyan or black&white */
#define PCC_YMCB    &H04    /* yellow/magenta/cyan/black */
#define PCC_4COLOR  &H04    /* a flag for YMCB and BGRW */
#define PCC_ADDITIVE    &H08    /* not ymcb but blue/green/red/white */
#define PCC_WB      &H09    /* black&white only,  0 == BLACK */
#define PCC_BGR     &H0A    /* blue/green/red */
#define PCC_BGR_WB  &H0B    /* blue/green/red or black&white */
#define PCC_BGRW    &H0C    /* blue/green/red/white */
/*
    The picture must be scanned once for each color component,  as the
    printer can only define one color at a time.  ie. If 'PCC_YMC' then
    first pass sends all 'Y' info to printer,  second pass sends all 'M'
    info,  _and third pass sends all C info to printer.  The CalComp
    PlotMaster is an example of this type of printer.
*/
#define PCC_MULTI_PASS  &H10    /* see explanation above */

STRUCT PrinterExtendedData  
    ADDRESS   ped_PrinterName     /* printer name,  null terminated */
    ADDRESS   ped_Init        /* called after LoadSeg */
    ADDRESS   ped_Expunge     /* called before UnLoadSeg */
    ADDRESS   ped_Open        /* called at OpenDevice */
    ADDRESS   ped_Close       /* called at CloseDevice */
    BYTE    ped_PrinterClass     /* printer class */
    BYTE    ped_ColorClass       /* color class */
    BYTE    ped_MaxColumns       /* number of print columns available */
    BYTE    ped_NumCharSets      /* number of character sets */
    SHORTINT   ped_NumRows          /* number of 'pins' in print head */
    LONGINT   ped_MaxXDots         /* number of dots max in a raster dump */
    LONGINT   ped_MaxYDots         /* number of dots max in a raster dump */
    SHORTINT   ped_XDotsInch        /* horizontal dot density */
    SHORTINT   ped_YDotsInch        /* vertical dot density */
    ADDRESS   ped_Commands      /* printer text command table */
    ADDRESS   ped_DoSpecial   /* special command handler */
    ADDRESS   ped_Render      /* raster render function */
    LONGINT    ped_TimeoutSecs      /* good write timeout */
    /* the following only exists if the segment version is >= 33 */
    ADDRESS   ped_8BitChars      /* conv. strings for the extended font */
    LONGINT    ped_PrintMode        /* set if text printed,  otherwise 0 */
    /* the following only exists if the segment version is >= 34 */
    /* ptr to conversion function for all chars */
    ADDRESS   ped_ConvFunc
END STRUCT 

STRUCT PrinterSegment  
    LONGINT   ps_NextSegment   /* (actually a ADDRESS) */
    LONGINT   ps_runAlert      /* MOVEQ #0, D0 : RTS */
    SHORTINT   ps_Version   /* segment version */
    SHORTINT   ps_Revision      /* segment revision */
    PrinterExtendedData ps_PED    /* printer extended data */
END STRUCT 
#endif
