#ifndef  FUNCS_COMMODITIES_FUNCS_H
#define  FUNCS_COMMODITIES_FUNCS_H

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

/*--- functions in V36 OR higher (Release 2.0) ---*/

/*  OBJECT UTILITIES */

DECLARE FUNCTION ADDRESS CreateCxObj( LONGINT _type, LONGINT arg1, LONGINT arg2 ) LIBRARY commodities
DECLARE FUNCTION ADDRESS CxBroker( STRUCTPTR nb, ADDRESS _error ) LIBRARY commodities
DECLARE FUNCTION LONGINT ActivateCxObj( ADDRESS co, LONGINT _true ) LIBRARY commodities
DECLARE FUNCTION DeleteCxObj( ADDRESS co ) LIBRARY commodities
DECLARE FUNCTION DeleteCxObjAll( ADDRESS co ) LIBRARY commodities
DECLARE FUNCTION LONGINT CxObjType( ADDRESS co ) LIBRARY commodities
DECLARE FUNCTION LONGINT  CxObjError( ADDRESS co ) LIBRARY commodities
DECLARE FUNCTION ClearCxObjError( ADDRESS co ) LIBRARY commodities
DECLARE FUNCTION LONGINT SetCxObjPri( ADDRESS co, LONGINT pri ) LIBRARY commodities

/*  OBJECT ATTACHMENT */

DECLARE FUNCTION AttachCxObj( ADDRESS headObj, ADDRESS co ) LIBRARY commodities
DECLARE FUNCTION EnqueueCxObj( ADDRESS headObj, ADDRESS co ) LIBRARY commodities
DECLARE FUNCTION InsertCxObj( ADDRESS headObj, ADDRESS co, ADDRESS pred ) LIBRARY commodities
DECLARE FUNCTION RemoveCxObj( ADDRESS co )  LIBRARY commodities

/*  TYPE SPECIFIC */

DECLARE FUNCTION SetTranslate( ADDRESS translator, STRUCTPTR events ) LIBRARY commodities
DECLARE FUNCTION SetFilter( ADDRESS filter, STRPTR text ) LIBRARY commodities
DECLARE FUNCTION SetFilterIX( ADDRESS filter, ADDRESS ix ) LIBRARY commodities
DECLARE FUNCTION LONGINT ParseIX( STRPTR description, ADDRESS ix ) LIBRARY commodities

/*  COMMON MESSAGE */

DECLARE FUNCTION LONGINT CxMsgType( ADDRESS cxm ) LIBRARY commodities
DECLARE FUNCTION APTR CxMsgData( ADDRESS cxm ) LIBRARY commodities
DECLARE FUNCTION LONGINT CxMsgID( ADDRESS cxm ) LIBRARY commodities

/*  MESSAGE ROUTING */

DECLARE FUNCTION DivertCxMsg( ADDRESS cxm, ADDRESS headObj, ADDRESS returnObj ) LIBRARY commodities
DECLARE FUNCTION RouteCxMsg( ADDRESS cxm, ADDRESS co ) LIBRARY commodities
DECLARE FUNCTION DisposeCxMsg( ADDRESS cxm ) LIBRARY commodities

/*  INPUT EVENT HANDLING */

DECLARE FUNCTION BOOL InvertKeyMap( LONGINT ansiCode, STRUCTPTR event, \
                                    STRUCTPTR km ) LIBRARY commodities
DECLARE FUNCTION AddIEvents( STRUCTPTR events ) LIBRARY commodities

/*--- functions in V38 OR higher (Release 2.1) ---*/
/*  MORE INPUT EVENT HANDLING */
DECLARE FUNCTION BOOL MatchIX( STRUCTPTR event, ADDRESS ix ) LIBRARY commodities

#endif   /* FUNCS_COMMODITIES_FUNCS_H */
