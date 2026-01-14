#ifndef  FUNCS_MATHIEEESINGBAS_FUNCS_H
#define  FUNCS_MATHIEEESINGBAS_FUNCS_H

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

DECLARE FUNCTION LONGINT IEEESPFix( SINGLE parm ) LIBRARY mathieeesingbas
DECLARE FUNCTION SINGLE IEEESPFlt( LONGINT integer ) LIBRARY mathieeesingbas
DECLARE FUNCTION LONGINT IEEESPCmp( SINGLE leftParm, SINGLE rightParm ) LIBRARY mathieeesingbas
DECLARE FUNCTION LONGINT IEEESPTst( SINGLE parm ) LIBRARY mathieeesingbas
DECLARE FUNCTION SINGLE IEEESPAbs( SINGLE parm ) LIBRARY mathieeesingbas
DECLARE FUNCTION SINGLE IEEESPNeg( SINGLE parm ) LIBRARY mathieeesingbas
DECLARE FUNCTION SINGLE IEEESPAdd( SINGLE leftParm, SINGLE rightParm ) LIBRARY mathieeesingbas
DECLARE FUNCTION SINGLE IEEESPSub( SINGLE leftParm, SINGLE rightParm ) LIBRARY mathieeesingbas
DECLARE FUNCTION SINGLE IEEESPMul( SINGLE leftParm, SINGLE rightParm ) LIBRARY mathieeesingbas
DECLARE FUNCTION SINGLE IEEESPDiv( SINGLE dividend, SINGLE divisor ) LIBRARY mathieeesingbas
DECLARE FUNCTION SINGLE IEEESPFloor( SINGLE parm ) LIBRARY mathieeesingbas
DECLARE FUNCTION SINGLE IEEESPCeil( SINGLE parm ) LIBRARY mathieeesingbas
#endif   /* FUNCS_MATHIEEESINGBAS_FUNCS_H */
