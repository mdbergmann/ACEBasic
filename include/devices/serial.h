#ifndef DEVICES_SERIAL_H
#define DEVICES_SERIAL_H 1
/*
** serial.h for ACE Basic
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
** This are the StructPointer defines for serial.h
*/
#ifndef IOExtSerPtr
#define IOExtSerPtr ADDRESS
#endif
#ifndef IOTArrayPtr
#define IOTArrayPtr ADDRESS
#endif
/*
** End of StructPointer defines for serial.h
*/
        
#ifndef   EXEC_IO_H
#include <exec/io.h>
#endif /* EXEC_IO_H */


           /* array of termination char's */
           /* to use, see serial.doc setparams */

 STRUCT  IOTArray  
    LONGINT TermArray0 
    LONGINT TermArray1 
END STRUCT 


#define SER_DEFAULT_CTLCHAR &H11130000  /* default chars for xON, xOFF */
/* You may change these via SETPARAMS.  At this time,  parity is not
   calculated _for xON/xOFF characters.  You must supply them with the
   desired parity. */

/******************************************************************/
/* CAUTION !!  IF YOU ACCESS the serial.device,  you MUST (!!!!) use an
   IOExtSer-sized structure or you may overlay innocent memory !! */
/******************************************************************/

 STRUCT  IOExtSer  
    IOStdReq IOSer 

   LONGINT   io_CtlChar     /* control char's (order = xON, xOFF, INQ, ACK) */
   LONGINT   io_RBufLen     /* length in bytes of serial port's read buffer */
   LONGINT   io_ExtFlags    /* additional serial flags (see bitdefs below) */
   LONGINT   io_Baud    /* baud rate requested (true baud) */
   LONGINT   io_BrkTime     /* duration of break signal in MICROseconds */
   IOTArray io_TermArray  /* termination character array */
   BYTE    io_ReadLen     /* bits per read character (# of bits) */
   BYTE    io_WriteLen    /* bits per write character (# of bits) */
   BYTE    io_StopBits    /* stopbits for read (# of bits) */
   BYTE    io_SerFlags    /* see SerFlags bit definitions below  */
   SHORTINT   io_Status 
END STRUCT 
   /* status of serial port,  as follows:
*          BIT  ACTIVE  FUNCTION
*           0    ---    reserved
*           1    ---    reserved
*           2    high   Connected to parallel "select" on the A1000.
*               Connected to both the parallel "select" and
*               serial "ring indicator" pins on the A500
*               & A2000.  Take care when making cables.
*           3    low    Data Set Ready
*           4    low    Clear To Send
*           5    low    Carrier Detect
*           6    low    Ready To Send
*           7    low    Data Terminal Ready
*           8    high   read overrun
*           9    high   break sent
*          10    high   break received
*          11    high   transmit x-OFFed
*          12    high   receive x-OFFed
*       13-15       reserved
*/

#define   SDCMD_QUERY       CMD_NONSTD  /* $09 */
#define   SDCMD_BREAK          (CMD_NONSTD+1)   /* $0A */
#define   SDCMD_SETPARAMS      (CMD_NONSTD+2)   /* $0B */


#define SERB_XDISABLED  7   /* io_SerFlags xOn-xOff feature disabled bit */
#define SERF_XDISABLED  (128)  /*    "     xOn-xOff feature disabled mask */
#define SERB_EOFMODE    6   /*    "     EOF mode enabled bit */
#define SERF_EOFMODE    (64)  /*    "     EOF mode enabled mask */
#define SERB_SHARED 5   /*    "     non-exclusive access bit */
#define SERF_SHARED (32)  /*    "     non-exclusive access mask */
#define SERB_RAD_BOOGIE 4   /*    "     high-speed mode active bit */
#define SERF_RAD_BOOGIE (16)  /*    "     high-speed mode active mask */
#define SERB_QUEUEDBRK  3   /*    "     queue this Break ioRqst */
#define SERF_QUEUEDBRK  (8)  /*    "     queue this Break ioRqst */
#define SERB_7WIRE  2   /*    "     RS232 7-wire protocol */
#define SERF_7WIRE  (4)  /*    "     RS232 7-wire protocol */
#define SERB_PARTY_ODD  1   /*    "     parity feature enabled bit */
#define SERF_PARTY_ODD  (2)  /*    "     parity feature enabled mask */
#define SERB_PARTY_ON   0   /*    "     parity-enabled bit */
#define SERF_PARTY_ON   (1)  /*    "     parity-enabled mask */

/* These now refect the actual bit positions in the io_Status SHORTINT */
#define IO_STATB_XOFFREAD 12       /* io_Status receive currently xOFF'ed bit */
#define IO_STATF_XOFFREAD (4096)  /*    "     receive currently xOFF'ed mask */
#define IO_STATB_XOFFWRITE 11      /*    "     transmit currently xOFF'ed bit */
#define IO_STATF_XOFFWRITE (2048) /*    "     transmit currently xOFF'ed mask */
#define IO_STATB_READBREAK 10      /*    "     break was latest input bit */
#define IO_STATF_READBREAK (1024) /*    "     break was latest input mask */
#define IO_STATB_WROTEBREAK 9      /*    "     break was latest output bit */
#define IO_STATF_WROTEBREAK (512) /*    "     break was latest output mask */
#define IO_STATB_OVERRUN 8     /*    "     status SHORTINT RBF overrun bit */
#define IO_STATF_OVERRUN (256)    /*    "     status SHORTINT RBF overrun mask */


#define SEXTB_MSPON 1   /* io_ExtFlags. Use mark-space parity,  */
                /*      instead of odd-even. */
#define SEXTF_MSPON (2)  /*    "     mark-space parity mask */
#define SEXTB_MARK  0   /*    "     if mark-space,  use mark */
#define SEXTF_MARK  (1)  /*    "     if mark-space,  use mark mask */


#define SerErr_DevBusy         1
#define SerErr_BaudMismatch    2 /* baud rate not supported by hardware */
#define SerErr_BufErr          4 /* Failed to allocate new read buffer */
#define SerErr_InvParam        5
#define SerErr_LineErr         6
#define SerErr_ParityErr       9
#define SerErr_TimerErr       11 /*(See the serial/OpenDevice autodoc)*/
#define SerErr_BufOverflow    12
#define SerErr_NoDSR          13
#define SerErr_DetectedBreak  15


#ifdef DEVICES_SERIAL_H_OBSOLETE
#define SerErr_InvBaud         3    /* unused */
#define SerErr_NotOpen         7    /* unused */
#define SerErr_PortReset       8    /* unused */
#define SerErr_InitErr        10    /* unused */
#define SerErr_NoCTS          14    /* unused */

/* These defines refer to the HIGH ORDER byte of io_Status.  They have
   been replaced by the new,  corrected ones above */
#define IOSTB_XOFFREAD  4   /* iost_hob receive currently xOFF'ed bit */
#define IOSTF_XOFFREAD  (16)  /*    "     receive currently xOFF'ed mask */
#define IOSTB_XOFFWRITE 3   /*    "     transmit currently xOFF'ed bit */
#define IOSTF_XOFFWRITE (8)  /*    "     transmit currently xOFF'ed mask */
#define IOSTB_READBREAK 2   /*    "     break was latest input bit */
#define IOSTF_READBREAK (4)  /*    "     break was latest input mask */
#define IOSTB_WROTEBREAK 1  /*    "     break was latest output bit */
#define IOSTF_WROTEBREAK (2) /*    "     break was latest output mask */
#define IOSTB_OVERRUN   0   /*    "     status SHORTINT RBF overrun bit */
#define IOSTF_OVERRUN   (1)  /*    "     status SHORTINT RBF overrun mask */

#define IOSERB_BUFRREAD 7   /* io_Flags from read buffer bit */
#define IOSERF_BUFRREAD (128)  /*    "     from read buffer mask */
#define IOSERB_QUEUED   6   /*    "     rqst-queued bit */
#define IOSERF_QUEUED   (64)  /*    "     rqst-queued mask */
#define IOSERB_ABORT    5   /*    "     rqst-aborted bit */
#define IOSERF_ABORT    (32)  /*    "     rqst-aborted mask */
#define IOSERB_ACTIVE   4   /*    "     rqst-qued-or-current bit */
#define IOSERF_ACTIVE   (16)  /*    "     rqst-qued-or-current mask */
#endif


#define SERIALNAME     "serial.device"

#endif /* DEVICES_SERIAL_H */
