/* 
** This program copies source files to a destination 
** directory/volume. Wildcards are supported. Recurses 
** into directories if "all" is part of the pattern and
** directories are created as necessary.
**
** Files are copied piece-wise according to a CHUNK 
** size. This permits slow/dodgy devices (eg. my 100M 
** SCSI Zip drive on an A1200 Ferret SCSI interface can't 
** handle big (~0.5M) files correctly).
**
** Known Bugs: Assumes that all path components higher
** than the ones to be visited exist, eg. if we're
** trying to create the directory 1.3 in ACE:bin/1.3
** when supplying the pattern "ACE:bin/#? all", then
** ACE:bin must already exist. So, it's best to choose
** a source which is high-level and can be recursed into.
** An obvious solution to this bug is to call a SUB which
** examines all path components and creates any that don't
** exist. Use Examine and ExAll for this? Or just take
** substrings delimited by ":" and "/"? 
**
** Author: David J Benn
**   Date: 29th December 1994,
**	   15th July 1996,
**  	   25th,26th,27th August 1996
*/

#include <exec/memory.h>
#include <dos/dos.h>
#include <dos/dosasl.h>
#include <funcs/exec_funcs.h>
#include <funcs/dos_funcs.h>

DefLng a-z

Library "exec.library"

Const FILEPATHSZ = 1024	/* size of file pathname */
Const CHUNK = 10240	/* copy files in 10K chunks */

Declare Sub Abort
Declare Sub CopyFile(src$,dest$)

On Break Call Abort : Break On

SUB Usage
    PRINT "usage: ";ARG$(0);" file-pattern [...] destination"
    STOP
END SUB

Sub Abort
/*
** Quits but does no cleanup!
*/
  Print Arg$(0);": ***break!"
  Library Close
  Stop
End Sub

Sub VisitFiles(pat$, dest$, allFiles)
/*
** Visit each file specified by the pattern.
** If the pattern contains "all", this function
** is called recursively. Each recursive call
** requires a new AnchorPath structure variable
** so that previous pattern match states aren't
** affected. 
*/
Declare Struct AnchorPath *anchor
Declare Struct FileInfoBlock *fileInfo

  /*
  ** Allocate a structure for the search.
  */
  anchor = AllocMem(Sizeof(AnchorPath)+FILEPATHSZ, MEMF_ANY Or MEMF_CLEAR)
  If anchor = NULL Then 
    Print Arg$(0);": Memory allocation error!"
  Else
    /*
    ** Set file path buffer length.
    */
    anchor->ap_StrLen = FILEPATHSZ

    /*
    ** Pattern-based search.
    */
    result = MatchFirst(pat$, anchor)
    While result <> ERROR_NO_MORE_ENTRIES
      /*
      ** Get the path.
      */
      path$ = anchor->ap_Buf

      /*
      ** Get the path minus the first directory
      ** or volume name.
      */
      destFilePart$ = path$
      posn = Instr(destFilePart$,":")
      If posn > 0 Then 
        destFilePart$ = Mid$(destFilePart$,posn+1)
      Else
        posn = Instr(destFilePart$,"/")
	If posn > 0 Then
	  destFilePart$ = Mid$(destFilePart$,posn+1)
	End If
      End If

      /*
      ** Is this a directory or file? If the former,
      ** does it need to be created? Otherwise, just
      ** copy the file. 
      */
      fileInfo = @anchor->ap_Info
      If fileInfo->fib_DirEntryType > 0 Then
      	/*
	** Try to create the directory. If it
 	** fails, either it already exists or
	** we don't have any space left.
	*/
	dirLock = CreateDir(dest$+destFilePart$)
        If dirLock Then 
	  Print path$;" [directory created]"
	  UnLock(dirLock)
	Else 
	  Print path$;" [directory]"
	End If

        /*
        ** Visit this directory recursively?
        */
        If allFiles Then Call VisitFiles(path$+"/#?", dest$, allFiles)
      Else
	/*
	** Copy the file then sleep for awhile to let 
	** the destination device (eg. Zip) to catch 
	** up if need be.
	*/
	CopyFile(path$, dest$+destFilePart$)
	Sleep For .25
      End If
      result = MatchNext(anchor)
    Wend

    /*
    ** Clean up resources associated with this search.
    */
    If anchor Then 
      MatchEnd(anchor)
      FreeMem(anchor, Sizeof(AnchorPath)+FILEPATHSZ)
    End If
  End If
End Sub

Sub ReportFileError(n) 
    CASE
	n = 1 : PRINT "Unable to open source file."
	n = 2 : PRINT "Source file empty."
	n = 3 : PRINT "Unable to allocate memory for file buffer."
	n = 4 : PRINT "Error while reading from source file."
	n = 5 : PRINT "Unable to open destination file."
	n = 6 : PRINT "Error while writing to destination file."
    END CASE
    CLOSE #1
    CLOSE #2
End Sub

Sub CopyFile(src$, dest$)
/*
** Copy a file from the specified full source path
** to the specified full destination path.
*/ 
ADDRESS src,dest,buf 
LONGINT length,bytes,bytes_read,bytes_written,total

  Print src$;" -> ";dest$

  OPEN "I",#1,src$ 
  src = HANDLE(1) : IF src = NULL THEN CALL ReportFileError(1) 
  bytes = LOF(1)
  OPEN "O",#2,dest$ 
  dest = HANDLE(2) : IF dest = NULL THEN CALL ReportFileError(5)
  IF bytes = 0 THEN CALL ReportFileError(2) 
  If bytes > CHUNK Then length = CHUNK Else length = bytes
  buf = AllocMem(length, MEMF_ANY Or MEMF_CLEAR)
  IF buf = NULL THEN CALL ReportFileError(3) 
  While Not Eof(1)
    bytes_read = _Read(src,buf,length)
    If bytes_read = -1 THEN 
      ReportFileError(4) 
    Else
      If bytes_read <> 0 Then
        bytes_written = _Write(dest,buf,bytes_read)
        If bytes_written <> bytes_read THEN CALL ReportFileError(6)
        total = total + bytes_written
      End If
    End If
    Print "Written";total;"bytes (";Str$((total*100)\bytes);"% )";Chr$(13);
  Wend
  If buf Then Call FreeMem(buf,length)
  Print
  CLOSE #2 
  CLOSE #1 
End Sub

/*
** Main.
*/
If Argcount >= 2 Then
  /*
  ** Construct the pattern from potentially multiple arguments.
  ** There must be at least two arguments the last of which is
  ** asumed to be a destination directory/volume (see usage).
  */
  pat$ = ""
  For i=1 To Argcount-1
    pat$ = pat$ + Arg$(i)
    If i <> Argcount-1 Then pat$ = pat$ + " "
  Next
  If Ucase$(Right$(pat$,4)) = " ALL" Then
    allFiles = TRUE
    pat$ = Left$(pat$,Len(pat$)-4)
  Else
    allFiles = FALSE
  End If

  /*
  ** Make sure we have a semi-sane destination.
  */
  dest$ = Arg$(Argcount)
  If Right$(dest$,1) <> ":" And Right$(dest$,1) <> "/" Then 
    dest$ = dest$ + "/"
  End If

  /*
  ** Go to it.
  */
  VisitFiles(pat$, dest$, allFiles)
Else
  Usage
End If
