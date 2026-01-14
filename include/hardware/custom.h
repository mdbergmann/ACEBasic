#ifndef HARDWARE_CUSTOM_H
#define HARDWARE_CUSTOM_H 1
/*
** custom.h for ACE Basic
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
** This are the StructPointer defines for custom.h
*/
#ifndef AudChannel_StructPtr
#define AudChannel_StructPtr ADDRESS
#endif
#ifndef CustomPtr
#define CustomPtr ADDRESS
#endif
#ifndef SpriteDef_StructPtr
#define SpriteDef_StructPtr ADDRESS
#endif
/*
** End of StructPointer defines for custom.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEC_TYPES_H */



/*
 * do this to get base of custom registers:
 * extern STRUCT Custom custom 
 */


STRUCT AudChannel_Struct  
      ADDRESS   ac_ptr  /* ptr to start of waveform data */
      SHORTINT ac_len  /* length of waveform in words */
      SHORTINT ac_per  /* sample period */
      SHORTINT ac_vol  /* volume */
      SHORTINT ac_dat  /* sample pair */
      STRING ac_pad SIZE 4   /*  2*SIZEOF(SHORTINT) */  /* unused */
END STRUCT 

STRUCT SpriteDef_Struct  
      SHORTINT _pos 
      SHORTINT ctl 
      SHORTINT dataa 
      SHORTINT datab        
END STRUCT 

STRUCT Custom  
    SHORTINT   bltddat 
    SHORTINT   dmaconr 
    SHORTINT   vposr 
    SHORTINT   vhposr 
    SHORTINT   dskdatr 
    SHORTINT   joy0dat 
    SHORTINT   joy1dat 
    SHORTINT   clxdat 
    SHORTINT   adkconr 
    SHORTINT   pot0dat 
    SHORTINT   pot1dat 
    SHORTINT   potinp 
    SHORTINT   serdatr 
    SHORTINT   dskbytr 
    SHORTINT   intenar 
    SHORTINT   intreqr 
    ADDRESS    dskpt 
    SHORTINT   dsklen 
    SHORTINT   dskdat 
    SHORTINT   refptr 
    SHORTINT   vposw 
    SHORTINT   vhposw 
    SHORTINT   copcon 
    SHORTINT   serdat 
    SHORTINT   serper 
    SHORTINT   potgo 
    SHORTINT   joytest 
    SHORTINT   strequ 
    SHORTINT   strvbl 
    SHORTINT   strhor 
    SHORTINT   strlong 
    SHORTINT   bltcon0 
    SHORTINT   bltcon1 
    SHORTINT   bltafwm 
    SHORTINT   bltalwm 
    ADDRESS    bltcpt 
    ADDRESS    bltbpt 
    ADDRESS    bltapt 
    ADDRESS    bltdpt 
    SHORTINT   bltsize 
    BYTE    pad2d 
    BYTE    bltcon0l    /* low 8 bits of bltcon0,  write only */
    SHORTINT   bltsizv 
    SHORTINT   bltsizh     /* 5e */
    SHORTINT   bltcmod 
    SHORTINT   bltbmod 
    SHORTINT   bltamod 
    SHORTINT   bltdmod 
    STRING pad34 SIZE 8   /*  4*SIZEOF(SHORTINT)  */
    SHORTINT   bltcdat 
    SHORTINT   bltbdat 
    SHORTINT   bltadat 
    STRING pad3b SIZE 6   /*  3*SIZEOF(SHORTINT)  */
    SHORTINT   deniseid    /* 7c */
    SHORTINT   dsksync 
    LONGINT   cop1lc 
    LONGINT   cop2lc 
    SHORTINT   copjmp1 
    SHORTINT   copjmp2 
    SHORTINT   copins 
    SHORTINT   diwstrt 
    SHORTINT   diwstop 
    SHORTINT   ddfstrt 
    SHORTINT   ddfstop 
    SHORTINT   dmacon 
    SHORTINT   clxcon 
    SHORTINT   intena 
    SHORTINT   intreq 
    SHORTINT   adkcon 
    STRING aud SIZE 64
    STRING bplpt SIZE 32  /*  8*SIZEOF(ADDRESS)  */
    SHORTINT   bplcon0 
    SHORTINT   bplcon1 
    SHORTINT   bplcon2 
    SHORTINT   bplcon3 
    SHORTINT   bpl1mod 
    SHORTINT   bpl2mod 
    SHORTINT   bplcon4 
    SHORTINT   clxcon2 
    STRING bpldat SIZE 16  /*  8*SIZEOF(SHORTINT) */
    STRING sprpt SIZE 32   /*  8*SIZEOF(ADDRESS)  */
    STRING spr SIZE 64
    STRING _color SIZE 64  /*  32*SIZEOF(SHORTINT)*/
    SHORTINT htotal 
    SHORTINT hsstop 
    SHORTINT hbstrt 
    SHORTINT hbstop 
    SHORTINT vtotal 
    SHORTINT vsstop 
    SHORTINT vbstrt 
    SHORTINT vbstop 
    SHORTINT sprhstrt 
    SHORTINT sprhstop 
    SHORTINT bplhstrt 
    SHORTINT bplhstop 
    SHORTINT hhposw 
    SHORTINT hhposr 
    SHORTINT beamcon0 
    SHORTINT hsstrt 
    SHORTINT vsstrt 
    SHORTINT hcenter 
    SHORTINT diwhigh   /* 1e4 */
    STRING padf3 SIZE 22   /*  11*SIZEOF(SHORTINT) */
    SHORTINT fmode 
END STRUCT 

#ifdef ECS_SPECIFIC

/* defines for beamcon register */
#define VARVBLANK   &H1000  /* Variable vertical blank enable */
#define LOLDIS      &H0800  /* LONGINT line disable */
#define CSCBLANKEN  &H0400  /* redirect composite sync */
#define VARVSYNC    &H0200  /* Variable vertical sync enable */
#define VARHSYNC    &H0100  /* Variable horizontal sync enable */
#define VARBEAM &H0080  /* variable beam counter enable */
#define DISPLAYDUAL &H0040  /* use UHRES pointer and standard pointers */
#define DISPLAYPAL  &H0020  /* set decodes to generate PAL display */
#define VARCSYNC    &H0010  /* Variable composite sync enable */
#define CSBLANK &H0008  /* Composite blank out to CSY* pin */
#define CSYNCTRUE   &H0004  /* composite sync true signal */
#define VSYNCTRUE   &H0002  /* vertical sync true */
#define HSYNCTRUE   &H0001  /* horizontal sync true */

/* new defines for bplcon0 */
#define USE_BPLCON3 1

/* new defines for bplcon2 */
#define BPLCON2_ZDCTEN      (1024) /* colormapped genlock bit */
#define BPLCON2_ZDBPEN      (2048) /* use bitplane as genlock bits */
#define BPLCON2_ZDBPSEL0    (4096) /* three bits to select one */
#define BPLCON2_ZDBPSEL1    (8192) /* of 8 bitplanes in */
#define BPLCON2_ZDBPSEL2    (16384) /* ZDBPEN genlock mode */

/* defines for bplcon3 register */
#define BPLCON3_EXTBLNKEN   (1)  /* external blank enable */
#define BPLCON3_EXTBLKZD    (2)  /* external blank ored into trnsprncy */
#define BPLCON3_ZDCLKEN (4)  /* zd pin outputs a 14mhz clock*/
#define BPLCON3_BRDNTRAN    (16)  /* border is opaque */
#define BPLCON3_BRDNBLNK    (32)  /* border is opaque */

#endif  /* ECS_SPECIFIC */

#endif  /* HARDWARE_CUSTOM_H */
