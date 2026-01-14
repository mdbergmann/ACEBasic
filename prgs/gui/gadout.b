{* 
** Demonstrates use of Gadget Output 
** command to get gadget values.
**
** D Benn, 1995
*}

SUB Test
SHORTINT theGadget, n
  WINDOW 9,"",(170,50)-(470,175),10
  {* RENDER GADGETS, BEVEL-BOXES AND TEXT *}
  GADGET 255,ON,10,(89,59)-(203,72),POTX
  GADGET 254,ON,10,(242,22)-(259,97),POTY
  GADGET 253,ON,"Gimme",(21,89)-(90,108),BUTTON
  GADGET 252,ON,"Quit",(134,89)-(203,108),BUTTON
  GADGET 251,ON,"123",(90,33)-(216,45),LONGINT
  GADGET 250,ON,"One",(90,8)-(216,21),STRING
  {* GADGET HANDLING CODE STARTS HERE *}
  Repeat
    GADGET WAIT 0
    theGadget = GADGET(1)
    If theGadget = 253 Then
    	msg$ = ""
        Gadget Output 255
	msg$ = msg$ + "x: "+Str$(Gadget(3))
        Gadget Output 254
	msg$ = msg$ + "  y: "+Str$(Gadget(3))
        Gadget Output 251
   	n$ = Str$(Gadget(2))
	n$ = Right$(n$,Len(n$)-1)
	msg$ = msg$ + "  n: "+n$
        Gadget Output 250
	msg$ = msg$ + "  s: "+Cstr(Gadget(2))
	MsgBox msg$,"Ok"
    End If 
  Until theGadget = 256 Or theGadget = 252
  {* CLEAN UP *}
  FOR n=255 TO 250 STEP -1
    GADGET CLOSE n
  NEXT
  WINDOW CLOSE 9 
END SUB

Test
