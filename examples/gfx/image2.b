{*
** An example of the use of Intuition Images in ACE.
** Image data taken from "Inside Amiga Graphics", p 182-184.
**
** Author: David J Benn
**   Date: 6th,7th November 1994
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
CONST manDataItems = 34, balloonDataItems = 44

LIBRARY "intuition.library"
DECLARE FUNCTION DrawImage(rastPort&, theImage&, left&, top&) LIBRARY intuition

DECLARE STRUCT Image manImage, balloonImage
ADDRESS man_image_addr, balloon_image_addr

'..manDataItems short words of CHIP RAM.
man_image_addr = ALLOC(manDataItems*SIZEOF(SHORTINT),0)  
IF man_image_addr = NULL THEN STOP
DIM man_image_data%(manDataItems) ADDRESS man_image_addr
FOR i%=0 TO manDataItems-1
  READ man_image_data%(i%)
NEXT
{*
** 2 bitplanes worth of data (14 x 17 bits x 2 bitplanes).
*}
'..FIRST BIT PLANE.
DATA &H0FC0,&H3FF0,&H3330,&H3330,&H3FF0,&H3FC0,&H0FC0,&H0300,&HFFFC,&HFFFC
DATA &H0FC0,&H0FC0,&H3FF0,&H3CF0,&H3CF0,&HFCFC,&HFCFC
'..SECOND BIT PLANE.
DATA &H0000,&H0000,&H0CC0,&H0CC0,&H0000,&H0300,&H0000,&H0000,&H0000,&H0000
DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000

manImage->LeftEdge 	= 0
manImage->TopEdge 	= 12
manImage->xWidth 	= 14
manImage->Height 	= manDataItems\2
manImage->Depth 	= 2
manImage->ImageData 	= @man_image_data%
manImage->PlanePick 	= 3
manImage->PlaneOnOff 	= 0
manImage->NextImage	= NULL

'..balloonDataItems short words of CHIP RAM.
balloon_image_addr = ALLOC(balloonDataItems*SIZEOF(SHORTINT),0)  
IF balloon_image_addr = NULL THEN STOP
DIM balloon_image_data%(balloonDataItems) ADDRESS balloon_image_addr
FOR i%=0 TO balloonDataItems-1
  READ balloon_image_data%(i%)
NEXT
{*
** 2 bitplanes worth of data (14 x 17 bits x 2 bitplanes).
*}
'..FIRST BIT PLANE.
DATA &H0F80,&H3FE0,&H7FF0,&H7FF0,&HFFF8,&HFFF8,&HFFF8,&H7FF0,&H7FF0,&H3FE0,&H0F80
DATA &H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000,&H0000
'..SECOND BIT PLANE.
DATA &H0F80,&H3FE0,&H7FF0,&H7FF0,&HFFF8,&HFFF8,&HFFF8,&H7FF0,&H7FF0,&H3FE0,&H0F80
DATA &H0200,&H0200,&H0200,&H0200,&H0200,&H0200,&H0200,&H0200,&H0200,&H0200,&H0200

balloonImage->LeftEdge 	= 8
balloonImage->TopEdge 	= 0
balloonImage->xWidth 	= 13
balloonImage->Height 	= balloonDataItems\2
balloonImage->Depth 	= 2
balloonImage->ImageData = @balloon_image_data%
balloonImage->PlanePick = 3
balloonImage->PlaneOnOff= 0
balloonImage->NextImage	= manImage

WINDOW 1,"A man and his balloon...",(0,0)-(320,200),10

DrawImage(WINDOW(8),balloonImage,140&,80&)

GADGET WAIT 0

WINDOW CLOSE 1
LIBRARY CLOSE
END
