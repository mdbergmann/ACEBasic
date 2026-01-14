{* 
** A test of ACE's implementation of random files.
**
** D Benn, 10th,11th,15th March 1996
*}

String theName Size 20
String phoneNum Size 15
Shortint age

Longint bytesRead

Struct person
  String theName Size 20
  String phoneNum Size 16
  Shortint age
End Struct

Declare Struct person X,Y

Sub HandleBreak
  Print "*** terminating!"
  Stop
End Sub

On Break Call HandleBreak : Break On

Kill "ram:people.db"

{* 
** Write some people.
** Error 205 = AmigaDOS error: Object not found. This
** will be returned if the file does not exist but can
** be ignored if we want to create a new file.
*}
Open "R",#1,"ram:people.db"
theError = Err
If theError = 0 Or theError = 205 Then
  Repeat
    Read theName
    If theName <> "" Then
      Read phoneNum, age
      X->theName = theName
      X->phoneNum = phoneNum
      X->age = age
      Put #1,X
    End If
  Until theName = ""

  {* Test whether we can read a record in the midst of writing. *}
  Get #1,Y,2 : Print "** Seek Test: ";Y->theName;" **" : Print

  {* Write a record out beyond the current EOF. *}
  X->theName = "Test"
  X->phoneNum = "911"
  X->age = 96
  Put #1,X,6   

  Close #1
End If  

Data "David Benn", "444 432", 32
Data "Karen Benn", "327 496", 30
Data "Jessie", "261 461", 2
Data "Marmaduke", "261 461", 6
Data ""

{* 
** Read them back and display them. 
*}
Open "R",#1,"ram:people.db"
If Err = 0 Then
  While Not Eof(1)
    Get #1,X
    bytesRead = Loc(1)
    Print "<<Record";Str$(bytesRead\Sizeof(X));">>"
    Print " Name: ",X->theName
    Print "Phone: ",X->phoneNum
    Print "  Age: ",X->age
    Print
  Wend
  Close #1
End If  
