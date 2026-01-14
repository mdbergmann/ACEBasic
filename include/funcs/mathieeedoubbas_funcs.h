#ifndef  FUNCS_MATHIEEEDOUBBAS_FUNCS_H
#define  FUNCS_MATHIEEEDOUBBAS_FUNCS_H

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

DECLARE FUNCTION LONGINT IEEEDPFix( DOUBLE parm ) LIBRARY mathieeedoubbas
DECLARE FUNCTION DOUBLE IEEEDPFlt( LONGINT integer ) LIBRARY mathieeedoubbas
DECLARE FUNCTION LONGINT IEEEDPCmp( DOUBLE leftParm, DOUBLE rightParm ) LIBRARY mathieeedoubbas
DECLARE FUNCTION LONGINT IEEEDPTst( DOUBLE parm ) LIBRARY mathieeedoubbas
DECLARE FUNCTION DOUBLE IEEEDPAbs( DOUBLE parm ) LIBRARY mathieeedoubbas
DECLARE FUNCTION DOUBLE IEEEDPNeg( DOUBLE parm ) LIBRARY mathieeedoubbas
DECLARE FUNCTION DOUBLE IEEEDPAdd( DOUBLE leftParm, DOUBLE rightParm ) LIBRARY mathieeedoubbas
DECLARE FUNCTION DOUBLE IEEEDPSub( DOUBLE leftParm, DOUBLE rightParm ) LIBRARY mathieeedoubbas
DECLARE FUNCTION DOUBLE IEEEDPMul( DOUBLE factor1, DOUBLE factor2 ) LIBRARY mathieeedoubbas
DECLARE FUNCTION DOUBLE IEEEDPDiv( DOUBLE dividend, DOUBLE divisor ) LIBRARY mathieeedoubbas
/*--- functions in V33 or higher (Release 1.2) ---*/
DECLARE FUNCTION DOUBLE IEEEDPFloor( DOUBLE parm ) LIBRARY mathieeedoubbas
DECLARE FUNCTION DOUBLE IEEEDPCeil( DOUBLE parm ) LIBRARY mathieeedoubbas
#endif   /* FUNCS_MATHIEEEDOUBBAS_FUNCS_H */
