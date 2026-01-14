#ifndef  FUNCS_ASL_FUNCS_H
#define  FUNCS_ASL_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

/*--- functions in V36 or higher (Release 2.0) ---*/

/* OBSOLETE -- Please use the generic requester functions instead */

DECLARE FUNCTION STRUCTPTR AllocFileRequest() LIBRARY asl
DECLARE FUNCTION FreeFileRequest( STRUCTPTR fileReq ) LIBRARY asl
DECLARE FUNCTION BOOL RequestFile( STRUCTPTR fileReq ) LIBRARY asl
DECLARE FUNCTION APTR AllocAslRequest( LONGINT reqType, STRUCTPTR tagList ) LIBRARY asl
DECLARE FUNCTION FreeAslRequest( APTR request ) LIBRARY asl
DECLARE FUNCTION BOOL AslRequest( APTR request, STRUCTPTR tagList ) LIBRARY asl

#endif   /* FUNCS_ASL_FUNCS_H */
