{*
** A Requester Editor for ACE programs.
** Copyright (C) 1998 David Benn
** 
** This program is free software; you can redistribute it and/or
** modify it under the terms of the GNU General Public License
** as published by the Free Software Foundation; either version 2
** of the License, or (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
**
** A requester (in this context, a window containing gadgets and text)
** can be designed on-screen. Code, in the form of an ACE subprogram, 
** is then generated to render it, await gadget activity and clean up.
**
** The programmer can add code to act upon specific gadget activity 
** and possibly return information to the main program.
**
** Author: David J Benn
**   Date: 6th-8th,10th,15th-22nd,25th,26th January 1995,
**	   13th,14th,18th-20th February 1995,
**	   12th September 1996
*}

DEFLNG a-z

STRING version SIZE 30
version = "$VER: ReqEd 1.12 (12.09.96)"

{*
** General constants.
*}
CONST true 	= -1&
CONST false 	= 0&
CONST null 	= 0&
CONST default 	= -1&

{*
** ASCII codes for special keys.
*}
CONST DEL_key 	= 127
CONST BKSPC_key = 8
CONST ENTER_key = 13

{*
** Border constants.
*}
CONST NO_EDGE		= 0 
CONST LEFT_EDGE		= 1 
CONST RIGHT_EDGE	= 2 
CONST TOP_EDGE		= 3 
CONST BOTTOM_EDGE	= 4
CONST EDGE_THICKNESS	= 2
 
{*
** Menu constants.
*}
CONST sDisable		= 0
CONST sEnable		= 1
CONST sCheck		= 2

CONST mProject		= 1
CONST iProject		= 0
CONST iExit 		= 1	'..for Preview mode Project menu.
CONST iNew		= 1	'..for Layout mode Project menu.
CONST iOpen		= 2
CONST iSave		= 3
CONST iSaveAs		= 4
CONST iToolBar		= 5
CONST iSep1.1		= 6
CONST iAbout		= 7
CONST iQuit		= 8

CONST mWindow		= 2
CONST iWindow		= 0
CONST iRedraw		= 1
CONST iPreview		= 2
CONST iSep2.1		= 3
CONST iSetId		= 4
CONST iSetTitle		= 5
CONST iSep2.2		= 6
CONST iSizeGadget	= 7
CONST iMoveable		= 8
CONST iDepthGadget	= 9
CONST iCloseGadget	= 10
CONST iSmartRefresh	= 11
CONST iBorderless	= 12

{*
** Gadget constants.
*}
CONST gButton		= 1
CONST gString		= 2
CONST gLongInt		= 3
CONST gPotX		= 4
CONST gPotY		= 5
CONST gText		= 6
CONST gRaisedBox	= 7
CONST gRecessedBox	= 8

{*
** GUI Object List node "kinds" (note: values agree with gadget constants above).
*}
CONST headOfList 	= 0
CONST buttonGadget 	= 1
CONST stringGadget 	= 2
CONST longintGadget 	= 3
CONST potXGadget 	= 4
CONST potYGadget 	= 5
CONST staticText 	= 6
CONST raisedBevelBox	= 7
CONST recessedBevelBox	= 8

{*
** Box styles.
*}
CONST NORMAL 		= 0
CONST RAISED 		= 1
CONST RECESSED 		= 2
CONST STRGAD 		= 3

{*
** Miscellaneous constants.
*}
CONST toolWdw = 1
CONST maxToolBarButtons = 8

{* 
** Structure definitions.
*}
STRUCT WindowStruct
   ADDRESS  NextWindow
   SHORTINT LeftEdge
   SHORTINT TopEdge
   SHORTINT xWidth
   SHORTINT Height
   SHORTINT MouseY
   SHORTINT MouseX
   SHORTINT MinWidth
   SHORTINT MinHeight
   SHORTINT MaxWidth
   SHORTINT MaxHeight
   LONGINT  Flags
   ADDRESS  MenuStrip
   ADDRESS  Title
   ADDRESS  FirstRequest
   ADDRESS  DMRequest
   SHORTINT ReqCount
   ADDRESS  WScreen
   ADDRESS  RPort
   BYTE     BorderLeft
   BYTE     BorderTop
   BYTE     BorderRight
   BYTE     BorderBottom
   ADDRESS  BorderRPort
   ADDRESS  FirstGadget
   ADDRESS  Parent
   ADDRESS  Descendant
   ADDRESS  Pointer
   BYTE     PtrHeight
   BYTE     PtrWidth
   BYTE     XOffset
   BYTE     YOffset
   LONGINT  IDCMPFlags
   ADDRESS  UserPort
   ADDRESS  WindowPort
   ADDRESS  MessageKey
   BYTE     DetailPen
   BYTE     BlockPen
   ADDRESS  CheckMark
   ADDRESS  ScreenTitle
   SHORTINT GZZMouseX
   SHORTINT GZZMouseY
   SHORTINT GZZWidth
   SHORTINT GZZHeight
   ADDRESS  ExtData
   ADDRESS  UserData
   ADDRESS  WLayer
   ADDRESS  IFont
END STRUCT

STRUCT GUIObjType
  SHORTINT kind
  SHORTINT x1
  SHORTINT y1
  SHORTINT x2
  SHORTINT y2
  ADDRESS  theText
  ADDRESS  fontName
  SHORTINT fontHeight
  SHORTINT textStyle
  SHORTINT frontColor
  SHORTINT backColor
  LONGINT  potVal
  ADDRESS  nextNode
END STRUCT

STRUCT CoordType
  SHORTINT x1
  SHORTINT y1
  SHORTINT x2
  SHORTINT y2
  LONGINT  valid
END STRUCT

STRUCT FontInfo
  ADDRESS  fontName
  SHORTINT fontHeight  
  SHORTINT textStyle
  SHORTINT frontColor
  SHORTINT backColor
END STRUCT

{*
** Globals.
*}
LONGINT finished
LONGINT wdwFlags, wdwID, dirty, toolBarActive
SHORTINT wdw_x1, wdw_y1, wdw_x2, wdw_y2
SHORTINT old_wdw_x1, old_wdw_y1
SHORTINT gadCount
STRING wdwTitle SIZE 100
STRING projectName SIZE 80
STRING reqName SIZE 80
DECLARE STRUCT GUIObjType *guiObjList
ADDRESS spriteData
DIM STRING buttonText(maxToolBarButtons) SIZE 15

{*
** Shared library function declarations.
*}
LIBRARY "graphics.library"
DECLARE FUNCTION SetDrMd(ADDRESS RPort, SHORTINT mode) LIBRARY graphics
DECLARE FUNCTION SHORTINT TextLength(ADDRESS RPort, STRING theText, ~
				     SHORTINT count) LIBRARY graphics

LIBRARY "intuition.library"
DECLARE FUNCTION SetPointer(ADDRESS wdw,ADDRESS spData,h%,w%,xOff%,yOff%) LIBRARY intuition
DECLARE FUNCTION SetWindowTitles(ADDRESS wdw,wdw_title$,scr_title$) LIBRARY intuition
CONST LEAVE = -1&

{*
** External SUB declarations.
*}
DECLARE SUB LONGINT FontInfoRequest(ADDRESS fontInfoStruct) EXTERNAL

'..See external references section in FontReq.b re: the following kludge!
ASSEM 
  xdef _EXIT_PROG
END ASSEM

{*
** Forward SUB references.
*}
DECLARE SUB RedrawGUIObjects
DECLARE SUB ADDRESS GUIObjVal(ADDRESS guiObjAddr, STRING prompt)

{*
** Subprogram definitions.
*}

{* General SUBs *}
SUB InitToolBarButtonText
SHARED buttonText
SHORTINT i
  FOR i=1 TO maxToolBarButtons
    READ buttonText(i)
  NEXT
  DATA "Button", "String", "LongInt", "PotX", "PotY", "Text"
  DATA "Plateau", "Panel"
END SUB

SUB InitCrossHairPointerData
SHARED spriteData
SHORTINT bytes, i, theWord
CONST numberOfPairs = 17

  bytes = numberOfPairs*2*SIZEOF(SHORTINT)
  spriteData = ALLOC(bytes,0)	'..allocate CHIP memory for sprite data.

  IF spriteData <> null THEN
    FOR i=0 TO bytes-1 STEP 2
      READ theWord
      *%(spriteData+i) := theWord
    NEXT

    DATA 0,0	'..position, control

    DATA &H0000, &H0000
    DATA &H0000, &H0000

    DATA &H0100, &H0000
    DATA &H0100, &H0000
    DATA &H0100, &H0000
    DATA &H0100, &H0000

    DATA &H0000, &H0000
    DATA &HFD7E, &H0000
    DATA &H0000, &H0000

    DATA &H0100, &H0000
    DATA &H0100, &H0000
    DATA &H0100, &H0000
    DATA &H0100, &H0000

    DATA &H0000, &H0000	
    DATA &H0000, &H0000	
    
    DATA 0,0	'..end
  END IF
END SUB

SUB LTRIM$(STRING x)
SHORTINT i
  FOR i=1 TO LEN(x)
    IF MID$(x,i,1) <> " " THEN EXIT FOR 
  NEXT
  LTRIM$ = MID$(x,i)
END SUB

SUB SetCurrWdw
SHARED toolBarActive, wdwID
SHORTINT currWdw
  IF NOT toolBarActive THEN 
    WINDOW OUTPUT wdwID
  ELSE
    currWdw = WINDOW(0)
    IF currWdw = wdwID OR currWdw = toolWdw THEN WINDOW OUTPUT currWdw
  END IF
END SUB

SUB SetWdwRect
SHARED wdwID, toolBarActive, dirty
SHARED old_wdw_x1, old_wdw_y1
SHARED wdw_x1, wdw_y1, wdw_x2, wdw_y2
DECLARE STRUCT WindowStruct *wdw
  WINDOW OUTPUT wdwID
  wdw = WINDOW(7)
  wdw_x1 = wdw->LeftEdge
  wdw_y1 = wdw->TopEdge
  wdw_x2 = wdw_x1 + WINDOW(2)
  wdw_y2 = wdw_y1 + WINDOW(3)
  IF toolBarActive THEN WINDOW OUTPUT toolWdw
  IF wdw_x1 <> old_wdw_x1 OR wdw_y1 <> old_wdw_y1 THEN 
    dirty = true
    old_wdw_x1 = wdw_x1
    old_wdw_y1 = wdw_y1
  END IF
END SUB

SUB STRING Rect(SHORTINT x1,SHORTINT y1,SHORTINT x2,SHORTINT y2)
  Rect = "("+LTRIM$(STR$(x1))+","+LTRIM$(STR$(y1))+")-("+ ~
	 LTRIM$(STR$(x2))+","+LTRIM$(STR$(y2))+")"
END SUB

SUB ShowMouseCoordinates(SHORTINT x1, SHORTINT y1, SHORTINT x2, SHORTINT y2)
SHARED wdwID, wdwFlags, wdwTitle
  WINDOW OUTPUT wdwID
  IF (wdwFlags AND 2) OR (wdwFlags AND 4) OR (wdwFlags AND 8) OR (wdwTitle <> "") THEN 
    SetWindowTitles(WINDOW(7),	"("+LTRIM$(STR$(x1))+","+ ~
				LTRIM$(STR$(y1))+")-("+ ~
				LTRIM$(STR$(x2))+","+ ~
				LTRIM$(STR$(y2))+")", ~
		    LEAVE)
  END IF
END SUB

SUB ResetReqWdwTitle
SHARED wdwID, wdwFlags, wdwTitle
  WINDOW OUTPUT wdwID
  IF wdwTitle <> "" THEN
    SetWindowTitles(WINDOW(7),wdwTitle,LEAVE)
  ELSE
    IF (wdwFlags AND 2) OR (wdwFlags AND 4) OR (wdwFlags AND 8) THEN
      SetWindowTitles(WINDOW(7),"",LEAVE)
    END IF
  END IF
END SUB

SUB CreateWindow
SHARED wdwTitle, wdwFlags, wdwID
SHARED wdw_x1, wdw_y1, wdw_x2, wdw_y2
SHARED spriteData
  IF wdwFlags AND 2 THEN
    '..Moveable, so need a title bar.
    WINDOW wdwID,wdwTitle,(wdw_x1,wdw_y1)-(wdw_x2,wdw_y2),wdwFlags
  ELSE
    IF wdwTitle <> "" THEN
      '..A title has been specified.
      WINDOW wdwID,wdwTitle,(wdw_x1,wdw_y1)-(wdw_x2,wdw_y2),wdwFlags
    ELSE
      '..No title specified.
      WINDOW wdwID,,(wdw_x1,wdw_y1)-(wdw_x2,wdw_y2),wdwFlags
    END IF
  END IF

  '..Set the window's mouse pointer.
  IF spriteData <> null THEN CALL SetPointer(WINDOW(7), spriteData, 15, 15, -8, -7)

  '..Redraw gadgets and text.
  RedrawGUIObjects
END SUB

SUB SetupMenus
SHARED toolBarActive, wdwFlags
SHORTINT i
  MENU mProject,iProject,sEnable,	"Project"
  MENU mProject,iNew,sEnable,		"   New",	"N"
  MENU mProject,iOpen,sEnable,		"   Open...",	"O"
  MENU mProject,iSave,sEnable,		"   Save...",	"S"
  MENU mProject,iSaveAs,sEnable,	"   Save As..."
  MENU mProject,iToolBar,sEnable,	"   Tool Bar",	"T"
  MENU mProject,iSep1.1,sDisable,	"-----------------"
  MENU mProject,iAbout,sEnable,		"   About..."
  MENU mProject,iQuit,sEnable,		"   Quit",	"Q"

  MENU mWindow,iWindow,sEnable,		"Window"
  MENU mWindow,iRedraw,sEnable,		"   Redraw",	"R"
  MENU mWindow,iPreview,sEnable,	"   Preview",	"P"
  MENU mWindow,iSep2.1,sDisable,	"----------------"
  MENU mWindow,iSetId,sEnable,		"   Set Id..."
  MENU mWindow,iSetTitle,sEnable,	"   Set Title..."
  MENU mWindow,iSep2.2,sDisable,	"----------------"
  MENU mWindow,iSizeGadget,sEnable,	"   Size Gadget"
  MENU mWindow,iMoveable,sEnable,	"   Moveable"
  MENU mWindow,iDepthGadget,sEnable,	"   Depth Gadget"
  MENU mWindow,iCloseGadget,sEnable,	"   Close Gadget"
  MENU mWindow,iSmartRefresh,sEnable,	"   Smart Refresh"
  MENU mWindow,iBorderless,sEnable,	"   Borderless"

  '..Is the Tool Bar window active?
  IF toolBarActive THEN MENU mProject,iToolBar,sCheck

  '..Set window menu checkmarks.
  FOR i=0 TO 5
    IF wdwFlags AND CINT(2^i) THEN MENU mWindow,iSizeGadget+i,sCheck
  NEXT 
END SUB

SUB DrawTextLayoutGuide(SHORTINT x1, SHORTINT y1, SHORTINT x2, SHORTINT y2)
  '..Left edge of layout guide 
  '..(possibly adjust, since it may have grown in 
  '..height due to large font being specified while 
  '..near top of window).
  IF y1 < 0 THEN y1 = 0
  LINE (x1,y1)-(x1,y2),2

  '..Text length indicator.
  LINE (x1,y2)-(x2,y2),2
END SUB

{* GUI Object List related SUBs/FNs *}

DEF ADDRESS NewGUIObj = ALLOC(SIZEOF(GUIObjType))

SUB ADDRESS GUIObjListHead
SHARED guiObjList
  guiObjList = NewGUIObj

  IF guiObjList = null THEN 
    MsgBox "Memory allocation error!","Continue"
  END IF

  guiObjList->kind = headOfList

  GUIObjListHead = guiObjList
END SUB

SUB LONGINT NodesOK(ADDRESS theNode)
SHARED guiObjList
  IF guiObjList = null THEN
    MsgBox "GUI Object List is not initialised!","Continue"
    NodesOK = false
    EXIT SUB
  END IF
  
  IF theNode = null THEN
    MsgBox "GUI Object Node is null!","Continue"
    NodesOK = false
    EXIT SUB
  END IF

  NodesOK = true
END SUB

SUB LONGINT NodesMatch(ADDRESS a, ADDRESS b)
DECLARE STRUCT GUIObjType *node1, *node2
  node1 = a
  node2 = b

  IF node1->kind = node2->kind AND ~
     node1->x1 = node2->x1 AND node1->y1 = node2->y1 AND ~
     node1->x2 = node2->x2 AND node1->y2 = node2->y2 THEN
    '..They are equal.
    NodesMatch = true
  ELSE
    '..They are different.
    NodesMatch = false
  END IF
END SUB

SUB AddGUIObj(ADDRESS theNode)
SHARED guiObjList, gadCount
DECLARE STRUCT GUIObjType *curr
  IF NodesOK(theNode) THEN
    '..Seek end of the list.   
    curr = guiObjList
    WHILE curr->nextNode <> null
      curr = curr->nextNode
    WEND

    '..Add the new node.
    IF GadCount <= 255 THEN
      IF curr->kind >= buttonGadget AND curr->kind <= potYGadget THEN ++gadCount
      curr->nextNode = theNode
    END IF
  END IF
END SUB

SUB RemoveGUIObj(ADDRESS theNode)
SHARED guiObjList, gadCount
DECLARE STRUCT GUIObjType *prev, *curr
LONGINT found
  IF NodesOK(theNode) THEN
    '..Find node.
    prev = guiObjList
    curr = guiObjList->nextNode
    found = false
    WHILE NOT found AND curr <> null
      IF NodesMatch(theNode,curr) THEN 
        found = true
      ELSE
        prev = curr
        curr = curr->nextNode
      END IF
    WEND

    '..Remove node from list.
    IF found THEN 
      IF curr->kind >= buttonGadget AND curr->kind <= potYGadget THEN --gadCount
      prev->nextNode = curr->nextNode
    END IF
  END IF
END SUB

SUB RedrawGUIObjects
SHARED guiObjList
DECLARE STRUCT GUIObjType *curr
  IF guiObjList = null THEN
    MsgBox "GUI Object List is not initialised!","Continue"
  ELSE
    '..Traverse the list drawing objects in requester window.
    curr = guiObjList->nextNode
    WHILE curr <> null
      objKind = curr->kind
      IF objKind = staticText THEN
	'..Text.
	DrawTextLayoutGuide(curr->x1,curr->y1,curr->x2,curr->y2)
      ELSE
	'..Gadget or Bevel-Box.
        CASE
          objKind = buttonGadget     : boxStyle = RAISED
          objKind = stringGadget     : boxStyle = STRGAD
          objKind = longintGadget    : boxStyle = STRGAD
          objKind = potXGadget       : boxStyle = RAISED
          objKind = potYGadget       : boxStyle = RAISED
	  objKind = raisedBevelBox   : boxStyle = RAISED
	  objKind = recessedBevelBox : boxStyle = RECESSED
        END CASE

	BEVELBOX (curr->x1,curr->y1)-(curr->x2,curr->y2),boxStyle
      END IF

      curr = curr->nextNode
    WEND
  END IF
END SUB

SUB SaveGUIObjects(SHORTINT fileNum)
SHARED guiObjList
DECLARE STRUCT GUIObjType *curr
  IF guiObjList = null THEN
    MsgBox "GUI Object List is not initialised!","Continue"
  ELSE
    '..Traverse the list writing objects to a file.   
    curr = guiObjList->nextNode
    WHILE curr <> null
      WRITE #fileNum,curr->kind
      IF curr->kind = potXGadget OR curr->kind = potYGadget THEN
	WRITE #fileNum,curr->potVal
      ELSE
	IF curr->kind <> raisedBevelBox AND curr->kind <> recessedBevelBox THEN
	  WRITE #fileNum,CSTR(curr->theText)
	END IF
      END IF
      IF curr->kind = staticText THEN
	WRITE #fileNum,CSTR(curr->fontName)
	WRITE #fileNum,curr->fontHeight
	WRITE #fileNum,curr->textStyle
	WRITE #fileNum,curr->frontColor
	WRITE #fileNum,curr->backColor
      END IF
      WRITE #fileNum,curr->x1,curr->y1,curr->x2,curr->y2
      curr = curr->nextNode
    WEND
  END IF
END SUB

SUB GetGUIObjects(SHORTINT fileNum)
SHARED guiObjList, gadCount
DECLARE STRUCT GUIObjType *curr
SHORTINT x1,y1,x2,y2
  IF guiObjList = null THEN
    MsgBox "GUI Object List is not initialised!","Continue"
  ELSE
    '..Read objects from a file adding them to the list.
    gadCount = 0
    curr = guiObjList
    WHILE NOT EOF(fileNum)
      curr->nextNode = NewGUIObj
      curr = curr->nextNode
      IF curr = null THEN MsgBox "Memory allocation error!","Continue":EXIT SUB
      INPUT #fileNum,theVal : curr->kind = theVal
      IF curr->kind <> staticText AND curr->kind <> raisedBevelBox AND ~
	 curr->kind <> recessedBevelBox THEN ++gadCount
      IF curr->kind = potXGadget OR curr->kind = potYGadget THEN
	INPUT #fileNum,theVal : curr->potVal = theVal
      ELSE
	IF curr->kind <> raisedBevelBox AND curr->kind <> recessedBevelBox THEN
	  INPUT #fileNum,theVal$
    	  curr->theText = ALLOC(LEN(theVal$)+1)
    	  IF curr->theText = null THEN MsgBox "Memory allocation error!","Continue":EXIT SUB
    	  STRING theText ADDRESS curr->theText
    	  theText = theVal$
	END IF
      END IF
      IF curr->kind = staticText THEN
	INPUT #fileNum,theVal$
    	curr->fontName = ALLOC(LEN(theVal$)+1)
    	IF curr->fontName = null THEN MsgBox "Memory allocation error!","Continue":EXIT SUB
    	STRING fontName ADDRESS curr->fontName
    	fontName = theVal$
	INPUT #fileNum,theVal : curr->fontHeight = theVal
	INPUT #fileNum,theVal : curr->textStyle = theVal
	INPUT #fileNum,theVal : curr->frontColor = theVal
	INPUT #fileNum,theVal : curr->backColor = theVal
      END IF 
      INPUT #fileNum,x1,y1,x2,y2
      curr->x1 = x1 : curr->y1 = y1 : curr->x2 = x2 : curr->y2 = y2
    WEND
  END IF
END SUB

SUB SHORTINT RenderGUIObjects(SHORTINT fileNum)
SHARED guiObjList
DECLARE STRUCT GUIObjType *curr
LONGINT theGadNum
SHORTINT x1,y1, x2,y2
SHORTINT bevelBoxMode
  IF guiObjList = null THEN
    MsgBox "GUI Object List is not initialised!","Continue"
    '..No minimum gadget number.
    RenderGUIObjects = 0
  ELSE
    '..Traverse the list generating code to render objects.
    theGadNum = 256
    curr = guiObjList->nextNode
    WHILE curr <> null
      IF curr->kind = staticText THEN
	'..Text.
	PRINT #fileNum,"  FONT ";CHR$(34);CSTR(curr->fontName);CHR$(34);","; ~
		       	LTRIM$(STR$(curr->fontHeight));" : ";
	PRINT #fileNum,"STYLE";curr->textStyle;" : ";
	PRINT #fileNum,"COLOR";STR$(curr->frontColor);","; ~
			LTRIM$(STR$(curr->backColor));" : ";
        PRINT #fileNum,"PENUP";" : ";
	IF CSTR(curr->theText) <> "" THEN
	  PRINT #fileNum,"SETXY";STR$(curr->x1);",";LTRIM$(STR$(curr->y2))
	  PRINT #fileNum,"  PRINT ";CHR$(34);CSTR(curr->theText);CHR$(34);";"
	END IF
      ELSE
	objKind = curr->kind
   	IF objKind = raisedBevelBox OR objKind = recessedBevelBox THEN
	  '..Bevel-Box.
	  PRINT #fileNum,"  BEVELBOX ";Rect(curr->x1,curr->y1,curr->x2,curr->y2);",";
	  IF objKind = raisedBevelBox THEN 
	    bevelBoxMode = RAISED 
	  ELSE
	    bevelBoxMode = RECESSED
	  END IF
	  PRINT #fileNum,LTRIM$(STR$(bevelBoxMode))
	ELSE
	  '..Gadget.
	  x1 = curr->x1 : y1 = curr->y1
	  x2 = curr->x2 : y2 = curr->y2
      
          objKind = curr->kind
        
	  '..Are offsets required for this gadget?
	  IF objKind = buttonGadget THEN
	    ++x2
	    ++y2
	  ELSE
	    IF objKind = stringGadget OR objKind = longintGadget THEN
	      x1 = x1+6 : y1 = y1+3
	      x2 = x2+6 : y2 = y2+3
	    END IF
	  END IF

          --theGadNum

 	  PRINT #fileNum,"  GADGET";STR$(theGadNum);",ON,";
	  IF curr->kind <> potXGadget AND curr->kind <> potYGadget THEN
	    PRINT #fileNum,CHR$(34);
	    IF CSTR(curr->theText) <> "" THEN PRINT #fileNum,CSTR(curr->theText);
	      PRINT #fileNum,CHR$(34);",";
	    ELSE
	      PRINT #fileNum,LTRIM$(STR$(curr->potVal));",";
	  END IF
	  PRINT #fileNum,Rect(x1,y1,x2,y2);",";
          CASE
            curr->kind = buttonGadget  : PRINT #fileNum,"BUTTON"
            curr->kind = stringGadget  : PRINT #fileNum,"STRING"
            curr->kind = longintGadget : PRINT #fileNum,"LONGINT"
            curr->kind = potXGadget    : PRINT #fileNum,"POTX"
            curr->kind = potYGadget    : PRINT #fileNum,"POTY"
          END CASE
	END IF
      END IF
      curr = curr->nextNode
    WEND
    '..Return minimum gadget number or zero if no gadgets.
    IF theGadNum <> 256 THEN RenderGUIObjects = theGadNum ELSE RenderGUIObjects = 0
  END IF
END SUB

{* GUI object modification SUBs *}

SUB ADDRESS InsideGUIObj(SHORTINT x, SHORTINT y)
SHARED guiObjList
DECLARE STRUCT GUIObjType *curr
LONGINT withinBounds
  IF guiObjList = null THEN
    MsgBox "GUI Object List is not initialised!","Continue"
    InsideGUIObj = null
  ELSE
    '..Find node.
    curr = guiObjList->nextNode
    withinBounds = false
    WHILE NOT withinBounds AND curr <> null
      IF x > curr->x1+EDGE_THICKNESS AND x < curr->x2-EDGE_THICKNESS AND ~ 
	 y > curr->y1+EDGE_THICKNESS AND y < curr->y2-EDGE_THICKNESS THEN
        withinBounds = true
      ELSE
        curr = curr->nextNode
      END IF
    WEND

    '..Return address of node (or null).
    IF withinBounds THEN InsideGUIObj = curr ELSE InsideGUIObj = null
  END IF
END SUB

SUB SelectGUIObj(ADDRESS theObject)
SHARED wdwID
DECLARE STRUCT GUIObjType *guiObject
SHORTINT left, right, top, bottom
  guiObject = theObject
  left = guiObject->x1 : top = guiObject->y1
  right = guiObject->x2 : bottom = guiObject->y2
  WINDOW OUTPUT wdwID
  COLOR 3:PENUP:SETXY left,top:PENDOWN
  SETXY right,top:SETXY right,bottom:SETXY left,bottom:SETXY left,top
END SUB

SUB DeleteGUIObj(ADDRESS theObject)
SHARED wdwID, dirty
DECLARE STRUCT GUIObjType *guiObject
STRING objName SIZE 20
  guiObject = theObject
  objKind = guiObject->kind
  CASE
    objKind = buttonGadget     : objName = "button"  
    objKind = stringGadget     : objName = "string gadget"
    objKind = longintGadget    : objName = "longint gadget"  
    objKind = potXGadget       : objName = "horizontal slider"  
    objKind = potYGadget       : objName = "vertical slider"  
    objKind = staticText       : objName = "static text"
    objKind = raisedBevelBox   : objName = "plateau"
    objKind = recessedBevelBox : objName = "panel"
  END CASE
  IF MsgBox("Delete selected "+objName+"?","Yes","No") THEN 
    RemoveGUIObj(theObject)
    IF NOT dirty THEN dirty = true
  END IF
  '..Refresh display to get rid of selection box and
  '..possibly to reflect absence of deleted object.
  WINDOW OUTPUT wdwID
  CLS : RedrawGUIObjects
END SUB

SUB ModifyGUIObjVal(ADDRESS theObject)
SHARED dirty, wdwID
DECLARE STRUCT GUIObjType *guiObject, tmpObject
STRING objName SIZE 20
STRING prompt SIZE 30

  guiObject = theObject

  objKind = guiObject->kind

  '..Can't modify Bevel-Box since it holds no text value!
  IF objKind = raisedBevelBox OR objKind = recessedBevelBox THEN 
    MsgBox "No text to modify.","Continue"
    '..Refresh display to get rid of selection box.
    WINDOW OUTPUT wdwID
    CLS : RedrawGUIObjects
    EXIT SUB
  END IF

  CASE
   objKind = buttonGadget : objName="button" : prompt = "Enter Button Text"
   objKind = stringGadget : objName="string gadget" : prompt = "Enter Default Text"
   objKind = longintGadget : objName="longint gadget" : prompt = "Enter Default Value"  
   objKind = potXGadget : objName="horizontal slider":prompt = "Enter Maximum Slider Value"
   objKind = potYGadget : objName="vertical slider":prompt = "Enter Maximum Slider Value" 
   objKind = staticText : objName="static text":prompt = "Enter Static Text"  
  END CASE

  '..Store current values.
  IF objKind <> potXGadget AND objKind <> potYGadget THEN 
    tmpObject->theText = guiObject->theText
  END IF

  IF objKind = staticText THEN
    tmpObject->fontName = guiObject->fontName
    tmpObject->fontHeight = guiObject->fontHeight
    tmpObject->textStyle = guiObject->textStyle
    tmpObject->frontColor = guiObject->frontColor
    tmpObject->backColor = guiObject->backColor
  END IF

  IF objKind = potXGadget OR objKind = potYGadget THEN
    tmpObject->potVal = guiObject->potVal
  END IF

  '..Change the GUI object?
  IF MsgBox("Modify selected "+objName+"?","Yes","No") THEN 
    IF GUIObjVal(theObject, prompt) <> null THEN 
      '..Valid change made.	 
      IF NOT dirty THEN dirty = true
    ELSE
      '..Invalid value(s) entered, so restore old values.
      IF objKind <> potXGadget AND objKind <> potYGadget THEN 
     	guiObject->theText = tmpObject->theText
      END IF

      IF objKind = staticText THEN
    	guiObject->fontName = tmpObject->fontName
    	guiObject->fontHeight = tmpObject->fontHeight
    	guiObject->textStyle = tmpObject->textStyle
    	guiObject->frontColor = tmpObject->frontColor
    	guiObject->backColor = tmpObject->backColor
      END IF

     IF objKind = potXGadget OR objKind = potYGadget THEN
    	guiObject->potVal = tmpObject->potVal
     END IF
    END IF
  END IF
  '..Refresh display to get rid of selection box.
  WINDOW OUTPUT wdwID
  CLS : RedrawGUIObjects
END SUB

SUB MoveGUIObj(ADDRESS theObject)
SHARED wdwID, dirty
DECLARE STRUCT GUIObjType *guiObject
ADDRESS RPort
SHORTINT oldX1,oldY1, oldX2,oldY2
SHORTINT x,y, lastX,lastY, xDiff,yDiff
SHORTINT left, right, top, bottom

  guiObject = theObject

  '..Remove the object from the list.
  RemoveGUIObj(guiObject)

  '..Refresh the display to show absence of the object.
  WINDOW OUTPUT wdwID
  CLS : RedrawGUIObjects
  
  '..Get initial position of object.
  left = guiObject->x1 : top = guiObject->y1
  right = guiObject->x2 : bottom = guiObject->y2

  oldX1 = left : oldY1 = top
  oldX2 = right : oldY2 = bottom

  RPort = WINDOW(8)
  SetDrMd(RPort,2)	'..XOR mode

  selected = true

  lastX = MOUSE(1) : lastY = MOUSE(2)
  x = lastX : y = lastY

  '..Allow the object to be moved.
  WHILE selected AND ~
	lastX > left+EDGE_THICKNESS AND lastX < right-EDGE_THICKNESS AND ~
	lastY > top+EDGE_THICKNESS AND lastY < bottom-EDGE_THICKNESS
    IF MOUSE(0) THEN
      '..Draw selection box.
      COLOR 1:PENUP:SETXY left,top:PENDOWN
      SETXY right,top:SETXY right,bottom:SETXY left,bottom:SETXY left,top

      ShowMouseCoordinates(left,top,right,bottom)

      '..Wait for mouse position to change or left button to be released.
      WHILE selected AND x = lastX AND y = lastY
        x = MOUSE(1) : y = MOUSE(2)
        IF NOT MOUSE(0) THEN selected = false
      WEND

      '..Erase selection box.
      COLOR 0:PENUP:SETXY left,top:PENDOWN
      SETXY right,top:SETXY right,bottom:SETXY left,bottom:SETXY left,top

      '..Adjust selection box? 
      '..Treat horizontal and vertical motion independently.
      xDiff = x-lastX : yDiff = y-lastY

      IF left+xDiff >= 0 THEN
        left = left + xDiff : right = right + xDiff
	lastX = x
      ELSE
	x = lastX
      END IF

      IF top+yDiff >= 0 THEN
        top = top + yDiff : bottom = bottom + yDiff 
	lastY = y
      ELSE
	y = lastY
      END IF
    ELSE
      '..Mouse button has been released.
      selected = false
    END IF 
  WEND
   
  SetDrMd(RPort,1)	'..JAM2 mode
  
  '..Modify the object's position.
  guiObject->x1 = left : guiObject->y1 = top
  guiObject->x2 = right : guiObject->y2 = bottom

  '..Add the modified object to (the end of) the list.
  guiObject->nextNode = null
  AddGUIObj(guiObject)

  '..Refresh the display to show object's (new) position.
  WINDOW OUTPUT wdwID
  CLS : RedrawGUIObjects

  IF NOT dirty AND (left <> oldX1 OR right <> oldX2 OR ~
     	 top <> oldY1 OR bottom <> oldY2) THEN dirty = true

  ResetReqWdwTitle
END SUB

SUB SHORTINT ObjEdge(SHORTINT x, SHORTINT y, ADDRESS theObject)
DECLARE STRUCT GUIObjType *guiObject
  guiObject = theObject

  CASE
    x >= guiObject->x1 AND x <= guiObject->x1+EDGE_THICKNESS AND ~
    y >= guiObject->y1 AND y <= guiObject->y2 : ObjEdge = LEFT_EDGE

    x >= guiObject->x2-EDGE_THICKNESS AND x <= guiObject->x2 AND ~
    y >= guiObject->y1 AND y <= guiObject->y2: ObjEdge = RIGHT_EDGE

    y >= guiObject->y1 AND y <= guiObject->y1+EDGE_THICKNESS AND ~
    x >= guiObject->x1 AND x <= guiObject->x2 : ObjEdge = TOP_EDGE

    y >= guiObject->y2-EDGE_THICKNESS AND y <= guiObject->y2 AND ~
    x >= guiObject->x1 AND x <= guiObject->x2: ObjEdge = BOTTOM_EDGE

    default : ObjEdge = NO_EDGE
  END CASE
END SUB

SUB ADDRESS OnGUIObjBorder(SHORTINT x, SHORTINT y, ADDRESS edge)
SHARED guiObjList
DECLARE STRUCT GUIObjType *curr
LONGINT onBorder
  IF guiObjList = null THEN
    MsgBox "GUI Object List is not initialised!","Continue"
    OnGUIObjBorder = null
    *%edge := NO_EDGE
  ELSE
    '..Find node.
    curr = guiObjList->nextNode
    onBorder = false
    WHILE NOT onBorder AND curr <> null
      *%edge := ObjEdge(x,y,curr)
      IF *%edge <> NO_EDGE THEN
	onBorder = true
      ELSE
        curr = curr->nextNode
      END IF
    WEND

    '..Return address of node (or null).
    IF onBorder THEN 
      OnGUIObjBorder = curr
    ELSE 
      *%edge := NO_EDGE
      OnGUIObjBorder = null
    END IF
  END IF
END SUB

SUB ResizeGUIObj(ADDRESS theObject, SHORTINT edge)
SHARED wdwID, dirty
DECLARE STRUCT GUIObjType *guiObject
ADDRESS RPort
SHORTINT oldX1,oldY1, oldX2,oldY2
SHORTINT x,y, lastX,lastY
SHORTINT left, right, top, bottom

  guiObject = theObject

  IF guiObject->kind = staticText THEN EXIT SUB

  '..Remove the object from the list.
  RemoveGUIObj(guiObject)

  '..Refresh the display to show absence of the object.
  WINDOW OUTPUT wdwID
  CLS : RedrawGUIObjects
  
  '..Get initial position of object.
  left = guiObject->x1 : top = guiObject->y1
  right = guiObject->x2 : bottom = guiObject->y2

  oldX1 = left : oldY1 = top
  oldX2 = right : oldY2 = bottom

  RPort = WINDOW(8)
  SetDrMd(RPort,2)	'..XOR mode

  selected = true

  lastX = MOUSE(1) : lastY = MOUSE(2)
  x = lastX : y = lastY

  '..Allow the object to be resized.
  WHILE selected
    IF MOUSE(0) THEN
      '..Draw selection box.
      COLOR 1:PENUP:SETXY left,top:PENDOWN
      SETXY right,top:SETXY right,bottom:SETXY left,bottom:SETXY left,top

      ShowMouseCoordinates(left,top,right,bottom)

      '..Wait for mouse position to change or left button to be released.
      WHILE selected AND x = lastX AND y = lastY
        x = MOUSE(1) : y = MOUSE(2)
        IF NOT MOUSE(0) THEN selected = false
      WEND

      '..Erase selection box.
      COLOR 0:PENUP:SETXY left,top:PENDOWN
      SETXY right,top:SETXY right,bottom:SETXY left,bottom:SETXY left,top

      '..Adjust one edge of the selection box?
      IF x >= 0 AND y >= 0 THEN
	'..Yes.
        CASE
	  edge = LEFT_EDGE   : IF x < right-EDGE_THICKNESS THEN left = x
	  edge = RIGHT_EDGE  : IF x > left+EDGE_THICKNESS THEN right = x
	  edge = TOP_EDGE    : IF y < bottom-EDGE_THICKNESS THEN top = y
	  edge = BOTTOM_EDGE : IF y > top+EDGE_THICKNESS THEN bottom = y
        END CASE     
        lastX = x : lastY = y
      ELSE
	'..No. Retain previous edge position.
	x = lastX : y = lastY
      END IF
    ELSE
      '..Mouse button has been released.
      selected = false
    END IF 
  WEND
   
  SetDrMd(RPort,1)	'..JAM2 mode
  
  '..Modify the object's position.
  guiObject->x1 = left : guiObject->y1 = top
  guiObject->x2 = right : guiObject->y2 = bottom

  '..Add the modified object to (the end of) the list.
  guiObject->nextNode = null
  AddGUIObj(guiObject)

  '..Refresh the display to show object's (new) position.
  WINDOW OUTPUT wdwID
  CLS : RedrawGUIObjects

  IF NOT dirty AND (left <> oldX1 OR right <> oldX2 OR ~
     	 top <> oldY1 OR bottom <> oldY2) THEN dirty = true

  ResetReqWdwTitle
END SUB

{* Project menu SUBs *}

SUB ToggleToolBar
SHARED toolBarActive, wdwID, buttonText
SHORTINT fontWidth, fontHeight, n

  IF NOT toolBarActive THEN
    '..Activate Tool Bar.
    fontWidth = SCREEN(5)
    fontHeight = SCREEN(6)
    WINDOW toolWdw,,(10,10)-(10+11*fontWidth,10+19.5*fontHeight),10
    FOR n=gButton TO gRecessedBox
      '..Render tool bar buttons making each one as wide as necessary
      '..to accomodate the longest button text.
      GADGET n,ON,buttonText(n-gButton+1),(fontWidth,fontHeight+(n-1)*2*fontHeight)- ~
			    (fontWidth+8*fontWidth,fontHeight+n*2*fontHeight),BUTTON,1
    NEXT

    WINDOW OUTPUT wdwID
    MENU mProject,iToolBar,sCheck
    toolBarActive = true
  ELSE
    '..Deactivate Tool Bar.
    FOR n=gButton TO gRecessedBox
      GADGET CLOSE n
    NEXT
    WINDOW OUTPUT toolWdw	'..prevent main window menus from being cleared.
    WINDOW CLOSE toolWdw
    WINDOW OUTPUT wdwID
    MENU mProject,iToolBar,sEnable
    toolBarActive = false
  END IF
END SUB

SUB SetProjectName(STRING fileReqTitle)
SHARED projectName
STRING newProjectName SIZE 80
  newProjectName = FileBox$(fileReqTitle)
  IF newProjectName <> "" THEN projectName = newProjectName
END SUB

SUB StoreInfo
SHARED projectName, reqName
SHARED wdwID, wdwTitle, wdwFlags
SHARED wdw_x1, wdw_y1, wdw_x2, wdw_y2
  OPEN "O",#1,projectName+".req"
  IF HANDLE(1) = null THEN 
    MsgBox "Unable to open "+projectName+".req for writing.","Continue"
    EXIT SUB
  ELSE
    PRINT #1,"#REQED PROJECT#"
    PRINT #1,reqName
    WRITE #1,wdwID
    IF wdwTitle <> "" THEN PRINT #1,wdwTitle ELSE PRINT #1,"#NULL#"
    WRITE #1,wdwFlags
    WRITE #1,wdw_x1,wdw_y1,wdw_x2,wdw_y2
    SaveGUIObjects(1)
    CLOSE #1
  END IF
END SUB

SUB GenerateCode
SHARED projectName, reqName, wdwID, wdwTitle, wdwFlags
SHARED wdw_x1, wdw_y1, wdw_x2, wdw_y2
STRING theTitle SIZE 80
SHORTINT minGadget
  IF reqName = "" THEN
    reqName = InputBox$("Requester SUB name?","Set requester SUB name",reqName,170,10)
  END IF

  IF reqName = "" THEN
    MsgBox projectName+".b not created.","Continue"
    EXIT SUB
  END IF
  OPEN "O",#1,projectName+".b"  
  IF HANDLE(1) = null THEN 
    MsgBox "Unable to open "+projectName+".b for writing.","Continue"
    EXIT SUB
  ELSE
    PRINT #1,"SUB ";reqName  
    {* Variables *}
    PRINT #1,"SHORTINT theGadget, n"  
    {* Code for window *}
    PRINT #1,"  WINDOW";STR$(wdwID);",";
    IF wdwTitle <> "" THEN
      '..A title has been specified. 
      PRINT #1,CHR$(34);wdwTitle;CHR$(34);
    ELSE
      '..There's no title but the window is moveable
      '..(otherwise we want no title bar at all).
      IF wdwFlags AND 2 THEN PRINT #1,CHR$(34);CHR$(34);
    END IF
    PRINT #1,",";Rect(wdw_x1,wdw_y1,wdw_x2,wdw_y2);",";LTRIM$(STR$(wdwFlags))
    {* Render gadgets, bevel-boxes and text *}
    PRINT #1,"  ";CHR$(123);"* RENDER GADGETS, BEVEL-BOXES AND TEXT *";CHR$(125)
    minGadget = RenderGUIObjects(1)
    {* Await and handle gadget activity *}
    PRINT #1,"  ";CHR$(123);"* GADGET HANDLING CODE STARTS HERE *";CHR$(125)
    PRINT #1,"  GADGET WAIT 0"
    PRINT #1,"  theGadget = GADGET(1)"
    {* Cleanup code *}
    PRINT #1,"  ";CHR$(123);"* CLEAN UP *";CHR$(125)
    IF minGadget <> 0 THEN
      PRINT #1,"  FOR n=255 TO";minGadget;"STEP -1"
      PRINT #1,"    GADGET CLOSE n"
      PRINT #1,"  NEXT" 
    END IF
    PRINT #1,"  WINDOW CLOSE";wdwID
    PRINT #1,"END SUB"
  END IF
  CLOSE #1
END SUB

SUB SaveProject
SHARED dirty, projectName, reqName
  SetWdwRect
  IF dirty THEN
    IF projectName = "" THEN CALL SetProjectName("Save Project")
    IF projectName = "" THEN
      '..Abort.
      MsgBox "Project name not specified.","Continue"
    ELSE
      GenerateCode
      IF reqName <> "" THEN
	'..Abort.
        StoreInfo
        dirty = false
      END IF
    END IF
  END IF
END SUB

SUB SaveAs
SHARED projectName, reqName, dirty
STRING oldProjectName SIZE 80
STRING oldReqName SIZE 80
  oldProjectName = projectName
  projectName = ""
  SetProjectName("Save As...")
  IF projectName = "" THEN
    '..Abort.
    MsgBox "Name not specified.","Continue"
    projectName = oldProjectName
  ELSE
    SetWdwRect
    oldReqName = reqName
    reqName = ""
    GenerateCode
    IF reqName = "" THEN
      '..Abort.
      reqName = oldReqName
      projectName = oldProjectName
    ELSE
      StoreInfo
      IF dirty THEN dirty = false
    END IF
  END IF
END SUB

SUB CloseProject
SHARED wdwID
  MENU CLEAR
  WINDOW CLOSE wdwID
END SUB

SUB OpenProject
SHARED projectName, reqName, dirty
SHARED wdwID, wdwTitle, wdwFlags
SHARED wdw_x1, wdw_y1, wdw_x2, wdw_y2
SHARED old_wdw_x1, old_wdw_y1
STRING oldProjectName SIZE 80
STRING fileType SIZE 80
STRING theName SIZE 80

  IF dirty THEN
    IF projectName <> "" THEN theName = projectName ELSE theName = "project"
    IF MsgBox("Save "+theName+"?","Yes","No") THEN CALL SaveProject
  END IF

  oldProjectName = projectName
  SetProjectName("Open Project")

  IF projectName = "" THEN
    MsgBox "Project name not specified.","Continue"
    projectName = oldProjectName
    EXIT SUB
  END IF 

  IF INSTR(projectName,".req") = 0 THEN
    MsgBox projectName+" not of required type.","Continue"
    projectName = oldProjectName
    EXIT SUB
  END IF

  IF GUIObjListHead = null THEN
    projectName = oldProjectName
    EXIT SUB
  END IF

  OPEN "I",#1,projectName
  IF HANDLE(1) = null THEN
    MsgBox "Unable to open "+projectName+" for input.","Continue"
    projectName = oldProjectName
    EXIT SUB
  ELSE
    LINE INPUT #1,fileType
    IF fileType <> "#REQED PROJECT#" THEN
      MsgBox projectName+" not of required type.","Continue"
      projectName = oldProjectName
      CLOSE #1
      EXIT SUB
    END IF
    CloseProject
    LINE INPUT #1,reqName
    INPUT #1,wdwID
    LINE INPUT #1,wdwTitle : IF wdwTitle = "#NULL#" THEN wdwTitle = ""
    INPUT #1,wdwFlags
    INPUT #1,wdw_x1,wdw_y1,wdw_x2,wdw_y2
    old_wdw_x1 = wdw_x1 : old_wdw_y1 = wdw_y1
    GetGUIObjects(1)
    CLOSE #1
    projectName = LEFT$(projectName,INSTR(projectName,".req")-1)
  END IF
  CreateWindow
  SetupMenus  
  dirty = false
END SUB

SUB NewProject
SHARED dirty, wdwID, wdwTitle, gadCount
SHARED wdwFlags, projectName, reqName
SHARED wdw_x1, wdw_y1, wdw_x2, wdw_y2
SHARED old_wdw_x1, old_wdw_y1
STRING theName SIZE 80
  IF dirty THEN
    IF projectName <> "" THEN theName = projectName ELSE theName = "project"
    IF MsgBox("Save "+theName+"?","Yes","No") THEN CALL SaveProject
  END IF
  CloseProject
  IF GUIObjListHead = null THEN EXIT SUB
  wdwID = 9
  wdwFlags = 0
  wdwTitle = ""
  reqName = ""
  projectName = ""
  wdw_x1 = 170 : wdw_y1 = 50 : old_wdw_x1 = 0 : old_wdw_y1 = 0
  wdw_x2 = 470 : wdw_y2 = 175
  gadCount = 0
  CreateWindow
  SetUpMenus  
  dirty = false
END SUB

SUB QuitProgram
SHARED finished, dirty, projectName
STRING theName SIZE 80
  IF dirty THEN
    IF projectName <> "" THEN theName = projectName ELSE theName = "project"
    IF MsgBox("Save "+theName+"?","Yes","No") THEN CALL SaveProject
  END IF
  finished = true
END SUB

{* Window menu SUBs *}

SUB PreviewRequester
SHARED wdwID, wdwFlags, wdwTitle
SHARED wdw_x1, wdw_y1, wdw_x2, wdw_y2
SHARED guiObjList
DECLARE STRUCT GUIObjType *curr
SHORTINT x1,y1, x2,y2
SHORTINT ID
SHORTINT objKind
LONGINT theGadNum
SHORTINT bevelBoxMode

  '..Render the window.
  SetWdwRect
  ID = wdwID-1
  IF ID = toolWdw THEN ID = 9  '..wrap around?
  IF wdwFlags AND 2 THEN
    '..Moveable, so need a title bar.
    WINDOW ID,wdwTitle,(wdw_x1,wdw_y1)-(wdw_x2,wdw_y2),wdwFlags
  ELSE
    IF wdwTitle <> "" THEN
      '..A title has been specified.
      WINDOW ID,wdwTitle,(wdw_x1,wdw_y1)-(wdw_x2,wdw_y2),wdwFlags
    ELSE
      '..No title specified.
      WINDOW ID,,(wdw_x1,wdw_y1)-(wdw_x2,wdw_y2),wdwFlags
    END IF
  END IF

  '..Set up menu.
  MENU mProject,iProject,sEnable,	"Project"
  MENU mProject,iExit,sEnable,		"Exit", "E"

  '..Render gadgets and text.
  IF guiObjList = null THEN
    MsgBox "GUI Object List is not initialised!","Continue"
  ELSE
    '..Traverse the list rendering objects.
    theGadNum = 256
    curr = guiObjList->nextNode
    WHILE curr <> null
      IF curr->kind = staticText THEN
	'..Text.
	FONT CSTR(curr->fontName),curr->fontHeight
	STYLE curr->textStyle
	COLOR curr->frontColor,curr->backColor
        PENUP
	IF curr->theText <> null THEN
	  SETXY curr->x1,curr->y2
	  PRINT CSTR(curr->theText);
        END IF	
      ELSE
	objKind = curr->kind
	IF objKind = raisedBevelBox OR objKind = recessedBevelBox THEN
	  '..Bevel-Box.
	  IF objKind = raisedBevelBox THEN 
	    bevelBoxMode = RAISED 
	  ELSE
	    bevelBoxMode = RECESSED
	  END IF
	  BEVELBOX (curr->x1,curr->y1)-(curr->x2,curr->y2),bevelBoxMode
	ELSE
	  '..Gadget.
	  x1 = curr->x1 : y1 = curr->y1
	  x2 = curr->x2 : y2 = curr->y2
      
          objKind = curr->kind
        
	  '..Are offsets required for this gadget?
	  IF objKind = buttonGadget THEN
	    ++x2
	    ++y2
	  ELSE
	    IF objKind = stringGadget OR objKind = longintGadget THEN
	      x1 = x1+6 : y1 = y1+3
	      x2 = x2+6 : y2 = y2+3
	    END IF
	  END IF

          --theGadNum 	

	  IF curr->kind <> potXGadget AND curr->kind <> potYGadget THEN
	     GADGET theGadNum,ON,CSTR(curr->theText),(x1,y1)-(x2,y2),objKind
	  ELSE
	     GADGET theGadNum,ON,curr->potVal,(x1,y1)-(x2,y2),objKind
	  END IF
        END IF
      END IF
      curr = curr->nextNode
    WEND
    
    '..Await Exit item selection from Project menu or close-gadget click.
    REPEAT
      MENU WAIT
    UNTIL (MENU(0) = mProject AND MENU(1) = iExit) OR GADGET(1) = 256

    '..Clean up.    
    FOR n=255 TO theGadNum STEP -1
      GADGET CLOSE n
    NEXT
    WINDOW CLOSE ID
  END IF  
END SUB

SUB ToggleFlag(SHORTINT theItem)
SHARED wdwFlags
SHORTINT theFlag
  theFlag = CINT(2^(theItem-iSizeGadget))
  IF wdwFlags AND theFlag THEN 
    '..Set flag
    wdwFlags = wdwFlags - theFlag
  ELSE
    '..Reset flag
    wdwFlags = wdwFlags OR theFlag
  END IF
END SUB

SUB SetWdwID
SHARED wdwID, dirty
SHORTINT newID
STRING wdwIDStr SIZE 2
  wdwIDStr = STR$(wdwID)
  wdwIDStr = LTRIM$(wdwIDStr)
  newID = InputBox("New window ID (2..9)","Set window ID",wdwIDStr,170,10)
  IF newID <> wdwID AND newID >= 2 AND newID <= 9 THEN
    dirty = newID <> wdwID
    SetWdwRect
    CloseProject
    wdwID = newID
    CreateWindow
    SetUpMenus
  END IF
END SUB

SUB SetWdwTitle
SHARED wdwID, wdwTitle, dirty
STRING newTitle SIZE 100
  newTitle = InputBox$("New window Title?","Set window Title",wdwTitle,170,10)  
  IF newTitle <> wdwTitle THEN
    dirty = newTitle <> wdwTitle
    wdwTitle = newTitle
    SetWdwRect
    CloseProject
    CreateWindow
    SetUpMenus
  END IF
END SUB

SUB ModifyWindow(SHORTINT theItem)
SHARED dirty
  IF theItem >= iSizeGadget THEN 
    CALL ToggleFlag(theItem)
    IF NOT dirty THEN dirty = true
    SetWdwRect
    CloseProject
    CreateWindow
    SetUpMenus
  ELSE
    CASE 
      theItem = iSetID    : SetWdwID
      theItem = iSetTitle : SetWdwTitle
    END CASE
  END IF
END SUB

SUB DrawBox(SHORTINT objKind, ADDRESS theCoord)
SHARED wdwID
ADDRESS RPort
SHORTINT xDiff,yDiff, x,y, firstX,firstY
DECLARE STRUCT CoordType *coord

  coord = theCoord

  WINDOW OUTPUT wdwID
  RPort = WINDOW(8)

  '..Await a mouse click in the requester window.
  WHILE NOT MOUSE(0):SLEEP FOR .02:WEND

  '..Go no further if user didn't click in requester window.
  IF WINDOW(0) <> wdwID THEN
    coord->valid = false
    EXIT SUB 
  END IF

  firstX = MOUSE(1) : firstY = MOUSE(2)

  IF MOUSE(0) THEN
    SetDrMd(RPort,2)	'..XOR mode

    WHILE MOUSE(0)
      x = MOUSE(1) : y = MOUSE(2)
      xDiff = x-firstX : yDiff = y-firstY
      IF xDiff > 0 AND yDiff > 0 THEN 
 	COLOR 1:PENUP:SETXY firstX,firstY:PENDOWN
	SETXY x,firstY:SETXY x,y:SETXY firstX,y:SETXY firstX,firstY
        ShowMouseCoordinates(firstX,firstY,x,y)
	COLOR 0:PENUP:SETXY firstX,firstY:PENDOWN
	SETXY x,firstY:SETXY x,y:SETXY firstX,y:SETXY firstX,firstY
      END IF
    WEND    
      
    SetDrMd(RPort,1)	'..JAM2 mode

    ResetReqWdwTitle
  
    IF xDiff > 0 AND yDiff > 0 THEN
      IF objKind = staticText THEN
	'..Text.
	DrawTextLayoutGuide(firstX,firstY,x,y)
	coord->valid = true   
      ELSE
	'..Gadget.
        CASE
          objKind = buttonGadget     : boxStyle = RAISED
          objKind = stringGadget     : boxStyle = STRGAD
          objKind = longintGadget    : boxStyle = STRGAD
          objKind = potXGadget       : boxStyle = RAISED
          objKind = potYGadget       : boxStyle = RAISED
	  objKind = raisedBevelBox   : boxStyle = RAISED
	  objKind = recessedBevelBox : boxStyle = RECESSED
        END CASE

 	BEVELBOX (firstX,firstY)-(x,y),boxStyle
  	coord->valid = true
      END IF

      '..Return coordinate info' for object.
      coord->x1 = firstX : coord->y1 = firstY
      coord->x2 = x : coord->y2 = y 
    ELSE
      coord->valid = false
    END IF
  ELSE
    coord->valid = false
  END IF
END SUB

SUB ADDRESS GUIObjVal(ADDRESS guiObjAddr, STRING prompt)
SHARED wdwID
DECLARE STRUCT GUIObjType *guiObj
DECLARE STRUCT FontInfo info
ADDRESS textAddress, RPort
SHORTINT objKind
STRING tmpString
STRING defaultString

  guiObj = guiObjAddr 
  objKind = guiObj->kind

  IF objKind <> potXGadget AND objKind <> potYGadget THEN
    IF guiObj->theText <> null THEN 
	defaultString = CSTR(guiObj->theText)
    ELSE
        defaultString = ""
    END IF
    IF objKind = longintGadget THEN
      '..Want to allow only entry of digits 0..9!
      textAddress = SADD(LTRIM$(STR$(InputBox(prompt,,defaultString,170,10))))
    ELSE
      textAddress = SADD(InputBox$(prompt,,defaultString,170,10))
    END IF

    guiObj->theText = ALLOC(LEN(CSTR(textAddress))+1)
    IF guiObj->theText = null THEN 
	MsgBox "Memory allocation error!","Continue"
	GUIObjVal = null
    ELSE
    	STRING theText ADDRESS guiObj->theText
    	theText = CSTR(textAddress)
    	GUIObjVal = guiObj->theText
    END IF

    IF objKind = staticText THEN
      IF FontInfoRequest(info) THEN
	'..Okay -> use info' from requester.
	textAddress = info->fontName
	guiObj->fontHeight = info->fontHeight
	guiObj->textStyle = info->textStyle
	guiObj->frontColor = info->frontColor
	guiObj->backColor = info->backColor
      ELSE
	'..Use defaults.
        textAddress = SADD("topaz")
        guiObj->fontHeight = 8
        guiObj->textStyle = 0
        guiObj->frontColor = 1
        guiObj->backColor = 0
      END IF

      '..Copy the font name.
      guiObj->fontName = ALLOC(LEN(CSTR(textAddress))+1)
      IF guiObj->fontName = null THEN 
	MsgBox "Memory allocation error!","Continue"
	GUIObjVal = null
      ELSE
        STRING fontName ADDRESS guiObj->fontName
        fontName = CSTR(textAddress)
      END IF

      '..Adjust text selection box.
      guiObj->y1 = guiObj->y2 - guiObj->fontHeight
      WINDOW OUTPUT wdwID
      RPort = WINDOW(8)
      FONT CSTR(guiObj->fontName),guiObj->fontHeight
      IF CSTR(guiObj->theText) = "" THEN
	'..Make sure selection box is big enough to use!
	tmpString = "M"  '..use a wide character.
	length = 1
      ELSE
        tmpString = CSTR(guiObj->theText)
        length = LEN(tmpString)
      END IF
      guiObj->x2 = guiObj->x1 + TextLength(RPort,tmpString,length)
    END IF
  ELSE
    '..POTX or POTY.
    REPEAT
      IF guiObj->potVal > 0 THEN 
	defaultString = LTRIM$(STR$(guiObj->potVal))
      ELSE
	defaultString = ""
      END IF
      guiObj->potVal = InputBox(prompt,,defaultString,170,10)
    UNTIL guiObj->potVal > 0
    GUIObjVal = guiObj->potVal
  END IF
END SUB

SUB CreateGUIObj(SHORTINT objKind, SHORTINT boxStyle)
SHARED wdwID, dirty
DECLARE STRUCT CoordType coord
DECLARE STRUCT GUIObjType *guiObj
STRING prompt SIZE 30

  WINDOW OUTPUT toolWdw
  GADGET objKind,OFF
  WINDOW OUTPUT wdwID
   
  DrawBox(objKind, coord)

  IF coord->valid THEN
    guiObj = NewGUIObj
    guiObj->kind = objKind
    guiObj->x1 = coord->x1
    guiObj->y1 = coord->y1
    guiObj->x2 = coord->x2
    guiObj->y2 = coord->y2

    IF objKind = raisedBevelBox OR objKind = recessedBevelBox THEN
        '..Add bevel-box object to the list and set the "dirty" 
	'..flag since the layout has changed.
        AddGUIObj(guiObj)
        IF NOT dirty THEN dirty = true      
    ELSE
      CASE
        objKind = buttonGadget  : prompt = "Enter Button Text"
        objKind = stringGadget  : prompt = "Enter Default Text"
        objKind = longintGadget : prompt = "Enter Default Value" 
        objKind = potXGadget    : prompt = "Enter Maximum Slider Value (> 0)"
        objKind = potYGadget    : prompt = "Enter Maximum Slider Value (> 0)" 
        objKind = staticText    : prompt = "Enter Static Text"
      END CASE    

      IF GUIObjVal(guiObj, prompt) <> null THEN       
        '..The GUI object is valid so add it to the list
        '..and set the "dirty" flag since the layout has changed.
        AddGUIObj(guiObj)
        IF NOT dirty THEN dirty = true

        '..Redraw text layout guide now that we have font, style and color,
        '..having previously adjusted the selection box.
        IF objKind = staticText THEN
          WINDOW OUTPUT wdwID
          CLS : RedrawGUIObjects
        END IF
      END IF
    END IF
  END IF
  
  '..Restore gadget imagery in tool window.
  WINDOW OUTPUT toolWdw
  FOR n = gButton TO gRecessedBox : GADGET n,ON : NEXT
  WINDOW OUTPUT wdwID
END SUB

{*
** Main.
*}
'..Initialise GUI object list.
IF GUIObjListHead = null THEN STOP

'..Initialise tool bar button text array.
InitToolBarButtonText

'..Initialise main window cross-hair mouse pointer.
InitCrossHairPointerData

'..Set up initial project.
wdwID = 9
wdw_x1 = 170 : wdw_y1 = 50 : old_wdw_x1 = wdw_x1 : old_wdw_y1 = wdw_y1
wdw_x2 = 470 : wdw_y2 = 175
gadCount = 0
toolBarActive = false : finished = false

CreateWindow
SetupMenus

'..Activate event trapping.
ON MENU GOSUB handle_menu : MENU ON
ON GADGET GOSUB handle_gadget : GADGET ON
ON WINDOW GOSUB handle_window : WINDOW ON
ON MOUSE GOSUB handle_mouse : MOUSE ON

'..Await events.
WHILE NOT finished
  SetCurrWdw
  SLEEP FOR .02
WEND

'..Deactivate event trapping.
MENU OFF : GADGET OFF : WINDOW OFF : MOUSE OFF

'..Clean up.
CloseProject
IF toolBarActive THEN CALL ToggleToolBar
CLEAR ALLOC
STOP

{*
** Event handlers.
*}

{* Menu handler *}
handle_menu:
  theMenu = MENU(0)
  theItem = MENU(1)

  '..Project menu?
  IF theMenu = mProject THEN
    CASE
	theItem = iNew	   : NewProject
	theItem = iOpen    : OpenProject
	theItem = iSave    : SaveProject
	theItem = iSaveAs  : SaveAs
	theItem = iToolBar : ToggleToolBar
	theItem = iAbout   : MsgBox "ReqEd v1.12, by David J Benn","Continue"
	theItem = iQuit	   : QuitProgram
    END CASE
    RETURN
  END IF

  '..Window menu?
  IF theMenu = mWindow THEN
    CASE 
      theItem = iRedraw : WINDOW OUTPUT wdwID:CLS:RedrawGUIObjects
      theItem = iPreview : PreviewRequester    
      default : IF theItem <> 0 THEN CALL ModifyWindow(theItem)
    END CASE
    RETURN
  END IF  

'..No menu.
RETURN

{* Window (close-gadget) handler *}
handle_window:
  IF WINDOW(0) = toolWdw THEN CALL ToggleToolBar
RETURN

{* Gadget handler (for Tool Bar) *}
handle_gadget:
  theGadget = GADGET(1) 

  CASE
    theGadget = gButton      : boxStyle = RAISED
    theGadget = gString      : boxStyle = STRGAD
    theGadget = gLongInt     : boxStyle = STRGAD
    theGadget = gPotX  	     : boxStyle = RAISED
    theGadget = gPotY 	     : boxStyle = RAISED
    theGadget = gText 	     : boxStyle = NORMAL
    theGadget = gRaisedBox   : boxStyle = RAISED
    theGadget = gRecessedBox : boxStyle = RECESSED
  END CASE

  CreateGUIObj(theGadget, boxStyle)
RETURN

{* Mouse-handler (left mouse-button click) *}
handle_mouse:
ADDRESS theObject
SHORTINT edge
  IF WINDOW(0) = wdwID THEN
    '..Get current mouse coordinates.
    mouseX = MOUSE(1) : mouseY = MOUSE(2)
    '..On a GUI object's border? If so, resize object from specified edge.
    theObject = OnGUIObjBorder(mouseX, mouseY, @edge)
    IF theObject <> null THEN
	ResizeGUIObj(theObject, edge) 
    ELSE
    	'..Within a GUI object's bounds?
    	theObject = InsideGUIObj(mouseX, mouseY)
    	IF theObject <> null THEN
      	  '..Show the object as being selected.
      	  SelectGUIObj(theObject)
          theKey$ = INKEY$
      	  CASE
	    theKey$ = CHR$(DEL_key) OR theKey$ = CHR$(BKSPC_key) : DeleteGUIObj(theObject)
            theKey$ = CHR$(ENTER_key) : ModifyGUIObjVal(theObject)
            default : MoveGUIObj(theObject)
          END CASE	
        END IF
    END IF
  END IF
RETURN

END
