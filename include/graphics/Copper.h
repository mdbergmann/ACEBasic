#ifndef GRAPHICS_COPPER_H
#define GRAPHICS_COPPER_H 1
/*
** copper.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/

/*
** This are the StructPointer defines for copper.h
*/
#ifndef CopInsPtr
#define CopInsPtr ADDRESS
#endif
#ifndef CopListPtr
#define CopListPtr ADDRESS
#endif
#ifndef UCopListPtr
#define UCopListPtr ADDRESS
#endif
#ifndef copinitPtr
#define copinitPtr ADDRESS
#endif
#ifndef cprlistPtr
#define cprlistPtr ADDRESS
#endif
/*
** End of StructPointer defines for copper.h
*/
        
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif


#define COPPER_MOVE 0       /* pseude opcode for move #XXXX, dir */
#define COPPER_WAIT 1       /* pseudo opcode for wait y, x */
#define CPRNXTBUF   2       /* continue processing with next buffer */
#define CPR_NT_LOF  &H8000  /* copper instruction only for SHORTINT frames */
#define CPR_NT_SHT  &H4000  /* copper instruction only for LONGINT frames */
#define CPR_NT_SYS  &H2000  /* copper user instruction only */

STRUCT CopIns
 
    SHORTINT   OpCode  /* 0 = move,  1 = wait */

    SHORTINT VWaitPos         /* vertical beam WAIT */
    SHORTINT DestAddr         /* destination ADDRESS of copper move */

END STRUCT 

/* shorthand FOR above */
/*
#define NXTLIST     u3.nxtlist
#define VWAITPOS    u3.u4.u1.VWaitPos
#define DESTADDR    u3.u4.u1.DestAddr
#define HWAITPOS    u3.u4.u2.HWaitPos
#define DESTDATA    u3.u4.u2.DestData
*/

/* structure of cprlist that points to list that hardware actually executes */
STRUCT cprlist
 
    cprlistPtr  _Next 
    ADDRESS   start      /* start of copper list */
    SHORTINT   MaxCount        /* number of LONGINT instructions */
END STRUCT 

STRUCT CopList
 
    CopListPtr  _Next   /* next block for this copper list */
    CopListPtr  _CopList   /* system use */
    ViewPortPtr  _ViewPort     /* system use */
    CopInsPtr  CopIns  /* start of this block */
    CopInsPtr  CopPtr  /* intermediate ptr */
    ADDRESS   CopLStart      /* mrgcop fills this in for LONGINT Frame*/
    ADDRESS   CopSStart      /* mrgcop fills this in for SHORTINT Frame*/
    SHORTINT   Count       /* intermediate counter */
    SHORTINT   MaxCount        /* max # of copins for this block */
    SHORTINT   DyOffset        /* offset this copper list vertical waits */
#ifdef V1_3
    ADDRESS   Cop2Start 
    ADDRESS   Cop3Start 
    ADDRESS   Cop4Start 
    ADDRESS   Cop5Start 
#endif
    SHORTINT  SLRepeat 
    SHORTINT  Flags 
END STRUCT 

/* These CopList->Flags are private */
#define EXACT_LINE 1
#define HALF_LINE 2


STRUCT UCopList
 
    UCopListPtr  _Next 
    CopListPtr  FirstCopList  /* head node of this copper list */
    CopListPtr  CopList       /* node in use */
END STRUCT 

/* Private graphics data structure. This structure has changed in the past, 
 * and will continue to change in the future. Do Not Touch!
 */

STRUCT copinit
 
    STRING vsync_hblank SIZE 4   /*  2*SIZEOF(SHORTINT)      */
    STRING diagstrt SIZE 24      /*  12*SIZEOF(SHORTINT)     */  /* copper LIST FOR first bitplane */
    STRING fm0 SIZE 4            /*  2*SIZEOF(SHORTINT)      */
    STRING diwstart SIZE 20      /*  10*SIZEOF(SHORTINT)     */
    STRING bplcon2 SIZE 4        /*  2*SIZEOF(SHORTINT)      */
    STRING sprfix SIZE 32        /*  2*8*SIZEOF(SHORTINT)    */
    STRING sprstrtup SIZE 64     /*  (2*8*2)*SIZEOF(SHORTINT)*/
    STRING wait14 SIZE 4         /*  2*SIZEOF(SHORTINT)      */
    STRING norm_hblank SIZE 4    /*  2*SIZEOF(SHORTINT)      */
    STRING jump SIZE 4           /*  2*SIZEOF(SHORTINT)      */
    STRING wait_forever SIZE 12  /*  6*SIZEOF(SHORTINT)      */
    STRING sprstop SIZE 16       /*  8*SIZEOF(SHORTINT)      */
END STRUCT 

#endif  /* GRAPHICS_COPPER_H */
