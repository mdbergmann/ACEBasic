#ifndef HARDWARE_ADKBITS_H
#define HARDWARE_ADKBITS_H 1
/*
** adkbits.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
**
*/


#define  ADKB_SETCLR    15 /* standard set/clear bit */
#define  ADKB_PRECOMP1  14 /* two bits of precompensation */
#define  ADKB_PRECOMP0  13
#define  ADKB_MFMPREC   12 /* use mfm style precompensation */
#define  ADKB_UARTBRK   11 /* force uart output to zero */
#define  ADKB_WORDSYNC  10 /* enable DSKSYNC register matching */
#define  ADKB_MSBSYNC   9  /* (Apple GCR Only) sync on MSB for reading */
#define  ADKB_FAST  8  /* 1 -> 2 us/bit (mfm),  2 -> 4 us/bit (gcr) */
#define  ADKB_USE3PN    7  /* use aud chan 3 to modulate period of ?? */
#define  ADKB_USE2P3    6  /* use aud chan 2 to modulate period of 3 */
#define  ADKB_USE1P2    5  /* use aud chan 1 to modulate period of 2 */
#define  ADKB_USE0P1    4  /* use aud chan 0 to modulate period of 1 */
#define  ADKB_USE3VN    3  /* use aud chan 3 to modulate volume of ?? */
#define  ADKB_USE2V3    2  /* use aud chan 2 to modulate volume of 3 */
#define  ADKB_USE1V2    1  /* use aud chan 1 to modulate volume of 2 */
#define  ADKB_USE0V1    0  /* use aud chan 0 to modulate volume of 1 */

#define  ADKF_SETCLR    (32768&)
#define  ADKF_PRECOMP1  (16384&)
#define  ADKF_PRECOMP0  (8192&)
#define  ADKF_MFMPREC   (4096&)
#define  ADKF_UARTBRK   (2048&)
#define  ADKF_WORDSYNC  (1024&)
#define  ADKF_MSBSYNC   (512&)
#define  ADKF_FAST  (256&)
#define  ADKF_USE3PN    (128&)
#define  ADKF_USE2P3    (64&)
#define  ADKF_USE1P2    (32&)
#define  ADKF_USE0P1    (16&)
#define  ADKF_USE3VN    (8&)
#define  ADKF_USE2V3    (4&)
#define  ADKF_USE1V2    (2&)
#define  ADKF_USE0V1    (1)

#define ADKF_PRE000NS   0           /* 000 ns of precomp */
#define ADKF_PRE140NS   (ADKF_PRECOMP0) /* 140 ns of precomp */
#define ADKF_PRE280NS   (ADKF_PRECOMP1) /* 280 ns of precomp */
#define ADKF_PRE560NS   (ADKF_PRECOMP0 OR ADKF_PRECOMP1) /* 560 ns of precomp */

#endif  /* HARDWARE_ADKBITS_H */
