#ifndef DEVICES_CONUNIT_H
#define DEVICES_CONUNIT_H 1
/*
** conunit.h for ACE Basic
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
** This are the StructPointer defines for conunit.h
*/
#ifndef ConUnitPtr
#define ConUnitPtr ADDRESS
#endif
/*
** End of StructPointer defines for conunit.h
*/
        
#ifndef EXEC_TYPES_H
#include    <exec/types.h>
#endif

#ifndef EXEC_PORTS_H
#include    <exec/ports.h>
#endif

#ifndef DEVICES_CONSOLE_H
#include    <devices/console.h>
#endif

#ifndef DEVICES_KEYMAP_H
#include    <devices/keymap.h>
#endif

#ifndef DEVICES_INPUTEVENT_H
#include    <devices/inputevent.h>
#endif


/* ---- console unit numbers for OpenDevice() */
#define CONU_LIBRARY    -1  /* no unit,  just fill in IO_DEVICE field */
#define CONU_STANDARD   0   /* standard unmapped console */

/* ---- New unit numbers for OpenDevice() - (V36) */

#define CONU_CHARMAP    1   /* bind character map to console */
#define CONU_SNIPMAP    3   /* bind character map w/ snip to console */

/* ---- New flag defines for OpenDevice() - (V37) */

#define CONFLAG_DEFAULT         0
#define CONFLAG_NODRAW_ON_NEWSIZE   1


#define PMB_ASM     (M_LNM+1)   /* internal storage bit for AS flag */
#define PMB_AWM     (PMB_ASM+1) /* internal storage bit for AW flag */
#define MAXTABS     80


STRUCT  ConUnit  
    MsgPort cu_MP 
    /* ---- read only variables */
    WindowPtr  cu_Window   /* intuition window bound to this unit */
    SHORTINT    cu_XCP      /* character position */
    SHORTINT    cu_YCP 
    SHORTINT    cu_XMax         /* max character position */
    SHORTINT    cu_YMax 
    SHORTINT    cu_XRSize       /* character raster size */
    SHORTINT    cu_YRSize 
    SHORTINT    cu_XROrigin     /* raster origin */
    SHORTINT    cu_YROrigin 
    SHORTINT    cu_XRExtant     /* raster maxima */
    SHORTINT    cu_YRExtant 
    SHORTINT    cu_XMinShrink   /* smallest area intact from resize process */
    SHORTINT    cu_YMinShrink 
    SHORTINT    cu_XCCP         /* cursor position */
    SHORTINT    cu_YCCP 

    /* ---- read/write variables (writes must must be protected) */
    /* ---- storage for AskKeyMap and SetKeyMap */
    KeyMap cu_KeyMapStruct 
    /* ---- tab stops */
    STRING cu_TabStops SIZE 160  /*  MAXTABS*SIZEOF(SHORTINT) */  /* 0 at start,  &Hffff at END of LIST */

    /* ---- console rastport attributes */
    BYTE    cu_Mask 
    BYTE    cu_FgPen 
    BYTE    cu_BgPen 
    BYTE    cu_AOLPen 
    BYTE    cu_DrawMode 
    BYTE    cu_Obsolete1    /* was cu_AreaPtSz -- not used in V36 */
    ADDRESS    cu_Obsolete2    /* was cu_AreaPtrn -- not used in V36 */
    STRING cu_Minterms SIZE 8   /* console minterms */
    TextFontPtr  cu_Font 
    BYTE    cu_AlgoStyle 
    BYTE    cu_TxFlags 
    SHORTINT   cu_TxHeight 
    SHORTINT   cu_TxWidth 
    SHORTINT   cu_TxBaseline 
    SHORTINT    cu_TxSpacing 

    /* ---- console MODES and RAW EVENTS switches */
    STRING cu_Modes SIZE 3  /* (PMB_AWM+7)/8 */     /* one bit per mode */
    STRING cu_RawEvents SIZE 4  /* (IECLASS_MAX+8)/8 */
END STRUCT 

#endif  /* DEVICES_CONUNIT_H */
