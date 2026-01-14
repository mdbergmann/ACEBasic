#ifndef  FUNCS_GRAPHICS_FUNCS_H
#define  FUNCS_GRAPHICS_FUNCS_H

/*
**
** Function declarations for ACE Basic
**
** Note: Translated to ACE by Nils Sjoholm
**
** Date: 11-Oct-95 TO 14-Oct-95
**
*/              

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

/*------ BitMap primitives ------*/
DECLARE FUNCTION LONGINT BltBitMap( STRUCTPTR srcBitMap, LONGINT xSrc, LONGINT ySrc, \
                                    STRUCTPTR destBitMap, LONGINT xDest, LONGINT yDest, \
                                    LONGINT xSize, LONGINT ySize,  LONGINT minterm, \
                                     LONGINT mask, ADDRESS tempA ) LIBRARY graphics
DECLARE FUNCTION BltTemplate( ADDRESS source, LONGINT xSrc, LONGINT srcMod, \
                               STRUCTPTR destRP, LONGINT xDest, LONGINT yDest, LONGINT xSize, \
                               LONGINT ySize ) LIBRARY graphics
/*------ Text routines ------*/
DECLARE FUNCTION ClearEOL( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION ClearScreen( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION SHORTINT TextLength( STRUCTPTR rp, STRPTR _STRING,  LONGINT count ) LIBRARY graphics
DECLARE FUNCTION LONGINT Text( STRUCTPTR rp, STRPTR _STRING,  LONGINT count ) LIBRARY graphics
DECLARE FUNCTION LONGINT SetFont( STRUCTPTR rp, STRUCTPTR textFont ) LIBRARY graphics
DECLARE FUNCTION STRUCTPTR OpenFont( STRUCTPTR textAttr ) LIBRARY graphics
DECLARE FUNCTION CloseFont( STRUCTPTR textFont ) LIBRARY graphics
DECLARE FUNCTION LONGINT AskSoftStyle( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION LONGINT SetSoftStyle( STRUCTPTR rp,  LONGINT _STYLE, LONGINT enable ) LIBRARY graphics
/*------    Gels routines ------*/
DECLARE FUNCTION AddBob( STRUCTPTR bob, STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION AddVSprite( STRUCTPTR vSprite, STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION DoCollision( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION DrawGList( STRUCTPTR rp, STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION InitGels( STRUCTPTR head, STRUCTPTR tail, STRUCTPTR gelsInfo ) LIBRARY graphics
DECLARE FUNCTION InitMasks( STRUCTPTR vSprite ) LIBRARY graphics
DECLARE FUNCTION RemIBob( STRUCTPTR bob, STRUCTPTR rp, STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION RemVSprite( STRUCTPTR vSprite ) LIBRARY graphics
DECLARE FUNCTION SetCollision(  LONGINT num, ADDRESS routine, STRUCTPTR gelsInfo ) LIBRARY graphics
DECLARE FUNCTION SortGList( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION AddAnimOb( STRUCTPTR anOb, STRUCTPTR anKey, STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION Animate( STRUCTPTR anKey, STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION BOOL GetGBuffers( STRUCTPTR anOb, STRUCTPTR rp, LONGINT flag ) LIBRARY graphics
DECLARE FUNCTION InitGMasks( STRUCTPTR anOb ) LIBRARY graphics
/*------    General graphics routines ------*/
DECLARE FUNCTION DrawEllipse( STRUCTPTR rp, LONGINT xCenter, LONGINT yCenter, LONGINT a, \
                              LONGINT b ) LIBRARY graphics
DECLARE FUNCTION LONGINT AreaEllipse( STRUCTPTR rp, LONGINT xCenter, LONGINT yCenter, LONGINT a, \
                                      LONGINT b ) LIBRARY graphics
DECLARE FUNCTION LoadRGB4( STRUCTPTR vp, ADDRESS colors, LONGINT count ) LIBRARY graphics
DECLARE FUNCTION InitRastPort( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION InitVPort( STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION LONGINT MrgCop( STRUCTPTR view ) LIBRARY graphics
DECLARE FUNCTION LONGINT MakeVPort( STRUCTPTR view, STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION LoadView( STRUCTPTR view ) LIBRARY graphics
DECLARE FUNCTION WaitBlit() LIBRARY graphics
DECLARE FUNCTION SetRast( STRUCTPTR rp,  LONGINT pen ) LIBRARY graphics
DECLARE FUNCTION Move( STRUCTPTR rp, LONGINT x, LONGINT y ) LIBRARY graphics
DECLARE FUNCTION Draw( STRUCTPTR rp, LONGINT x, LONGINT y ) LIBRARY graphics
DECLARE FUNCTION LONGINT AreaMove( STRUCTPTR rp, LONGINT x, LONGINT y ) LIBRARY graphics
DECLARE FUNCTION LONGINT AreaDraw( STRUCTPTR rp, LONGINT x, LONGINT y ) LIBRARY graphics
DECLARE FUNCTION LONGINT AreaEnd( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION WaitTOF() LIBRARY graphics
DECLARE FUNCTION QBlit( STRUCTPTR blit ) LIBRARY graphics
DECLARE FUNCTION InitArea( STRUCTPTR areaInfo, APTR vectorBuffer, LONGINT maxVectors ) LIBRARY graphics
DECLARE FUNCTION SetRGB4( STRUCTPTR vp, LONGINT index,  LONGINT red, \
                          LONGINT green,  LONGINT blue ) LIBRARY graphics
DECLARE FUNCTION QBSBlit( STRUCTPTR blit ) LIBRARY graphics
DECLARE FUNCTION BltClear( ADDRESS memBlock,  LONGINT byteCount, LONGINT flags ) LIBRARY graphics
DECLARE FUNCTION RectFill( STRUCTPTR rp, LONGINT xMin, LONGINT yMin, LONGINT xMax, LONGINT yMax ) LIBRARY graphics
DECLARE FUNCTION BltPattern( STRUCTPTR rp, ADDRESS mask, LONGINT xMin, LONGINT yMin, \
                             LONGINT xMax, LONGINT yMax,  LONGINT maskBPR ) LIBRARY graphics
DECLARE FUNCTION LONGINT ReadPixel( STRUCTPTR rp, LONGINT x, LONGINT y ) LIBRARY graphics
DECLARE FUNCTION LONGINT WritePixel( STRUCTPTR rp, LONGINT x, LONGINT y ) LIBRARY graphics
DECLARE FUNCTION BOOL Flood( STRUCTPTR rp,  LONGINT mode, LONGINT x, LONGINT y ) LIBRARY graphics
DECLARE FUNCTION PolyDraw( STRUCTPTR rp, LONGINT count, ADDRESS polyTable ) LIBRARY graphics
DECLARE FUNCTION SetAPen( STRUCTPTR rp,  LONGINT pen ) LIBRARY graphics
DECLARE FUNCTION SetBPen( STRUCTPTR rp,  LONGINT pen ) LIBRARY graphics
DECLARE FUNCTION SetDrMd( STRUCTPTR rp,  LONGINT drawMode ) LIBRARY graphics
DECLARE FUNCTION InitView( STRUCTPTR view ) LIBRARY graphics
DECLARE FUNCTION CBump( STRUCTPTR copList ) LIBRARY graphics
DECLARE FUNCTION CMove( STRUCTPTR copList, APTR destination, LONGINT _DATA ) LIBRARY graphics
DECLARE FUNCTION CWait( STRUCTPTR copList, LONGINT v, LONGINT h ) LIBRARY graphics
DECLARE FUNCTION LONGINT VBeamPos() LIBRARY graphics
DECLARE FUNCTION InitBitMap( STRUCTPTR bitMap, LONGINT depth, LONGINT _WIDTH, LONGINT height ) LIBRARY graphics
DECLARE FUNCTION ScrollRaster( STRUCTPTR rp, LONGINT dx, LONGINT dy, LONGINT xMin, LONGINT yMin, \
                               LONGINT xMax, LONGINT yMax ) LIBRARY graphics
DECLARE FUNCTION WaitBOVP( STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION SHORTINT GetSprite( STRUCTPTR sprite, LONGINT num ) LIBRARY graphics
DECLARE FUNCTION FreeSprite( LONGINT num ) LIBRARY graphics
DECLARE FUNCTION ChangeSprite( STRUCTPTR vp, STRUCTPTR sprite, ADDRESS newData ) LIBRARY graphics
DECLARE FUNCTION MoveSprite( STRUCTPTR vp, STRUCTPTR sprite, LONGINT x, LONGINT y ) LIBRARY graphics
DECLARE FUNCTION LockLayerRom( STRUCTPTR layer ) LIBRARY graphics
DECLARE FUNCTION UnlockLayerRom( STRUCTPTR layer ) LIBRARY graphics
DECLARE FUNCTION SyncSBitMap( STRUCTPTR layer ) LIBRARY graphics
DECLARE FUNCTION CopySBitMap( STRUCTPTR layer ) LIBRARY graphics
DECLARE FUNCTION OwnBlitter() LIBRARY graphics
DECLARE FUNCTION DisownBlitter() LIBRARY graphics
DECLARE FUNCTION STRUCTPTR InitTmpRas( STRUCTPTR tmpRas, ADDRESS buffer, LONGINT _SIZE ) LIBRARY graphics
DECLARE FUNCTION AskFont( STRUCTPTR rp, STRUCTPTR textAttr ) LIBRARY graphics
DECLARE FUNCTION AddFont( STRUCTPTR textFont ) LIBRARY graphics
DECLARE FUNCTION RemFont( STRUCTPTR textFont ) LIBRARY graphics
DECLARE FUNCTION ADDRESS AllocRaster(  LONGINT _WIDTH,  LONGINT height ) LIBRARY graphics
DECLARE FUNCTION FreeRaster( ADDRESS p,  LONGINT _WIDTH,  LONGINT height ) LIBRARY graphics
DECLARE FUNCTION AndRectRegion( STRUCTPTR region, STRUCTPTR rectangle ) LIBRARY graphics
DECLARE FUNCTION BOOL OrRectRegion( STRUCTPTR region, STRUCTPTR rectangle ) LIBRARY graphics
DECLARE FUNCTION STRUCTPTR NewRegion() LIBRARY graphics
DECLARE FUNCTION BOOL ClearRectRegion( STRUCTPTR region, STRUCTPTR rectangle ) LIBRARY graphics
DECLARE FUNCTION ClearRegion( STRUCTPTR region ) LIBRARY graphics
DECLARE FUNCTION DisposeRegion( STRUCTPTR region ) LIBRARY graphics
DECLARE FUNCTION FreeVPortCopLists( STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION FreeCopList( STRUCTPTR copList ) LIBRARY graphics
DECLARE FUNCTION ClipBlit( STRUCTPTR srcRP, LONGINT xSrc, LONGINT ySrc, \
                           STRUCTPTR destRP, LONGINT xDest, LONGINT yDest, LONGINT xSize, \
                           LONGINT ySize,  LONGINT minterm ) LIBRARY graphics
DECLARE FUNCTION BOOL XorRectRegion( STRUCTPTR region, STRUCTPTR rectangle ) LIBRARY graphics
DECLARE FUNCTION FreeCprList( STRUCTPTR cprList ) LIBRARY graphics
DECLARE FUNCTION STRUCTPTR GetColorMap( LONGINT entries ) LIBRARY graphics
DECLARE FUNCTION FreeColorMap( STRUCTPTR colorMap ) LIBRARY graphics
DECLARE FUNCTION LONGINT GetRGB4( STRUCTPTR colorMap, LONGINT entry ) LIBRARY graphics
DECLARE FUNCTION ScrollVPort( STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION STRUCTPTR UCopperListInit( STRUCTPTR uCopList, LONGINT n ) LIBRARY graphics
DECLARE FUNCTION FreeGBuffers( STRUCTPTR anOb, STRUCTPTR rp, LONGINT flag ) LIBRARY graphics
DECLARE FUNCTION BltBitMapRastPort( STRUCTPTR srcBitMap, LONGINT xSrc, LONGINT ySrc, \
                                    STRUCTPTR destRP, LONGINT xDest, LONGINT yDest, LONGINT xSize, \
                                    LONGINT ySize,  LONGINT minterm ) LIBRARY graphics
DECLARE FUNCTION BOOL OrRegionRegion( STRUCTPTR srcRegion, STRUCTPTR destRegion ) LIBRARY graphics
DECLARE FUNCTION BOOL XorRegionRegion( STRUCTPTR srcRegion, STRUCTPTR destRegion ) LIBRARY graphics
DECLARE FUNCTION BOOL AndRegionRegion( STRUCTPTR srcRegion, STRUCTPTR destRegion ) LIBRARY graphics
DECLARE FUNCTION SetRGB4CM( STRUCTPTR colorMap, LONGINT index,  LONGINT red, \
                            LONGINT green,  LONGINT blue ) LIBRARY graphics
DECLARE FUNCTION BltMaskBitMapRastPort( STRUCTPTR srcBitMap, LONGINT xSrc, LONGINT ySrc, \
                                        STRUCTPTR destRP, LONGINT xDest, LONGINT yDest, LONGINT xSize, \
                                        LONGINT ySize,  LONGINT minterm, ADDRESS bltMask ) LIBRARY graphics
DECLARE FUNCTION BOOL AttemptLockLayerRom( STRUCTPTR layer ) LIBRARY graphics
/*--- functions in V36 OR higher (Release 2.0) ---*/
DECLARE FUNCTION APTR GfxNew(  LONGINT gfxNodeType ) LIBRARY graphics
DECLARE FUNCTION GfxFree( APTR gfxNodePtr ) LIBRARY graphics
DECLARE FUNCTION GfxAssociate( APTR associateNode, APTR gfxNodePtr ) LIBRARY graphics
DECLARE FUNCTION BitMapScale( STRUCTPTR bitScaleArgs ) LIBRARY graphics
DECLARE FUNCTION SHORTINT ScalerDiv(  LONGINT factor,  LONGINT numerator, LONGINT denominator ) LIBRARY graphics
DECLARE FUNCTION SHORTINT TextExtent( STRUCTPTR rp, STRPTR _STRING, LONGINT count, STRUCTPTR textExtent ) LIBRARY graphics
DECLARE FUNCTION LONGINT TextFit( STRUCTPTR rp, STRPTR _STRING,  LONGINT strLen, \
                                  STRUCTPTR textExtent, STRUCTPTR constrainingExtent, \
                                  LONGINT strDirection,  LONGINT constrainingBitWidth, \
                                  LONGINT constrainingBitHeight ) LIBRARY graphics
DECLARE FUNCTION APTR GfxLookUp( APTR associateNode ) LIBRARY graphics
DECLARE FUNCTION BOOL VideoControl( STRUCTPTR colorMap, STRUCTPTR tagarray ) LIBRARY graphics
DECLARE FUNCTION STRUCTPTR OpenMonitor( STRPTR monitorName,LONGINT displayID ) LIBRARY graphics
DECLARE FUNCTION BOOL CloseMonitor( STRUCTPTR monitorSpec ) LIBRARY graphics
DECLARE FUNCTION ADDRESS FindDisplayInfo(  LONGINT displayID ) LIBRARY graphics
DECLARE FUNCTION LONGINT NextDisplayInfo(  LONGINT displayID ) LIBRARY graphics
DECLARE FUNCTION LONGINT GetDisplayInfoData( ADDRESS _HANDLE, ADDRESS buf, \
                                             LONGINT _SIZE,  LONGINT tagID,  LONGINT displayID ) LIBRARY graphics
DECLARE FUNCTION FontExtent( STRUCTPTR _FONT, STRUCTPTR fontExtent ) LIBRARY graphics
DECLARE FUNCTION LONGINT ReadPixelLine8( STRUCTPTR rp,  LONGINT xstart, \
                                         LONGINT ystart,  LONGINT _WIDTH, ADDRESS array, \
                                         STRUCTPTR tempRP ) LIBRARY graphics
DECLARE FUNCTION LONGINT WritePixelLine8( STRUCTPTR rp,  LONGINT xstart, \
                                          LONGINT ystart,  LONGINT _WIDTH, ADDRESS array, \
                                          STRUCTPTR tempRP ) LIBRARY graphics
DECLARE FUNCTION LONGINT ReadPixelArray8( STRUCTPTR rp,  LONGINT xstart, \
                                          LONGINT ystart,  LONGINT xstop,  LONGINT ystop, \
                                          ADDRESS array, STRUCTPTR temprp ) LIBRARY graphics
DECLARE FUNCTION LONGINT WritePixelArray8( STRUCTPTR rp,  LONGINT xstart, \
                                           LONGINT ystart,  LONGINT xstop,  LONGINT ystop, \
                                           ADDRESS array, STRUCTPTR temprp ) LIBRARY graphics
DECLARE FUNCTION LONGINT GetVPModeID( STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION LONGINT ModeNotAvailable(  LONGINT modeID ) LIBRARY graphics
DECLARE FUNCTION SHORTINT WeighTAMatch( STRUCTPTR reqTextAttr, STRUCTPTR targetTextAttr, STRUCTPTR targetTags ) LIBRARY graphics
DECLARE FUNCTION EraseRect( STRUCTPTR rp, LONGINT xMin, LONGINT yMin, LONGINT xMax, \
                            LONGINT yMax ) LIBRARY graphics
DECLARE FUNCTION LONGINT ExtendFont( STRUCTPTR _FONT, STRUCTPTR fontTags ) LIBRARY graphics
DECLARE FUNCTION  StripFont( STRUCTPTR _FONT ) LIBRARY graphics
/*--- functions in V39 OR higher (Release 3) ---*/
DECLARE FUNCTION SHORTINT CalcIVG( STRUCTPTR v, STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION LONGINT AttachPalExtra( STRUCTPTR cm, STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION LONGINT ObtainBestPenA( STRUCTPTR cm,  LONGINT r,  LONGINT g,LONGINT b, STRUCTPTR tags ) LIBRARY graphics
DECLARE FUNCTION SetRGB32( STRUCTPTR vp,  LONGINT n,  LONGINT r, \
                           LONGINT g,  LONGINT b ) LIBRARY graphics
DECLARE FUNCTION LONGINT GetAPen( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION LONGINT GetBPen( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION LONGINT GetDrMd( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION LONGINT GetOutlinePen( STRUCTPTR rp ) LIBRARY graphics
DECLARE FUNCTION LoadRGB32( STRUCTPTR vp, ADDRESS table ) LIBRARY graphics
DECLARE FUNCTION LONGINT SetChipRev(  LONGINT want ) LIBRARY graphics
DECLARE FUNCTION  SetABPenDrMd( STRUCTPTR rp,  LONGINT apen,  LONGINT bpen, LONGINT drawmode ) LIBRARY graphics
DECLARE FUNCTION GetRGB32( STRUCTPTR cm,  LONGINT firstcolor, LONGINT ncolors, ADDRESS table ) LIBRARY graphics
DECLARE FUNCTION STRUCTPTR AllocBitMap(  LONGINT sizex,  LONGINT sizey, \
                                         LONGINT depth,  LONGINT flags, \
                                         STRUCTPTR friend_bitmap ) LIBRARY graphics
DECLARE FUNCTION FreeBitMap( STRUCTPTR bm ) LIBRARY graphics
DECLARE FUNCTION LONGINT GetExtSpriteA( STRUCTPTR ss, STRUCTPTR tags ) LIBRARY graphics
DECLARE FUNCTION LONGINT CoerceMode( STRUCTPTR vp,  LONGINT monitorid, LONGINT flags ) LIBRARY graphics
DECLARE FUNCTION ChangeVPBitMap( STRUCTPTR vp, STRUCTPTR bm, STRUCTPTR db ) LIBRARY graphics
DECLARE FUNCTION ReleasePen( STRUCTPTR cm,  LONGINT n ) LIBRARY graphics
DECLARE FUNCTION LONGINT ObtainPen( STRUCTPTR cm,  LONGINT n,  LONGINT r, \
                                    LONGINT g,  LONGINT b, LONGINT f ) LIBRARY graphics
DECLARE FUNCTION LONGINT GetBitMapAttr( STRUCTPTR bm,  LONGINT attrnum ) LIBRARY graphics
DECLARE FUNCTION STRUCTPTR AllocDBufInfo( STRUCTPTR vp ) LIBRARY graphics
DECLARE FUNCTION FreeDBufInfo( STRUCTPTR dbi ) LIBRARY graphics
DECLARE FUNCTION LONGINT SetOutlinePen( STRUCTPTR rp,  LONGINT pen ) LIBRARY graphics
DECLARE FUNCTION LONGINT SetWriteMask( STRUCTPTR rp,  LONGINT msk ) LIBRARY graphics
DECLARE FUNCTION SetMaxPen( STRUCTPTR rp,  LONGINT maxpen ) LIBRARY graphics
DECLARE FUNCTION SetRGB32CM( STRUCTPTR cm,  LONGINT n,  LONGINT r, LONGINT g,  LONGINT b ) LIBRARY graphics
DECLARE FUNCTION ScrollRasterBF( STRUCTPTR rp, LONGINT dx, LONGINT dy, LONGINT xMin, \
                                 LONGINT yMin, LONGINT xMax, LONGINT yMax ) LIBRARY graphics
DECLARE FUNCTION LONGINT FindColor( STRUCTPTR cm,  LONGINT r,  LONGINT g, \
                                    LONGINT b, LONGINT maxcolor ) LIBRARY graphics
DECLARE FUNCTION STRUCTPTR AllocSpriteDataA( STRUCTPTR bm, STRUCTPTR tags ) LIBRARY graphics
DECLARE FUNCTION LONGINT ChangeExtSpriteA( STRUCTPTR vp, STRUCTPTR oldsprite, \
                                           STRUCTPTR newsprite, STRUCTPTR tags ) LIBRARY graphics
DECLARE FUNCTION FreeSpriteData( STRUCTPTR sp ) LIBRARY graphics
DECLARE FUNCTION SetRPAttrsA( STRUCTPTR rp, STRUCTPTR tags ) LIBRARY graphics
DECLARE FUNCTION GetRPAttrsA( STRUCTPTR rp, STRUCTPTR tags ) LIBRARY graphics
DECLARE FUNCTION LONGINT BestModeIDA( STRUCTPTR tags ) LIBRARY graphics
/*--- functions in V40 OR higher (Release 3.1) ---
DECLARE FUNCTION WriteChunkyPixels( STRUCTPTR rp,  LONGINT xstart, \
                                    LONGINT ystart,  LONGINT xstop,  LONGINT ystop, \
                                    ADDRESS array, LONGINT bytesperrow ) LIBRARY graphics
*/
#endif   /* FUNCS_GRAPHICS_FUNCS_H */
