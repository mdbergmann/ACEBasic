#ifndef GADGETS_TAPEDECK_H
#define GADGETS_TAPEDECK_H 1
/*
** tapedeck.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
**
*/


/*****************************************************************************/

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

/*****************************************************************************/

#define TDECK_Dummy     (TAG_USER+&H05000000)
#define TDECK_Mode      (TDECK_Dummy + 1)
#define TDECK_Paused        (TDECK_Dummy + 2)

#define TDECK_Tape      (TDECK_Dummy + 3)
    /* (SHORTINT) Indicate whether tapedeck or animation controls.  Defaults
     * to FALSE. */

#define TDECK_Frames        (TDECK_Dummy + 11)
    /* (LONGINT) Number of frames in animation.  Only valid when using
     * animation controls. */

#define TDECK_CurrentFrame  (TDECK_Dummy + 12)
    /* (LONGINT) Current frame.  Only valid when using animation controls. */

/*****************************************************************************/

/* Possible values for TDECK_Mode */
#define BUT_REWIND  0
#define BUT_PLAY    1
#define BUT_FORWARD 2
#define BUT_STOP    3
#define BUT_PAUSE   4
#define BUT_BEGIN   5
#define BUT_FRAME   6
#define BUT_END     7

/*****************************************************************************/

#endif /* GADGETS_TAPEDECK_H */
