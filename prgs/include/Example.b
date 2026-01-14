#include <Petr.h>

screen 1,640,256,2,2  
window 1,,(0,0)-(640,256),32,1
 palette 0,0,0.2,0
 palette 1,1,1,1
 palette 2,.2,0,1
 palette 3,.8,.4,0

font "topaz",8	'..(This helps for the purposes of the demo. DB)

locate 5,5
prints " Include `mys`, press left mouse button"
Mys
locate 15,10
prints "Pressed left mouse button at position ";m.a;",";m.b

waitmouse
pause(5)
CLS

box(100,540,50,150,3,1)
locate 12,20
prints " This is made by include `BOX` "
waitmouse
pause(5)

color 2,3
CLS

gline(10,10,22,0)
prints " Include `Gline` up"
gline(15,10,22,1)
prints " Include `Gline` down"
waitmouse

Again:
color 1,2
CLS
locate 5,10
prints "Input by include in$"

a$=in$(10,10," Insert any numeric value : ","123.456",8)
locate 12,10
prints " Inserted : ";a$
locate 15,10
prints " Include`s `Using` output of given value is ";Using$("#####.##",Val(NoSpace$(a$)),1)
waitmouse
CLS

locate 3,5
prints " Include GAD used with include box : "


    box(130,470,75,140,2,1)
    box(150,450,85,130,3,0)
    color 1,3
    LOCATE 13,22
    PrintS "Do you want to try in$ again ?"
    t$(1)="yes"
    t$(2)="no"
    tg%(1,1)=15%
    tg%(1,2)=25%
    tg%(1,3)=5%
    tg%(2,1)=15%
    tg%(2,2)=47%
    tg%(2,3)=4%
   tg%(3,3)=0%
  i=GAD%
if i= 1 then again

color 1,0
cls
locate 10,10
prints "so bye, be happy"
locate 24,50
prints "Oh - that is include waitmouse"
waitmouse
window close 1
screen close 1
END
