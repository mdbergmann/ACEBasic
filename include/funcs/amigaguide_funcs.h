#ifndef  FUNCS_AMIGAGUIDE_FUNCS_H
#define  FUNCS_AMIGAGUIDE_FUNCS_H

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


/*--- functions in V40 or higher (Release 3.1) ---*/

/* Public entries */

DECLARE FUNCTION LONGINT LockAmigaGuideBase( APTR _handle ) LIBRARY amigaguide
DECLARE FUNCTION UnlockAmigaGuideBase( LONGINT key ) LIBRARY amigaguide
DECLARE FUNCTION APTR OpenAmigaGuideA(STRUCTPTR nag, STRUCTPTR rest) LIBRARY amigaguide
DECLARE FUNCTION APTR OpenAmigaGuideAsyncA(STRUCTPTR nag, STRUCTPTR attrs ) LIBRARY amigaguide
DECLARE FUNCTION CloseAmigaGuide(APTR cl ) LIBRARY amigaguide
DECLARE FUNCTION LONGINT AmigaGuideSignal(APTR cl ) LIBRARY amigaguide
DECLARE FUNCTION STRUCTPTR GetAmigaGuideMsg(APTR cl ) LIBRARY amigaguide
DECLARE FUNCTION ReplyAmigaGuideMsg(STRUCTPTR amsg ) LIBRARY amigaguide
DECLARE FUNCTION LONGINT SetAmigaGuideContextA(APTR cl, LONGINT id, \
                                               STRUCTPTR attrs ) LIBRARY amigaguide
DECLARE FUNCTION LONGINT SendAmigaGuideContextA( APTR cl, STRUCTPTR attrs ) LIBRARY amigaguide
DECLARE FUNCTION LONGINT SendAmigaGuideCmdA( APTR cl, STRPTR cmd, STRUCTPTR attrs ) LIBRARY amigaguide
DECLARE FUNCTION LONGINT SetAmigaGuideAttrsA( APTR cl, STRUCTPTR attrs ) LIBRARY amigaguide
DECLARE FUNCTION LONGINT GetAmigaGuideAttr( LONGINT tag, APTR cl, ADDRESS storage ) LIBRARY amigaguide
DECLARE FUNCTION LONGINT LoadXRef( BPTR lock, STRPTR _name ) LIBRARY amigaguide
DECLARE FUNCTION ExpungeXRef() LIBRARY amigaguide
DECLARE FUNCTION APTR AddAmigaGuideHostA( STRUCTPTR h, STRPTR _name, STRUCTPTR attrs ) LIBRARY amigaguide
DECLARE FUNCTION LONGINT RemoveAmigaGuideHostA( APTR hh, STRUCTPTR attrs ) LIBRARY amigaguide
DECLARE FUNCTION STRPTR GetAmigaGuideString( LONGINT id ) LIBRARY amigaguide

#endif   /* FUNCS_AMIGAGUIDE_FUNCS_H */
