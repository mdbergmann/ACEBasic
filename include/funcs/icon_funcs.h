#ifndef  FUNCS_ICON_FUNCS_H
#define  FUNCS_ICON_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

DECLARE FUNCTION FreeFreeList( STRUCTPTR freelist ) LIBRARY icon
DECLARE FUNCTION BOOL AddFreeList( STRUCTPTR freelist, APTR mem, LONGINT _SIZE ) LIBRARY icon
DECLARE FUNCTION STRUCTPTR GetDiskObject( ADDRESS _NAME ) LIBRARY icon
DECLARE FUNCTION BOOL PutDiskObject( ADDRESS _NAME, STRUCTPTR diskobj ) LIBRARY icon
DECLARE FUNCTION FreeDiskObject( STRUCTPTR diskobj ) LIBRARY icon
DECLARE FUNCTION ADDRESS FindToolType( ADDRESS toolTypeArray, ADDRESS typeName ) LIBRARY icon
DECLARE FUNCTION BOOL MatchToolValue( ADDRESS typeString, ADDRESS value ) LIBRARY icon
DECLARE FUNCTION ADDRESS BumpRevision( ADDRESS newname, ADDRESS oldname ) LIBRARY icon
/*--- functions in V36 OR higher (Release 2.0) ---*/
DECLARE FUNCTION STRUCTPTR GetDefDiskObject( LONGINT _TYPE ) LIBRARY icon
DECLARE FUNCTION BOOL PutDefDiskObject( STRUCTPTR diskObject ) LIBRARY icon
DECLARE FUNCTION STRUCTPTR GetDiskObjectNew( ADDRESS _NAME ) LIBRARY icon
/*--- functions in V37 OR higher (Release 2.04) ---*/
DECLARE FUNCTION BOOL DeleteDiskObject( ADDRESS _NAME ) LIBRARY icon

#endif   /* FUNCS_ICON_FUNCS_H */
