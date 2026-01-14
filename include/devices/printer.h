#ifndef     DEVICES_PRINTER_H
#define     DEVICES_PRINTER_H 1
/*
** printer.h for ACE Basic
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
** This are the StructPointer defines for printer.h
*/
#ifndef IODRPReqPtr
#define IODRPReqPtr ADDRESS
#endif
#ifndef IOPrtCmdReqPtr
#define IOPrtCmdReqPtr ADDRESS
#endif
/*
** End of StructPointer defines for printer.h
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


#define  PRD_RAWWRITE      (CMD_NONSTD+0)
#define  PRD_PRTCOMMAND    (CMD_NONSTD+1)
#define  PRD_DUMPRPORT     (CMD_NONSTD+2)
#define  PRD_QUERY     (CMD_NONSTD+3)

/* printer command definitions */

#define aRIS     0  /* ESCc  reset            ISO */
#define aRIN     1  /* ESC#1 initialize       +++ */
#define aIND     2  /* ESCD  lf           ISO */
#define aNEL     3  /* ESCE  return, lf            ISO */
#define aRI  4  /* ESCM  reverse lf       ISO */

#define aSGR0    5  /* ESC[0m normal BYTE set         ISO */
#define aSGR3    6  /* ESC[3m italics on          ISO */
#define aSGR23   7  /* ESC[23m italics off        ISO */
#define aSGR4    8  /* ESC[4m underline on        ISO */
#define aSGR24   9  /* ESC[24m underline off          ISO */
#define aSGR1   10  /* ESC[1m boldface on         ISO */
#define aSGR22  11  /* ESC[22m boldface off       ISO */
#define aSFC    12  /* SGR30-39  set foreground color ISO */
#define aSBC    13  /* SGR40-49  set background color ISO */

#define aSHORP0 14  /* ESC[0w normal pitch        DEC */
#define aSHORP2 15  /* ESC[2w elite on            DEC */
#define aSHORP1 16  /* ESC[1w elite off       DEC */
#define aSHORP4 17  /* ESC[4w condensed fine on       DEC */
#define aSHORP3 18  /* ESC[3w condensed off       DEC */
#define aSHORP6 19  /* ESC[6w enlarged on         DEC */
#define aSHORP5 20  /* ESC[5w enlarged off        DEC */

#define aDEN6   21  /* ESC[6"z shadow print on        DEC (sort of) */
#define aDEN5   22  /* ESC[5"z shadow print off       DEC */
#define aDEN4   23  /* ESC[4"z doublestrike on        DEC */
#define aDEN3   24  /* ESC[3"z doublestrike off       DEC */
#define aDEN2   25  /* ESC[2"z  NLQ on            DEC */
#define aDEN1   26  /* ESC[1"z  NLQ off       DEC */

#define aSUS2   27  /* ESC[2v superscript on          +++ */
#define aSUS1   28  /* ESC[1v superscript off         +++ */
#define aSUS4   29  /* ESC[4v subscript on        +++ */
#define aSUS3   30  /* ESC[3v subscript off       +++ */
#define aSUS0   31  /* ESC[0v normalize the line      +++ */
#define aPLU    32  /* ESCL  partial line up          ISO */
#define aPLD    33  /* ESCK  partial line down        ISO */

#define aFNT0   34  /* ESC(B US BYTE set    or Typeface  0 (default) */
#define aFNT1   35  /* ESC(R French BYTE set    or Typeface  1 */
#define aFNT2   36  /* ESC(K German BYTE set    or Typeface  2 */
#define aFNT3   37  /* ESC(A UK BYTE set    or Typeface  3 */
#define aFNT4   38  /* ESC(E Danish I BYTE set  or Typeface  4 */
#define aFNT5   39  /* ESC(H Sweden BYTE set    or Typeface  5 */
#define aFNT6   40  /* ESC(Y Italian BYTE set   or Typeface  6 */
#define aFNT7   41  /* ESC(Z Spanish BYTE set   or Typeface  7 */
#define aFNT8   42  /* ESC(J Japanese BYTE set  or Typeface  8 */
#define aFNT9   43  /* ESC(6 Norweign BYTE set  or Typeface  9 */
#define aFNT10  44  /* ESC(C Danish II BYTE set or Typeface 10 */

/*
    Suggested typefaces are:

     0 - default typeface.
     1 - Line Printer or equiv.
     2 - Pica or equiv.
     3 - Elite or equiv.
     4 - Helvetica or equiv.
     5 - Times Roman or equiv.
     6 - Gothic or equiv.
     7 - Script or equiv.
     8 - Prestige or equiv.
     9 - Caslon or equiv.
    10 - Orator or equiv.
*/

#define aPROP2  45  /* ESC[2p  proportional on        +++ */
#define aPROP1  46  /* ESC[1p  proportional off       +++ */
#define aPROP0  47  /* ESC[0p  proportional clear     +++ */
#define aTSS    48  /* ESC[n E set proportional offset ISO */
#define aJFY5   49  /* ESC[5 F auto left justify      ISO */
#define aJFY7   50  /* ESC[7 F auto right justify     ISO */
#define aJFY6   51  /* ESC[6 F auto full justify      ISO */
#define aJFY0   52  /* ESC[0 F auto justify off       ISO */
#define aJFY3   53  /* ESC[3 F letter space (justify) ISO (special) */
#define aJFY1   54  /* ESC[1 F SHORTINT fill(auto center) ISO (special) */

#define aVERP0  55  /* ESC[0z  1/8" line spacing      +++ */
#define aVERP1  56  /* ESC[1z  1/6" line spacing      +++ */
#define aSLPP   57  /* ESC[nt  set form length n      DEC */
#define aPERF   58  /* ESC[nq  perf skip n (n>0)      +++ */
#define aPERF0  59  /* ESC[0q  perf skip off          +++ */

#define aLMS    60  /* ESC#9   Left margin set        +++ */
#define aRMS    61  /* ESC#0   Right margin set       +++ */
#define aTMS    62  /* ESC#8   Top margin set         +++ */
#define aBMS    63  /* ESC#2   Bottom marg set        +++ */
#define aSTBM   64  /* ESC[Pn1 Pn2r  T&B margins      DEC */
#define aSLRM   65  /* ESC[Pn1 Pn2s  L&R margin       DEC */
#define aCAM    66  /* ESC#3   Clear margins          +++ */

#define aHTS    67  /* ESCH    Set horiz tab          ISO */
#define aVTS    68  /* ESCJ    Set vertical tabs      ISO */
#define aTBC0   69  /* ESC[0g  Clr horiz tab          ISO */
#define aTBC3   70  /* ESC[3g  Clear all h tab        ISO */
#define aTBC1   71  /* ESC[1g  Clr vertical tabs      ISO */
#define aTBC4   72  /* ESC[4g  Clr all v tabs         ISO */
#define aTBCALL 73  /* ESC#4   Clr all h & v tabs     +++ */
#define aTBSALL 74  /* ESC#5   Set default tabs       +++ */
#define aEXTEND 75  /* ESC[Pn"x extended commands     +++ */

#define aRAW    76  /* ESC[Pn"r Next 'Pn' chars are raw +++ */

STRUCT IOPrtCmdReq  
    _Message io_Message 
    DevicePtr  io_Device      /* device node pointer  */
    UnitPtr  io_Unit        /* unit (driver private)*/
    SHORTINT   io_Command      /* device command */
    BYTE    io_Flags 
    BYTE    io_Error            /* error or warning num */
    SHORTINT   io_PrtCommand       /* printer command */
    BYTE    io_Parm0            /* first command parameter */
    BYTE    io_Parm1            /* second command parameter */
    BYTE    io_Parm2            /* third command parameter */
    BYTE    io_Parm3            /* fourth command parameter */
END STRUCT 

STRUCT IODRPReq  
    _Message io_Message 
    DevicePtr  io_Device      /* device node pointer  */
    UnitPtr  io_Unit        /* unit (driver private)*/
    SHORTINT   io_Command      /* device command */
    BYTE    io_Flags 
    BYTE    io_Error            /* error or warning num */
    RastPortPtr  io_RastPort   /* raster port */
    ColorMapPtr  io_ColorMap   /* color map */
    LONGINT   io_Modes            /* graphics viewport modes */
    SHORTINT   io_SrcX             /* source x origin */
    SHORTINT   io_SrcY             /* source y origin */
    SHORTINT   io_SrcWidth         /* source x width */
    SHORTINT   io_SrcHeight        /* source x height */
    LONGINT    io_DestCols         /* destination x width */
    LONGINT    io_DestRows         /* destination y height */
    SHORTINT   io_Special      /* option flags */
END STRUCT 

#define SPECIAL_MILCOLS     &H0001  /* DestCols specified in 1/1000" */
#define SPECIAL_MILROWS     &H0002  /* DestRows specified in 1/1000" */
#define SPECIAL_FULLCOLS    &H0004  /* make DestCols maximum possible */
#define SPECIAL_FULLROWS    &H0008  /* make DestRows maximum possible */
#define SPECIAL_FRACCOLS    &H0010  /* DestCols is fraction of FULLCOLS */
#define SPECIAL_FRACROWS    &H0020  /* DestRows is fraction of FULLROWS */
#define SPECIAL_CENTER      &H0040  /* center image on paper */
#define SPECIAL_ASPECT      &H0080  /* ensure correct aspect ratio */
#define SPECIAL_DENSITY1    &H0100  /* lowest resolution (dpi) */
#define SPECIAL_DENSITY2    &H0200  /* next res */
#define SPECIAL_DENSITY3    &H0300  /* next res */
#define SPECIAL_DENSITY4    &H0400  /* next res */
#define SPECIAL_DENSITY5    &H0500  /* next res */
#define SPECIAL_DENSITY6    &H0600  /* next res */
#define SPECIAL_DENSITY7    &H0700  /* highest res */
#define SPECIAL_NOFORMFEED  &H0800  /* don't eject paper on gfx prints */
#define SPECIAL_TRUSTME     &H1000  /* don't reset on gfx prints */
/*
    Compute _print size,  set 'io_DestCols' and 'io_DestRows' in the calling
    program's 'IODRPReq' structure and exit,  DON'T PRINT.  This allows the
    calling program to see what the final print size would be in printer
    pixels.  Note that it modifies the 'io_DestCols' and 'io_DestRows'
    fields of your 'IODRPReq' structure.  Also,  set the print density and
    update the 'MaxXDots',  'MaxYDots',  'XDotsInch',  and 'YDotsInch' fields
    of the 'PrinterExtendedData' structure.
*/
#define SPECIAL_NOPRINT     &H2000  /* see above */

#define PDERR_NOERR     0   /* clean exit,  no errors */
#define PDERR_CANCEL        1   /* user cancelled print */
#define PDERR_NOTGRAPHICS   2   /* printer cannot output graphics */
#define PDERR_INVERTHAM     3   /* OBSOLETE */
#define PDERR_BADDIMENSION  4   /* print dimensions illegal */
#define PDERR_DIMENSIONOVFLOW   5   /* OBSOLETE */
#define PDERR_INTERNALMEMORY    6   /* no memory for internal variables */
#define PDERR_BUFFERMEMORY  7   /* no memory for print buffer */
h/*
    Note : this is an internal error that can be returned from the render
    FUNCTION _to the printer device.  It is NEVER returned TO the user.
    IF the printer device sees this ERROR it converts it 'PDERR_NOERR'
    AND exits gracefully.  Refer TO the document ON
    'How TO WRITE a Graphics Printer Driver' FOR more info.
*/
#define PDERR_TOOKCONTROL   8   /* Took control in case 0 of render */

/* internal use */
#define SPECIAL_DENSITYMASK &H0700  /* masks out density values */
#define SPECIAL_DIMENSIONSMASK \
    (SPECIAL_MILCOLS OR SPECIAL_MILROWS OR SPECIAL_FULLCOLS OR SPECIAL_FULLROWS\
    OR SPECIAL_FRACCOLS OR SPECIAL_FRACROWS OR SPECIAL_ASPECT)
#endif
