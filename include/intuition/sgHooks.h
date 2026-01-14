#ifndef INTUITION_SGHOOKS_H
#define INTUITION_SGHOOKS_H TRUE
/*
** sghooks.h for ACE Basic
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
** This are the StructPointer defines for sghooks.h
*/
#ifndef SGWorkPtr
#define SGWorkPtr ADDRESS
#endif
#ifndef StringExtendPtr
#define StringExtendPtr ADDRESS
#endif
/*
** End of StructPointer defines for sghooks.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef GadgetInfoPtr
#define GadgetInfoPtr ADDRESS
#endif

STRUCT StringExtend  
    /* display specifications   */

    TextFontPtr  _Font   /* must be an open Font (not TextAttr)  */
    STRING Pens SIZE 2      /* color of text/backgroun      */
    STRING ActivePens SIZE 2    /* colors when gadget is active     */

    /* edit specifications  */
    LONGINT   InitialModes    /* initial mode flags,  below        */
    HookPtr  EditHook   /* if non-NULL,  must supply WorkBuffer  */
    ADDRESS   WorkBuffer     /* must be as large as StringInfo.Buffer*/

    STRING Reserved SIZE 16  /* 4*SIZEOF(LONGINT) */    /* set TO 0             */
END STRUCT 

STRUCT SGWork    
    /* set up when gadget is first activated    */

    GadgetPtr  _Gadget     /* the contestant itself    */
    StringInfoPtr  StringInfo     /* easy access to sinfo     */
    ADDRESS   WorkBuffer     /* intuition's planned result   */
    ADDRESS   PrevBuffer     /* what was there before    */
    LONGINT       Modes       /* current mode         */

    /* modified for each input event    */
    InputEventPtr  IEvent     /* actual event: do not change  */
    SHORTINT       Code        /* character code,  if one byte  */
    SHORTINT        BufferPos   /* cursor position      */
    SHORTINT        NumChars 
    LONGINT       Actions     /* what Intuition will do   */
    LONGINT        _LongInt     /* temp storage for longint */

    GadgetInfoPtr  GadgetInfo     /* see cghooks.h        */
    SHORTINT       EditOp      /* from constants below     */
END STRUCT 

/* SGWork.EditOp -
 * These values indicate what basic type of operation the global
 * editing hook has performed on the string before your gadget's custom
 * editing hook gets called.  You do not have to be concerned with the
 * value your custom hook leaves in the EditOp field,  only if you
 * write a global editing hook.
 *
 * For most of these general edit operations,  you'll want to compare
 * the BufferPos and NumChars of the StringInfo (before global editing)
 * and SGWork (after global editing).
 */

#define EO_NOOP     (&H0001)
    /* did nothing                          */
#define EO_DELBACKWARD  (&H0002)
    /* deleted some chars (maybe 0).                */
#define EO_DELFORWARD   (&H0003)
    /* deleted some characters under and in front of the cursor */
#define EO_MOVECURSOR   (&H0004)
    /* moved the cursor                     */
#define EO_ENTER    (&H0005)
    /* "enter" or "return" key,  terminate               */
#define EO_RESET    (&H0006)
    /* current Intuition-style undo                 */
#define EO_REPLACECHAR  (&H0007)
    /* replaced one character and (maybe) advanced cursor       */
#define EO_INSERTCHAR   (&H0008)
    /* inserted one BYTE into string or added one at end        */
#define EO_BADFORMAT    (&H0009)
    /* didn't like the text data,  e.g.,  Bad LONGINT         */
#define EO_BIGCHANGE    (&H000A)    /* unused by Intuition  */
    /* complete or major change to the text,  e.g. new string    */
#define EO_UNDO     (&H000B)    /* unused by Intuition  */
    /* some other style of undo                 */
#define EO_CLEAR    (&H000C)
    /* clear the string                     */
#define EO_SPECIAL  (&H000D)    /* unused by Intuition  */
    /* some operation that doesn't fit into the categories here */


/* Mode Flags definitions (ONLY first group allowed as InitialModes)    */
#define SGM_REPLACE (&H1&)   /* replace mode         */
/* please initialize StringInfo with in-range value of BufferPos
 * if you are using SGM_REPLACE mode.
 */

#define SGM_FIXEDFIELD  (&H2&)   /* fixed length buffer      */
                    /* always set SGM_REPLACE,  too  */
#define SGM_NOFILTER    (&H4&)   /* don't filter control chars   */

/* SGM_EXITHELP is new for V37,  and ignored by V36: */
#define SGM_EXITHELP    (&H80&)   /* EXIT with code = &H5F IF HELP hit */


/* These Mode Flags are for internal use only               */
#define SGM_NOCHANGE    (&H8&)   /* no edit changes yet      */
#define SGM_NOWORKB (&H10&)   /* Buffer == PrevBuffer     */
#define SGM_CONTROL (&H20&)   /* control BYTE escape mode */
#define SGM_LONGINT (&H40&)   /* an intuition LONGINT GADGET  */

/* String Gadget Action Flags (put in SGWork.Actions by EditHook)   */
#define SGA_USE     (&H1&)  /* use contents of SGWork       */
#define SGA_END     (&H2&)  /* terminate gadget,  code in Code field */
#define SGA_BEEP    (&H4&)  /* flash the screen for the user    */
#define SGA_REUSE   (&H8&)  /* reuse input event            */
#define SGA_REDISPLAY   (&H10&) /* gadget visuals changed       */

/* New for V37: */
#define SGA_NEXTACTIVE  (&H20&) /* Make next possible gadget active.    */
#define SGA_PREVACTIVE  (&H40&) /* Make previous possible gadget active.*/

/* function id for only existing custom string gadget edit hook */

#define SGH_KEY     (1&)    /* process editing keystroke        */
#define SGH_CLICK   (2&)    /* process mouse click cursor position  */

/* Here's a brief summary of how the custom string gadget edit hook works:
 *  You provide a hook in StringInfo.Extension.EditHook.
 *  The hook is called in the standard way with the 'object'
 *  a pointer to SGWork,  and the 'message' a pointer to a command
 *  block,  starting either with (longword) SGH_KEY,  SGH_CLICK, 
 *  or something new.
 *
 *  You return 0 if you don't understand the command (SGH_KEY is
 *  required and assumed).  Return non-zero if you implement the
 *  command.
 *
 *   SGH_KEY:
 *  There are no parameters following the command longword.
 *
 *  Intuition will put its idea of proper values in the SGWork
 *  before calling you,  and if you leave SGA_USE set in the
 *  SGWork.Actions field,  Intuition will use the values
 *  found in SGWork fields WorkBuffer,  NumChars,  BufferPos, 
 *  and LongInt,  copying the WorkBuffer back to the StringInfo
 *  Buffer.
 *
 *  NOTE WELL: You may NOT change other SGWork fields.
 *
 *  If you clear SGA_USE,  the string gadget will be unchanged.
 *
 *  If you set SGA_END,  Intuition will terminate the activation
 *  of the string gadget.  If you also set SGA_REUSE,  Intuition
 *  will reuse the input event after it deactivates your gadget.
 *
 *  In this case,  Intuition will put the value found in SGWork.Code
 *  into the IntuiMessage.Code field of the IDCMP_GADGETUP message it
 *  sends to the application.
 *
 *  If you set SGA_BEEP,  Intuition will call DisplayBeep()  use
 *  this if the user has typed in error,  or buffer is full.
 *
 *  Set SGA_REDISPLAY if the changes to the gadget warrant a
 *  gadget redisplay.  Note: cursor movement requires a redisplay.
 *
 *  Starting in V37,  you may set SGA_PREVACTIVE or SGA_NEXTACTIVE
 *  when you set SGA_END.  This tells Intuition that you want
 *  the next or previous gadget with GFLG_TABCYCLE to be activated.
 *
 *   SGH_CLICK:
 *  This hook command is called when Intuition wants to position
 *  the cursor in response to a mouse click in the string gadget.
 *
 *  Again,  here are no parameters following the command longword.
 *
 *  This time,  Intuition has already calculated the mouse position
 *  character cell and put it in SGWork.BufferPos.  The previous
 *  BufferPos value remains in the SGWork.StringInfo.BufferPos.
 *
 *  Intuition will again use the SGWork fields listed above for
 *  SGH_KEY.  One restriction is that you are NOT allowed to set
 *  SGA_END or SGA_REUSE for this command.  Intuition will not
 *  stand for a gadget which goes inactive when you click in it.
 *
 *  You should always leave the SGA_REDISPLAY flag set,  since Intuition
 *  uses this processing when activating a string gadget.
 */

#endif
