#ifndef DOS_VAR_H
#define DOS_VAR_H 1
/*
** var.h for ACE Basic
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
** This are the StructPointer defines for var.h
*/
#ifndef LocalVarPtr
#define LocalVarPtr ADDRESS
#endif
/*
** End of StructPointer defines for var.h
*/
     
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif


/* the structure in the pr_LocalVars list */
/* Do NOT allocate yourself,  use SetVar()!!! This structure may grow in */
/* future releases!  The list should be left in alphabetical order,  and */
/* may have multiple entries with the same name but different types.    */

STRUCT LocalVar  
    Node lv_Node 
    SHORTINT   lv_Flags 
    ADDRESS   lv_Value 
    LONGINT   lv_Len 
END STRUCT 

/*
 * The lv_Flags bits are available to the application.  The unused
 * lv_Node.ln_Pri bits are reserved for system use.
 */

/* bit definitions for lv_Node.ln_Type: */
#define LV_VAR          0   /* an variable */
#define LV_ALIAS        1   /* an alias */
/* to be or'ed into type: */
#define LVB_IGNORE      7   /* ignore this entry on GetVar,  etc */
#define LVF_IGNORE      &H80

/* definitions of flags passed to GetVar()/SetVar()/DeleteVar() */
/* bit defs to be OR'ed with the type: */
/* item will be treated as a single line of text unless BINARY_VAR is used */
#define GVB_GLOBAL_ONLY     8
#define GVF_GLOBAL_ONLY     &H100
#define GVB_LOCAL_ONLY      9
#define GVF_LOCAL_ONLY      &H200
#define GVB_BINARY_VAR      10      /* treat variable as binary */
#define GVF_BINARY_VAR      &H400
#define GVB_DONT_NULL_TERM  11  /* only with GVF_BINARY_VAR */
#define GVF_DONT_NULL_TERM  &H800

/* this is only supported in >= V39 dos.  V37 dos ignores this. */
/* this causes SetVar to affect ENVARC: as well as ENV:.    */
#define GVB_SAVE_VAR        12  /* only with GVF_GLOBAL_VAR */
#define GVF_SAVE_VAR        &H1000

#endif /* DOS_VAR_H */
