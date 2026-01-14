/*
** WorkBench argument and ToolType subprograms.
**
** Workbench arguments are contained in the
** WBStartup structure's ArgList after
** a program has been launched from the
** Workbench or an icon with a default tool
** has been double-clicked.
**
** The order in which the arguments appear in
** the list is the same as the order in which
** the icons (corresponding to the arguments)
** were selected with the mouse.

    Wb Argument Subprograms
    -----------------------
  - WBlaunched returns TRUE or FALSE to indicate whether
    the current program was started from the Workbench		
    or not.

  - WBargcount returns the number of arguments
    to a Workbench launched program. The name
    of the program is NOT included in this count.		

  - WBarg$(N) returns the Nth Workbench argument
    as a string. The zeroth argument is the
    program's name. Only the name of the argument
    is returned, not it's full path. To obtain
    the latter, use WBargPath$(N).				

  - WBargPath$(N) returns the full path of the
    Nth Workbench argument as a string.			


    ToolType Subprograms
    --------------------
  - ToolTypeVal$(theArg$,toolType$) searches the
    Wb argument's .info file for the specified tooltype
    and returns its value as a string. The null string
    is returned if the tooltype is not found.

  - ToolTypeValMatched(toolVal$,value$) returns
    TRUE or FALSE indicating the presence or absence
    of a value in a ToolType string.

  - DefaultTool$(theArg$) returns the default tool from
    a Wb argument's .info file. The NULL string is returned
    if no default tool exists or if the argument does not
    correspond to a project icon.

** Author: David J Benn
**   Date: 25th December 1992,
** 	   29th,30th December 1994,
**	   5th March 1995,
**	   11th September 1996
*/

#include <ace/acedef.h>

{*
** External references.
*}
EXTERNAL ADDRESS WBenchMsg	/* Task's WBStartup MESSAGE (from startup.lib). */

{*
** Structure definitions.
** These could instead be included via the appropriate 
** header files in ACEinclude:. 
*}
STRUCT WBArg
  ADDRESS wa_Lock
  ADDRESS wa_Name
END STRUCT

STRUCT Node
  ADDRESS ln_Succ
  ADDRESS ln_Pred
  BYTE    ln_Type
  BYTE    ln_Pri
  ADDRESS ln_Name
END STRUCT

STRUCT _Message
  Node     mn_Node
  ADDRESS  mn_ReplyPort
  SHORTINT mn_Length
END STRUCT

STRUCT WBStartup
  _Message sm_Message
  ADDRESS  sm_Process
  ADDRESS  sm_Segment
  LONGINT  sm_NumArgs
  ADDRESS  sm_ToolWindow
  ADDRESS  sm_ArgList
END STRUCT

STRUCT DateStamp
  LONGINT ds_Days
  LONGINT ds_Minute
  LONGINT ds_Tick
END STRUCT

STRUCT FileInfoBlock
  LONGINT   fib_DiskKey
  LONGINT   fib_DirEntryType
  STRING    fib_FileName SIZE 108
  LONGINT   fib_Protection
  LONGINT   fib_EntryType
  LONGINT   fib_Size
  LONGINT   fib_NumBlocks
  DateStamp fib_Date
  STRING    fib_Comment SIZE 80
  STRING    fib_Reserved SIZE 36
END STRUCT

STRUCT _Gadget
  ADDRESS  NextGadget
  SHORTINT LeftEdge
  SHORTINT TopEdge
  SHORTINT Wdth
  SHORTINT Height
  SHORTINT Flags
  SHORTINT Activation
  SHORTINT GadgetType
  ADDRESS  GadgetRender
  ADDRESS  SelectRender
  ADDRESS  GadgetText
  LONGINT  MutualExclude
  ADDRESS  SpecialInfo
  SHORTINT GadgetID
  ADDRESS  UserData
END STRUCT

STRUCT DiskObject
  SHORTINT do_Magic
  SHORTINT do_Version
  _Gadget  do_Gadget
  SHORTINT do_Type
  ADDRESS  do_DefaultTool
  ADDRESS  do_ToolTypes
  LONGINT  do_CurrentX
  LONGINT  do_CurrentY
  ADDRESS  do_DrawerData
  ADDRESS  do_ToolWindow
  LONGINT  do_StackSize
END STRUCT

{*
** Shared library functions used by more than one subprogram.
*}
DECLARE FUNCTION ADDRESS GetDiskObject(STRING theIconName) LIBRARY icon
DECLARE FUNCTION FreeDiskObject(ADDRESS diskObject) LIBRARY icon

{*
** Subprogram definitions.
*}
SUB LONGINT WBlaunched EXTERNAL

  { Was the program Wb-launched? }

  IF WBenchMsg <> NULL THEN
    WBlaunched = TRUE
  ELSE
    WBlaunched = FALSE
  END IF
END SUB

SUB SHORTINT WBargcount EXTERNAL
DECLARE STRUCT WBStartup *WBinfo
DECLARE STRUCT WBArg *argptr
SHORTINT n

  { Return # of WB args }

  WBinfo = WBenchMsg

  IF WBinfo <> NULL THEN
    n = WBinfo->sm_NumArgs
    --n  /* don't include WBarg$(0). */
    WBargcount = n
  ELSE
    WBargcount = 0
  END IF
END SUB

SUB WBarg$(SHORTINT N) EXTERNAL
DECLARE STRUCT WBStartup *WBinfo
DECLARE STRUCT WBArg *argptr
SHORTINT max_param,count

  { Return the Nth WB arg }

  WBinfo = WBenchMsg

  IF WBinfo <> NULL THEN
    max_param = WBinfo->sm_NumArgs
  ELSE
    max_param = 0
  END IF

  IF max_param > 0 AND N <= max_param THEN
    argptr = WBinfo->sm_ArgList

    count=0
    WHILE count < N
      argptr = argptr+SIZEOF(WBArg)
      ++count
    WEND

    WBarg$ = CSTR(argptr->wa_Name)
  ELSE
    {* Nth argument is non-existent. *}
    WBarg$ = ""
  END IF
END SUB

SUB ADDRESS WBargLock(SHORTINT N)
DECLARE STRUCT WBStartup *WBinfo
DECLARE STRUCT WBArg *argptr
SHORTINT max_param,count

  { Return the Nth WB arg lock }

  WBinfo = WBenchMsg

  IF WBinfo <> NULL THEN
    max_param = WBinfo->sm_NumArgs
  ELSE
    max_param = 0
  END IF

  IF max_param > 0 AND N <= max_param THEN
    argptr = WBinfo->sm_ArgList

    count=0
    WHILE count < N
      argptr = argptr+SIZEOF(WBArg)
      ++count
    WEND

    WBargLock = argptr->wa_Lock
  ELSE
    {* Nth lock is non-existent. *}
    WBargLock = NULL
  END IF
END SUB

SUB get_abs_path(ADDRESS lock, ADDRESS abspathaddr)
STRING abspath ADDRESS abspathaddr
ADDRESS parentlock
DECLARE STRUCT FileInfoBlock info

DECLARE FUNCTION ADDRESS ParentDir LIBRARY dos
DECLARE FUNCTION Examine LIBRARY dos

  { recursively construct absolute path }

  IF lock <> NULL THEN
    parentlock = ParentDir(lock)
    get_abs_path(parentlock,abspathaddr)
  END IF

  IF lock <> NULL THEN
    Examine(lock,info)
    abspath = abspath + info->fib_FileName
    IF parentlock <> NULL THEN
      {* directory *}
      abspath = abspath + "/"
    ELSE
      {* volume *}
      abspath = abspath + ":"
    END IF
  END IF
END SUB

SUB WBargPath$(SHORTINT N) EXTERNAL
ADDRESS arglock
STRING  abspath

  { Return full path of Nth WB arg }

  arglock = WBargLock(N)

  IF arglock <> NULL THEN
    get_abs_path(arglock,@abspath)
    WBargPath$ = abspath
  ELSE
    WBargPath$ = ""
  END IF
END SUB

SUB ToolTypeVal$(theArg$,toolType$) EXTERNAL
DECLARE STRUCT DiskObject *dobj
ADDRESS toolArray, toolTypeValAddr

DECLARE FUNCTION ADDRESS FindToolType(ADDRESS toolArray, STRING toolType) LIBRARY icon

  /* Return a tooltype value from a Wb argument's .info file. */

  LIBRARY "icon.library"

  IF theArg$ <> "" THEN
    dobj = GetDiskObject(theArg$)
    IF dobj = NULL THEN
    	tmpVal$ = ""
    ELSE
    	toolArray = dobj->do_ToolTypes
    	IF toolArray = NULL THEN
	  tmpVal$ = ""
    	ELSE
    	  toolTypeValAddr = FindToolType(toolArray,toolType$)
 	  IF toolTypeValAddr = NULL THEN
	    tmpVal$ = ""
	  ELSE
	    tmpVal$ = CSTR(toolTypeValAddr)
	  END IF
 	END IF
    END IF

    IF dobj <> NULL THEN CALL FreeDiskObject(dobj)
  ELSE
    {* Wb argument is NULL. *}
    tmpVal$ = ""
  END IF

  LIBRARY CLOSE "icon.library"

  ToolTypeVal$ = tmpVal$
END SUB

SUB LONGINT ToolTypeValMatched(toolVal$,value$) EXTERNAL
LONGINT theVal

DECLARE FUNCTION SHORTINT MatchToolValue(toolVal$,value$) LIBRARY icon

  { Return TRUE/FALSE indicating presence/absence of value in ToolType string }

  LIBRARY "icon.library"

  theVal = -MatchToolValue(toolVal$,value$)

  LIBRARY CLOSE "icon.library"

  ToolTypeValMatched = theVal
END SUB

SUB DefaultTool$(theArg$) EXTERNAL
DECLARE STRUCT DiskObject *dobj

  /* Return the default tool from a Wb argument's .info file. */

  LIBRARY "icon.library"

  IF theArg$ <> "" THEN
    dobj = GetDiskObject(theArg$)
    IF dobj = NULL THEN
    	tmpVal$ = ""
    ELSE
    	IF dobj->do_DefaultTool = NULL THEN
	  tmpVal$ = ""
    	ELSE
	  tmpVal$ = CSTR(dobj->do_DefaultTool)
 	END IF
    END IF

    IF dobj <> NULL THEN CALL FreeDiskObject(dobj)
  ELSE
    {* Wb argument is NULL. *}
    tmpVal$ = ""
  END IF

  LIBRARY CLOSE "icon.library"

  DefaultTool$ = tmpVal$
END SUB
