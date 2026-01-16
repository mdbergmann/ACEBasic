{*
** An example of the use of Intuition Images in ACE.
**
** Author: David J Benn
**   Date: 6th November 1994
*}

STRUCT Image
  SHORTINT LeftEdge
  SHORTINT TopEdge
  SHORTINT xWidth	'..Width is a reserved word.
  SHORTINT Height
  SHORTINT Depth	
  ADDRESS  ImageData
  BYTE 	   PlanePick
  BYTE	   PlaneOnOff
  ADDRESS  NextImage	'..Pointer to next Image structure.
END STRUCT

CONST NULL = 0&
CONST iHeight = 22

LIBRARY "intuition.library"
DECLARE FUNCTION DrawImage(rastPort&, theImage&, left&, top&) LIBRARY intuition

DECLARE STRUCT Image theImage
ADDRESS image_addr

image_addr = ALLOC(iHeight*SIZEOF(SHORTINT),0)  '..iHeight short words of CHIP RAM.
IF image_addr = NULL THEN STOP
DIM image_data%(iHeight) ADDRESS image_addr
FOR i%=0 TO iHeight-1
  READ image_data%(i%)
NEXT
'..2 bitplanes worth of data (16 x 11 bits x 2 bitplanes).
DATA &H3C0,&H3C0,&H3C0,&H3C0,&HFFFF,&HFFFF,&HFFFF,&H3C0,&H3C0,&H3C0,&H3C0
DATA &H3C0,&H3C0,&H3C0,&H3C0,&HFFFF,&HFFFF,&HFFFF,&H3C0,&H3C0,&H3C0,&H3C0

theImage->LeftEdge 	= 0
theImage->TopEdge 	= 0
theImage->xWidth 	= 16
theImage->Height 	= iHeight\2
theImage->Depth 	= 2
theImage->ImageData 	= @image_data%	'..Could use image_addr here.
theImage->PlaneOnOff 	= 0
theImage->NextImage	= NULL

SCREEN 1,640,200,2,2
WINDOW 1,,(0,0)-(640,200),32,1

theImage->PlanePick 	= 1
DrawImage(WINDOW(8),theImage,270&,110&)

theImage->PlanePick 	= 2
DrawImage(WINDOW(8),theImage,290&,110&)

theImage->PlanePick 	= 3
DrawImage(WINDOW(8),theImage,310&,110&)

WHILE INKEY$="" AND NOT MOUSE(0):SLEEP:WEND

WINDOW CLOSE 1
SCREEN CLOSE 1
LIBRARY CLOSE
END
