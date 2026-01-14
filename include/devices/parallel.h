#ifndef DEVICES_PARALLEL_H
#define DEVICES_PARALLEL_H 1
/*
** parallel.h for ACE Basic
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
** This are the StructPointer defines for parallel.h
*/
#ifndef IOExtParPtr
#define IOExtParPtr ADDRESS
#endif
#ifndef IOPArrayPtr
#define IOPArrayPtr ADDRESS
#endif
/*
** End of StructPointer defines for parallel.h
*/
      
#ifndef   EXEC_IO_H
#include <exec/io.h>
#endif   /* !EXEC_IO_H */


STRUCT  IOPArray
    LONGINT PTermArray0 
    LONGINT PTermArray1 
END STRUCT 

/******************************************************************/
/* CAUTION !!  IF YOU ACCESS the parallel.device,  you MUST (!!!!) use
   an IOExtPar-sized structure or you may overlay innocent memory !! */
/******************************************************************/

 STRUCT   IOExtPar  
    IOStdReq IOPar 

    LONGINT   io_PExtFlags     /* (not used) flag extension area */
    BYTE    io_Status    /* status of parallel port and registers */
    BYTE    io_ParFlags      /* see PARFLAGS bit definitions below */
    IOPArray io_PTermArray  /* termination character array */
END STRUCT 

#define PARB_SHARED 5      /* ParFlags non-exclusive access bit */
#define PARF_SHARED (32)     /*    "     non-exclusive access mask */
#define PARB_SLOWMODE   4      /*    "     slow printer bit */
#define PARF_SLOWMODE   (16)     /*    "     slow printer mask */
#define PARB_FASTMODE   3      /*    "     fast I/O mode selected bit */
#define PARF_FASTMODE   (8)     /*    "     fast I/O mode selected mask */
#define PARB_RAD_BOOGIE 3      /*    "     for backward compatibility */
#define PARF_RAD_BOOGIE (8)     /*    "     for backward compatibility */

#define PARB_ACKMODE    2      /*    "     ACK interrupt handshake bit */
#define PARF_ACKMODE    (4)     /*    "     ACK interrupt handshake mask */

#define PARB_EOFMODE    1      /*    "     EOF mode enabled bit */
#define PARF_EOFMODE    (2)     /*    "     EOF mode enabled mask */

#define IOPARB_QUEUED   6      /* IO_FLAGS rqst-queued bit */
#define IOPARF_QUEUED   (64)     /*    "     rqst-queued mask */
#define IOPARB_ABORT    5      /*    "     rqst-aborted bit */
#define IOPARF_ABORT    (32)     /*    "     rqst-aborted mask */
#define IOPARB_ACTIVE   4      /*    "     rqst-qued-or-current bit */
#define IOPARF_ACTIVE   (16)     /*    "     rqst-qued-or-current mask */
#define IOPTB_RWDIR 3      /* IO_STATUS read=0, write=1 bit */
#define IOPTF_RWDIR (8)     /*    "     read=0, write=1 mask */
#define IOPTB_PARSEL    2      /*    "     printer selected on the A1000 */
#define IOPTF_PARSEL    (4)     /* printer selected & serial "Ring Indicator"
                      _on the A500 & A2000.  Be careful when
                      making cables */
#define IOPTB_PAPEROUT 1       /*    "     paper out bit */
#define IOPTF_PAPEROUT (2)      /*    "     paper out mask */
#define IOPTB_PARBUSY  0       /*    "     printer in busy toggle bit */
#define IOPTF_PARBUSY  (1)      /*    "     printer in busy toggle mask */
/* Note: previous versions of this include files had bits 0 and 2 swapped */

#define PARALLELNAME        "parallel.device"

#define PDCMD_QUERY     (CMD_NONSTD)
#define PDCMD_SETPARAMS (CMD_NONSTD+1)

#define ParErr_DevBusy          1
#define ParErr_BufTooBig    2
#define ParErr_InvParam 3
#define ParErr_LineErr      4
#define ParErr_NotOpen      5
#define ParErr_PortReset    6
#define ParErr_InitErr          7

#endif  /* DEVICES_PARALLEL_H */
