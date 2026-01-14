#ifndef EXEC_ALERTS_H
#define EXEC_ALERTS_H 1
/*
** alerts.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/02/95
**
**
*/


/*********************************************************************
*
*  Format of the alert error number:
*
*    +-+-------------+----------------+--------------------------------+
*    |D|  SubSysId   OR  General Error OR    SubSystem Specific Error    |
*    +-+-------------+----------------+--------------------------------+
*     1    7 bits      8 bits          16 bits
*
*            D:  DeadEnd alert
*         SubSysId:  indicates ROM subsystem number.
*    General Error:  roughly indicates what the error was
*   Specific Error:  indicates more detail
**********************************************************************/

/**********************************************************************
*
*  Hardware/CPU specific alerts:  They may show without the 8 at the
*  front of the number.  These are CPU/68000 specific.  See 68&H0
*  programmer's manuals for more details.
*
**********************************************************************/
#define ACPU_BusErr &H80000002  /* Hardware bus fault/access error */
#define ACPU_AddressErr &H80000003  /* Illegal address access (ie: odd) */
#define ACPU_InstErr    &H80000004  /* Illegal instruction */
#define ACPU_DivZero    &H80000005  /* Divide by zero */
#define ACPU_CHK    &H80000006  /* Check instruction error */
#define ACPU_TRAPV  &H80000007  /* TrapV instruction error */
#define ACPU_PrivErr    &H80000008  /* Privilege violation error */
#define ACPU_Trace  &H80000009  /* Trace error */
#define ACPU_LineA  &H8000000A  /* Line 1010 Emulator error */
#define ACPU_LineF  &H8000000B  /* Line 1111 Emulator error */
#define ACPU_Format &H8000000E  /* Stack frame format error */
#define ACPU_Spurious   &H80000018  /* Spurious interrupt error */
#define ACPU_AutoVec1   &H80000019  /* AutoVector Level 1 interrupt error */
#define ACPU_AutoVec2   &H8000001A  /* AutoVector Level 2 interrupt error */
#define ACPU_AutoVec3   &H8000001B  /* AutoVector Level 3 interrupt error */
#define ACPU_AutoVec4   &H8000001C  /* AutoVector Level 4 interrupt error */
#define ACPU_AutoVec5   &H8000001D  /* AutoVector Level 5 interrupt error */
#define ACPU_AutoVec6   &H8000001E  /* AutoVector Level 6 interrupt error */
#define ACPU_AutoVec7   &H8000001F  /* AutoVector Level 7 interrupt error */

/*********************************************************************
*
*  General Alerts
*
*  For example: timer.device cannot open math.library would be &H05038015
*
*   Alert(AN_TimerDev|AG_OpenLib|AO_MathLib) 
*
*********************************************************************/

/*------ alert types */
#define AT_DeadEnd  &H80000000
#define AT_Recovery &H00000000

/*------ general purpose alert codes */
#define AG_NoMemory &H00010000
#define AG_MakeLib  &H00020000
#define AG_OpenLib  &H00030000
#define AG_OpenDev  &H00040000
#define AG_OpenRes  &H00050000
#define AG_IOError  &H00060000
#define AG_NoSignal &H00070000
#define AG_BadParm  &H00080000
#define AG_CloseLib &H00090000  /* usually too many closes */
#define AG_CloseDev &H000A0000  /* or a mismatched close */
#define AG_ProcCreate   &H000B0000  /* Process creation failed */

/*------ alert objects: */
#define AO_ExecLib  &H00008001
#define AO_GraphicsLib  &H00008002
#define AO_LayersLib    &H00008003
#define AO_Intuition    &H00008004
#define AO_MathLib  &H00008005
#define AO_DOSLib   &H00008007
#define AO_RAMLib   &H00008008
#define AO_IconLib  &H00008009
#define AO_ExpansionLib &H0000800A
#define AO_DiskfontLib  &H0000800B
#define AO_UtilityLib   &H0000800C
#define AO_KeyMapLib    &H0000800D

#define AO_AudioDev &H00008010
#define AO_ConsoleDev   &H00008011
#define AO_GamePortDev  &H00008012
#define AO_KeyboardDev  &H00008013
#define AO_TrackDiskDev &H00008014
#define AO_TimerDev &H00008015

#define AO_CIARsrc  &H00008020
#define AO_DiskRsrc &H00008021
#define AO_MiscRsrc &H00008022

#define AO_BootStrap    &H00008030
#define AO_Workbench    &H00008031
#define AO_DiskCopy &H00008032
#define AO_GadTools &H00008033
#define AO_Unknown  &H00008035

/*********************************************************************
*
*   Specific Alerts:
*
*   For example:   exec.library -- corrupted memory list
*
*       ALERT  AN_MemCorrupt     8100 0005
*
*********************************************************************/

/*------ exec.library */
#define AN_ExecLib  &H01000000
#define AN_ExcptVect    &H01000001 /* 68000 exception vector checksum (obs.) */
#define AN_BaseChkSum   &H01000002 /* Execbase checksum (obs.) */
#define AN_LibChkSum    &H01000003 /* Library checksum failure */

#define AN_MemCorrupt   &H81000005 /* Corrupt memory list detected in FreeMem */
#define AN_IntrMem  &H81000006 /* No memory for interrupt servers */
#define AN_InitAPtr &H01000007 /* InitStruct() of an ADDRESS source (obs.) */
#define AN_SemCorrupt   &H01000008 /* A semaphore is in an illegal state
                      at ReleaseSemaphore() */
#define AN_FreeTwice    &H01000009 /* Freeing memory already freed */
#define AN_BogusExcpt   &H8100000A /* illegal 68k exception taken (obs.) */
#define AN_IOUsedTwice  &H0100000B /* Attempt to reuse active IORequest */
#define AN_MemoryInsane &H0100000C /* Sanity check on memory list failed
                      during AvailMem(MEMF_LARGEST) */
#define AN_IOAfterClose &H0100000D /* IO attempted on closed IORequest */
#define AN_StackProbe   &H0100000E /* Stack appears to extend out of range */
#define AN_BadFreeAddr  &H0100000F /* Memory header not located. [Usually an
                      invalid address passed to FreeMem()] */
#define AN_BadSemaphore &H01000010 /* An attempt was made to use the old
                      _message semaphores. */

/*------ graphics.library */
#define AN_GraphicsLib  &H02000000
#define AN_GfxNoMem &H82010000  /* graphics out of memory */
#define AN_GfxNoMemMspc &H82010001  /* MonitorSpec alloc,  no memory */
#define AN_LongFrame    &H82010006  /* LONGINT frame,  no memory */
#define AN_ShortFrame   &H82010007  /* SHORTINT frame,  no memory */
#define AN_TextTmpRas   &H02010009  /* text,  no memory for TmpRas */
#define AN_BltBitMap    &H8201000A  /* BltBitMap,  no memory */
#define AN_RegionMemory &H8201000B  /* regions,  memory not available */
#define AN_MakeVPort    &H82010030  /* MakeVPort,  no memory */
#define AN_GfxNewError  &H0200000C
#define AN_GfxFreeError &H0200000D

#define AN_GfxNoLCM &H82011234  /* emergency memory not available */

#define AN_ObsoleteFont &H02000401  /* unsupported font description used */

/*------ layers.library */
#define AN_LayersLib    &H03000000
#define AN_LayersNoMem  &H83010000  /* layers out of memory */

/*------ intuition.library */
#define AN_Intuition    &H04000000
#define AN_GadgetType   &H84000001  /* unknown gadget type */
#define AN_BadGadget    &H04000001  /* Recovery form of AN_GadgetType */
#define AN_CreatePort   &H84010002  /* create port,  no memory */
#define AN_ItemAlloc    &H04010003  /* item plane alloc,  no memory */
#define AN_SubAlloc &H04010004  /* sub alloc,  no memory */
#define AN_PlaneAlloc   &H84010005  /* plane alloc,  no memory */
#define AN_ItemBoxTop   &H84000006  /* item box top < RelZero */
#define AN_OpenScreen   &H84010007  /* open screen,  no memory */
#define AN_OpenScrnRast &H84010008  /* open screen,  raster alloc,  no memory */
#define AN_SysScrnType  &H84000009  /* open sys screen,  unknown type */
#define AN_AddSWGadget  &H8401000A  /* add SW gadgets,  no memory */
#define AN_OpenWindow   &H8401000B  /* open window,  no memory */
#define AN_BadState &H8400000C  /* Bad State Return entering Intuition */
#define AN_BadMessage   &H8400000D  /* Bad Message received by IDCMP */
#define AN_WeirdEcho    &H8400000E  /* Weird echo causing incomprehension */
#define AN_NoConsole    &H8400000F  /* couldn't open the Console Device */
#define AN_NoISem   &H04000010  /* Intuition skipped obtaining a sem */
#define AN_ISemOrder    &H04000011  /* Intuition obtained a sem in bad order */

/*------ math.library */
#define AN_MathLib  &H05000000

/*------ dos.library */
#define AN_DOSLib   &H07000000
#define AN_StartMem &H07010001 /* no memory at startup */
#define AN_EndTask  &H07000002 /* EndTask didn't */
#define AN_QPktFail &H07000003 /* Qpkt failure */
#define AN_AsyncPkt &H07000004 /* Unexpected packet received */
#define AN_FreeVec  &H07000005 /* Freevec failed */
#define AN_DiskBlkSeq   &H07000006 /* Disk block sequence error */
#define AN_BitMap   &H07000007 /* Bitmap corrupt */
#define AN_KeyFree  &H07000008 /* Key already free */
#define AN_BadChkSum    &H07000009 /* Invalid checksum */
#define AN_DiskError    &H0700000A /* Disk Error */
#define AN_KeyRange &H0700000B /* Key out of range */
#define AN_BadOverlay   &H0700000C /* Bad overlay */
#define AN_BadInitFunc  &H0700000D /* Invalid init packet for cli/shell */
#define AN_FileReclosed &H0700000E /* A filehandle was closed more than once */

/*------ ramlib.library */
#define AN_RAMLib   &H08000000
#define AN_BadSegList   &H08000001  /* no overlays in library seglists */

/*------ icon.library */
#define AN_IconLib  &H09000000

/*------ expansion.library */
#define AN_ExpansionLib &H0A000000
#define AN_BadExpansionFree &H0A000001 /* freeed free region */

/*------ diskfont.library */
#define AN_DiskfontLib  &H0B000000

/*------ audio.device */
#define AN_AudioDev &H10000000

/*------ console.device */
#define AN_ConsoleDev   &H11000000
#define AN_NoWindow &H11000001  /* Console can't open initial window */

/*------ gameport.device */
#define AN_GamePortDev  &H12000000

/*------ keyboard.device */
#define AN_KeyboardDev  &H13000000

/*------ trackdisk.device */
#define AN_TrackDiskDev &H14000000
#define AN_TDCalibSeek  &H14000001  /* calibrate: seek error */
#define AN_TDDelay  &H14000002  /* delay: error on timer wait */

/*------ timer.device */
#define AN_TimerDev &H15000000
#define AN_TMBadReq &H15000001 /* bad request */
#define AN_TMBadSupply  &H15000002 /* power supply -- no 50/60Hz ticks */

/*------ cia.resource */
#define AN_CIARsrc  &H20000000

/*------ disk.resource */
#define AN_DiskRsrc &H21000000
#define AN_DRHasDisk    &H21000001  /* get unit: already has disk */
#define AN_DRIntNoAct   &H21000002  /* interrupt: no active unit */

/*------ misc.resource */
#define AN_MiscRsrc &H22000000

/*------ bootstrap */
#define AN_BootStrap    &H30000000
#define AN_BootError    &H30000001  /* boot code returned an error */

/*------ Workbench */
#define AN_Workbench            &H31000000
#define AN_NoFonts          &HB1000001
#define AN_WBBadStartupMsg1     &H31000001
#define AN_WBBadStartupMsg2     &H31000002
#define AN_WBBadIOMsg           &H31000003  /* Hacker code? */
#define AN_WBReLayoutToolMenu       &HB1010009  /* GadTools broke? */

/*------ DiskCopy */
#define AN_DiskCopy &H32000000

/*------ toolkit for Intuition */
#define AN_GadTools &H33000000

/*------ System utility library */
#define AN_UtilityLib   &H34000000

/*------ For use by any application that needs it */
#define AN_Unknown  &H35000000

#endif /* EXEC_ALERTS_H */
