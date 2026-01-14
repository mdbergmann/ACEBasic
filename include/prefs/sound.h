#ifndef PREFS_SOUND_H
#define PREFS_SOUND_H 1
/*
** sound.h for ACE Basic
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
** This are the StructPointer defines for sound.h
*/
#ifndef SoundPrefsPtr
#define SoundPrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for sound.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/*****************************************************************************/


#define ID_SOND 1397706308 


STRUCT SoundPrefs
 
    STRING sop_Reserved SIZE 16  /* 4*SIZEOF(LONGINT) */        /* SYSTEM reserved        */
    SHORTINT  sop_DisplayQueue        /* Flash the display?     */
    SHORTINT  sop_AudioQueue          /* Make some sound?       */
    SHORTINT sop_AudioType           /* Type of sound,  see below   */
    SHORTINT sop_AudioVolume         /* Volume of sound,  0..64     */
    SHORTINT sop_AudioPeriod         /* Period of sound,  127..2500 */
    SHORTINT sop_AudioDuration           /* Length of simple beep      */
    STRING sop_AudioFileName SIZE 256       /* Filename of 8SVX file      */
END STRUCT 


/* constants for SoundPrefs.sop_AudioType */
#define SPTYPE_BEEP 0   /* simple beep sound */
#define SPTYPE_SAMPLE   1   /* sampled sound     */


/*****************************************************************************/


#endif /* PREFS_SOUND_H */
