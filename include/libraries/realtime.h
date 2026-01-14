#ifndef LIBRARIES_REALTIME_H
#define LIBRARIES_REALTIME_H
/*
** realtime.h for ACE Basic
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
** This are the StructPointer defines for realtime.h
*/
#ifndef ConductorPtr
#define ConductorPtr ADDRESS
#endif
#ifndef PlayerPtr
#define PlayerPtr ADDRESS
#endif
#ifndef RealTimeBasePtr
#define RealTimeBasePtr ADDRESS
#endif
#ifndef pmStatePtr
#define pmStatePtr ADDRESS
#endif
#ifndef pmTimePtr
#define pmTimePtr ADDRESS
#endif
/*
** End of StructPointer defines for realtime.h
*/


/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif


/*****************************************************************************/


/* realtime.library's idea of time is based on a clock which emits a pulse
 * 1200 times a second (1.2kHz). All time values maintained by realtime.library
 * are based on this number. For example,  the field RealTimeBase->rtb_Time
 * expresses an amount of time equivalent to (RealTimeBase->rtb_Time/TICK_FREQ)
 * seconds.
 */
#define TICK_FREQ 1200


/*****************************************************************************/


/* Each Conductor represents a group of applications which wish to remain
 * synchronized together.
 *
 * This structure must only be allocated by realtime.library and is
 * READ-ONLY!
 */
STRUCT Conductor
 
    Node cdt_Link 
    SHORTINT      cdt_Reserved0 
    MinList cdt_Players       /* this conductor's players      */
    LONGINT      cdt_ClockTime     /* current time of this sequence */
    LONGINT      cdt_StartTime     /* start time of this sequence   */
    LONGINT      cdt_ExternalTime      /* time from external unit   */
    LONGINT      cdt_MaxExternalTime   /* upper limit on sync'd time    */
    LONGINT      cdt_Metronome     /* MetricTime highest pri node   */
    SHORTINT      cdt_Reserved1 
    SHORTINT      cdt_Flags         /* conductor flags       */
    BYTE       cdt_State         /* playing or stopped        */
END STRUCT 

/* Flag bits for Conductor.cdt_Flags */
#define CONDUCTF_EXTERNAL (1)   /* clock is externally driven */
#define CONDUCTF_GOTTICK  (2)   /* received 1st external tick */
#define CONDUCTF_METROSET (4)   /* cdt_Metronome filled in    */
#define CONDUCTF_PRIVATE  (8)   /* conductor is private   */

#define CONDUCTB_EXTERNAL 0
#define CONDUCTB_GOTTICK  1
#define CONDUCTB_METROSET 2
#define CONDUCTB_PRIVATE  3

/* constants for Conductor.cdt_State and SetConductorState() */
#define CONDSTATE_STOPPED     0   /* clock is stopped          */
#define CONDSTATE_PAUSED      1   /* clock is paused           */
#define CONDSTATE_LOCATE      2   /* go to 'running' when ready    */
#define CONDSTATE_RUNNING     3   /* run clock NOW         */

/* These do not actually exist as Conductor states,  but are used as additional
 * arguments to SetConductorState()
 */
#define CONDSTATE_METRIC     -1   /* ask high node to locate       */
#define CONDSTATE_SHUTTLE    -2   /* time changing but not running */
#define CONDSTATE_LOCATE_SET -3   /* maestro done locating     */


/*****************************************************************************/


/* The Player is the connection between a Conductor and an application.
 *
 * This structure must only be allocated by realtime.library and is
 * READ-ONLY!
 */
STRUCT Player
 
    Node pl_Link 
    BYTE          pl_Reserved0 
    BYTE          pl_Reserved1 
    HookPtr  pl_Hook        /* player's hook function   */
    ConductorPtr  pl_Source      /* pointer to parent context    */
    TaskPtr  pl_Task        /* task to signal for alarm     */
    LONGINT          pl_MetricTime      /* current time in app's metric */
    LONGINT          pl_AlarmTime   /* time to wake up      */
    ADDRESS   pl_UserData    /* for application use  */
    SHORTINT         pl_PlayerID    /* for application use  */
    SHORTINT         pl_Flags   /* general Player flags     */
END STRUCT 

/* Flag bits for Player.pl_Flags */
#define PLAYERF_READY     (1)   /* player is ready to go!        */
#define PLAYERF_ALARMSET  (2)   /* alarm is set          */
#define PLAYERF_QUIET     (4)   /* a dummy player,  used for sync */
#define PLAYERF_CONDUCTED (8)   /* give me metered time      */
#define PLAYERF_EXTSYNC   (16)   /* granted external sync     */

#define PLAYERB_READY     0
#define PLAYERB_ALARMSET  1
#define PLAYERB_QUIET     2
#define PLAYERB_CONDUCTED 3
#define PLAYERB_EXTSYNC   4


/*****************************************************************************/


/* Tags for CreatePlayer(),  SetPlayerAttrs(),  and GetPlayerAttrs() */
#define PLAYER_Base     (TAG_USER+64)
#define PLAYER_Hook     (PLAYER_Base+1)   /* set address of hook function */
#define PLAYER_Name     (PLAYER_Base+2)   /* name of player       */
#define PLAYER_Priority     (PLAYER_Base+3)   /* priority of player       */
#define PLAYER_Conductor    (PLAYER_Base+4)   /* set conductor for player     */
#define PLAYER_Ready        (PLAYER_Base+5)   /* the "ready" flag         */
#define PLAYER_AlarmTime    (PLAYER_Base+12)  /* alarm time (sets PLAYERF_ALARMSET) */
#define PLAYER_Alarm        (PLAYER_Base+13)  /* sets/clears PLAYERF_ALARMSET flag  */
#define PLAYER_AlarmSigTask (PLAYER_Base+6)   /* task to signal for alarm/notify    */
#define PLAYER_AlarmSigBit  (PLAYER_Base+8)   /* signal bit for alarm (or -1) */
#define PLAYER_Conducted    (PLAYER_Base+7)   /* sets/clears PLAYERF_CONDUCTED flag   */
#define PLAYER_Quiet        (PLAYER_Base+9)   /* don't process time thru this */
#define PLAYER_UserData     (PLAYER_Base+10)
#define PLAYER_ID       (PLAYER_Base+11)
#define PLAYER_ExtSync      (PLAYER_Base+14)  /* attempt/release to ext sync  */
#define PLAYER_ErrorCode    (PLAYER_Base+15)  /* error return value       */


/*****************************************************************************/


/* Method types for messages sent via a Player's hook */
#define PM_TICK     0
#define PM_STATE    1
#define PM_POSITION 2
#define PM_SHUTTLE  3

/* used for PM_TICK,  PM_POSITION and PM_SHUTTLE methods */
STRUCT pmTime
 
    LONGINT pmt_Method         /* PM_TICK,  PM_POSITION,  or PM_SHUTTLE */
    LONGINT pmt_Time 
END STRUCT 

/* used for the PM_STATE method */
STRUCT pmState
 
    LONGINT pms_Method         /* PM_STATE */
    LONGINT pms_OldState 
END STRUCT 


/*****************************************************************************/


/* Possible lock types for LockRealTime() */
#define RT_CONDUCTORS 0   /* conductor list */


/*****************************************************************************/


/* realtime.library error codes */
#define RTE_NOMEMORY    801   /* memory allocation failed      */
#define RTE_NOCONDUCTOR 802   /* player needs a conductor      */
#define RTE_NOTIMER 803   /* timer (CIA) allocation failed */
#define RTE_PLAYING 804   /* can't shuttle while playing   */


/*****************************************************************************/


/* OpenLibrary("realtime.library", 0) returns a pointer to this structure.
 * All fields are READ-ONLY.
 */
STRUCT RealTimeBase
 
    _Library rtb_LibNode 
    STRING rtb_Reserved0 SIZE 2  

    LONGINT      rtb_Time          /* current time                 */
    LONGINT      rtb_TimeFrac      /* fixed-point fraction part of time    */
    SHORTINT      rtb_Reserved1 
    SHORTINT       rtb_TickErr       /* nanosecond error from ideal Tick     */
END STRUCT                    /* length to real tick length       */

/* Actual tick length is: 1/TICK_FREQ + rtb_TickErr/1e9 */

#define RealTime_TickErr_Min -705
#define RealTime_TickErr_Max  705


/*****************************************************************************/


#endif /* LIBRARIES_REALTIME_H */
