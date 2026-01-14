{*
** An example of shared library function usage in ACE.

** Note that to call any shared library function from ACE,
** there are three requirements:

**	1. You must open the library in question.
**	2. You must declare the function.
**	3. A .bmap file for the library must be 
**	   present in the ACEbmaps: directory.
 
** For this program, the required bmaps are dos.bmap and
** graphics.bmap.

** Note that one of the function declarations below shows how 
** the library can be specified. This will result in a faster
** lookup by directing ACE to the correct .bmap file (see "DateStamp").

** Note also how the optional parameter-list can be specified for a 
** function (see "Text"). This is useful for documentation purposes.
*}

LIBRARY "graphics.library"
LIBRARY "dos.library"

DECLARE FUNCTION VBeamPos& LIBRARY
DECLARE FUNCTION Text(Rp&,text$,length&) LIBRARY
DECLARE FUNCTION Move LIBRARY 
DECLARE FUNCTION SetSoftStyle LIBRARY
DECLARE FUNCTION DrawEllipse LIBRARY
DECLARE FUNCTION DateStamp LIBRARY "dos.library"

CLS

COLOR 1
DrawEllipse(window(8),100,100,50,25)

PRINT "Vertical beam position =";VBeamPos

hello$="Hi there"
addr&=VARPTR(hello$)

COLOR 2
Move(WINDOW(8),100,100)
SetSoftStyle(WINDOW(8),1&,255&)  {* underline *}
Text(WINDOW(8),addr&,CINT(LEN(hello$)))
COLOR 1

DIM v&(2)
DateStamp(varptr(v&))
PRINT "Time =";v&(1)\60;":";v&(1) mod 60;":";v&(2)\50

LIBRARY CLOSE
