#ifndef  FUNCS_BULLET_FUNCS_H
#define  FUNCS_BULLET_FUNCS_H

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
#include <exec_types.h>
#endif

DECLARE FUNCTION STRUCTPTR OpenEngine() LIBRARY bullet
DECLARE FUNCTION CloseEngine( STRUCTPTR glyphEngine ) LIBRARY bullet
DECLARE FUNCTION LONGINT SetInfoA( STRUCTPTR glyphEngine, STRUCTPTR tagList ) LIBRARY bullet
DECLARE FUNCTION LONGINT ObtainInfoA( STRUCTPTR glyphEngine, STRUCTPTR tagList ) LIBRARY bullet
DECLARE FUNCTION LONGINT ReleaseInfoA( STRUCTPTR glyphEngine, STRUCTPTR tagList ) LIBRARY bullet
#endif   /* FUNCS_BULLET_FUNCS_H */
