#ifndef GRAPHICS_REGIONS_H
#define GRAPHICS_REGIONS_H 1
/*
** regions.h for ACE Basic
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
** This are the StructPointer defines for regions.h
*/
#ifndef RegionPtr
#define RegionPtr ADDRESS
#endif
#ifndef RegionRectanglePtr
#define RegionRectanglePtr ADDRESS
#endif
/*
** End of StructPointer defines for regions.h
*/
     
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif


STRUCT RegionRectangle
 
    RegionRectanglePtr  _Next 
    RegionRectanglePtr  Prev 
    Rectangle bounds 
END STRUCT 

STRUCT Region
 
    Rectangle bounds 
    RegionRectanglePtr  RegionRectangle 
END STRUCT 

#endif  /* GRAPHICS_REGIONS_H */
