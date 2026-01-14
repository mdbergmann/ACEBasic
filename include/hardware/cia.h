#ifndef HARDWARE_CIA_H
#define HARDWARE_CIA_H 1
/*
** cia.h for ACE Basic
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
** This are the StructPointer defines for cia.h
*/
#ifndef CIAPtr
#define CIAPtr ADDRESS
#endif
/*
** End of StructPointer defines for cia.h
*/



#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEC_TYPES_H */



/*
 * ciaa is on an ODD address (e.g. the low byte) -- $bfe001
 * ciab is on an EVEN address (e.g. the high byte) -- $bfd000
 *
 * do this to get the definitions:
 *    extern STRUCT CIA ciaa 
             extern ciab 
 */


STRUCT CIA  
    BYTE    ciapra 
    STRING pad0 SIZE &Hff  
    BYTE    ciaprb 
    STRING pad1 SIZE &Hff  
    BYTE    ciaddra 
    STRING pad2 SIZE &Hff  
    BYTE    ciaddrb 
    STRING pad3 SIZE &Hff  
    BYTE    ciatalo 
    STRING pad4 SIZE &Hff  
    BYTE    ciatahi 
    STRING pad5 SIZE &Hff  
    BYTE    ciatblo 
    STRING pad6 SIZE &Hff  
    BYTE    ciatbhi 
    STRING pad7 SIZE &Hff  
    BYTE    ciatodlow 
    STRING pad8 SIZE &Hff  
    BYTE    ciatodmid 
    STRING pad9 SIZE &Hff  
    BYTE    ciatodhi 
    STRING pad10 SIZE &Hff  
    BYTE    unusedreg 
    STRING pad11 SIZE &Hff  
    BYTE    ciasdr 
    STRING pad12 SIZE &Hff  
    BYTE    ciaicr 
    STRING pad13 SIZE &Hff  
    BYTE    ciacra 
    STRING pad14 SIZE &Hff  
    BYTE    ciacrb 
END STRUCT 


/* interrupt control register bit numbers */
#define CIAICRB_TA  0
#define CIAICRB_TB  1
#define CIAICRB_ALRM    2
#define CIAICRB_SP  3
#define CIAICRB_FLG 4
#define CIAICRB_IR  7
#define CIAICRB_SETCLR  7

/* control register A bit numbers */
#define CIACRAB_START   0
#define CIACRAB_PBON    1
#define CIACRAB_OUTMODE 2
#define CIACRAB_RUNMODE 3
#define CIACRAB_LOAD    4
#define CIACRAB_INMODE  5
#define CIACRAB_SPMODE  6
#define CIACRAB_TODIN   7

/* control register B bit numbers */
#define CIACRBB_START   0
#define CIACRBB_PBON    1
#define CIACRBB_OUTMODE 2
#define CIACRBB_RUNMODE 3
#define CIACRBB_LOAD    4
#define CIACRBB_INMODE0 5
#define CIACRBB_INMODE1 6
#define CIACRBB_ALARM   7

/* interrupt control register masks */
#define CIAICRF_TA  (1&)
#define CIAICRF_TB  (2&)
#define CIAICRF_ALRM    (4&)
#define CIAICRF_SP  (8&)
#define CIAICRF_FLG (16&)
#define CIAICRF_IR  (128&)
#define CIAICRF_SETCLR  (128&)

/* control register A register masks */
#define CIACRAF_START   (1&)
#define CIACRAF_PBON    (2&)
#define CIACRAF_OUTMODE (4&)
#define CIACRAF_RUNMODE (8&)
#define CIACRAF_LOAD    (16&)
#define CIACRAF_INMODE  (32&)
#define CIACRAF_SPMODE  (64&)
#define CIACRAF_TODIN   (128&)

/* control register B register masks */
#define CIACRBF_START   (1&)
#define CIACRBF_PBON    (2&)
#define CIACRBF_OUTMODE (4&)
#define CIACRBF_RUNMODE (8&)
#define CIACRBF_LOAD    (16&)
#define CIACRBF_INMODE0 (32&)
#define CIACRBF_INMODE1 (64&)
#define CIACRBF_ALARM   (128&)

/* control register B INMODE masks */
#define CIACRBF_IN_PHI2 0
#define CIACRBF_IN_CNT  (CIACRBF_INMODE0)
#define CIACRBF_IN_TA   (CIACRBF_INMODE1)
#define CIACRBF_IN_CNT_TA  (CIACRBF_INMODE0 OR CIACRBF_INMODE1)

/*
 * Port definitions -- what each bit in a cia peripheral register is tied to
 */

/* ciaa port A (&Hbfe001) */
#define CIAB_GAMEPORT1  (7)   /* gameport 1,  pin 6 (fire button*) */
#define CIAB_GAMEPORT0  (6)   /* gameport 0,  pin 6 (fire button*) */
#define CIAB_DSKRDY (5)   /* disk ready* */
#define CIAB_DSKTRACK0  (4)   /* disk on track 00* */
#define CIAB_DSKPROT    (3)   /* disk write protect* */
#define CIAB_DSKCHANGE  (2)   /* disk change* */
#define CIAB_LED    (1)   /* led light control (0==>bright) */
#define CIAB_OVERLAY    (0)   /* memory overlay bit */

/* ciaa port B (&Hbfe101) -- parallel port */

/* ciab port A (&Hbfd000) -- serial and printer control */
#define CIAB_COMDTR (7)   /* serial Data Terminal Ready* */
#define CIAB_COMRTS (6)   /* serial Request to Send* */
#define CIAB_COMCD  (5)   /* serial Carrier Detect* */
#define CIAB_COMCTS (4)   /* serial Clear to Send* */
#define CIAB_COMDSR (3)   /* serial Data Set Ready* */
#define CIAB_PRTRSEL    (2)   /* printer SELECT */
#define CIAB_PRTRPOUT   (1)   /* printer paper out */
#define CIAB_PRTRBUSY   (0)   /* printer busy */

/* ciab port B (&Hbfd100) -- disk control */
#define CIAB_DSKMOTOR   (7)   /* disk motorr* */
#define CIAB_DSKSEL3    (6)   /* disk select unit 3* */
#define CIAB_DSKSEL2    (5)   /* disk select unit 2* */
#define CIAB_DSKSEL1    (4)   /* disk select unit 1* */
#define CIAB_DSKSEL0    (3)   /* disk select unit 0* */
#define CIAB_DSKSIDE    (2)   /* disk side select* */
#define CIAB_DSKDIREC   (1)   /* disk direction of seek* */
#define CIAB_DSKSTEP    (0)   /* disk step heads* */

/* ciaa port A (&Hbfe001) */
#define CIAF_GAMEPORT1  (128&)
#define CIAF_GAMEPORT0  (64&)
#define CIAF_DSKRDY (32&)
#define CIAF_DSKTRACK0  (16&)
#define CIAF_DSKPROT    (8&)
#define CIAF_DSKCHANGE  (4&)
#define CIAF_LED    (2&)
#define CIAF_OVERLAY    (1&)

/* ciaa port B (&Hbfe101) -- parallel port */

/* ciab port A (&Hbfd000) -- serial and printer control */
#define CIAF_COMDTR (128&)
#define CIAF_COMRTS (64&)
#define CIAF_COMCD  (32&)
#define CIAF_COMCTS (16&)
#define CIAF_COMDSR (8&)
#define CIAF_PRTRSEL    (4&)
#define CIAF_PRTRPOUT   (2&)
#define CIAF_PRTRBUSY   (1&)

/* ciab port B (&Hbfd100) -- disk control */
#define CIAF_DSKMOTOR   (128&)
#define CIAF_DSKSEL3    (64&)
#define CIAF_DSKSEL2    (32&)
#define CIAF_DSKSEL1    (16&)
#define CIAF_DSKSEL0    (8&)
#define CIAF_DSKSIDE    (4&)
#define CIAF_DSKDIREC   (2&)
#define CIAF_DSKSTEP    (1)

#endif  /* HARDWARE_CIA_H */
