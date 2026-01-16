{*
** This program demonstrates how the existence of a directory
** or file can be determined.
**
** Author: David J Benn
**   Date: 14th March 1995
*}

'..Constants.
CONST null = 0&
CONST ACCESS_READ = -2&
CONST NONEXISTENT = 0, ISAFILE = -3, ISADIR = 2

'..Structure definitions.
STRUCT FileInfoBlock
  longint fib_DiskKey
  longint fib_DirEntryType
  string  fib_FileName size 108
  longint fib_Protection
  longint fib_EntryType
  longint fib_Size
  longint fib_NumBlocks
  string  fib_Date size 12
  string  fib_Comment size 80
  string  fib_Reserved size 36
END STRUCT

'..Shared library function declarations.
DECLARE FUNCTION LONGINT Lock library dos
DECLARE FUNCTION UnLock library dos
DECLARE FUNCTION Examine library dos

'..Subprograms.
SUB SHORTINT EntryType(STRING dname)
LONGINT myLock
DECLARE STRUCT FileInfoBlock info

  myLock = Lock(dname,ACCESS_READ) 

  IF myLock <> null then
    Examine(myLock,info)
    UnLock(mylock)
    EntryType = info->fib_EntryType
  ELSE
    EntryType = NONEXISTENT
  END IF
END SUB

SUB Usage
  PRINT
  PRINT "usage: ";ARG$(0);" directory-name"
END SUB

'..Main.
IF ARGCOUNT <> 1 THEN
  Usage
ELSE
  theName$ = ARG$(1)
  type = EntryType(ARG$(1))
  CASE
    type = NONEXISTENT : PRINT theName$;" does not exist."
    type = ISAFILE     : PRINT theName$;" is a file."
    type = ISADIR      : PRINT theName$;" is a directory."
  END CASE
END IF
