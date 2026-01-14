#ifndef GRAPHICS_DISPLAY_H
#define GRAPHICS_DISPLAY_H 1
/*
** display.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/


/* bplcon0 defines */
#define MODE_640    &H8000
#define PLNCNTMSK   &H7     /* how many bit planes? */
                    /* 0 = none,  1->6 = 1->6,  7 = reserved */
#define PLNCNTSHFT  12          /* bits to shift for bplcon0 */
#define PF2PRI      &H40        /* bplcon2 bit */
#define COLORON     &H0200      /* disable color burst */
#define DBLPF       &H400
#define HOLDNMODIFY &H800
#define INTERLACE   4           /* interlace mode for 400 */

/* bplcon1 defines */
#define PFA_FINE_SCROLL       &HF
#define PFB_FINE_SCROLL_SHIFT 4
#define PF_FINE_SCROLL_MASK   &HF

/* display window start and stop defines */
#define DIW_HORIZ_POS   &H7F       /* horizontal start/stop */
#define DIW_VRTCL_POS   &H1FF      /* vertical start/stop */
#define DIW_VRTCL_POS_SHIFT 7

/* Data fetch start/stop horizontal position */
#define DFTCH_MASK  &HFF

/* vposr bits */
#define VPOSRLOF    &H8000

#endif  /* GRAPHICS_DISPLAY_H */
