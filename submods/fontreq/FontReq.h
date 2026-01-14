{*
** External subprogram declarations and structure definitions for the
** library module FontReq.o, which creates a simple ASL font requester
** and returns font name, height, style and front/back pen colors. 
**
** See also ace.doc, "Creating & using ACE subprogram modules".
**
** This file should reside in ACEinclude: so that #include <FontReq.h>
** can be used in programs linked with FontReq.o.
**  
** Author: David J Benn
**   Date: 22nd January 1995, 
**	   5th March 1995
*}

STRUCT FontInfo
  ADDRESS  fontName
  SHORTINT fontHeight  
  SHORTINT textStyle
  SHORTINT frontColor
  SHORTINT backColor
END STRUCT

DECLARE SUB LONGINT FontInfoRequest(ADDRESS fontInfoStruct) EXTERNAL
