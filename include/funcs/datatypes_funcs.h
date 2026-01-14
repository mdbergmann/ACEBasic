#ifndef  FUNCS_DATATYPES_FUNCS_H
#define  FUNCS_DATATYPES_FUNCS_H

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

/*--- functions in V40 or higher (Release 3.1) ---*/

/* Public entries */

DECLARE FUNCTION STRUCTPTR ObtainDataTypeA( LONGINT _type, APTR _handle, \
                                            STRUCTPTR attrs ) LIBRARY datatypes
DECLARE FUNCTION ReleaseDataType( STRUCTPTR dt ) LIBRARY datatypes
DECLARE FUNCTION ADDRESS NewDTObjectA( APTR _name, STRUCTPTR attrs ) LIBRARY datatypes
DECLARE FUNCTION DisposeDTObject( ADDRESS o ) LIBRARY datatypes
DECLARE FUNCTION LONGINT SetDTAttrsA( ADDRESS o, STRUCTPTR win, STRUCTPTR req, \
                                      STRUCTPTR attrs ) LIBRARY datatypes
DECLARE FUNCTION LONGINT GetDTAttrsA( ADDRESS o, STRUCTPTR attrs ) LIBRARY datatypes
DECLARE FUNCTION LONGINT AddDTObject( STRUCTPTR win, STRUCTPTR req, ADDRESS o, \
                                      LONGINT  _pos ) LIBRARY datatypes
DECLARE FUNCTION RefreshDTObjectA( ADDRESS o, STRUCTPTR win, STRUCTPTR req, \
                                   STRUCTPTR attrs ) LIBRARY datatypes
DECLARE FUNCTION LONGINT DoAsyncLayout( ADDRESS o, STRUCTPTR gpl ) LIBRARY datatypes
DECLARE FUNCTION LONGINT DoDTMethodA( ADDRESS o, STRUCTPTR win, STRUCTPTR req, \
                                   ADDRESS msg ) LIBRARY datatypes
DECLARE FUNCTION LONGINT RemoveDTObject( STRUCTPTR win, ADDRESS o ) LIBRARY datatypes
DECLARE FUNCTION ADDRESS GetDTMethods( ADDRESS object ) LIBRARY datatypes
DECLARE FUNCTION STRUCTPTR GetDTTriggerMethods( ADDRESS object ) LIBRARY datatypes
DECLARE FUNCTION LONGINT PrintDTObjectA( ADDRESS o, STRUCTPTR w, STRUCTPTR r, \
                                         STRUCTPTR msg ) LIBRARY datatypes
DECLARE FUNCTION STRPTR GetDTString( LONGINT id ) LIBRARY datatypes

#endif   /* FUNCS_DATATYPES_FUNCS_H */
