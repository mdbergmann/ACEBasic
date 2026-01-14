'..**************************************************************
'..* A demo of the FOUR (yes 4!) ways to handle gadgets in ACE: *
'..* WAIT for any gadget; WAIT for one gadget; event trapping;  *
'..* polling for gadgets. The first and second are the nicest 	*
'..* operating-system-wise. 					*
'..* 		   						*
'..* Remove ONE set of curly brackets to use a method.          *
'..* (Method #1 is already uncommented).                        *
'..**************************************************************

'..When polling for gadgets or using event trapping (methods #3 and #4), 
'..comment the next line out to avoid conflict.

OPTION w+	'..Define window close-gadget trapping too.

'..set up some gadgets
window 1,"Gadgets",(0,0)-(640,200),31

gadget 1,ON,"12345",(10,75)-(200,88),STRING		'..string

gadget 2,ON,50,(420,160)-(510,168),POTX			'..horizontal slider

gadget 3,ON,25,(505,100)-(520,150),POTY			'..vertical slider

gadget 4,ON,"Quit",(110,165)-(190,181),BUTTON 		'..boolean

gadget 5,ON,"Move",(115,140)-(185,156),BUTTON		'..boolean


'..handle gadgets in one of 4 ways!

'..await any gadget!			METHOD #1
WHILE -1
  gadget wait 0
  gosub handle_gad
WEND

{'..await gadgets 1 and 4 in turn	METHOD #2
gadget wait 1
gosub handle_gad
gadget wait 4
goto quit}

{'..gadget event trapping		METHOD #3
ON GADGET GOSUB handle_gad
GADGET ON

ON WINDOW GOTO quit			'..this will compete with OPTION w+
WINDOW ON

while -1
  sleep
wend}

'..poll gadgets			METHOD #4
while -1
  while not gadget(0)
    sleep
  wend
  gosub handle_gad
wend

'..general purpose gadget handling routine
handle_gad:
  gad = gadget(1)
  if gad=4 then if MsgBox("Are you sure?","Yes","No Way!") then quit  
  if gad=5 then 
    gadget mod 2,25
    gadget mod 3,25
    return
  end if
  locate 5,1:print "gadget:";gad
  if gad<5 then
    locate gad,1
    print gad;"-->> ";
    if gad=2 or gad=3 then
      print gadget(3);chr$(8);"    "
    else
      print CSTR(gadget(2))
    end if
  end if
return

'..cleanup!
quit:
gadget close 5
gadget close 4
gadget close 3
gadget close 2
gadget close 1

window close 1

END
