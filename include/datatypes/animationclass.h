#ifndef DATATYPES_ANIMATIONCLASS_H
#define DATATYPES_ANIMATIONCLASS_H 1
/*
** animationclass.h for ACE Basic
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
** This are the StructPointer defines for animationclass.h
*/
#ifndef AnimHeaderPtr
#define AnimHeaderPtr ADDRESS
#endif
#ifndef adtFramePtr
#define adtFramePtr ADDRESS
#endif
#ifndef adtStartPtr
#define adtStartPtr ADDRESS
#endif
/*
** End of StructPointer defines for animationclass.h
*/       

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef DATATYPES_DATATYPESCLASS_H
#include <datatypes/datatypesclass.h>
#endif

#ifndef DATATYPES_PICTURECLASS_H
#include <datatypes/pictureclass.h>
#endif

#ifndef DATATYPES_SOUNDCLASS_H
#include <datatypes/soundclass.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif

              
/*****************************************************************************/

#define ANIMATIONDTCLASS        "animation.datatype"

/*****************************************************************************/

/* Animation attributes */
#define ADTA_Dummy      (DTA_Dummy + 600)
#define ADTA_ModeID     PDTA_ModeID
#define ADTA_KeyFrame       PDTA_BitMap
    /* (STRUCT BitMap *) Key frame (first frame) bitmap */

#define ADTA_ColorRegisters PDTA_ColorRegisters
#define ADTA_CRegs      PDTA_CRegs
#define ADTA_GRegs      PDTA_GRegs
#define ADTA_ColorTable     PDTA_ColorTable
#define ADTA_ColorTable2    PDTA_ColorTable2
#define ADTA_Allocated      PDTA_Allocated
#define ADTA_NumColors      PDTA_NumColors
#define ADTA_NumAlloc       PDTA_NumAlloc

#define ADTA_Remap      PDTA_Remap
    /* (SHORTINT) : Remap animation (defaults to TRUE) */

#define ADTA_Screen     PDTA_Screen
    /* (STRUCT Screen *) Screen to remap to */

#define ADTA_NumSparse      PDTA_NumSparse
    /* (SHORTINT) Number of colors used for sparse remapping */

#define ADTA_SparseTable    PDTA_SparseTable
    /* (BYTE  *) Pointer to a table of pen numbers indicating
     * which colors should be used when remapping the image.
     * This array must contain as many entries as there
     * are colors specified with ADTA_NumSparse */

#define ADTA_Width      (ADTA_Dummy + 1)
#define ADTA_Height     (ADTA_Dummy + 2)
#define ADTA_Depth      (ADTA_Dummy + 3)
#define ADTA_Frames     (ADTA_Dummy + 4)
    /* (LONGINT) Number of frames in the animation */

#define ADTA_Frame      (ADTA_Dummy + 5)
    /* (LONGINT) Current frame */

#define ADTA_FramesPerSecond    (ADTA_Dummy + 6)
    /* (LONGINT) Frames per second */

#define ADTA_FrameIncrement (ADTA_Dummy + 7)
    /* (LONGINT) Amount to change frame by when fast forwarding or
     * rewinding.  Defaults to 10. */

/* Sound attributes */
#define ADTA_Sample     SDTA_Sample
#define ADTA_SampleLength   SDTA_SampleLength
#define ADTA_Period     SDTA_Period
#define ADTA_Volume     SDTA_Volume
#define ADTA_Cycles     SDTA_Cycles

/*****************************************************************************/

#define ID_ANIM 1095649613 
#define ID_ANHD 1095649348 
#define ID_DLTA 1145852993 

/*****************************************************************************/

/*  Required ANHD structure describes an ANIM frame */
STRUCT AnimHeader
 
    BYTE     ah_Operation   /*  The compression method:
                     0  set directly (normal ILBM BODY), 
                     1  _XOR ILBM mode, 
                     2  _LONGINT Delta mode, 
                     3  _SHORTINT Delta mode, 
                     4  Generalized SHORTINT/LONGINT Delta mode, 
                     5  _Byte Vertical Delta mode
                     6  Stereo op 5 (third party)
                    74  (ascii 'J') reserved for Eric Graham's
                    compression technique (details to be
                    released later). */

    BYTE     ah_Mask    /* (XOR mode only - plane mask where each
                   bit is set =1 if there is data and =0
                   _if not.) */

    SHORTINT    ah_Width   /* (XOR mode only - width and height of the */
    SHORTINT    ah_Height  /* area represented by the BODY to eliminate */
                /* unnecessary un-changed data) */


    SHORTINT     ah_Left    /* (XOR mode only - position of rectangular */
    SHORTINT     ah_Top     /* area representd by the BODY) */


    LONGINT    ah_AbsTime     /* Timing for a frame relative to the time
                   the first frame was displayed,  in
                   jiffies (1/60 sec) */

    LONGINT    ah_RelTime     /* Timing for frame relative to time
                   previous frame was displayed - in
                   jiffies (1/60 sec) */

    BYTE     ah_Interleave  /* Indicates how may frames back this data is to
                   modify.  0 defaults to indicate two frames back
                   (for double buffering). n indicates n frames back.
                   The main intent here is to allow values
                   of 1 for special applications where
                   frame _data would modify the immediately
                   previous frame. */

    BYTE     ah_Pad0    /* Pad byte,  not used at present. */

    LONGINT    ah_Flags   /* 32 option bits used by options=4 and 5.
                   At present only 6 are identified,  but the
                   rest are set =0 so they can be used to
                   implement future ideas.  These are defined
                   _for _option 4 only at this point.  It is
                   recommended that all bits be set =0 for
                   _option 5 and that any bit settings
                   used in the future (such as for XOR mode)
                   be compatible with the option 4
                   bit settings.   Player code should check
                   undefined bits in options 4 and 5 to assure
                   they are zero.

                   The six bits for current use are:

                    bit #   set =0          set =1
                    ===============================================
                    0       _SHORTINT data      LONGINT data
                    1       set         XOR
                    2       separate info       one info list
                        _for each plane      for all planes
                    3       _not RLC         RLC (run length coded)
                    4       horizontal      vertical
                    5       _SHORTINT info offsets  LONGINT info offsets
                */

    STRING ah_Pad SIZE 16      /* This is a pad for future use for future
                   compression modes. */
END STRUCT 

/*****************************************************************************/

#define ADTM_Dummy      (&H700)

#define ADTM_LOADFRAME      (&H701)
    /* Used to load a frame of the animation */

#define ADTM_UNLOADFRAME    (&H702)
    /* Used to unload a frame of the animation */

#define ADTM_START      (&H703)
    /* Used to start the animation */

#define ADTM_PAUSE      (&H704)
    /* Used to pause the animation (don't reset the timer) */

#define ADTM_STOP       (&H705)
    /* Used to stop the animation */

#define ADTM_LOCATE     (&H706)
    /* Used to locate a frame in the animation (as set by a slider...) */

/*****************************************************************************/

/* ADTM_LOADFRAME,  ADTM_UNLOADFRAME */
STRUCT adtFrame
 
    LONGINT        MethodID 
    LONGINT        alf_TimeStamp      /* Timestamp of frame to load */

    /* The following fields are filled in by the ADTM_LOADFRAME method,  */
    /* and are read-only for any other methods. */

    LONGINT        alf_Frame      /* Frame number */
    LONGINT        alf_Duration       /* Duration of frame */

    BitMapPtr  alf_BitMap         /* Loaded BitMap */
    ColorMapPtr  alf_CMap       /* Colormap,  if changed */

    ADDRESS   alf_Sample         /* Sound data */
    LONGINT        alf_SampleLength 
    LONGINT        alf_Period 

    ADDRESS         alf_UserData       /* Used by load frame for extra data */
END STRUCT 

/* ADTM_START,  ADTM_PAUSE,  ADTM_STOP,  ADTM_LOCATE */
STRUCT adtStart
 
    LONGINT        MethodID 
    LONGINT        asa_Frame      /* Frame # to start at */
END STRUCT 

/*****************************************************************************/

#endif  /* DATATYPES_ANIMATIONCLASS_H */
