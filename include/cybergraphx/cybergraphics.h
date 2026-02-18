#ifndef CYBERGRAPHX_CYBERGRAPHICS_H
#define CYBERGRAPHX_CYBERGRAPHICS_H 1
/*
** cybergraphics.h for ACE Basic
**
** CyberGraphX / cybergraphics.library constants and tags.
** Works with both native CyberGraphX and Picasso96's
** CyberGraphX compatibility layer.
**
** Translated from the CGraphX-DevKit v41.18 header
** by the ACE project, 2026.
*/

#define CYBERGFXNAME "cybergraphics.library"
#define CYBERGFX_INCLUDE_VERSION 41

/*
 * Parameters for GetCyberMapAttr()
 */
#define CYBRMATTR_XMOD        &H80000001  /* BytesPerRow */
#define CYBRMATTR_BPPIX       &H80000002  /* BytesPerPixel */
#define CYBRMATTR_PIXFMT      &H80000004  /* pixel format */
#define CYBRMATTR_WIDTH       &H80000005  /* width in pixels */
#define CYBRMATTR_HEIGHT      &H80000006  /* height in lines */
#define CYBRMATTR_DEPTH       &H80000007  /* bits per pixel */
#define CYBRMATTR_ISCYBERGFX  &H80000008  /* -1 if cybergfx bitmap */
#define CYBRMATTR_ISLINEARMEM &H80000009  /* -1 if linear accessible */

/*
 * Parameters for GetCyberIDAttr()
 */
#define CYBRIDATTR_PIXFMT &H80000001  /* pixel format */
#define CYBRIDATTR_WIDTH  &H80000002  /* visible width */
#define CYBRIDATTR_HEIGHT &H80000003  /* visible height */
#define CYBRIDATTR_DEPTH  &H80000004  /* bits per pixel */
#define CYBRIDATTR_BPPIX  &H80000005  /* BytesPerPixel */

/*
 * Tags for BestCModeIDTagList() / BestCModeID()
 */
#define CYBRBIDTG_TB            (TAG_USER+&H50000)
#define CYBRBIDTG_Depth         CYBRBIDTG_TB+0
#define CYBRBIDTG_NominalWidth  CYBRBIDTG_TB+1
#define CYBRBIDTG_NominalHeight CYBRBIDTG_TB+2
#define CYBRBIDTG_MonitorID     CYBRBIDTG_TB+3
#define CYBRBIDTG_BoardName     CYBRBIDTG_TB+5

/*
 * Tags for CModeRequestTagList()
 */
#define CYBRMREQ_TB          (TAG_USER+&H40000)
#define CYBRMREQ_MinDepth    CYBRMREQ_TB+0
#define CYBRMREQ_MaxDepth    CYBRMREQ_TB+1
#define CYBRMREQ_MinWidth    CYBRMREQ_TB+2
#define CYBRMREQ_MaxWidth    CYBRMREQ_TB+3
#define CYBRMREQ_MinHeight   CYBRMREQ_TB+4
#define CYBRMREQ_MaxHeight   CYBRMREQ_TB+5
#define CYBRMREQ_CModelArray CYBRMREQ_TB+6
#define CYBRMREQ_WinTitle    CYBRMREQ_TB+20
#define CYBRMREQ_OKText      CYBRMREQ_TB+21
#define CYBRMREQ_CancelText  CYBRMREQ_TB+22
#define CYBRMREQ_Screen      CYBRMREQ_TB+30

/*
 * Pixel formats (PIXFMT_xxx)
 */
#define PIXFMT_LUT8    0
#define PIXFMT_RGB15   1
#define PIXFMT_BGR15   2
#define PIXFMT_RGB15PC 3
#define PIXFMT_BGR15PC 4
#define PIXFMT_RGB16   5
#define PIXFMT_BGR16   6
#define PIXFMT_RGB16PC 7
#define PIXFMT_BGR16PC 8
#define PIXFMT_RGB24   9
#define PIXFMT_BGR24   10
#define PIXFMT_ARGB32  11
#define PIXFMT_BGRA32  12
#define PIXFMT_RGBA32  13

/*
 * Rectangle formats for xxxPixelArray() calls
 */
#define RECTFMT_RGB   0
#define RECTFMT_RGBA  1
#define RECTFMT_ARGB  2
#define RECTFMT_LUT8  3
#define RECTFMT_GREY8 4

/*
 * Tags for LockBitMapTagList()
 */
#define LBMI_WIDTH       &H84001001
#define LBMI_HEIGHT      &H84001002
#define LBMI_DEPTH       &H84001003
#define LBMI_PIXFMT      &H84001004
#define LBMI_BYTESPERPIX &H84001005
#define LBMI_BYTESPERROW &H84001006
#define LBMI_BASEADDRESS &H84001007

/*
 * Tags for UnLockBitMapTagList()
 */
#define UBMI_UPDATERECTS  &H85001001
#define UBMI_REALLYUNLOCK &H85001002

/*
 * Parameters for CVideoCtrlTagList()
 */
#define SETVC_DPMSLevel &H88002001

#define DPMS_ON      0  /* Full operation */
#define DPMS_STANDBY 1  /* Minimal power reduction */
#define DPMS_SUSPEND 2  /* Significant power reduction */
#define DPMS_OFF     3  /* Lowest power consumption */

/*
 * Colour Table source formats for WriteLUTPixelArray()
 */
#define CTABFMT_XRGB8 0  /* ULONG [] table */

/*
 * graphics.library/AllocBitMap() extended flags
 */
#define BMB_SPECIALFMT 7
#define BMF_SPECIALFMT 128


#endif /* CYBERGRAPHX_CYBERGRAPHICS_H */
