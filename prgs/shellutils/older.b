{ An example of structures and library functions at work
  to compare the datestamps of two files.

  Author: David Benn
    Date: 31st December 1993,
	  5th January 1994 }

DEFLNG a-z

CONST NOT_OLDER=0,OLDER=5	 '..WARN=5 in a shell script

'..structure definitions
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

'..subprograms
SUB get_file_datestamp(STRING fname,ADDRESS ds_addr)
CONST ACCESS_READ = -2&
CONST NULL = 0&

LONGINT mylock

DECLARE STRUCT DateStamp *ds,*Date
DECLARE STRUCT FileInfoBlock file_info

DECLARE FUNCTION Lock& library dos
DECLARE FUNCTION UnLock library dos
DECLARE FUNCTION Examine library dos

  ds = ds_addr
  mylock = Lock(fname,ACCESS_READ) 

  if mylock <> NULL then
    Examine(mylock,file_info)
    Date = @file_info->fib_Date
    ds->days  = Date->days
    ds->mins  = Date->mins
    ds->ticks = Date->ticks
    UnLock(mylock)
  end if
END SUB

SUB usage
  print 
  print "usage: ";arg$(0);" file1 file2"
  print
  print "Typical usage in a shell script is:"
  print
  print "	 FAILAT 11" 
  print
  print "	 ";arg$(0);" >NIL: file1 file2"
  print
  print "	 IF WARN"
  print "	   ."
  print "	   ."
  print "	 ENDIF"
  print
END SUB

'..main
DECLARE STRUCT DateStamp stamp1,stamp2

if argcount=2 then
  get_file_datestamp(arg$(1),stamp1)
  get_file_datestamp(arg$(2),stamp2)

  d1=stamp1->days
  d2=stamp2->days
  m1=stamp1->mins
  m2=stamp2->mins
  t1=stamp1->ticks
  t2=stamp2->ticks

  if (d2>d1) or (d2=d1 and m2>m1) or (d2=d1 and m2=m1 and t2>t1) then 
    print arg$(1);" is older than ";arg$(2);"."
    SYSTEM OLDER
  else
    print arg$(1);" is not older than ";arg$(2);"."
    SYSTEM NOT_OLDER
  end if
else
  usage
end if

END
