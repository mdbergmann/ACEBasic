#ifndef GRAPHICS_VIEW_H
#define GRAPHICS_VIEW_H 1
/*
** view.h for ACE Basic
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
** This are the StructPointer defines for view.h
*/
#ifndef ColorMapPtr
#define ColorMapPtr ADDRESS
#endif
#ifndef DBufInfoPtr
#define DBufInfoPtr ADDRESS
#endif
#ifndef PaletteExtraPtr
#define PaletteExtraPtr ADDRESS
#endif
#ifndef RasInfoPtr
#define RasInfoPtr ADDRESS
#endif
#ifndef ViewPtr
#define ViewPtr ADDRESS
#endif
#ifndef ViewExtraPtr
#define ViewExtraPtr ADDRESS
#endif
#ifndef ViewPortPtr
#define ViewPortPtr ADDRESS
#endif
#ifndef ViewPortExtraPtr
#define ViewPortExtraPtr ADDRESS
#endif
/*
** End of StructPointer defines for view.h
*/


#define ECS_SPECIFIC

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_SEMAPHORES_H
#include <exec/semaphores.h>
#endif

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif

#ifndef GRAPHICS_COPPER_H
#include <graphics/copper.h>
#endif

#ifndef GRAPHICS_GFXNODES_H
#include <graphics/gfxnodes.h>
#endif

#ifndef GRAPHICS_MONITOR_H
#include <graphics/monitor.h>
#endif

#ifndef GRAPHICS_DISPLAYINFO_H
#include <graphics/displayinfo.h>
#endif

#ifndef HARDWARE_CUSTOM_H
#include <hardware/custom.h>
#endif

STRUCT ViewPort
 
    ViewPortPtr  _Next 
    ColorMapPtr  ColorMap  /* table of colors for this viewport */
                    /* if this is nil,  MakeVPort assumes default values */
    CopListPtr  DspIns    /* used by MakeVPort() */
    CopListPtr  SprIns    /* used by sprite stuff */
    CopListPtr  ClrIns    /* used by sprite stuff */
    UCopListPtr  UCopIns   /* User copper list */
    SHORTINT    DWidth 
    SHORTINT  DHeight 
    SHORTINT    DxOffset 
    SHORTINT  DyOffset 
    SHORTINT   Modes 
    BYTE    SpritePriorities 
    BYTE    ExtendedModes 
    RasInfoPtr  RasInfo 
END STRUCT 

STRUCT View
 
    ViewPortPtr  ViewPort 
    cprlistPtr  LOFCprList    /* used for interlaced and noninterlaced */
    cprlistPtr  SHFCprList    /* only used during interlace */
    SHORTINT    DyOffset 
    SHORTINT  DxOffset    /* for complete View positioning */
                   /* offsets are +- adjustments to standard #s */
    SHORTINT   Modes          /* such as INTERLACE,  GENLOC */
END STRUCT 

/* these structures are obtained via GfxNew */
/* and disposed by GfxFree */
STRUCT ViewExtra
 
    ExtendedNode n 
    ViewPtr  View       /* backwards link */
    MonitorSpecPtr  Monitor     /* monitors for this view */
    SHORTINT TopLine 
END STRUCT 

/* this structure is obtained via GfxNew */
/* and disposed by GfxFree */
STRUCT ViewPortExtra
 
    ExtendedNode n 
    ViewPortPtr  ViewPort   /* backwards link */
    Rectangle DisplayClip    /* MakeVPort display clipping information */
    /* These are added for V39 */
    ADDRESS   VecTable         /* Private */
    STRING DriverData SIZE 8  /*  2*SIZEOF(ADDRESS) */
    SHORTINT  Flags 
    STRING Origin SIZE 8          /* First visible POINT relative TO the DClip.
                     * One for each possible playfield.
                     */
    LONGINT cop1ptr           /* private */
    LONGINT cop2ptr           /* private */
END STRUCT 

/* All these VPXF_ flags are private */
#define VPXB_FREE_ME        0
#define VPXF_FREE_ME        (1)
#define VPXB_LAST       1
#define VPXF_LAST       (2)
#define VPXB_STRADDLES_256  4
#define VPXF_STRADDLES_256  (16)
#define VPXB_STRADDLES_512  5
#define VPXF_STRADDLES_512  (32)


#define EXTEND_VSTRUCT  &H1000  /* unused bit in Modes field of View */

#define VPF_A2024         &H40  /* VP?_ fields internal only */
#define VPF_TENHZ         &H20
#define VPB_A2024         6
#define VPB_TENHZ         4

/* defines used for Modes in IVPargs */

#define GENLOCK_VIDEO   &H0002
#define LACE        &H0004
#define DOUBLESCAN  &H0008
#define SUPERHIRES  &H0020
#define PFBA        &H0040
#define EXTRA_HALFBRITE &H0080
#define GENLOCK_AUDIO   &H0100
#define DUALPF      &H0400
#define HAM     &H0800
#define EXTENDED_MODE   &H1000
#define VP_HIDE &H2000
#define SPRITES &H4000
#define HIRES       &H8000

STRUCT RasInfo  /* used by callers to and InitDspC() */
 
   RasInfoPtr  _Next       /* used for dualpf */
   BitMapPtr  BitMap 
   SHORTINT    RxOffset 
   SHORTINT  RyOffset       /* scroll offsets in this BitMap */
END STRUCT 

STRUCT ColorMap
 
    BYTE    Flags 
    BYTE    _Type 
    SHORTINT   Count 
    ADDRESS    ColorTable 
    ViewPortExtraPtr  cm_vpe 
    ADDRESS    LowColorBits 
    BYTE    TransparencyPlane 
    BYTE    SpriteResolution 
    BYTE    SpriteResDefault    /* what resolution you get when you have set SPRITERESN_DEFAULT */
    BYTE    AuxFlags 
    ViewPortPtr  cm_vp 
    ADDRESS    NormalDisplayInfo 
    ADDRESS    CoerceDisplayInfo 
    TagItemPtr  cm_batch_items 
    LONGINT   VPModeID 
    PaletteExtraPtr  PalExtra 
    SHORTINT   SpriteBase_Even 
    SHORTINT   SpriteBase_Odd 
    SHORTINT   Bp_0_base 
    SHORTINT   Bp_1_base 

END STRUCT 

/* if Type == 0 then ColorMap is V1.2/V1.3 compatible */
/* if Type != 0 then ColorMap is V38       compatible */
/* the system will never create other than V39 type colormaps when running V39 */

#define COLORMAP_TYPE_V1_2  &H00
#define COLORMAP_TYPE_V1_4  &H01
#define COLORMAP_TYPE_V36 COLORMAP_TYPE_V1_4    /* use this definition */
#define COLORMAP_TYPE_V39   &H02

/* Flags variable */
#define COLORMAP_TRANSPARENCY   &H01
#define COLORPLANE_TRANSPARENCY &H02
#define BORDER_BLANKING     &H04
#define BORDER_NOTRANSPARENCY   &H08
#define VIDEOCONTROL_BATCH  &H10
#define USER_COPPER_CLIP    &H20
#define BORDERSPRITES   &H40

#define CMF_CMTRANS 0
#define CMF_CPTRANS 1
#define CMF_BRDRBLNK    2
#define CMF_BRDNTRAN    3
#define CMF_BRDRSPRT    6

#define SPRITERESN_ECS      0
/* ^140ns,  except in 35ns viewport,  where it is 70ns. */
#define SPRITERESN_140NS    1
#define SPRITERESN_70NS     2
#define SPRITERESN_35NS     3
#define SPRITERESN_DEFAULT  -1

/* AuxFlags : */
#define CMAB_FULLPALETTE 0
#define CMAF_FULLPALETTE (1)
#define CMAB_NO_INTERMED_UPDATE 1
#define CMAF_NO_INTERMED_UPDATE (2)
#define CMAB_NO_COLOR_LOAD 2
#define CMAF_NO_COLOR_LOAD (4)
#define CMAB_DUALPF_DISABLE 3
#define CMAF_DUALPF_DISABLE (8)


STRUCT PaletteExtra             /* structure may be extended so watch out! */
 
    SignalSemaphore pe_Semaphore         /* shared semaphore for arbitration */
    SHORTINT   pe_FirstFree                /* *private*                */
    SHORTINT   pe_NFree                /* number of free colors        */
    SHORTINT   pe_FirstShared              /* *private*                */
    SHORTINT   pe_NShared              /* *private*                */
    ADDRESS   pe_RefCnt              /* *private*                */
    ADDRESS   pe_AllocList               /* *private*                */
    ViewPortPtr  pe_ViewPort            /* back pointer to viewport     */
    SHORTINT   pe_SharableColors           /* the number of sharable colors.   */
END STRUCT 

/* flags values for ObtainPen */

#define PENB_EXCLUSIVE 0
#define PENB_NO_SETCOLOR 1

#define PENF_EXCLUSIVE (2&)
#define PENF_NO_SETCOLOR (2)

/* obsolete names for PENF_xxx flags: */

#define PEN_EXCLUSIVE PENF_EXCLUSIVE
#define PEN_NO_SETCOLOR PENF_NO_SETCOLOR

/* precision values for ObtainBestPen : */

#define PRECISION_EXACT -1
#define PRECISION_IMAGE 0
#define PRECISION_ICON  16
#define PRECISION_GUI   32


/* tags for ObtainBestPen: */
#define OBP_Precision &H84000000
#define OBP_FailIfBad &H84000001

/* From V39,  MakeVPort() will return an error if there is not enough memory, 
 * or the requested mode cannot be opened with the requested depth with the
 * given bitmap (for higher bandwidth alignments).
 */

#define MVP_OK      0   /* you want to see this one */
#define MVP_NO_MEM  1   /* insufficient memory for intermediate workspace */
#define MVP_NO_VPE  2   /* ViewPort does not have a ViewPortExtra,  and
                 * insufficient memory to allocate a temporary one.
                 */
#define MVP_NO_DSPINS   3   /* insufficient memory for intermidiate copper
                 * instructions.
                 */
#define MVP_NO_DISPLAY  4   /* BitMap data is misaligned for this viewport's
                 * mode and depth - see AllocBitMap().
                 */
#define MVP_OFF_BOTTOM  5   /* PRIVATE - you will never see this. */

/* From V39,  MrgCop() will return an error if there is not enough memory, 
 * or for some reason MrgCop() did not need to make any copper lists.
 */

#define MCOP_OK     0   /* you want to see this one */
#define MCOP_NO_MEM 1   /* insufficient memory to allocate the system
                 * copper lists.
                 */
#define MCOP_NOP    2   /* MrgCop() did not merge any copper lists
                 * (eg,  no ViewPorts in the list,  or all marked as
                 * hidden).
                 */

STRUCT DBufInfo  
    ADDRESS    dbi_Link1 
    LONGINT   dbi_Count1 
    _Message dbi_SafeMessage      /* replied to when safe to write to old bitmap */
    ADDRESS dbi_UserData1          /* first user data */

    ADDRESS    dbi_Link2 
    LONGINT   dbi_Count2 
    _Message dbi_DispMessage  /* replied to when new bitmap has been displayed at least
                            once */
    ADDRESS    dbi_UserData2           /* second user data */
    LONGINT   dbi_MatchLong 
    ADDRESS    dbi_CopPtr1 
    ADDRESS    dbi_CopPtr2 
    ADDRESS    dbi_CopPtr3 
    SHORTINT   dbi_BeamPos1 
    SHORTINT   dbi_BeamPos2 
END STRUCT 

#endif  /* GRAPHICS_VIEW_H */
