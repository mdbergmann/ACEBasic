'..Messier Object Finder.

const true=-1&,false=0&
const sentinel=-1
const max_lines=15

shortint M
single MAG,DEC,RA
string OBJ$,CONSTEL$

'..main program
window 1,"Messier Finder",(0,0)-(640,200),6

font "topaz",8

finished=false

while not finished
main:
  restore
  color 1
  cls
  locate 2,10: print "Options..."
  locate 4,10: print "1. Show data for a single Messier object"
  locate 5,10: print "2. List all Messier objects in a constellation"  
  locate 6,10: print "3. List all Messier objects of a certain type"  
  locate 7,10: print "4. List all Messier objects"
  locate 8,10: print "5. Quit"
  locate 10,10:print "Select an option (1..5)"
  repeat
    opt$=inkey$
    Sleep
  until opt$>="1" and opt$<="5"
  if opt$="5" then 
    finished=true
  else
    on val(opt$) gosub one_obj,by_const,by_obj_type,all_objs
  end if
wend

window close 1
STOP

'..return to main menu upon ctrl-c break detection 
ON BREAK GOTO main
BREAK ON

SUB display_titles
   '..column headings
   print "M#";tab(10);" MAG";tab(20);" DEC";tab(30);" RA";tab(45);
   print "Object";tab(65);"Constellation"
   print "--";tab(10);" ---";tab(20);" ---";tab(30);" --";tab(45);
   print "------";tab(65);"-------------"
END SUB

SUB dm_form$(n,first$)
  '..convert n to hrs/degs & mins format
  '..hrs/degs
  dh$=str$(fix(n))		
  if n<10 then dh$=" 0"+right$(dh$,1)
  x$=dh$+first$
  '..mins
  mins=abs(n-fix(n))*60
  min$=str$(fix(mins))
  if mins<10 then min$=" 0"+right$(min$,1)
  x$=x$+min$+"m"
  '..return string		
  dm_form$=x$
END SUB

SUB show_data
SHARED M,MAG,DEC,RA,OBJ$,CONSTEL$
   '..object data
   print "M";M;tab(10);MAG;
   print tab(20);dm_form$(DEC,"d");tab(30);dm_form$(RA,"h");
   print tab(45);OBJ$;tab(65);CONSTEL$
END SUB

BREAK STOP
SUB await_return(msg$)
  print
  print msg$
  while inkey$<>chr$(13):Sleep:wend  
END SUB
BREAK ON

'*************************************

one_obj:
 '..display data about 1 Messier object.
 cls
 
 locate 2,10:input "Enter Messier number: ",mes_num

 REPEAT
  READ M, DEC, RA, MAG, OBJ$, CONSTEL$ 
 UNTIL M = mes_num or M = sentinel

 if M <> mes_num or M = sentinel then 
   locate 4,10:print "M";mes_num;"not found."
 else
   cls
   display_titles
   show_data
 end if

 await_return("Hit <return> for menu...")
RETURN

'*************************************

by_const:
  '..display data about objects in a given constellation.
  cls
  locate 2,10
  input "Enter name of constellation: ",target$
  target$=ucase$(target$)

  obj_count=0
  found=false

  cls
  display_titles

  repeat
    READ M, DEC, RA, MAG, OBJ$, CONSTEL$   
    CONSTEL$=ucase$(CONSTEL$)   
    if (instr(CONSTEL$,target$)or instr(target$,CONSTEL$)) and M<>sentinel then 
      ++obj_count
      found=true
      show_data
    end if
    if obj_count = max_lines then
      await_return("Hit <return> to continue...")
      cls
      display_titles
      obj_count=0
    end if  
  until M = sentinel  
 
  if not found then 
    print "No Messier objects were found in ";target$;"."
  end if

  await_return("Hit <return> for menu...")
RETURN

'*************************************

by_obj_type:
  '..display data about objects of a given type.
  cls
  locate 2,10: PRINT "Object types..."
  locate 4,10: PRINT "1. Diffuse Nebula"
  locate 5,10: PRINT "2. Planetary Nebula" 
  locate 6,10: PRINT "3. Globular Cluster"
  locate 7,10: PRINT "4. Open Cluster"
  locate 8,10: PRINT "5. Spiral Galaxy"
  locate 9,10: PRINT "6. Elliptical Galaxy"
  locate 10,10:PRINT "7. Irregular Galaxy"
  locate 11,10:PRINT "8. None"
  locate 13,10:PRINT "Select option (1..8)"
  BREAK STOP
  repeat
    opt$=inkey$
    Sleep
  until opt$>="1" and opt$<="8"
  BREAK ON
  opt=val(opt$)

  case
    opt=1 : target$="Diffuse Nebula" 
    opt=2 : target$="Planetary Nebula" 
    opt=3 : target$="Globular Cluster" 
    opt=4 : target$="Open Cluster" 
    opt=5 : target$="Spiral Galaxy" 
    opt=6 : target$="Elliptical Galaxy" 
    opt=7 : target$="Irregular Galaxy" 
    opt=8 : return
  end case

  obj_count=0
  found=false

  cls
  display_titles

  repeat
    READ M, DEC, RA, MAG, OBJ$, CONSTEL$      
    if OBJ$ = target$ and M <> sentinel then 
      ++obj_count
      found=true
      show_data
    end if
    if obj_count = max_lines then
      await_return("Hit <return> to continue...")
      cls
      display_titles
      obj_count=0
    end if  
  until M = sentinel  
 
  if not found then 
    print "No Messier objects of type: ";target$;" were found."
  end if

  await_return("Hit <return> for menu...")
RETURN

'*************************************

all_objs:
 '..display data about all Messier objects.
 obj_count=0

 cls
 display_titles

 REPEAT
  READ M, DEC, RA, MAG, OBJ$, CONSTEL$ 
  if M <> sentinel then 
    show_data
    ++obj_count
    if obj_count = max_lines then
      await_return("Hit <return> to continue...")
      cls
      display_titles
      obj_count=0
    end if  
  end if
 UNTIL M = sentinel

 await_return("Hit <return> for menu...")
RETURN

'************ Messier Data ********************* 
 DATA 1,21.59,05.31,9,"Diffuse Nebula","Taurus" 
 DATA 2,-01.03,21.31,7,"Globular Cluster","Aquarius" 
 DATA 3,28.38,13.40,7,"Globular Cluster","Canes Vena" 
 DATA 4,-26.24,16.21,6,"Globular Cluster","Scorpio" 
 DATA 5,02.16,15.16,6,"Globular Cluster","Serp Caput" 
 DATA 6,-32.11,17.37,6,"Diffuse Nebula","Sagittar" 
 DATA 7,-34.48,17.51,5,"Open Cluster","Scorpio" 
 DATA 8,-24.23,18.01,0,"Diffuse Nebula","Sagittar" 
 DATA 9,-18.28,17.62,8,"Globular Cluster","Ophiuchus" 
 DATA 10,-04.02,16.55,7,"Globular Cluster","Ophiuchus" 
 DATA 11,-06.20,18.48,6,"Open Cluster","Scutum" 
 DATA 12,-01.52,16.45,7,"Globular Cluster","Ophiuchus" 
 DATA 13,36.33,16.40,6,"Globular Cluster","Hercules" 
 DATA 14,-03.13,17.35,9,"Globular Cluster","Ophiuchus" 
 DATA 15,11.57,21.28,7,"Globular Cluster","Pegasus" 
 DATA 16,-13.48,18.16,7,"Open Cluster","Serp Cauda" 
 DATA 17,-16.12,18.18,7,"Diffuse Nebula","Sagittar" 
 DATA 18,-17.09,18.17,7,"Open Cluster","Sagittar" 
 DATA 19,-26.11,16.59,8,"Globular Cluster","Ophiuchus" 
 DATA 20,-23.02,17.59,0,"Diffuse Nebula","Sagittar" 
 DATA 21,-22.30,18.02,7,"Open Cluster","Sagittar" 
 DATA 22,-23.58,18.33,6,"Globular Cluster","Sagittar" 
 DATA 23,-19.01,17.54,7,"Open Cluster","Sagittar" 
 DATA 24,-18.30,18.14,5,"Open Cluster","Sagittar" 
 DATA 25,-19.17,18.29,6,"Open Cluster","Sagittar" 
 DATA 26,-09.27,18.43,8,"Open Cluster","Scutum" 
 DATA 27,22.35,19.58,8, "Planetary Nebula","Vulpecula" 
 DATA 28,-24.54,18.22,8,"Globular Cluster","Sagittar" 
 DATA 29,38.22,20.22,7,"Open Cluster","Cygnus" 
 DATA 30,-23.25,21.38,8,"Globular Cluster","Capricorn" 
 DATA 31,41.00,00.40,4,"Spiral Galaxy","Andromeda" 
 DATA 32,40.36,00.40,9,"Elliptical Galaxy","Andromeda" 
 DATA 33,30.24,01.31,6,"Spiral Galaxy","Triangulm" 
 DATA 34,42.34,02.39,6,"Open Cluster","Perseus" 
 DATA 35,24.21,06.06,6,"Open Cluster","Gemini" 
 DATA 36,34.06,05.33,6,"Open Cluster","Auriga" 
 DATA 37,32.32,05.49,6,"Open Cluster","Auriga" 
 DATA 38,35.48,05.25,7,"Open Cluster","Auriga" 
 DATA 39,48.13,21.30,5,"Open Cluster","Cygnus" 
 DATA 40,58.05,12.22,9,"Double Star ","Ursa Major" 
 DATA 41,-20.41,06.45,6,"Open Cluster","Canis Ma" 
 DATA 42,-05.25,05.33,0,"Diffuse Nebula","Orion" 
 DATA 43,-05.18,05.33,0,"Diffuse Nebula","Orion" 
 DATA 44,20.10,08.37,4,"Open Cluster","Cancer" 
 DATA 45,23.57,03.44,2,"Open Cluster","Taurus" 
 DATA 46,-14.42,07.40,7,"Open Cluster","Puppis" 
 DATA 47,-14.22,07.34,5,"Open Cluster","Puppis" 
 DATA 48,-05.38,08.11,6,"Open Cluster","Hydra" 
 DATA 49,08.16,12.27,9,"Elliptical Galaxy","Virgo" 
 DATA 50,-08.16,7.01,6,"Open Cluster","Monoceros" 
 DATA 51,47.27,13.28,9,"Spiral Galaxy","Canes Vena" 
 DATA 52,61.19,23.22,8,"Open Cluster","Cassiopeia" 
 DATA 53,18.26,13.11,8,"Globular Cluster","Coma Beren" 
 DATA 54,-30.32,18.52,8,"Globular Cluster","Sagittar" 
 DATA 55,-31.03,19.37,6,"Globular Cluster","Sagittar" 
 DATA 56,30.05,19.15,9,"Globular Cluster","Lyra" 
 DATA 57,32.58,18.52,9,"Planetary Nebula","Lyra" 
 DATA 58,12.05,12.35,10,"Spiral Galaxy","Virgo" 
 DATA 59,11.55,12.40,10,"Elliptical Galaxy","Virgo" 
 DATA 60,11.49,12.41,10,"Elliptical Galaxy","Virgo" 
 DATA 61,04.45,12.19,10,"Spiral Galaxy","Virgo" 
 DATA 62,-30.03,16.58,7,"Globular Cluster","Ophiuchus" 
 DATA 63,42.17,13.14,9,"Spiral Galaxy","Canes Vena" 
 DATA 64,21.57,12.54,8,"Spiral Galaxy","Coma Beren" 
 DATA 65,13.23,11.16,10,"Spiral Galaxy","Leo" 
 DATA 66,13.17,11.18,9,"Spiral Galaxy","Leo" 
 DATA 67,12.00,08.49,7,"Open Cluster","Cancer" 
 DATA 68,-26.29,12.37,9,"Globular Cluster","Hydra" 
 DATA 69,-32.23,18.28,8,"Globular Cluster","Sagittar" 
 DATA 70,-32.12,18.40,8,"Globular Cluster","Sagittar" 
 DATA 71,18.39,19.52,8,"Globular Cluster","Sagitta" 
 DATA 72,-12.44,20.51,9,"Globular Cluster","Aquarius" 
 DATA 73,-12.50,20.56,0,"(Four Stars)","Aquarius" 
 DATA 74,15.32,01.34,10,"Spiral Galaxy","Pisces" 
 DATA 75,-22.04,20.03,9,"Globular Cluster","Sagittar" 
 DATA 76,51.19,01.39,11,"Planetary Nebula","Perseus" 
 DATA 77,-00.14,02.40,10,"Spiral Galaxy","Cetus" 
 DATA 78,00.02,05.44,8,"Diffuse Nebula","Orion" 
 DATA 79,-24.34,05.22,8,"Globular Cluster","Lepus" 
 DATA 80,-22.52,16.14,8,"Globular Cluster","Scorpio" 
 DATA 81,69.18,09.52,7,"Spiral Galaxy","Ursa Major" 
 DATA 82,69.56,09.52,9,"Irregular Galaxy","Ursa Major" 
 DATA 83,-29.37,13.34,8,"Spiral Galaxy","Hydra" 
 DATA 84,13.10,12.23,10,"Elliptical Galaxy","Virgo" 
 DATA 85,18.28,12.23,10,"Elliptical Galaxy","Coma Beren" 
 DATA 86,13.13,12.24,10,"Elliptical Galaxy","Virgo" 
 DATA 87,12.40,12.28,10,"Elliptical Galaxy","Virgo" 
 DATA 88,14.42,12.30,10,"Spiral Galaxy","Coma Beren" 
 DATA 89,12.50,12.33,11,"Elliptical Galaxy","Virgo" 
 DATA 90,13.26,12.34,10,"Spiral Galaxy","Virgo" 
 DATA 91,14.30,12.35,9,"Unexplained ","Coma Beren" 
 DATA 92,43.12,17.16,7,"Globular Cluster","Hercules" 
 DATA 93,-23.45,07.43,6,"Open Cluster","Puppis" 
 DATA 94,41.23,12.49,9,"Spiral Galaxy","Canes Vena" 
 DATA 95,11.58,10.41,10,"Spiral Galaxy","Leo" 
 DATA 96,12.05,10.44,10,"Spiral Galaxy","Leo" 
 DATA 97,55.18,11.12,11,"Planetary Nebula","Ursa Major" 
 DATA 98,15.11,12.11,10,"Spiral Galaxy","Coma Beren" 
 DATA 99,14.42,12.16,10,"Spiral Galaxy","Coma Beren" 
 DATA 100,16.06,12.20,10,"Spiral Galaxy","Coma Beren" 
 DATA 101,54.35,14.01,8,"Spiral Galaxy","Ursa Major" 
 DATA 103,60.26,01.30,7,"Open Cluster","Cassiopeia" 
 DATA 104,-11.21,12.37,8,"Spiral Galaxy","Virgo" 
 DATA 105,12.51,10.45,10,"Elliptical Galaxy","Leo" 
 DATA 106,47.35,12.17,9,"Spiral Galaxy","Canes Vena" 
 DATA 107,-12.57,16.30,9,"Globular Cluster","Ophiuchus" 
 DATA 108,55.57,11.09,10,"Spiral Galaxy","Ursa Major" 
 DATA 109,53.39,11.55,10,"Spiral Galaxy","Ursa Major" 
 DATA -1,0,0,0,"",""	'..sentinel
