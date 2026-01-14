{*
** Simple sprite demo - Inside Amiga Graphics, p 197,198.
** Adapted from C to ACE BASIC, 1st Dec 1994 by David Benn.
*}

CONST NULL = 0&
CONST elements = 32

STRUCT SimpleSprite
  ADDRESS  posctldata
  SHORTINT height
  SHORTINT x
  SHORTINT y
  SHORTINT num
END STRUCT

DECLARE STRUCT SimpleSprite Sprite

'..Allocate CHIP RAM for sprite data array.
ADDRESS dataAddress
dataAddress = ALLOC(elements*SIZEOF(SHORTINT), 0)
IF dataAddress = NULL THEN STOP
DIM SHORTINT spriteData(elements) ADDRESS dataAddress

'..Read sprite data into array.
SHORTINT i
FOR i=0 TO elements-1
  READ spriteData(i)
NEXT

'..Sprite data.
DATA 0,0

DATA &HFFFF,&HFFFF
DATA &HFFFF,&HFFFF

DATA &HC003,&HCE73
DATA &HC003,&HCE73

DATA &HFF8F,&HC073
DATA &HFF8F,&HC073

DATA &HC003,&HCE73
DATA &HC003,&HCE73

DATA &HF1FF,&HCE03
DATA &HF1FF,&HCE03

DATA &HC003,&HCE73
DATA &HC003,&HCE73

DATA &HFFFF,&HFFFF
DATA &HFFFF,&HFFFF

'..End of sprite data.
DATA 0,0

{*
** Main.
*}
LIBRARY "graphics.library"

DECLARE FUNCTION LONGINT GetSprite() LIBRARY
DECLARE FUNCTION FreeSprite() LIBRARY
DECLARE FUNCTION ChangeSprite() LIBRARY
DECLARE FUNCTION MoveSprite() LIBRARY
DECLARE FUNCTION WaitBOVP() LIBRARY

ADDRESS  WVP		'..viewport
SHORTINT spgot		'..sprite number
SHORTINT n

SCREEN 1,640,200,3,2
WINDOW 1,"Simple Sprite",(0,0)-(640,200),8,1

WVP = SCREEN(3)

'..Allocate sprite #3.
spgot = GetSprite(Sprite,3)
IF spgot <> 3 THEN STOP

'..Set sprite height and initial position.
Sprite->x = 20
Sprite->y = 10
Sprite->height = 14

'..Set sprite's colors.
PALETTE 21,.8,.2,.53
PALETTE 22,.2,.87,.27
PALETTE 23,.8,.67,.27

'..Set up our sprite.
ChangeSprite(WVP,Sprite,@spriteData)

'..Move sprite from top-left.
FOR n=10 TO 100
  WaitBOVP(WVP)
  MoveSprite(WVP,Sprite,n*3,n)
  SLEEP FOR .025
NEXT

GADGET WAIT 0

FreeSprite(spgot)
WINDOW CLOSE 1
SCREEN CLOSE 1

END
