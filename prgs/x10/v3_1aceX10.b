'************************************************************
'* PROGRAM BY PETER ZIELINSKI (02)519-6352 SYDNEY NSW AUST. *
'*               FOR THE X-10 HOME CONTROLER.               *
'*                   VER 3.1 for A.C.E.                     *
'*         PLEASE REF. TO PROGRAMMING GUIDE BOOK            *
'*               SUPPLIED WITH THE X-10.                    *
'************************************************************
version$ = "$VER: V3.1 X10 (8.12.94) by Peter Zielinski"
' SAME AS 3.0 BUT ADDED HOUSE CODE DOWNLOAD
if SYSTEM < 37 then reply=MsgBox("Need Wb 2.04 or higher.","OK"):END
DEFINT a-z
CONST	 buffer_size=1024&

STRING   param$, buffer, bufferp, parity, data_bits, stop_bits, wires, Xon, share, fast,ux$
LONGINT  baud,unit,unitx,chars

Mp=0
'..create a port for this program called "reader"
message open #1,"X10Port","r"
if err=400 then 
  goto Cot
end if
message clear #1
Mp=1

Cot:
SUB Ser_x
shared unit,baud,param$ 
  serial open 1,unit,baud,param$,5000
  open "O",1,"X10_3.cnf"
  write #1,unit,255
  close 1
END SUB

SUB about_box
  x$="Written in ACE by Peter Zielinski for X10 Ver 3.1 "+CHR$(169)+" 1994"
  dummy = MsgBox(x$,"OK")
END SUB
  unitx=0
  unit=0
  baud=600
  parity="N"
  data_bits="8"
  stop_bits="1"  
  wires="3" '7 or 3
  Xon="?"  'X or ?
  share="S" 'S or ?
  fast="?" 'F or ?
  param$ = parity+data_bits+stop_bits+wires+Xon+share+fast

  open "I",#1,"X10_3.cnf"
  input #1,unit,unitx
  close #1
  if unitx<255 then 
    gosub Ser
  else 
    serial open 1,unit,baud,param$,5000
  end if

 palette 4,0.93,0.20,0 'red
 palette 5,0.33,0.87,0 'green

 DIM HCODE(16)
 DIM UCODE(8)
 DIM JDATA(6)
 UCODE(1)=128:UCODE(2)=64:UCODE(3)=32:UCODE(4)=16
 UCODE(5)=8:UCODE(6)=4:UCODE(7)=2:UCODE(8)=1
 HCODE(1)=96:HCODE(2)=224:HCODE(3)=32:HCODE(4)=160
 HCODE(5)=16:HCODE(6)=144:HCODE(7)=80:HCODE(8)=208
 HCODE(9)=112:HCODE(10)=240:HCODE(11)=48:HCODE(12)=176
 HCODE(13)=0:HCODE(14)=128:HCODE(15)=64:HCODE(16)=192

'..set up some gadgets and window
if Mp=0 then window 1,"X10 by P.J.Zielinski",(0,0)-(482,248),14
if MP=1 then window 1,"X10 by P.J.Zielinski with MessagePort Named (X10Port) ",(0,0)-(482,248),14
BEVELBOX (3,3)-(470,230),1
FONT "topaz",8
U=1:HC=1:L=7:DIM J(12)
unitz=unit
if unitz=0 then unitz=1
locate 2,5:print "House Code" 
gadget 1,1,16,(20,22)-(120,32),4	'..horizontal slider
locate 4,16:print " ";CHR$(HC+64) 
locate 6,5:print "Unit Code" 
gadget 2,1,16,(20,55)-(120,65),4	'..horizontal slider
locate 8,16:print U;chr$(8);"  " 	
locate 10,5:print "Dim Level"
locate 14,2:print "MIN<-      ->MAX" 
gadget 3,1,15,(20,85)-(120,95),4        '..horizontal slider
gadget mod 3,8	                        '..set slider to half way 
locate 12,16:print L+1;chr$(8);"  " 
gadget 4,1,"On",(20,120)-(70,140),1 	'..boolean
gadget 5,1,"Off",(71,120)-(118,140),1 	'..boolean
gadget 6,1,"About",(20,141)-(70,161),1 	'..boolean
gadget 7,1,"Dim",(71,141)-(118,161),1 	'..boolean
gadget 8,1,"Serial Port",(20,162)-(118,182),1 '..boolean
gadget 9,1,"Quit",(20,183)-(118,203),1  '..boolean
gadget 10,1,"1",(190,50)-(210,70),1 	'..boolean
gadget 11,1,"1",(190,73)-(210,93),1 	'..boolean
gadget 12,1,"2",(220,50)-(240,70),1 	'..boolean
gadget 13,1,"2",(220,73)-(240,93),1 	'..boolean
gadget 14,1,"3",(250,50)-(270,70),1 	'..boolean
gadget 15,1,"3",(250,73)-(270,93),1 	'..boolean
gadget 16,1,"4",(280,50)-(300,70),1 	'..boolean
gadget 17,1,"4",(280,73)-(300,93),1 	'..boolean
gadget 18,1,"5",(190,115)-(210,135),1   '..boolean
gadget 19,1,"5",(190,138)-(210,158),1 	'..boolean
gadget 20,1,"6",(220,115)-(240,135),1 	'..boolean
gadget 21,1,"6",(220,138)-(240,158),1 	'..boolean
gadget 22,1,"7",(250,115)-(270,135),1 	'..boolean
gadget 23,1,"7",(250,138)-(270,158),1 	'..boolean
gadget 24,1,"8",(280,115)-(300,135),1 	'..boolean
gadget 25,1,"8",(280,138)-(300,158),1 	'..boolean
gadget 26,1,"09",(320,50)-(340,70),1 	'..boolean
gadget 27,1,"09",(320,73)-(340,93),1 	'..boolean
gadget 28,1,"10",(350,50)-(370,70),1 	'..boolean
gadget 29,1,"10",(350,73)-(370,93),1 	'..boolean
gadget 30,1,"11",(380,50)-(400,70),1 	'..boolean
gadget 31,1,"11",(380,73)-(400,93),1 	'..boolean
gadget 32,1,"12",(410,50)-(430,70),1 	'..boolean
gadget 33,1,"12",(410,73)-(430,93),1 	'..boolean
gadget 34,1,"13",(320,115)-(340,135),1  '..boolean
gadget 35,1,"13",(320,138)-(340,158),1	'..boolean
gadget 36,1,"14",(350,115)-(370,135),1	'..boolean
gadget 37,1,"14",(350,138)-(370,158),1	'..boolean
gadget 38,1,"15",(380,115)-(400,135),1	'..boolean
gadget 39,1,"15",(380,138)-(400,158),1	'..boolean
gadget 40,1,"16",(410,115)-(430,135),1  '..boolean
gadget 41,1,"16",(410,138)-(430,158),1	'..boolean
gadget 42,1,"D/load H/CODE",(140,22)-(250,33),1'..boolean

LOCATE 8,21:PRINT "ON"
LOCATE 11,21:PRINT "OFF"
LOCATE 16,21:PRINT "ON"
LOCATE 19,21:PRINT "OFF"
LOCATE 8,56:PRINT "ON"
LOCATE 11,56:PRINT "OFF"
LOCATE 16,56:PRINT "ON"
LOCATE 19,56:PRINT "OFF"
LOCATE 3,33:PRINT " X10 CONTROL"
LOCATE 4,33:PRINT " Port # ";unitz
LOCATE 3,51:color 1,5:PRINT "    ":color 1,0 
LINE (220,190)-(400,225),,B
LOCATE 24,36:PRINT "STATUS"
LOCATE 22,24:PRINT "RESPONSE"
LINE (135,170)-(177,225),,B
LOCATE 23,18:PRINT " ???"
LOCATE 24,18:PRINT " ???"
LOCATE 25,18:PRINT " ???"
LOCATE 26,18:PRINT " ???"
LOCATE 27,18:PRINT " ???"

on gadget gosub handle_gad
on mouse gosub handle_mouse

on window goto quit
window on

window output 1
gosub SETIME

gadget on
mouse on
{* main loop *}
finished = 0
while not finished
   mouse stop
   window output 1
   locate 15,2:print "               " 
   LOCATE 27,6:PRINT TIME$;
   if Mp=1 then GOSUB Mport
   gosub LOOKx
   mouse on 
   sleep for .05
wend
goto quit
end

'..general purpose gadget handling routine
handle_gad:
  gad = gadget(1)
     if gad=42 then                    'D/LOAD H/CODE gadget
        I=0:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "D/L" 
        A=HCODE(HC):C=0:D=0
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=41 then                    'unit 16 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=1:D=0
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=40 then                    'unit 16 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=1:D=0 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=39 then                    'unit 15 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=2:D=0
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=38 then                    'unit 15 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=2:D=0 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=37 then                    'unit 14 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=4:D=0
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=36 then                    'unit 14 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=4:D=4 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=35 then                    'unit 13 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=8:D=0
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=34 then                    'unit 13 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=8:D=0 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=33 then                    'unit 12 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=16:D=0
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=32 then                    'unit 12 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=16:D=0 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=31 then                    'unit 11 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=32:D=0
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=30 then                    'unit 11 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=32:D=0
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=29 then                    'unit 10 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=64:D=0
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=28 then                    'unit 10 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=64:D=0 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=27 then                    'unit 9 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF"        
        C=128:D=0
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=26 then                    'unit 9 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=128:D=0 
        gosub SENDIT
        locate 14,8:print "   "
    end if

     if gad=25 then                    'unit 8 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=0:D=1
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=24 then                    'unit 8 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=0:D=1 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=23 then                    'unit 7 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=0:D=2
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=22 then                    'unit 7 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=0:D=2 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=21 then                    'unit 6 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=0:D=4
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=20 then                    'unit 6 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=0:D=4 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=19 then                    'unit 5 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=0:D=8
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=18 then                    'unit 5 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=0:D=8 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=17 then                    'unit 4 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=0:D=16
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=16 then                    'unit 4 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=0:D=16 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=15 then                    'unit 3 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=0:D=32
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=14 then                    'unit 3 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=0:D=32 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=13 then                    'unit 2 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        C=0:D=64
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=12 then                    'unit 2 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=0:D=64 
        gosub SENDIT
        locate 14,8:print "   "
    end if
     if gad=11 then                    'unit 1 off gadget
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF"        
        C=0:D=128
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=10 then                    'unit 1 on gadget
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON "
        C=0:D=128 
        gosub SENDIT
        locate 14,8:print "   "
    end if

     if gad=9 then quit
     if gad=8 then 
         serial close 1
         gosub Ser
         WINDOW OUTPUT 1
         unitz=unit
         if unitz=0 then unitz=1
         LOCATE 4,33:PRINT " Port # ";unitz;"  "
         gosub SETIME
      end if
     if gad=7 then                     'dim gadget for selected unit  
        A=DA:I=1:S=16:T=8  
        locate 14,8:print "DIM" 
        IF U>8 THEN D=0:C=UCODE(U-8)
        IF U<9 THEN C=0:D=UCODE(U)
        IF L<8 THEN T=7
        IF L>8 THEN T=9
        gosub SENDIT
        locate 14,8:print "   "
     end if
     if gad=6 then                     'about gadget
        about_box
     end if
     if gad=5 then                     'off gadget for selected unit
        A=3:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "OFF" 
        IF U>8 THEN D=0:C=UCODE(U-8)
        IF U<9 THEN C=0:D=UCODE(U)
        gosub SENDIT 
        locate 14,8:print "   "
     end if
     if gad=4 then                     'on gadget for selected unit
        A=2:I=1:S=16
        WINDOW OUTPUT 1
        locate 14,8:print "ON " 
        IF U>8 THEN D=0:C=UCODE(U-8)
        IF U<9 THEN C=0:D=UCODE(U)
        gosub SENDIT
        WINDOW OUTPUT 1
        locate 14,8:print "   "
     end if
     if gad=3 then                     'slider for dim level
        L=ABS(gadget(3)-15)            'CONV 0-15 TO 15-0
        IF L>15 THEN L=15
        IF L<0 THEN L=0
        DA=5+(240 AND (L*16))
        WINDOW OUTPUT 1
        locate 12,16:print gadget(3);chr$(8);" " 
     end if
     if gad=2 then                     'slider for unit code
        U=gadget(3)
        U=U+1
        IF U<1 THEN U=1
        IF U>16 THEN U=16
        IF U>8 THEN D=0:C=UCODE(U-8)
        IF U<9 THEN C=0:D=UCODE(U)
        WINDOW OUTPUT 1
        locate 8,16:print U;chr$(8);"  " 
     end if
     if gad=1 then                     'slider for house code
       HC=gadget(3)
       HC=HC+1
       IF HC<1 THEN HC=1 
       IF HC>16 THEN HC=16
       B=HCODE(HC)
       WINDOW OUTPUT 1
       locate 4,16:print " ";CHR$(HC+64) 
     end if
    mouse on
    return

SENDIT:
 WINDOW OUTPUT 1
 LOCATE 3,51:color 1,4:PRINT " TX ":color 1,0
 IF I=1 THEN E=A+B+C+D 'CHECKSUM
 IF I=2 THEN E=A+B+C   'CLOCK CHSM
 IF I=0 THEN E=A+B+C   'CLOCK CHSM
 IF E>256 THEN E=E-256
 IF E>256 THEN E=E-256
 FOR J=1 TO S
 serial write 1,CHR$(255),1 'SYNC TO X10
 NEXT J
 serial write 1,CHR$(I),1 'BIT17 DIRECT COMMAND
 serial write 1,CHR$(A),1 'BIT18 FUNCTION/LEVEL
 serial write 1,CHR$(B),1 'BIT19 HOUSE CODE
 serial write 1,CHR$(C),1 'BIT20 UNIT BIT 9-16     
 IF I=1 THEN serial write 1,CHR$(D),1 'BIT21 UNIT BIT 1-8
 serial write 1,CHR$(E),1 'CHKSUM
 LOCATE 26,30:PRINT " CHECKSUM IS         "
 LOCATE 26,30:PRINT " CHECKSUM IS ";E
 COUNT=0:X=0:K=0
 sleep for T
 T=1
 LOCATE 3,51:color 1,5:PRINT "    ":color 1,0  

LOOK:
   IF X=0 THEN sleep for .05:COUNT=COUNT+1
   IF COUNT=100 AND X=0 THEN LOCATE 27,30:PRINT " X-10 IS NOT ON LINE ":BEEP:return
   IF K>6 AND X=1 THEN LOCATE 27,30:PRINT " X-10 ACK DONE      ":return
   IF I=2 AND X=1 THEN LOCATE 27,30:PRINT " X-10 ACK DONE      ":return
   chars=serial(1,0)
   IF chars=0 THEN LOOK
   COUNT=0  
   IF chars <>0 THEN K=K+1:serial read 1,J$,1  
   IF ASC(J$)=1 AND X=0 THEN X=1
   J$=""   
   GOTO LOOK

LOOKx:
   WINDOW OUTPUT 1 
   chars=serial(1,0)
   IF chars=0 THEN JX=0:LOCATE 3,51:color 1,5:PRINT "    ":color 1,0:return
   IF chars <>0 then serial read 1,JJ$,1
   IF ASC(JJ$)=255 then JJ$="":GOTO LOOKx
   LOCATE 3,51:color 1,4:PRINT " RX ":color 1,0 
   JX=JX+1
   JDATA(JX)=0
   JDATA(JX)=ASC(JJ$)   
'   PRINT ASC(JJ$);
   JJ$=""
   LOCATE 23,18:PRINT "    " 
   LOCATE 23,18:PRINT JDATA(2)
   LOCATE 24,18:PRINT "    "  
   LOCATE 24,18:PRINT JDATA(3)
   LOCATE 25,18:PRINT "    " 
   LOCATE 25,18:PRINT JDATA(4) 
   LOCATE 26,18:PRINT "    "  
   LOCATE 26,18:PRINT JDATA(5) 
   LOCATE 27,18:PRINT "    " 
   LOCATE 27,18:PRINT JDATA(6)   
   GOTO LOOK

SETIME:
 window 2,"X10 by P.J.Zielinski",(100,100)-(350,140),22
 WINDOW OUTPUT 2
 FONT "topaz",8
 print
 print "Please WAIT checking INTERFACE"
 WINDOW OUTPUT 1
 HRS=VAL(LEFT$(TIME$,2)):MIN=VAL(MID$(TIME$,4,2)) 'set time
 I=2:S=16:A=MIN:B=HRS:C=0:D=0:T=2
 locate 14,7:print "WAIT!!" 
 GOSUB SENDIT
 GOSUB SENDIT
 GOSUB GETHCODE
 window output 1
 locate 14,7:print "      " 
 U=1:L=8:C=0:D=128:S=16
 DA=5+(240 AND (L*16))
 K=0:JX=0
 window close 2
 gadget mod 1,HC	
RETURN

GETHCODE:
 JX=1:VV=0  'get house code
 FOR XJ=1 TO 16
 serial write 1,CHR$(255),1 'SYNC TO X10
 NEXT XJ
 serial write 1,CHR$(4),1 'BIT17 DIRECT COMMAND
LOOKZ:
   IF JX=12 THEN GOTO DISX
   chars=serial(1,0)
   IF VV=1000 THEN VV=0:RETURN
   IF chars=0 THEN VV=VV+1:GOTO LOOKZ
   serial read 1,J$,1
   J(JX)=ASC(J$)
   JX=JX+1
   GOTO LOOKZ
DISX:            ' h/code lookup table
   VV=0
   IF J(11)=96 THEN HC=1
   IF J(11)=224 THEN HC=2
   IF J(11)=32 THEN HC=3
   IF J(11)=160 THEN HC=4
   IF J(11)=16 THEN HC=5
   IF J(11)=144 THEN HC=6
   IF J(11)=80 THEN HC=7
   IF J(11)=208 THEN HC=8
   IF J(11)=112 THEN HC=9
   IF J(11)=240 THEN HC=10
   IF J(11)=48 THEN HC=11
   IF J(11)=176 THEN HC=12
   IF J(11)=0 THEN HC=13
   IF J(11)=128 THEN HC=14
   IF J(11)=64 THEN HC=15
   IF J(11)=192 THEN HC=16
   B=HCODE(HC)
   WINDOW OUTPUT 1
   locate 4,16:print " ";CHR$(HC+64) 
RETURN

Mport:                     'Messageport control
  message read #1,bufferp
  sleep for .1
  if bufferp="QQ" then quit
  if bufferp="" then return
  LOCATE 27,30:PRINT " Message Channel RX "
  BEEP
  H$=mid$(bufferp,3,1)  'HC
  IF HC<1 OR HC>16 THEN RETURN
  U=val(mid$(bufferp,7,2))  'UN
  IF U<1 OR U>16 THEN RETURN
  IF U>8 THEN D=0:C=UCODE(U-8)
  IF U<9 THEN C=0:D=UCODE(U)
  H=val(mid$(bufferp,11,1)) 'C
  IF H=1 THEN Mport1
  A=H:I=1:S=16
  locate 14,8:print "MSG"
  GOSUB SENDIT
  locate 14,8:print "   "
  bufferp=""
  goto Mport
Mport1:
  L=val(mid$(bufferp,14,2)) 'L
  IF L>15 THEN L=15
  IF L<0 THEN L=0
  A=5+(240 AND (L*16))
  I=1:S=16
  locate 14,8:print "MSG"
  GOSUB SENDIT
  locate 14,8:print "   "
  bufferp=""
  goto Mport

handle_mouse:
  wdw_id = window(0)
  if wdw_id > 0 then window output wdw_id
  return

Ser:
   unitq=0
   ux$=str$(unit)
   if unit=0 then ux$=" 1"
   unitq=inputbox(" Port # 1-8  Port is set to"+ux$," Select Serial Port # ","1")
   if unitq = 0 then return
   if unitq = 1 then unitq=0
   if unitq < 0 then unitq=0
   if unitq > 8 then unitq=0
   unit=unitq
   Ser_x
   return

'..cleanup!
quit:
  sleep for .1
  gadget close 42
  gadget close 41
  gadget close 40
  gadget close 39
  gadget close 38
  gadget close 37
  gadget close 36
  gadget close 35
  gadget close 34
  gadget close 33
  gadget close 32
  gadget close 31
  gadget close 30
  gadget close 29
  gadget close 28
  gadget close 27
  gadget close 26
  gadget close 25
  gadget close 24
  gadget close 23
  gadget close 22
  gadget close 21
  gadget close 20
  gadget close 19
  gadget close 18
  gadget close 17
  gadget close 16
  gadget close 15
  gadget close 14
  gadget close 13
  gadget close 12
  gadget close 11
  gadget close 10
  gadget close 9
  gadget close 8
  gadget close 7
  gadget close 6
  gadget close 5
  gadget close 4
  gadget close 3
  gadget close 2
  gadget close 1
  message close #1
  window close 1
  serial close 1
END
