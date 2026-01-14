#ifndef GRAPHICS_GFXBASE_H
#define GRAPHICS_GFXBASE_H 1
/*
** gfxbase.h for ACE Basic
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
** This are the StructPointer defines for gfxbase.h
*/
#ifndef GfxBasePtr
#define GfxBasePtr ADDRESS
#endif
/*
** End of StructPointer defines for gfxbase.h
*/
      
#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif
#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#ifndef EXEC_INTERRUPTS_H
#include <exec/interrupts.h>
#endif
#ifndef GRAPHICS_MONITOR_H
#include <graphics/monitor.h>
#endif
#ifndef HARDWARE_BLIT_H
#include <hardware/blit.h>
#endif

STRUCT GfxBase
 
    _Library LibNode 
    ViewPtr  ActiView 
    copinitPtr  copinit    /* ptr to copper start up list */
    ADDRESS   cia            /* for 8520 resource use */
    ADDRESS   blitter        /* for future blitter resource use */
    ADDRESS   LOFlist 
    ADDRESS   SHFlist 
    bltnodePtr  blthd 
    bltnodePtr  blttl 
    bltnodePtr  bsblthd 
    bltnodePtr  bsblttl 
    Interrupt vbsrv 
    Interrupt timsrv 
    Interrupt bltsrv 
    _List TextFonts 
    TextFontPtr  DefaultFont 
    SHORTINT   Modes           /* copy of current first bplcon0 */
    BYTE    VBlank 
    BYTE    Debug 
    SHORTINT    BeamSync 
    SHORTINT    system_bplcon0      /* it is ored into each bplcon0 for display */
    BYTE    SpriteReserved 
    BYTE    bytereserved 
    SHORTINT   Flags 
    SHORTINT    BlitLock 
    SHORTINT    BlitNest 

    _List BlitWaitQ 
    TaskPtr  BlitOwner 
    _List TOF_WaitQ 
    SHORTINT   DisplayFlags        /* NTSC PAL GENLOC etc*/
                    /* flags initialized at power on */
    ADDRESS   SimpleSprites 
    SHORTINT   MaxDisplayRow       /* hardware stuff,  do not use */
    SHORTINT   MaxDisplayColumn    /* hardware stuff,  do not use */
    SHORTINT   NormalDisplayRows 
    SHORTINT   NormalDisplayColumns 
    /* the following are for standard non interlace,  1/2 wb width */
    SHORTINT   NormalDPMX      /* Dots per meter on display */
    SHORTINT   NormalDPMY      /* Dots per meter on display */
    SignalSemaphorePtr  LastChanceMemory 
    ADDRESS   LCMptr 
    SHORTINT   MicrosPerLine       /* 256 time usec/line */
    SHORTINT   MinDisplayColumn 
    BYTE    ChipRevBits0 
    BYTE    MemType 
    STRING crb_reserved SIZE 4  
    SHORTINT   monitor_id 
    STRING hedley SIZE 32  /* 8*SIZEOF(LONGINT) */
    STRING hedley_sprites SIZE 32  /* 8*SIZEOF(LONGINT) */  /* sprite ptrs FOR intuition MOUSE */
    STRING hedley_sprites1 SIZE 32 /* 8*SIZEOF(LONGINT) */ /* sprite ptrs FOR intuition MOUSE */
    SHORTINT    hedley_count 
    SHORTINT   hedley_flags 
    SHORTINT    hedley_tmp 
    ADDRESS   hash_table 
    SHORTINT   current_tot_rows 
    SHORTINT   current_tot_cclks 
    BYTE    hedley_hint 
    BYTE    hedley_hint2 
    STRING nreserved SIZE 16  /* 4*SIZEOF(LONGINT) */
    ADDRESS   a2024_sync_raster 
    SHORTINT   control_delta_pal 
    SHORTINT   control_delta_ntsc 
    MonitorSpecPtr  current_monitor 
    _List MonitorList 
    MonitorSpecPtr  default_monitor 
    SignalSemaphorePtr  MonitorListSemaphore 
    ADDRESS   DisplayInfoDataBase 
    SHORTINT   TopLine 
    SignalSemaphorePtr  ActiViewCprSemaphore 
    ADDRESS   UtilBase       /* for hook and tag utilities. had to change because of name clash  */
    ADDRESS   ExecBase       /* to link with rom.lib */
    ADDRESS   bwshifts 
    ADDRESS   StrtFetchMasks 
    ADDRESS   StopFetchMasks 
    ADDRESS   Overrun 
    ADDRESS   RealStops 
    SHORTINT   SpriteWidth     /* current width (in words) of sprites */
    SHORTINT   SpriteFMode         /* current sprite fmode bits    */
    BYTE    SoftSprites     /* bit mask of size change knowledgeable sprites */
    BYTE    arraywidth 
    SHORTINT   DefaultSpriteWidth  /* what width intuition wants */
    BYTE    SprMoveDisable 
    BYTE    WantChips 
    BYTE    BoardMemType 
    BYTE    Bugs 
    ADDRESS   gb_LayersBase 
    LONGINT   ColorMask 
    ADDRESS    IVector 
    ADDRESS    IData 
    LONGINT   SpecialCounter      /* special for double buffering */
    ADDRESS    DBList 
    SHORTINT   MonitorFlags 
    BYTE    ScanDoubledSprites 
    BYTE    BP3Bits 
    AnalogSignalInterval MonitorVBlank 
    MonitorSpecPtr  natural_monitor 
    ADDRESS    ProgData 
    BYTE    ExtSprites 
    BYTE    pad3 
    SHORTINT   GfxFlags 
    LONGINT   VBCounter 
    SignalSemaphorePtr  HashTableSemaphore 
    STRING HWEmul SIZE 36   /*  9*SIZEOF(LONGINT)  */
END STRUCT 

/*
#define ChunkyToPlanarPtr HWEmul[0] ???????
*/





/* Values for GfxBase->DisplayFlags */
#define NTSC        1
#define GENLOC      2
#define PAL     4
#define TODA_SAFE   8
#define REALLY_PAL  16  /* what is actual crystal frequency
                 (as opposed to what bootmenu set the agnus to)?
                 (V39) */
#define LPEN_SWAP_FRAMES    32
                /* LightPen software could set this bit if the
                 * "lpen-with-interlace" fix put in for V39
                 * does not work. This is true of a number of
                 * Agnus chips.
                 * (V40).
                 */

#define BLITMSG_FAULT   4

/* bits defs for ChipRevBits */
#define GFXB_BIG_BLITS  0
#define GFXB_HR_AGNUS   0
#define GFXB_HR_DENISE  1
#define GFXB_AA_ALICE   2
#define GFXB_AA_LISA    3
#define GFXB_AA_MLISA   4   /* internal use only. */

#define GFXF_BIG_BLITS  1
#define GFXF_HR_AGNUS   1
#define GFXF_HR_DENISE  2
#define GFXF_AA_ALICE   4
#define GFXF_AA_LISA    8
#define GFXF_AA_MLISA   16  /* internal use only */

/* Pass ONE of these to SetChipRev() */
#define SETCHIPREV_A    GFXF_HR_AGNUS
#define SETCHIPREV_ECS  (GFXF_HR_AGNUS OR GFXF_HR_DENISE)
#define SETCHIPREV_AA   (GFXF_AA_ALICE OR GFXF_AA_LISA OR SETCHIPREV_ECS)
#define SETCHIPREV_BEST &Hffffffff

/* memory type */
#define BUS_16      0
#define NML_CAS     0
#define BUS_32      1
#define DBL_CAS     2
#define BANDWIDTH_1X    (BUS_16 OR NML_CAS)
#define BANDWIDTH_2XNML BUS_32
#define BANDWIDTH_2XDBL DBL_CAS
#define BANDWIDTH_4X    (BUS_32 OR DBL_CAS)

/* GfxFlags (private) */
#define NEW_DATABASE    1

#define GRAPHICSNAME    "graphics.library"

#endif  /* GRAPHICS_GFXBASE_H */
