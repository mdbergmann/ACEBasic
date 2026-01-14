#ifndef DEVICES_AUDIO_H
#define DEVICES_AUDIO_H 1
/*
** audio.h for ACE Basic
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
** This are the StructPointer defines for audio.h
*/
#ifndef IOAudioPtr ADDRESS
#define IOAudioPtr ADDRESS
#endif
/*
** End of StructPointer defines for audio.h
*/      
     

#ifndef EXEC_IO_H
#include <exec/io.h>
#endif

#define AUDIONAME       "audio.device"

#define ADHARD_CHANNELS     4

#define ADALLOC_MINPREC     -128
#define ADALLOC_MAXPREC     127

#define ADCMD_FREE      (CMD_NONSTD+0)
#define ADCMD_SETPREC       (CMD_NONSTD+1)
#define ADCMD_FINISH        (CMD_NONSTD+2)
#define ADCMD_PERVOL        (CMD_NONSTD+3)
#define ADCMD_LOCK      (CMD_NONSTD+4)
#define ADCMD_WAITCYCLE     (CMD_NONSTD+5)
#define ADCMD_ALLOCATE      32

#define ADIOB_PERVOL        4
#define ADIOF_PERVOL        (16)
#define ADIOB_SYNCCYCLE     5
#define ADIOF_SYNCCYCLE     (32)
#define ADIOB_NOWAIT        6
#define ADIOF_NOWAIT        (64)
#define ADIOB_WRITEMESSAGE  7
#define ADIOF_WRITEMESSAGE  (128)

#define ADIOERR_NOALLOCATION    -10
#define ADIOERR_ALLOCFAILED -11
#define ADIOERR_CHANNELSTOLEN   -12

STRUCT IOAudio  
    IORequest ioa_Request 
    SHORTINT ioa_AllocKey 
    ADDRESS   ioa_Data 
    LONGINT ioa_Length 
    SHORTINT ioa_Period 
    SHORTINT ioa_Volume 
    SHORTINT ioa_Cycles 
    _Message ioa_WriteMsg 
END STRUCT 

#endif  /* DEVICES_AUDIO_H */
