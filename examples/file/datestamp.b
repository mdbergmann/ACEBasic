{*
** Getting a file's DateStamp.
** Author: David J Benn
**   Date: 27th January 1995
*}

DEFLNG a-z

{*
** Constants.
*}
CONST ACCESS_READ = -2&
CONST NULL = 0&
CONST true = -1&, false = 0&

{*
** Structure definitions.
*}
STRUCT DateStamp
  LONGINT days
  LONGINT mins
  LONGINT ticks
END STRUCT

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

{*
** Shared library functions.
*}
DECLARE FUNCTION Lock& library dos
DECLARE FUNCTION UnLock library dos
DECLARE FUNCTION Examine library dos

{*
** Subprograms.
*}
SUB GetDateStamp(STRING fname, ADDRESS ds_addr)
LONGINT mylock
DECLARE STRUCT DateStamp *ds,*Date
DECLARE STRUCT FileInfoBlock info

  mylock = Lock(fname,ACCESS_READ) 

  IF mylock <> NULL THEN
    Examine(mylock,info)
    Date = @info->fib_Date
    ds = ds_addr
    ds->days  = Date->days
    ds->mins  = Date->mins
    ds->ticks = Date->ticks
    UnLock(mylock)
    GetDateStamp = true
  ELSE
    GetDateStamp = false
  END IF
END SUB

{*
** Main.
*}
DECLARE STRUCT DateStamp stamp

IF ARGCOUNT = 1 THEN
  IF GetDateStamp(ARG$(1),stamp) THEN
    PRINT stamp->days;
    PRINT stamp->mins;
    PRINT stamp->ticks
  END IF
ELSE
  PRINT "usage: ";ARG$(0);" filename" 
END IF
