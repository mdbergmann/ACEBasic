{*
** CyberGraphX API example.
**
** Demonstrates using the CyberGraphics library (cybergraphics.library)
** from ACE BASIC via the BMAP. Works with both native CyberGraphX
** and Picasso96's CyberGraphX compatibility layer.
**
** This program:
**   - Opens cybergraphics.library
**   - Opens a P96 RTG screen (mode 13)
**   - Uses CyberGraphX functions to query screen properties
**   - Demonstrates IsCyberModeID, GetCyberMapAttr
**
** Requires: Picasso96 or CyberGraphX RTG driver
*}

#include <cybergraphx/cybergraphics.h>

LIBRARY "cybergraphics.library"
DECLARE FUNCTION IsCyberModeID&(displayID&) LIBRARY cybergraphics
DECLARE FUNCTION GetCyberMapAttr&(bitmap&, attrTag&) LIBRARY cybergraphics

CONST SCR_W = 640
CONST SCR_H = 480
CONST SCR_DEPTH = 8

LONGINT bitmapAddr&, modeID&, isCyber&
LONGINT bpr&, bpp&, pixFmt&, bmWidth&, bmHeight&, bmDepth&

' Open a 256-color P96/RTG screen
SCREEN 1, SCR_W, SCR_H, SCR_DEPTH, 13
IF ERR = 600 THEN
  PRINT "P96/CGX not available or no matching display mode."
  STOP
END IF

WINDOW 1,"",(0,0)-(SCR_W-1,SCR_H-1),0,1

' Get the screen's BitMap address
' SCREEN(4) returns &Screen->BitMap (embedded struct)
bitmapAddr& = SCREEN(4)

' Query bitmap attributes using CyberGraphX API
bpr&     = GetCyberMapAttr&(bitmapAddr&, CYBRMATTR_XMOD)
bpp&     = GetCyberMapAttr&(bitmapAddr&, CYBRMATTR_BPPIX)
pixFmt&  = GetCyberMapAttr&(bitmapAddr&, CYBRMATTR_PIXFMT)
bmWidth& = GetCyberMapAttr&(bitmapAddr&, CYBRMATTR_WIDTH)
bmHeight&= GetCyberMapAttr&(bitmapAddr&, CYBRMATTR_HEIGHT)
bmDepth& = GetCyberMapAttr&(bitmapAddr&, CYBRMATTR_DEPTH)
isCyber& = GetCyberMapAttr&(bitmapAddr&, CYBRMATTR_ISCYBERGFX)

COLOR 1, 0
LOCATE 2, 2
PRINT "CyberGraphX API Info"
PRINT
PRINT "  BytesPerRow:  "; bpr&
PRINT "  BytesPerPix:  "; bpp&
PRINT "  Pixel Format: "; pixFmt&
PRINT "  Width:        "; bmWidth&
PRINT "  Height:       "; bmHeight&
PRINT "  Depth:        "; bmDepth&
PRINT "  IsCyberGfx:   "; isCyber&
PRINT
PRINT "  Press any key to exit."

WHILE INKEY$ = ""
WEND

LIBRARY CLOSE
WINDOW CLOSE 1
SCREEN CLOSE 1
