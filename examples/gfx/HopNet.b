' *** Hopfield Neural Network ***

'...  - 7 nodes
'...  - symmetrical connection weights
'...  - alterable weights & node settings  

'...see: "Connectionist Ideas & Algorithms",
'...      Communications of the ACM, November 1991

'...David J Benn, 7th March-8th March 1991
'...Modified for ACE BASIC on 20th-21st,26th February 1992,
'...			      7th,31st January 1993,
'...			      2nd October 1994

DIM wt(7,7),initial.wt(7,7),nodex(7),nodey(7),node(7),flag(7)

SUB plot.link(n1,n2)
shared nodex,nodey,node 
  LINE (nodex(n1),nodey(n1))-(nodex(n2),nodey(n2)),2
  '...replot nodes
  IF node(n1) THEN 
    '...activate
    line (nodex(n1)-10,nodey(n1)-5)-(nodex(n1)+10,nodey(n1)+5),2,bf
  else
    '...deactivate
    line (nodex(n1)-10,nodey(n1)-5)-(nodex(n1)+10,nodey(n1)+5),1,bf '..erase
    line (nodex(n1)-10,nodey(n1)-5)-(nodex(n1)+10,nodey(n1)+5),2,b  '..outline
  end if 
  IF node(n2) THEN 
    line (nodex(n2)-10,nodey(n2)-5)-(nodex(n2)+10,nodey(n2)+5),2,bf
  else
    line (nodex(n2)-10,nodey(n2)-5)-(nodex(n2)+10,nodey(n2)+5),1,bf
    line (nodex(n2)-10,nodey(n2)-5)-(nodex(n2)+10,nodey(n2)+5),2,b
  end if  
END SUB

SUB unplot.link(n1,n2)
shared nodex,nodey,node 
  LINE (nodex(n1),nodey(n1))-(nodex(n2),nodey(n2)),1
  '...replot nodes
  IF node(n1) THEN 
    '...activate
    line (nodex(n1)-10,nodey(n1)-5)-(nodex(n1)+10,nodey(n1)+5),2,bf
  else
    '...deactivate
    line (nodex(n1)-10,nodey(n1)-5)-(nodex(n1)+10,nodey(n1)+5),1,bf '..erase
    line (nodex(n1)-10,nodey(n1)-5)-(nodex(n1)+10,nodey(n1)+5),2,b  '..outline
  end if 
  IF node(n2) THEN 
    line (nodex(n2)-10,nodey(n2)-5)-(nodex(n2)+10,nodey(n2)+5),2,bf
  else
    line (nodex(n2)-10,nodey(n2)-5)-(nodex(n2)+10,nodey(n2)+5),1,bf
    line (nodex(n2)-10,nodey(n2)-5)-(nodex(n2)+10,nodey(n2)+5),2,b
  end if
END SUB
    
SUB plot.weight(i,j,colr%)    
shared wt,initial.wt,nodex,nodey,node
  COLOR colr%,1  
  x%=(nodex(i)+nodex(j)) / 2 
  y%=(nodey(i)+nodey(j)) / 2 
  SETXY x%-8,y%+3
  wt$=STR$(wt(i,j))
  FOR k=1 TO LEN(wt$)
    ch$=MID$(wt$,k,1)
    IF ch$=" " THEN
      sn$="+"
      PRINT sn$; 
    ELSE  
      PRINT ch$;
    END IF
  NEXT  
END SUB              

SUB plot.node(n,colr%)
shared nodex,nodey  
  if colr%=2 then
    '...activate
    line (nodex(n)-10,nodey(n)-5)-(nodex(n)+10,nodey(n)+5),2,bf 
  else
    '...deactivate
    line (nodex(n)-10,nodey(n)-5)-(nodex(n)+10,nodey(n)+5),1,bf '..erase
    line (nodex(n)-10,nodey(n)-5)-(nodex(n)+10,nodey(n)+5),2,b  '..outline
  end if
END SUB
   
SUB clrline 
    LOCATE 12,50
    PRINT"                               "
    LOCATE 11,50
    PRINT"                               "
END SUB

RANDOMIZE TIMER
  
WINDOW 2,"Hopfield Neural Network",(0,0)-(640,200),6
FONT "topaz",8
PENUP	'..don't want SETXY to draw a line!
color 2,1
cls

xoff=55
yoff=35

FOR i=1 TO 7
  READ nodex(i),nodey(i)
  nodex(i)=nodex(i)+xoff
  nodey(i)=nodey(i)+yoff
NEXT

'...node coords

DATA 55,5
DATA 155,5

DATA 55,55
DATA 155,55

DATA 5,105
DATA 105,105
DATA 205,105

'...set up connection weight adjacency matrix
FOR i=1 TO 7
  FOR j=1 TO 7
    READ wt(i,j)
    initial.wt(i,j)=wt(i,j)
  NEXT
NEXT
    
'...link data
DATA 0,-1,1,-1,0,0,0
DATA -1,0,0,3,0,0,0
DATA 1,0,0,-1,2,1,0
DATA -1,3,-1,0,0,-2,3
DATA 0,0,2,0,0,1,0
DATA 0,0,1,-2,1,0,-1
DATA 0,0,0,3,0,-1,0

GOSUB draw.links  
GOSUB draw.nodes
GOSUB draw.weights
GOSUB node.key
GOSUB weight.matrix
  
'...reset all nodes
FOR i=1 TO 7
  node(i)=0
NEXT
    
'...main loop
WHILE -1
  GOSUB main.menu
WEND
  
main.menu:
  color 2,1
  LOCATE 2,50: PRINT"1. activate a node"
  LOCATE 3,50: PRINT"2. deactivate a node"
  LOCATE 4,50: PRINT"3. deactivate all nodes"
  LOCATE 5,50: PRINT"4. randomize nodes"
  LOCATE 6,50: PRINT"5. change a weight"
  LOCATE 7,50: PRINT"6. reset all weights"
  LOCATE 8,50: PRINT"7. seek a stable state"
  LOCATE 9,50: PRINT"0. quit"
  color 3,1
  LOCATE 10,50:PRINT"   enter 0..7"
  color 2,1
  getitagain:
    k$=""
    WHILE k$=""
      k$=INKEY$
    WEND
    k=VAL(k$)
    IF (k<0 OR k>7) OR NOT(k$>="0" AND k$<="7") THEN getitagain
    IF k=0 THEN
      WINDOW CLOSE 2
      stop
    END IF
    if k=1 then gosub set.node
    if k=2 then gosub reset.node
    if k=3 then gosub reset.all.nodes
    if k=4 then gosub rnd.nodes
    if k=5 then gosub change.weight
    if k=6 then gosub reset.all.weights
    if k=7 then gosub seek
    clrline
RETURN

set.node:
  LOCATE 12,50
  PRINT"set which node (1..7)?"
  GOSUB get.node.num
  node(n)=-1
  line (nodex(n)-10,nodey(n)-5)-(nodex(n)+10,nodey(n)+5),2,bf  
RETURN

reset.node:
  LOCATE 12,50
  PRINT"reset which node (1..7)?"
  GOSUB get.node.num
  node(n)=0
  line (nodex(n)-10,nodey(n)-5)-(nodex(n)+10,nodey(n)+5),1,bf '..erase  
  line (nodex(n)-10,nodey(n)-5)-(nodex(n)+10,nodey(n)+5),2,b  '..outline
RETURN

reset.all.nodes:
  LOCATE 12,50
  PRINT"resetting nodes..."
  FOR i=1 TO 7
    node(i)=0
    line (nodex(i)-10,nodey(i)-5)-(nodex(i)+10,nodey(i)+5),1,bf '..erase 
    line (nodex(i)-10,nodey(i)-5)-(nodex(i)+10,nodey(i)+5),2,b  '..outline 
  NEXT
RETURN

reset.all.weights:
  LOCATE 12,50
  PRINT"resetting weights..."
  FOR i=1 TO 7
    FOR j=1 TO 7
      wt(i,j)=initial.wt(i,j)
    NEXT
  NEXT
  CLS
  GOSUB draw.links  
  GOSUB draw.nodes
  GOSUB draw.weights
  GOSUB node.key
  GOSUB weight.matrix
RETURN

rnd.nodes:
  LOCATE 12,50
  PRINT"randomizing nodes..."
  FOR i=1 TO 7
    r=RND
    IF r<=.5 THEN 
      node(i)=-1
      CALL plot.node(i,2)  '...activate
    ELSE
      node(i)=0
      CALL plot.node(i,3)  '...deactivate
    END IF
  NEXT
RETURN
                            
change.weight:  
 get.n1:
  clrline
  LOCATE 12,50
  PRINT "first node (1..7)"
  GOSUB get.node.num
  n1=n
  clrline
  LOCATE 12,50
  PRINT "second node (1..7)"
  GOSUB get.node.num
  n2=n
  IF n1=n2 THEN get.n1
  clrline
  LOCATE 12,50
  INPUT"enter new weight ",weight
  weight=INT(weight)
  IF weight<>0 THEN 
    '...get rid of old weight
    CALL plot.weight(n1,n2,0)
    '...plot line of no link before
    IF NOT(wt(n1,n2)) THEN CALL plot.link(n1,n2)
    wt(n1,n2)=weight
    wt(n2,n1)=weight
    CALL plot.weight(n1,n2,3)
  ELSE
    '...get rid of weight
    CALL plot.weight(n1,n2,0)
    CALL unplot.link(n1,n2)
    wt(n1,n2)=0
    wt(n2,n1)=0
  END IF
  GOSUB weight.matrix
  GOSUB draw.nodes
RETURN    
                  
get.node.num:
  n=0
  WHILE n<1 OR n>7 
    n=VAL(INKEY$)
  WEND  
RETURN

seek:
  LOCATE 12,50
  PRINT "Stop after each pass (y/n)"
  answer$=""
  WHILE answer$<>"Y" AND answer$<>"N"
    answer$=INKEY$
    answer$=UCASE$(answer$)
  WEND  
  IF answer$="Y" THEN pass.pause=-1 ELSE pass.pause=0
  clrline
  COLOR 2,1
  LOCATE 14,40
  PRINT "Node  Sum"
  pass=0
  seek.pass:
    nodes.changing=0
    pass=pass+1
    COLOR 2,1
    LOCATE 11,50
    PRINT"seeking stable state"
    LOCATE 11,71
    PRINT "#";pass
    FOR k=1 TO 7
      flag(k)=0
    NEXT 
    i=1
    WHILE i<=7
     sum=0
     get.node:
      r=INT(RND*7)+1
      IF flag(r) THEN get.node
      flag(r)=-1
      '...is it linked to other nodes & are they active?
      FOR j=1 TO 7
        IF wt(r,j) THEN 
          IF node(j) THEN sum=sum+wt(r,j)
        END IF  
      NEXT
      '...show sum of node's connections
      COLOR 4,1
      LOCATE 15+r,40
      PRINT r;"   ";sum  
      '...if sum is greater than 0 -> activate node
      IF sum>0 THEN
        IF node(r)=0 THEN 
          node(r)=-1
          CALL plot.node(r,2)
          nodes.changing=nodes.changing+1
        END IF  
      ELSE
        IF node(r)<>0 THEN
          node(r)=0
          CALL plot.node(r,3)
          nodes.changing=nodes.changing+1
        END IF          
      END IF
      i=i+1
      IF INKEY$<>"" THEN exit.seek
    WEND
    IF nodes.changing AND pass.pause THEN GOSUB pause.after.pass  
  IF nodes.changing > 0 THEN seek.pass
  exit.seek:
    clrline
    LOCATE 11,50
    PRINT "Network stable."
    GOSUB pause.after.pass  
    '...clear node sums
    FOR i=1 TO 9
      LOCATE 13+i,40
      PRINT "          "
    NEXT  
RETURN

pause.after.pass:
  LOCATE 12,50
  PRINT "Hit return to continue."
  WHILE INKEY$<>chr$(13)
  WEND
  LOCATE 12,50
  PRINT "                          "
  clrline    
RETURN  

draw.links:   
  bse=1
  FOR i=1 TO 7
    FOR j=bse TO 7
      IF wt(i,j) THEN LINE (nodex(i),nodey(i))-(nodex(j),nodey(j)),2
    NEXT
    bse=bse+1
  NEXT
RETURN

draw.nodes:
  FOR i=1 TO 7
    IF NOT node(i) THEN 
      plot.node(i,1)
    ELSE
      plot.node(i,2)
    END IF
  NEXT
RETURN

draw.weights:
  COLOR 3,1
  bse=1
  FOR i=1 TO 7       
    FOR j=bse TO 7
      IF wt(i,j) THEN CALL plot.weight(i,j,3)
    NEXT 
    bse=bse+1
  NEXT
  COLOR 2,1
RETURN  

node.key:
  COLOR 4,1
  LOCATE 3,39:PRINT"1"
  LOCATE 3,43:PRINT"2"
  LOCATE 5,39:PRINT"3"
  LOCATE 5,43:PRINT"4"
  LOCATE 7,37:PRINT"5"
  LOCATE 7,41:PRINT"6"
  LOCATE 7,45:PRINT"7"
  COLOR 2,1
RETURN  
      
weight.matrix:
  color 4,1 
  locate 12,50
  print "updating weight matrix..."
  COLOR 2,1
  '...column labels
  FOR label.x=1 TO 7
    LOCATE 14,54+(label.x*3)
    PRINT label.x
  NEXT
  '...row labels
  FOR label.y=1 TO 7
    LOCATE 15+label.y,53
    PRINT label.y
  NEXT   
  COLOR 3,1
  '...connection weight matrix
  FOR mat.x=1 TO 7
    FOR mat.y=1 TO 7
      LOCATE 15+mat.x,54+(mat.y*3)
      PRINT wt(mat.x,mat.y);
    NEXT
  NEXT
  locate 12,50
  print "                         " 
RETURN
