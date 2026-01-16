          {* 
	  ** This program copies a source file to a destination file
	  ** using dos.library functions for speed.
	  ** Originally written as an example program for an ACE user
	  ** in Budapest! The current version has better error reporting
	  ** and handles command-line arguments.
	  **
	  ** Author: David J Benn
	  **   Date: 29th December 1994
	  *}
	  DECLARE FUNCTION _Read&(fh,buf,length) LIBRARY dos 
          DECLARE FUNCTION _Write&(fh,buf,length) LIBRARY dos 
	  SUB usage
	    PRINT "usage: ";ARG$(0);" src dest"
	    STOP
	  END SUB
          SUB ReportError(n) 
	    CASE
		n = 1 : PRINT "Unable to open source file."
		n = 2 : PRINT "Source file empty."
		n = 3 : PRINT "Unable to allocate memory for source file buffer."
		n = 4 : PRINT "Error while reading from source file."
		n = 5 : PRINT "Unable to open destination file."
		n = 6 : PRINT "Error while writing to destination file."
	    END CASE
            CLOSE #1 : STOP 
          END SUB 
          ADDRESS fh, buf 
          LONGINT length 
	  IF ARGCOUNT <> 2 THEN CALL usage
          src$ = ARG$(1) : dest$ = ARG$(2)
          OPEN "I",#1,src$ 
          fh = HANDLE(1) : IF fh = 0 THEN CALL ReportError(1) 
          length = LOF(1) : IF length = 0 THEN CALL ReportError(2) 
          buf = ALLOC(length) : IF buf = 0 THEN CALL ReportError(3) 
          IF _Read(fh,buf,length) <> length THEN CALL ReportError(4) 
          CLOSE #1 
          OPEN "O",#1,dest$ 
          fh = HANDLE(1) : IF fh = 0 THEN CALL ReportError(5) 
          IF _Write(fh,buf,length) <> length THEN CALL ReportError(6) 
          CLOSE #1 
          END
