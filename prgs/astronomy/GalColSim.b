{ Galaxy Collision Simulator 

 Galaxy Collision Program
 by M.C. Schroeder and Neil F. Comins.
 Appeared in Astronomy magazine, December 1988
 as an IBM GW-BASIC program. 
 
 Adapted to Macintosh Turbo Pascal 1.1 by David J. Benn
 Date: 4th April - 17th April, 2nd & 3rd May 1991

 Adapted for ACE Amiga BASIC by David J. Benn
 Date: 27th,28th November 1992,
       7th January 1993,
       11th October 1993,
       18th December 1993,
       18th September 1994,
       2nd October 1994
	
 This program allows 2 galaxies to interact via
 their gravitational fields. The TARGET galaxy
 is a disk and the INTRUDER galaxy is treated as
 a point mass. }
 
const 	SF2=2
const	arr_size=1000
const	aspect=0.625
const	true=-1&
const	false=0&
const	SIM=1
const	PARAMS=2
 
dim 	X(arr_size),Y(arr_size),Z(arr_size)
dim	VX(arr_size),VY(arr_size),VZ(arr_size)

longint	NRR,NRS,NS,DR
    
single	M1,M2
  
single	X1,Y1,Z1
single	X2,Y2,Z2
single  VX1,VY1,VZ1
single  VX2,VY2,VZ2
    
longint	NTSPR,sim_time

SUB title
  title$ = "*** Galaxy Collision Simulator ***"
  color 2
  locate 2,40-len(title$)\2
  PRINT title$   
END SUB

SUB await_CR
  color 3
  PRINT
  PRINT "Press <return> to begin simulation..."
  while inkey$<>chr$(13):wend
END SUB

SUB instructions
string ans
  PRINT
  color 3
  locate csrlin,25
  PRINT "Do you want instructions? (y/n)"
  repeat
    ans = ucase$(inkey$)
  until ans="Y" or ans="N"
  if ans="Y" then 
    cls
    PRINT
    title
    PRINT
    color 1
    PRINT "This is an adaptation of a BASIC program which appeared in" 
    PRINT "Astronomy magazine, December 1988."
    PRINT
    PRINT "The purpose of the program is to show the large scale effects of"
    PRINT "one galaxy (here refered to as the INTRUDER galaxy) passing nearby"
    PRINT "or through another (TARGET) galaxy."
    PRINT
    PRINT "This is a task which until recent times has been the province of"
    PRINT "of the supercomputer due to the sheer processing power required to"
    PRINT "accurately model the gravitational effects of two galaxies - each"
    PRINT "containing tens or hundreds of billions of stars - upon one ";
    PRINT "another."
    PRINT
    PRINT "However, if the number of stars in the target galaxy is limited and"
    PRINT "the intruder galaxy is considered to be a point gravitational"
    PRINT "source, the problem becomes manageable on a microcomputer."
    PRINT
    PRINT "In this simulation the target galaxy consists of concentric rings" 
    PRINT "of stars."
    await_CR
    cls
    PRINT
    title
    PRINT
    color 1
    PRINT "Before a simulation begins, you will be asked to enter a number of"
    PRINT "parameters. Here is some background information:"
    PRINT
    PRINT "  - 1 parsec = 3.26 light years = approx 30 million million kms"
    PRINT "  - 1 solar mass = the mass of our sun = 1990 thousand million"
    PRINT "    million million million kilograms"
    PRINT "  - Each time step represents 1.2 million years"
    PRINT "  - Each integer X, Y or Z step represents 500 parsecs"
    PRINT "  - Vx, Vy and Vz represent the velocities in the 3 axes"
    PRINT "  - The mass of the target galaxy equals 20 billion solar masses"
    PRINT "  - The mass of the intruder galaxy is entered as a fraction of"
    PRINT "    the target galaxy (eg: 0.25 x 20 billion = 5 billion)."   
    await_CR
    cls
    PRINT
    title
    PRINT
    color 1
    PRINT "The following are some sample initial conditions and their results:"
    PRINT
    PRINT "Result        Intruder Mass   X   Y   Z   Vx   Vy   Vz   Time Steps"
    PRINT
    PRINT "Ring Galaxy       1           7.5  0  35   0    0   -1     65"
    PRINT "Bridge Galaxy     0.25       40   10  10  -1    0    0    120"
    PRINT "Whirlpool Galaxy  0.25      -30   30   0   0   -0.5  0.5  175"
    PRINT
    PRINT "For best results, use about 10 concentric rings and 20 stars per" 
    PRINT "ring. This shows enough detail without slowing the simulation down"
    PRINT "too much."    
    PRINT 
    PRINT "In what follows, you will also be given the opportunity to choose"
    PRINT "one of the above 3 resultant galaxies rather than entering initial"
    PRINT "condition values." 
    PRINT
    PRINT "This program may also be run from the shell/CLI, with the following"
    PRINT "syntax:"
    PRINT
    PRINT "    GalColSim [ring | bridge | whirlpool]"
    await_CR
  end if
END SUB

SUB entry_method
string ans 
  cls
  color 1
  PRINT:PRINT
  PRINT "Enter [P]arameters or [N]ame of simulation?"
  repeat
    ans=ucase$(inkey$)
  until ans="P" or ans="N"
  case
    ans="P" : entry_method=PARAMS
    ans="N" : entry_method=SIM
  end case
END SUB

SUB set_parameters(opt)
shared 	 NRR,NRS,NS,DR
shared	 M2
shared	 X2,Y2,Z2
shared	 VX2,VY2,VZ2
shared	 NTSPR
  '..initialise parameters
  if opt=1 then
    '..ring
    M2=1
    X2=7.5 : Y2=0  : Z2=35
    VX2=0  : VY2=0 : VZ2=-1    
    NTSPR=65
  else
    if opt=2 then
      '..bridge
      M2=0.25
      X2=40  : Y2=10 : Z2=10
      VX2=-1 : VY2=0 : VZ2=0
      NTSPR=120   
    else
      '..whirlpool
      M2=0.25
      X2=-30 : Y2=30    : Z2=0
      VX2=0  : VY2=-0.5 : VZ2=0.5
      NTSPR=175
    end if
  end if 

  '..number of rings and stars per ring
  NRR=10
  NRS=20
  NS=NRR*NRS
  if NRR<2 then NRR=2
  DR=20 \ (NRR-1)
END SUB

SUB args_present
string end_state
  if argcount<>1 then
    args_present=false
    exit sub
  else 
    args_present=true
    end_state=ucase$(arg$(1))
    case
      end_state="RING"      : opt=1
      end_state="BRIDGE"    : opt=2
      end_state="WHIRLPOOL" : opt=3
    end case
    set_parameters(opt)       
  end if
END SUB

SUB get_simulation
shortint opt

  '..ask for simulation end-state
  PRINT
  PRINT "Which end-state?"
  PRINT
  PRINT "1. Ring Galaxy"
  PRINT "2. Bridge Galaxy"
  PRINT "3. Whirlpool Galaxy"
  repeat 
    opt=val(inkey$)
  until opt>=1 and opt<=3
  
  set_parameters(opt)
END SUB

SUB get_parameters
{The stars are distributed in the
 TARGET galaxy in rings. The total number
 of stars is the product of the # of rings and
 the # of stars per ring.}
shared 	NRR,NRS,NS,DR
shared	M2
shared	X2,Y2,Z2
shared	VX2,VY2,VZ2
shared	NTSPR
string 	ANS  
 repeat
  cls
  PRINT
  PRINT "Enter the initial conditions..."
  PRINT
  PRINT "Input the number of rings of stars in the TARGET galaxy (try 8-20):"
  input NRR
  PRINT
  PRINT "Input the number of stars per ring in the TARGET galaxy (try 15-30):"
  input NRS
  PRINT
  NS=NRR*NRS
  if NRR<2 then NRR=2
  DR=20 \ (NRR-1)
  PRINT "Input the mass fraction of the INTRUDER galaxy"
  PRINT "in units of the TARGET galaxy mass (try 0.25-1):"
  input M2
  PRINT
  PRINT "Input the initial X Y Z co-ordinates of the INTRUDER galaxy"
  PRINT "(eg: 40 10 10):"
  PRINT "The TARGET galaxy is located at 0 0 0."
  PRINT "X: "; 
  input X2
  PRINT "Y: "; 
  input Y2
  PRINT "Z: "; 
  input Z2
  PRINT
  PRINT "Input the initial X Y Z  velocities"
  PRINT "of the INTRUDER galaxy (eg: -1 0 0):"
  PRINT "The TARGET galaxy is initially at rest."
  PRINT "X: "; 
  input VX2
  PRINT "Y: "; 
  input VY2
  PRINT "Z: "; 
  input VZ2
  {not too small (0 is ok) - system may crash at around +- .34 or so...}
  if VX2<0.5 then VX2=VX2*2;
  if VY2<0.5 then VY2=VY2*2;
  if VZ2<0.5 then VZ2=VZ2*2;
  PRINT
  {the position of the TARGET galaxy
   is assigned by the computer}
  PRINT "Input number of time steps for this run (try 50-200)"
  input NTSPR
  PRINT
  PRINT "Are these inputs correct? (y/n) "
  repeat
    ANS = ucase$(inkey$)
  until ANS="Y" or ANS="N"
 until ANS="Y"
END SUB
    
SUB update_display
{update screen display}
shared 	X,Y,VX,VY,Z,VZ
shared	NRR,NRS,NS,DR    
shared	M1,M2  
shared	X1,Y1,Z1
shared	X2,Y2,Z2
shared  VX1,VY1,VZ1
shared  VX2,VY2,VZ2   
shared	NTSPR,sim_time
single 	XC,YC,ZC,XX1,YY1,ZZ1,XX2,YY2,ZZ2
longint	I,J
single	XP,YP,ZP
string	ch
    {calculate centre of mass of system
     for use as centre of output display}
    XC=(M1*X1+M2*X2)/(M1+M2)
    YC=(M1*Y1+M2*Y2)/(M1+M2)
    ZC=(M1*Z1+M2*Z2)/(M1+M2)
    {set up output display - clear text & graphics}
    cls
    {print out display headings}  
    color 3
    locate 2  
    PRINT "        Polar             Edge-on"
    color 3
    locate 22
    PRINT "        Step:";sim_time
    color 5
    locate 23
    PRINT "   Real Time:";int((sim_time+1)*1.2);"million years"
    color 4
    locate 24
    PRINT "   Press any key to stop"
    '..view frames
    LINE (0,0)-(159,166),2,b
    LINE (161,0)-(319,166),2,b
    {calculate position of galactic centres and display on screen}
    XX1=(X1-XC)
    YY1=(Y1-YC)
    ZZ1=(Z1-ZC)
    XX2=(X2-XC)
    YY2=(Y2-YC)
    ZZ2=(Z2-ZC)
    ZP=Z(1)-ZC + Z(NS)-ZC
    CIRCLE(int(XX1+75),int(YY1+75)),2,1,,,aspect	{target x-y}
    CIRCLE(int(XX1+225),int(ZP+75)),2,1,,,aspect	{target x-z}
    CIRCLE(int(XX2+75),int(YY2+75)),1,5,,,aspect     	{intruder x-y}
    CIRCLE(int(XX2+225),int(2*ZZ2+75)),1,5,,,aspect   	{intruder x-z}
    {place stars on screen}
    FOR I=1 TO NS
      XP=int(X(I)-XC)
      YP=int(Y(I)-YC)
      ZP=2*(Z(I)-ZC)
      PSET(int(XP+75),int(YP+75)),1
      PSET(int(XP+225),int(ZP+75)),1
    NEXT
END SUB

SUB define_galaxies
shared 	X,Y,VX,VY,Z,VZ
shared	NRR,NRS,NS,DR    
shared	M1,M2  
shared	X1,Y1,Z1
shared	X2,Y2,Z2
shared  VX1,VY1,VZ1
shared  VX2,VY2,VZ2   
shared	NTSPR,sim_time
longint	IR,IT,I
single	R,RV,T,T1,TH,V
 PRINT
 PRINT "*** Defining structure & position" 
 PRINT "    of galaxies. Please wait."
 {initialise TARGET galaxy mass,
  position and velocity}
 M1=5
 X1=150
 Y1=100
 Z1=0
 VX1=0
 VY1=0
 VZ1=0
 {scale the INTRUDER galaxy mass,
  position and velocities.}
 sim_time=0
 M2=M2*M1
 X2=X2+X1
 Y2=Y2+Y1
 Z2=Z2+Z1
 {setup initial load
  place stars in concentric rings
  from r=10 to r=30 at intervals of DR}
 FOR IR=1 TO NRR
    R=10+(IR-1)*DR
    V=SQR(M1/R)
    TH=(0.5*V/R)*(180/3.14159)
    IF R=10 THEN V=0.9*V
    FOR IT=1 TO NRS
        T=(IT-1)*360/NRS
        T1=3.14159*(T-TH)/180
        I=I+1      
        {initialise star positions}
        X(I)=R*COS(T/57.2958)+150
        Y(I)=R*SIN(T/57.2958)+100
        VZ(I)=0
        Z(I)=0
        {initialise star velocities to place them in circular
         orbits about the TARGET galaxy.}
        VX(I)=-V*SIN(T1)
        VY(I)=V*COS(T1)
    NEXT
 NEXT
END SUB

SUB particle_pusher
shared 	X,Y,VX,VY,Z,VZ
shared	NRR,NRS,NS,DR    
shared	M1,M2  
shared	X1,Y1,Z1
shared	X2,Y2,Z2
shared  VX1,VY1,VZ1
shared  VX2,VY2,VZ2   
shared	NTSPR,sim_time
longint	I,J,K
single	R1,R2
single	AX,AY,AZ
single	RR 
single	Ex,Ey,Ez
    FOR K=1 TO NTSPR 
        FOR J=1 TO 1 
            FOR I=1 TO NS
             {determine the force on a star
              due to the galactic centres
              SF2 below, called the softening factor,
              is used to prevent overflows
              during force calculations
              SF2 is assigned a value above.
              You may experiment with its value
              but it should be kept as small as possible
              to better approximate a true 1/r**2 force.}
              Ex=(X(I)-X1)^2
              Ey=(Y(i)-Y1)^2
              Ez=(Z(i)-Z1)^2
              R1=M1/(Ex+Ey+Ez+SF2)^1.5
              Ex=(X(I)-X2)^2
              Ey=(Y(i)-Y2)^2
              Ez=(Z(i)-Z2)^2
              R2=M2/(Ex+Ey+Ez+SF2)^1.5
              {calculate stars x,y,z accelerations}
              AX=R1*(X1-X(I))+R2*(X2-X(I))
              AY=R1*(Y1-Y(I))+R2*(Y2-Y(I))
              AZ=R1*(Z1-Z(I))+R2*(Z2-Z(I))
              {update star positions and velocities
               using a time centred leap-frog algorithm}
              VX(I)=VX(I)+AX
              VY(I)=VY(I)+AY
              VZ(I)=VZ(I)+AZ
              X(I)=X(I)+VX(I)
              Y(I)=Y(I)+VY(I)
              Z(I)=Z(I)+VZ(I)
              if inkey$<>"" then exit sub
            NEXT
          {update positions
           and velocities of the galactic centres}
           Ex=(X1-X2)^2
           Ey=(Y1-Y2)^2
           Ez=(Z1-Z2)^2
           RR=(Ex+Ey+Ez+SF2)^1.5
           AX=(X2-X1)/RR
           AY=(Y2-Y1)/RR
           AZ=(Z2-Z1)/RR
           VX1=VX1+M2*AX
           VY1=VY1+M2*AY
           VZ1=VZ1+M2*AZ
           VX2=VX2-M1*AX
           VY2=VY2-M1*AY
           VZ2=VZ2-M1*AZ
           X1=X1+VX1
           Y1=Y1+VY1
           Z1=Z1+VZ1
           X2=X2+VX2
           Y2=Y2+VY2
           Z2=Z2+VZ2
           ++sim_time
        NEXT
        update_display
     NEXT   
END SUB

SUB continue
shared 	NTSPR
string 	ans
    color 2
    locate 24
    PRINT "   Continue simulation? (y/n)"
    repeat
      ans = ucase$(inkey$)
    until ans="Y" or ans="N"
    if ans="Y" then 
      continue=true
      locate 24
      PRINT "   Enter number of time steps: ";
      input NTSPR
    else 
      continue=false
    end if
END SUB

SUB finished 
string ans
  cls
  color 5
  locate 12,8
  PRINT "Another Simulation? (y/n)"
  repeat
    ans=ucase$(inkey$)
  until ans="Y" or ans="N"
  if ans="N" then finished=true else finished=false
END SUB

SUB open_hires
  SCREEN 2,640,225,2,2
  WINDOW 2,,(0,0)-(640,225),32,2
  palette 0,0,0,0	'..black
  palette 1,1,1,1	'..white
  palette 2,1,1,0.13	'..yellow
  palette 3,1,0,0	'..red
  FONT "topaz",8
  color 1
END SUB

SUB close_hires
  WINDOW CLOSE 2
  SCREEN CLOSE 2
END SUB

{ ** main ** }  
SCREEN 1,320,225,3,1
WINDOW 1,,(0,0)-(320,225),32,1
palette 0,0,0,0		'..black
palette 1,1,1,1		'..white
palette 2,1,0,0		'..red
palette 3,0,1,0		'..green
palette 4,0,0,1		'..blue
palette 5,1,1,0.13	'..yellow

FONT "topaz",8

color 1

    argument = args_present

    repeat  
      if not argument then 
        open_hires
        title
        instructions 
        if entry_method = SIM then
          get_simulation
        else
          get_parameters
        end if
        define_galaxies 
        close_hires
        update_display
      else
        define_galaxies
	update_display
        argument=false
      end if
      repeat   
        particle_pusher
      until not continue
    until finished

WINDOW CLOSE 1
SCREEN CLOSE 1
