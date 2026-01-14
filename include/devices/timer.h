#ifndef DEVICES_TIMER_H
#define DEVICES_TIMER_H 1
/*
** timer.h for ACE Basic
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
** This are the StructPointer defines for timer.h
*/
#ifndef EClockValPtr
#define EClockValPtr ADDRESS
#endif
#ifndef timerequestPtr
#define timerequestPtr ADDRESS
#endif
#ifndef timevalPtr
#define timevalPtr ADDRESS
#endif
/*
** End of StructPointer defines for timer.h
*/
          
#include <exec/types.h>
#include <exec/io.h>


/* unit defintions */
#define UNIT_MICROHZ    0
#define UNIT_VBLANK    1
#define UNIT_ECLOCK    2
#define UNIT_WAITUNTIL    3
#define    UNIT_WAITECLOCK    4

#define TIMERNAME    "timer.device"

STRUCT timeval  
    LONGINT tv_secs 
    LONGINT tv_micro 
END STRUCT 

STRUCT EClockVal  
    LONGINT ev_hi 
    LONGINT ev_lo 
END STRUCT 

STRUCT timerequest  
    IORequest tr_node 
    timeval tr_time 
END STRUCT 

/* IO_COMMAND to use for adding a timer */
#define TR_ADDREQUEST    CMD_NONSTD
#define TR_GETSYSTIME    (CMD_NONSTD+1)
#define TR_SETSYSTIME    (CMD_NONSTD+2)

#endif /* DEVICES_TIMER_H */
