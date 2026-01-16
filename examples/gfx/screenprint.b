REM  ScreenPrint
REM  Carolyn Scheppner   CBM  04/86
REM
REM  Graphic screen dump to the printer
REM   using exec library calls
REM  Requires exec.bmap
REM  Use Preferences to select options
REM   such as GrayScale and Negative

REM  ***  Calling Program  ***

REM  Custom Screen, some graphics
w = 320: h = 200: d = 5
SCREEN 1,w,h,d,1
t$=" D = Draw   P = Print   Q = Quit "
WINDOW 1,t$,(0,0)-(320,200),7,1
PALETTE 0,1,1,1
PALETTE 1,.2,.4,.8

GOSUB DrawLines:

MainLoop:
k$ = INKEY$
IF k$ = "d" THEN 
   GOSUB DrawLines:
ELSE
  IF k$ = "p" THEN
   BorderFlag% = 0  'No borders printed
   GOSUB ScreenDump
   BEEP  '..signal that we're done
   REM  Time to read any error msgs
   FOR de = 1 TO 5000: NEXT
  ELSE
    IF k$ = "q" THEN Quit
  END IF
END IF
GOTO MainLoop

Quit:
WINDOW CLOSE 1
SCREEN CLOSE 1
END

DrawLines:
CLS               
RANDOMIZE  TIMER
FOR k = 1 TO 12
   x1 = 80 + INT(RND(1) * (w - 160)) 
   x2 = 80 + INT(RND(1) * (w - 160))
   y1 = 40 + INT(RND(1) * (h - 100))
   y2 = 40 + INT(RND(1) * (h - 100))
   dx = 2 + INT(RND(1) * 3)
   IF RND(1) < .5 THEN dx = -dx
   dy = 2 + INT(RND(1) * 2)
   IF RND(1) < .5 THEN dy = -dy
   co = 1 + INT(RND(1) * 16)
   nl = 12 + INT(RND(1) * 10) 
   FOR j = 1 TO nl
      LINE (x1,y1)-(x2,y2),co
      x1 = x1 + dx
      x2 = x2 + dx
      y1 = y1 + dy
      y2 = y2 - dy
   NEXT
NEXT
RETURN
END

ScreenDump:

REM  If first call of this routine 
REM   declare the exec library functions
REM    which return values

LIBRARY "exec.library"

DECLARE FUNCTION AllocSignal%() LIBRARY
DECLARE FUNCTION AllocMem&()    LIBRARY
DECLARE FUNCTION FindTask&()    LIBRARY
DECLARE FUNCTION DoIO&()        LIBRARY
DECLARE FUNCTION OpenDevice&()  LIBRARY
DECLARE FUNCTION CloseDevice()  LIBRARY
DECLARE FUNCTION FreeMem()      LIBRARY
DECLARE FUNCTION FreeSignal()   LIBRARY
DECLARE FUNCTION AddPort()      LIBRARY
DECLARE FUNCTION RemPort()      LIBRARY

REM  Get addresses of the structures

sWindow&   = WINDOW(7)
sScreen&   = PEEKL(sWindow& + 46)
sViewPort& = sScreen& + 44
sRastPort& = sScreen& + 84
sColorMap& = PEEKL(sViewPort& + 4)

REM  Get Screen width, height, modes 

maxWidth%  = PEEKW(sScreen& + 12)
maxHeight% = PEEKW(sScreen& + 14)
viewModes% = PEEKW(sViewPort& + 32)

REM Set up parameters for dump command

command%  = 11   'Printer command number
srcX% = 0        'Send whole screen
srcY% = 0 
srcWidth%  = maxWidth%
srcHeight% = maxHeight%
destRows& = 0    'Dump will compute
destCols& = 0
special% = &H84  'FullCol | Aspect

IF BorderFlag% = 0 THEN  'No Borders
   srcX% = srcX% + 3
   srcY% = srcY% + 11
   srcWidth%  = srcWidth% - 3 - 11
   srcHeight% = srcHeight% - 11 - 3
END IF   

REM *** CreatePort ***

sigBit% =  AllocSignal%(-1)
ClearPublic& = 65537&
msgPort& = AllocMem&(40,ClearPublic&)
IF msgPort& = 0 THEN
   PRINT "Can't allocate msgPort"
   GOTO cleanup4
END IF

POKE(msgPort& + 8), 4 'Type=NT_MSGPORT
POKE(msgPort& + 9), 0 'Priority 0 
portName$ = "MyPrtPort"+CHR$(0)
POKEL(msgPort& + 10), SADD(portName$)
POKE(msgPort& + 14), 0 'Flags
POKE(msgPort& + 15), sigBit%
sigTask& = FindTask&(0)
POKEL(msgPort& + 16), sigTask&

CALL AddPort(msgPort&)  'Add the port 

REM  *** CreatExtIO ***

ioRequest& = AllocMem&(64,ClearPublic&)
IF ioRequest& = 0  THEN
   PRINT "Can't allocate ioRequest"
   GOTO cleanup3
END IF

POKE(ioRequest& + 8),5 'Type=NT_MESSAGE
POKE(ioRequest& + 9),0 'Priority 0
POKEL(ioRequest& + 14), msgPort&


REM  *** Open the Printer Device ***

devName$ = "printer.device"+CHR$(0)
pError& = OpenDevice&(SADD(devName$),0,ioRequest&,0)
'pError& = OpenDevice&(devName$,0,ioRequest&,0)
IF pError& <> 0  THEN
   PRINT "Can't open printer"
   GOTO cleanup2
END IF

REM  *** Dump the RastPort ***

POKEW(ioRequest& + 28), command%
POKEL(ioRequest& + 32), sRastPort&
POKEL(ioRequest& + 36), sColorMap&
POKEL(ioRequest& + 40), viewModes%
POKEW(ioRequest& + 44), srcX%
POKEW(ioRequest& + 46), srcY%
POKEW(ioRequest& + 48), srcWidth%
POKEW(ioRequest& + 50), srcHeight%
POKEL(ioRequest& + 52), destCols&
POKEL(ioRequest& + 56), destRows&
POKEW(ioRequest& + 60), special%

ioError& = DoIO&(ioRequest&)
IF ioError& <> 0 THEN
   PRINT "DumpRPort error =" ioError&
   GOTO cleanup1
END IF

cleanup1:
   REM  *** Close Printer Device ***
   CALL CloseDevice(ioRequest&)

cleanup2:
   REM  *** DeleteExtIO ***
   POKE(ioRequest& + 8), &HFF
   POKEL(ioRequest& + 20), -1
   POKEL(ioRequest& + 24), -1
   CALL FreeMem(ioRequest&,64)

cleanup3:
   REM  *** DeletePort ***
   CALL RemPort(msgPort&)
   POKE(msgPort& + 8), &HFF  
   POKEL(msgPort& + 20), -1
   CALL FreeSignal(sigBit%)
   CALL FreeMem(msgPort&,40)
   
cleanup4:   
   LIBRARY CLOSE

RETURN
