#ifndef DOS_EXALL_H
#define DOS_EXALL_H 1
/*
** exall.h for ACE Basic
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
** This are the StructPointer defines for exall.h
*/
#ifndef ExAllControlPtr
#define ExAllControlPtr ADDRESS
#endif
#ifndef ExAllDataPtr
#define ExAllDataPtr ADDRESS
#endif
/*
** End of StructPointer defines for exall.h
*/
     
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif


/* NOTE: V37 dos.library,  when doing ExAll() emulation,  and V37 filesystems  */
/* will return an error if passed ED_OWNER.  If you get ERROR_BAD_NUMBER,     */
/* retry with ED_COMMENT to get everything but owner info.  All filesystems  */
/* supporting ExAll() must support through ED_COMMENT,  and must check Type   */
/* and return ERROR_BAD_NUMBER if they don't support the type.           */

/* values that can be passed for what data you want from ExAll() */
/* each higher value includes those below it (numerically)   */
/* you MUST chose one of these values */
#define ED_NAME     1
#define ED_TYPE     2
#define ED_SIZE     3
#define ED_PROTECTION   4
#define ED_DATE     5
#define ED_COMMENT  6
#define ED_OWNER    7

/*
 *   Structure in which exall results are returned in.  Note that only the
 *   fields asked for will exist!
 */

STRUCT ExAllData  
    ExAllDataPtr  ed_Next 
    ADDRESS   ed_Name 
    LONGINT    ed_Type 
    LONGINT   ed_Size 
    LONGINT   ed_Prot 
    LONGINT   ed_Days 
    LONGINT   ed_Mins 
    LONGINT   ed_Ticks 
    ADDRESS   ed_Comment  /* strings will be after last used field */
    SHORTINT   ed_OwnerUID     /* new for V39 */
    SHORTINT   ed_OwnerGID 
END STRUCT 

/*
 *   Control structure passed to ExAll.  Unused fields MUST be initialized to
 *   0,  expecially eac_LastKey.
 *
 *   eac_MatchFunc is a hook (see utility.library documentation for usage)
 *   It should return true if the entry is to returned,  false if it is to be
 *   ignored.
 *
 *   This structure MUST be allocated by AllocDosObject()!
 */

STRUCT ExAllControl  
    LONGINT   eac_Entries      /* number of entries returned in buffer      */
    LONGINT   eac_LastKey      /* Don't touch inbetween linked ExAll calls! */
    ADDRESS   eac_MatchString  /* wildcard string for pattern match or NULL */
    HookPtr  eac_MatchFunc  /* optional private wildcard function     */
END STRUCT 

#endif /* DOS_EXALL_H */
