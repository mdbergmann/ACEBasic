' Program: nocaps.b
' Written by: Dan Oberlin
'
' Takes multiple filenames as CLI arguments and renames the files to
' their lowercase equivalents.  Nice for easily renaming those IBM
' files you may download.
 
FOR i% = 1 TO ARGCOUNT
	newname$ = ""
	FOR j% = 1 TO LEN(ARG$(i%))
	k% = ASC(MID$(ARG$(i%),j%,1))
	IF k% >= &H41 AND k% <= &H5a THEN
		newname$ = newname$+chr$(k%+&H20)
	ELSE
		newname$ = newname$+chr$(k%)
	END IF
	NEXT
	SYSTEM "rename "+ARG$(i%)+" "+newname$
NEXT
