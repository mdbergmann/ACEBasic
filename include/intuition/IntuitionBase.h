#ifndef INTUITION_INTUITIONBASE_H
#define INTUITION_INTUITIONBASE_H 1
/*
** intuitionbase.h for ACE Basic
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
** This are the StructPointer defines for intuitionbase.h
*/
#ifndef IntuitionBasePtr
#define IntuitionBasePtr ADDRESS
#endif
/*
** End of StructPointer defines for intuitionbase.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif


#ifndef EXEC_INTERRUPTS_H
#include <exec/interrupts.h>
#endif

/* these are the display modes for which we have corresponding parameter
 *  settings in the config arrays
 */
#define DMODECOUNT  &H0002  /* how many modes there are */
#define HIRESPICK   &H0000
#define LOWRESPICK  &H0001

#define EVENTMAX 10     /* size of event array */

/* these are the system Gadget defines */
#define RESCOUNT    2
#define HIRESGADGET 0
#define LOWRESGADGET    1

#define GADGETCOUNT 8
#define UPFRONTGADGET   0
#define DOWNBACKGADGET  1
#define SIZEGADGET  2
#define CLOSEGADGET 3
#define DRAGGADGET  4
#define SUPFRONTGADGET  5
#define SDOWNBACKGADGET 6
#define SDRAGGADGET 7

/* ======================================================================== */
/* === IntuitionBase ====================================================== */
/* ======================================================================== */
/*
 * Be sure to protect yourself against someone modifying these data as
 * you look at them.  This is done by calling:
 *
 * lock = LockIBase(0),  which returns a ULONG.  When done call
 * UnlockIBase(lock) where lock is what LockIBase() returned.
 */

/* This structure is strictly READ ONLY */
STRUCT IntuitionBase
 
    _Library LibNode 

    View ViewLord 

    WindowPtr  ActiveWindow 
    ScreenPtr  ActiveScreen 

    /* the FirstScreen variable points to the frontmost Screen.  Screens are
     * then maintained in a front to back order using Screen.NextScreen
     */
    ScreenPtr  FirstScreen  /* for linked list of all screens */

    LONGINT Flags     /* values are all system private */
    SHORTINT    MouseY 
    SHORTINT   MouseX 
            /* note "backwards" order of these      */

    LONGINT Seconds   /* timestamp of most current input event */
    LONGINT Micros    /* timestamp of most current input event */

    /* I told you this was private.
     * The data beyond this point has changed,  is changing,  and
     * will continue to change.
     */
END STRUCT 

#endif

