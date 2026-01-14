#ifndef  FUNCS_NONVOLATILE_FUNCS_H
#define  FUNCS_NONVOLATILE_FUNCS_H

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

/*--- functions in V40 OR higher (Release 3.1) ---*/
DECLARE FUNCTION APTR GetCopyNV( STRPTR appName, STRPTR itemName, LONGINT killRequesters ) LIBRARY nonvolatile
DECLARE FUNCTION FreeNVData( APTR _DATA ) LIBRARY nonvolatile
DECLARE FUNCTION SHORTINT StoreNV( STRPTR appName, STRPTR itemName, APTR _DATA, \
                                   LONGINT length, LONGINT killRequesters ) LIBRARY nonvolatile
DECLARE FUNCTION BOOL DeleteNV( STRPTR appName, STRPTR itemName, LONGINT killRequesters ) LIBRARY nonvolatile
DECLARE FUNCTION STRUCTPTR GetNVInfo( LONGINT killRequesters ) LIBRARY nonvolatile
DECLARE FUNCTION STRUCTPTR GetNVList( STRPTR appName, LONGINT killRequesters ) LIBRARY nonvolatile
DECLARE FUNCTION BOOL SetNVProtection( STRPTR appName, STRPTR itemName, LONGINT mask, \
                                       LONGINT killRequesters ) LIBRARY nonvolatile
#endif   /* FUNCS_NONVOLATILE_FUNCS_H */
