#ifndef LIBRARIES_CONFIGREGS_H
#define LIBRARIES_CONFIGREGS_H 1
/*
** configregs.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/

/*
** This are the StructPointer defines for configregs.h
*/
#ifndef DiagAreaPtr
#define DiagAreaPtr ADDRESS
#endif
#ifndef ExpansionControlPtr
#define ExpansionControlPtr ADDRESS
#endif
#ifndef ExpansionRomPtr
#define ExpansionRomPtr ADDRESS
#endif
/*
** End of StructPointer defines for configregs.h
*/




#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif  /* EXEC_TYPES_H */


/*
** AutoConfig (tm) boards each contain a 32 byte "ExpansionRom" area that is
** read by the system software at configuration time.  Configuration of each
** board starts when the ConfigIn* signal is passed from the previous board
** (or from the system for the first board).  Each board will present it's
** ExpansionRom structure at location $00E80000 to be read by the system.
** This file defines the appearance of the ExpansionRom area.
**
** Expansion boards are actually organized such that only one nybble per
** 16 bit SHORTINT contains valid information.  The low nybbles of each
** SHORTINT are combined to fill the structure below. (This table is structured
** as LOGICAL information.  This means that it never corresponds exactly
** with a physical implementation.)
**
** The ExpansionRom space is further split into two regions:  The first 16
** bytes are read-only.  Except for the er_type field,  this area is inverted
** by the system software when read in.  The second 16 bytes contain the
** control portion,  where all read/write registers are located.
**
** The system builds one "ConfigDev" structure for each board found.  The
** list of boards can be examined using the expansion.library/FindConfigDev
** function.
**
** A special "hacker" Manufacturer ID number is reserved for test use:
** 2011 ($7DB).  When inverted this will look like $F824.
*/

STRUCT ExpansionRom         /* -First 16 bytes of the expansion ROM */
    BYTE    er_Type     /* Board type,  size and flags */
    BYTE    er_Product  /* Product number,  assigned by manufacturer */
    BYTE    er_Flags    /* Flags */
    BYTE    er_Reserved03   /* Must be zero ($ff inverted) */
    SHORTINT   er_Manufacturer  /* Unique ID, ASSIGNED BY COMMODORE-AMIGA! */
    LONGINT   er_SerialNumber  /* Available for use by manufacturer */
    SHORTINT   er_InitDiagVec  /* Offset to optional "DiagArea" structure */
    BYTE    er_Reserved0c 
    BYTE    er_Reserved0d 
    BYTE    er_Reserved0e 
    BYTE    er_Reserved0f 
END STRUCT 


/*
** Note that use of the ec_BaseAddress register is tricky.  The system
** will actually write twice.  First the low order nybble is written
** to the ec_BaseAddress register+2 (D15-D12).  Then the entire byte is
** written to ec_BaseAddress (D15-D8).  This allows writing of a byte-wide
** address to nybble size registers.
*/

STRUCT ExpansionControl     /* -Second 16 bytes of the expansion ROM */
    BYTE    ec_Interrupt    /* Optional interrupt control register */
    BYTE    ec_Z3_HighBase  /* Zorro III   : Config address bits 24-31 */
    BYTE    ec_BaseAddress  /* Zorro II/III: Config address bits 16-23 */
    BYTE    ec_Shutup   /* The system writes here to shut up a board */
    BYTE    ec_Reserved14 
    BYTE    ec_Reserved15 
    BYTE    ec_Reserved16 
    BYTE    ec_Reserved17 
    BYTE    ec_Reserved18 
    BYTE    ec_Reserved19 
    BYTE    ec_Reserved1a 
    BYTE    ec_Reserved1b 
    BYTE    ec_Reserved1c 
    BYTE    ec_Reserved1d 
    BYTE    ec_Reserved1e 
    BYTE    ec_Reserved1f 
END STRUCT 

/*
** many of the constants below consist of a triplet of equivalent
** definitions: xxMASK is a bit mask of those bits that matter.
** xxBIT is the starting bit number of the field.  xxSIZE is the
** number of bits that make up the definition.  This method is
** used when the field is larger than one bit.
**
** If the field is only one bit wide then the xxB_xx and xxF_xx convention
** is used (xxB_xx is the bit number,  and xxF_xx is mask of the bit).
*/

/* manifest constants */
#define E_SLOTSIZE      &H10000
#define E_SLOTMASK      &Hffff
#define E_SLOTSHIFT     16

/* these define the free regions of Zorro memory space.
** THESE MAY WELL CHANGE FOR FUTURE PRODUCTS!
*/
#define E_EXPANSIONBASE &H00e80000  /* Zorro II  config address */
#define EZ3_EXPANSIONBASE   &Hff000000  /* Zorro III config address */

#define E_EXPANSIONSIZE &H00080000  /* Zorro II  I/O type cards */
#define E_EXPANSIONSLOTS    8

#define E_MEMORYBASE        &H00200000  /* Zorro II  8MB space */
#define E_MEMORYSIZE        &H00800000
#define E_MEMORYSLOTS       128

#define EZ3_CONFIGAREA      &H40000000  /* Zorro III space */
#define EZ3_CONFIGAREAEND   &H7FFFFFFF  /* Zorro III space */
#define EZ3_SIZEGRANULARITY &H00080000  /* 512K increments */



/**** er_Type definitions (ttldcmmm) ***************************************/

/* er_Type board type bits -- the OS ignores "old style" boards */
#define ERT_TYPEMASK        &Hc0    /* Bits 7-6 */
#define ERT_TYPEBIT     6
#define ERT_TYPESIZE        2
#define ERT_NEWBOARD        &Hc0
#define ERT_ZORROII     ERT_NEWBOARD
#define ERT_ZORROIII        &H80

/* other bits defined in er_Type */
#define ERTB_MEMLIST        5   /* Link RAM into free memory list */
#define ERTB_DIAGVALID      4   /* ROM vector is valid */
#define ERTB_CHAINEDCONFIG  3   /* Next config is part of the same card */

#define ERTF_MEMLIST        (32)
#define ERTF_DIAGVALID      (16)
#define ERTF_CHAINEDCONFIG  (8)

/* er_Type field memory size bits */
#define ERT_MEMMASK     &H07    /* Bits 2-0 */
#define ERT_MEMBIT      0
#define ERT_MEMSIZE     3



/**** er_Flags byte -- for those things that didn't fit into the type byte ****/
/**** the hardware stores this byte in inverted form               ****/
#define ERFF_MEMSPACE       (128)  /* Wants to be in 8 meg space. */
#define ERFB_MEMSPACE       7   /* (NOT IMPLEMENTED) */

#define ERFF_NOSHUTUP       (64)  /* Board can't be shut up */
#define ERFB_NOSHUTUP       6

#define ERFF_EXTENDED       (32)  /* Zorro III: Use extended size table */
#define ERFB_EXTENDED       5   /*        for bits 0-2 of er_Type */
                    /* Zorro II : Must be 0 */

#define ERFF_ZORRO_III      (16)  /* Zorro III: must be 1 */
#define ERFB_ZORRO_III      4   /* Zorro II : must be 0 */

#define ERT_Z3_SSMASK       &H0F    /* Bits 3-0.  Zorro III Sub-Size.  How */
#define ERT_Z3_SSBIT        0   /* much space the card actually uses   */
#define ERT_Z3_SSSIZE       4   /* (regardless of config granularity)  */
                    /* Zorro II : must be 0        */


/* ec_Interrupt register (unused) ********************************************/
#define ECIB_INTENA     1
#define ECIB_RESET      3
#define ECIB_INT2PEND       4
#define ECIB_INT6PEND       5
#define ECIB_INT7PEND       6
#define ECIB_INTERRUPTING   7

#define ECIF_INTENA     (2)
#define ECIF_RESET      (8)
#define ECIF_INT2PEND       (16)
#define ECIF_INT6PEND       (32)
#define ECIF_INT7PEND       (64)
#define ECIF_INTERRUPTING   (128)



/***************************************************************************
**
** these are the specifications for the diagnostic area.  If the Diagnostic
** Address Valid bit is set in the Board Type byte (the first byte in
** expansion space) then the Diag Init vector contains a valid offset.
**
** The Diag Init vector is actually a SHORTINT offset from the base of the
** board.  The resulting address points to the base of the DiagArea
** structure.  The structure may be physically implemented either four, 
** eight,  or sixteen bits wide.  The code will be copied out into
** ram first before being called.
**
** The da_Size field,  and both code offsets (da_DiagPoint and da_BootPoint)
** are offsets from the diag area AFTER it has been copied into ram,  and
** "de-nibbleized" (if needed).  (In other words,  the size is the size of
** the actual information,  not how much address space is required to
** store it.)
**
** All bits are encoded with uninverted logic (e.g. 5 volts on the bus
** is a logic one).
**
** If your board is to make use of the boot facility then it must leave
** its config area available even after it has been configured.  Your
** boot vector will be called AFTER your board's final address has been
** set.
**
****************************************************************************/

STRUCT DiagArea  
    BYTE    da_Config   /* see below for definitions */
    BYTE    da_Flags    /* see below for definitions */
    SHORTINT   da_Size     /* the size (in bytes) of the total diag area */
    SHORTINT   da_DiagPoint    /* where to start for diagnostics,  or zero */
    SHORTINT   da_BootPoint    /* where to start for booting */
    SHORTINT   da_Name     /* offset in diag area where a string */
                /*   identifier can be found (or zero if no */
                /*   identifier is present). */

    SHORTINT   da_Reserved01   /* two words of reserved data.  must be zero. */
    SHORTINT   da_Reserved02 
END STRUCT 

/* da_Config definitions */
/*
** DAC_BYTEWIDE can be simulated using DAC_NIBBLEWIDE.
*/
#define DAC_BUSWIDTH    &HC0 /* two bits for bus width */
#define DAC_NIBBLEWIDE  &H00
#define DAC_BYTEWIDE    &H40 /* BUG: Will not work under V34 Kickstart! */
#define DAC_WORDWIDE    &H80

#define DAC_BOOTTIME    &H30    /* two bits for when to boot */
#define DAC_NEVER   &H00    /* obvious */
#define DAC_CONFIGTIME  &H10    /* call da_BootPoint when first configing */
                /*   the device */
#define DAC_BINDTIME    &H20    /* run when binding drivers to boards */

/*
**
** These are the calling conventions for the diagnostic callback
** (from da_DiagPoint):
**
** A7 -- points to at least 2K of stack
** A6 -- ExecBase
** A5 -- ExpansionBase
** A3 -- your board's ConfigDev structure
** A2 -- Base of diag/init area that was copied
** A0 -- Base of your board
**
** Your board must return a value in D0.  If this value is NULL,  then
** the diag/init area that was copied in will be returned to the free
** memory pool.
*/


#endif /* LIBRARIES_CONFIGREGS_H */
