#ifndef  FUNCS_COLORWHEEL_FUNCS_H
#define  FUNCS_COLORWHEEL_FUNCS_H

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

/*--- functions in V39 or higher (Release 3) ---*/

/* Public entries */

DECLARE FUNCTION ConvertHSBToRGB( STRUCTPTR hsb, STRUCTPTR rgb ) LIBRARY colorwheel
DECLARE FUNCTION ConvertRGBToHSB( STRUCTPTR rgb, STRUCTPTR hsb ) LIBRARY colorwheel
#endif   /* FUNCS_COLORWHEEL_FUNCS_H */
