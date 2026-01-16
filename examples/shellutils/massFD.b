{*
** Process each FD file in a specified directory and copy the resulting
** bmap file to the ACEbmaps: directory.
**
** FD filenames must end in "_lib.fd" to be recognised as valid FD
** files here.
**
** This program assumes the existence of ACE:utils/fd2bmap/fd2bmap.
**
** More sanity checks could be added.
**
** Author: David J Benn
**   Date: 18th November 1994
*}

SUB cleanup
  CLOSE #1
  KILL "ram:my_FD_dir"
END SUB

IF ARGCOUNT<>1 THEN
  PRINT "usage: ";ARG$(0);" source-directory"
ELSE
  ON BREAK GOTO quit
  BREAK ON
  theDir$ = ARG$(1)
  FILES TO "ram:my_FD_dir", theDir$
  IF RIGHT$(theDir$,1) <> ":" THEN theDir$ = theDir$+"/"   '..dir or volume?
  OPEN "I",#1,"ram:my_FD_dir"
  IF NOT EOF(1) THEN LINE INPUT #1,f$	'..skip first line
  WHILE NOT EOF(1)
    LINE INPUT #1,f$
    IF UCASE$(RIGHT$(f$,7)) <> "_LIB.FD" THEN
      PRINT f$;" -> not a valid FD file."
    ELSE
      PRINT f$;" -> converting - ";
      SYSTEM "ACE:utils/fd2bmap/fd2bmap >NIL: "+ ~
             theDir$+LEFT$(f$,INSTR(f$,"_")-1)+" ACEbmaps:"
      PRINT "done."
    END IF
  WEND
  cleanup
END IF
STOP

quit:
  PRINT "**Break: ";ARG$(0);" terminating!"
  cleanup
END
