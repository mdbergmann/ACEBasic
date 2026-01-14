{*
** ASL Font Requester for use in conjunction with ACE programs.
**
** Author: David J Benn
**   Date: 22nd January, 
**	   10th,13th February 1995,
**	   5th March 1995,
**	   29th September 1996
*}

{*
** General constants.
*}
CONST true = -1&, false = 0&
CONST null = 0&

{*
** ASL contants/values.
*}
CONST ASL_FontRequest	= 1

CONST FONF_FRONTCOLOR 	= 1
CONST FONF_BACKCOLOR	= 2
CONST FONF_STYLES	= 4
CONST FONF_FIXEDWIDTH	= 16

CONST TAG_DONE 		= 0&

{*
** Structure definitions.
*}
STRUCT TagItem
  LONGINT ti_Tag
  LONGINT ti_Data
END STRUCT

STRUCT TextAttr
  ADDRESS  ta_Name
  SHORTINT ta_YSize
  BYTE	   ta_Style
  BYTE 	   ta_Flags
END STRUCT

STRUCT FontRequester
  ADDRESS  fo_Reserved1
  ADDRESS  fo_Reserved2
  TextAttr fo_Attr
  BYTE	   fo_FrontPen
  BYTE	   fo_BackPen
  BYTE	   fo_DrawMode
  ADDRESS  fo_UserData
  SHORTINT fo_LeftEdge
  SHORTINT fo_TopEdge
  SHORTINT fo_Width
  SHORTINT fo_Height
END STRUCT

STRUCT FontInfo
  ADDRESS  fontName
  SHORTINT fontHeight
  SHORTINT textStyle
  SHORTINT frontColor
  SHORTINT backColor
END STRUCT

{*
** Shared library function declarations.
*}
DECLARE FUNCTION ADDRESS AllocAslRequest(LONGINT type, ADDRESS ptags) LIBRARY asl
DECLARE FUNCTION FreeAslRequest(ADDRESS request) LIBRARY asl
DECLARE FUNCTION SHORTINT AslRequest(ADDRESS request, ADDRESS ptags) LIBRARY asl

DECLARE FUNCTION ADDRESS AllocateTagItems(LONGINT tags) LIBRARY utility
DECLARE FUNCTION FreeTagItems(ADDRESS ptags) LIBRARY utility

{*
** Subprogram definitions.
*}
SUB LONGINT FontInfoRequest(ADDRESS theInfo) EXTERNAL
DECLARE STRUCT TagItem *fontReqTags, *tag
DECLARE STRUCT FontRequester *request
DECLARE STRUCT TextAttr *theAttr
DECLARE STRUCT FontInfo *info
LONGINT ASL_FuncFlags, retVal

  LIBRARY "utility.library"
  LIBRARY "asl.library"

  info = theInfo

  {* Allocate requester structure. *}
  fontReqTags = AllocateTagItems(2)
  IF fontReqTags = null THEN
    retVal = false
  ELSE
    ASL_FuncFlags = SHL(1,31) + &H80000 + 20  {* see C header libraries/asl.h *}
    tag = fontReqTags
    tag->ti_Tag = ASL_FuncFlags
    tag->ti_Data = FONF_FRONTCOLOR OR FONF_BACKCOLOR OR FONF_STYLES OR FONF_FIXEDWIDTH
    tag = tag + SIZEOF(TagItem)
    tag->ti_Tag = TAG_DONE

    request = AllocAslRequest(ASL_FontRequest, fontReqTags)

    IF request = null THEN 
      retVal = false
    ELSE
      {* Render the requester. *}
      IF AslRequest(request, null) THEN
        {* Okay -> get font information. *}
        theAttr = @request->fo_Attr
        info->fontName = theAttr->ta_Name
        info->fontHeight = theAttr->ta_YSize
        info->textStyle = theAttr->ta_Style
        info->frontColor = request->fo_FrontPen
        info->backColor = request->fo_BackPen
        retVal = true
      ELSE
        {* Requester cancelled. *}
        retVal = false
      END IF
    END IF

    {* Clean up. *}
    FreeAslRequest(request)
    FreeTagItems(fontReqTags)

    LIBRARY CLOSE "asl.library"
    LIBRARY CLOSE "utility.library"
  END IF

  {* successful? *}
  FontInfoRequest = retVal
END SUB
