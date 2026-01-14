#ifndef GRAPHICS_SPRITE_H
#define GRAPHICS_SPRITE_H 1
/*
** sprite.h for ACE Basic
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
** This are the StructPointer defines for sprite.h
*/
#ifndef ExtSpritePtr
#define ExtSpritePtr ADDRESS
#endif
#ifndef SimpleSpritePtr
#define SimpleSpritePtr ADDRESS
#endif
/*
** End of StructPointer defines for sprite.h
*/
         
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#define SPRITE_ATTACHED &H80

STRUCT SimpleSprite
 
    ADDRESS   posctldata 
    SHORTINT height 
    SHORTINT   x 
    SHORTINT  y     /* current position */
    SHORTINT   num 
END STRUCT 

STRUCT ExtSprite
 
    SimpleSprite es_SimpleSprite     /* conventional simple sprite structure */
    SHORTINT   es_wordwidth            /* graphics use only,  subject to change */
    SHORTINT   es_flags            /* graphics use only,  subject to change */
END STRUCT 



/* tags for AllocSpriteData() */
#define SPRITEA_Width       &H81000000
#define SPRITEA_XReplication    &H81000002
#define SPRITEA_YReplication    &H81000004
#define SPRITEA_OutputHeight    &H81000006
#define SPRITEA_Attached    &H81000008
#define SPRITEA_OldDataFormat   &H8100000a  /* MUST pass in outputheight if using this tag */

/* tags for GetExtSprite() */
#define GSTAG_SPRITE_NUM &H82000020
#define GSTAG_ATTACHED   &H82000022
#define GSTAG_SOFTSPRITE &H82000024

/* tags valid for either GetExtSprite or ChangeExtSprite */
#define GSTAG_SCANDOUBLED   &H83000000  /* request "NTSC-Like" height if possible. */

#endif  /* GRAPHICS_SPRITE_H */
