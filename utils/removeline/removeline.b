/*  ACE version of the RemoveLine utility. 
    It will 'shave' off all lines that are put in by the acpp (tested) or
    dcpp (untested) preprocessors.
    It uses a somewhat modified version of Roland Acton's buffered _Read
    routine as used in the ACE Basic Indenter.
    Also the ParseCommandLine SUB from the same program is used.
    Uses two 8K buffers for reading and writing the preprocessed source. */
    
   

LIBRARY "exec.library"

DECLARE FUNCTION CopyMem() LIBRARY "exec.library"
DECLARE SUB SHORTINT ParseCommandLine

DECLARE FUNCTION AllocMem& library exec
DECLARE FUNCTION FreeMem& library exec
DECLARE FUNCTION _Open& library dos
DECLARE FUNCTION _Close& library dos
DECLARE FUNCTION _Read& library dos
DECLARE FUNCTION _Write& library dos
LONGINT srcfilehandle,destfilehandle

SUB SHORTINT ParseCommandLine
  shared srcfilehandle,destfilehandle

  if argcount<>2 then
    print "Command line error."
    print "Usage: ";ARG$(0);" <source-file> <destination-file>"
    ParseCommandLine=0%
  else
	    srcfilehandle=_Open(arg$(1),1005&) 
/*	    srcfilehandle=_Open("t:removeline.beta",1005&) */
	    if srcfilehandle>0& then
	      destfilehandle=_Open(arg$(2),1006&) 
/*	      destfilehandle=_Open("t:removeline.b",1006&) */
	      if destfilehandle>0& then
	        ParseCommandLine=1%
	      else
	        _Close(srcfilehandle)
	        print "Couldn't open file ";arg$(2)
	        ParseCommandLine=0%
	      end if
	    else
	      print "Couldn't open file ";arg$(1)
	      ParseCommandLine=0%
	    end if
	end if
END SUB

SUB RetFail
	PRINT "Out of memory!"
	STOP
END SUB

SUB RemoveLine
	SHARED srcfilehandle,destfilehandle

	ADDRESS BufferStart
	ADDRESS FileLineAddress
	ADDRESS LastLetterAddress

	LONGINT ReadBuffer
	LONGINT WriteBuffer
	LONGINT ReadBufferStart
	LONGINT WriteBufferStart
	LONGINT ReadBufferPos
	LONGINT WriteBufferPos
	LONGINT BufferCount

	SHORTINT Letter

	ReadBuffer=8192&
	WriteBuffer=8192&
	ReadBufferPos=0&
	WriteBufferPos=0&

	ReadBufferStart=AllocMem(ReadBuffer,0&)
	IF (ReadBufferStart=0) THEN
		_Close(srcfilehandle)
		_Close(destfilehandle)
		RetFail
	END IF
	WriteBufferStart=AllocMem(WriteBuffer,0&)
	IF (WriteBufferStart=0) THEN
		_Close(srcfilehandle)
		_Close(destfilehandle)
		RetFail
	END IF

	BufferCount=_Read(srcfilehandle,ReadBufferStart,ReadBuffer)

	IF BufferCount THEN
		IF PEEK(ReadBufferStart)=35% THEN
			REPEAT
				++ReadBufferPos
				IF ReadBufferPos=BufferCount THEN
					BufferCount=_Read(srcfilehandle,ReadBufferStart,ReadBuffer)
					ReadBufferPos=0&
				END IF
			UNTIL (PEEK(ReadBufferStart+ReadBufferPos)=10%) OR (BufferCount=0&)
		END IF
		IF BufferCount THEN
			REPEAT
				REPEAT
					Letter=PEEK(ReadBufferStart+ReadBufferPos)
					POKE WriteBufferStart+WriteBufferPos,Letter
					++ReadBufferPos
					++WriteBufferPos
					IF ReadBufferPos=BufferCount THEN
						BufferCount=_Read(srcfilehandle,ReadBufferStart,ReadBuffer)
						ReadBufferPos=0&
					END IF
					IF WriteBufferPos=WriteBuffer THEN
						_Write(destfilehandle,WriteBufferStart,WriteBuffer)
						WriteBufferPos=0&
					END IF
				UNTIL Letter=10%
				IF PEEK(ReadBufferStart+ReadBufferPos)=35% THEN
					REPEAT
						++ReadBufferPos
						IF ReadBufferPos=BufferCount THEN
							BufferCount=_Read(srcfilehandle,ReadBufferStart,ReadBuffer)
							ReadBufferPos=0&
						END IF
					UNTIL (PEEK(ReadBufferStart+ReadBufferPos)=10%) OR (BufferCount=0&)
				END IF
			UNTIL BufferCount=0&
			IF WriteBufferPos THEN
				_Write(destfilehandle,WriteBufferStart,WriteBufferPos)
			END IF
		END IF
	END IF	

	FreeMem(ReadBufferStart,ReadBuffer)
	FreeMem(WriteBufferStart,WriteBuffer)
	_Close(srcfilehandle)
	_Close(destfilehandle)
END SUB

SHORTINT ParseSuccess

ParseSuccess=ParseCommandLine()
IF ParseSuccess THEN
	PRINT "Removing obsolete lines."
/*	t!=TIMER */
	RemoveLine()
/*	PRINT TIMER-t! */
END IF
END
