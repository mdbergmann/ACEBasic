#ifndef HARDWARE_DMABITS_H
#define HARDWARE_DMABITS_H 1
/*
** dmabits.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
**
*/


/* write definitions for dmaconw */
#define DMAF_SETCLR  &H8000
#define DMAF_AUDIO   &H000F   /* 4 bit mask */
#define DMAF_AUD0    &H0001
#define DMAF_AUD1    &H0002
#define DMAF_AUD2    &H0004
#define DMAF_AUD3    &H0008
#define DMAF_DISK    &H0010
#define DMAF_SPRITE  &H0020
#define DMAF_BLITTER &H0040
#define DMAF_COPPER  &H0080
#define DMAF_RASTER  &H0100
#define DMAF_MASTER  &H0200
#define DMAF_BLITHOG &H0400
#define DMAF_ALL     &H01FF   /* all dma channels */

/* read definitions for dmaconr */
/* bits 0-8 correspnd to dmaconw definitions */
#define DMAF_BLTDONE &H4000
#define DMAF_BLTNZERO   &H2000

#define DMAB_SETCLR  15
#define DMAB_AUD0    0
#define DMAB_AUD1    1
#define DMAB_AUD2    2
#define DMAB_AUD3    3
#define DMAB_DISK    4
#define DMAB_SPRITE  5
#define DMAB_BLITTER 6
#define DMAB_COPPER  7
#define DMAB_RASTER  8
#define DMAB_MASTER  9
#define DMAB_BLITHOG 10
#define DMAB_BLTDONE 14
#define DMAB_BLTNZERO   13

#endif  /* HARDWARE_DMABITS_H */
