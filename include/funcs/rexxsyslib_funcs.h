#ifndef  FUNCS_REXXSYSLIB_FUNCS_H
#define  FUNCS_REXXSYSLIB_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

/*--- functions in V33 OR higher (Release 1.2) ---*/
#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

DECLARE FUNCTION ADDRESS CreateArgstring( ADDRESS _STRING, LONGINT length ) LIBRARY rexxsyslib
DECLARE FUNCTION DeleteArgstring( ADDRESS argstring ) LIBRARY rexxsyslib
DECLARE FUNCTION LONGINT LengthArgstring( ADDRESS argstring ) LIBRARY rexxsyslib
DECLARE FUNCTION STRUCTPTR CreateRexxMsg( STRUCTPTR port, ADDRESS extension, \
                                          ADDRESS host ) LIBRARY rexxsyslib
DECLARE FUNCTION DeleteRexxMsg( STRUCTPTR packet ) LIBRARY rexxsyslib
DECLARE FUNCTION ClearRexxMsg( STRUCTPTR msgptr, LONGINT count ) LIBRARY rexxsyslib
DECLARE FUNCTION BOOL FillRexxMsg( STRUCTPTR msgptr, LONGINT count, LONGINT mask ) LIBRARY rexxsyslib
DECLARE FUNCTION BOOL IsRexxMsg( STRUCTPTR msgptr ) LIBRARY rexxsyslib


DECLARE FUNCTION LockRexxBase( LONGINT resource ) LIBRARY rexxsyslib
DECLARE FUNCTION UnlockRexxBase( LONGINT resource ) LIBRARY rexxsyslib

#endif   /* FUNCS_REXXSYSLIB_FUNCS_H */
