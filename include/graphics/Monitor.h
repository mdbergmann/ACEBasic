#ifndef GRAPHICS_MONITOR_H
#define GRAPHICS_MONITOR_H 1
/*
** monitor.h for ACE Basic
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
** This are the StructPointer defines for monitor.h
*/
#ifndef AnalogSignalIntervalPtr
#define AnalogSignalIntervalPtr ADDRESS
#endif
#ifndef MonitorSpecPtr
#define MonitorSpecPtr ADDRESS
#endif
#ifndef SpecialMonitorPtr
#define SpecialMonitorPtr ADDRESS
#endif
/*
** End of StructPointer defines for monitor.h
*/
      
#ifndef EXEC_SEMAPHORES_H
#include    <exec/semaphores.h>
#endif

#ifndef GRAPHICS_GFXNODES_H
#include    <graphics/gfxnodes.h>
#endif

#ifndef GRAPHICS_GFX_H
#include    <graphics/gfx.h>
#endif


STRUCT  MonitorSpec
 
    ExtendedNode ms_Node 
    SHORTINT   ms_Flags 
    LONGINT    ratioh 
    LONGINT    ratiov 
    SHORTINT   total_rows 
    SHORTINT   total_colorclocks 
    SHORTINT   DeniseMaxDisplayColumn 
    SHORTINT   BeamCon0 
    SHORTINT   min_row 
    SpecialMonitorPtr  ms_Special 
    SHORTINT   ms_OpenCount 
    ADDRESS   ms_transform 
    ADDRESS   ms_translate 
    ADDRESS   ms_scale 
    SHORTINT   ms_xoffset 
    SHORTINT   ms_yoffset 
    Rectangle ms_LegalView 
    ADDRESS   ms_maxoscan    /* maximum legal overscan */
    ADDRESS   ms_videoscan   /* video display overscan */
    SHORTINT   DeniseMinDisplayColumn 
    LONGINT   DisplayCompatible 
    _List DisplayInfoDataBase 
    SignalSemaphore DisplayInfoDataBaseSemaphore 
    ADDRESS   ms_MrgCop 
    ADDRESS   ms_LoadView 
    ADDRESS   ms_KillView 
END STRUCT 

#define TO_MONITOR      0
#define FROM_MONITOR        1
#define STANDARD_XOFFSET    9
#define STANDARD_YOFFSET    0

#define MSB_REQUEST_NTSC    0
#define MSB_REQUEST_PAL     1
#define MSB_REQUEST_SPECIAL 2
#define MSB_REQUEST_A2024   3
#define MSB_DOUBLE_SPRITES  4
#define MSF_REQUEST_NTSC    (1)
#define MSF_REQUEST_PAL     (2)
#define MSF_REQUEST_SPECIAL     (4)
#define MSF_REQUEST_A2024       (8)
#define MSF_DOUBLE_SPRITES      (16)


/* obsolete,  v37 compatible definitions follow */
#define REQUEST_NTSC        (1)
#define REQUEST_PAL     (2)
#define REQUEST_SPECIAL     (4)
#define REQUEST_A2024       (8)

#define DEFAULT_MONITOR_NAME    "default.monitor"
#define NTSC_MONITOR_NAME   "ntsc.monitor"
#define PAL_MONITOR_NAME    "pal.monitor"
#define STANDARD_MONITOR_MASK   ( REQUEST_NTSC OR REQUEST_PAL )

#define STANDARD_NTSC_ROWS  262
#define STANDARD_PAL_ROWS   312
#define STANDARD_COLORCLOCKS    226
#define STANDARD_DENISE_MAX 455
#define STANDARD_DENISE_MIN 93
#define STANDARD_NTSC_BEAMCON   ( &H0000 )
#define STANDARD_PAL_BEAMCON    ( DISPLAYPAL )

#define SPECIAL_BEAMCON ( VARVBLANK OR LOLDIS OR VARVSYNC OR VARHSYNC OR VARBEAM OR CSBLANK OR VSYNCTRUE)

#define MIN_NTSC_ROW    21
#define MIN_PAL_ROW 29
#define STANDARD_VIEW_X &H81
#define STANDARD_VIEW_Y &H2C
#define STANDARD_HBSTRT &H06
#define STANDARD_HSSTRT &H0B
#define STANDARD_HSSTOP &H1C
#define STANDARD_HBSTOP &H2C
#define STANDARD_VBSTRT &H0122
#define STANDARD_VSSTRT &H02A6
#define STANDARD_VSSTOP &H03AA
#define STANDARD_VBSTOP &H1066

#define VGA_COLORCLOCKS (STANDARD_COLORCLOCKS/2)
#define VGA_TOTAL_ROWS  (STANDARD_NTSC_ROWS*2)
#define VGA_DENISE_MIN  59
#define MIN_VGA_ROW 29
#define VGA_HBSTRT  &H08
#define VGA_HSSTRT  &H0E
#define VGA_HSSTOP  &H1C
#define VGA_HBSTOP  &H1E
#define VGA_VBSTRT  &H0000
#define VGA_VSSTRT  &H0153
#define VGA_VSSTOP  &H0235
#define VGA_VBSTOP  &H0CCD

#define VGA_MONITOR_NAME    "vga.monitor"

/* NOTE: VGA70 definitions are obsolete - a VGA70 monitor has never been
 * implemented.
 */
#define VGA70_COLORCLOCKS (STANDARD_COLORCLOCKS/2)
#define VGA70_TOTAL_ROWS 449
#define VGA70_DENISE_MIN 59
#define MIN_VGA70_ROW   35
#define VGA70_HBSTRT    &H08
#define VGA70_HSSTRT    &H0E
#define VGA70_HSSTOP    &H1C
#define VGA70_HBSTOP    &H1E
#define VGA70_VBSTRT    &H0000
#define VGA70_VSSTRT    &H02A6
#define VGA70_VSSTOP    &H0388
#define VGA70_VBSTOP    &H0F73

#define VGA70_BEAMCON   (SPECIAL_BEAMCON ^ VSYNCTRUE)
#define VGA70_MONITOR_NAME  "vga70.monitor"

#define BROADCAST_HBSTRT    &H01
#define BROADCAST_HSSTRT    &H06
#define BROADCAST_HSSTOP    &H17
#define BROADCAST_HBSTOP    &H27
#define BROADCAST_VBSTRT    &H0000
#define BROADCAST_VSSTRT    &H02A6
#define BROADCAST_VSSTOP    &H054C
#define BROADCAST_VBSTOP    &H1C40
#define BROADCAST_BEAMCON   ( LOLDIS OR CSBLANK )
#define RATIO_FIXEDPART 4
#define RATIO_UNITY (16)

STRUCT  AnalogSignalInterval
 
    SHORTINT   asi_Start 
    SHORTINT   asi_Stop 
END STRUCT 

STRUCT  SpecialMonitor
 
    ExtendedNode spm_Node 
    SHORTINT   spm_Flags 
    ADDRESS   do_monitor 
    ADDRESS   reserved1 
    ADDRESS   reserved2 
    ADDRESS   reserved3
    AnalogSignalInterval hblank 
    AnalogSignalInterval vblank 
    AnalogSignalInterval hsync 
    AnalogSignalInterval vsync 
END STRUCT 

#endif  /* GRAPHICS_MONITOR_H */
