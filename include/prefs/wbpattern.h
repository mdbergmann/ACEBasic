#ifndef PREFS_WBPATTERN_H
#define PREFS_WBPATTERN_H 1
/*
** wbpattern.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
**
*/

/*
** This are the StructPointer defines for wbpattern.h
*/
#ifndef WBPatternPrefsPtr
#define WBPatternPrefsPtr ADDRESS
#endif
/*
** End of StructPointer defines for wbpattern.h
*/


/*****************************************************************************/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif

/*****************************************************************************/

#define ID_PTRN 1347703374 

/*****************************************************************************/

STRUCT WBPatternPrefs
 
    STRING wbp_Reserved SIZE 16  /* 4*SIZEOF(LONGINT) */
    SHORTINT    wbp_Which          /* Which pattern is it */
    SHORTINT    wbp_Flags 
    BYTE     wbp_Revision           /* Must be set to zero */
    BYTE     wbp_Depth          /* Depth of pattern */
    SHORTINT    wbp_DataLength         /* Length of following data */
END STRUCT 

/*****************************************************************************/

/* constants for WBPatternPrefs.wbp_Which */
#define WBP_ROOT    0
#define WBP_DRAWER  1
#define WBP_SCREEN  2

/* wbp_Flags values */
#define WBPF_PATTERN    &H0001
    /* Data contains a pattern */

#define WBPF_NOREMAP    &H0010
    /* Don't remap the pattern */

/*****************************************************************************/

#define MAXDEPTH    3   /*  Max depth supported (8 colors) */
#define DEFPATDEPTH 2   /*  Depth of default patterns */

/*  Pattern width & height: */
#define PAT_WIDTH   16
#define PAT_HEIGHT  16

/*****************************************************************************/

#endif /* PREFS_WBPATTERN_H */
