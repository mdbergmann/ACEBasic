'******************************************
'*              MakeReserved              *
'*   K.Veijalainen (veijalai@cc.lut.fi)   *
'*                                        *
'* For creating UppercACEr.Reserved-files *
'* from ACE's "words"-output files.       *
'*                                        *
'* Add new strings to be ignored in the   *
'* CASE-statement in main loop and        *
'* recompile when new ACE versions appear.*
'*                                        *
'* 31.7.1994 - Work started.              *
'******************************************

version$="MakeReserved for ACE2.16 by K.Veijalainen (veijalai@cc.lut.fi)"

'Get the parameters
IF argcount<1 THEN
	PRINT "You must specify the outputfile."
	PRINT "Usage: "+ARG$(0)+" <outputfile>"
	STOP
ELSE
	_outfile$=ARG$(1)
END IF

ON BREAK GOTO lopetus
BREAK ON

'Globally declare all variables as short int
DEFINT a-z,_

print "Creating temp file..."
SYSTEM "ACE words >t:ReservedTemp1"
'Sort the file to t:
print "Sorting..."
SYSTEM "sort t:ReservedTemp1 t:ReservedTemp"
kill "t:ReservedTemp1"

'Open the files.
open "I",1,"t:ReservedTemp"
open "O",2,_outfile$

'Gotta advertise a bit.. :-)
print version$
print #2,chr$(39)+version$

print "Creating "+_outfile$+"..."
ot$=""
while not eof(1)
	line input #1,t$
	'Remove the dollar signs
	if right$(t$,1)="$" then
		t$=left$(t$,len(t$)-1)
	end if
	l$=left$(t$,20)
	'Was this the same as the one before?
	if ot$<>t$ then
		'Add future lines to be ignored here! (20 characters!)
		CASE
			l$="ACE Amiga BASIC Comp" :  t$=""
			l$="AmigaBASIC RESERVED " :  t$=""
			l$="ACE-SPECIFIC RESERVE" :  t$=""
		END CASE
		'Output to _outfile$, if the line is not empty.
		if len(t$)>0 then print #2,t$
	end if
	ot$=t$
wend
print "Done."

lopetus:
	close #1
	close #2
	kill "t:ReservedTemp"
	stop
