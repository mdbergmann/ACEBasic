{* 
** Demonstration of String Gadget Activation.
** ReqEd was used for the window design.
**
** Author: David J Benn
**   Date: 22nd October 1995
*}

Declare Function ActivateGadget(gad&,wdw&,req&) Library intuition

CONST NULL = 0&
CONST close_wdw = 256
CONST button_next = 252

SUB NextStringGad(ADDRESS wdw, SHORTINT theGadget)
ADDRESS gad
  Gadget Output theGadget
  gad = Gadget(4)
  If gad <> NULL Then Call ActivateGadget(gad,wdw,NULL)
END SUB

SUB MyReq
SHORTINT theGadget, n, gadgetID
  WINDOW 9,,(170,50)-(464,226),8
  {* RENDER GADGETS, BEVEL-BOXES AND TEXT *}
  GADGET 255,ON,"One",(79,22)-(220,36),STRING
  GADGET 254,ON,"Two",(79,55)-(220,69),STRING
  GADGET 253,ON,"Three",(79,88)-(220,102),STRING
  BEVELBOX (11,7)-(275,155),1
  GADGET 252,ON,"Next",(113,125)-(170,144),BUTTON
  {* GADGET HANDLING CODE STARTS HERE *}
  gadgetID = 255
  REPEAT
    GADGET WAIT 0
    theGadget = GADGET(1)
    IF theGadget = button_next THEN 
 	NextStringGad(WINDOW(7),gadgetID)
      	--gadgetID
   	IF gadgetID = 252 THEN gadgetID = 255
    END IF
  UNTIL theGadget = close_wdw
  {* CLEAN UP *}
  FOR n=255 TO 252 STEP -1
    GADGET CLOSE n
  NEXT
  WINDOW CLOSE 9 
END SUB

MyReq
