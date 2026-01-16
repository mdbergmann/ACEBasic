{* 
** This program reads a file into a dynamically allocated string 
** buffer.
**
** The section delimited by "***" is the guts of the program. The
** rest is just support code.
**
** See also the ACE docs re: INPUT$ for a similar but more limited
** method.
*}

CONST NULL = 0&

ADDRESS fh, buf
LONGINT length, count

DECLARE FUNCTION LONGINT xRead(ADDRESS fileHandle, ADDRESS buffer, ~
		               LONGINT length) LIBRARY

SUB quit(SHORTINT errNum)
  CASE
	errNum = 0 : PRINT "Unable to open file."
	errNum = 1 : PRINT "Unable to allocate memory." : CLOSE #1
	errNum = 2 : PRINT "Read error." : CLOSE #1
  END CASE

  STOP		'..Quit.
END SUB

theFile$ = FILEBOX$("Select a text file:")

'***
OPEN "I",#1,theFile$			'..Open file for input.
fh = HANDLE(1)				'..Get AmigaDOS file handle.
IF fh = NULL THEN CALL quit(0)
length = LOF(1)				'..Get length of file in bytes.
buf = ALLOC(length)+1			'..Allocate an ASCII-0 filled buffer.
IF buf = NULL THEN CALL quit(1)
count = xRead(fh, buf, length)		'..Read file contents into buffer.
IF count <> length THEN CALL quit(2)
CLOSE #1
'***

STRING myFileBytes ADDRESS buf		'..Associate buffer with a string.

PRINT myFileBytes			'..Do something with the string.
PRINT
PRINT LEFT$(myFileBytes,80)
