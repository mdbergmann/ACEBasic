/*
** Get files/directories specified by a pattern.
** Recurse into directories if "all" is part of the pattern.
**
** Author: David J Benn
**   Date: 25th August 1996
*/

#include <dos/dos.h>
#include <dos/dosasl.h>
#include <funcs/dos_funcs.h>

DefLng a-z

Const BUFSZ = 1024

Sub Usage
  Print "usage: ";Arg$(0);" file-pattern"
End Sub

Sub Abort
/*
** Quits but does no cleanup!
*/
  Print Arg$(0);": ***break!"
  Stop
End Sub

Sub VisitFiles(pat$, allFiles)
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

  anchor = Alloc(Sizeof(AnchorPath)+BUFSZ)
  If anchor = NULL Then 
    Print Arg$(0);": Memory allocation error!"
  Else
    anchor->ap_StrLen = BUFSZ
    result = MatchFirst(pat$, anchor)
    While result <> ERROR_NO_MORE_ENTRIES
      Print anchor->ap_Buf;
      FileInfo = @anchor->ap_Info
      If fileInfo->fib_DirEntryType > 0 Then
        Print " [DIR]"
        If allFiles Then Call VisitFiles(anchor->ap_Buf+"/#?", allFiles)
      Else
	Print
      End If
      result = MatchNext(anchor)
    Wend
    MatchEnd(anchor)
  End If
End Sub

/*
** Main.
*/
If Argcount >= 1 Then
  On Break Call Abort : Break On

  /*
  ** Construct the pattern from potentially multiple arguments.
  */
  pat$ = ""
  For i=1 To Argcount
    pat$ = pat$ + Arg$(i)
    If i <> Argcount Then pat$ = pat$ + " "
  Next
  If Ucase$(Right$(pat$,4)) = " ALL" Then
    allFiles = TRUE
    pat$ = Left$(pat$,Len(pat$)-4)
  Else
    allFiles = FALSE
  End If

  VisitFiles(pat$, allFiles)
Else
  Usage
End If
