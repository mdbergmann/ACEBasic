#ifndef DEVICES_CD_H
#define DEVICES_CD_H 1
/*
** cd.h for ACE Basic
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
** This are the StructPointer defines for cd.h
*/
#ifndef CDInfoPtr
#define CDInfoPtr ADDRESS
#endif
#ifndef CDTOCPtr
#define CDTOCPtr ADDRESS
#endif
#ifndef CDXLPtr
#define CDXLPtr ADDRESS
#endif
#ifndef LSNMSFPtr
#define LSNMSFPtr ADDRESS
#endif
#ifndef QCodePtr
#define QCodePtr ADDRESS
#endif
#ifndef RMSFPtr
#define RMSFPtr ADDRESS
#endif
#ifndef TOCEntryPtr
#define TOCEntryPtr ADDRESS
#endif
#ifndef TOCSummaryPtr
#define TOCSummaryPtr ADDRESS
#endif
/*
** End of StructPointer defines for cd.h
*/
                     
#include <exec/types.h>
#include <exec/nodes.h>


/**************************************************************************
 *                                    *
 *   CD Commands                              *
 *                                    *
 **************************************************************************/

#define CD_RESET         1
#define CD_READ      2
#define CD_WRITE         3
#define CD_UPDATE        4
#define CD_CLEAR         5
#define CD_STOP      6
#define CD_START         7
#define CD_FLUSH         8
#define CD_MOTOR         9
#define CD_SEEK     10
#define CD_FORMAT       11
#define CD_REMOVE       12
#define CD_CHANGENUM        13
#define CD_CHANGESTATE      14
#define CD_PROTSTATUS       15

#define CD_GETDRIVETYPE     18
#define CD_GETNUMTRACKS     19
#define CD_ADDCHANGEINT     20
#define CD_REMCHANGEINT     21
#define CD_GETGEOMETRY      22
#define CD_EJECT        23


#define CD_INFO     32
#define CD_CONFIG       33
#define CD_TOCMSF       34
#define CD_TOCLSN       35

#define CD_READXL       36

#define CD_PLAYTRACK        37
#define CD_PLAYMSF      38
#define CD_PLAYLSN      39
#define CD_PAUSE        40
#define CD_SEARCH       41

#define CD_QCODEMSF     42
#define CD_QCODELSN     43
#define CD_ATTENUATE        44

#define CD_ADDFRAMEINT      45
#define CD_REMFRAMEINT      46


/**************************************************************************
 *                                    *
 *   Device Driver Error Codes                        *
 *                                    *
 **************************************************************************/

#define CDERR_OPENFAIL       (-1) /* device/unit failed to open   */
#define CDERR_ABORTED        (-2) /* request terminated early         */
#define CDERR_NOCMD      (-3) /* command not supported by device      */
#define CDERR_BADLENGTH      (-4) /* invalid length (IO_LENGTH/IO_OFFSET) */
#define CDERR_BADADDRESS     (-5) /* invalid address (IO_DATA misaligned) */
#define CDERR_UNITBUSY       (-6) /* device opens ok,  but unit is busy    */
#define CDERR_SELFTEST       (-7) /* hardware failed self-test        */

#define CDERR_NotSpecified   20   /* general catchall             */
#define CDERR_NoSecHdr       21   /* couldn't even find a sector      */
#define CDERR_BadSecPreamble 22   /* sector looked wrong          */
#define CDERR_BadSecID       23   /* ditto                */
#define CDERR_BadHdrSum      24   /* header had incorrect checksum    */
#define CDERR_BadSecSum      25   /* data had incorrect checksum      */
#define CDERR_TooFewSecs     26   /* couldn't find enough sectors     */
#define CDERR_BadSecHdr      27   /* another "sector looked wrong"    */
#define CDERR_WriteProt      28   /* can't write to a protected disk      */
#define CDERR_NoDisk         29   /* no disk in the drive         */
#define CDERR_SeekError      30   /* couldn't find track 0        */
#define CDERR_NoMem      31   /* ran out of memory            */
#define CDERR_BadUnitNum     32   /* asked for a unit > NUMUNITS      */
#define CDERR_BadDriveType   33   /* not a drive cd.device understands    */
#define CDERR_DriveInUse     34   /* someone else allocated the drive     */
#define CDERR_PostReset      35   /* user hit reset  awaiting doom    */
#define CDERR_BadDataType    36   /* data on disk is wrong type   */
#define CDERR_InvalidState   37   /* invalid cmd under current conditions */

#define CDERR_Phase      42   /* illegal or unexpected SCSI phase     */
#define CDERR_NoBoard        50   /* open failed for non-existant board   */



/**************************************************************************
 *                                    *
 * Configuration                              *
 *                                    *
 *   The drive is configured by TagList items defined as follows:     *
 *                                    *
 **************************************************************************/

#define TAGCD_PLAYSPEED &H0001
#define TAGCD_READSPEED &H0002
#define TAGCD_READXLSPEED   &H0003
#define TAGCD_SECTORSIZE    &H0004
#define TAGCD_XLECC     &H0005
#define TAGCD_EJECTRESET    &H0006


/**************************************************************************
 *                                    *
 * Information                                *
 *                                    *
 *  Information/Status structure describes current speed settings     *
 *  for read and play commands,  sector size,  audio attenuation    *
 *  precision,  and drive status.                      *
 *                                    *
 **************************************************************************/

STRUCT CDInfo  
                /*                    Default     */
    SHORTINT   PlaySpeed       /* Audio play speed       (75)    */
    SHORTINT   ReadSpeed       /* Data-rate of CD_READ command   (Max)   */
    SHORTINT   ReadXLSpeed     /* Data-rate of CD_READXL command (75)    */
    SHORTINT   SectorSize      /* Number of bytes per sector     (2048)      */
    SHORTINT   XLECC       /* CDXL ECC enabled/disabled          */
    SHORTINT   EjectReset      /* Reset on eject enabled/disabled        */
    STRING Reserved1 SIZE 8    /*  4*SIZEOF(SHORTINT) */   /* Reserved FOR future expansion          */

    SHORTINT   MaxSpeed        /* Maximum speed drive can handle (75,  150)   */
    SHORTINT   AudioPrecision  /* 0 = no attenuator,  1 = mute only,       */
                /* other = (# levels - 1)             */
    SHORTINT   Status      /* See flags below                */
    STRING Reserved2 SIZE 8    /* 4*SIZEOF(SHORTINT)  */  /* Reserved FOR future expansion          */
END STRUCT 


/* Flags for Status */

#define CDSTSB_CLOSED    0 /* Drive door is closed            */
#define CDSTSB_DISK  1 /* A disk has been detected            */
#define CDSTSB_SPIN  2 /* Disk is spinning (motor is on)          */
#define CDSTSB_TOC   3 /* Table of contents read.  Disk is valid.     */
#define CDSTSB_CDROM     4 /* Track 1 contains CD-ROM data        */
#define CDSTSB_PLAYING   5 /* Audio is playing                */
#define CDSTSB_PAUSED    6 /* Pause mode (pauses on play command)     */
#define CDSTSB_SEARCH    7 /* Search mode (Fast Forward/Fast Reverse)     */
#define CDSTSB_DIRECTION 8 /* Search direction (0 = Forward,  1 = Reverse) */

#define CDSTSF_CLOSED    &H0001
#define CDSTSF_DISK  &H0002
#define CDSTSF_SPIN  &H0004
#define CDSTSF_TOC   &H0008
#define CDSTSF_CDROM     &H0010
#define CDSTSF_PLAYING   &H0020
#define CDSTSF_PAUSED    &H0040
#define CDSTSF_SEARCH    &H0080
#define CDSTSF_DIRECTION &H0100


/* Modes for CD_SEARCH */

#define CDMODE_NORMAL   0     /* Normal play at current play speed    */
#define CDMODE_FFWD 1     /* Fast forward play (skip-play forward)*/
#define CDMODE_FREV 2     /* Fast reverse play (skip-play reverse)*/


/**************************************************************************
 *                                    *
 * Position Information                       *
 *                                    *
 *  Position information can be described in two forms: MSF and LSN   *
 *  form.  MSF (Minutes,  Seconds,  Frames) form is a time encoding.    *
 *  LSN (Logical Sector Number) form is frame (sector) count.     *
 *  The desired form is selected using the io_Flags field of the      *
 *  IOStdReq structure.  The flags and the STRUCT are described    *
 *  below.                                *
 *                                    *
 **************************************************************************/

STRUCT RMSF  

    BYTE    Reserved        /* Reserved (always zero) */
    BYTE    Minute      /* Minutes (0-72ish)      */
    BYTE    Second      /* Seconds (0-59)         */
    BYTE    Frame       /* Frame   (0-74)         */
END STRUCT 

STRUCT LSNMSF  

    RMSF MSF        /* Minute,  Second,  Frame  */
    LONGINT   LSN         /* Logical Sector Number  */
END STRUCT 


/**************************************************************************
 *                                    *
 * CD Transfer Lists                              *
 *                                    *
 *  A CDXL node is a double link node  however only single linkage    *
 *  is used by the device driver.  If you wish to construct a     *
 *  transfer list manually,  it is only neccessary to define the   *
 *  mln_Succ pointer of the MinNode.  You may also use the Exec   *
 *  list functions by defining a List or MinList structure and by     *
 *  using the AddHead/AddTail functions to create the list.  This     *
 *  will create a double-linked list.  Although a double-linked   *
 *  list is not required by the device driver,  you may wish use it    *
 *  for your own purposes.  Don't forget to initialize the        *
 *  the List/MinList before using it!                 *
 *                                    *
 **************************************************************************/

STRUCT  CDXL  

    MinNode Node         /* double linkage          */
    ADDRESS   Buffer           /* data destination (SHORTINT aligned) */
    LONGINT          Length           /* must be even # bytes        */
    LONGINT          Actual           /* bytes transferred       */
    ADDRESS          IntData          /* interrupt server data segment   */
    ADDRESS   IntCode     /* interrupt server code entry     */
END STRUCT 


/**************************************************************************
 *                                    *
 * CD Table of Contents                       *
 *                                    *
 *  The CD_TOC command returns an array of CDTOC entries.         *
 *  Entry zero contains summary information describing how many   *
 *  tracks the disk has and the play-time of the disk.        *
 *  Entries 1 through N (N = Number of tracks on disk) contain    *
 *  information about the track.                      *
 *                                    *
 **************************************************************************/

STRUCT TOCSummary  

    BYTE     FirstTrack  /* First track on disk (always 1)        */
    BYTE     LastTrack   /* Last track on disk            */
    LSNMSF LeadOut     /* Beginning of lead-out track (end of disk) */
END STRUCT 


STRUCT TOCEntry  

    BYTE     CtlAdr      /* Q-Code info          */
    BYTE     Track       /* Track number             */
    LSNMSF Position    /* Start position of this track */
END STRUCT 


STRUCT CDTOC  

    TOCSummary Summary   /* First entry (0) is summary information */
    TOCEntry Entry     /* Entries 1-N are track entries      */
END STRUCT 



/**************************************************************************
 *                                    *
 * Q-Code Packets                             *
 *                                    *
 *  Q-Code packets are only returned when audio is playing.   *
 *  Currently,  only position packets are returned (ADR_POSITION)      *
 *  The other ADR_ types are almost never encoded on the disk     *
 *  and are of little use anyway.  To avoid making the QCode      *
 *  structure a STRUCT,  these other ADR_ structures are not defined.   *
 *                                    *
 **************************************************************************/

STRUCT QCode  

    BYTE     CtlAdr     /* Data type / QCode type       */
    BYTE     Track  /* Track number         */
    BYTE     Index  /* Track subindex number        */
    BYTE     Zero       /* The "Zero" byte of Q-Code packet */
    LSNMSF TrackPosition  /* Position from start of track     */
    LSNMSF DiskPosition   /* Position from start of disk      */
END STRUCT 


#define CTLADR_CTLMASK &HF0   /* Control field */

#define CTL_CTLMASK    &HD0   /* To be ANDed with CtlAdr before compared  */

#define CTL_2AUD       &H00   /* 2 audio channels without preemphasis     */
#define CTL_2AUDEMPH   &H10   /* 2 audio channels with preemphasis    */
#define CTL_4AUD       &H80   /* 4 audio channels without preemphasis     */
#define CTL_4AUDEMPH   &H90   /* 4 audio channels with preemphasis    */
#define CTL_DATA       &H40   /* CD-ROM Data                  */

#define CTL_COPYMASK   &H20   /* To be ANDed with CtlAdr before compared  */

#define CTL_COPY       &H20   /* When true,  this audio/data can be copied */

#define CTLADR_ADRMASK &H0F   /* Address field                */

#define ADR_POSITION   &H01   /* Q-Code is position information   */
#define ADR_UPC        &H02   /* Q-Code is UPC information (not used)     */
#define ADR_ISRC       &H03   /* Q-Code is ISRC (not used)        */
#define ADR_HYBRID     &H05   /* This disk is a hybrid disk       */


#endif
