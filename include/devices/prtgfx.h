#ifndef DEVICES_PRTGFX_H
#define DEVICES_PRTGFX_H 1
/*
** prtgfx.h for ACE Basic
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
** This are the StructPointer defines for prtgfx.h
*/
#ifndef PrtInfoPtr
#define PrtInfoPtr ADDRESS
#endif
#ifndef colorEntryPtr
#define colorEntryPtr ADDRESS
#endif
/*
** End of StructPointer defines for prtgfx.h
*/
       
#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif


#define PCMYELLOW   0       /* byte index for yellow */
#define PCMMAGENTA  1       /* byte index for magenta */
#define PCMCYAN     2       /* byte index for cyan */
#define PCMBLACK    3       /* byte index for black */
#define PCMBLUE     PCMYELLOW   /* byte index for blue */
#define PCMGREEN    PCMMAGENTA  /* byte index for green */
#define PCMRED      PCMCYAN     /* byte index for red */
#define PCMWHITE    PCMBLACK    /* byte index for white */

STRUCT colorEntry  
    LONGINT colorLong     /* quick access to all of YMCB */
    STRING colorByte SIZE 4   /* 1 entry for each of YMCB */
    STRING colorSByte SIZE 4   /* ditto (except signed) */
END STRUCT 

STRUCT PrtInfo   /* printer info */
    ADDRESS   pi_render      /* PRIVATE - DO NOT USE! */
    RastPortPtr  pi_rp      /* PRIVATE - DO NOT USE! */
    RastPortPtr  pi_temprp  /* PRIVATE - DO NOT USE! */
    ADDRESS   pi_RowBuf        /* PRIVATE - DO NOT USE! */
    ADDRESS   pi_HamBuf        /* PRIVATE - DO NOT USE! */
    colorEntryPtr  pi_ColorMap   /* PRIVATE - DO NOT USE! */
    colorEntryPtr  pi_ColorInt   /* color intensities for entire row */
    colorEntryPtr  pi_HamInt     /* PRIVATE - DO NOT USE! */
    colorEntryPtr  pi_Dest1Int   /* PRIVATE - DO NOT USE! */
    colorEntryPtr  pi_Dest2Int   /* PRIVATE - DO NOT USE! */
    ADDRESS   pi_ScaleX        /* array of scale values for X */
    ADDRESS   pi_ScaleXAlt         /* PRIVATE - DO NOT USE! */
    ADDRESS   pi_dmatrix       /* pointer to dither matrix */
    ADDRESS   pi_TopBuf        /* PRIVATE - DO NOT USE! */
    ADDRESS   pi_BotBuf        /* PRIVATE - DO NOT USE! */

    SHORTINT pi_RowBufSize         /* PRIVATE - DO NOT USE! */
    SHORTINT pi_HamBufSize         /* PRIVATE - DO NOT USE! */
    SHORTINT pi_ColorMapSize       /* PRIVATE - DO NOT USE! */
    SHORTINT pi_ColorIntSize       /* PRIVATE - DO NOT USE! */
    SHORTINT pi_HamIntSize         /* PRIVATE - DO NOT USE! */
    SHORTINT pi_Dest1IntSize       /* PRIVATE - DO NOT USE! */
    SHORTINT pi_Dest2IntSize       /* PRIVATE - DO NOT USE! */
    SHORTINT pi_ScaleXSize         /* PRIVATE - DO NOT USE! */
    SHORTINT pi_ScaleXAltSize      /* PRIVATE - DO NOT USE! */

    SHORTINT pi_PrefsFlags         /* PRIVATE - DO NOT USE! */
    LONGINT  pi_special        /* PRIVATE - DO NOT USE! */
    SHORTINT pi_xstart         /* PRIVATE - DO NOT USE! */
    SHORTINT pi_ystart         /* PRIVATE - DO NOT USE! */
    SHORTINT pi_width          /* source width (in pixels) */
    SHORTINT pi_height         /* PRIVATE - DO NOT USE! */
    LONGINT  pi_pc             /* PRIVATE - DO NOT USE! */
    LONGINT  pi_pr             /* PRIVATE - DO NOT USE! */
    SHORTINT pi_ymult          /* PRIVATE - DO NOT USE! */
    SHORTINT pi_ymod           /* PRIVATE - DO NOT USE! */
    SHORTINT pi_ety             /* PRIVATE - DO NOT USE! */
    SHORTINT pi_xpos           /* offset to start printing picture */
    SHORTINT pi_threshold      /* threshold value (from prefs) */
    SHORTINT pi_tempwidth      /* PRIVATE - DO NOT USE! */
    SHORTINT pi_flags          /* PRIVATE - DO NOT USE! */
END STRUCT 

#endif  /* DEVICES_PRTGFX_H */
