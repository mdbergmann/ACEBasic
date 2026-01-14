#ifndef EXEC_RESIDENT_H
#define EXEC_RESIDENT_H 1
/*
** resident.h for ACE Basic
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
** This are the StructPointer defines for resident.h
*/
#ifndef ResidentPtr
#define ResidentPtr ADDRESS
#endif
/*
** End of StructPointer defines for resident.h
*/
     
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEC_TYPES_H */




STRUCT Resident  
    SHORTINT rt_MatchWord  /* SHORTINT to match on (ILLEGAL)   */
    ResidentPtr  rt_MatchTag  /* pointer to the above   */
    ADDRESS  rt_EndSkip        /* address to continue scan */
    BYTE  rt_Flags      /* various tag flags        */
    BYTE  rt_Version        /* release version number   */
    BYTE  rt_Type       /* type of module (NT_XXXXXX)   */
    BYTE  rt_Pri        /* initialization priority */
    ADDRESS   rt_Name      /* pointer to node name */
    ADDRESS   rt_IdString  /* pointer to identification string */
    ADDRESS  rt_Init       /* pointer to init code */
END STRUCT 

#define RTC_MATCHWORD   &H4AFC  /* The 68000 "ILLEGAL" instruction */

#define RTF_AUTOINIT    (128)  /* rt_Init points to data structure */
#define RTF_AFTERDOS    (4)
#define RTF_SINGLETASK  (2)
#define RTF_COLDSTART   (1)

/* Compatibility: (obsolete) */
/* #define RTM_WHEN    3 */
#define RTW_NEVER   0
#define RTW_COLDSTART   1

#endif  /* EXEC_RESIDENT_H */
