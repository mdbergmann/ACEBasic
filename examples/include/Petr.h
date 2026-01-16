shortint Kontrola,m.a,m.b
  'Kontrola - shared variable which is used in subs "in$" and "Innum!" 
  'this variable returns 3,4,5,6 - if an cursor is pressed 
  '                      and  10 - if esc is pressed(with included keymap)

  'm.a and m.b  - shared variable which is used in subs "mys",
  '                                     "GAD%" and "Waitmouse"
  ' m.a row of mouse click (1-25)
  ' m.b column of mouse click (1-80)

dim t$(16)
dim tg%(16,3)
  'shared arrays used in subprogram "GAD%"
  ' t$  gadgets texts
  ' tg% (i,1)  row of gadget
  ' tg% (i,2)  start column of gadget
  ' tg% (i,3)  lenght of gadget


SUB pause(dsecs%)
 'waits for dsecs% / 10  seconds
 Longint t
 t=TIMER*10
 WHILE ABS(t-(TIMER*10))<dsecs%
 WEND
END SUB

SUB NoSpace$(f$)
  'this subprogram removes all characters with ascii code <33
  shortint i
  string s$ size 80,i$ size 4
  for i=1 to len(f$)
    i$=mid$(f$,i,1)
    If asc(i$)>32 then s$=s$+i$
  next i
  NoSpace$=s$
END SUB

SUB key$
 'this subprogram waits for press of keyboard and returns pressed column
    String i$ SIZE 2
    Repeat
     i$=inkey$
    Until i$<>""
    key$=i$
END SUB 

SUB Mys
 'this subprogram wait for mouse click and then returns
 'mouse position in shared variables m.a (column) and m.b (row)
 Shared m.a, m.b
 SHORTINT h
 String i$ SIZE 2

Repeat
 h=MOUSE(0)          
 If h<>0 THEN
   m.a=INT(MOUSE(1)/8)+1
   m.b=INT(MOUSE(2)/8)+1
   EXIT SUB
 End if
until h<>0
END SUB


SUB BOX(x1%,x2%,y1%,y2%,col%,st%)
  'this subprogram draw a 3D like box
  'x1% - start x coordinate  (lines)
  'x2% - end x coordinate  (lines)
  'y1% - start y coordinate  (lines)
  'y2% - end y coordinate  (lines)
  'col% - color to fil the box
  'st% - 0 to box up or 1 to box down
  
  shortint col1,col2
  col1=abs(st%-1)
  col2=st%
  line (x1%,y1%)-(x2%,y2%),col%,bf
  line (x1%,y1%)-(x2%,y1%),col1
  line (x1%,y1%)-(x1%,y2%),col1
  line (x1%,y2%)-(x2%,y2%),col2
  line (x2%,y1%)-(x2%,y2%),col2
END SUB


SUB gline(ra%,sl%,de%,st%)
  'this subprogram draw a 3D like box 1 row high and locate print to it
  'sl% - start x coordinate  (columns)
  'ra% - start y coordinate  (rows)
  'de% - lenght of box in columns
  'st% - 0 to box up or 1 to box down

  shortint col1,col2,x1,x2,y1,y2
  col1=abs(st%-1)
  col2=st%
  x1=sl%*8-9
  x2=(sl%+de%)*8-8
  y1=ra%*8-9
  y2=ra%*8
  line (x1,y1)-(x2,y1),col1
  line (x1,y1)-(x1,y2),col1
  line (x1,y2)-(x2,y2),col2
  line (x2,y1)-(x2,y2),col2
  locate ra%,sl%
END SUB

SUB PrTime
  'this subprogram writes time and date on top right corner of screen
  oldfg%=window(10)
  color 3,2
  box(496,592,13,35,2,0)
  locate 3,69
  Prints left$(time$,len(time$)-3)
  locate 4,64
  Prints Date$
  color oldfg%,3
END SUB

SUB in$(i%,j%,t$,n$,l%)
  'this subprogram is for easy formatted input on custom screens
  'i% - start row
  'j% - start column
  't$ - help text for input
  'n$ - posible text for input
  'l% - maximum/defeault lenght of text
  'shared variable kontrola returns 3,4,5,6 - cursor; 10 - esc (with included keymap)

  PrTime
  ON TIMER(10) gosub ICAS
  TIMER ON
  SHARED kontrola
  SHORTINT a,d,m,Radic
  STRING j$ SIZE 80
   NULL$=""
   m=0
   d=0
   Kontrola=0
   Radic=0
   color 1,3
   If i%=0 then i%=csrlin+1
   If j%=0 then j%=pos
   n$=left$(n$,l%)
   m=l%-LEN(n$)
   LOCATE i%,j%
  Prints t$;n$;Space$(m);
   color 2,3
   Prints "<"
   j%=j%+LEN(t$)
   LOCATE i%,j%
   color 1,3
   SOUND 1141.42,1,32,1
   SOUND 906,2,32,0

   string i$ SIZE 2

Pokracovani:
    i$=key$
    a=asc(i$)

    If a=8 then
      i$=NULL$
      If d>0 then
        j$=left$(j$,(d-1))
        d=d-2
       else
	--d	
      End if
    End if

    If a=127 then
        i$=NULL$
        j$=NULL$
        d=-1
    End if

    If a=27 then
       kontrola=10
       goto Hotovo
    End if

    If a=7 or (a>8 and a<13) then
       kontrola=a-6
       goto Hotovo
    End if

    If a=13 then
       goto Hotovo
    End if

      If a>31 or a=8 then
        j$=j$+i$
        ++d
        If d=l% then
          goto Hotovo
        End if
        locate i%,j%
        Prints j$;
         color 3,3
        Prints "|";
         color 1,3
        Prints space$(l%-d-1)
      End if

goto Pokracovani

ICAS:
PrTime
locate i%,j%
return

Hotovo:
 LOCATE i%,j%
 If j$=NULL$ THEN j$=n$ 
 j$=left$(j$+space$(l%-d),l%)
 Prints j$;space$(1)
 in$=j$
END SUB

SUB InNum!(i%,j%,t$,n$,l%)
 'this subprogram is like in$, but for variables
 Shared Kontrola
 InNum!=Val(NoSpace$(in$(i%,j%,t$,n$,l%)))
END SUB

SUB GAD%
 'this subprogram draws gadgets with user text and returns the number of selected gadget
 ' gadgets texts is in shared array t$
 ' array tg% (i,1)  row of gadget
 ' array tg% (i,2)  start column of gadget
 ' array tg% (i,3)  lenght of gadget
 ' gadgets can be selected by alt - cursor and Enter too
  PrTime
  ON TIMER(30) gosub GCAS
  TIMER ON
  shared tg%,t$
  shortint i,n,vysl,h,zm,m.a,m.b,poz,pozst
  String i$ SIZE 2
repeat
  ++n
until tg%(n,3)=0
  --n
locate 2,2
  color 0,2
  for i=1 to n
   gline(tg%(i,1),tg%(i,2),tg%(i,3),0)
   If left$(t$(i),1)<>space$(1) then t$(i)=space$(1)+t$(i)
   t$(i)=left$((t$(i)+space$(tg%(i,3))),tg%(i,3))
   Prints t$(i)
  next i


REPEAT
 m.a=0%
 m.b=0%
 zm =0%

REPEAT
 i$=INKEY$
 If i$<>"" then
   If asc(i$)=10 then poz=poz+1
   If asc(i$)= 9 then poz=poz-1
   If asc(i$)=13 and poz<1000 and poz>0 then poz=poz+1000
   zm=1000
 End if
 h=MOUSE(0)          
 If h<>0 THEN
  m.a=INT(MOUSE(1)/8)+1
  m.b=INT(MOUSE(2)/8)+1
  zm=1000
 End if
Until zm=1000

  locate 15,15
  for i=1 to n
   locate 15,10
   If m.b=tg%(i,1) then
     If m.a>=tg%(i,2) and m.a<(tg%(i,2)+tg%(i,3)) then
       vysl=i
       gline(tg%(i,1),tg%(i,2),tg%(i,3),1)
     End if
   End if
  next i

  If poz<0 then poz=0
  If poz>n and poz<1000 then poz=1
  If poz>0 and poz<1000 then
    gline(tg%(poz,1),tg%(poz,2),tg%(poz,3),1)
    If pozst>0 then
      gline(tg%(pozst,1),tg%(pozst,2),tg%(pozst,3),0)
    End if
    pozst=poz
  End if
  If poz>1000 then
    gad%=poz-1000
    EXIT SUB
  End if
until vysl>0
 gad%=vysl
EXIT SUB

GCAS:
PrTime
return
END SUB

SUB  WaitMouse
   'this subprogram show wait gadget and waits for selecting them
  shared m.a,m.b
  shortint i,h,j
  h=window(10)
  j=window(11)
  i=CSRLIN			
  box(276,348,180,195,3,0)
  Gline(24,36,8,0)
  color 1,j
  Prints " O.K. ! "
  repeat
    MYS
  until m.b=24 and m.a>35 and m.a<44 
  line (275,179)-(350,196),j,bf
  color h,j
  LOCATE i,1 
END SUB

SUB Using$(f$,b!,Dec%)
' this routine returns formatted string representation of rounded numeric value b!
'	f$ - format :    "!" means not round
'   			"." inserts decimal point
'                     	any other character inserts digit position
'	b! - number
'	Dec% - rounding:  that means number of digits after decimal point
'			it can be a negative value too
' for instance : 	Using$("#####.##,123.567,1)  returns "  123.60"
'			Using$("#####.!!,123.567,1)  returns "  123.57"
'			Using$("#####.##,123.567,-1)  returns "  120.00"

  string r$ size 30
  shortint cf,cr,df,dr,dz,de,lf,lr,sign
  sign=sgn(b!)
  b!=abs(b!)
  If b!<.001 then b!=0
  lf=len(f$)  
  cf=instr(f$,".")-1
  If cf<0 then cf=lf
  df=lf-cf
  dz=-df
  If dz>-1 then dz=-1
  If instr(f$,"!")<1 then 
     If (-dz-1)>Dec% then dz=-Dec%-1
  End if
  b!=b!+5*10^dz

  r$=mid$(str$(b!),2,15)

  de=instr(r$,"E")
  If de>0 then 
    de=val(NoSpace$(mid$(r$,de+1)))
    If de=7 then r$=mid$(str$(CLNG(b!/10)),2,15)+"0"
    If de=8 then r$=mid$(str$(CLNG(b!/100)),2,15)+"00"
    If de>8 then r$=string$(10,37)
  End if

  cr=instr(r$,".")-1
  lr=len(r$)
  If cr<0 then cr=lr
  dz=Dec%
  if -dz>cf then dz=1-cf
  If instr(f$,"!")<1 then 
     If dz>0 then
        r$=left$(r$,cr+1+dz)
       else
        r$=left$(r$,cr+dz)+string$(-dz,48)
     End if
  End if

  cr=instr(r$,".")-1
  lr=len(r$)
  If cr<0 then cr=lr
  dr=lr-cr

 If df<=dr then
   r$=left$(r$,(lr-dr+df))
  else
   If dr=0 then
      r$=r$+"."
      df=df-1
   End if
   r$=r$+string$((df-dr),48)
 End if

  If sign<0 then 
    r$="-"+r$
    cr=cr+1
  End if
  If cf>=cr then
    r$=space$(cf-cr)+r$
   else
    r$="%"+r$
  End if

  Using$=r$
  
END SUB
