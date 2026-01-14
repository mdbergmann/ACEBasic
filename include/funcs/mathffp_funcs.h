#ifndef  FUNCS_MATHFFP_FUNCS_H
#define  FUNCS_MATHFFP_FUNCS_H

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

DECLARE FUNCTION LONGINT SPFix( SINGLE parm ) LIBRARY mathffp
DECLARE FUNCTION SINGLE SPFlt( LONGINT integer ) LIBRARY mathffp
DECLARE FUNCTION LONGINT SPCmp( SINGLE leftParm, SINGLE rightParm ) LIBRARY mathffp
DECLARE FUNCTION LONGINT SPTst( SINGLE parm ) LIBRARY mathffp
DECLARE FUNCTION SINGLE SPAbs( SINGLE parm ) LIBRARY mathffp
DECLARE FUNCTION SINGLE SPNeg( SINGLE parm ) LIBRARY mathffp
DECLARE FUNCTION SINGLE SPAdd( SINGLE leftParm, SINGLE rightParm ) LIBRARY mathffp
DECLARE FUNCTION SINGLE SPSub( SINGLE leftParm, SINGLE rightParm ) LIBRARY mathffp
DECLARE FUNCTION SINGLE SPMul( SINGLE leftParm, SINGLE rightParm ) LIBRARY mathffp
DECLARE FUNCTION SINGLE SPDiv( SINGLE leftParm, SINGLE rightParm ) LIBRARY mathffp
/*--- functions in V33 OR higher (Release 1.2) ---*/
DECLARE FUNCTION SINGLE SPFloor( SINGLE parm ) LIBRARY mathffp
DECLARE FUNCTION SINGLE SPCeil( SINGLE parm ) LIBRARY mathffp
#endif   /* FUNCS_MATHFFP_FUNCS_H */
