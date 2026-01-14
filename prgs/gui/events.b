window 1,"Events",(0,0)-(500,150)

menu 1,0,1,"Project"
menu 1,1,1,"New"
menu 1,2,1,"Open"
menu 1,3,1,"Quit","Q"

gadget 1,ON,"Quit",(100,100)-(150,116),BUTTON

on menu gosub menu_handler
on gadget gosub gadget_handler
on window gosub quit
on break gosub quit
on mouse gosub handle_mouse
on timer(1) gosub timer_handler
 
menu on
gadget on
window on
break on
mouse on
timer on

while -1
  SLEEP
  k$ = inkey$
  if k$<>"" then print k$
wend


'..trap handlers
menu_handler:
  x=menu(0) : y=menu(1)
  locate 1,1:print x,y
  if x=1 and y=3 then quit
return

gadget_handler:
  locate 2,1:print gadget(1)
  goto quit
return

timer_handler:
  beep
return

handle_mouse:
  row=csrlin:col=pos
  locate 2,40
  print "                ";
  locate 2,40
  print "Mouse:";mouse(1);mouse(2)
  locate row,col
return

quit:
  if not MsgBox("Really Quit?","YES","NO!") then RETURN
  menu clear
  gadget close 1
  window close 1
end
