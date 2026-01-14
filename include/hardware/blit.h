#ifndef HARDWARE_BLIT_H
#define HARDWARE_BLIT_H 1
/*
** blit.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
** Note: Fixed a missing kludgefill in bltnode
**       14-Oct-95      Nils Sjoholm
**
*/

/*
** This are the StructPointer defines for blit.h
*/
#ifndef bltnodePtr
#define bltnodePtr ADDRESS
#endif
/*
** End of StructPointer defines for blit.h
*/


#define HSIZEBITS 6
#define VSIZEBITS 16-HSIZEBITS
#define HSIZEMASK &H3f        /* 2^6 -- 1 */
#define VSIZEMASK &H3FF       /* 2^10 - 1 */

/* all agnii support horizontal blit of at least 1024 bits (128 bytes) wide */
/* some agnii support horizontal blit of up to 32768 bits (4096 bytes) wide */

#ifndef  NO_BIG_BLITS
#define  MINBYTESPERROW 128
#define  MAXBYTESPERROW 4096
#else
#define  MAXBYTESPERROW 128
#endif

/* definitions for blitter control register 0 */

#define ABC    &H80
#define ABNC   &H40
#define ANBC   &H20
#define ANBNC  &H10
#define NABC   &H8
#define NABNC  &H4
#define NANBC  &H2
#define NANBNC &H1

/* some commonly used operations */
#define A_OR_B    ABC OR ANBC OR NABC OR ABNC OR ANBNC OR NABNC
#define A_OR_C    ABC OR NABC OR ABNC OR ANBC OR NANBC OR ANBNC
#define A_XOR_C   NABC OR ABNC OR NANBC OR ANBNC
#define A_TO_D    ABC OR ANBC OR ABNC OR ANBNC

#define BC0B_DEST 8
#define BC0B_SRCC 9
#define BC0B_SRCB   10
#define BC0B_SRCA 11
#define BC0F_DEST &H100
#define BC0F_SRCC &H200
#define BC0F_SRCB &H400
#define BC0F_SRCA &H800

#define BC1F_DESC   2         /* blitter descend direction */

#define DEST &H100
#define SRCC &H200
#define SRCB &H400
#define SRCA &H800

#define ASHIFTSHIFT  12       /* bits to right align ashift value */
#define BSHIFTSHIFT  12       /* bits to right align bshift value */

/* definations for blitter control register 1 */
#define LINEMODE     &H1
#define FILL_OR      &H8
#define FILL_XOR     &H10
#define FILL_CARRYIN &H4
#define ONEDOT       &H2      /* one dot per horizontal line */
#define OVFLAG       &H20
#define SIGNFLAG     &H40
#define BLITREVERSE  &H2

#define SUD      &H10
#define SUL      &H8
#define AUL      &H4

#define OCTANT8   24
#define OCTANT7   4
#define OCTANT6   12
#define OCTANT5   28
#define OCTANT4   20
#define OCTANT3   8
#define OCTANT2   0
#define OCTANT1   16

/* stuff for blit qeuer */
STRUCT bltnode
 
    bltnodePtr  n 
    ADDRESS   _function 
    BYTE    stat
    BYTE    bn_dummy 
    SHORTINT   blitsize 
    SHORTINT   beamsync 
    ADDRESS   cleanup
END STRUCT 

/* defined bits for bltstat */
#define CLEANUP &H40
#define CLEANME CLEANUP

#endif  /* HARDWARE_BLIT_H */
