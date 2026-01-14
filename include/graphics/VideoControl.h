#ifndef GRAPHICS_VIDEOCONTROL_H
#define GRAPHICS_VIDEOCONTROL_H 1
/*
** videocontrol.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEC_TYPES_H */

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif /* UTILITY_TAGITEM_H */

#define VTAG_END_CM             &H00000000
#define VTAG_CHROMAKEY_CLR      &H80000000
#define VTAG_CHROMAKEY_SET      &H80000001
#define VTAG_BITPLANEKEY_CLR        &H80000002
#define VTAG_BITPLANEKEY_SET        &H80000003
#define VTAG_BORDERBLANK_CLR        &H80000004
#define VTAG_BORDERBLANK_SET        &H80000005
#define VTAG_BORDERNOTRANS_CLR      &H80000006
#define VTAG_BORDERNOTRANS_SET      &H80000007
#define VTAG_CHROMA_PEN_CLR     &H80000008
#define VTAG_CHROMA_PEN_SET     &H80000009
#define VTAG_CHROMA_PLANE_SET       &H8000000A
#define VTAG_ATTACH_CM_SET      &H8000000B
#define VTAG_NEXTBUF_CM         &H8000000C
#define VTAG_BATCH_CM_CLR       &H8000000D
#define VTAG_BATCH_CM_SET       &H8000000E
#define VTAG_NORMAL_DISP_GET        &H8000000F
#define VTAG_NORMAL_DISP_SET        &H80000010
#define VTAG_COERCE_DISP_GET        &H80000011
#define VTAG_COERCE_DISP_SET        &H80000012
#define VTAG_VIEWPORTEXTRA_GET      &H80000013
#define VTAG_VIEWPORTEXTRA_SET      &H80000014
#define VTAG_CHROMAKEY_GET      &H80000015
#define VTAG_BITPLANEKEY_GET        &H80000016
#define VTAG_BORDERBLANK_GET        &H80000017
#define VTAG_BORDERNOTRANS_GET      &H80000018
#define VTAG_CHROMA_PEN_GET     &H80000019
#define VTAG_CHROMA_PLANE_GET       &H8000001A
#define VTAG_ATTACH_CM_GET      &H8000001B
#define VTAG_BATCH_CM_GET       &H8000001C
#define VTAG_BATCH_ITEMS_GET        &H8000001D
#define VTAG_BATCH_ITEMS_SET        &H8000001E
#define VTAG_BATCH_ITEMS_ADD        &H8000001F
#define VTAG_VPMODEID_GET       &H80000020
#define VTAG_VPMODEID_SET       &H80000021
#define VTAG_VPMODEID_CLR       &H80000022
#define VTAG_USERCLIP_GET       &H80000023
#define VTAG_USERCLIP_SET       &H80000024
#define VTAG_USERCLIP_CLR       &H80000025
/* The following tags are V39 specific. They will be ignored (returing error -3) by
    earlier versions */
#define VTAG_PF1_BASE_GET       &H80000026
#define VTAG_PF2_BASE_GET       &H80000027
#define VTAG_SPEVEN_BASE_GET        &H80000028
#define VTAG_SPODD_BASE_GET     &H80000029
#define VTAG_PF1_BASE_SET       &H8000002a
#define VTAG_PF2_BASE_SET       &H8000002b
#define VTAG_SPEVEN_BASE_SET        &H8000002c
#define VTAG_SPODD_BASE_SET     &H8000002d
#define VTAG_BORDERSPRITE_GET       &H8000002e
#define VTAG_BORDERSPRITE_SET       &H8000002f
#define VTAG_BORDERSPRITE_CLR       &H80000030
#define VTAG_SPRITERESN_SET     &H80000031
#define VTAG_SPRITERESN_GET     &H80000032
#define VTAG_PF1_TO_SPRITEPRI_SET   &H80000033
#define VTAG_PF1_TO_SPRITEPRI_GET   &H80000034
#define VTAG_PF2_TO_SPRITEPRI_SET   &H80000035
#define VTAG_PF2_TO_SPRITEPRI_GET   &H80000036
#define VTAG_IMMEDIATE          &H80000037
#define VTAG_FULLPALETTE_SET        &H80000038
#define VTAG_FULLPALETTE_GET        &H80000039
#define VTAG_FULLPALETTE_CLR        &H8000003A
#define VTAG_DEFSPRITERESN_SET      &H8000003B
#define VTAG_DEFSPRITERESN_GET      &H8000003C

/* all the following tags follow the new,  rational standard for videocontrol tags:
 * VC_xxx, state     set the state of attribute 'xxx' to value 'state'
 * VC_xxx_QUERY, &var    get the state of attribute 'xxx' and store it into the longword
 *          pointed to by &var.
 *
 * The following are new for V40:
 */

#define VC_IntermediateCLUpdate     &H80000080
    /* default=true. When set graphics will update the intermediate copper
     * lists on color changes,  etc. When false,  it won't,  and will be faster.
     */
#define VC_IntermediateCLUpdate_Query   &H80000081

#define VC_NoColorPaletteLoad       &H80000082
    /* default = false. When set,  graphics will only load color 0
     * for this ViewPort,  and so the ViewPort's colors will come
     * from the previous ViewPort's.
     *
     * NB - Using this tag and VTAG_FULLPALETTE_SET together is undefined.
     */
#define VC_NoColorPaletteLoad_Query &H80000083

#define VC_DUALPF_Disable       &H80000084
    /* default = false. When this flag is set,  the dual-pf bit
       in Dual-Playfield screens will be turned off. Even bitplanes
       will still come from the first BitMap and odd bitplanes
       from the second BitMap,  and both R[xy]Offsets will be
       considered. This can be used (with appropriate palette
       selection) _for cross-fades between differently scrolling
       images.
       When this flag is turned on,  colors will be loaded for
       the viewport as if it were a single viewport of depth
       depth1+depth2 */
#define VC_DUALPF_Disable_Query     &H80000085


#endif  /* GRAPHICS_VIDEOCONTROL_H */
