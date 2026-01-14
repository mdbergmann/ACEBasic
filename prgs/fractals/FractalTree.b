' Realistic Fractal Trees
' By John Grillo
' Copyright 1985
' by MicroSPARC, Inc.
' (in Nibble Mac magazine, Jan/Feb 1986)
' Converted from MS Mac BASIC to ACE Amiga BASIC
' by David Benn, December 1994

DEFINT a-z : CONST n=1200
DIM a!(n), L(n)   'Branch angles AND lengths
DIM px(n), py(n)  'Branch END-points

RANDOMIZE TIMER

DECLARE SUB InitMenu

SCREEN 1,640,400,2,4
WINDOW 1,"Fractal Trees",(0,0)-(640,400),2,1

GOSUB StartVals
InitMenu

ON MENU GOSUB MenuEvent
MENU ON

Loop:
  IF Done=1 THEN Loop
  MENU 5,1,0
  MENU 5,2,1
  MENU 5,3,0
  n1=1 : n2=1 : k=1  'n1 is loop start, n2 is loop END, k is counter
  b=1  'number of branches from any given node
  a!(1)=1.57+(px(1)-256)/400  'a! is a branch's starting angle
  GOSUB DrawTrunk
  GOSUB DrawTree
  Done = 1
  MENU 5,1,1
  MENU 5,2,0
  MENU 5,3,1
GOTO Loop

MenuEvent:
  MenuId = MENU(0) : ItemId = MENU(1)
  IF MenuId=5 AND ItemId=1 THEN Done=0
  IF MenuId=5 AND ItemId=2 THEN Done=1 : RETURN
  IF MenuId=1 THEN px(1)=ItemId*100-50 : MaxItems = 5 : GOSUB ClrMenu
  IF MenuId=2 THEN an!=ItemId*.2+RND/10 : MaxItems = 3 : GOSUB ClrMenu
  IF MenuId=3 THEN pct!=1.25-.25*ItemId : MaxItems = 5 : GOSUB ClrMenu
  IF MenuId=4 AND ItemId=3 THEN fib!=.618 : MaxItems = 5 : GOSUB ClrMenu
  IF MenuId=4 AND ItemId<>3 THEN fib!=.1*ItemId+.3:MaxItems = 5:GOSUB ClrMenu
  IF MenuId=5 AND ItemId=4 THEN WINDOW CLOSE 1 : SCREEN CLOSE 1 : END
  IF MenuId=5 AND ItemId=3 THEN CLS
RETURN

StartVals:
  px(1)=320 : py(1)=240
  an!=.4+RND*.1
  L(1)=120
  MinLen=2  'No more growth IF length < MinLen
  fib!=.618 : thk=20 : pct!=.5
  Done=1
RETURN

DrawTrunk:
  LINE (320,400)-(px(1),py(1))
RETURN

DrawTree:
  n1=n2 : n2=k  'redefine start, END of loop
  IF n1=n2 AND k>1 THEN RETURN  'no limbs ON last pass
  IF k>2 THEN n1=n1+1  'skip repeats
  FOR i=n1 TO n2
    GOSUB DrawLimbs
    IF Done=1 THEN i=n2
  NEXT i
  IF k<N THEN DrawTree  'REPEAT this process UNTIL max # nodes
RETURN

DrawLimbs:
  IF i>n THEN Done=1 : RETURN
  IF L(i)<MinLen THEN RETURN  'don't draw branch ON smallest limbs
  FOR j=-b TO b  'set up loop FOR each limb at ith tip
    IF j<>0 OR RND>pct! THEN GOSUB DrawBranch
    IF Done=1 THEN j=b/2
  NEXT j
RETURN

DrawBranch:
 k=k+1 : rand!=an!*RND-an!/2
 IF k>n THEN RETURN  'More nodes than allowed
 a!(k)=a!(i)+j*an!+rand!  'Define angle FOR this branch. Notice that when
 			  'b is 2, j is -1, 0 or 1, so branch will go left,
			  'straight or right.
 L(k)=fib!*L(i)+rand!*thk  'define NEW length
 IF j=0 THEN L(k)=L(k)*(1+rand!)  'make center limb a bit longer
 px(k)=px(i)+INT(L(k)*COS(a!(k)))
 py(k)=py(i)-INT(L(k)*SIN(a!(k)))
 IF Done=1 THEN RETURN
 LINE (px(i),py(i))-(px(k),py(k))
RETURN

ClrMenu:
  FOR Item=1 TO MaxItems
    MENU MenuId,Item,1
  NEXT Item
  MENU MenuId,ItemId,2
RETURN

SUB InitMenu
  MENU 1,0,1,"  Position"
  MENU 1,1,1,"  Far left"
  MENU 1,2,1,"  Left"
  MENU 1,3,2,"  Center"
  MENU 1,4,1,"  Right"
  MENU 1,5,1,"  Far right"

  MENU 2,0,1,"  Angle"
  MENU 2,1,1,"  Small"
  MENU 2,2,2,"  Medium"
  MENU 2,3,1,"  Large"

  MENU 3,0,1,"  Center br."
  MENU 3,1,1,"  None"
  MENU 3,2,1,"  Occasional"
  MENU 3,3,2,"  Moderate"
  MENU 3,4,1,"  Frequent"
  MENU 3,5,1,"  Always"

  MENU 4,0,1,"  Length"
  MENU 4,1,1,"  .4"
  MENU 4,2,1,"  .5"
  MENU 4,3,2,"  .618"
  MENU 4,4,1,"  .7"
  MENU 4,5,1,"  .8"

  MENU 5,0,1,"Trees"
  MENU 5,1,1,"Draw tree"
  MENU 5,2,0,"Stop drawing"
  MENU 5,3,1,"Clear screen"
  MENU 5,4,1,"Quit","Q"
END SUB
