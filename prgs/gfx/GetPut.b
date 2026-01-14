{* 
** Simple copy and paste of rastport sections.
**
** This is _like_ BASIC's GET and PUT commands 
** but less data is kept (ie. positional not bitmap
** data).
**
** Author: David J Benn
**   Date: 10th-11th November 1994
*}

CONST default = -1&

LIBRARY "graphics.library"

DECLARE FUNCTION ClipBlit() LIBRARY graphics

STRUCT source_info
  ADDRESS SrcRp
  SHORTINT SrcX
  SHORTINT SrcY
  SHORTINT XSize
  SHORTINT YSize
END STRUCT

SUB GetIt(x1&, y1&, x2&, y2&, ADDRESS info_addr)
DECLARE STRUCT source_info *info
{* 
** Store data needed for PUT operation.
*} 
  info = info_addr

  info->SrcRp 	= WINDOW(8)   		'..source rastport
  info->SrcX 	= x1&	   		'..left
  info->SrcY 	= y1&	   		'..top
  info->XSize 	= ABS(x2&-x1&)+1 	'..width
  info->YSize 	= ABS(y2&-y1&)+1 	'..height
END SUB

SUB PutIt(SHORTINT DestX, SHORTINT DestY, ADDRESS info_addr)
DECLARE STRUCT source_info *info
{* 
** PUT image from source rastport to destination rastport.
*}
CONST Minterm = &HC0
ADDRESS DestRp

  info = info_addr

  DestRp = WINDOW(8)

  ClipBlit(info->SrcRp, info->SrcX, info->SrcY, ~
	   DestRp, DestX, DestY, info->XSize, info->YSize, ~
	   Minterm)
END SUB


{* Main *}
DECLARE STRUCT source_info src

WINDOW 1,"Source",(0,0)-(320,150),2

LINE (10,10)-(125,125),2,b	'..Draw a rectangle.
PAINT (100,100),1,2		'..Fill it.

GetIt(10,10,125,125,src)	'..Prepare to copy it.

WINDOW 2,"Destination",(320,25)-(640,200),10

PutIt(20,20,src)		'..Copy & paste from source
				'..into current output window
				'..with an x,y offset.

'..Wait for window 2's close gadget to be clicked.
GADGET WAIT 0	

WINDOW CLOSE 2
WINDOW CLOSE 1

END
