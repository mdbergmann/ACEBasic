#ifndef DEVICES_GAMEPORT_H
#define DEVICES_GAMEPORT_H 1
/*
** gameport.h for ACE Basic
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
** This are the StructPointer defines for gameport.h
*/
#ifndef GamePortTriggerPtr
#define GamePortTriggerPtr ADDRESS
#endif
/*
** End of StructPointer defines for gameport.h
*/
      
#ifndef EXEC_TYPES_H
#include    <exec/types.h>
#endif

#ifndef EXEC_IO_H
#include    <exec/io.h>
#endif


/******  GamePort commands ******/
#define  GPD_READEVENT     (CMD_NONSTD+0)
#define  GPD_ASKCTYPE      (CMD_NONSTD+1)
#define  GPD_SETCTYPE      (CMD_NONSTD+2)
#define  GPD_ASKTRIGGER    (CMD_NONSTD+3)
#define  GPD_SETTRIGGER    (CMD_NONSTD+4)

/******  GamePort structures ******/

/* gpt_Keys */
#define  GPTB_DOWNKEYS     0
#define  GPTF_DOWNKEYS     (1)
#define  GPTB_UPKEYS       1
#define  GPTF_UPKEYS       (2)

STRUCT GamePortTrigger  
   SHORTINT gpt_Keys      /* key transition triggers */
   SHORTINT gpt_Timeout       /* time trigger (vertical blank units) */
   SHORTINT gpt_XDelta        /* X distance trigger */
   SHORTINT gpt_YDelta        /* Y distance trigger */
END STRUCT 

/****** Controller Types ******/
#define  GPCT_ALLOCATED    -1    /* allocated by another user */
#define  GPCT_NOCONTROLLER 0

#define  GPCT_MOUSE    1
#define  GPCT_RELJOYSTICK  2
#define  GPCT_ABSJOYSTICK  3


/****** Errors ******/
#define  GPDERR_SETCTYPE   1     /* this controller not valid at this time */

#endif  /* DEVICES_GAMEPORT_H */
