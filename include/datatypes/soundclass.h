#ifndef DATATYPES_SOUNDCLASS_H
#define DATATYPES_SOUNDCLASS_H 1
/*
** soundclass.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/02/95
**
**
*/

/*
** This are the StructPointer defines for soundclass.h
*/
#ifndef VoiceHeaderPtr
#define VoiceHeaderPtr ADDRESS
#endif
/*
** End of StructPointer defines for soundclass.h
*/
      
#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef DATATYPES_DATATYPESCLASS_H
#include <datatypes/datatypesclass.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/*****************************************************************************/

#define SOUNDDTCLASS        "sound.datatype"

/*****************************************************************************/

/* Sound attributes */
#define SDTA_Dummy      (DTA_Dummy + 500)
#define SDTA_VoiceHeader    (SDTA_Dummy + 1)
#define SDTA_Sample     (SDTA_Dummy + 2)
   /* (BYTE  *) Sample data */

#define SDTA_SampleLength   (SDTA_Dummy + 3)
   /* (LONGINT) Length of the sample data in UBYTEs */

#define SDTA_Period     (SDTA_Dummy + 4)
    /* (SHORTINT) Period */

#define SDTA_Volume     (SDTA_Dummy + 5)
    /* (SHORTINT) Volume.  Range from 0 to 64 */

#define SDTA_Cycles     (SDTA_Dummy + 6)

/* The following tags are new for V40 */
#define SDTA_SignalTask     (SDTA_Dummy + 7)
    /* (STRUCT Task *) Task to signal when sound is complete or
    _next buffer needed. */

#define SDTA_SignalBit      (SDTA_Dummy + 8)
    /* (BYTE) Signal bit to use on completion or -1 to disable */

#define SDTA_Continuous     (SDTA_Dummy + 9)
    /* (LONGINT) Playing a continuous stream of data.  Defaults to
    FALSE. */

/*****************************************************************************/

#define CMP_NONE     0
#define CMP_FIBDELTA 1

STRUCT VoiceHeader
 
    LONGINT        vh_OneShotHiSamples 
    LONGINT        vh_RepeatHiSamples 
    LONGINT        vh_SamplesPerHiCycle 
    SHORTINT        vh_SamplesPerSec 
    BYTE         vh_Octaves 
    BYTE         vh_Compression 
    LONGINT        vh_Volume 
END STRUCT 

/*****************************************************************************/

/* IFF types */
#define ID_8SVX 944985688 
#define ID_VHDR 1447576658 
#define ID_BODY &H424F4459 

/*****************************************************************************/

#endif  /* DATATYPES_SOUNDCLASS_H */
