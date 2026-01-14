#include <SUBmods/FontReq.h>

DECLARE STRUCT FontInfo info

IF FontInfoRequest(info) THEN
  PRINT "Font name:   ";CSTR(info->fontName)
  PRINT "Font height: ";info->fontHeight
  PRINT "Text style:  ";info->textStyle
  PRINT "Font color:  ";info->frontColor
  PRINT "Back color:  ";info->backColor
END IF
